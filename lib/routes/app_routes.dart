import 'package:flutter/material.dart';
import '../screens/splash_screen.dart';
import '../screens/onboarding_screen.dart';
import '../screens/login_screen.dart';
import '../screens/signup_screen.dart';
import '../screens/forgot_password_screen.dart';
import '../screens/profile_setup_screen.dart';
import '../screens/dashboard_screen.dart';
import '../screens/payment_screen.dart';
import '../screens/report_processing_screen.dart';
import '../screens/report_detail_screen.dart';
import '../screens/notifications_screen.dart';
import '../models/service_model.dart';
import '../models/report_model.dart';

/// Central routing configuration for the application
/// Manages all named routes, route guards, and deep linking
///
/// Requirements: 1.1, 1.2, 2.4, 2.5, 3.6, 4.2, 5.4, 6.1
class AppRoutes {
  // Route names
  static const String splash = '/';
  static const String onboarding = '/onboarding';
  static const String login = '/login';
  static const String signup = '/signup';
  static const String forgotPassword = '/forgot-password';
  static const String profileSetup = '/profile-setup';
  static const String dashboard = '/dashboard';
  static const String payment = '/payment';
  static const String reportProcessing = '/report-processing';
  static const String reportDetail = '/report-detail';
  static const String notifications = '/notifications';

  /// Get all route definitions
  static Map<String, WidgetBuilder> getRoutes() {
    return {
      splash: (context) => const SplashScreen(),
      onboarding: (context) => const OnboardingScreen(),
      login: (context) => const LoginScreen(),
      signup: (context) => const SignupScreen(),
      forgotPassword: (context) => const ForgotPasswordScreen(),
      profileSetup: (context) => const ProfileSetupScreen(),
      dashboard: (context) => const DashboardScreen(),
      notifications: (context) => const NotificationsScreen(),
    };
  }

  /// Generate route for dynamic routes with arguments
  static Route<dynamic>? onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case payment:
        final service = settings.arguments as Service?;
        if (service == null) {
          return _errorRoute('Service data is required');
        }
        return MaterialPageRoute(
          builder: (context) => PaymentScreen(service: service),
          settings: settings,
        );

      case reportProcessing:
        final args = settings.arguments as Map<String, dynamic>?;
        if (args == null ||
            !args.containsKey('paymentId') ||
            !args.containsKey('service')) {
          return _errorRoute('Payment and service data are required');
        }
        return MaterialPageRoute(
          builder: (context) => ReportProcessingScreen(
            paymentId: args['paymentId'] as String,
            service: args['service'] as Service,
          ),
          settings: settings,
        );

      case reportDetail:
        final args = settings.arguments as Map<String, dynamic>?;
        if (args == null ||
            !args.containsKey('report') ||
            !args.containsKey('service')) {
          return _errorRoute('Report and service data are required');
        }
        return MaterialPageRoute(
          builder: (context) => ReportDetailScreen(
            report: args['report'] as Report,
            service: args['service'] as Service,
          ),
          settings: settings,
        );

      default:
        return null;
    }
  }

  /// Handle unknown routes
  static Route<dynamic> onUnknownRoute(RouteSettings settings) {
    return _errorRoute('Route not found: ${settings.name}');
  }

  /// Create error route
  static Route<dynamic> _errorRoute(String message) {
    return MaterialPageRoute(
      builder: (context) => Scaffold(
        appBar: AppBar(
          title: const Text('Error'),
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.error_outline,
                  size: 64,
                  color: Colors.red,
                ),
                const SizedBox(height: 16),
                Text(
                  message,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pushNamedAndRemoveUntil(
                      splash,
                      (route) => false,
                    );
                  },
                  child: const Text('Go to Home'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Navigate to payment screen with service
  static Future<void> navigateToPayment(
    BuildContext context,
    Service service,
  ) {
    return Navigator.pushNamed(
      context,
      payment,
      arguments: service,
    );
  }

  /// Navigate to report processing screen
  static Future<void> navigateToReportProcessing(
    BuildContext context, {
    required String paymentId,
    required Service service,
  }) {
    return Navigator.pushNamed(
      context,
      reportProcessing,
      arguments: {
        'paymentId': paymentId,
        'service': service,
      },
    );
  }

  /// Navigate to report detail screen
  static Future<void> navigateToReportDetail(
    BuildContext context, {
    required Report report,
    required Service service,
  }) {
    return Navigator.pushNamed(
      context,
      reportDetail,
      arguments: {
        'report': report,
        'service': service,
      },
    );
  }

  /// Navigate and clear all previous routes
  static Future<void> navigateAndClearStack(
    BuildContext context,
    String routeName,
  ) {
    return Navigator.pushNamedAndRemoveUntil(
      context,
      routeName,
      (route) => false,
    );
  }

  /// Navigate and replace current route
  static Future<void> navigateAndReplace(
    BuildContext context,
    String routeName, {
    Object? arguments,
  }) {
    return Navigator.pushReplacementNamed(
      context,
      routeName,
      arguments: arguments,
    );
  }
}
