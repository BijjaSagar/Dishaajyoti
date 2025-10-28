import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/api_service.dart';
import '../services/geocoding_service.dart';
import '../utils/error_handler.dart';
import '../widgets/buttons/primary_button.dart';
import '../widgets/inputs/custom_text_field.dart';
import '../widgets/dialogs/loading_overlay.dart';
import '../l10n/app_localizations.dart';

/// Kundali Input Form Screen
/// Requirements: 1.1, 9.1, 9.2
class KundaliInputScreen extends StatefulWidget {
  const KundaliInputScreen({super.key});

  @override
  State<KundaliInputScreen> createState() => _KundaliInputScreenState();
}

class _KundaliInputScreenState extends State<KundaliInputScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _placeController = TextEditingController();

  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  double? _latitude;
  double? _longitude;
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _placeController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final l10n = AppLocalizations.of(context)!;
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now().subtract(const Duration(days: 365 * 25)),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      helpText: l10n.kundali_input_dob_hint,
    );

    if (date != null) {
      setState(() {
        _selectedDate = date;
      });
    }
  }

  Future<void> _selectTime() async {
    final l10n = AppLocalizations.of(context)!;
    final time = await showTimePicker(
      context: context,
      initialTime: const TimeOfDay(hour: 12, minute: 0),
      helpText: l10n.kundali_input_time_hint,
    );

    if (time != null) {
      setState(() {
        _selectedTime = time;
      });
    }
  }

  Future<void> _fetchCoordinates() async {
    final l10n = AppLocalizations.of(context)!;
    if (_placeController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.kundali_input_place_first)),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final geocodingService = GeocodingService.instance;
      final coordinates = await geocodingService.getIndianCityCoordinates(
        _placeController.text,
      );

      if (coordinates != null) {
        setState(() {
          _latitude = coordinates['latitude'];
          _longitude = coordinates['longitude'];
          _isLoading = false;
        });

        if (mounted) {
          final l10n = AppLocalizations.of(context)!;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(l10n.kundali_input_coords_success),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else {
        setState(() {
          _isLoading = false;
        });
        if (mounted) {
          final l10n = AppLocalizations.of(context)!;
          ErrorHandler.showError(
            context,
            title: l10n.kundali_input_coords_failed,
            message: l10n.kundali_form_coords_not_found,
          );
        }
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });

      if (mounted) {
        final l10n = AppLocalizations.of(context)!;
        ErrorHandler.showError(
          context,
          title: l10n.kundali_input_coords_failed,
          message: e.toString(),
        );
      }
    }
  }

  Future<void> _generateKundali() async {
    final l10n = AppLocalizations.of(context)!;
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.kundali_input_dob_required)),
      );
      return;
    }

    if (_selectedTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.kundali_input_time_required)),
      );
      return;
    }

    if (_latitude == null || _longitude == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.kundali_input_coords_required),
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final apiService = context.read<ApiService>();

      final dateStr =
          '${_selectedDate!.year}-${_selectedDate!.month.toString().padLeft(2, '0')}-${_selectedDate!.day.toString().padLeft(2, '0')}';
      final timeStr =
          '${_selectedTime!.hour.toString().padLeft(2, '0')}:${_selectedTime!.minute.toString().padLeft(2, '0')}:00';

      final response = await apiService.generateKundali(
        name: _nameController.text,
        dateOfBirth: dateStr,
        timeOfBirth: timeStr,
        placeOfBirth: _placeController.text,
        latitude: _latitude!,
        longitude: _longitude!,
      );

      setState(() {
        _isLoading = false;
      });

      if (mounted) {
        final l10n = AppLocalizations.of(context)!;
        if (response.data['success'] == true) {
          final kundaliId = response.data['data']['kundali_id'];

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(l10n.kundali_input_success),
              backgroundColor: Colors.green,
            ),
          );

          // Navigate to Kundali detail screen
          Navigator.pushReplacementNamed(
            context,
            '/kundali-detail',
            arguments: kundaliId,
          );
        } else {
          ErrorHandler.showError(
            context,
            title: l10n.kundali_input_failed,
            message: response.data['message'] ?? l10n.error_unknown,
          );
        }
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });

      if (mounted) {
        final l10n = AppLocalizations.of(context)!;
        ErrorHandler.showError(
          context,
          title: l10n.kundali_input_failed,
          message: e.toString(),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.kundali_input_title),
        elevation: 0,
      ),
      body: LoadingOverlay(
        isLoading: _isLoading,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  l10n.kundali_input_header,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  l10n.kundali_input_subtitle,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 24),
                CustomTextField(
                  controller: _nameController,
                  label: l10n.kundali_input_name_label,
                  hint: l10n.kundali_input_name_hint,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return l10n.kundali_input_name_required;
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                InkWell(
                  onTap: _selectDate,
                  child: InputDecorator(
                    decoration: InputDecoration(
                      labelText: l10n.kundali_input_dob_label,
                      border: const OutlineInputBorder(),
                      suffixIcon: const Icon(Icons.calendar_today),
                    ),
                    child: Text(
                      _selectedDate != null
                          ? '${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}'
                          : l10n.kundali_input_dob_select,
                      style: TextStyle(
                        color:
                            _selectedDate != null ? Colors.black : Colors.grey,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                InkWell(
                  onTap: _selectTime,
                  child: InputDecorator(
                    decoration: InputDecoration(
                      labelText: l10n.kundali_input_time_label,
                      border: const OutlineInputBorder(),
                      suffixIcon: const Icon(Icons.access_time),
                    ),
                    child: Text(
                      _selectedTime != null
                          ? '${_selectedTime!.hour.toString().padLeft(2, '0')}:${_selectedTime!.minute.toString().padLeft(2, '0')}'
                          : l10n.kundali_input_time_select,
                      style: TextStyle(
                        color:
                            _selectedTime != null ? Colors.black : Colors.grey,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: CustomTextField(
                        controller: _placeController,
                        label: l10n.kundali_input_place_label,
                        hint: l10n.kundali_input_place_hint,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return l10n.kundali_input_place_required;
                          }
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      onPressed: _fetchCoordinates,
                      icon: const Icon(Icons.location_on),
                      tooltip: l10n.kundali_input_fetch_coords,
                      style: IconButton.styleFrom(
                        backgroundColor: Theme.of(context).primaryColor,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                if (_latitude != null && _longitude != null)
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.green.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.green.shade200),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.check_circle,
                            color: Colors.green, size: 20),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            l10n.kundali_input_coords_display(
                              _latitude!.toStringAsFixed(4),
                              _longitude!.toStringAsFixed(4),
                            ),
                            style: const TextStyle(fontSize: 12),
                          ),
                        ),
                      ],
                    ),
                  ),
                const SizedBox(height: 32),
                PrimaryButton(
                  label: l10n.kundali_input_generate,
                  onPressed: _generateKundali,
                  isLoading: _isLoading,
                ),
                const SizedBox(height: 16),
                Text(
                  l10n.kundali_input_note,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                    fontStyle: FontStyle.italic,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
