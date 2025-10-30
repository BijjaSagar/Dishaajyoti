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
import '../screens/report_detail_api_screen.dart';
import '../screens/firebase_report_detail_screen.dart';
import '../screens/reports_list_screen.dart';
import '../screens/notifications_screen.dart';
import '../screens/kundali_input_screen.dart';
import '../screens/kundali_list_screen.dart';
import '../screens/kundali_detail_screen.dart';
import '../screens/palmistry_upload_screen.dart';
import '../screens/palmistry_analysis_screen.dart';
import '../screens/numerology_input_screen.dart';
import '../screens/numerology_analysis_screen.dart';
import '../screens/compatibility_check_screen.dart';
import '../screens/compatibility_result_screen.dart';
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
  static const String reportDetailApi = '/report-detail-api';
  static const String firebaseReportDetail = '/firebase-report-detail';
  static const String reportsList = '/reports-list';
  static const String notifications = '/notifications';

  // Kundali routes
  static const String kundaliInput = '/kundali-input';
  static const String kundaliList = '/kundali-list';
  static const String kundaliDetail = '/kundali-detail';

  // Palmistry routes
  static const String palmistryUpload = '/palmistry-upload';
  static const String palmistryAnalysis = '/palmistry-analysis';

  // Numerology routes
  static const String numerologyInput = '/numerology-input';
  static const String numerologyAnalysis = '/numerology-analysis';

  // Compatibility routes
  static const String compatibilityCheck = '/compatibility-check';
  static const String compatibilityResult = '/compatibility-result';

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
      reportsList: (context) => const ReportsListScreen(),
      notifications: (context) => const NotificationsScreen(),
      kundaliInput: (context) => const KundaliInputScreen(),
      kundaliList: (context) => const KundaliListScreen(),
      palmistryUpload: (context) => const PalmistryUploadScreen(),
      numerologyInput: (context) => const NumerologyInputScreen(),
      compatibilityCheck: (context) => const CompatibilityCheckScreen(),
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

      case reportDetailApi:
        final reportId = settings.arguments;
        if (reportId == null) {
          return _errorRoute('Report ID is required');
        }
        return MaterialPageRoute(
          builder: (context) => ReportDetailApiScreen(
            reportId:
                reportId is int ? reportId : int.parse(reportId.toString()),
          ),
          settings: settings,
        );

      case kundaliDetail:
        final kundaliId = settings.arguments;
        if (kundaliId == null) {
          return _errorRoute('Kundali ID is required');
        }
        return MaterialPageRoute(
          builder: (context) => KundaliDetailScreen(
            kundaliId:
                kundaliId is int ? kundaliId : int.parse(kundaliId.toString()),
          ),
          settings: settings,
        );

      case palmistryAnalysis:
        final analysisData = settings.arguments as Map<String, dynamic>?;
        if (analysisData == null) {
          return _errorRoute('Analysis data is required');
        }
        return MaterialPageRoute(
          builder: (context) =>
              PalmistryAnalysisScreen(analysisData: analysisData),
          settings: settings,
        );

      case numerologyAnalysis:
        final analysisData = settings.arguments as Map<String, dynamic>?;
        if (analysisData == null) {
          return _errorRoute('Analysis data is required');
        }
        return MaterialPageRoute(
          builder: (context) =>
              NumerologyAnalysisScreen(analysisData: analysisData),
          settings: settings,
        );

      case compatibilityResult:
        final compatibilityData = settings.arguments as Map<String, dynamic>?;
        if (compatibilityData == null) {
          return _errorRoute('Compatibility data is required');
        }
        return MaterialPageRoute(
          builder: (context) =>
              CompatibilityResultScreen(compatibilityData: compatibilityData),
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

  /// Navigate to report detail screen (API version)
  static Future<void> navigateToReportDetailApi(
    BuildContext context, {
    required int reportId,
  }) {
    return Navigator.pushNamed(
      context,
      reportDetailApi,
      arguments: reportId,
    );
  }

  /// Navigate to reports list screen
  static Future<void> navigateToReportsList(BuildContext context) {
    return Navigator.pushNamed(context, reportsList);
  }

  /// Navigate to Kundali input screen
  static Future<void> navigateToKundaliInput(BuildContext context) {
    return Navigator.pushNamed(context, kundaliInput);
  }

  /// Navigate to Kundali list screen
  static Future<void> navigateToKundaliList(BuildContext context) {
    return Navigator.pushNamed(context, kundaliList);
  }

  /// Navigate to Kundali detail screen
  static Future<void> navigateToKundaliDetail(
    BuildContext context, {
    required int kundaliId,
  }) {
    return Navigator.pushNamed(
      context,
      kundaliDetail,
      arguments: kundaliId,
    );
  }

  /// Navigate to Palmistry upload screen
  static Future<void> navigateToPalmistryUpload(BuildContext context) {
    return Navigator.pushNamed(context, palmistryUpload);
  }

  /// Navigate to Palmistry analysis screen
  static Future<void> navigateToPalmistryAnalysis(
    BuildContext context, {
    required Map<String, dynamic> analysisData,
  }) {
    return Navigator.pushNamed(
      context,
      palmistryAnalysis,
      arguments: analysisData,
    );
  }

  /// Navigate to Numerology input screen
  static Future<void> navigateToNumerologyInput(BuildContext context) {
    return Navigator.pushNamed(context, numerologyInput);
  }

  /// Navigate to Numerology analysis screen
  static Future<void> navigateToNumerologyAnalysis(
    BuildContext context, {
    required Map<String, dynamic> analysisData,
  }) {
    return Navigator.pushNamed(
      context,
      numerologyAnalysis,
      arguments: analysisData,
    );
  }

  /// Navigate to Compatibility check screen
  static Future<void> navigateToCompatibilityCheck(BuildContext context) {
    return Navigator.pushNamed(context, compatibilityCheck);
  }

  /// Navigate to Compatibility result screen
  static Future<void> navigateToCompatibilityResult(
    BuildContext context, {
    required Map<String, dynamic> compatibilityData,
  }) {
    return Navigator.pushNamed(
      context,
      compatibilityResult,
      arguments: compatibilityData,
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
