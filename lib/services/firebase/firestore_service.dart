import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../../models/firebase/user_profile_model.dart';
import '../../models/firebase/service_report_model.dart';
import '../../models/firebase/order_model.dart';
import 'firebase_service_manager.dart';

/// Service for handling all Firestore database operations
class FirestoreService {
  // Singleton instance
  static final FirestoreService _instance = FirestoreService._internal();

  factory FirestoreService() => _instance;

  FirestoreService._internal();

  // Convenience getter for singleton instance
  static FirestoreService get instance => _instance;

  // Get Firestore instance from service manager
  FirebaseFirestore get _firestore => FirebaseServiceManager.instance.firestore;

  // Collection references
  CollectionReference get _usersCollection => _firestore.collection('users');
  CollectionReference get _reportsCollection =>
      _firestore.collection('reports');
  CollectionReference get _ordersCollection => _firestore.collection('orders');

  // ==================== User Profile Operations ====================

  /// Create a new user profile in Firestore
  Future<void> createUserProfile(UserProfile profile) async {
    try {
      await _usersCollection.doc(profile.id).set(profile.toFirestore());
      debugPrint('User profile created: ${profile.id}');
    } catch (e) {
      debugPrint('Error creating user profile: $e');
      rethrow;
    }
  }

  /// Get user profile by user ID
  Future<UserProfile?> getUserProfile(String userId) async {
    try {
      final doc = await _usersCollection.doc(userId).get();
      if (!doc.exists) {
        debugPrint('User profile not found: $userId');
        return null;
      }
      return UserProfile.fromFirestore(doc);
    } catch (e) {
      debugPrint('Error getting user profile: $e');
      rethrow;
    }
  }

  /// Update user profile
  Future<void> updateUserProfile(
    String userId,
    Map<String, dynamic> updates,
  ) async {
    try {
      // Add updatedAt timestamp
      updates['updatedAt'] = Timestamp.now();

      await _usersCollection.doc(userId).update(updates);
      debugPrint('User profile updated: $userId');
    } catch (e) {
      debugPrint('Error updating user profile: $e');
      rethrow;
    }
  }

  /// Update user FCM token
  Future<void> updateFCMToken(String userId, String fcmToken) async {
    try {
      await updateUserProfile(userId, {'fcmToken': fcmToken});
      debugPrint('FCM token updated for user: $userId');
    } catch (e) {
      debugPrint('Error updating FCM token: $e');
      rethrow;
    }
  }

  /// Update user preferences
  Future<void> updateUserPreferences(
    String userId,
    UserPreferences preferences,
  ) async {
    try {
      await updateUserProfile(userId, {'preferences': preferences.toMap()});
      debugPrint('User preferences updated: $userId');
    } catch (e) {
      debugPrint('Error updating user preferences: $e');
      rethrow;
    }
  }

  // ==================== Service Report Operations ====================

  /// Create a new service report
  Future<String> createServiceReport(ServiceReport report) async {
    try {
      final docRef = await _reportsCollection.add(report.toFirestore());
      debugPrint('Service report created: ${docRef.id}');
      return docRef.id;
    } catch (e) {
      debugPrint('Error creating service report: $e');
      rethrow;
    }
  }

  /// Get service report by ID
  Future<ServiceReport?> getServiceReport(String reportId) async {
    try {
      final doc = await _reportsCollection.doc(reportId).get();
      if (!doc.exists) {
        debugPrint('Service report not found: $reportId');
        return null;
      }
      return ServiceReport.fromFirestore(doc);
    } catch (e) {
      debugPrint('Error getting service report: $e');
      rethrow;
    }
  }

