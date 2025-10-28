import 'package:flutter/material.dart';
import '../models/order_model.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';
import '../widgets/buttons/primary_button.dart';
import '../l10n/app_localizations.dart';
import 'package:intl/intl.dart';

/// Order tracking screen showing order status and timeline
/// Requirements: 10.4, 10.5
class OrderTrackingScreen extends StatelessWidget {
  final Order order;

  const OrderTrackingScreen({
    super.key,
    required this.order,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: AppColors.lightGray,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          l10n.order_tracking_title,
          style: AppTypography.h3.copyWith(
            color: AppColors.textPrimary,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Order Status Card
            _buildOrderStatusCard(context),
            const SizedBox(height: 20),

            // Order Details Card
            _buildOrderDetailsCard(context),
            const SizedBox(height: 20),

            // Timeline Card
            _buildTimelineCard(context),
            const SizedBox(height: 20),

            // Action Buttons
            if (order.status == OrderStatus.completed && order.reportId != null)
              _buildActionButtons(context),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderStatusCard(BuildContext context) {
    final statusColor = _getStatusColor(order.status);
    final statusIcon = _getStatusIcon(order.status);

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            statusColor,
            statusColor.withValues(alpha: 0.8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: statusColor.withValues(alpha: 0.3),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(
            statusIcon,
            size: 64,
            color: AppColors.white,
          ),
          const SizedBox(height: 16),
          Text(
            order.status.displayName,
            style: AppTypography.h2.copyWith(
              color: AppColors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _getStatusMessage(order.status, context),
            style: AppTypography.bodyMedium.copyWith(
              color: AppColors.white.withValues(alpha: 0.9),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildOrderDetailsCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppLocalizations.of(context)!.order_tracking_order_details,
            style: AppTypography.h3.copyWith(
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          _buildDetailRow(
            AppLocalizations.of(context)!.order_tracking_order_id,
            order.id,
          ),
          const SizedBox(height: 12),
          _buildDetailRow(
            AppLocalizations.of(context)!.order_tracking_service,
            order.serviceName,
          ),
          const SizedBox(height: 12),
          _buildDetailRow(
            AppLocalizations.of(context)!.order_tracking_amount,
            '₹${order.amount}',
          ),
          const SizedBox(height: 12),
          _buildDetailRow(
            AppLocalizations.of(context)!.order_tracking_order_date,
            DateFormat('dd MMM yyyy, hh:mm a').format(order.createdAt),
          ),
          if (order.paymentId != null) ...[
            const SizedBox(height: 12),
            _buildDetailRow(
              AppLocalizations.of(context)!.order_tracking_payment_id,
              order.paymentId!,
            ),
          ],
          if (order.completedAt != null) ...[
            const SizedBox(height: 12),
            _buildDetailRow(
              AppLocalizations.of(context)!.order_tracking_completed_on,
              DateFormat('dd MMM yyyy, hh:mm a').format(order.completedAt!),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTypography.bodyMedium.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Text(
            value,
            style: AppTypography.bodyMedium.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.right,
          ),
        ),
      ],
    );
  }

  Widget _buildTimelineCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppLocalizations.of(context)!.order_tracking_timeline,
            style: AppTypography.h3.copyWith(
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 20),
          _buildTimelineItem(
            AppLocalizations.of(context)!.order_tracking_order_placed,
            DateFormat('dd MMM yyyy, hh:mm a').format(order.createdAt),
            true,
            Icons.shopping_cart,
          ),
          _buildTimelineItem(
            AppLocalizations.of(context)!.order_tracking_payment_confirmed,
            order.paymentId != null
                ? AppLocalizations.of(context)!.order_tracking_payment_completed
                : AppLocalizations.of(context)!.order_tracking_payment_pending,
            order.paymentId != null,
            Icons.payment,
          ),
          _buildTimelineItem(
            AppLocalizations.of(context)!.order_tracking_processing,
            order.status == OrderStatus.processing ||
                    order.status == OrderStatus.completed
                ? AppLocalizations.of(context)!
                    .order_tracking_processing_in_progress
                : AppLocalizations.of(context)!
                    .order_tracking_processing_waiting,
            order.status == OrderStatus.processing ||
                order.status == OrderStatus.completed,
            Icons.hourglass_empty,
          ),
          _buildTimelineItem(
            AppLocalizations.of(context)!.order_tracking_completed,
            order.completedAt != null
                ? DateFormat('dd MMM yyyy, hh:mm a').format(order.completedAt!)
                : AppLocalizations.of(context)!.order_tracking_payment_pending,
            order.status == OrderStatus.completed,
            Icons.check_circle,
            isLast: true,
          ),
        ],
      ),
    );
  }

  Widget _buildTimelineItem(
    String title,
    String subtitle,
    bool isCompleted,
    IconData icon, {
    bool isLast = false,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: isCompleted
                    ? AppColors.success
                    : AppColors.mediumGray.withValues(alpha: 0.3),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: AppColors.white,
                size: 20,
              ),
            ),
            if (!isLast)
              Container(
                width: 2,
                height: 40,
                color: isCompleted
                    ? AppColors.success
                    : AppColors.mediumGray.withValues(alpha: 0.3),
              ),
          ],
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(top: 8, bottom: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTypography.bodyLarge.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Column(
      children: [
        PrimaryButton(
          label: l10n.order_tracking_view_report,
          width: double.infinity,
          onPressed: () {
            // Navigate to report detail screen
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(l10n.order_tracking_opening_report),
                backgroundColor: AppColors.success,
              ),
            );
          },
        ),
        const SizedBox(height: 12),
        OutlinedButton(
          onPressed: () {
            // Download report
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(l10n.order_tracking_downloading_report),
                backgroundColor: AppColors.primaryBlue,
              ),
            );
          },
          style: OutlinedButton.styleFrom(
            side: const BorderSide(color: AppColors.primaryBlue, width: 2),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.symmetric(vertical: 16),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.download, color: AppColors.primaryBlue),
              const SizedBox(width: 8),
              Text(
                l10n.order_tracking_download_report,
                style: AppTypography.button.copyWith(
                  color: AppColors.primaryBlue,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Color _getStatusColor(OrderStatus status) {
    switch (status) {
      case OrderStatus.pending:
        return AppColors.warning;
      case OrderStatus.processing:
        return AppColors.info;
      case OrderStatus.completed:
        return AppColors.success;
      case OrderStatus.failed:
        return AppColors.error;
      case OrderStatus.cancelled:
        return AppColors.textSecondary;
    }
  }

  IconData _getStatusIcon(OrderStatus status) {
    switch (status) {
      case OrderStatus.pending:
        return Icons.pending;
      case OrderStatus.processing:
        return Icons.autorenew;
      case OrderStatus.completed:
        return Icons.check_circle;
      case OrderStatus.failed:
        return Icons.error;
      case OrderStatus.cancelled:
        return Icons.cancel;
    }
  }

  String _getStatusMessage(OrderStatus status, BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    switch (status) {
      case OrderStatus.pending:
        return l10n.order_tracking_status_pending;
      case OrderStatus.processing:
        return l10n.order_tracking_status_processing;
      case OrderStatus.completed:
        return l10n.order_tracking_status_completed;
      case OrderStatus.failed:
        return l10n.order_tracking_status_failed;
      case OrderStatus.cancelled:
        return l10n.order_tracking_status_cancelled;
    }
  }
}
