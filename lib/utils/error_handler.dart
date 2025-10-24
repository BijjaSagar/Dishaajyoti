import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../widgets/dialogs/error_dialog.dart';
import '../widgets/dialogs/success_dialog.dart';
import 'constants.dart';

/// Global error handler for API errors and network issues
class ErrorHandler {
  /// Handle API exception and show appropriate dialog
  static void handleApiException(
    BuildContext context,
    ApiException exception, {
    VoidCallback? onRetry,
    VoidCallback? onDismiss,
  }) {
    String title = 'Error';
    String message = exception.message;
    bool showRetry = false;

    switch (exception.type) {
      case ApiExceptionType.network:
        title = 'Network Error';
        message = AppConstants.networkErrorMessage;
        showRetry = true;
        break;

      case ApiExceptionType.timeout:
        title = 'Connection Timeout';
        message = 'The request took too long. Please try again.';
        showRetry = true;
        break;

      case ApiExceptionType.unauthorized:
        title = 'Session Expired';
        message = AppConstants.sessionExpiredMessage;
        showRetry = false;
        break;

      case ApiExceptionType.forbidden:
        title = 'Access Denied';
        message = 'You do not have permission to perform this action.';
        showRetry = false;
        break;

      case ApiExceptionType.notFound:
        title = 'Not Found';
        message = 'The requested resource was not found.';
        showRetry = false;
        break;

      case ApiExceptionType.validation:
        title = 'Validation Error';
        message = exception.message;
        showRetry = false;
        break;

      case ApiExceptionType.server:
        title = 'Server Error';
        message = AppConstants.serverErrorMessage;
        showRetry = true;
        break;

      case ApiExceptionType.unknown:
        title = 'Error';
        message = AppConstants.unknownErrorMessage;
        showRetry = true;
        break;
    }

    ErrorDialog.show(
      context,
      title: title,
      message: message,
      onRetry: showRetry ? onRetry : null,
      onDismiss: onDismiss,
      showRetryButton: showRetry && onRetry != null,
    );
  }

  /// Handle generic exception
  static void handleException(
    BuildContext context,
    Exception exception, {
    VoidCallback? onRetry,
    VoidCallback? onDismiss,
  }) {
    if (exception is ApiException) {
      handleApiException(
        context,
        exception,
        onRetry: onRetry,
        onDismiss: onDismiss,
      );
    } else {
      ErrorDialog.show(
        context,
        title: 'Error',
        message: exception.toString(),
        onRetry: onRetry,
        onDismiss: onDismiss,
        showRetryButton: onRetry != null,
      );
    }
  }

  /// Show success message
  static void showSuccess(
    BuildContext context, {
    required String title,
    required String message,
    VoidCallback? onDismiss,
  }) {
    SuccessDialog.show(
      context,
      title: title,
      message: message,
      onDismiss: onDismiss,
    );
  }

  /// Show error message
  static void showError(
    BuildContext context, {
    required String title,
    required String message,
    VoidCallback? onRetry,
    VoidCallback? onDismiss,
    bool showRetryButton = false,
  }) {
    ErrorDialog.show(
      context,
      title: title,
      message: message,
      onRetry: onRetry,
      onDismiss: onDismiss,
      showRetryButton: showRetryButton,
    );
  }

  /// Check network connectivity and show error if offline
  static Future<bool> checkNetworkConnectivity(BuildContext context) async {
    // This is a placeholder - in production, use connectivity_plus package
    // For now, we'll assume network is available
    // In a real implementation:
    // final connectivityResult = await Connectivity().checkConnectivity();
    // if (connectivityResult == ConnectivityResult.none) {
    //   showError(
    //     context,
    //     title: 'No Internet Connection',
    //     message: 'Please check your internet connection and try again.',
    //     showRetryButton: true,
    //   );
    //   return false;
    // }
    return true;
  }

  /// Show network error with retry option
  static void showNetworkError(
    BuildContext context, {
    required VoidCallback onRetry,
    VoidCallback? onDismiss,
  }) {
    ErrorDialog.show(
      context,
      title: 'Network Error',
      message: AppConstants.networkErrorMessage,
      onRetry: onRetry,
      onDismiss: onDismiss,
      showRetryButton: true,
    );
  }

  /// Show session expired error
  static void showSessionExpired(
    BuildContext context, {
    VoidCallback? onDismiss,
  }) {
    ErrorDialog.show(
      context,
      title: 'Session Expired',
      message: AppConstants.sessionExpiredMessage,
      onDismiss: onDismiss,
      showRetryButton: false,
    );
  }

  /// Show payment error
  static void showPaymentError(
    BuildContext context, {
    String? message,
    VoidCallback? onRetry,
    VoidCallback? onDismiss,
  }) {
    ErrorDialog.show(
      context,
      title: 'Payment Failed',
      message: message ?? AppConstants.paymentFailedMessage,
      onRetry: onRetry,
      onDismiss: onDismiss,
      showRetryButton: onRetry != null,
    );
  }

  /// Show validation error
  static void showValidationError(
    BuildContext context, {
    required String message,
    VoidCallback? onDismiss,
  }) {
    ErrorDialog.show(
      context,
      title: 'Validation Error',
      message: message,
      onDismiss: onDismiss,
      showRetryButton: false,
    );
  }
}
