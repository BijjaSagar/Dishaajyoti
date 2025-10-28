import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../l10n/app_localizations.dart';
import '../services/api_service.dart';
import '../services/geocoding_service.dart';
import '../utils/error_handler.dart';
import '../widgets/buttons/primary_button.dart';
import '../widgets/inputs/custom_text_field.dart';

/// Compatibility Check Form Screen
/// Requirements: 7.1, 7.2, 7.3, 7.4
class CompatibilityCheckScreen extends StatefulWidget {
  const CompatibilityCheckScreen({super.key});

  @override
  State<CompatibilityCheckScreen> createState() =>
      _CompatibilityCheckScreenState();
}

class _CompatibilityCheckScreenState extends State<CompatibilityCheckScreen> {
  final _formKey = GlobalKey<FormState>();

  // Person 1 details
  final _person1NameController = TextEditingController();
  final _person1PlaceController = TextEditingController();
  DateTime? _person1Date;
  TimeOfDay? _person1Time;
  double? _person1Latitude;
  double? _person1Longitude;

  // Person 2 details
  final _person2NameController = TextEditingController();
  final _person2PlaceController = TextEditingController();
  DateTime? _person2Date;
  TimeOfDay? _person2Time;
  double? _person2Latitude;
  double? _person2Longitude;

  bool _isChecking = false;
  bool _isFetchingCoords1 = false;
  bool _isFetchingCoords2 = false;

  @override
  void dispose() {
    _person1NameController.dispose();
    _person1PlaceController.dispose();
    _person2NameController.dispose();
    _person2PlaceController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(bool isPerson1) async {
    final l10n = AppLocalizations.of(context)!;
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now().subtract(const Duration(days: 365 * 25)),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      helpText: l10n.compatibility_dob_label,
    );

    if (date != null) {
      setState(() {
        if (isPerson1) {
          _person1Date = date;
        } else {
          _person2Date = date;
        }
      });
    }
  }

  Future<void> _selectTime(bool isPerson1) async {
    final l10n = AppLocalizations.of(context)!;
    final time = await showTimePicker(
      context: context,
      initialTime: const TimeOfDay(hour: 12, minute: 0),
      helpText: l10n.compatibility_time_label,
    );

    if (time != null) {
      setState(() {
        if (isPerson1) {
          _person1Time = time;
        } else {
          _person2Time = time;
        }
      });
    }
  }

