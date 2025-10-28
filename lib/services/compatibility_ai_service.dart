import 'api_service.dart';
import 'kundali_ai_service.dart';

/// Service class for Marriage Compatibility AI operations
/// Requirements: 7.1, 9.1
class CompatibilityAIService {
  final ApiService _apiService;

  CompatibilityAIService({ApiService? apiService})
      : _apiService = apiService ?? ApiService();

  /// Check marriage compatibility between two individuals
  /// Requirements: 7.1, 9.1
  Future<ServiceResult<Map<String, dynamic>>> checkCompatibility({
    int? person1KundaliId,
    int? person2KundaliId,
    Map<String, dynamic>? person1BirthDetails,
    Map<String, dynamic>? person2BirthDetails,
  }) async {
    try {
      // Validate that we have either Kundali IDs or birth details
      if (person1KundaliId == null && person1BirthDetails == null) {
        return ServiceResult.error(
          'Please provide either Kundali ID or birth details for person 1',
        );
      }

      if (person2KundaliId == null && person2BirthDetails == null) {
        return ServiceResult.error(
          'Please provide either Kundali ID or birth details for person 2',
        );
      }

      final response = await _apiService.checkCompatibility(
        person1KundaliId: person1KundaliId,
        person2KundaliId: person2KundaliId,
        person1BirthDetails: person1BirthDetails,
        person2BirthDetails: person2BirthDetails,
      );

      if (response.data['success'] == true) {
        return ServiceResult.success(response.data['data']);
      } else {
        return ServiceResult.error(
          response.data['message'] ?? 'Failed to check compatibility',
        );
      }
    } on ApiException catch (e) {
      return ServiceResult.error(e.message);
    } catch (e) {
      return ServiceResult.error('An unexpected error occurred: $e');
    }
  }

  /// Check compatibility using Kundali IDs
  /// Requirements: 7.1, 9.1
  Future<ServiceResult<Map<String, dynamic>>> checkCompatibilityByKundaliIds({
    required int person1KundaliId,
    required int person2KundaliId,
  }) async {
    return checkCompatibility(
      person1KundaliId: person1KundaliId,
      person2KundaliId: person2KundaliId,
    );
  }

  /// Check compatibility using birth details
  /// Requirements: 7.1, 9.1
  Future<ServiceResult<Map<String, dynamic>>> checkCompatibilityByBirthDetails({
    required String person1Name,
    required DateTime person1DateOfBirth,
    required String person1TimeOfBirth,
    required String person1PlaceOfBirth,
    required double person1Latitude,
    required double person1Longitude,
    required String person2Name,
    required DateTime person2DateOfBirth,
    required String person2TimeOfBirth,
    required String person2PlaceOfBirth,
    required double person2Latitude,
    required double person2Longitude,
    String? person1Timezone,
    String? person2Timezone,
  }) async {
    final person1Details = {
      'name': person1Name,
      'date_of_birth': _formatDate(person1DateOfBirth),
      'time_of_birth': person1TimeOfBirth,
      'place_of_birth': person1PlaceOfBirth,
      'latitude': person1Latitude,
      'longitude': person1Longitude,
      if (person1Timezone != null) 'timezone': person1Timezone,
    };

    final person2Details = {
      'name': person2Name,
      'date_of_birth': _formatDate(person2DateOfBirth),
      'time_of_birth': person2TimeOfBirth,
      'place_of_birth': person2PlaceOfBirth,
      'latitude': person2Latitude,
      'longitude': person2Longitude,
      if (person2Timezone != null) 'timezone': person2Timezone,
    };

    return checkCompatibility(
      person1BirthDetails: person1Details,
      person2BirthDetails: person2Details,
    );
  }

  /// Get compatibility report by ID
  /// Requirements: 7.1, 9.1
  Future<ServiceResult<Map<String, dynamic>>> getCompatibilityReport(
    int compatibilityId,
  ) async {
    try {
      // Note: This assumes there's a specific endpoint for getting compatibility by ID
      // If not available, this would need to be implemented in the backend
      final response = await _apiService.getCompatibilityList(
        page: 1,
        limit: 100,
      );

      if (response.data['success'] == true) {
        final compatibilityList = response.data['data'] as List;
        final compatibility = compatibilityList.firstWhere(
          (item) => item['compatibility_id'] == compatibilityId,
          orElse: () => null,
        );

        if (compatibility != null) {
          return ServiceResult.success(compatibility);
        } else {
          return ServiceResult.error('Compatibility report not found');
        }
      } else {
        return ServiceResult.error(
          response.data['message'] ?? 'Failed to fetch compatibility report',
        );
      }
    } on ApiException catch (e) {
      return ServiceResult.error(e.message);
    } catch (e) {
      return ServiceResult.error('An unexpected error occurred: $e');
    }
  }

  /// Get list of user's compatibility records
  /// Requirements: 7.1, 9.1
  Future<ServiceResult<List<Map<String, dynamic>>>> getCompatibilityList({
    int page = 1,
    int limit = 10,
  }) async {
    try {
      final response = await _apiService.getCompatibilityList(
        page: page,
        limit: limit,
      );

      if (response.data['success'] == true) {
        final compatibilityList =
            (response.data['data'] as List).cast<Map<String, dynamic>>();
        return ServiceResult.success(compatibilityList);
      } else {
        return ServiceResult.error(
          response.data['message'] ?? 'Failed to fetch compatibility list',
        );
      }
    } on ApiException catch (e) {
      return ServiceResult.error(e.message);
    } catch (e) {
      return ServiceResult.error('An unexpected error occurred: $e');
    }
  }

  /// Format DateTime to string for API
  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }
}
