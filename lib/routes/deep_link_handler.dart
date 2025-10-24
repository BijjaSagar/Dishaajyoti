import 'package:flutter/material.dart';
import 'app_routes.dart';

/// Deep link handler for processing app links and universal links
/// Supports navigation from external sources
///
/// Requirements: 1.1, 1.2
class DeepLinkHandler {
  /// Parse deep link URI and return route information
  static DeepLinkRoute? parseDeepLink(Uri uri) {
    // Handle different deep link patterns
    final path = uri.path;
    final queryParams = uri.queryParameters;

    // Example deep link patterns:
    // dishaajyoti://app/login
    // dishaajyoti://app/dashboard
    // dishaajyoti://app/service/{serviceId}
    // dishaajyoti://app/report/{reportId}
    // https://dishaajyoti.com/reset-password?token=xxx

    switch (path) {
      case '/':
      case '/home':
        return DeepLinkRoute(
          routeName: AppRoutes.splash,
        );

      case '/login':
        return DeepLinkRoute(
          routeName: AppRoutes.login,
        );

      case '/signup':
        return DeepLinkRoute(
          routeName: AppRoutes.signup,
        );

      case '/dashboard':
        return DeepLinkRoute(
          routeName: AppRoutes.dashboard,
        );

      case '/reset-password':
        final token = queryParams['token'];
        if (token != null) {
          return DeepLinkRoute(
            routeName: AppRoutes.forgotPassword,
            arguments: {'token': token},
          );
        }
        return DeepLinkRoute(
          routeName: AppRoutes.forgotPassword,
        );

      default:
        // Handle dynamic routes
        if (path.startsWith('/service/')) {
          final serviceId = path.replaceFirst('/service/', '');
          return DeepLinkRoute(
            routeName: AppRoutes.dashboard,
            arguments: {'serviceId': serviceId},
          );
        }

        if (path.startsWith('/report/')) {
          final reportId = path.replaceFirst('/report/', '');
          return DeepLinkRoute(
            routeName: AppRoutes.dashboard,
            arguments: {'reportId': reportId},
          );
        }

        return null;
    }
  }

  /// Handle deep link navigation
  static Future<void> handleDeepLink(
    BuildContext context,
    Uri uri,
  ) async {
    final deepLinkRoute = parseDeepLink(uri);

    if (deepLinkRoute == null) {
      // Invalid deep link, navigate to splash
      Navigator.pushNamedAndRemoveUntil(
        context,
        AppRoutes.splash,
        (route) => false,
      );
      return;
    }

    // Navigate to the parsed route
    if (deepLinkRoute.arguments != null) {
      Navigator.pushNamed(
        context,
        deepLinkRoute.routeName,
        arguments: deepLinkRoute.arguments,
      );
    } else {
      Navigator.pushNamed(
        context,
        deepLinkRoute.routeName,
      );
    }
  }

  /// Create deep link URI for sharing
  static Uri createDeepLink({
    required String path,
    Map<String, String>? queryParameters,
  }) {
    return Uri(
      scheme: 'dishaajyoti',
      host: 'app',
      path: path,
      queryParameters: queryParameters,
    );
  }

  /// Create web link for sharing
  static Uri createWebLink({
    required String path,
    Map<String, String>? queryParameters,
  }) {
    return Uri(
      scheme: 'https',
      host: 'dishaajyoti.com',
      path: path,
      queryParameters: queryParameters,
    );
  }

  /// Get shareable link for a report
  static Uri getReportShareLink(String reportId) {
    return createWebLink(
      path: '/report/$reportId',
    );
  }

  /// Get shareable link for a service
  static Uri getServiceShareLink(String serviceId) {
    return createWebLink(
      path: '/service/$serviceId',
    );
  }
}

/// Deep link route information
class DeepLinkRoute {
  final String routeName;
  final Object? arguments;

  DeepLinkRoute({
    required this.routeName,
    this.arguments,
  });
}
