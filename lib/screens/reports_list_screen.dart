import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/report_provider.dart';
import '../models/report_model.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';
import '../utils/error_handler.dart';
import '../l10n/app_localizations.dart';

/// Reports List Screen
/// Requirements: 8.3, 8.4
class ReportsListScreen extends StatefulWidget {
  const ReportsListScreen({super.key});

  @override
  State<ReportsListScreen> createState() => _ReportsListScreenState();
}

class _ReportsListScreenState extends State<ReportsListScreen> {
  final ScrollController _scrollController = ScrollController();
  ReportStatus? _selectedStatus;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadReports();
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent * 0.9) {
      final provider = context.read<ReportProvider>();
      if (!provider.isLoading && provider.hasMoreReports) {
        provider.loadMoreReports(status: _selectedStatus);
      }
    }
  }

  Future<void> _loadReports() async {
    final provider = context.read<ReportProvider>();
    final success = await provider.loadReports(status: _selectedStatus);

    if (!success && mounted) {
      ErrorHandler.showError(
        context,
        title: 'Failed to load reports',
        message: provider.error ?? 'Unknown error',
      );
    }
  }

  Future<void> _refreshReports() async {
    final provider = context.read<ReportProvider>();
    final success = await provider.refreshReports(status: _selectedStatus);

    if (!success && mounted) {
      ErrorHandler.showError(
        context,
        title: 'Failed to refresh reports',
        message: provider.error ?? 'Unknown error',
      );
    }
  }

  void _filterByStatus(ReportStatus? status) {
    setState(() {
      _selectedStatus = status;
    });
    _loadReports();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightGray,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        title: Text(
          'My Reports',
          style: AppTypography.h3.copyWith(color: AppColors.textPrimary),
        ),
        centerTitle: true,
        actions: [
          PopupMenuButton<ReportStatus?>(
            icon: const Icon(Icons.filter_list, color: AppColors.primaryBlue),
            onSelected: _filterByStatus,
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: null,
                child: Text('All Reports'),
              ),
              const PopupMenuItem(
                value: ReportStatus.ready,
                child: Text('Ready'),
              ),
              const PopupMenuItem(
                value: ReportStatus.generating,
                child: Text('Generating'),
              ),
              const PopupMenuItem(
                value: ReportStatus.failed,
                child: Text('Failed'),
              ),
            ],
          ),
          IconButton(
            icon: const Icon(Icons.refresh, color: AppColors.primaryBlue),
            onPressed: _refreshReports,
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: Consumer<ReportProvider>(
        builder: (context, provider, child) {
          return _buildBody(provider);
        },
      ),
    );
  }

  Widget _buildBody(ReportProvider provider) {
    if (provider.isLoading && !provider.hasReports) {
      return const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(AppColors.primaryOrange),
        ),
      );
    }

    if (provider.error != null && !provider.hasReports) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 80,
              color: AppColors.error.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 16),
            Text(
              'Failed to Load Reports',
              style: AppTypography.h3.copyWith(color: AppColors.error),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Text(
                provider.error!,
                style: AppTypography.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _refreshReports,
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryOrange,
                foregroundColor: AppColors.white,
              ),
            ),
          ],
        ),
      );
    }

    if (!provider.hasReports) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.description,
              size: 80,
              color: AppColors.textTertiary.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 16),
            Text(
              'No Reports Yet',
              style: AppTypography.h3.copyWith(color: AppColors.textSecondary),
            ),
            const SizedBox(height: 8),
            Text(
              'Generate your first report to see it here',
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.textTertiary,
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _refreshReports,
      color: AppColors.primaryOrange,
      child: ListView.builder(
        controller: _scrollController,
        padding: const EdgeInsets.all(16),
        itemCount: provider.reports.length + (provider.hasMoreReports ? 1 : 0),
        itemBuilder: (context, index) {
          if (index == provider.reports.length) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(
                    AppColors.primaryOrange,
                  ),
                ),
              ),
            );
          }

          final report = provider.reports[index];
          return _buildReportCard(report);
        },
      ),
    );
  }

  Widget _buildReportCard(Report report) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        onTap: () => _navigateToReportDetail(report),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  _buildStatusIcon(report.status),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          report.fileName,
                          style: AppTypography.subtitle1.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Report #${report.id}',
                          style: AppTypography.bodySmall.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  _buildStatusChip(report.status),
                ],
              ),
              const Divider(height: 24),
              Row(
                children: [
                  Expanded(
                    child: _buildInfoChip(
                      icon: Icons.insert_drive_file,
                      label: _formatFileSize(report.fileSize),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _buildInfoChip(
                      icon: Icons.calendar_today,
                      label: _formatDate(report.createdAt),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusIcon(ReportStatus status) {
    IconData icon;
    Color color;

    switch (status) {
      case ReportStatus.ready:
        icon = Icons.check_circle;
        color = AppColors.success;
        break;
      case ReportStatus.generating:
        icon = Icons.hourglass_empty;
        color = AppColors.warning;
        break;
      case ReportStatus.failed:
        icon = Icons.error;
        color = AppColors.error;
        break;
    }

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(icon, color: color, size: 24),
    );
  }

  Widget _buildStatusChip(ReportStatus status) {
    Color color;
    String label;

    switch (status) {
      case ReportStatus.ready:
        color = AppColors.success;
        label = 'Ready';
        break;
      case ReportStatus.generating:
        color = AppColors.warning;
        label = 'Generating';
        break;
      case ReportStatus.failed:
        color = AppColors.error;
        label = 'Failed';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Text(
        label,
        style: AppTypography.bodySmall.copyWith(
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }

  Widget _buildInfoChip({required IconData icon, required String label}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.lightGray,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: AppColors.textSecondary),
          const SizedBox(width: 4),
          Flexible(
            child: Text(
              label,
              style: AppTypography.bodySmall.copyWith(
                color: AppColors.textSecondary,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  String _formatFileSize(int bytes) {
    if (bytes < 1024) {
      return '$bytes B';
    } else if (bytes < 1024 * 1024) {
      return '${(bytes / 1024).toStringAsFixed(1)} KB';
    } else {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
  }

  String _formatDate(DateTime date) {
    final months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  void _navigateToReportDetail(Report report) {
    // Navigate to report detail screen
    // For now, we'll use a simple navigation
    // In a real app, you'd fetch the service details
    Navigator.pushNamed(
      context,
      '/report-detail-api',
      arguments: report.id,
    );
  }
}
