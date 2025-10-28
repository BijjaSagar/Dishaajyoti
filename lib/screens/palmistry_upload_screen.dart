import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../services/api_service.dart';
import '../services/firebase/cloud_functions_service.dart';
import '../services/firebase/cloud_storage_service.dart';
import '../services/firebase/firebase_service_manager.dart';
import '../models/firebase/service_report_model.dart';
import '../utils/error_handler.dart';
import '../widgets/buttons/primary_button.dart';
import 'report_processing_screen.dart';
import '../l10n/app_localizations.dart';

/// Palmistry Upload Screen
/// Requirements: 5.1
class PalmistryUploadScreen extends StatefulWidget {
  const PalmistryUploadScreen({super.key});

  @override
  State<PalmistryUploadScreen> createState() => _PalmistryUploadScreenState();
}

class _PalmistryUploadScreenState extends State<PalmistryUploadScreen> {
  File? _leftHandImage;
  File? _rightHandImage;
  bool _isUploading = false;
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage(bool isLeftHand) async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1920,
        maxHeight: 1920,
        imageQuality: 85,
      );

      if (image != null) {
        setState(() {
          if (isLeftHand) {
            _leftHandImage = File(image.path);
          } else {
            _rightHandImage = File(image.path);
          }
        });
      }
    } catch (e) {
      if (mounted) {
        ErrorHandler.showError(
          context,
          title: AppLocalizations.of(context)!.palmistry_upload_failed,
          message: e.toString(),
        );
      }
    }
  }

  Future<void> _pickImageFromGallery(bool isLeftHand) async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1920,
        maxHeight: 1920,
        imageQuality: 85,
      );

      if (image != null) {
        setState(() {
          if (isLeftHand) {
            _leftHandImage = File(image.path);
          } else {
            _rightHandImage = File(image.path);
          }
        });
      }
    } catch (e) {
      if (mounted) {
        ErrorHandler.showError(
          context,
          title: AppLocalizations.of(context)!.palmistry_select_failed,
          message: e.toString(),
        );
      }
    }
  }

  void _showImageSourceDialog(bool isLeftHand) {
    final l10n = AppLocalizations.of(context)!;
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: Text(l10n.palmistry_take_photo),
              onTap: () {
                Navigator.pop(context);
                _pickImage(isLeftHand);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: Text(l10n.palmistry_choose_gallery),
              onTap: () {
                Navigator.pop(context);
                _pickImageFromGallery(isLeftHand);
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _uploadAndAnalyze() async {
    if (_leftHandImage == null || _rightHandImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.palmistry_both_required),
        ),
      );
      return;
    }

    setState(() {
      _isUploading = true;
    });

    try {
      // Check if Firebase is available
      final useFirebase = FirebaseServiceManager.instance.isFirebaseAvailable;

      if (useFirebase) {
        // Use Cloud Functions for Palmistry analysis
        final userId = FirebaseServiceManager.instance.currentUserId;
        if (userId == null) {
          throw Exception('User not authenticated');
        }

        // Upload images to Cloud Storage
        final leftHandUrl = await CloudStorageService.instance.uploadImage(
          userId: userId,
          reportId: 'temp_${DateTime.now().millisecondsSinceEpoch}',
          imageFile: _leftHandImage!,
        );

        final rightHandUrl = await CloudStorageService.instance.uploadImage(
          userId: userId,
          reportId: 'temp_${DateTime.now().millisecondsSinceEpoch}',
          imageFile: _rightHandImage!,
        );

        // Request Palmistry analysis (24h delay)
        final result =
            await CloudFunctionsService.instance.requestPalmistryAnalysis(
          userId: userId,
          imageUrl: leftHandUrl, // Primary image
          options: {
            'leftHandUrl': leftHandUrl,
            'rightHandUrl': rightHandUrl,
          },
        );

        final reportId = result['reportId'] as String;
        final estimatedDelivery = result['estimatedDelivery'] as String?;

        setState(() {
          _isUploading = false;
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                estimatedDelivery != null
                    ? 'Analysis scheduled. Expected delivery: ${DateTime.parse(estimatedDelivery).toLocal()}'
                    : 'Analysis scheduled for 24 hours',
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
                serviceType: ServiceType.palmistry,
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

        final uploadResponse = await apiService.uploadPalmImages(
          leftHandImagePath: _leftHandImage!.path,
          rightHandImagePath: _rightHandImage!.path,
        );

        if (uploadResponse.data['success'] == true) {
          final palmistryId = uploadResponse.data['data']['palmistry_id'];

          final analyzeResponse = await apiService.analyzePalmistry(
            palmistryId: palmistryId,
          );

          setState(() {
            _isUploading = false;
          });

          if (analyzeResponse.data['success'] == true) {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                      AppLocalizations.of(context)!.palmistry_upload_success),
                  backgroundColor: Colors.green,
                ),
              );

              Navigator.pushReplacementNamed(
                context,
                '/palmistry-analysis',
                arguments: analyzeResponse.data['data'],
              );
            }
          } else {
            if (mounted) {
              ErrorHandler.showError(
                context,
                title: AppLocalizations.of(context)!.palmistry_analysis_failed,
                message: analyzeResponse.data['message'] ??
                    AppLocalizations.of(context)!.error_unknown,
              );
            }
          }
        } else {
          setState(() {
            _isUploading = false;
          });
          if (mounted) {
            ErrorHandler.showError(
              context,
              title: AppLocalizations.of(context)!.palmistry_analysis_failed,
              message: uploadResponse.data['message'] ??
                  AppLocalizations.of(context)!.error_unknown,
            );
          }
        }
      }
    } catch (e) {
      setState(() {
        _isUploading = false;
      });
      if (mounted) {
        final errorMessage = e is CloudFunctionException
            ? CloudFunctionsService.getErrorMessage(e)
            : e.toString();

        ErrorHandler.showError(
          context,
          title: AppLocalizations.of(context)!.palmistry_analysis_failed,
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
        title: Text(l10n.palmistry_title),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              l10n.palmistry_upload_header,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              l10n.palmistry_upload_subtitle,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 32),
            _buildImageCard(
              title: l10n.palmistry_left_hand_label,
              image: _leftHandImage,
              onTap: () => _showImageSourceDialog(true),
              onRemove: () => setState(() => _leftHandImage = null),
            ),
            const SizedBox(height: 16),
            _buildImageCard(
              title: l10n.palmistry_right_hand_label,
              image: _rightHandImage,
              onTap: () => _showImageSourceDialog(false),
              onRemove: () => setState(() => _rightHandImage = null),
            ),
            const SizedBox(height: 32),
            PrimaryButton(
              label: l10n.palmistry_analyze_button,
              onPressed: _uploadAndAnalyze,
              isLoading: _isUploading,
            ),
            const SizedBox(height: 16),
            Text(
              l10n.palmistry_tips,
              style: const TextStyle(
                fontSize: 12,
                color: Colors.grey,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImageCard({
    required String title,
    required File? image,
    required VoidCallback onTap,
    required VoidCallback onRemove,
  }) {
    final l10n = AppLocalizations.of(context)!;
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (image != null)
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.red),
                    onPressed: onRemove,
                    tooltip: l10n.palmistry_remove_image,
                  ),
              ],
            ),
          ),
          if (image != null)
            ClipRRect(
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(12),
                bottomRight: Radius.circular(12),
              ),
              child: Image.file(
                image,
                height: 200,
                fit: BoxFit.cover,
              ),
            )
          else
            InkWell(
              onTap: onTap,
              child: Container(
                height: 200,
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(12),
                    bottomRight: Radius.circular(12),
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.add_a_photo,
                      size: 48,
                      color: Colors.grey.shade400,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      l10n.palmistry_tap_to_capture,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
