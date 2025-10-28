import 'dart:async';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'firebase_service_manager.dart';
import 'firestore_service.dart';
import '../../routes/navigation_service.dart';
import '../../routes/app_routes.dart';

/// Firebase Cloud Messaging service for handling push notifications
/// Integrates with Firestore to store FCM tokens and manage notification state
///
/// Requirements: 6.2, 6.3
class FirebaseNotificationService {
  // Singleton instance
  static final FirebaseNotificationService _instance =
      FirebaseNotificationService._internal();

  factory FirebaseNotificationService() => _instance;

  FirebaseNotificationService._internal();

  // Convenience getter for singleton instance
  static FirebaseNotificationService get instance => _instance;

  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final FirestoreService _firestoreService = FirestoreService.instance;

  // Callbacks for handling notifications
  Function(RemoteMessage)? onForegroundMessage;
  Function(RemoteMessage)? onMessageTap;
  Function(String)? onTokenRefresh;

  bool _isInitialized = false;
  String? _currentToken;

  /// Initialize Firebase Cloud Messaging
  /// Requests permissions, gets FCM token, and sets up listeners
  ///
  /// Requirements: 6.2, 6.3
  Future<void> initialize() async {
    if (_isInitialized) {
      debugPrint('Firebase Notification Service already initialized');
      return;
    }

    try {
      // Request notification permissions (iOS)
      final settings = await _requestPermission();

      if (settings.authorizationStatus == AuthorizationStatus.authorized ||
          settings.authorizationStatus == AuthorizationStatus.provisional) {
        debugPrint('Notification permission granted');

        // Get and store FCM token
        await _initializeFCMToken();

        // Set up message handlers
        _setupMessageHandlers();

        // Listen to token refresh
        _setupTokenRefreshListener();

        _isInitialized = true;
        debugPrint('Firebase Notification Service initialized successfully');
      } else {
        debugPrint('Notification permission denied');
      }
    } catch (e) {
      debugPrint('Error initializing Firebase Notification Service: $e');
      rethrow;
    }
  }

  /// Request notification permissions (primarily for iOS)
  Future<NotificationSettings> _requestPermission() async {
    try {
      return await _firebaseMessaging.requestPermission(
        alert: true,
        announcement: false,
        badge: true,
        carPlay: false,
        criticalAlert: false,
        provisional: false,
        sound: true,
      );
    } catch (e) {
      debugPrint('Error requesting notification permission: $e');
      rethrow;
    }
  }

  /// Initialize FCM token and store in Firestore
  Future<void> _initializeFCMToken() async {
    try {
      // Get FCM token
      _currentToken = await _firebaseMessaging.getToken();

      if (_currentToken != null) {
        debugPrint('FCM Token obtained: $_currentToken');

        // Store token in Firestore if user is authenticated
        await _storeFCMTokenInFirestore(_currentToken!);
      } else {
        debugPrint('Failed to get FCM token');
      }
    } catch (e) {
      debugPrint('Error initializing FCM token: $e');
    }
  }

  /// Store FCM token in Firestore user profile
  Future<void> _storeFCMTokenInFirestore(String token) async {
    try {
      final userId = FirebaseServiceManager.instance.currentUserId;

      if (userId != null) {
        await _firestoreService.updateFCMToken(userId, token);
        debugPrint('FCM token stored in Firestore for user: $userId');
      } else {
        debugPrint('No authenticated user, FCM token not stored');
      }
    } catch (e) {
      debugPrint('Error storing FCM token in Firestore: $e');
    }
  }

