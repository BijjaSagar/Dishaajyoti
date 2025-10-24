# Error Handling and Dialogs

This directory contains dialog widgets and error handling utilities for the DishaAjyoti application.

## Components

### 1. SuccessDialog

A dialog widget that displays a success message with an animated checkmark.

**Features:**
- Animated checkmark with elastic scale animation
- Customizable title and message
- Optional dismiss callback
- Customizable button text

**Usage:**
```dart
SuccessDialog.show(
  context,
  title: 'Success',
  message: 'Your profile has been updated successfully!',
  onDismiss: () {
    // Handle dismiss action
  },
);
```

### 2. ErrorDialog

A dialog widget that displays an error message with an error icon and optional retry button.

**Features:**
- Animated error icon with shake effect
- Customizable title and message
- Optional retry callback
- Optional dismiss callback
- Configurable retry button visibility
- Customizable button texts

**Usage:**
```dart
ErrorDialog.show(
  context,
  title: 'Network Error',
  message: 'Please check your connection and try again.',
  onRetry: () {
    // Retry the failed operation
  },
  onDismiss: () {
    // Handle dismiss action
  },
  showRetryButton: true,
);
```

### 3. LoadingOverlay

A widget that displays a loading indicator overlay during async operations.

**Features:**
- Can be used as a widget wrapper or as a dialog
- Optional loading message
- Prevents user interaction while loading
- Customizable appearance

**Usage as Widget:**
```dart
LoadingOverlay(
  isLoading: _isLoading,
  message: 'Loading...',
  child: YourContentWidget(),
)
```

**Usage as Dialog:**
```dart
// Show loading
LoadingOverlay.show(context, message: 'Processing...');

// Hide loading
LoadingOverlay.hide(context);
```

## Error Handler Utility

The `ErrorHandler` class provides a centralized way to handle errors throughout the application.

### Methods

#### handleApiException
Handles API exceptions and shows appropriate error dialogs based on the exception type.

```dart
try {
  final response = await apiService.get('/endpoint');
} on ApiException catch (e) {
  ErrorHandler.handleApiException(
    context,
    e,
    onRetry: () => retryOperation(),
  );
}
```

#### handleException
Handles generic exceptions.

```dart
try {
  // Some operation
} catch (e) {
  ErrorHandler.handleException(context, e);
}
```

#### showSuccess
Shows a success message dialog.

```dart
ErrorHandler.showSuccess(
  context,
  title: 'Success',
  message: 'Operation completed successfully!',
);
```

#### showError
Shows a custom error message dialog.

```dart
ErrorHandler.showError(
  context,
  title: 'Error',
  message: 'Something went wrong',
  showRetryButton: true,
  onRetry: () => retryOperation(),
);
```

#### showNetworkError
Shows a network error dialog with retry option.

```dart
ErrorHandler.showNetworkError(
  context,
  onRetry: () => retryOperation(),
);
```

#### showSessionExpired
Shows a session expired error dialog.

```dart
ErrorHandler.showSessionExpired(
  context,
  onDismiss: () {
    Navigator.pushReplacementNamed(context, '/login');
  },
);
```

#### showPaymentError
Shows a payment error dialog.

```dart
ErrorHandler.showPaymentError(
  context,
  message: 'Payment could not be processed',
  onRetry: () => retryPayment(),
);
```

#### showValidationError
Shows a validation error dialog.

```dart
ErrorHandler.showValidationError(
  context,
  message: 'Please fill in all required fields',
);
```

#### checkNetworkConnectivity
Checks network connectivity and shows error if offline.

```dart
final hasNetwork = await ErrorHandler.checkNetworkConnectivity(context);
if (hasNetwork) {
  // Proceed with network operation
}
```

## Best Practices

1. **Always use LoadingOverlay for async operations** to provide visual feedback to users.

2. **Handle specific exception types** using the appropriate ErrorHandler methods.

3. **Provide retry options** for network and server errors.

4. **Use meaningful error messages** that help users understand what went wrong.

5. **Don't show retry buttons** for validation or authorization errors.

6. **Always hide loading overlays** in finally blocks or catch blocks to prevent UI blocking.

7. **Use onDismiss callbacks** to handle navigation or cleanup after error dialogs.

## Example: Complete API Call with Error Handling

```dart
Future<void> loadUserProfile() async {
  // Show loading
  LoadingOverlay.show(context, message: 'Loading profile...');

  try {
    final apiService = ApiService();
    final response = await apiService.get('/profile');
    
    // Hide loading
    LoadingOverlay.hide(context);
    
    // Update UI with data
    setState(() {
      _profile = Profile.fromJson(response.data);
    });
    
    // Show success message
    ErrorHandler.showSuccess(
      context,
      title: 'Success',
      message: 'Profile loaded successfully!',
    );
  } on ApiException catch (e) {
    // Hide loading
    LoadingOverlay.hide(context);
    
    // Handle API exception with retry
    ErrorHandler.handleApiException(
      context,
      e,
      onRetry: () => loadUserProfile(),
      onDismiss: () {
        // Navigate back if needed
        Navigator.pop(context);
      },
    );
  } catch (e) {
    // Hide loading
    LoadingOverlay.hide(context);
    
    // Handle unexpected errors
    ErrorHandler.showError(
      context,
      title: 'Error',
      message: 'An unexpected error occurred',
    );
  }
}
```

## Error Types Handled

The error handler automatically handles the following API exception types:

- **Network Errors**: Connection issues, timeouts
- **Unauthorized (401)**: Session expired, invalid token
- **Forbidden (403)**: Access denied
- **Not Found (404)**: Resource not found
- **Validation Errors (400)**: Invalid input
- **Server Errors (5xx)**: Backend issues
- **Unknown Errors**: Unexpected errors

Each error type is displayed with an appropriate title, message, and retry option (where applicable).

## Customization

All dialog widgets support customization through their parameters:

- **Colors**: Defined in `app_colors.dart`
- **Typography**: Defined in `app_typography.dart`
- **Animations**: Can be adjusted in the widget constructors
- **Messages**: Can be customized through parameters or constants

## Requirements Satisfied

This implementation satisfies the following requirements from the design document:

- **12.1**: User-friendly error messages for all error types
- **12.2**: Error logging for debugging (handled in ApiService)
- **12.3**: Network error detection with retry option
- **12.4**: Data loss prevention (handled by form state management)
- **12.5**: Support contact option (can be added to critical error dialogs)
