import 'api_service.dart';
import 'kundali_ai_service.dart';

/// Service class for Numerology AI operations
/// Requirements: 6.1, 9.1
class NumerologyAIService {
  final ApiService _apiService;

  NumerologyAIService({ApiService? apiService})
      : _apiService = apiService ?? ApiService();

  /// Calculate numerology numbers
  /// Requirements: 6.1, 9.1
  Future<ServiceResult<Map<String, dynamic>>> calculateNumerology({
    required String fullName,
    required DateTime dateOfBirth,
  }) async {
    try {
      final response = await _apiService.calculateNumerology(
        fullName: fullName,
        dateOfBirth: _formatDate(dateOfBirth),
      );

      if (response.data['success'] == true) {
        return ServiceResult.success(response.data['data']);
      } else {
        return ServiceResult.error(
          response.data['message'] ?? 'Failed to calculate numerology',
        );
      }
    } on ApiException catch (e) {
      return ServiceResult.error(e.message);
    } catch (e) {
      return ServiceResult.error('An unexpected error occurred: $e');
    }
  }

  /// Generate detailed numerology analysis
  /// Requirements: 6.1, 9.1
  Future<ServiceResult<Map<String, dynamic>>> analyzeNumerology({
    required String fullName,
    required DateTime dateOfBirth,
  }) async {
    try {
      final response = await _apiService.analyzeNumerology(
        fullName: fullName,
        dateOfBirth: _formatDate(dateOfBirth),
      );

      if (response.data['success'] == true) {
        return ServiceResult.success(response.data['data']);
      } else {
        return ServiceResult.error(
          response.data['message'] ?? 'Failed to analyze numerology',
        );
      }
    } on ApiException catch (e) {
      return ServiceResult.error(e.message);
    } catch (e) {
      return ServiceResult.error('An unexpected error occurred: $e');
    }
  }

  /// Get list of user's numerology records
  /// Requirements: 6.1, 9.1
  Future<ServiceResult<List<Map<String, dynamic>>>> getNumerologyList({
    int page = 1,
    int limit = 10,
  }) async {
    try {
      final response = await _apiService.getNumerologyList(
        page: page,
        limit: limit,
      );

      if (response.data['success'] == true) {
        final numerologyList =
            (response.data['data'] as List).cast<Map<String, dynamic>>();
        return ServiceResult.success(numerologyList);
      } else {
        return ServiceResult.error(
          response.data['message'] ?? 'Failed to fetch numerology list',
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