  Future<void> _fetchCoordinates(bool isPerson1) async {
    final l10n = AppLocalizations.of(context)!;
    final placeController =
        isPerson1 ? _person1PlaceController : _person2PlaceController;

    if (placeController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.compatibility_place_first)),
      );
      return;
    }

    setState(() {
      if (isPerson1) {
        _isFetchingCoords1 = true;
      } else {
        _isFetchingCoords2 = true;
      }
    });

    try {
      final geocodingService = GeocodingService.instance;
      final coordinates = await geocodingService.getIndianCityCoordinates(
        placeController.text,
      );

      if (coordinates != null) {
        setState(() {
          if (isPerson1) {
            _person1Latitude = coordinates['latitude'];
            _person1Longitude = coordinates['longitude'];
            _isFetchingCoords1 = false;
          } else {
            _person2Latitude = coordinates['latitude'];
            _person2Longitude = coordinates['longitude'];
            _isFetchingCoords2 = false;
          }
        });

        if (mounted) {
          final l10n = AppLocalizations.of(context)!;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(l10n.compatibility_coords_success),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else {
        setState(() {
          if (isPerson1) {
            _isFetchingCoords1 = false;
          } else {
            _isFetchingCoords2 = false;
          }
        });
        if (mounted) {
          final l10n = AppLocalizations.of(context)!;
          ErrorHandler.showError(
            context,
            title: l10n.compatibility_coords_failed,
            message: 'Could not find coordinates for the specified place',
          );
        }
      }
    } catch (e) {
      setState(() {
        if (isPerson1) {
          _isFetchingCoords1 = false;
        } else {
          _isFetchingCoords2 = false;
        }
      });

      if (mounted) {
        final l10n = AppLocalizations.of(context)!;
        ErrorHandler.showError(
          context,
          title: l10n.compatibility_coords_failed,
          message: e.toString(),
        );
      }
    }
  }

  Future<void> _checkCompatibility() async {
    final l10n = AppLocalizations.of(context)!;

    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_person1Date == null || _person2Date == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.compatibility_dob_required)),
      );
      return;
    }

    if (_person1Time == null || _person2Time == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.compatibility_time_required)),
      );
      return;
    }

    if (_person1Latitude == null ||
        _person1Longitude == null ||
        _person2Latitude == null ||
        _person2Longitude == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.compatibility_coords_required),
        ),
      );
      return;
    }

    setState(() {
      _isChecking = true;
    });

    try {
      final apiService = context.read<ApiService>();

      final person1BirthDetails = {
        'name': _person1NameController.text,
        'date_of_birth':
            '${_person1Date!.year}-${_person1Date!.month.toString().padLeft(2, '0')}-${_person1Date!.day.toString().padLeft(2, '0')}',
        'time_of_birth':
            '${_person1Time!.hour.toString().padLeft(2, '0')}:${_person1Time!.minute.toString().padLeft(2, '0')}:00',
        'place_of_birth': _person1PlaceController.text,
        'latitude': _person1Latitude,
        'longitude': _person1Longitude,
      };

      final person2BirthDetails = {
        'name': _person2NameController.text,
        'date_of_birth':
            '${_person2Date!.year}-${_person2Date!.month.toString().padLeft(2, '0')}-${_person2Date!.day.toString().padLeft(2, '0')}',
        'time_of_birth':
            '${_person2Time!.hour.toString().padLeft(2, '0')}:${_person2Time!.minute.toString().padLeft(2, '0')}:00',
        'place_of_birth': _person2PlaceController.text,
        'latitude': _person2Latitude,
        'longitude': _person2Longitude,
      };

      final response = await apiService.checkCompatibility(
        person1BirthDetails: person1BirthDetails,
        person2BirthDetails: person2BirthDetails,
      );

      setState(() {
        _isChecking = false;
      });

      if (mounted) {
        final l10n = AppLocalizations.of(context)!;
        if (response.data['success'] == true) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(l10n.compatibility_analysis_completed),
              backgroundColor: Colors.green,
            ),
          );

          // Navigate to compatibility result screen
          Navigator.pushReplacementNamed(
            context,
            '/compatibility-result',
            arguments: response.data['data'],
          );
        } else {
          ErrorHandler.showError(
            context,
            title: l10n.compatibility_analysis_failed,
            message: response.data['message'] ?? 'Unknown error',
          );
        }
      }
    } catch (e) {
      setState(() {
        _isChecking = false;
      });

      if (mounted) {
        final l10n = AppLocalizations.of(context)!;
        ErrorHandler.showError(
          context,
          title: l10n.compatibility_analysis_failed,
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
        title: Text(l10n.compatibility_title),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                l10n.compatibility_check_title,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                l10n.compatibility_check_subtitle,
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 24),
              _buildPersonSection(
                l10n.compatibility_person1,
                _person1NameController,
                _person1PlaceController,
                _person1Date,
                _person1Time,
                _person1Latitude,
                _person1Longitude,
                _isFetchingCoords1,
                true,
              ),
              const SizedBox(height: 24),
              _buildPersonSection(
                l10n.compatibility_person2,
                _person2NameController,
                _person2PlaceController,
                _person2Date,
                _person2Time,
                _person2Latitude,
                _person2Longitude,
                _isFetchingCoords2,
                false,
              ),
              const SizedBox(height: 32),
              PrimaryButton(
                label: l10n.compatibility_check_button,
                onPressed: _checkCompatibility,
                isLoading: _isChecking,
              ),
              const SizedBox(height: 16),
              Text(
                l10n.compatibility_note,
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
    );
  }

  Widget _buildPersonSection(
    String title,
    TextEditingController nameController,
    TextEditingController placeController,
    DateTime? selectedDate,
    TimeOfDay? selectedTime,
    double? latitude,
    double? longitude,
    bool isFetchingCoords,
    bool isPerson1,
  ) {
    final l10n = AppLocalizations.of(context)!;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).primaryColor,
              ),
            ),
            const SizedBox(height: 16),
            CustomTextField(
              controller: nameController,
              label: l10n.compatibility_name_label,
              hint: l10n.compatibility_name_hint,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return l10n.compatibility_name_required;
                }
                return null;
              },
            ),
            const SizedBox(height: 12),
            InkWell(
              onTap: () => _selectDate(isPerson1),
              child: InputDecorator(
                decoration: InputDecoration(
                  labelText: l10n.compatibility_dob_label,
                  border: const OutlineInputBorder(),
                  suffixIcon: const Icon(Icons.calendar_today),
                ),
                child: Text(
                  selectedDate != null
                      ? '${selectedDate.day}/${selectedDate.month}/${selectedDate.year}'
                      : l10n.compatibility_dob_select,
                  style: TextStyle(
                    color: selectedDate != null ? Colors.black : Colors.grey,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            InkWell(
              onTap: () => _selectTime(isPerson1),
              child: InputDecorator(
                decoration: InputDecoration(
                  labelText: l10n.compatibility_time_label,
                  border: const OutlineInputBorder(),
                  suffixIcon: const Icon(Icons.access_time),
                ),
                child: Text(
                  selectedTime != null
                      ? '${selectedTime.hour.toString().padLeft(2, '0')}:${selectedTime.minute.toString().padLeft(2, '0')}'
                      : l10n.compatibility_time_select,
                  style: TextStyle(
                    color: selectedTime != null ? Colors.black : Colors.grey,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: CustomTextField(
                    controller: placeController,
                    label: l10n.compatibility_place_label,
                    hint: l10n.compatibility_place_hint,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return l10n.compatibility_place_required;
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  onPressed: isFetchingCoords
                      ? null
                      : () => _fetchCoordinates(isPerson1),
                  icon: isFetchingCoords
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.location_on),
                  tooltip: l10n.compatibility_fetch_coords,
                  style: IconButton.styleFrom(
                    backgroundColor: Theme.of(context).primaryColor,
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            if (latitude != null && longitude != null)
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
                        l10n.compatibility_coords_display(
                          latitude.toStringAsFixed(4),
                          longitude.toStringAsFixed(4),
                        ),
                        style: const TextStyle(fontSize: 12),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
