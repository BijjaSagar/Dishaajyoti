import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/kundali_with_chart_model.dart';
import 'firebase_service.dart';
import 'dart:io';

/// Firebase Kundali Service
/// Handles all Kundali operations with Firebase
class FirebaseKundaliService {
  static final FirebaseKundaliService instance = FirebaseKundaliService._init();

  FirebaseKundaliService._init();

  final _firebase = FirebaseService.instance;
  static const String _collection = 'kundalis';

  /// Save Kundali to Firestore
  Future<void> saveKundali(KundaliWithChart kundali) async {
    try {
      final userId = _firebase.currentUserId;
      if (userId == null) throw Exception('User not authenticated');

      await _firebase.saveDocument(
        collection: _collection,
        docId: kundali.id,
        data: {
          ...kundali.toJson(),
          'userId': userId,
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        },
      );

      print('Kundali saved to Firebase: ${kundali.id}');
    } catch (e) {
      print('Error saving Kundali to Firebase: $e');
      rethrow;
    }
  }

  /// Get all Kundalis for current user
  Future<List<KundaliWithChart>> getKundalis() async {
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
          .map((doc) => KundaliWithChart.fromJson(
                doc.data() as Map<String, dynamic>,
              ))
          .toList();
    } catch (e) {
      print('Error getting Kundalis from Firebase: $e');
      return [];
    }
  }

  /// Stream Kundalis (real-time updates)
  Stream<List<KundaliWithChart>> streamKundalis() {
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
            .map((doc) => KundaliWithChart.fromJson(
                  doc.data() as Map<String, dynamic>,
                ))
            .toList());
  }

  /// Get single Kundali
  Future<KundaliWithChart?> getKundali(String kundaliId) async {
    try {
      final doc = await _firebase.getDocument(
        collection: _collection,
        docId: kundaliId,
      );

      if (!doc.exists) return null;

      return KundaliWithChart.fromJson(doc.data() as Map<String, dynamic>);
    } catch (e) {
      print('Error getting Kundali from Firebase: $e');
      return null;
    }
  }

  /// Delete Kundali
  Future<void> deleteKundali(String kundaliId) async {
    try {
      await _firebase.deleteDocument(
        collection: _collection,
        docId: kundaliId,
      );

      print('Kundali deleted from Firebase: $kundaliId');
    } catch (e) {
      print('Error deleting Kundali from Firebase: $e');
      rethrow;
    }
  }

  /// Upload Kundali PDF to Storage
  Future<String> uploadKundaliPDF({
    required String kundaliId,
    required File pdfFile,
  }) async {
    try {
      final userId = _firebase.currentUserId;
      if (userId == null) throw Exception('User not authenticated');

      final path = 'kundalis/$userId/$kundaliId/kundali.pdf';

      final downloadUrl = await _firebase.uploadFile(
        file: pdfFile,
        path: path,
      );

      // Update Kundali document with PDF URL
      await _firebase.updateDocument(
        collection: _collection,
        docId: kundaliId,
        data: {'pdfPath': downloadUrl},
      );

      return downloadUrl;
    } catch (e) {
      print('Error uploading Kundali PDF: $e');
      rethrow;
    }
  }

  /// Generate Kundali using Cloud Function
  Future<Map<String, dynamic>> generateKundaliWithAI({
    required Map<String, dynamic> birthDetails,
  }) async {
    try {
      final result = await _firebase.callFunction(
        functionName: 'generateKundali',
        parameters: birthDetails,
      );

      return result as Map<String, dynamic>;
    } catch (e) {
      print('Error generating Kundali with AI: $e');
      rethrow;
    }
  }
}
