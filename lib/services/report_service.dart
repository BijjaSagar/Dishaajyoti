import 'dart:typed_data';
import 'package:dio/dio.dart';
import '../models/report_model.dart';
import '../utils/constants.dart';
import 'api_service.dart';

/// Report service for retrieving and downloading reports
class ReportService {
  final ApiService _apiService;

  ReportService({ApiService? apiService})
      : _apiService = apiService ?? ApiService();

  /// Get all reports for current user
  ///
  /// Requirements: 10.4
  Future<List<Report>> getReports({
    int page = 1,
    int limit = 20,
    ReportStatus? status,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'page': page,
        'limit': limit,
      };

      if (status != null) {
        queryParams['status'] = status.name;
      }

      final response = await _apiService.get(
        AppConstants.reportsEndpoint,
        queryParameters: queryParams,
      );

      final List<dynamic> reportsJson =
          response.data['reports'] ?? response.data;
      return reportsJson.map((json) => Report.fromJson(json)).toList();
    } catch (e) {
      rethrow;
    }
  }

  /// Get report by ID
  ///
  /// Requirements: 10.4
  Future<Report> getReportById(String reportId) async {
    try {
      final response = await _apiService.get(
        '${AppConstants.reportsEndpoint}/$reportId',
      );

      return Report.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }

  /// Download report as bytes
  ///
  /// Requirements: 10.4
  Future<Uint8List> downloadReport(String reportId) async {
    try {
      final response = await _apiService.dio.get(
        '${AppConstants.reportsEndpoint}/$reportId/download',
        options: Options(
          responseType: ResponseType.bytes,
          followRedirects: true,
          validateStatus: (status) => status! < 500,
        ),
      );

      if (response.statusCode == 200) {
        return Uint8List.fromList(response.data);
      } else {
        throw ApiException(
          message: 'Failed to download report',
          statusCode: response.statusCode,
          type: ApiExceptionType.server,
        );
      }
    } catch (e) {
      rethrow;
    }
  }

  /// Get report download URL
  Future<String> getReportDownloadUrl(String reportId) async {
    try {
      final response = await _apiService.get(
        '${AppConstants.reportsEndpoint}/$reportId/download-url',
      );

      return response.data['url'] as String;
    } catch (e) {
      rethrow;
    }
  }

  /// Get report generation status
  Future<ReportGenerationStatus> getReportStatus(String reportId) async {
    try {
      final response = await _apiService.get(
        '${AppConstants.reportsEndpoint}/$reportId/status',
      );

      return ReportGenerationStatus.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }

  /// Request report regeneration
  Future<Report> regenerateReport(String reportId) async {
    try {
      final response = await _apiService.post(
        '${AppConstants.reportsEndpoint}/$reportId/regenerate',
      );

      return Report.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }

  /// Delete report
  Future<void> deleteReport(String reportId) async {
    try {
      await _apiService.delete(
        '${AppConstants.reportsEndpoint}/$reportId',
      );
    } catch (e) {
      rethrow;
    }
  }

  /// Get reports by service
  Future<List<Report>> getReportsByService(String serviceId) async {
    try {
      final response = await _apiService.get(
        AppConstants.reportsEndpoint,
        queryParameters: {'serviceId': serviceId},
      );

      final List<dynamic> reportsJson =
          response.data['reports'] ?? response.data;
      return reportsJson.map((json) => Report.fromJson(json)).toList();
    } catch (e) {
      rethrow;
    }
  }

  /// Share report via email
  Future<void> shareReport({
    required String reportId,
    required String email,
  }) async {
    try {
      await _apiService.post(
        '${AppConstants.reportsEndpoint}/$reportId/share',
        data: {'email': email},
      );
    } catch (e) {
      rethrow;
    }
  }
}

/// Report generation status model
class ReportGenerationStatus {
  final String reportId;
  final ReportStatus status;
  final int progress;
  final String? message;
  final DateTime? estimatedCompletion;

  ReportGenerationStatus({
    required this.reportId,
    required this.status,
    required this.progress,
    this.message,
    this.estimatedCompletion,
  });

  factory ReportGenerationStatus.fromJson(Map<String, dynamic> json) {
    return ReportGenerationStatus(
      reportId: json['reportId'] as String,
      status: ReportStatus.values.firstWhere(
        (s) => s.name == json['status'],
        orElse: () => ReportStatus.generating,
      ),
      progress: json['progress'] as int,
      message: json['message'] as String?,
      estimatedCompletion: json['estimatedCompletion'] != null
          ? DateTime.parse(json['estimatedCompletion'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'reportId': reportId,
      'status': status.name,
      'progress': progress,
      if (message != null) 'message': message,
      if (estimatedCompletion != null)
        'estimatedCompletion': estimatedCompletion!.toIso8601String(),
    };
  }
}
