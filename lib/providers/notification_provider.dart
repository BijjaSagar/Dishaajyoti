import 'package:flutter/widgets.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import '../models/notification_model.dart';
import '../services/notification_service.dart';
import '../services/firebase/firebase_notification_service.dart';

/// Notification state provider
///
/// Manages notification state and unread count
/// Requirements: 9.4, 6.2, 6.3
class NotificationProvider with ChangeNotifier {
  final NotificationService _notificationService = NotificationService();
  final FirebaseNotificationService _firebaseNotificationService =
      FirebaseNotificationService.instance;

  int _unreadCount = 0;
  List<NotificationModel> _notifications = [];
  bool _isLoading = false;
  String? _fcmToken;

  int get unreadCount => _unreadCount;
  List<NotificationModel> get notifications => _notifications;
  bool get isLoading => _isLoading;
  String? get fcmToken => _fcmToken;

  /// Initialize notification provider
  Future<void> initialize() async {
    // Initialize legacy notification service
    await _notificationService.initialize();
    await loadUnreadCount();
    await loadNotifications();

    // Set up Firebase notification callbacks
    _setupFirebaseNotificationHandlers();

    // Get FCM token
    _fcmToken = await _firebaseNotificationService.getToken();
    debugPrint('FCM Token in provider: $_fcmToken');

    // Check for initial message (app opened from terminated state)
    await _firebaseNotificationService.checkInitialMessage();

    // Set up legacy notification tap callback
    _notificationService.onNotificationTap = (notification) {
      // Handle notification tap
      loadUnreadCount();
      loadNotifications();
    };
  }

  /// Set up Firebase notification handlers
  void _setupFirebaseNotificationHandlers() {
    // Handle foreground messages
    _firebaseNotificationService.onForegroundMessage = (RemoteMessage message) {
      debugPrint('Foreground notification received in provider');

      // Convert to NotificationModel and save
      final notification = _convertRemoteMessageToNotificationModel(message);
      _saveNotificationLocally(notification);

      // Increment unread count
      _unreadCount++;
      notifyListeners();
    };

    // Handle notification taps
    _firebaseNotificationService.onMessageTap = (RemoteMessage message) {
      debugPrint('Notification tapped in provider');

      // Reload notifications and update unread count
      loadUnreadCount();
      loadNotifications();
    };

    // Handle token refresh
    _firebaseNotificationService.onTokenRefresh = (String newToken) {
      debugPrint('FCM Token refreshed in provider: $newToken');
      _fcmToken = newToken;
      notifyListeners();
    };
  }

  /// Convert RemoteMessage to NotificationModel
  NotificationModel _convertRemoteMessageToNotificationModel(
    RemoteMessage message,
  ) {
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
      switch (typeStr) {
        case 'kundali_ready':
        case 'palmistry_ready':
        case 'numerology_ready':
        case 'report_ready':
          return NotificationType.reportReady;
        case 'payment_confirmed':
          return NotificationType.paymentConfirmed;
        case 'report_scheduled':
          return NotificationType.reportScheduled;
        case 'report_failed':
          return NotificationType.reportFailed;
        default:
          return NotificationType.general;
      }
    }
    return NotificationType.general;
  }

  /// Save notification locally
  Future<void> _saveNotificationLocally(NotificationModel notification) async {
    try {
      // Add to local list
      _notifications.insert(0, notification);

      // Keep only last 100 notifications
      if (_notifications.length > 100) {
        _notifications = _notifications.sublist(0, 100);
      }

      notifyListeners();
    } catch (e) {
      debugPrint('Error saving notification locally: $e');
    }
  }

  /// Load unread count
  Future<void> loadUnreadCount() async {
    try {
      final count = await _notificationService.getUnreadCount();
      _unreadCount = count;
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading unread count: $e');
    }
  }

  /// Load notifications
  Future<void> loadNotifications() async {
    _isLoading = true;
    notifyListeners();

    try {
      final notifications = await _notificationService.getNotifications();
      _notifications = notifications;
    } catch (e) {
      debugPrint('Error loading notifications: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Mark all notifications as read
  Future<void> markAllAsRead() async {
    await _notificationService.markAllAsRead();
    await loadUnreadCount();
    await loadNotifications();
  }

  /// Clear all notifications
  Future<void> clearAllNotifications() async {
    await _notificationService.clearAllNotifications();
    await loadUnreadCount();
    await loadNotifications();
  }

  /// Get FCM token
  Future<String?> getToken() async {
    return await _notificationService.getToken();
  }

  /// Delete FCM token
  Future<void> deleteToken() async {
    await _notificationService.deleteToken();
  }
}
