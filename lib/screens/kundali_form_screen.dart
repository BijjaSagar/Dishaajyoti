import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';
import '../widgets/inputs/custom_text_field.dart';
import '../widgets/buttons/primary_button.dart';
import '../models/service_model.dart';
import '../models/kundali_model.dart';
import '../models/vedic_kundali_model.dart';
import '../services/kundali_service.dart';
import '../services/vedic_kundali_calculator.dart';
import '../services/kundali_pdf_generator.dart';
import '../services/database_helper.dart';
import 'kundali_list_screen.dart';

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
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;

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

  Future<void> _generateKundali() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select your date of birth'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    if (_selectedTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select your time of birth'),
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
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter valid latitude and longitude'),
          backgroundColor: AppColors.error,
        ),
      );
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
      // Combine date and time
      final birthDateTime = DateTime(
        _selectedDate!.year,
        _selectedDate!.month,
        _selectedDate!.day,
        _selectedTime!.hour,
        _selectedTime!.minute,
      );

      // Create birth details for Vedic calculator
      final birthDetails = BirthDetails(
        name: _nameController.text,
        dateTime: birthDateTime,
        locationName: _placeController.text,
        latitude: latitude,
        longitude: longitude,
      );

      // Calculate Vedic Kundali
      final vedicCalculator = VedicKundaliCalculator(birthDetails);
      final vedicData = await vedicCalculator.calculateKundaliData();

      // Also generate simple Kundali data for backward compatibility
      final kundaliData = await KundaliService.instance.generateKundali(
        dateOfBirth: _selectedDate!,
        timeOfBirth: _timeController.text,
        placeOfBirth: _placeController.text,
      );

      // Create Kundali object
      final kundali = Kundali(
        id: 'KUNDALI_${DateTime.now().millisecondsSinceEpoch}',
        userId: 'user123', // TODO: Get from auth provider
        name: _nameController.text,
        dateOfBirth: _selectedDate!,
        timeOfBirth: _timeController.text,
        placeOfBirth: _placeController.text,
        data: kundaliData,
        createdAt: DateTime.now(),
      );

      // Generate PDF
      final pdfPath = await KundaliPdfGenerator.instance.generatePdf(kundali);

      // Update Kundali with PDF path
      final kundaliWithPdf = Kundali(
        id: kundali.id,
        userId: kundali.userId,
        name: kundali.name,
        dateOfBirth: kundali.dateOfBirth,
        timeOfBirth: kundali.timeOfBirth,
        placeOfBirth: kundali.placeOfBirth,
        pdfPath: pdfPath,
        data: kundali.data,
        createdAt: kundali.createdAt,
      );

      // Save to local database
      await DatabaseHelper.instance.insertKundali(kundaliWithPdf);

      if (mounted) {
        // Close loading dialog
        Navigator.of(context).pop();

        // Navigate to Kundali list screen to show the generated Kundali
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => const KundaliListScreen(),
          ),
        );

        // Show success message
        Future.delayed(const Duration(milliseconds: 500), () {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Kundali generated successfully!'),
                backgroundColor: AppColors.success,
                duration: Duration(seconds: 3),
              ),
            );
          }
        });
      }
    } catch (e) {
      if (mounted) {
        // Close loading dialog
        Navigator.of(context).pop();

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to generate Kundali: ${e.toString()}'),
            backgroundColor: AppColors.error,
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
              decoration: BoxDecoration(
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
              'AI Generating Kundali',
              style: AppTypography.h3.copyWith(
                color: AppColors.primaryBlue,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            // Description
            Text(
              'Calculating planetary positions and creating your personalized birth chart...',
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
          'Free Kundali',
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
                        'Get Your Free Kundali',
                        style: AppTypography.h2.copyWith(
                          color: AppColors.white,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Enter your birth details to generate your personalized Kundali',
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
                  label: 'Full Name',
                  hint: 'Enter your full name',
                  keyboardType: TextInputType.name,
                  textInputAction: TextInputAction.next,
                  prefixIcon: const Icon(
                    Icons.person_outline,
                    color: AppColors.primaryBlue,
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter your name';
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
                      label: 'Date of Birth',
                      hint: 'Select your date of birth',
                      prefixIcon: const Icon(
                        Icons.calendar_today,
                        color: AppColors.primaryBlue,
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please select your date of birth';
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
                      label: 'Time of Birth',
                      hint: 'Select your time of birth',
                      prefixIcon: const Icon(
                        Icons.access_time,
                        color: AppColors.primaryBlue,
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please select your time of birth';
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
                  label: 'Place of Birth',
                  hint: 'Enter your place of birth (e.g., Mumbai, India)',
                  keyboardType: TextInputType.text,
                  textInputAction: TextInputAction.next,
                  prefixIcon: const Icon(
                    Icons.location_on_outlined,
                    color: AppColors.primaryBlue,
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter your place of birth';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),

                // Latitude field
                CustomTextField(
                  controller: _latitudeController,
                  label: 'Latitude',
                  hint: 'e.g., 19.0760 (for Mumbai)',
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
                      return 'Please enter latitude';
                    }
                    final lat = double.tryParse(value);
                    if (lat == null || lat < -90 || lat > 90) {
                      return 'Latitude must be between -90 and 90';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),

                // Longitude field
                CustomTextField(
                  controller: _longitudeController,
                  label: 'Longitude',
                  hint: 'e.g., 72.8777 (for Mumbai)',
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
                      return 'Please enter longitude';
                    }
                    final lon = double.tryParse(value);
                    if (lon == null || lon < -180 || lon > 180) {
                      return 'Longitude must be between -180 and 180';
                    }
                    return null;
                  },
                  onSubmitted: (_) => _generateKundali(),
                ),
                const SizedBox(height: 32),

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
                          'Your Kundali will be calculated using Vedic Astrology with Lahiri Ayanamsa. Includes birth chart, planetary positions, houses, nakshatras, and Vimshottari Dasha.',
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
                  label: 'Generate Free Kundali',
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