  /// Set up message handlers for foreground and background
  void _setupMessageHandlers() {
    // Handle foreground messages
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      debugPrint('Foreground message received: ${message.messageId}');
      debugPrint('Title: ${message.notification?.title}');
      debugPrint('Body: ${message.notification?.body}');
      debugPrint('Data: ${message.data}');

      // Trigger callback if set
      if (onForegroundMessage != null) {
        onForegroundMessage!(message);
      }
    });

    // Handle notification taps when app is in background
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      debugPrint('Notification tapped (background): ${message.messageId}');
      _handleNotificationTap(message);
    });
  }

  /// Set up listener for token refresh
  void _setupTokenRefreshListener() {
    _firebaseMessaging.onTokenRefresh.listen((String newToken) {
      debugPrint('FCM Token refreshed: $newToken');
      _currentToken = newToken;

      // Store new token in Firestore
      _storeFCMTokenInFirestore(newToken);

      // Trigger callback if set
      if (onTokenRefresh != null) {
        onTokenRefresh!(newToken);
      }
    });
  }

  /// Handle notification tap and navigate to appropriate screen
  void _handleNotificationTap(RemoteMessage message) {
    debugPrint('Handling notification tap');
    debugPrint('Notification data: ${message.data}');

    // Extract notification type and data
    final notificationType = message.data['type'] as String?;
    final reportId = message.data['reportId'] as String?;
    final orderId = message.data['orderId'] as String?;

    // Navigate based on notification type
    try {
      switch (notificationType) {
        case 'kundali_ready':
        case 'palmistry_ready':
        case 'numerology_ready':
        case 'report_ready':
        case 'report_failed':
          if (reportId != null) {
            // Navigate to report detail screen
            NavigationService().navigateTo(
              AppRoutes.reportDetailApi,
              arguments: reportId,
            );
          } else {
            // Navigate to reports list if no specific report ID
            NavigationService().navigateTo(AppRoutes.reportsList);
          }
          break;

        case 'payment_confirmed':
          if (orderId != null) {
            // Navigate to reports list to see the processing report
            NavigationService().navigateTo(AppRoutes.reportsList);
          }
          break;

        case 'report_scheduled':
          // Navigate to reports list to see scheduled reports
          NavigationService().navigateTo(AppRoutes.reportsList);
          break;

        default:
          // For unknown types, navigate to notifications screen
          NavigationService().navigateTo(AppRoutes.notifications);
          break;
      }
    } catch (e) {
      debugPrint('Error navigating from notification: $e');
      // Fallback to notifications screen
      NavigationService().navigateTo(AppRoutes.notifications);
    }

    // Trigger callback if set
    if (onMessageTap != null) {
      onMessageTap!(message);
    }
  }

  /// Check if app was opened from a terminated state via notification
  Future<void> checkInitialMessage() async {
    try {
      final initialMessage = await _firebaseMessaging.getInitialMessage();

      if (initialMessage != null) {
        debugPrint(
          'App opened from terminated state via notification: ${initialMessage.messageId}',
        );
        _handleNotificationTap(initialMessage);
      }
    } catch (e) {
      debugPrint('Error checking initial message: $e');
    }
  }

  /// Get current FCM token
  Future<String?> getToken() async {
    try {
      if (_currentToken != null) {
        return _currentToken;
      }

      _currentToken = await _firebaseMessaging.getToken();
      return _currentToken;
    } catch (e) {
      debugPrint('Error getting FCM token: $e');
      return null;
    }
  }

  /// Delete FCM token (for logout)
  Future<void> deleteToken() async {
    try {
      await _firebaseMessaging.deleteToken();
      _currentToken = null;
      debugPrint('FCM token deleted');
    } catch (e) {
      debugPrint('Error deleting FCM token: $e');
    }
  }

  /// Subscribe to a topic
  Future<void> subscribeToTopic(String topic) async {
    try {
      await _firebaseMessaging.subscribeToTopic(topic);
      debugPrint('Subscribed to topic: $topic');
    } catch (e) {
      debugPrint('Error subscribing to topic $topic: $e');
    }
  }

  /// Unsubscribe from a topic
  Future<void> unsubscribeFromTopic(String topic) async {
    try {
      await _firebaseMessaging.unsubscribeFromTopic(topic);
      debugPrint('Unsubscribed from topic: $topic');
    } catch (e) {
      debugPrint('Error unsubscribing from topic $topic: $e');
    }
  }

  /// Get notification settings
  Future<NotificationSettings> getNotificationSettings() async {
    try {
      return await _firebaseMessaging.getNotificationSettings();
    } catch (e) {
      debugPrint('Error getting notification settings: $e');
      rethrow;
    }
  }

  /// Check if notifications are enabled
  Future<bool> areNotificationsEnabled() async {
    try {
      final settings = await getNotificationSettings();
      return settings.authorizationStatus == AuthorizationStatus.authorized ||
          settings.authorizationStatus == AuthorizationStatus.provisional;
    } catch (e) {
      debugPrint('Error checking notification status: $e');
      return false;
    }
  }

  /// Set foreground notification presentation options (iOS)
  Future<void> setForegroundNotificationPresentationOptions({
    bool alert = true,
    bool badge = true,
    bool sound = true,
  }) async {
    try {
      await _firebaseMessaging.setForegroundNotificationPresentationOptions(
        alert: alert,
        badge: badge,
        sound: sound,
      );
      debugPrint('Foreground notification presentation options set');
    } catch (e) {
      debugPrint('Error setting foreground notification options: $e');
    }
  }

  /// Dispose resources
  void dispose() {
    _isInitialized = false;
    debugPrint('Firebase Notification Service disposed');
  }
}

/// Background message handler (must be top-level function)
/// This is called when the app is in the background or terminated
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  debugPrint('Background message received: ${message.messageId}');
  debugPrint('Title: ${message.notification?.title}');
  debugPrint('Body: ${message.notification?.body}');
  debugPrint('Data: ${message.data}');

  // Handle background message processing here if needed
  // Note: This runs in a separate isolate, so it has limited access to app state
}
