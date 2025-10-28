import 'dart:async';
import 'package:flutter/material.dart';
import '../models/service_model.dart';
import '../models/firebase/order_model.dart';
import '../services/firebase/cloud_functions_service.dart';
import '../services/firebase/firestore_service.dart';
import '../services/firebase/firebase_service_manager.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';
import '../widgets/buttons/primary_button.dart';
import 'payment_screen.dart';
import 'report_processing_screen.dart';
import '../l10n/app_localizations.dart';

/// Order confirmation screen showing order details before payment
/// Requirements: 10.2, 10.3
/// Supports Firebase Cloud Functions and testing mode
class OrderConfirmationScreen extends StatefulWidget {
  final Service service;
  final Map<String, dynamic>? additionalData;
  final bool testMode;

  const OrderConfirmationScreen({
    super.key,
    required this.service,
    this.additionalData,
    this.testMode = false,
  });

  @override
  State<OrderConfirmationScreen> createState() =>
      _OrderConfirmationScreenState();
}

class _OrderConfirmationScreenState extends State<OrderConfirmationScreen> {
  bool _isProcessing = false;
  StreamSubscription<FirebaseOrder?>? _orderSubscription;

  @override
  void dispose() {
    _orderSubscription?.cancel();
    super.dispose();
  }

  Future<void> _handleFreeService(BuildContext context) async {
    setState(() {
      _isProcessing = true;
    });

    try {
      // Check if Firebase is available
      final useFirebase = FirebaseServiceManager.instance.isFirebaseAvailable;

      if (useFirebase) {
        final userId = FirebaseServiceManager.instance.currentUserId;
        if (userId == null) {
          throw Exception('User not authenticated');
        }

        // Create order in Firestore with testMode flag
        final order = FirebaseOrder(
          id: '',
          userId: userId,
          serviceType: widget.service.id,
          amount: widget.service.price.toDouble(),
          status: FirebaseOrderStatus.pending,
          createdAt: DateTime.now(),
          testMode: widget.testMode || widget.service.isFree,
          metadata: widget.additionalData,
        );

        final orderId = await FirestoreService.instance.createOrder(order);

        // Listen for order status updates
        _orderSubscription =
            FirestoreService.instance.watchOrder(orderId).listen(
          (updatedOrder) {
            if (updatedOrder?.status == FirebaseOrderStatus.paid &&
                updatedOrder?.reportId != null) {
              // Navigate to report processing screen
              if (mounted) {
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(
                    builder: (context) => ReportProcessingScreen(
                      reportId: updatedOrder!.reportId!,
                      serviceType: null,
                    ),
                  ),
                );
              }
            }
          },
        );

        // In test mode, the Firestore trigger will auto-complete the order
        if (widget.testMode || widget.service.isFree) {
          // Wait a moment for the trigger to process
          await Future.delayed(const Duration(seconds: 2));
        }
      } else {
        // Fallback to local processing
        if (mounted) {
          Navigator.of(context).pop();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Service started successfully'),
              backgroundColor: AppColors.success,
            ),
          );
        }
      }
    } catch (e) {
      setState(() {
        _isProcessing = false;
      });

      if (mounted) {
        final errorMessage = e is CloudFunctionException
            ? CloudFunctionsService.getErrorMessage(e)
            : e.toString();

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $errorMessage'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  Future<void> _handlePayment(BuildContext context) async {
    // Check if Firebase is available
    final useFirebase = FirebaseServiceManager.instance.isFirebaseAvailable;

    if (useFirebase) {
      final userId = FirebaseServiceManager.instance.currentUserId;
      if (userId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please log in to continue'),
            backgroundColor: AppColors.error,
          ),
        );
        return;
      }

      // Create order in Firestore
      final order = FirebaseOrder(
        id: '',
        userId: userId,
        serviceType: widget.service.id,
        amount: widget.service.price.toDouble(),
        status: FirebaseOrderStatus.pending,
        createdAt: DateTime.now(),
        testMode: widget.testMode,
        metadata: widget.additionalData,
      );

      final orderId = await FirestoreService.instance.createOrder(order);

      // Navigate to payment screen with orderId
      if (mounted) {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => PaymentScreen(
              service: widget.service,
              orderId: orderId,
            ),
          ),
        );
      }
    } else {
      // Fallback to PHP backend payment
      if (mounted) {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => PaymentScreen(service: widget.service),
          ),
        );
      }
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
          'Confirm Order',
          style: AppTypography.h3.copyWith(
            color: AppColors.textPrimary,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Success Icon
                    Center(
                      child: Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          color: AppColors.primaryBlue.withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            widget.service.icon,
                            style: const TextStyle(fontSize: 48),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Service Details Card
                    _buildServiceDetailsCard(context),
                    const SizedBox(height: 16),

                    // Order Details Card
                    _buildOrderDetailsCard(),
                    const SizedBox(height: 16),

                    // What You'll Get Card
                    _buildWhatYouGetCard(),
                    const SizedBox(height: 16),

                    // Terms and Conditions
                    _buildTermsCard(),
                  ],
                ),
              ),
            ),

            // Bottom Action Button
            _buildBottomActionButton(context),
          ],
        ),
      ),
    );
  }

  Widget _buildServiceDetailsCard(BuildContext context) {
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
            'Service Details',
            style: AppTypography.h3.copyWith(
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            widget.service.name,
            style: AppTypography.subtitle1.copyWith(
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            widget.service.description,
            style: AppTypography.bodyMedium.copyWith(
              color: AppColors.textSecondary,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.lightBlue,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.access_time,
                  size: 16,
                  color: AppColors.primaryBlue,
                ),
                const SizedBox(width: 6),
                Text(
                  'Delivery: ${widget.service.estimatedTime}',
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.primaryBlue,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderDetailsCard() {
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
            'Order Summary',
            style: AppTypography.h3.copyWith(
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          _buildPriceRow('Service Price', widget.service.price),
          const SizedBox(height: 12),
          _buildPriceRow('Tax & Fees', 0, isSubtotal: true),
          const SizedBox(height: 16),
          const Divider(height: 1, color: AppColors.mediumGray),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Total Amount',
                style: AppTypography.subtitle1.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              Text(
                '₹${widget.service.price}',
                style: AppTypography.h2.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryOrange,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPriceRow(String label, int amount, {bool isSubtotal = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: AppTypography.bodyMedium.copyWith(
            color: isSubtotal ? AppColors.textSecondary : AppColors.textPrimary,
          ),
        ),
        Text(
          amount == 0 ? 'Included' : '₹$amount',
          style: AppTypography.bodyMedium.copyWith(
            color: isSubtotal ? AppColors.textSecondary : AppColors.textPrimary,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildWhatYouGetCard() {
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
          Row(
            children: [
              const Icon(
                Icons.check_circle_outline,
                color: AppColors.success,
                size: 24,
              ),
              const SizedBox(width: 8),
              Text(
                'What You\'ll Get',
                style: AppTypography.h3.copyWith(
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...widget.service.features.map((feature) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      margin: const EdgeInsets.only(top: 6),
                      width: 6,
                      height: 6,
                      decoration: const BoxDecoration(
                        color: AppColors.primaryOrange,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        feature,
                        style: AppTypography.bodyMedium.copyWith(
                          color: AppColors.textSecondary,
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }

  Widget _buildTermsCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.lightBlue,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.primaryBlue.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.info_outline,
                color: AppColors.primaryBlue,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Important Information',
                style: AppTypography.bodyMedium.copyWith(
                  color: AppColors.primaryBlue,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            '• Report will be generated within ${widget.service.estimatedTime}\n'
            '• You will receive a notification when ready\n'
            '• Report can be downloaded as PDF\n'
            '• Refund available if not satisfied',
            style: AppTypography.bodySmall.copyWith(
              color: AppColors.primaryBlue,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomActionButton(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Total:',
                style: AppTypography.subtitle1.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              Text(
                '₹${widget.service.price}',
                style: AppTypography.h2.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryOrange,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (widget.testMode)
            Container(
              padding: const EdgeInsets.all(12),
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: AppColors.warning.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.warning),
              ),
              child: Row(
                children: [
                  const Icon(Icons.science, color: AppColors.warning, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Testing Mode: Payment will be bypassed',
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.warning,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          PrimaryButton(
            label: widget.service.isFree || widget.testMode
                ? 'Start Service'
                : 'Proceed to Payment',
            width: double.infinity,
            isLoading: _isProcessing,
            onPressed: _isProcessing
                ? null
                : () {
                    if (widget.service.isFree || widget.testMode) {
                      _handleFreeService(context);
                    } else {
                      _handlePayment(context);
                    }
                  },
          ),
        ],
      ),
    );
  }
}
