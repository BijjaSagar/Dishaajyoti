import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../l10n/app_localizations.dart';
import '../services/api_service.dart';
import '../services/firebase/cloud_functions_service.dart';
import '../services/firebase/firebase_service_manager.dart';
import '../models/firebase/service_report_model.dart';
import '../utils/error_handler.dart';
import '../widgets/buttons/primary_button.dart';
import '../widgets/inputs/custom_text_field.dart';
import 'report_processing_screen.dart';

/// Numerology Input Form Screen
/// Requirements: 6.1, 6.2, 6.3
class NumerologyInputScreen extends StatefulWidget {
  const NumerologyInputScreen({super.key});

  @override
  State<NumerologyInputScreen> createState() => _NumerologyInputScreenState();
}

class _NumerologyInputScreenState extends State<NumerologyInputScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  DateTime? _selectedDate;
  bool _isAnalyzing = false;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final l10n = AppLocalizations.of(context)!;
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now().subtract(const Duration(days: 365 * 25)),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      helpText: l10n.numerology_dob_label,
    );

    if (date != null) {
      setState(() {
        _selectedDate = date;
      });
    }
  }

  Future<void> _analyzeNumerology() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedDate == null) {
      final l10n = AppLocalizations.of(context)!;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.numerology_dob_required)),
      );
      return;
    }

    setState(() {
      _isAnalyzing = true;
    });

    try {
      // Check if Firebase is available
      final useFirebase = FirebaseServiceManager.instance.isFirebaseAvailable;

      if (useFirebase) {
        // Use Cloud Functions for Numerology analysis
        final userId = FirebaseServiceManager.instance.currentUserId;
        if (userId == null) {
          throw Exception('User not authenticated');
        }

        final dateStr =
            '${_selectedDate!.year}-${_selectedDate!.month.toString().padLeft(2, '0')}-${_selectedDate!.day.toString().padLeft(2, '0')}';

        // Request Numerology report (12h delay)
        final result =
            await CloudFunctionsService.instance.requestNumerologyReport(
          userId: userId,
          details: {
            'fullName': _nameController.text,
            'dateOfBirth': dateStr,
          },
        );

        final reportId = result['reportId'] as String;
        final estimatedDelivery = result['estimatedDelivery'] as String?;

        setState(() {
          _isAnalyzing = false;
        });

        if (mounted) {
          final l10n = AppLocalizations.of(context)!;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                estimatedDelivery != null
                    ? 'Analysis scheduled. Expected delivery: ${DateTime.parse(estimatedDelivery).toLocal()}'
                    : 'Analysis scheduled for 12 hours',
              ),
              backgroundColor: Colors.green,
              duration: const Duration(seconds: 4),
            ),
          );

          // Navigate to report processing screen
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => ReportProcessingScreen(
                reportId: reportId,
                serviceType: ServiceType.numerology,
                estimatedDelivery: estimatedDelivery != null
                    ? DateTime.parse(estimatedDelivery)
                    : null,
              ),
            ),
          );
        }
      } else {
        // Fallback to PHP backend
        final apiService = context.read<ApiService>();

        final dateStr =
            '${_selectedDate!.year}-${_selectedDate!.month.toString().padLeft(2, '0')}-${_selectedDate!.day.toString().padLeft(2, '0')}';

        final response = await apiService.analyzeNumerology(
          fullName: _nameController.text,
          dateOfBirth: dateStr,
        );

        setState(() {
          _isAnalyzing = false;
        });

        if (mounted) {
          if (response.data['success'] == true) {
            final l10n = AppLocalizations.of(context)!;
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(l10n.numerology_analysis_completed),
                backgroundColor: Colors.green,
              ),
            );

            Navigator.pushReplacementNamed(
              context,
              '/numerology-analysis',
              arguments: response.data['data'],
            );
          } else {
            final l10n = AppLocalizations.of(context)!;
            ErrorHandler.showError(
              context,
              title: l10n.numerology_analysis_failed,
              message: response.data['message'] ?? l10n.error_unknown,
            );
          }
        }
      }
    } catch (e) {
      setState(() {
        _isAnalyzing = false;
      });

      if (mounted) {
        final l10n = AppLocalizations.of(context)!;
        final errorMessage = e is CloudFunctionException
            ? CloudFunctionsService.getErrorMessage(e)
            : e.toString();

        ErrorHandler.showError(
          context,
          title: l10n.numerology_analysis_failed,
          message: errorMessage,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.numerology_title),
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
                l10n.numerology_input_header,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                l10n.numerology_input_subtitle,
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 32),
              CustomTextField(
                controller: _nameController,
                label: l10n.numerology_name_label,
                hint: l10n.numerology_name_hint,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return l10n.numerology_name_required;
                  }
                  if (value.length < 2) {
                    return l10n.numerology_name_min_length;
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              InkWell(
                onTap: _selectDate,
                child: InputDecorator(
                  decoration: InputDecoration(
                    labelText: l10n.numerology_dob_label,
                    border: const OutlineInputBorder(),
                    suffixIcon: const Icon(Icons.calendar_today),
                  ),
                  child: Text(
                    _selectedDate != null
                        ? '${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}'
                        : l10n.numerology_dob_select,
                    style: TextStyle(
                      color: _selectedDate != null ? Colors.black : Colors.grey,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 32),
              _buildInfoCard(),
              const SizedBox(height: 32),
              PrimaryButton(
                label: l10n.numerology_analyze_button,
                onPressed: _analyzeNumerology,
                isLoading: _isAnalyzing,
              ),
              const SizedBox(height: 16),
              Text(
                l10n.numerology_note,
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

  Widget _buildInfoCard() {
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
            Row(
              children: [
                Icon(
                  Icons.info_outline,
                  color: Theme.of(context).primaryColor,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  l10n.numerology_what_discover,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _buildInfoItem(
                l10n.numerology_life_path, l10n.numerology_life_path_desc),
            _buildInfoItem(
                l10n.numerology_destiny, l10n.numerology_destiny_desc),
            _buildInfoItem(
                l10n.numerology_soul_urge, l10n.numerology_soul_urge_desc),
            _buildInfoItem(l10n.numerology_lucky_numbers,
                l10n.numerology_lucky_numbers_desc),
            _buildInfoItem(l10n.numerology_compatibility_label,
                l10n.numerology_compatibility_desc),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoItem(String title, String description) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 4),
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
