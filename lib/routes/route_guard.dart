import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import 'app_routes.dart';

/// Route guard for protecting authenticated routes
/// Checks authentication state before allowing navigation
///
/// Requirements: 3.6, 4.2, 11.1, 11.2
class RouteGuard {
  /// List of routes that require authentication
  static const List<String> _protectedRoutes = [
    AppRoutes.profileSetup,
    AppRoutes.dashboard,
    AppRoutes.payment,
    AppRoutes.reportProcessing,
    AppRoutes.reportDetail,
  ];

  /// List of routes that should redirect to dashboard if already authenticated
  static const List<String> _guestOnlyRoutes = [
    AppRoutes.login,
    AppRoutes.signup,
    AppRoutes.forgotPassword,
  ];

  /// Check if route requires authentication
  static bool isProtectedRoute(String? routeName) {
    if (routeName == null) return false;
    return _protectedRoutes.contains(routeName);
  }

  /// Check if route is guest-only
  static bool isGuestOnlyRoute(String? routeName) {
    if (routeName == null) return false;
    return _guestOnlyRoutes.contains(routeName);
  }

  /// Guard route navigation based on authentication state
  static Future<bool> canNavigate(
    BuildContext context,
    String routeName,
  ) async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    // Check if route requires authentication
    if (isProtectedRoute(routeName)) {
      if (!authProvider.isAuthenticated) {
        // Redirect to login if not authenticated
        if (context.mounted) {
          Navigator.pushNamedAndRemoveUntil(
            context,
            AppRoutes.login,
            (route) => false,
          );
        }
        return false;
      }

      // Check if session is still valid
      final isSessionValid = await authProvider.isSessionValid();
      if (!isSessionValid) {
        // Session expired, redirect to login
        if (context.mounted) {
          Navigator.pushNamedAndRemoveUntil(
            context,
            AppRoutes.login,
            (route) => false,
          );
        }
        return false;
      }

      // Update activity timestamp
      await authProvider.updateActivity();
      return true;
    }

    // Check if route is guest-only
    if (isGuestOnlyRoute(routeName)) {
      if (authProvider.isAuthenticated) {
        // Already authenticated, redirect to dashboard
        if (context.mounted) {
          Navigator.pushNamedAndRemoveUntil(
            context,
            AppRoutes.dashboard,
            (route) => false,
          );
        }
        return false;
      }
    }

    return true;
  }

  /// Wrapper widget that guards child routes
  static Widget guard({
    required BuildContext context,
    required Widget child,
    required String routeName,
  }) {
    return FutureBuilder<bool>(
      future: canNavigate(context, routeName),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        if (snapshot.hasData && snapshot.data == true) {
          return child;
        }

        // Navigation was blocked, show empty container
        // The actual navigation redirect happens in canNavigate
        return const SizedBox.shrink();
      },
    );
  }
}
