import 'package:cloud_firestore/cloud_firestore.dart';
import 'firebase_service.dart';
import 'dart:io';

/// Firebase Report Service
/// Handles all service reports (Palmistry, Numerology, Compatibility, etc.)
class FirebaseReportService {
  static final FirebaseReportService instance = FirebaseReportService._init();

  FirebaseReportService._init();

  final _firebase = FirebaseService.instance;
  static const String _collection = 'reports';

  /// Create a new report request
  Future<String> createReportRequest({
    required String serviceId,
    required String serviceName,
    required Map<String, dynamic> inputData,
    File? imageFile,
  }) async {
    try {
      final userId = _firebase.currentUserId;
      if (userId == null) throw Exception('User not authenticated');

      // Generate report ID
      final reportId = 'REPORT_${DateTime.now().millisecondsSinceEpoch}';

      // Upload image if provided (for palmistry)
      String? imageUrl;
      if (imageFile != null) {
        final imagePath = 'reports/$userId/$reportId/input_image.jpg';
        imageUrl = await _firebase.uploadFile(
          file: imageFile,
          path: imagePath,
        );
      }

      // Create report document
      final reportData = {
        'reportId': reportId,
        'userId': userId,
        'serviceId': serviceId,
        'serviceName': serviceName,
        'inputData': inputData,
        'imageUrl': imageUrl,
        'status': 'pending', // pending, processing, completed, failed
        'progress': 0,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
        'expiresAt': null, // Set when completed
        'pdfUrl': null,
        'result': null,
      };

      await _firebase.saveDocument(
        collection: _collection,
        docId: reportId,
        data: reportData,
      );

      // Trigger Cloud Function to process report
      await _triggerReportProcessing(reportId, serviceId, inputData, imageUrl);

      return reportId;
    } catch (e) {
      print('Error creating report request: $e');
      rethrow;
    }
  }

  /// Trigger Cloud Function to process report
  Future<void> _triggerReportProcessing(
    String reportId,
    String serviceId,
    Map<String, dynamic> inputData,
    String? imageUrl,
  ) async {
    try {
      await _firebase.callFunction(
        functionName: 'processReport',
        parameters: {
          'reportId': reportId,
          'serviceId': serviceId,
          'inputData': inputData,
          'imageUrl': imageUrl,
        },
      );
    } catch (e) {
      print('Error triggering report processing: $e');
      // Don't rethrow - report is created, processing will be retried
    }
  }

  /// Get all reports for current user
  Future<List<Map<String, dynamic>>> getReports() async {
    try {
      final userId = _firebase.currentUserId;
      if (userId == null) return [];

      final snapshot = await _firebase.getDocuments(
        collection: _collection,
        queryBuilder: (ref) => ref
            .where('userId', isEqualTo: userId)
            .orderBy('createdAt', descending: true),
      );

      return snapshot.docs
          .map((doc) => doc.data() as Map<String, dynamic>)
          .toList();
    } catch (e) {
      print('Error getting reports: $e');
      return [];
    }
  }

  /// Stream reports (real-time updates)
  Stream<List<Map<String, dynamic>>> streamReports() {
    final userId = _firebase.currentUserId;
    if (userId == null) return Stream.value([]);

    return _firebase
        .streamDocuments(
          collection: _collection,
          queryBuilder: (ref) => ref
              .where('userId', isEqualTo: userId)
              .orderBy('createdAt', descending: true),
        )
        .map((snapshot) => snapshot.docs
            .map((doc) => doc.data() as Map<String, dynamic>)
            .toList());
  }

  /// Get single report
  Future<Map<String, dynamic>?> getReport(String reportId) async {
    try {
      final doc = await _firebase.getDocument(
        collection: _collection,
        docId: reportId,
      );

      if (!doc.exists) return null;

      return doc.data() as Map<String, dynamic>;
    } catch (e) {
      print('Error getting report: $e');
      return null;
    }
  }

  /// Stream single report (for real-time status updates)
  Stream<Map<String, dynamic>?> streamReport(String reportId) {
    return _firebase.firestore
        .collection(_collection)
        .doc(reportId)
        .snapshots()
        .map((doc) {
      if (!doc.exists) return null;
      return doc.data() as Map<String, dynamic>;
    });
  }

  /// Delete report
  Future<void> deleteReport(String reportId) async {
    try {
      await _firebase.deleteDocument(
        collection: _collection,
        docId: reportId,
      );

      print('Report deleted: $reportId');
    } catch (e) {
      print('Error deleting report: $e');
      rethrow;
    }
  }

  /// Check if report has expired
  bool isReportExpired(Map<String, dynamic> report) {
    final expiresAt = report['expiresAt'] as Timestamp?;
    if (expiresAt == null) return false;

    return DateTime.now().isAfter(expiresAt.toDate());
  }

  /// Get report expiry date
  DateTime? getReportExpiryDate(Map<String, dynamic> report) {
    final expiresAt = report['expiresAt'] as Timestamp?;
    return expiresAt?.toDate();
  }

  /// Get days until expiry
  int? getDaysUntilExpiry(Map<String, dynamic> report) {
    final expiryDate = getReportExpiryDate(report);
    if (expiryDate == null) return null;

    final difference = expiryDate.difference(DateTime.now());
    return difference.inDays;
  }
}
