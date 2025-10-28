import 'dart:io';
import 'dart:typed_data';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'package:share_plus/share_plus.dart';
import '../models/report_model.dart';
import 'api_service.dart';
import 'kundali_ai_service.dart';

/// Service class for Report AI operations
/// Requirements: 8.3, 8.4, 8.5
class ReportAIService {
  final ApiService _apiService;

  ReportAIService({ApiService? apiService})
      : _apiService = apiService ?? ApiService();

  /// Get list of user's reports with pagination and filtering
  /// Requirements: 8.3, 8.4, 9.1
  Future<ServiceResult<List<Report>>> getReportsList({
    int page = 1,
    int limit = 10,
    String? serviceType,
  }) async {
    try {
      final response = await _apiService.getReportsList(
        page: page,
        limit: limit,
        serviceType: serviceType,
      );

      if (response.data['success'] == true) {
        final reportList = (response.data['data'] as List)
            .map((json) => Report.fromJson(json))
            .toList();
        return ServiceResult.success(reportList);
      } else {
        return ServiceResult.error(
          response.data['message'] ?? 'Failed to fetch reports list',
        );
      }
    } on ApiException catch (e) {
      return ServiceResult.error(e.message);
    } catch (e) {
      return ServiceResult.error('An unexpected error occurred: $e');
    }
  }

  /// Get detailed report information by ID
  /// Requirements: 8.4, 9.1
  Future<ServiceResult<Report>> getReportDetails(int reportId) async {
    try {
      final response = await _apiService.getReport(reportId);

      if (response.data['success'] == true) {
        final reportData = response.data['data'];
        final report = Report.fromJson(reportData);
        return ServiceResult.success(report);
      } else {
        return ServiceResult.error(
          response.data['message'] ?? 'Failed to fetch report details',
        );
      }
    } on ApiException catch (e) {
      return ServiceResult.error(e.message);
    } catch (e) {
      return ServiceResult.error('An unexpected error occurred: $e');
    }
  }

  /// Download PDF report and save to device
  /// Requirements: 8.3, 9.1
  Future<ServiceResult<String>> downloadReport(int reportId) async {
    try {
      final response = await _apiService.downloadReport(reportId);

      if (response.statusCode == 200) {
        // Get the bytes from response
        final bytes = response.data as Uint8List;

        // Get the downloads directory
        final directory = await getApplicationDocumentsDirectory();
        final downloadsPath = path.join(directory.path, 'reports');

        // Create reports directory if it doesn't exist
        final reportsDir = Directory(downloadsPath);
        if (!await reportsDir.exists()) {
          await reportsDir.create(recursive: true);
        }

        // Generate filename with timestamp
        final timestamp = DateTime.now().millisecondsSinceEpoch;
        final fileName = 'report_${reportId}_$timestamp.pdf';
        final filePath = path.join(downloadsPath, fileName);

        // Write file
        final file = File(filePath);
        await file.writeAsBytes(bytes);

        return ServiceResult.success(filePath);
      } else {
        return ServiceResult.error('Failed to download report');
      }
    } on ApiException catch (e) {
      return ServiceResult.error(e.message);
    } catch (e) {
      return ServiceResult.error('An unexpected error occurred: $e');
    }
  }

  /// Share report via email or messaging apps
  /// Requirements: 8.5, 9.1
  Future<ServiceResult<bool>> shareReport(int reportId) async {
    try {
      // First download the report
      final downloadResult = await downloadReport(reportId);

      if (downloadResult.isError) {
        return ServiceResult.error(
          downloadResult.error ?? 'Failed to download report for sharing',
        );
      }

      final filePath = downloadResult.data!;

      // Share the file using share_plus package
      final result = await Share.shareXFiles(
        [XFile(filePath)],
        subject: 'Astrology Report',
        text: 'Please find attached your astrology report from DishaAjyoti.',
      );

      if (result.status == ShareResultStatus.success) {
        return ServiceResult.success(true);
      } else {
        return ServiceResult.error('Failed to share report');
      }
    } on ApiException catch (e) {
      return ServiceResult.error(e.message);
    } catch (e) {
      return ServiceResult.error('An unexpected error occurred: $e');
    }
  }

  /// Share report via email with specific recipient
  /// Requirements: 8.5, 9.1
  Future<ServiceResult<bool>> shareReportViaEmail({
    required int reportId,
    required String recipientEmail,
    String? subject,
    String? body,
  }) async {
    try {
      // First download the report
      final downloadResult = await downloadReport(reportId);

      if (downloadResult.isError) {
        return ServiceResult.error(
          downloadResult.error ?? 'Failed to download report for sharing',
        );
      }

      final filePath = downloadResult.data!;

      // Share via email with pre-filled recipient
      final result = await Share.shareXFiles(
        [XFile(filePath)],
        subject: subject ?? 'Your Astrology Report from DishaAjyoti',
        text: body ??
            'Dear $recipientEmail,\n\nPlease find attached your astrology report from DishaAjyoti.\n\nBest regards,\nDishaAjyoti Team',
      );

      if (result.status == ShareResultStatus.success) {
        return ServiceResult.success(true);
      } else {
        return ServiceResult.error('Failed to share report via email');
      }
    } on ApiException catch (e) {
      return ServiceResult.error(e.message);
    } catch (e) {
      return ServiceResult.error('An unexpected error occurred: $e');
    }
  }

  /// Get reports filtered by service type
  /// Requirements: 8.4, 9.1
  Future<ServiceResult<List<Report>>> getReportsByServiceType({
    required String serviceType,
    int page = 1,
    int limit = 10,
  }) async {
    return getReportsList(
      page: page,
      limit: limit,
      serviceType: serviceType,
    );
  }

  /// Check if report file exists locally
  /// Requirements: 8.3
  Future<bool> isReportDownloaded(int reportId) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final downloadsPath = path.join(directory.path, 'reports');
      final reportsDir = Directory(downloadsPath);

      if (!await reportsDir.exists()) {
        return false;
      }

      // Check if any file with this report ID exists
      final files = await reportsDir.list().toList();
      return files.any((file) {
        final fileName = path.basename(file.path);
        return fileName.startsWith('report_$reportId');
      });
    } catch (e) {
      return false;
    }
  }

  /// Delete locally downloaded report
  /// Requirements: 8.3
  Future<ServiceResult<bool>> deleteLocalReport(int reportId) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final downloadsPath = path.join(directory.path, 'reports');
      final reportsDir = Directory(downloadsPath);

      if (!await reportsDir.exists()) {
        return ServiceResult.error('No reports found');
      }

      // Find and delete files with this report ID
      final files = await reportsDir.list().toList();
      bool deleted = false;

      for (final file in files) {
        final fileName = path.basename(file.path);
        if (fileName.startsWith('report_$reportId')) {
          await file.delete();
          deleted = true;
        }
      }

      if (deleted) {
        return ServiceResult.success(true);
      } else {
        return ServiceResult.error('Report not found locally');
      }
    } catch (e) {
      return ServiceResult.error('Failed to delete local report: $e');
    }
  }
}
