import 'package:flutter/foundation.dart';
import '../models/report_model.dart';
import '../services/report_service.dart';

/// Report state provider
///
/// Manages report list and operations
/// Requirements: 10.4
class ReportProvider with ChangeNotifier {
  final ReportService _reportService;

  List<Report> _reports = [];
  Report? _selectedReport;
  bool _isLoading = false;
  String? _error;
  int _currentPage = 1;
  bool _hasMoreReports = true;

  ReportProvider({ReportService? reportService})
      : _reportService = reportService ?? ReportService();

  // Getters
  List<Report> get reports => _reports;
  Report? get selectedReport => _selectedReport;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get hasReports => _reports.isNotEmpty;
  bool get hasMoreReports => _hasMoreReports;
  int get currentPage => _currentPage;

  /// Load reports for current user
  ///
  /// Requirements: 10.4
  Future<bool> loadReports({
    int page = 1,
    int limit = 20,
    ReportStatus? status,
    bool append = false,
  }) async {
    _setLoading(true);
    _clearError();

    try {
      final reports = await _reportService.getReports(
        page: page,
        limit: limit,
        status: status,
      );

      if (append) {
        _reports.addAll(reports);
      } else {
        _reports = reports;
      }

      _currentPage = page;
      _hasMoreReports = reports.length >= limit;
      notifyListeners();
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Load next page of reports
  Future<bool> loadMoreReports({
    int limit = 20,
    ReportStatus? status,
  }) async {
    if (!_hasMoreReports || _isLoading) return false;

    return await loadReports(
      page: _currentPage + 1,
      limit: limit,
      status: status,
      append: true,
    );
  }

  /// Load report by ID
  ///
  /// Requirements: 10.4
  Future<bool> loadReportById(String reportId) async {
    _setLoading(true);
    _clearError();

    try {
      final report = await _reportService.getReportById(reportId);
      _selectedReport = report;

      // Update report in list if it exists
      final index = _reports.indexWhere((r) => r.id == reportId);
      if (index != -1) {
        _reports[index] = report;
      }

      notifyListeners();
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Download report as bytes
  ///
  /// Requirements: 10.4
  Future<Uint8List?> downloadReport(String reportId) async {
    _setLoading(true);
    _clearError();

    try {
      final bytes = await _reportService.downloadReport(reportId);
      notifyListeners();
      return bytes;
    } catch (e) {
      _setError(e.toString());
      return null;
    } finally {
      _setLoading(false);
    }
  }

  /// Get report download URL
  Future<String?> getReportDownloadUrl(String reportId) async {
    _setLoading(true);
    _clearError();

    try {
      final url = await _reportService.getReportDownloadUrl(reportId);
      notifyListeners();
      return url;
    } catch (e) {
      _setError(e.toString());
      return null;
    } finally {
      _setLoading(false);
    }
  }

  /// Get report generation status
  Future<ReportGenerationStatus?> getReportStatus(String reportId) async {
    try {
      final status = await _reportService.getReportStatus(reportId);
      return status;
    } catch (e) {
      _setError(e.toString());
      return null;
    }
  }

  /// Load reports by service
  Future<bool> loadReportsByService(String serviceId) async {
    _setLoading(true);
    _clearError();

    try {
      final reports = await _reportService.getReportsByService(serviceId);
      _reports = reports;
      notifyListeners();
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Regenerate report
  Future<bool> regenerateReport(String reportId) async {
    _setLoading(true);
    _clearError();

    try {
      final report = await _reportService.regenerateReport(reportId);

      // Update report in list
      final index = _reports.indexWhere((r) => r.id == reportId);
      if (index != -1) {
        _reports[index] = report;
      }

      if (_selectedReport?.id == reportId) {
        _selectedReport = report;
      }

      notifyListeners();
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Delete report
  Future<bool> deleteReport(String reportId) async {
    _setLoading(true);
    _clearError();

    try {
      await _reportService.deleteReport(reportId);

      // Remove report from list
      _reports.removeWhere((r) => r.id == reportId);

      if (_selectedReport?.id == reportId) {
        _selectedReport = null;
      }

      notifyListeners();
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Share report via email
  Future<bool> shareReport({
    required String reportId,
    required String email,
  }) async {
    _setLoading(true);
    _clearError();

    try {
      await _reportService.shareReport(reportId: reportId, email: email);
      notifyListeners();
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Select a report
  void selectReport(Report report) {
    _selectedReport = report;
    notifyListeners();
  }

  /// Clear selected report
  void clearSelectedReport() {
    _selectedReport = null;
    notifyListeners();
  }

  /// Get report by ID from cached list
  Report? getReportById(String reportId) {
    try {
      return _reports.firstWhere((report) => report.id == reportId);
    } catch (e) {
      return null;
    }
  }

  /// Filter reports by status
  List<Report> filterByStatus(ReportStatus status) {
    return _reports.where((report) => report.status == status).toList();
  }

  /// Get ready reports only
  List<Report> getReadyReports() {
    return _reports
        .where((report) => report.status == ReportStatus.ready)
        .toList();
  }

  /// Get generating reports only
  List<Report> getGeneratingReports() {
    return _reports
        .where((report) => report.status == ReportStatus.generating)
        .toList();
  }

  /// Get failed reports only
  List<Report> getFailedReports() {
    return _reports
        .where((report) => report.status == ReportStatus.failed)
        .toList();
  }

  /// Get reports sorted by date (newest first)
  List<Report> getReportsSortedByDate({bool descending = true}) {
    final sortedReports = List<Report>.from(_reports);
    sortedReports.sort(
      (a, b) => descending
          ? b.createdAt.compareTo(a.createdAt)
          : a.createdAt.compareTo(b.createdAt),
    );
    return sortedReports;
  }

  /// Refresh reports
  Future<bool> refreshReports({ReportStatus? status}) async {
    _currentPage = 1;
    _hasMoreReports = true;
    return await loadReports(page: 1, status: status);
  }

  /// Clear all report data
  void clearReports() {
    _reports = [];
    _selectedReport = null;
    _currentPage = 1;
    _hasMoreReports = true;
    _clearError();
    notifyListeners();
  }

  /// Set loading state
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  /// Set error message
  void _setError(String error) {
    _error = error;
    notifyListeners();
  }

  /// Clear error message
  void _clearError() {
    _error = null;
  }
}
