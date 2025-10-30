import 'dart:async';
import 'package:flutter/material.dart';
import '../models/report_model.dart';
import '../models/service_model.dart';
import '../models/firebase/service_report_model.dart';
import '../services/firebase/firestore_service.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';
import '../widgets/buttons/primary_button.dart';
import 'report_detail_screen.dart';
import 'firebase_report_detail_screen.dart';

/// Report processing screen that shows progress while AI generates the report
/// Displays animated loading state and navigates to report detail on completion
/// Supports real-time Firebase updates for report status
class ReportProcessingScreen extends StatefulWidget {
  final String? paymentId;
  final Service? service;
  final String? reportId;
  final ServiceType? serviceType;
  final DateTime? estimatedDelivery;

  const ReportProcessingScreen({
    super.key,
    this.paymentId,
    this.service,
    this.reportId,
    this.serviceType,
    this.estimatedDelivery,
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
  ServiceReport? _firebaseReport;
  StreamSubscription<ServiceReport?>? _reportSubscription;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();

    // Use Firebase real-time updates if reportId is provided
    if (widget.reportId != null) {
      _listenToFirebaseReport();
    } else {
      _startReportGeneration();
    }
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
    _reportSubscription?.cancel();
    super.dispose();
  }

  /// Listen to Firebase report updates in real-time
  void _listenToFirebaseReport() {
    _reportSubscription = FirestoreService.instance
        .watchReport(widget.reportId!)
        .listen((report) {
      if (report == null) return;

      setState(() {
        _firebaseReport = report;
        _updateStatusFromFirebase(report);
      });

      // Auto-navigate when completed
      if (report.status == ServiceReportStatus.completed && report.isReady) {
        _animationController.stop();
        Future.delayed(const Duration(seconds: 1), () {
          if (mounted) {
            _navigateToReportDetail();
          }
        });
      }
    });
  }

  /// Update UI status based on Firebase report status
  void _updateStatusFromFirebase(ServiceReport report) {
    switch (report.status) {
      case ServiceReportStatus.pending:
        _progress = 0.1;
        _statusMessage = 'Request received...';
        _reportStatus = ReportStatus.generating;
        break;
      case ServiceReportStatus.scheduled:
        _progress = 0.2;
        if (widget.estimatedDelivery != null) {
          final remaining =
              widget.estimatedDelivery!.difference(DateTime.now());
          final hours = remaining.inHours;
          _statusMessage = 'Scheduled for processing in $hours hours';
        } else {
          _statusMessage = 'Scheduled for processing...';
        }
        _reportStatus = ReportStatus.generating;
        break;
      case ServiceReportStatus.processing:
        _progress = 0.6;
        _statusMessage = 'AI is generating your report...';
        _reportStatus = ReportStatus.generating;
        break;
      case ServiceReportStatus.completed:
        _progress = 1.0;
        _statusMessage = 'Report ready!';
        _reportStatus = ReportStatus.ready;
        break;
      case ServiceReportStatus.failed:
        _progress = 0.0;
        _statusMessage = report.errorMessage ?? 'Failed to generate report';
        _reportStatus = ReportStatus.failed;
        break;
    }
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
        serviceId: widget.service?.id ?? 'unknown',
        paymentId: widget.paymentId ?? 'unknown',
        fileName:
            '${widget.service?.name.replaceAll(' ', '_') ?? 'Report'}_Report.pdf',
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
    if (_generatedReport != null && widget.service != null) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => ReportDetailScreen(
            report: _generatedReport!,
            service: widget.service!,
          ),
        ),
      );
    } else if (_firebaseReport != null || widget.reportId != null) {
      // Navigate to Firebase report detail screen
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => FirebaseReportDetailScreen(
            reportId: widget.reportId!,
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
                    widget.service?.icon ?? _getServiceIcon(),
                    style: const TextStyle(fontSize: 56),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 48),

            // Service Name
            Text(
              widget.service?.name ??
                  widget.serviceType
                      ?.toString()
                      .split('.')
                      .last
                      .toUpperCase() ??
                  'Report',
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

  String _getServiceIcon() {
    switch (widget.serviceType) {
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
      default:
        return '✨';
    }
  }
}
