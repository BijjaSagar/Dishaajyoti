import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/foundation.dart';
import 'firebase_service_manager.dart';

/// Exception thrown when Cloud Function call fails
class CloudFunctionException implements Exception {
  final String code;
  final String message;
  final dynamic details;

  CloudFunctionException({
    required this.code,
    required this.message,
    this.details,
  });

  @override
  String toString() => 'CloudFunctionException: [$code] $message';
}

/// Service for calling Firebase Cloud Functions
class CloudFunctionsService {
  // Singleton instance
  static final CloudFunctionsService _instance =
      CloudFunctionsService._internal();

  factory CloudFunctionsService() => _instance;

  CloudFunctionsService._internal();

  // Convenience getter for singleton instance
  static CloudFunctionsService get instance => _instance;

  // Get Cloud Functions instance from service manager
  FirebaseFunctions get _functions => FirebaseServiceManager.instance.functions;

  // ==================== Kundali Generation ====================

  /// Generate Kundali using Cloud Function
  /// Returns a map containing reportId and status
  Future<Map<String, dynamic>> generateKundali({
    required String userId,
    required Map<String, dynamic> birthDetails,
    required String chartStyle,
  }) async {
    try {
      debugPrint('Calling generateKundali Cloud Function...');

      final callable = _functions.httpsCallable('generateKundali');
      final result = await callable.call<Map<String, dynamic>>({
        'userId': userId,
        'birthDetails': birthDetails,
        'chartStyle': chartStyle,
      });

      debugPrint('Kundali generation initiated: ${result.data}');
      return Map<String, dynamic>.from(result.data);
    } on FirebaseFunctionsException catch (e) {
      debugPrint('Cloud Function error: ${e.code} - ${e.message}');
      throw CloudFunctionException(
        code: e.code,
        message: e.message ?? 'Failed to generate Kundali',
        details: e.details,
      );
    } catch (e) {
      debugPrint('Unexpected error calling generateKundali: $e');
      throw CloudFunctionException(
        code: 'unknown',
        message: 'An unexpected error occurred: $e',
      );
    }
  }

  // ==================== Palmistry Analysis ====================

  /// Request Palmistry analysis (24h delay)
  /// Returns a map containing reportId, status, and estimatedDelivery
  Future<Map<String, dynamic>> requestPalmistryAnalysis({
    required String userId,
    required String imageUrl,
    required Map<String, dynamic> options,
  }) async {
    try {
      debugPrint('Calling requestPalmistryAnalysis Cloud Function...');

      final callable = _functions.httpsCallable('requestPalmistryAnalysis');
      final result = await callable.call<Map<String, dynamic>>({
        'userId': userId,
        'imageUrl': imageUrl,
        'options': options,
      });

      debugPrint('Palmistry analysis scheduled: ${result.data}');
      return Map<String, dynamic>.from(result.data);
    } on FirebaseFunctionsException catch (e) {
      debugPrint('Cloud Function error: ${e.code} - ${e.message}');
      throw CloudFunctionException(
        code: e.code,
        message: e.message ?? 'Failed to request Palmistry analysis',
        details: e.details,
      );
    } catch (e) {
      debugPrint('Unexpected error calling requestPalmistryAnalysis: $e');
      throw CloudFunctionException(
        code: 'unknown',
        message: 'An unexpected error occurred: $e',
      );
    }
  }

  // ==================== Numerology Report ====================

  /// Request Numerology report (12h delay)
  /// Returns a map containing reportId, status, and estimatedDelivery
  Future<Map<String, dynamic>> requestNumerologyReport({
    required String userId,
    required Map<String, dynamic> details,
  }) async {
    try {
      debugPrint('Calling requestNumerologyReport Cloud Function...');

      final callable = _functions.httpsCallable('requestNumerologyReport');
      final result = await callable.call<Map<String, dynamic>>({
        'userId': userId,
        'details': details,
      });

      debugPrint('Numerology report scheduled: ${result.data}');
      return Map<String, dynamic>.from(result.data);
    } on FirebaseFunctionsException catch (e) {
      debugPrint('Cloud Function error: ${e.code} - ${e.message}');
      throw CloudFunctionException(
        code: e.code,
        message: e.message ?? 'Failed to request Numerology report',
        details: e.details,
      );
    } catch (e) {
      debugPrint('Unexpected error calling requestNumerologyReport: $e');
      throw CloudFunctionException(
        code: 'unknown',
        message: 'An unexpected error occurred: $e',
      );
    }
  }

  // ==================== Payment Processing ====================

