import 'package:flutter/material.dart';

/// Global navigation service for navigating without BuildContext
/// Useful for navigation from services, providers, or background tasks
///
/// Requirements: 1.1, 1.2, 11.3
class NavigationService {
  static final NavigationService _instance = NavigationService._internal();
  factory NavigationService() => _instance;
  NavigationService._internal();

  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  /// Get current context
  BuildContext? get context => navigatorKey.currentContext;

  /// Get current navigator state
  NavigatorState? get navigator => navigatorKey.currentState;

  /// Navigate to named route
  Future<dynamic>? navigateTo(String routeName, {Object? arguments}) {
    return navigator?.pushNamed(routeName, arguments: arguments);
  }

  /// Navigate and replace current route
  Future<dynamic>? navigateAndReplace(String routeName, {Object? arguments}) {
    return navigator?.pushReplacementNamed(routeName, arguments: arguments);
  }

  /// Navigate and clear all previous routes
  Future<dynamic>? navigateAndClearStack(
    String routeName, {
    Object? arguments,
  }) {
    return navigator?.pushNamedAndRemoveUntil(
      routeName,
      (route) => false,
      arguments: arguments,
    );
  }

  /// Pop current route
  void pop([dynamic result]) {
    navigator?.pop(result);
  }

  /// Pop until specific route
  void popUntil(String routeName) {
    navigator?.popUntil(ModalRoute.withName(routeName));
  }

  /// Check if can pop
  bool canPop() {
    return navigator?.canPop() ?? false;
  }

  /// Show dialog
  Future<T?> showDialogWidget<T>(Widget dialog) {
    if (context == null) {
      throw Exception('Navigation context is not available');
    }
    return showDialog<T>(
      context: context!,
      builder: (context) => dialog,
    );
  }

  /// Show bottom sheet
  Future<T?> showBottomSheetWidget<T>(Widget bottomSheet) {
    if (context == null) {
      throw Exception('Navigation context is not available');
    }
    return showModalBottomSheet<T>(
      context: context!,
      builder: (context) => bottomSheet,
    );
  }

  /// Show snackbar
  void showSnackBar(String message, {Duration? duration}) {
    if (context == null) return;

    ScaffoldMessenger.of(context!).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: duration ?? const Duration(seconds: 3),
      ),
    );
  }
}
