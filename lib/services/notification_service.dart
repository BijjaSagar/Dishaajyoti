import 'dart:convert';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/notification_model.dart';

/// Firebase Cloud Messaging service for handling push notifications
///
/// Requirements: 9.4
class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final String _notificationsKey = 'notifications_history';
  final String _unreadCountKey = 'unread_notifications_count';

  // Callback for handling notification taps
  Function(NotificationModel)? onNotificationTap;

  /// Initialize Firebase Cloud Messaging
  ///
  /// Requirements: 9.4
  Future<void> initialize() async {
    try {
      // Request permission for iOS
      NotificationSettings settings =
          await _firebaseMessaging.requestPermission(
        alert: true,
        announcement: false,
        badge: true,
        carPlay: false,
        criticalAlert: false,
        provisional: false,
        sound: true,
      );

      if (settings.authorizationStatus == AuthorizationStatus.authorized) {
        debugPrint('User granted notification permission');
      } else if (settings.authorizationStatus ==
          AuthorizationStatus.provisional) {
        debugPrint('User granted provisional notification permission');
      } else {
        debugPrint('User declined or has not accepted notification permission');
      }

      // Get FCM token
      String? token = await _firebaseMessaging.getToken();
      debugPrint('FCM Token: $token');

      // Listen to token refresh
      _firebaseMessaging.onTokenRefresh.listen((newToken) {
        debugPrint('FCM Token refreshed: $newToken');
        // TODO: Send token to backend
      });

      // Handle foreground messages
      FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

      // Handle background message taps
      FirebaseMessaging.onMessageOpenedApp.listen(_handleBackgroundMessageTap);

      // Check if app was opened from a terminated state via notification
      RemoteMessage? initialMessage =
          await _firebaseMessaging.getInitialMessage();
      if (initialMessage != null) {
        _handleBackgroundMessageTap(initialMessage);
      }
    } catch (e) {
      debugPrint('Error initializing notifications: $e');
    }
  }

  /// Handle foreground messages
  void _handleForegroundMessage(RemoteMessage message) {
    debugPrint('Foreground message received: ${message.messageId}');

    final notification = _convertToNotificationModel(message);
    _saveNotificationToHistory(notification);
    _incrementUnreadCount();
  }

  /// Handle background message tap
  void _handleBackgroundMessageTap(RemoteMessage message) {
    debugPrint('Background message tapped: ${message.messageId}');

    final notification = _convertToNotificationModel(message);

    // Mark as read when tapped
    _markNotificationAsRead(notification.id);

    // Trigger callback if set
    if (onNotificationTap != null) {
      onNotificationTap!(notification);
    }
  }

  /// Convert RemoteMessage to NotificationModel
  NotificationModel _convertToNotificationModel(RemoteMessage message) {
    return NotificationModel(
      id: message.messageId ?? DateTime.now().millisecondsSinceEpoch.toString(),
      title: message.notification?.title ?? 'Notification',
      body: message.notification?.body ?? '',
      imageUrl: message.notification?.android?.imageUrl ??
          message.notification?.apple?.imageUrl,
      data: message.data,
      createdAt: DateTime.now(),
      isRead: false,
      type: _getNotificationType(message.data),
    );
  }

  /// Get notification type from data
  NotificationType _getNotificationType(Map<String, dynamic> data) {
    if (data.containsKey('type')) {
      final typeStr = data['type'] as String;
      return NotificationType.values.firstWhere(
        (e) => e.toString() == 'NotificationType.$typeStr',
        orElse: () => NotificationType.general,
      );
    }
    return NotificationType.general;
  }

  /// Save notification to local history
  Future<void> _saveNotificationToHistory(
      NotificationModel notification) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final notificationsJson = prefs.getString(_notificationsKey);

      List<NotificationModel> notifications = [];
      if (notificationsJson != null) {
        final List<dynamic> decoded = jsonDecode(notificationsJson);
        notifications =
            decoded.map((json) => NotificationModel.fromJson(json)).toList();
      }

      // Add new notification at the beginning
      notifications.insert(0, notification);

      // Keep only last 100 notifications
      if (notifications.length > 100) {
        notifications = notifications.sublist(0, 100);
      }

      // Save back to preferences
      final encoded = jsonEncode(
        notifications.map((n) => n.toJson()).toList(),
      );
      await prefs.setString(_notificationsKey, encoded);
    } catch (e) {
      debugPrint('Error saving notification to history: $e');
    }
  }

  /// Get all notifications from history
  Future<List<NotificationModel>> getNotifications() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final notificationsJson = prefs.getString(_notificationsKey);

      if (notificationsJson != null) {
        final List<dynamic> decoded = jsonDecode(notificationsJson);
        return decoded.map((json) => NotificationModel.fromJson(json)).toList();
      }
    } catch (e) {
      debugPrint('Error getting notifications: $e');
    }
    return [];
  }

  /// Mark notification as read
  Future<void> _markNotificationAsRead(String notificationId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final notificationsJson = prefs.getString(_notificationsKey);

      if (notificationsJson != null) {
        final List<dynamic> decoded = jsonDecode(notificationsJson);
        List<NotificationModel> notifications =
            decoded.map((json) => NotificationModel.fromJson(json)).toList();

        // Find and mark as read
        final index = notifications.indexWhere((n) => n.id == notificationId);
        if (index != -1 && !notifications[index].isRead) {
          notifications[index] = notifications[index].copyWith(isRead: true);

          // Save back
          final encoded = jsonEncode(
            notifications.map((n) => n.toJson()).toList(),
          );
          await prefs.setString(_notificationsKey, encoded);

          // Decrement unread count
          _decrementUnreadCount();
        }
      }
    } catch (e) {
      debugPrint('Error marking notification as read: $e');
    }
  }

  /// Mark all notifications as read
  Future<void> markAllAsRead() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final notificationsJson = prefs.getString(_notificationsKey);

      if (notificationsJson != null) {
        final List<dynamic> decoded = jsonDecode(notificationsJson);
        List<NotificationModel> notifications =
            decoded.map((json) => NotificationModel.fromJson(json)).toList();

        // Mark all as read
        notifications =
            notifications.map((n) => n.copyWith(isRead: true)).toList();

        // Save back
        final encoded = jsonEncode(
          notifications.map((n) => n.toJson()).toList(),
        );
        await prefs.setString(_notificationsKey, encoded);

        // Reset unread count
        await prefs.setInt(_unreadCountKey, 0);
      }
    } catch (e) {
      debugPrint('Error marking all notifications as read: $e');
    }
  }

  /// Get unread notifications count
  Future<int> getUnreadCount() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getInt(_unreadCountKey) ?? 0;
    } catch (e) {
      debugPrint('Error getting unread count: $e');
      return 0;
    }
  }

  /// Increment unread count
  Future<void> _incrementUnreadCount() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final currentCount = prefs.getInt(_unreadCountKey) ?? 0;
      await prefs.setInt(_unreadCountKey, currentCount + 1);
    } catch (e) {
      debugPrint('Error incrementing unread count: $e');
    }
  }

  /// Decrement unread count
  Future<void> _decrementUnreadCount() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final currentCount = prefs.getInt(_unreadCountKey) ?? 0;
      if (currentCount > 0) {
        await prefs.setInt(_unreadCountKey, currentCount - 1);
      }
    } catch (e) {
      debugPrint('Error decrementing unread count: $e');
    }
  }

  /// Get FCM token
  Future<String?> getToken() async {
    try {
      return await _firebaseMessaging.getToken();
    } catch (e) {
      debugPrint('Error getting FCM token: $e');
      return null;
    }
  }

  /// Delete FCM token
  Future<void> deleteToken() async {
    try {
      await _firebaseMessaging.deleteToken();
    } catch (e) {
      debugPrint('Error deleting FCM token: $e');
    }
  }

  /// Clear all notifications
  Future<void> clearAllNotifications() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_notificationsKey);
      await prefs.setInt(_unreadCountKey, 0);
    } catch (e) {
      debugPrint('Error clearing notifications: $e');
    }
  }
}

/// Background message handler (must be top-level function)
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  debugPrint('Background message received: ${message.messageId}');
  // Handle background message here if needed
}
