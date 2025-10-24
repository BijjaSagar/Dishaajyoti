import '../models/payment_model.dart';
import '../utils/constants.dart';
import 'api_service.dart';

/// Payment service for creating orders and verifying payments
class PaymentService {
  final ApiService _apiService;

  PaymentService({ApiService? apiService})
      : _apiService = apiService ?? ApiService();

  /// Create a payment order
  ///
  /// Requirements: 8.4
  Future<PaymentOrder> createOrder({
    required String serviceId,
    required int amount,
    String currency = 'INR',
    Map<String, dynamic>? metadata,
  }) async {
    try {
      final response = await _apiService.post(
        '${AppConstants.paymentsEndpoint}/orders',
        data: {
          'serviceId': serviceId,
          'amount': amount,
          'currency': currency,
          if (metadata != null) 'metadata': metadata,
        },
      );

      return PaymentOrder.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }

  /// Verify payment after completion
  ///
  /// Requirements: 8.4
  Future<Payment> verifyPayment({
    required String orderId,
    required String paymentId,
    required String signature,
  }) async {
    try {
      final response = await _apiService.post(
        '${AppConstants.paymentsEndpoint}/verify',
        data: {
          'orderId': orderId,
          'paymentId': paymentId,
          'signature': signature,
        },
      );

      return Payment.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }

  /// Get payment by ID
  Future<Payment> getPayment(String paymentId) async {
    try {
      final response = await _apiService.get(
        '${AppConstants.paymentsEndpoint}/$paymentId',
      );

      return Payment.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }

  /// Get all payments for current user
  Future<List<Payment>> getUserPayments({
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final response = await _apiService.get(
        AppConstants.paymentsEndpoint,
        queryParameters: {
          'page': page,
          'limit': limit,
        },
      );

      final List<dynamic> paymentsJson =
          response.data['payments'] ?? response.data;
      return paymentsJson.map((json) => Payment.fromJson(json)).toList();
    } catch (e) {
      rethrow;
    }
  }

  /// Request refund for a payment
  Future<Payment> requestRefund({
    required String paymentId,
    String? reason,
  }) async {
    try {
      final response = await _apiService.post(
        '${AppConstants.paymentsEndpoint}/$paymentId/refund',
        data: {
          if (reason != null) 'reason': reason,
        },
      );

      return Payment.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }

  /// Get payment status
  Future<PaymentStatus> getPaymentStatus(String paymentId) async {
    try {
      final response = await _apiService.get(
        '${AppConstants.paymentsEndpoint}/$paymentId/status',
      );

      final statusString = response.data['status'] as String;
      return PaymentStatus.values.firstWhere(
        (status) => status.name == statusString,
        orElse: () => PaymentStatus.pending,
      );
    } catch (e) {
      rethrow;
    }
  }

  /// Cancel a pending payment
  Future<void> cancelPayment(String paymentId) async {
    try {
      await _apiService.post(
        '${AppConstants.paymentsEndpoint}/$paymentId/cancel',
      );
    } catch (e) {
      rethrow;
    }
  }
}

/// Payment order model for Razorpay integration
class PaymentOrder {
  final String id;
  final String orderId;
  final int amount;
  final String currency;
  final String serviceId;
  final DateTime createdAt;
  final Map<String, dynamic>? metadata;

  PaymentOrder({
    required this.id,
    required this.orderId,
    required this.amount,
    required this.currency,
    required this.serviceId,
    required this.createdAt,
    this.metadata,
  });

  factory PaymentOrder.fromJson(Map<String, dynamic> json) {
    return PaymentOrder(
      id: json['id'] as String,
      orderId: json['orderId'] as String,
      amount: json['amount'] as int,
      currency: json['currency'] as String,
      serviceId: json['serviceId'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      metadata: json['metadata'] as Map<String, dynamic>?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'orderId': orderId,
      'amount': amount,
      'currency': currency,
      'serviceId': serviceId,
      'createdAt': createdAt.toIso8601String(),
      if (metadata != null) 'metadata': metadata,
    };
  }
}
