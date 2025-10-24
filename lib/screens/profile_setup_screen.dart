import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';
import '../widgets/buttons/primary_button.dart';
import '../widgets/buttons/secondary_button.dart';
import '../widgets/inputs/custom_text_field.dart';
import '../utils/validators.dart';

/// Profile setup screen with 3-step wizard for new users
/// Collects birth details, career information, and challenges
class ProfileSetupScreen extends StatefulWidget {
  const ProfileSetupScreen({super.key});

  @override
  State<ProfileSetupScreen> createState() => _ProfileSetupScreenState();
}

class _ProfileSetupScreenState extends State<ProfileSetupScreen> {
  int _currentStep = 0;
  final int _totalSteps = 3;

  // Form keys for validation
  final _step1FormKey = GlobalKey<FormState>();
  final _step2FormKey = GlobalKey<FormState>();
  final _step3FormKey = GlobalKey<FormState>();

  // Step 1: Birth Details controllers
  final _dobController = TextEditingController();
  final _timeOfBirthController = TextEditingController();
  final _placeOfBirthController = TextEditingController();

  // Step 2: Career Information controllers
  final _careerController = TextEditingController();
  final _goalsController = TextEditingController();

  // Step 3: Challenges controller
  final _challengesController = TextEditingController();

  // Error texts
  String? _dobError;
  String? _timeOfBirthError;
  String? _placeOfBirthError;
  String? _careerError;
  String? _goalsError;
  String? _challengesError;

  @override
  void dispose() {
    _dobController.dispose();
    _timeOfBirthController.dispose();
    _placeOfBirthController.dispose();
    _careerController.dispose();
    _goalsController.dispose();
    _challengesController.dispose();
    super.dispose();
  }

  void _nextStep() {
    if (_validateCurrentStep()) {
      if (_currentStep < _totalSteps - 1) {
        setState(() {
          _currentStep++;
        });
      } else {
        _completeProfileSetup();
      }
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      setState(() {
        _currentStep--;
      });
    }
  }

  bool _validateCurrentStep() {
    setState(() {
      _dobError = null;
      _timeOfBirthError = null;
      _placeOfBirthError = null;
      _careerError = null;
      _goalsError = null;
      _challengesError = null;
    });

    switch (_currentStep) {
      case 0:
        return _validateStep1();
      case 1:
        return _validateStep2();
      case 2:
        return _validateStep3();
      default:
        return false;
    }
  }

  bool _validateStep1() {
    bool isValid = true;

    final dobValidation = Validators.required(_dobController.text);
    if (dobValidation != null) {
      setState(() => _dobError = dobValidation);
      isValid = false;
    }

    final timeValidation = Validators.required(_timeOfBirthController.text);
    if (timeValidation != null) {
      setState(() => _timeOfBirthError = timeValidation);
      isValid = false;
    }

    final placeValidation = Validators.required(_placeOfBirthController.text);
    if (placeValidation != null) {
      setState(() => _placeOfBirthError = placeValidation);
      isValid = false;
    }

    return isValid;
  }

  bool _validateStep2() {
    bool isValid = true;

    final careerValidation = Validators.required(_careerController.text);
    if (careerValidation != null) {
      setState(() => _careerError = careerValidation);
      isValid = false;
    }

    final goalsValidation = Validators.required(_goalsController.text);
    if (goalsValidation != null) {
      setState(() => _goalsError = goalsValidation);
      isValid = false;
    }

    return isValid;
  }

