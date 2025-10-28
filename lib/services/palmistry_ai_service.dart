import 'dart:io';
import 'api_service.dart';
import 'kundali_ai_service.dart';

/// Service class for Palmistry AI operations
/// Requirements: 5.1, 9.1
class PalmistryAIService {
  final ApiService _apiService;
  static const int maxFileSizeBytes = 5 * 1024 * 1024; // 5MB

  PalmistryAIService({ApiService? apiService})
      : _apiService = apiService ?? ApiService();

  /// Upload palm images with validation
  /// Requirements: 5.1, 9.1
  Future<ServiceResult<Map<String, dynamic>>> uploadPalmImages({
    required String leftHandImagePath,
    required String rightHandImagePath,
  }) async {
    try {
      // Validate file sizes
      final leftHandFile = File(leftHandImagePath);
      final rightHandFile = File(rightHandImagePath);

      if (!await leftHandFile.exists() || !await rightHandFile.exists()) {
        return ServiceResult.error('Image files not found');
      }

      final leftHandSize = await leftHandFile.length();
      final rightHandSize = await rightHandFile.length();

      if (leftHandSize > maxFileSizeBytes || rightHandSize > maxFileSizeBytes) {
        return ServiceResult.error(
          'Image file size exceeds 5MB limit. Please use a smaller image.',
        );
      }

      final response = await _apiService.uploadPalmImages(
        leftHandImagePath: leftHandImagePath,
        rightHandImagePath: rightHandImagePath,
      );

      if (response.data['success'] == true) {
        return ServiceResult.success(response.data['data']);
      } else {
        return ServiceResult.error(
          response.data['message'] ?? 'Failed to upload palm images',
        );
      }
    } on ApiException catch (e) {
      return ServiceResult.error(e.message);
    } catch (e) {
      return ServiceResult.error('An unexpected error occurred: $e');
    }
  }

  /// Analyze palmistry data
  /// Requirements: 5.1, 9.1
  Future<ServiceResult<Map<String, dynamic>>> analyzePalmistry({
    required int palmistryId,
    String? additionalNotes,
  }) async {
    try {
      final response = await _apiService.analyzePalmistry(
        palmistryId: palmistryId,
        additionalNotes: additionalNotes,
      );

      if (response.data['success'] == true) {
        return ServiceResult.success(response.data['data']);
      } else {
        return ServiceResult.error(
          response.data['message'] ?? 'Failed to analyze palmistry',
        );
      }
    } on ApiException catch (e) {
      return ServiceResult.error(e.message);
    } catch (e) {
      return ServiceResult.error('An unexpected error occurred: $e');
    }
  }

  /// Get list of user's palmistry records
  /// Requirements: 5.1, 9.1
  Future<ServiceResult<List<Map<String, dynamic>>>> getPalmistryList({
    int page = 1,
    int limit = 10,
  }) async {
    try {
      final response = await _apiService.getPalmistryList(
        page: page,
        limit: limit,
      );

      if (response.data['success'] == true) {
        final palmistryList =
            (response.data['data'] as List).cast<Map<String, dynamic>>();
        return ServiceResult.success(palmistryList);
      } else {
        return ServiceResult.error(
          response.data['message'] ?? 'Failed to fetch palmistry list',
        );
      }
    } on ApiException catch (e) {
      return ServiceResult.error(e.message);
    } catch (e) {
      return ServiceResult.error('An unexpected error occurred: $e');
    }
  }
}