  /// Get all reports for a user with pagination
  Future<List<ServiceReport>> getUserReports(
    String userId, {
    int limit = 20,
    DocumentSnapshot? startAfter,
  }) async {
    try {
      Query query = _reportsCollection
          .where('userId', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .limit(limit);

      if (startAfter != null) {
        query = query.startAfterDocument(startAfter);
      }

      final snapshot = await query.get();
      return snapshot.docs
          .map((doc) => ServiceReport.fromFirestore(doc))
          .toList();
    } catch (e) {
      debugPrint('Error getting user reports: $e');
      rethrow;
    }
  }

  /// Get reports by status for a user
  Future<List<ServiceReport>> getUserReportsByStatus(
    String userId,
    ServiceReportStatus status, {
    int limit = 20,
  }) async {
    try {
      final snapshot = await _reportsCollection
          .where('userId', isEqualTo: userId)
          .where('status', isEqualTo: status.toString())
          .orderBy('createdAt', descending: true)
          .limit(limit)
          .get();

      return snapshot.docs
          .map((doc) => ServiceReport.fromFirestore(doc))
          .toList();
    } catch (e) {
      debugPrint('Error getting user reports by status: $e');
      rethrow;
    }
  }

  /// Update report status
  Future<void> updateReportStatus(
    String reportId,
    ServiceReportStatus status,
  ) async {
    try {
      final updates = <String, dynamic>{
        'status': status.toString(),
      };

      // Add completedAt timestamp if status is completed
      if (status == ServiceReportStatus.completed) {
        updates['completedAt'] = Timestamp.now();
      }

      await _reportsCollection.doc(reportId).update(updates);
      debugPrint('Report status updated: $reportId -> $status');
    } catch (e) {
      debugPrint('Error updating report status: $e');
      rethrow;
    }
  }

  /// Update report with files
  Future<void> updateReportFiles(
    String reportId,
    ReportFiles files,
  ) async {
    try {
      await _reportsCollection.doc(reportId).update({
        'files': files.toMap(),
      });
      debugPrint('Report files updated: $reportId');
    } catch (e) {
      debugPrint('Error updating report files: $e');
      rethrow;
    }
  }

  /// Update report data
  Future<void> updateReportData(
    String reportId,
    Map<String, dynamic> data,
  ) async {
    try {
      await _reportsCollection.doc(reportId).update({
        'data': data,
      });
      debugPrint('Report data updated: $reportId');
    } catch (e) {
      debugPrint('Error updating report data: $e');
      rethrow;
    }
  }

  /// Delete a report
  Future<void> deleteReport(String reportId) async {
    try {
      await _reportsCollection.doc(reportId).delete();
      debugPrint('Report deleted: $reportId');
    } catch (e) {
      debugPrint('Error deleting report: $e');
      rethrow;
    }
  }

  // ==================== Order Operations ====================

  /// Create a new order
  Future<String> createOrder(FirebaseOrder order) async {
    try {
      final docRef = await _ordersCollection.add(order.toFirestore());
      debugPrint('Order created: ${docRef.id}');
      return docRef.id;
    } catch (e) {
      debugPrint('Error creating order: $e');
      rethrow;
    }
  }

  /// Get order by ID
  Future<FirebaseOrder?> getOrder(String orderId) async {
    try {
      final doc = await _ordersCollection.doc(orderId).get();
      if (!doc.exists) {
        debugPrint('Order not found: $orderId');
        return null;
      }
      return FirebaseOrder.fromFirestore(doc);
    } catch (e) {
      debugPrint('Error getting order: $e');
      rethrow;
    }
  }

  /// Get all orders for a user
  Future<List<FirebaseOrder>> getUserOrders(
    String userId, {
    int limit = 20,
    DocumentSnapshot? startAfter,
  }) async {
    try {
      Query query = _ordersCollection
          .where('userId', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .limit(limit);

      if (startAfter != null) {
        query = query.startAfterDocument(startAfter);
      }

      final snapshot = await query.get();
      return snapshot.docs
          .map((doc) => FirebaseOrder.fromFirestore(doc))
          .toList();
    } catch (e) {
      debugPrint('Error getting user orders: $e');
      rethrow;
    }
  }

  /// Update order status
  Future<void> updateOrderStatus(
    String orderId,
    FirebaseOrderStatus status,
  ) async {
    try {
      final updates = <String, dynamic>{
        'status': status.toString(),
      };

      // Add paidAt timestamp if status is paid
      if (status == FirebaseOrderStatus.paid) {
        updates['paidAt'] = Timestamp.now();
      }

      await _ordersCollection.doc(orderId).update(updates);
      debugPrint('Order status updated: $orderId -> $status');
    } catch (e) {
      debugPrint('Error updating order status: $e');
      rethrow;
    }
  }

  /// Update order with payment information
  Future<void> updateOrderPayment(
    String orderId, {
    required String paymentId,
    required String paymentMethod,
  }) async {
    try {
      await _ordersCollection.doc(orderId).update({
        'paymentId': paymentId,
        'paymentMethod': paymentMethod,
        'status': FirebaseOrderStatus.paid.toString(),
        'paidAt': Timestamp.now(),
      });
      debugPrint('Order payment updated: $orderId');
    } catch (e) {
      debugPrint('Error updating order payment: $e');
      rethrow;
    }
  }

  /// Link order to report
  Future<void> linkOrderToReport(String orderId, String reportId) async {
    try {
      await _ordersCollection.doc(orderId).update({
        'reportId': reportId,
      });
      debugPrint('Order linked to report: $orderId -> $reportId');
    } catch (e) {
      debugPrint('Error linking order to report: $e');
      rethrow;
    }
  }

  // ==================== Batch Operations ====================

  /// Batch write multiple operations
  Future<void> batchWrite(
    List<void Function(WriteBatch batch)> operations,
  ) async {
    try {
      final batch = _firestore.batch();
      for (final operation in operations) {
        operation(batch);
      }
      await batch.commit();
      debugPrint('Batch write completed: ${operations.length} operations');
    } catch (e) {
      debugPrint('Error in batch write: $e');
      rethrow;
    }
  }

  // ==================== Real-time Listeners ====================

  /// Watch a specific report for real-time updates
  Stream<ServiceReport?> watchReport(String reportId) {
    try {
      return _reportsCollection.doc(reportId).snapshots().map((snapshot) {
        if (!snapshot.exists) {
          debugPrint('Report not found in stream: $reportId');
          return null;
        }
        return ServiceReport.fromFirestore(snapshot);
      });
    } catch (e) {
      debugPrint('Error watching report: $e');
      rethrow;
    }
  }

  /// Watch all reports for a user with real-time updates
  Stream<List<ServiceReport>> watchUserReports(
    String userId, {
    int limit = 20,
  }) {
    try {
      return _reportsCollection
          .where('userId', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .limit(limit)
          .snapshots()
          .map((snapshot) {
        return snapshot.docs
            .map((doc) => ServiceReport.fromFirestore(doc))
            .toList();
      });
    } catch (e) {
      debugPrint('Error watching user reports: $e');
      rethrow;
    }
  }

  /// Watch reports by status for a user with real-time updates
  Stream<List<ServiceReport>> watchUserReportsByStatus(
    String userId,
    ServiceReportStatus status, {
    int limit = 20,
  }) {
    try {
      return _reportsCollection
          .where('userId', isEqualTo: userId)
          .where('status', isEqualTo: status.toString())
          .orderBy('createdAt', descending: true)
          .limit(limit)
          .snapshots()
          .map((snapshot) {
        return snapshot.docs
            .map((doc) => ServiceReport.fromFirestore(doc))
            .toList();
      });
    } catch (e) {
      debugPrint('Error watching user reports by status: $e');
      rethrow;
    }
  }

  /// Watch user profile for real-time updates
  Stream<UserProfile?> watchUserProfile(String userId) {
    try {
      return _usersCollection.doc(userId).snapshots().map((snapshot) {
        if (!snapshot.exists) {
          debugPrint('User profile not found in stream: $userId');
          return null;
        }
        return UserProfile.fromFirestore(snapshot);
      });
    } catch (e) {
      debugPrint('Error watching user profile: $e');
      rethrow;
    }
  }

  /// Watch orders for a user with real-time updates
  Stream<List<FirebaseOrder>> watchUserOrders(
    String userId, {
    int limit = 20,
  }) {
    try {
      return _ordersCollection
          .where('userId', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .limit(limit)
          .snapshots()
          .map((snapshot) {
        return snapshot.docs
            .map((doc) => FirebaseOrder.fromFirestore(doc))
            .toList();
      });
    } catch (e) {
      debugPrint('Error watching user orders: $e');
      rethrow;
    }
  }

  /// Watch a specific order for real-time updates
  Stream<FirebaseOrder?> watchOrder(String orderId) {
    try {
      return _ordersCollection.doc(orderId).snapshots().map((snapshot) {
        if (!snapshot.exists) {
          debugPrint('Order not found in stream: $orderId');
          return null;
        }
        return FirebaseOrder.fromFirestore(snapshot);
      });
    } catch (e) {
      debugPrint('Error watching order: $e');
      rethrow;
    }
  }

  // ==================== Query Helpers ====================

  /// Get last document for pagination
  Future<DocumentSnapshot?> getLastDocument(
    String userId,
    int limit,
  ) async {
    try {
      final snapshot = await _reportsCollection
          .where('userId', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .limit(limit)
          .get();

      if (snapshot.docs.isEmpty) return null;
      return snapshot.docs.last;
    } catch (e) {
      debugPrint('Error getting last document: $e');
      return null;
    }
  }

  /// Count user reports
  Future<int> countUserReports(String userId) async {
    try {
      final snapshot = await _reportsCollection
          .where('userId', isEqualTo: userId)
          .count()
          .get();
      return snapshot.count ?? 0;
    } catch (e) {
      debugPrint('Error counting user reports: $e');
      return 0;
    }
  }
}
