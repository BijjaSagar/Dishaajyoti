import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'theme/app_theme.dart';
import 'providers/auth_provider.dart';
import 'providers/profile_provider.dart';
import 'providers/service_provider.dart';
import 'providers/report_provider.dart';
import 'providers/notification_provider.dart';
import 'providers/language_provider.dart';
import 'routes/app_routes.dart';
import 'routes/navigation_service.dart';
import 'utils/app_lifecycle_observer.dart';
import 'l10n/app_localizations.dart';

/// Background message handler (must be top-level function)
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  debugPrint('Background message received: ${message.messageId}');
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await Firebase.initializeApp();

  // Set up background message handler
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  runApp(const DishaAjyotiApp());
}

class DishaAjyotiApp extends StatelessWidget {
  const DishaAjyotiApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => ProfileProvider()),
        ChangeNotifierProvider(create: (_) => ServiceProvider()),
        ChangeNotifierProvider(create: (_) => ReportProvider()),
        ChangeNotifierProvider(
          create: (_) => NotificationProvider()..initialize(),
        ),
        ChangeNotifierProvider(
          create: (_) => LanguageProvider()..loadLanguage(),
        ),
      ],
      child: Consumer<LanguageProvider>(
        builder: (context, languageProvider, child) {
          return AppLifecycleObserver(
            child: MaterialApp(
              title: 'DishaAjyoti',
              theme: AppTheme.lightTheme,
              darkTheme: AppTheme.darkTheme,
              themeMode: ThemeMode.light,
              debugShowCheckedModeBanner: false,
              navigatorKey: NavigationService().navigatorKey,
              initialRoute: AppRoutes.splash,
              routes: AppRoutes.getRoutes(),
              onGenerateRoute: AppRoutes.onGenerateRoute,
              onUnknownRoute: AppRoutes.onUnknownRoute,
              // Localization configuration
              locale: languageProvider.locale,
              localizationsDelegates: const [
                AppLocalizations.delegate,
                GlobalMaterialLocalizations.delegate,
                GlobalWidgetsLocalizations.delegate,
                GlobalCupertinoLocalizations.delegate,
              ],
              supportedLocales: const [
                Locale('en'), // English
                Locale('hi'), // Hindi
              ],
            ),
          );
        },
      ),
    );
  }
}
