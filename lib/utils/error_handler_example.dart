import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../widgets/dialogs/loading_overlay.dart';
import 'error_handler.dart';

/// Example usage of error handling utilities
/// This file demonstrates how to use the error handling components
/// in various scenarios throughout the application.

class ErrorHandlerExample {
  /// Example 1: Handling API call with loading and error handling
  static Future<void> exampleApiCall(BuildContext context) async {
    // Show loading overlay
    LoadingOverlay.show(context, message: 'Loading...');

    try {
      // Make API call
      final apiService = ApiService();
      final response = await apiService.get('/example-endpoint');

      // Hide loading overlay
      LoadingOverlay.hide(context);

      // Show success message
      ErrorHandler.showSuccess(
        context,
        title: 'Success',
        message: 'Data loaded successfully!',
      );
    } on ApiException catch (e) {
      // Hide loading overlay
      LoadingOverlay.hide(context);

      // Handle API exception with retry option
      ErrorHandler.handleApiException(
        context,
        e,
        onRetry: () => exampleApiCall(context),
        onDismiss: () {
          // Handle dismiss action
          print('User dismissed error dialog');
        },
      );
    } catch (e) {
      // Hide loading overlay
      LoadingOverlay.hide(context);

      // Handle generic exception
      ErrorHandler.showError(
        context,
        title: 'Error',
        message: 'An unexpected error occurred',
      );
    }
  }

  /// Example 2: Using LoadingOverlay as a widget wrapper
  static Widget exampleWithLoadingWidget(bool isLoading) {
    return LoadingOverlay(
      isLoading: isLoading,
      message: 'Processing...',
      child: Scaffold(
        appBar: AppBar(title: const Text('Example')),
        body: const Center(
          child: Text('Content goes here'),
        ),
      ),
    );
  }

  /// Example 3: Network error handling
  static Future<void> exampleNetworkCheck(BuildContext context) async {
    final hasNetwork = await ErrorHandler.checkNetworkConnectivity(context);

    if (!hasNetwork) {
      ErrorHandler.showNetworkError(
        context,
        onRetry: () => exampleNetworkCheck(context),
      );
      return;
    }

    // Proceed with network operation
    print('Network is available');
  }

  /// Example 4: Payment error handling
  static void examplePaymentError(BuildContext context) {
    ErrorHandler.showPaymentError(
      context,
      message: 'Payment could not be processed. Please try again.',
      onRetry: () {
        // Retry payment
        print('Retrying payment...');
      },
      onDismiss: () {
        // Navigate back or handle dismissal
        Navigator.of(context).pop();
      },
    );
  }

  /// Example 5: Session expired handling
  static void exampleSessionExpired(BuildContext context) {
    ErrorHandler.showSessionExpired(
      context,
      onDismiss: () {
        // Navigate to login screen
        Navigator.of(context).pushReplacementNamed('/login');
      },
    );
  }

  /// Example 6: Validation error
  static void exampleValidationError(BuildContext context) {
    ErrorHandler.showValidationError(
      context,
      message: 'Please fill in all required fields correctly.',
    );
  }

  /// Example 7: Custom success message
  static void exampleSuccessMessage(BuildContext context) {
    ErrorHandler.showSuccess(
      context,
      title: 'Profile Updated',
      message: 'Your profile has been updated successfully!',
      onDismiss: () {
        // Navigate to profile screen
        Navigator.of(context).pushReplacementNamed('/profile');
      },
    );
  }

  /// Example 8: Handling multiple retry attempts
  static Future<void> exampleWithRetryLimit(
    BuildContext context, {
    int maxRetries = 3,
    int currentAttempt = 0,
  }) async {
    LoadingOverlay.show(context, message: 'Attempting to connect...');

    try {
      final apiService = ApiService();
      final response = await apiService.get('/example-endpoint');

      LoadingOverlay.hide(context);

      ErrorHandler.showSuccess(
        context,
        title: 'Success',
        message: 'Connected successfully!',
      );
    } on ApiException catch (e) {
      LoadingOverlay.hide(context);

      if (currentAttempt < maxRetries) {
        ErrorHandler.handleApiException(
          context,
          e,
          onRetry: () => exampleWithRetryLimit(
            context,
            maxRetries: maxRetries,
            currentAttempt: currentAttempt + 1,
          ),
        );
      } else {
        ErrorHandler.showError(
          context,
          title: 'Connection Failed',
          message: 'Maximum retry attempts reached. Please try again later.',
          showRetryButton: false,
        );
      }
    }
  }
}
