import '../models/kundali_model.dart';
import 'api_service.dart';

/// Service class for Kundali AI operations
/// Requirements: 1.1, 1.2, 9.1
class KundaliAIService {
  final ApiService _apiService;

  KundaliAIService({ApiService? apiService})
      : _apiService = apiService ?? ApiService();

  /// Generate new Kundali with birth details
  /// Requirements: 1.1, 9.1
  Future<ServiceResult<Kundali>> generateKundali({
    required String name,
    required DateTime dateOfBirth,
    required String timeOfBirth,
    required String placeOfBirth,
    required double latitude,
    required double longitude,
    String? timezone,
  }) async {
    try {
      final response = await _apiService.generateKundali(
        name: name,
        dateOfBirth: _formatDate(dateOfBirth),
        timeOfBirth: timeOfBirth,
        placeOfBirth: placeOfBirth,
        latitude: latitude,
        longitude: longitude,
        timezone: timezone,
      );

      if (response.data['success'] == true) {
        final kundaliData = response.data['data'];
        final kundali = Kundali.fromJson(kundaliData);
        return ServiceResult.success(kundali);
      } else {
        return ServiceResult.error(
          response.data['message'] ?? 'Failed to generate Kundali',
        );
      }
    } on ApiException catch (e) {
      return ServiceResult.error(e.message);
    } catch (e) {
      return ServiceResult.error('An unexpected error occurred: $e');
    }
  }

  /// Get list of user's Kundalis with pagination
  /// Requirements: 1.1, 9.1
  Future<ServiceResult<List<Kundali>>> getKundaliList({
    int page = 1,
    int limit = 10,
  }) async {
    try {
      final response = await _apiService.getKundaliList(
        page: page,
        limit: limit,
      );

      if (response.data['success'] == true) {
        final kundaliList = (response.data['data'] as List)
            .map((json) => Kundali.fromJson(json))
            .toList();
        return ServiceResult.success(kundaliList);
      } else {
        return ServiceResult.error(
          response.data['message'] ?? 'Failed to fetch Kundali list',
        );
      }
    } on ApiException catch (e) {
      return ServiceResult.error(e.message);
    } catch (e) {
      return ServiceResult.error('An unexpected error occurred: $e');
    }
  }

  /// Get specific Kundali by ID
  /// Requirements: 1.1, 9.1
  Future<ServiceResult<Kundali>> getKundali(int kundaliId) async {
    try {
      final response = await _apiService.getKundali(kundaliId);

      if (response.data['success'] == true) {
        final kundaliData = response.data['data'];
        final kundali = Kundali.fromJson(kundaliData);
        return ServiceResult.success(kundali);
      } else {
        return ServiceResult.error(
          response.data['message'] ?? 'Failed to fetch Kundali',
        );
      }
    } on ApiException catch (e) {
      return ServiceResult.error(e.message);
    } catch (e) {
      return ServiceResult.error('An unexpected error occurred: $e');
    }
  }

  /// Generate detailed AI report for Kundali
  /// Requirements: 1.2, 9.1
  Future<ServiceResult<Map<String, dynamic>>> generateKundaliReport(
    int kundaliId,
  ) async {
    try {
      final response = await _apiService.generateKundaliReport(kundaliId);

      if (response.data['success'] == true) {
        return ServiceResult.success(response.data['data']);
      } else {
        return ServiceResult.error(
          response.data['message'] ?? 'Failed to generate Kundali report',
        );
      }
    } on ApiException catch (e) {
      return ServiceResult.error(e.message);
    } catch (e) {
      return ServiceResult.error('An unexpected error occurred: $e');
    }
  }

  /// Delete Kundali by ID
  /// Requirements: 9.1
  Future<ServiceResult<bool>> deleteKundali(int kundaliId) async {
    try {
      final response = await _apiService.deleteKundali(kundaliId);

      if (response.data['success'] == true) {
        return ServiceResult.success(true);
      } else {
        return ServiceResult.error(
          response.data['message'] ?? 'Failed to delete Kundali',
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

/// Service result wrapper for handling success and error states
class ServiceResult<T> {
  final T? data;
  final String? error;
  final bool isSuccess;

  ServiceResult._({
    this.data,
    this.error,
    required this.isSuccess,
  });

  factory ServiceResult.success(T data) {
    return ServiceResult._(
      data: data,
      isSuccess: true,
    );
  }

  factory ServiceResult.error(String error) {
    return ServiceResult._(
      error: error,
      isSuccess: false,
    );
  }

  bool get isError => !isSuccess;
}