  /// Process payment using Cloud Function
  /// Returns a map containing order status and payment confirmation
  Future<Map<String, dynamic>> processPayment({
    required String orderId,
    required String paymentId,
    required double amount,
    String? paymentMethod,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      debugPrint('Calling processPayment Cloud Function...');

      final callable = _functions.httpsCallable('processPayment');
      final result = await callable.call<Map<String, dynamic>>({
        'orderId': orderId,
        'paymentId': paymentId,
        'amount': amount,
        'paymentMethod': paymentMethod,
        'metadata': metadata,
      });

      debugPrint('Payment processed: ${result.data}');
      return Map<String, dynamic>.from(result.data);
    } on FirebaseFunctionsException catch (e) {
      debugPrint('Cloud Function error: ${e.code} - ${e.message}');
      throw CloudFunctionException(
        code: e.code,
        message: e.message ?? 'Failed to process payment',
        details: e.details,
      );
    } catch (e) {
      debugPrint('Unexpected error calling processPayment: $e');
      throw CloudFunctionException(
        code: 'unknown',
        message: 'An unexpected error occurred: $e',
      );
    }
  }

  // ==================== Matchmaking/Compatibility ====================

  /// Request compatibility check
  /// Returns a map containing reportId and status
  Future<Map<String, dynamic>> requestCompatibilityCheck({
    required String userId,
    required Map<String, dynamic> person1Details,
    required Map<String, dynamic> person2Details,
  }) async {
    try {
      debugPrint('Calling requestCompatibilityCheck Cloud Function...');

      final callable = _functions.httpsCallable('requestCompatibilityCheck');
      final result = await callable.call<Map<String, dynamic>>({
        'userId': userId,
        'person1Details': person1Details,
        'person2Details': person2Details,
      });

      debugPrint('Compatibility check initiated: ${result.data}');
      return Map<String, dynamic>.from(result.data);
    } on FirebaseFunctionsException catch (e) {
      debugPrint('Cloud Function error: ${e.code} - ${e.message}');
      throw CloudFunctionException(
        code: e.code,
        message: e.message ?? 'Failed to request compatibility check',
        details: e.details,
      );
    } catch (e) {
      debugPrint('Unexpected error calling requestCompatibilityCheck: $e');
      throw CloudFunctionException(
        code: 'unknown',
        message: 'An unexpected error occurred: $e',
      );
    }
  }

  // ==================== Order Management ====================

  /// Cancel an order
  /// Returns a map containing cancellation status
  Future<Map<String, dynamic>> cancelOrder({
    required String orderId,
    String? reason,
  }) async {
    try {
      debugPrint('Calling cancelOrder Cloud Function...');

      final callable = _functions.httpsCallable('cancelOrder');
      final result = await callable.call<Map<String, dynamic>>({
        'orderId': orderId,
        'reason': reason,
      });

      debugPrint('Order cancelled: ${result.data}');
      return Map<String, dynamic>.from(result.data);
    } on FirebaseFunctionsException catch (e) {
      debugPrint('Cloud Function error: ${e.code} - ${e.message}');
      throw CloudFunctionException(
        code: e.code,
        message: e.message ?? 'Failed to cancel order',
        details: e.details,
      );
    } catch (e) {
      debugPrint('Unexpected error calling cancelOrder: $e');
      throw CloudFunctionException(
        code: 'unknown',
        message: 'An unexpected error occurred: $e',
      );
    }
  }

  // ==================== Error Handling Helpers ====================

  /// Get user-friendly error message from Cloud Function exception
  static String getErrorMessage(dynamic error) {
    if (error is CloudFunctionException) {
      switch (error.code) {
        case 'unauthenticated':
          return 'You must be logged in to perform this action';
        case 'permission-denied':
          return 'You do not have permission to perform this action';
        case 'not-found':
          return 'The requested resource was not found';
        case 'already-exists':
          return 'This resource already exists';
        case 'invalid-argument':
          return 'Invalid input provided. Please check your data';
        case 'deadline-exceeded':
          return 'Request timed out. Please try again';
        case 'unavailable':
          return 'Service temporarily unavailable. Please try again later';
        case 'resource-exhausted':
          return 'Service limit reached. Please try again later';
        default:
          return error.message;
      }
    } else if (error is FirebaseFunctionsException) {
      return error.message ?? 'An error occurred';
    }
    return 'An unexpected error occurred';
  }

  /// Check if error is retryable
  static bool isRetryableError(dynamic error) {
    if (error is CloudFunctionException) {
      return error.code == 'unavailable' ||
          error.code == 'deadline-exceeded' ||
          error.code == 'resource-exhausted';
    }
    return false;
  }

  /// Retry a Cloud Function call with exponential backoff
  Future<T> retryCall<T>(
    Future<T> Function() call, {
    int maxRetries = 3,
    Duration initialDelay = const Duration(seconds: 1),
  }) async {
    int retries = 0;
    Duration delay = initialDelay;

    while (true) {
      try {
        return await call();
      } catch (e) {
        retries++;
        if (retries >= maxRetries || !isRetryableError(e)) {
          rethrow;
        }

        debugPrint(
            'Retrying Cloud Function call (attempt $retries/$maxRetries)...');
        await Future.delayed(delay);
        delay *= 2; // Exponential backoff
      }
    }
  }
}
