import 'package:flutter/material.dart';
import '../../models/report_model.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_typography.dart';
import 'package:intl/intl.dart';

class ReportCard extends StatelessWidget {
  final Report report;
  final String serviceName;
  final VoidCallback onTap;

  const ReportCard({
    super.key,
    required this.report,
    required this.serviceName,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // Optimized: Cache computed values to prevent recalculation on rebuild
    final statusColor = _getStatusColor();
    final statusIcon = _getStatusIcon();
    final formattedDate = _formatDate(report.createdAt);
    final formattedFileSize = _formatFileSize(report.fileSize);
    final statusText = _getStatusText();

    // Optimized: Cache text styles
    final serviceNameStyle = AppTypography.h3.copyWith(
      fontSize: 18,
      color: AppColors.textPrimary,
    );
    final dateStyle = AppTypography.bodySmall.copyWith(
      color: AppColors.textSecondary,
    );
    final fileSizeStyle = AppTypography.bodySmall.copyWith(
      color: AppColors.textSecondary,
    );

    // Create semantic label for screen readers
    final semanticLabel =
        '$serviceName report, Status: $statusText, Created: $formattedDate, File size: $formattedFileSize';

    return Semantics(
      label: semanticLabel,
      button: true,
      hint: report.status == ReportStatus.ready
          ? 'Double tap to view report'
          : report.status == ReportStatus.generating
              ? 'Report is still being generated'
              : 'Report generation failed',
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: AppColors.shadowLight,
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Semantics(
                    label: 'Status: $statusText',
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: statusColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        statusIcon,
                        color: statusColor,
                        size: 24,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          serviceName,
                          style: serviceNameStyle,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          formattedDate,
                          style: dateStyle,
                        ),
                      ],
                    ),
                  ),
                  _buildStatusBadge(statusColor),
                ],
              ),
              const SizedBox(height: 12),
              Semantics(
                label: 'File size: $formattedFileSize',
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppColors.lightGray,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.insert_drive_file_outlined,
                        size: 16,
                        color: AppColors.textSecondary,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        formattedFileSize,
                        style: fileSizeStyle,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusBadge(Color statusColor) {
    final statusText = _getStatusText();
    final badgeTextStyle = AppTypography.bodySmall.copyWith(
      color: statusColor,
      fontWeight: FontWeight.w600,
      fontSize: 11,
    );

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: statusColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: statusColor.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Text(
        statusText,
        style: badgeTextStyle,
      ),
    );
  }

  Color _getStatusColor() {
    switch (report.status) {
      case ReportStatus.ready:
        return AppColors.success;
      case ReportStatus.generating:
        return AppColors.primaryOrange;
      case ReportStatus.failed:
        return AppColors.error;
    }
  }

  IconData _getStatusIcon() {
    switch (report.status) {
      case ReportStatus.ready:
        return Icons.check_circle;
      case ReportStatus.generating:
        return Icons.hourglass_empty;
      case ReportStatus.failed:
        return Icons.error;
    }
  }

  String _getStatusText() {
    switch (report.status) {
      case ReportStatus.ready:
        return 'Ready';
      case ReportStatus.generating:
        return 'Generating';
      case ReportStatus.failed:
        return 'Failed';
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return 'Today, ${DateFormat('h:mm a').format(date)}';
    } else if (difference.inDays == 1) {
      return 'Yesterday, ${DateFormat('h:mm a').format(date)}';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else {
      return DateFormat('MMM d, yyyy').format(date);
    }
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
}
