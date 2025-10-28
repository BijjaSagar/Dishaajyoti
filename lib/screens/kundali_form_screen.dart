import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';
import '../widgets/inputs/custom_text_field.dart';
import '../widgets/buttons/primary_button.dart';
import '../models/service_model.dart';
import '../models/kundali_model.dart';
import '../models/vedic_kundali_model.dart';
import '../models/chart_data_model.dart';
import '../models/firebase/service_report_model.dart';
import '../services/kundali_chart_service.dart';
import '../services/vedic_kundali_calculator.dart';
import '../services/professional_kundali_pdf_generator.dart';
import '../services/geocoding_service.dart';
import '../services/firebase/cloud_functions_service.dart';
import '../services/firebase/firebase_service_manager.dart';
import 'kundali_list_screen.dart';
import 'report_processing_screen.dart';
import '../l10n/app_localizations.dart';

/// Kundali Form Screen for collecting birth details
/// Free service - no payment required
class KundaliFormScreen extends StatefulWidget {
  final Service service;

  const KundaliFormScreen({
    super.key,
    required this.service,
  });

  @override
  State<KundaliFormScreen> createState() => _KundaliFormScreenState();
}

class _KundaliFormScreenState extends State<KundaliFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _dateController = TextEditingController();
  final _timeController = TextEditingController();
  final _placeController = TextEditingController();
  final _latitudeController = TextEditingController();
  final _longitudeController = TextEditingController();

  bool _isLoading = false;
  bool _isFetchingCoordinates = false;
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  ChartStyle _selectedChartStyle = ChartStyle.northIndian;

  @override
  void dispose() {
    _nameController.dispose();
    _dateController.dispose();
    _timeController.dispose();
    _placeController.dispose();
    _latitudeController.dispose();
    _longitudeController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().subtract(const Duration(days: 365 * 25)),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primaryOrange,
              onPrimary: AppColors.white,
              onSurface: AppColors.textPrimary,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        _dateController.text = '${picked.day}/${picked.month}/${picked.year}';
      });
    }
  }

  Future<void> _selectTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primaryOrange,
              onPrimary: AppColors.white,
              onSurface: AppColors.textPrimary,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && picked != _selectedTime) {
      setState(() {
        _selectedTime = picked;
        _timeController.text = picked.format(context);
      });
    }
  }

  Future<void> _fetchCoordinates() async {
    final l10n = AppLocalizations.of(context)!;
    final placeName = _placeController.text.trim();

    if (placeName.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.kundali_input_place_first),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    setState(() {
      _isFetchingCoordinates = true;
    });

    try {
      final coordinates =
          await GeocodingService.instance.getIndianCityCoordinates(placeName);

      if (coordinates != null) {
        setState(() {
          _latitudeController.text =
              coordinates['latitude']!.toStringAsFixed(4);
          _longitudeController.text =
              coordinates['longitude']!.toStringAsFixed(4);
        });

        if (mounted) {
          final l10n = AppLocalizations.of(context)!;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(l10n.kundali_form_coords_found(placeName)),
              backgroundColor: AppColors.success,
            ),
          );
        }
      } else {
        if (mounted) {
          final l10n = AppLocalizations.of(context)!;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(l10n.kundali_form_coords_not_found),
              backgroundColor: AppColors.error,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        final l10n = AppLocalizations.of(context)!;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${l10n.common_error}: ${e.toString()}'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isFetchingCoordinates = false;
        });
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
        SnackBar(
          content: Text(l10n.kundali_form_dob_required),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    if (_selectedTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.kundali_form_time_required),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    // Validate latitude and longitude
    final latitude = double.tryParse(_latitudeController.text);
    final longitude = double.tryParse(_longitudeController.text);

    if (latitude == null || longitude == null) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                '${l10n.kundali_form_latitude_required} & ${l10n.kundali_form_longitude_required}'),
            backgroundColor: AppColors.error,
          ),
        );
      }
      return;
    }

    // Show loading dialog
    if (mounted) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => _buildLoadingDialog(),
      );
    }

    try {
      // Check if Firebase is available
      final useFirebase = FirebaseServiceManager.instance.isFirebaseAvailable;

      if (useFirebase) {
        // Use Cloud Functions for Kundali generation
        final userId = FirebaseServiceManager.instance.currentUserId;
        if (userId == null) {
          throw Exception('User not authenticated');
        }

        // Combine date and time
        final birthDateTime = DateTime(
          _selectedDate!.year,
          _selectedDate!.month,
          _selectedDate!.day,
          _selectedTime!.hour,
          _selectedTime!.minute,
        );

        // Prepare birth details for Cloud Function
        final birthDetails = {
          'name': _nameController.text,
          'dateOfBirth': birthDateTime.toIso8601String(),
          'timeOfBirth': _timeController.text,
          'placeOfBirth': _placeController.text,
          'latitude': latitude,
          'longitude': longitude,
        };

        // Call Cloud Function
        final result = await CloudFunctionsService.instance.generateKundali(
          userId: userId,
          birthDetails: birthDetails,
          chartStyle: _selectedChartStyle.toString().split('.').last,
        );

        final reportId = result['reportId'] as String;

        if (mounted) {
          // Close loading dialog
          Navigator.of(context).pop();

          // Navigate to report processing screen with real-time updates
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (context) => ReportProcessingScreen(
                reportId: reportId,
                serviceType: ServiceType.kundali,
              ),
            ),
          );
        }
      } else {
        // Fallback to local generation
        final birthDateTime = DateTime(
          _selectedDate!.year,
          _selectedDate!.month,
          _selectedDate!.day,
          _selectedTime!.hour,
          _selectedTime!.minute,
        );

        final birthDetails = BirthDetails(
          name: _nameController.text,
          dateTime: birthDateTime,
          locationName: _placeController.text,
          latitude: latitude,
          longitude: longitude,
        );

        final kundaliWithChart =
            await KundaliChartService.instance.generateKundaliWithChart(
          birthDetails: birthDetails,
          chartStyle: _selectedChartStyle,
        );

        final vedicCalculator = VedicKundaliCalculator(birthDetails);
        final vedicData = await vedicCalculator.calculateKundaliData();

        final pdfPath =
            await ProfessionalKundaliPdfGenerator.instance.generatePdf(
          Kundali(
            id: kundaliWithChart.id,
            userId: kundaliWithChart.userId,
            name: kundaliWithChart.name,
            dateOfBirth: kundaliWithChart.dateOfBirth,
            timeOfBirth: kundaliWithChart.timeOfBirth,
            placeOfBirth: kundaliWithChart.placeOfBirth,
            data: kundaliWithChart.data,
            createdAt: kundaliWithChart.createdAt,
          ),
          vedicData,
        );

        final finalKundali = kundaliWithChart.copyWith(pdfPath: pdfPath);
        await KundaliChartService.instance.saveKundali(finalKundali);

        if (mounted) {
          Navigator.of(context).pop();
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (context) => const KundaliListScreen(),
            ),
          );

          Future.delayed(const Duration(milliseconds: 500), () {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(l10n.kundali_form_success),
                  backgroundColor: AppColors.success,
                  duration: const Duration(seconds: 3),
                ),
              );
            }
          });
        }
      }
    } catch (e) {
      if (mounted) {
        Navigator.of(context).pop();

        final errorMessage = e is CloudFunctionException
            ? CloudFunctionsService.getErrorMessage(e)
            : e.toString();

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.kundali_form_failed(errorMessage)),
            backgroundColor: AppColors.error,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Widget _buildLoadingDialog() {
    final l10n = AppLocalizations.of(context)!;
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // AI Animation Icon
            Container(
              width: 80,
              height: 80,
              decoration: const BoxDecoration(
                gradient: AppColors.primaryGradient,
                shape: BoxShape.circle,
              ),
              child: const Center(
                child: Text(
                  '🤖',
                  style: TextStyle(fontSize: 40),
                ),
              ),
            ),
            const SizedBox(height: 24),
            // Loading indicator
            const CircularProgressIndicator(
              valueColor:
                  AlwaysStoppedAnimation<Color>(AppColors.primaryOrange),
            ),
            const SizedBox(height: 24),
            // Title
            Text(
              l10n.kundali_form_generating_title,
              style: AppTypography.h3.copyWith(
                color: AppColors.primaryBlue,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            // Description
            Text(
              l10n.kundali_form_generating_message,
              style: AppTypography.bodySmall.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.primaryBlue),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          l10n.kundali_form_title,
          style: AppTypography.h3.copyWith(
            color: AppColors.primaryBlue,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Header
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: AppColors.primaryGradient,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    children: [
                      const Text(
                        '🌟',
                        style: TextStyle(fontSize: 48),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        l10n.kundali_form_header,
                        style: AppTypography.h2.copyWith(
                          color: AppColors.white,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        l10n.kundali_form_subtitle,
                        style: AppTypography.bodyMedium.copyWith(
                          color: AppColors.white.withValues(alpha: 0.9),
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),

                // Name field
                CustomTextField(
                  controller: _nameController,
                  label: l10n.kundali_form_name_label,
                  hint: l10n.kundali_form_name_hint,
                  keyboardType: TextInputType.name,
                  textInputAction: TextInputAction.next,
                  prefixIcon: const Icon(
                    Icons.person_outline,
                    color: AppColors.primaryBlue,
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return l10n.kundali_form_name_required;
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),

                // Date of Birth field
                GestureDetector(
                  onTap: _selectDate,
                  child: AbsorbPointer(
                    child: CustomTextField(
                      controller: _dateController,
                      label: l10n.kundali_form_dob_label,
                      hint: l10n.kundali_form_dob_hint,
                      prefixIcon: const Icon(
                        Icons.calendar_today,
                        color: AppColors.primaryBlue,
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return l10n.kundali_form_dob_required;
                        }
                        return null;
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Time of Birth field
                GestureDetector(
                  onTap: _selectTime,
                  child: AbsorbPointer(
                    child: CustomTextField(
                      controller: _timeController,
                      label: l10n.kundali_form_time_label,
                      hint: l10n.kundali_form_time_hint,
                      prefixIcon: const Icon(
                        Icons.access_time,
                        color: AppColors.primaryBlue,
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return l10n.kundali_form_time_required;
                        }
                        return null;
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Place of Birth field
                CustomTextField(
                  controller: _placeController,
                  label: l10n.kundali_form_place_label,
                  hint: l10n.kundali_form_place_hint,
                  keyboardType: TextInputType.text,
                  textInputAction: TextInputAction.next,
                  prefixIcon: const Icon(
                    Icons.location_on_outlined,
                    color: AppColors.primaryBlue,
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return l10n.kundali_form_place_required;
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),

                // Auto-fetch coordinates button
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed:
                        _isFetchingCoordinates ? null : _fetchCoordinates,
                    icon: _isFetchingCoordinates
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                AppColors.primaryOrange,
                              ),
                            ),
                          )
                        : const Icon(Icons.my_location),
                    label: Text(
                      _isFetchingCoordinates
                          ? l10n.kundali_form_fetching_coords
                          : l10n.kundali_form_auto_fill_coords,
                    ),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.primaryOrange,
                      side: const BorderSide(color: AppColors.primaryOrange),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Latitude field
                CustomTextField(
                  controller: _latitudeController,
                  label: l10n.kundali_form_latitude_label,
                  hint: l10n.kundali_form_latitude_hint,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                    signed: true,
                  ),
                  textInputAction: TextInputAction.next,
                  prefixIcon: const Icon(
                    Icons.my_location,
                    color: AppColors.primaryBlue,
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return l10n.kundali_form_latitude_required;
                    }
                    final lat = double.tryParse(value);
                    if (lat == null || lat < -90 || lat > 90) {
                      return l10n.kundali_form_latitude_invalid;
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),

                // Longitude field
                CustomTextField(
                  controller: _longitudeController,
                  label: l10n.kundali_form_longitude_label,
                  hint: l10n.kundali_form_longitude_hint,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                    signed: true,
                  ),
                  textInputAction: TextInputAction.done,
                  prefixIcon: const Icon(
                    Icons.place,
                    color: AppColors.primaryBlue,
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return l10n.kundali_form_longitude_required;
                    }
                    final lon = double.tryParse(value);
                    if (lon == null || lon < -180 || lon > 180) {
                      return l10n.kundali_form_longitude_invalid;
                    }
                    return null;
                  },
                  onSubmitted: (_) => _generateKundali(),
                ),
                const SizedBox(height: 32),

                // Chart Style Selection
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.primaryOrange.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppColors.primaryOrange.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(
                            Icons.style,
                            color: AppColors.primaryOrange,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Chart Style',
                            style: AppTypography.bodyMedium.copyWith(
                              fontWeight: FontWeight.bold,
                              color: AppColors.primaryBlue,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: RadioListTile<ChartStyle>(
                              title: const Text('North Indian'),
                              subtitle: const Text('Diamond shape'),
                              value: ChartStyle.northIndian,
                              groupValue: _selectedChartStyle,
                              onChanged: (value) {
                                setState(() {
                                  _selectedChartStyle = value!;
                                });
                              },
                              activeColor: AppColors.primaryOrange,
                              contentPadding: EdgeInsets.zero,
                              dense: true,
                            ),
                          ),
                          Expanded(
                            child: RadioListTile<ChartStyle>(
                              title: const Text('South Indian'),
                              subtitle: const Text('Square shape'),
                              value: ChartStyle.southIndian,
                              groupValue: _selectedChartStyle,
                              onChanged: (value) {
                                setState(() {
                                  _selectedChartStyle = value!;
                                });
                              },
                              activeColor: AppColors.primaryOrange,
                              contentPadding: EdgeInsets.zero,
                              dense: true,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Info box
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.lightBlue.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppColors.primaryBlue.withValues(alpha: 0.2),
                    ),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(
                        Icons.info_outline,
                        color: AppColors.primaryBlue,
                        size: 20,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          l10n.kundali_form_info,
                          style: AppTypography.bodySmall.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),

                // Generate button
                PrimaryButton(
                  label: l10n.kundali_form_generate,
                  onPressed: _isLoading ? null : _generateKundali,
                  isLoading: _isLoading,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
