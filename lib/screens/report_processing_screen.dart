import 'package:flutter/material.dart';
import '../models/report_model.dart';
import '../models/service_model.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';
import '../widgets/buttons/primary_button.dart';
import 'report_detail_screen.dart';

/// Report processing screen that shows progress while AI generates the report
/// Displays animated loading state and navigates to report detail on completion
class ReportProcessingScreen extends StatefulWidget {
  final String paymentId;
  final Service service;

  const ReportProcessingScreen({
    super.key,
    required this.paymentId,
    required this.service,
  });

  @override
  State<ReportProcessingScreen> createState() => _ReportProcessingScreenState();
}

class _ReportProcessingScreenState extends State<ReportProcessingScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _pulseAnimation;

  ReportStatus _reportStatus = ReportStatus.generating;
  double _progress = 0.0;
  String _statusMessage = 'Initializing AI processor...';
  Report? _generatedReport;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _startReportGeneration();
  }

  void _initializeAnimations() {
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 0.95, end: 1.05).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _startReportGeneration() async {
    // Simulate report generation process with progress updates
    // In production, this would poll the backend API for status updates

    try {
      // Step 1: Analyzing data
      await Future.delayed(const Duration(seconds: 2));
      if (!mounted) return;
      setState(() {
        _progress = 0.25;
        _statusMessage = 'Analyzing your profile data...';
      });

      // Step 2: Processing with AI
      await Future.delayed(const Duration(seconds: 3));
      if (!mounted) return;
      setState(() {
        _progress = 0.50;
        _statusMessage = 'AI is generating insights...';
      });

      // Step 3: Creating report
      await Future.delayed(const Duration(seconds: 2));
      if (!mounted) return;
      setState(() {
        _progress = 0.75;
        _statusMessage = 'Creating your personalized report...';
      });

      // Step 4: Finalizing
      await Future.delayed(const Duration(seconds: 2));
      if (!mounted) return;
      setState(() {
        _progress = 1.0;
        _statusMessage = 'Report ready!';
      });

      // Simulate successful report generation
      await Future.delayed(const Duration(milliseconds: 500));
      if (!mounted) return;

      // Create mock report (in production, this would come from API)
      final report = Report(
        id: 'report_${DateTime.now().millisecondsSinceEpoch}',
        userId: 'user_123', // Replace with actual user ID
        serviceId: widget.service.id,
        paymentId: widget.paymentId,
        fileName: '${widget.service.name.replaceAll(' ', '_')}_Report.pdf',
        fileUrl:
            'https://example.com/reports/sample.pdf', // Replace with actual URL
        fileSize: 1024000, // 1MB
        status: ReportStatus.ready,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      setState(() {
        _reportStatus = ReportStatus.ready;
        _generatedReport = report;
      });

      _animationController.stop();

      // Auto-navigate to report detail after a brief delay
      await Future.delayed(const Duration(seconds: 1));
      if (!mounted) return;
      _navigateToReportDetail();
    } catch (e) {
      // Handle report generation failure
      if (!mounted) return;
      setState(() {
        _reportStatus = ReportStatus.failed;
        _statusMessage = 'Failed to generate report';
      });
      _animationController.stop();
    }
  }

  void _navigateToReportDetail() {
    if (_generatedReport != null) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => ReportDetailScreen(
            report: _generatedReport!,
            service: widget.service,
          ),
        ),
      );
    }
  }

  void _handleRetry() {
    setState(() {
      _reportStatus = ReportStatus.generating;
      _progress = 0.0;
      _statusMessage = 'Initializing AI processor...';
      _generatedReport = null;
    });
    _animationController.repeat(reverse: true);
    _startReportGeneration();
  }

  void _handleContactSupport() {
    // TODO: Implement contact support functionality
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Support contact: support@dishaajyoti.com'),
        backgroundColor: AppColors.info,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: _reportStatus != ReportStatus.generating,
      onPopInvokedWithResult: (bool didPop, dynamic result) async {
        if (!didPop && _reportStatus == ReportStatus.generating) {
          final shouldExit = await _showExitConfirmation();
          if (shouldExit == true && context.mounted) {
            Navigator.of(context).pop();
          }
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.white,
        appBar: AppBar(
          backgroundColor: AppColors.white,
          elevation: 0,
          leading: _reportStatus != ReportStatus.generating
              ? IconButton(
                  icon: const Icon(Icons.arrow_back,
                      color: AppColors.textPrimary),
                  onPressed: () => Navigator.of(context).pop(),
                )
              : null,
          title: Text(
            'Report Generation',
            style: AppTypography.h3.copyWith(
              color: AppColors.textPrimary,
            ),
          ),
          centerTitle: true,
        ),
        body: SafeArea(
          child: _buildBody(),
        ),
      ),
    );
  }

  Widget _buildBody() {
    if (_reportStatus == ReportStatus.failed) {
      return _buildErrorState();
    }

    return _buildProcessingState();
  }

  Widget _buildProcessingState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Animated Icon
            ScaleTransition(
              scale: _pulseAnimation,
              child: Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppColors.primaryOrange, AppColors.accentOrange],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primaryOrange.withValues(alpha: 0.3),
                      blurRadius: 20,
                      spreadRadius: 5,
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    widget.service.icon,
                    style: const TextStyle(fontSize: 56),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 48),

            // Service Name
            Text(
              widget.service.name,
              style: AppTypography.h2.copyWith(
                color: AppColors.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 16),

            // Status Message
            Text(
              _statusMessage,
              style: AppTypography.bodyLarge.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 48),

            // Progress Bar
            Column(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    value: _progress,
                    minHeight: 8,
                    backgroundColor: AppColors.lightGray,
                    valueColor: const AlwaysStoppedAnimation<Color>(
                      AppColors.primaryOrange,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  '${(_progress * 100).toInt()}% Complete',
                  style: AppTypography.bodyMedium.copyWith(
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 48),

            // Info Box
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.lightBlue,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppColors.primaryBlue.withValues(alpha: 0.2),
                ),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.info_outline,
                    color: AppColors.primaryBlue,
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'This usually takes 1-2 minutes. Please don\'t close the app.',
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.primaryBlue,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Error Icon
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: AppColors.error.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.error_outline,
                color: AppColors.error,
                size: 64,
              ),
            ),

            const SizedBox(height: 32),

            // Error Title
            Text(
              'Report Generation Failed',
              style: AppTypography.h2.copyWith(
                color: AppColors.error,
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 16),

            // Error Message
            Text(
              'We encountered an issue while generating your report. '
              'Don\'t worry, your payment is safe and we\'ll process a refund.',
              style: AppTypography.bodyLarge.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 48),

            // Action Buttons
            Column(
              children: [
                PrimaryButton(
                  label: 'Retry Generation',
                  width: double.infinity,
                  onPressed: _handleRetry,
                ),
                const SizedBox(height: 12),
                OutlinedButton(
                  onPressed: _handleContactSupport,
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: AppColors.primaryBlue),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: SizedBox(
                    width: double.infinity,
                    child: Text(
                      'Contact Support',
                      style: AppTypography.button.copyWith(
                        color: AppColors.primaryBlue,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text(
                    'Back to Dashboard',
                    style: AppTypography.bodyMedium.copyWith(
                      color: AppColors.textSecondary,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<bool?> _showExitConfirmation() {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Text(
          'Exit Report Generation?',
          style: AppTypography.h3.copyWith(
            color: AppColors.textPrimary,
          ),
        ),
        content: Text(
          'Your report is still being generated. If you exit now, '
          'you can check the status later in the Reports tab.',
          style: AppTypography.bodyMedium.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(
              'Stay',
              style: AppTypography.button.copyWith(
                color: AppColors.primaryBlue,
              ),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(
              'Exit',
              style: AppTypography.button.copyWith(
                color: AppColors.error,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
