import 'package:flutter/widgets.dart';
import '../models/notification_model.dart';
import '../services/notification_service.dart';

/// Notification state provider
///
/// Manages notification state and unread count
/// Requirements: 9.4
class NotificationProvider with ChangeNotifier {
  final NotificationService _notificationService = NotificationService();

  int _unreadCount = 0;
  List<NotificationModel> _notifications = [];
  bool _isLoading = false;

  int get unreadCount => _unreadCount;
  List<NotificationModel> get notifications => _notifications;
  bool get isLoading => _isLoading;

  /// Initialize notification provider
  Future<void> initialize() async {
    await _notificationService.initialize();
    await loadUnreadCount();
    await loadNotifications();

    // Set up notification tap callback
    _notificationService.onNotificationTap = (notification) {
      // Handle notification tap
      loadUnreadCount();
      loadNotifications();
    };
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