  bool _validateStep3() {
    final challengesValidation =
        Validators.required(_challengesController.text);
    if (challengesValidation != null) {
      setState(() => _challengesError = challengesValidation);
      return false;
    }

    return true;
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().subtract(const Duration(days: 365 * 20)),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primaryOrange,
              onPrimary: AppColors.white,
              surface: AppColors.white,
              onSurface: AppColors.textPrimary,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _dobController.text =
            '${picked.day.toString().padLeft(2, '0')}/${picked.month.toString().padLeft(2, '0')}/${picked.year}';
      });
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primaryOrange,
              onPrimary: AppColors.white,
              surface: AppColors.white,
              onSurface: AppColors.textPrimary,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _timeOfBirthController.text = picked.format(context);
      });
    }
  }

  void _completeProfileSetup() {
    // TODO: Save profile data to backend
    // For now, navigate to dashboard (placeholder)
    // In a real implementation, this would call an API service

    // Show success message
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Profile setup completed successfully!'),
        backgroundColor: AppColors.success,
      ),
    );

    // Navigate to dashboard
    // Navigator.pushReplacementNamed(context, '/dashboard');
    // For now, just pop back
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        leading: _currentStep > 0
            ? IconButton(
                icon:
                    const Icon(Icons.arrow_back, color: AppColors.textPrimary),
                onPressed: _previousStep,
              )
            : IconButton(
                icon:
                    const Icon(Icons.arrow_back, color: AppColors.textPrimary),
                onPressed: () => Navigator.pop(context),
              ),
        title: Text(
          'Complete Your Profile',
          style: AppTypography.h3.copyWith(color: AppColors.textPrimary),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Progress indicator
            _buildProgressIndicator(),

            // Step content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: _buildStepContent(),
              ),
            ),

            // Navigation buttons
            _buildNavigationButtons(),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressIndicator() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Step ${_currentStep + 1} of $_totalSteps',
                style: AppTypography.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                '${((_currentStep + 1) / _totalSteps * 100).toInt()}%',
                style: AppTypography.bodyMedium.copyWith(
                  color: AppColors.primaryOrange,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: (_currentStep + 1) / _totalSteps,
              backgroundColor: AppColors.lightGray,
              valueColor: const AlwaysStoppedAnimation<Color>(
                AppColors.primaryOrange,
              ),
              minHeight: 8,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepContent() {
    switch (_currentStep) {
      case 0:
        return _buildBirthDetails();
      case 1:
        return _buildCareerInfo();
      case 2:
        return _buildChallenges();
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildBirthDetails() {
    return Form(
      key: _step1FormKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Birth Details',
            style: AppTypography.h2.copyWith(color: AppColors.textPrimary),
          ),
          const SizedBox(height: 8),
          Text(
            'Help us understand your astrological profile',
            style: AppTypography.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 32),
          CustomTextField(
            controller: _dobController,
            label: 'Date of Birth',
            hint: 'DD/MM/YYYY',
            errorText: _dobError,
            keyboardType: TextInputType.none,
            suffixIcon: IconButton(
              icon: const Icon(
                Icons.calendar_today,
                color: AppColors.primaryOrange,
              ),
              onPressed: () => _selectDate(context),
            ),
            onChanged: (_) {
              if (_dobError != null) {
                setState(() => _dobError = null);
              }
            },
          ),
          const SizedBox(height: 20),
          CustomTextField(
            controller: _timeOfBirthController,
            label: 'Time of Birth',
            hint: 'HH:MM AM/PM',
            errorText: _timeOfBirthError,
            keyboardType: TextInputType.none,
            suffixIcon: IconButton(
              icon:
                  const Icon(Icons.access_time, color: AppColors.primaryOrange),
              onPressed: () => _selectTime(context),
            ),
            onChanged: (_) {
              if (_timeOfBirthError != null) {
                setState(() => _timeOfBirthError = null);
              }
            },
          ),
          const SizedBox(height: 20),
          CustomTextField(
            controller: _placeOfBirthController,
            label: 'Place of Birth',
            hint: 'City, State, Country',
            errorText: _placeOfBirthError,
            keyboardType: TextInputType.text,
            textInputAction: TextInputAction.done,
            prefixIcon:
                const Icon(Icons.location_on, color: AppColors.primaryOrange),
            onChanged: (_) {
              if (_placeOfBirthError != null) {
                setState(() => _placeOfBirthError = null);
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildCareerInfo() {
    return Form(
      key: _step2FormKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Career Information',
            style: AppTypography.h2.copyWith(color: AppColors.textPrimary),
          ),
          const SizedBox(height: 8),
          Text(
            'Tell us about your professional journey',
            style: AppTypography.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 32),
          CustomTextField(
            controller: _careerController,
            label: 'Current/Past Career',
            hint: 'e.g., Software Engineer, Teacher, Business Owner',
            errorText: _careerError,
            keyboardType: TextInputType.text,
            textInputAction: TextInputAction.next,
            prefixIcon: const Icon(Icons.work, color: AppColors.primaryOrange),
            onChanged: (_) {
              if (_careerError != null) {
                setState(() => _careerError = null);
              }
            },
          ),
          const SizedBox(height: 20),
          CustomTextField(
            controller: _goalsController,
            label: 'Career Goals',
            hint: 'What are your professional aspirations?',
            errorText: _goalsError,
            keyboardType: TextInputType.multiline,
            textInputAction: TextInputAction.newline,
            maxLines: 4,
            prefixIcon: const Padding(
              padding: EdgeInsets.only(bottom: 60),
              child: Icon(Icons.flag, color: AppColors.primaryOrange),
            ),
            onChanged: (_) {
              if (_goalsError != null) {
                setState(() => _goalsError = null);
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildChallenges() {
    return Form(
      key: _step3FormKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Your Challenges',
            style: AppTypography.h2.copyWith(color: AppColors.textPrimary),
          ),
          const SizedBox(height: 8),
          Text(
            'Share what you\'re currently facing',
            style: AppTypography.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 32),
          CustomTextField(
            controller: _challengesController,
            label: 'Current Challenges',
            hint: 'What obstacles or difficulties are you experiencing?',
            errorText: _challengesError,
            keyboardType: TextInputType.multiline,
            textInputAction: TextInputAction.newline,
            maxLines: 5,
            prefixIcon: const Padding(
              padding: EdgeInsets.only(bottom: 80),
              child: Icon(Icons.psychology, color: AppColors.primaryOrange),
            ),
            onChanged: (_) {
              if (_challengesError != null) {
                setState(() => _challengesError = null);
              }
            },
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.lightBlue,
              border: Border.all(color: AppColors.primaryBlue, width: 1),
              borderRadius: BorderRadius.circular(12),
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
                    'Your information is kept private and secure. We use it only to provide personalized guidance.',
                    style: AppTypography.bodySmall.copyWith(
                      color: AppColors.darkBlue,
                      height: 1.5,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavigationButtons() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            if (_currentStep > 0) ...[
              Expanded(
                child: SecondaryButton(
                  label: 'Back',
                  onPressed: _previousStep,
                  height: 56,
                ),
              ),
              const SizedBox(width: 16),
            ],
            Expanded(
              flex: _currentStep > 0 ? 1 : 1,
              child: PrimaryButton(
                label: _currentStep < _totalSteps - 1 ? 'Next' : 'Complete',
                onPressed: _nextStep,
                height: 56,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
