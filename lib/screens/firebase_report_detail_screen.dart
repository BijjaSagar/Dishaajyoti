import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/firebase/service_report_model.dart';
import '../services/firebase/firestore_service.dart';
import '../services/firebase/cloud_storage_service.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';
import '../widgets/buttons/primary_button.dart';
import '../l10n/app_localizations.dart';

/// Firebase Report Detail Screen
/// Displays detailed information about a report generated via Cloud Functions
class FirebaseReportDetailScreen extends StatefulWidget {
  final String reportId;

  const FirebaseReportDetailScreen({
    super.key,
    required this.reportId,
  });

  @override
  State<FirebaseReportDetailScreen> createState() =>
      _FirebaseReportDetailScreenState();
}

class _FirebaseReportDetailScreenState
    extends State<FirebaseReportDetailScreen> {
  ServiceReport? _report;
  bool _isLoading = true;
  String? _error;
  double? _downloadProgress;

  @override
  void initState() {
    super.initState();
    _loadReport();
  }

  Future<void> _loadReport() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      final report =
          await FirestoreService.instance.getServiceReport(widget.reportId);

      if (report == null) {
        throw Exception('Report not found');
      }

      setState(() {
        _report = report;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _downloadPDF() async {
    if (_report?.files.pdfUrl == null) {
      _showError('PDF not available');
      return;
    }

    try {
      final url = Uri.parse(_report!.files.pdfUrl!);
      if (await canLaunchUrl(url)) {
        await launchUrl(url, mode: LaunchMode.externalApplication);
      } else {
        _showError('Could not open PDF');
      }
    } catch (e) {
      _showError('Error opening PDF: ${e.toString()}');
    }
  }

  Future<void> _viewImage(String imageUrl) async {
    try {
      final url = Uri.parse(imageUrl);
      if (await canLaunchUrl(url)) {
        await launchUrl(url, mode: LaunchMode.externalApplication);
      } else {
        _showError('Could not open image');
      }
    } catch (e) {
      _showError('Error opening image: ${e.toString()}');
    }
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.error,
      ),
    );
  }

  String _getServiceIcon(ServiceType type) {
    switch (type) {
      case ServiceType.kundali:
        return '🌟';
      case ServiceType.palmistry:
        return '🤚';
      case ServiceType.numerology:
        return '🔢';
      case ServiceType.matchmaking:
        return '💑';
      case ServiceType.panchang:
        return '📅';
    }
  }

  String _getServiceName(ServiceType type) {
    switch (type) {
      case ServiceType.kundali:
        return 'Kundali';
      case ServiceType.palmistry:
        return 'Palmistry';
      case ServiceType.numerology:
        return 'Numerology';
      case ServiceType.matchmaking:
        return 'Matchmaking';
      case ServiceType.panchang:
        return 'Panchang';
    }
  }

  @override
  Widget build(BuildContext context) {
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
          'Report Details',
          style: AppTypography.h3.copyWith(
            color: AppColors.textPrimary,
          ),
        ),
        centerTitle: true,
        actions: [
          if (_report != null && _report!.files.pdfUrl != null)
            IconButton(
              icon: const Icon(Icons.share, color: AppColors.primaryBlue),
              onPressed: () {
                // TODO: Implement share functionality
                _showError('Share feature coming soon');
              },
            ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(AppColors.primaryOrange),
        ),
      );
    }

    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.error_outline,
                size: 80,
                color: AppColors.error,
              ),
              const SizedBox(height: 16),
              Text(
                'Error Loading Report',
                style: AppTypography.h2.copyWith(color: AppColors.error),
              ),
              const SizedBox(height: 8),
              Text(
                _error!,
                style: AppTypography.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              PrimaryButton(
                label: 'Retry',
                onPressed: _loadReport,
              ),
            ],
          ),
        ),
      );
    }

    if (_report == null) {
      return const Center(
        child: Text('Report not found'),
      );
    }

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header Card
          _buildHeaderCard(),
          const SizedBox(height: 16),

          // Status Card
          _buildStatusCard(),
          const SizedBox(height: 16),

          // Files Card
          if (_report!.isReady) ...[
            _buildFilesCard(),
            const SizedBox(height: 16),
          ],

          // Calculated Data Card (for Kundali)
          if (_report!.serviceType == ServiceType.kundali &&
              _report!.calculatedData != null)
            _buildCalculatedDataCard(),

          const SizedBox(height: 16),

          // Action Buttons
          if (_report!.isReady) _buildActionButtons(),

          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildHeaderCard() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryOrange.withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          // Service Icon
          Text(
            _getServiceIcon(_report!.serviceType),
            style: const TextStyle(fontSize: 64),
          ),
          const SizedBox(height: 16),
          // Service Name
          Text(
            _getServiceName(_report!.serviceType),
            style: AppTypography.h2.copyWith(color: AppColors.white),
          ),
          const SizedBox(height: 8),
          // Report ID
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              'Report #${widget.reportId.substring(0, 8)}',
              style: AppTypography.bodySmall.copyWith(
                color: AppColors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusCard() {
    Color statusColor;
    IconData statusIcon;
    String statusText;

    switch (_report!.status) {
      case ServiceReportStatus.pending:
        statusColor = AppColors.warning;
        statusIcon = Icons.pending;
        statusText = 'Pending';
        break;
      case ServiceReportStatus.scheduled:
        statusColor = AppColors.info;
        statusIcon = Icons.schedule;
        statusText = 'Scheduled';
        break;
      case ServiceReportStatus.processing:
        statusColor = AppColors.warning;
        statusIcon = Icons.hourglass_empty;
        statusText = 'Processing';
        break;
      case ServiceReportStatus.completed:
        statusColor = AppColors.success;
        statusIcon = Icons.check_circle;
        statusText = 'Completed';
        break;
      case ServiceReportStatus.failed:
        statusColor = AppColors.error;
        statusIcon = Icons.error;
        statusText = 'Failed';
        break;
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: statusColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(statusIcon, color: statusColor, size: 32),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Status',
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  statusText,
                  style: AppTypography.h3.copyWith(
                    color: statusColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (_report!.metadata != null &&
                    _report!.metadata!['estimatedDelivery'] != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      'Est. Delivery: ${_report!.metadata!['estimatedDelivery']}',
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilesCard() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Files',
            style: AppTypography.h3.copyWith(
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          if (_report!.files.pdfUrl != null)
            _buildFileItem(
              icon: Icons.picture_as_pdf,
              title: 'PDF Report',
              subtitle: 'View your complete report',
              onTap: _downloadPDF,
            ),
          if (_report!.files.imageUrls.isNotEmpty) ...[
            const SizedBox(height: 12),
            ...List.generate(
              _report!.files.imageUrls.length,
              (index) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _buildFileItem(
                  icon: Icons.image,
                  title: 'Chart Image ${index + 1}',
                  subtitle: 'View chart visualization',
                  onTap: () => _viewImage(_report!.files.imageUrls[index]),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildFileItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.lightGray,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.primaryOrange.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: AppColors.primaryOrange),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTypography.bodyLarge.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: AppTypography.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: AppColors.textSecondary,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCalculatedDataCard() {
    final calculatedData = _report!.calculatedData;
    if (calculatedData == null) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Astrological Details',
            style: AppTypography.h3.copyWith(
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          if (calculatedData['lagna'] != null)
            _buildDataRow('Lagna (Ascendant)', calculatedData['lagna']),
          if (calculatedData['moonSign'] != null)
            _buildDataRow('Moon Sign', calculatedData['moonSign']),
          if (calculatedData['sunSign'] != null)
            _buildDataRow('Sun Sign', calculatedData['sunSign']),
          if (calculatedData['moonNakshatra'] != null)
            _buildDataRow('Moon Nakshatra', calculatedData['moonNakshatra']),
        ],
      ),
    );
  }

  Widget _buildDataRow(String label, dynamic value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: AppTypography.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          Text(
            value.toString(),
            style: AppTypography.bodyMedium.copyWith(
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          if (_report!.files.pdfUrl != null)
            PrimaryButton(
              label: 'View PDF Report',
              onPressed: _downloadPDF,
              icon: Icons.picture_as_pdf,
            ),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: () {
              Navigator.of(context).pop();
            },
            icon: const Icon(Icons.arrow_back),
            label: const Text('Back to Reports'),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.primaryBlue,
              side: const BorderSide(color: AppColors.primaryBlue),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(vertical: 16),
              minimumSize: const Size(double.infinity, 50),
            ),
          ),
        ],
      ),
    );
  }
}
