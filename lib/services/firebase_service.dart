import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'dart:io';

/// Firebase Service - Central service for all Firebase operations
/// Handles Firestore, Storage, Functions, and Auth
class FirebaseService {
  static final FirebaseService instance = FirebaseService._init();

  FirebaseService._init();

  // Firebase instances
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final FirebaseFunctions _functions = FirebaseFunctions.instance;

  // Getters
  FirebaseFirestore get firestore => _firestore;
  FirebaseAuth get auth => _auth;
  FirebaseStorage get storage => _storage;
  FirebaseFunctions get functions => _functions;

  // Current user
  User? get currentUser => _auth.currentUser;
  String? get currentUserId => _auth.currentUser?.uid;

  /// Initialize Firebase with offline persistence
  Future<void> initialize() async {
    try {
      // Enable offline persistence for Firestore
      _firestore.settings = const Settings(
        persistenceEnabled: true,
        cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
      );

      print('Firebase Service initialized successfully');
    } catch (e) {
      print('Error initializing Firebase Service: $e');
    }
  }

  // ==================== AUTHENTICATION ====================

  /// Sign in with email and password
  Future<UserCredential> signInWithEmail(String email, String password) async {
    return await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  /// Sign up with email and password
  Future<UserCredential> signUpWithEmail(String email, String password) async {
    return await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  /// Sign out
  Future<void> signOut() async {
    await _auth.signOut();
  }

  /// Send password reset email
  Future<void> sendPasswordResetEmail(String email) async {
    await _auth.sendPasswordResetEmail(email: email);
  }

  // ==================== FIRESTORE OPERATIONS ====================

  /// Save document to Firestore
  Future<void> saveDocument({
    required String collection,
    required String docId,
    required Map<String, dynamic> data,
  }) async {
    await _firestore.collection(collection).doc(docId).set(
          data,
          SetOptions(merge: true),
        );
  }

  /// Get document from Firestore
  Future<DocumentSnapshot> getDocument({
    required String collection,
    required String docId,
  }) async {
    return await _firestore.collection(collection).doc(docId).get();
  }

  /// Get documents with query
  Future<QuerySnapshot> getDocuments({
    required String collection,
    Query Function(CollectionReference)? queryBuilder,
  }) async {
    CollectionReference ref = _firestore.collection(collection);

    if (queryBuilder != null) {
      return await queryBuilder(ref).get();
    }

    return await ref.get();
  }

  /// Stream documents (real-time updates)
  Stream<QuerySnapshot> streamDocuments({
    required String collection,
    Query Function(CollectionReference)? queryBuilder,
  }) {
    CollectionReference ref = _firestore.collection(collection);

    if (queryBuilder != null) {
      return queryBuilder(ref).snapshots();
    }

    return ref.snapshots();
  }

  /// Delete document
  Future<void> deleteDocument({
    required String collection,
    required String docId,
  }) async {
    await _firestore.collection(collection).doc(docId).delete();
  }

  /// Update document
  Future<void> updateDocument({
    required String collection,
    required String docId,
    required Map<String, dynamic> data,
  }) async {
    await _firestore.collection(collection).doc(docId).update(data);
  }

  // ==================== STORAGE OPERATIONS ====================

  /// Upload file to Firebase Storage
  Future<String> uploadFile({
    required File file,
    required String path,
    Function(double)? onProgress,
  }) async {
    final ref = _storage.ref().child(path);
    final uploadTask = ref.putFile(file);

    // Listen to progress
    if (onProgress != null) {
      uploadTask.snapshotEvents.listen((TaskSnapshot snapshot) {
        final progress = snapshot.bytesTransferred / snapshot.totalBytes;
        onProgress(progress);
      });
    }

    // Wait for upload to complete
    await uploadTask;

    // Get download URL
    return await ref.getDownloadURL();
  }

  /// Upload bytes to Firebase Storage
  Future<String> uploadBytes({
    required List<int> bytes,
    required String path,
    String? contentType,
  }) async {
    final ref = _storage.ref().child(path);
    final metadata = SettableMetadata(contentType: contentType);

    await ref.putData(bytes as Uint8List, metadata);

    return await ref.getDownloadURL();
  }

  /// Delete file from Storage
  Future<void> deleteFile(String path) async {
    await _storage.ref().child(path).delete();
  }

  /// Get download URL
  Future<String> getDownloadURL(String path) async {
    return await _storage.ref().child(path).getDownloadURL();
  }

  // ==================== CLOUD FUNCTIONS ====================

  /// Call Cloud Function
  Future<dynamic> callFunction({
    required String functionName,
    Map<String, dynamic>? parameters,
  }) async {
    try {
      final callable = _functions.httpsCallable(functionName);
      final result = await callable.call(parameters);
      return result.data;
    } catch (e) {
      print('Error calling function $functionName: $e');
      rethrow;
    }
  }

  // ==================== BATCH OPERATIONS ====================

  /// Batch write operations
  Future<void> batchWrite(
    List<Map<String, dynamic>> operations,
  ) async {
    final batch = _firestore.batch();

    for (var operation in operations) {
      final type = operation['type'] as String;
      final collection = operation['collection'] as String;
      final docId = operation['docId'] as String;
      final data = operation['data'] as Map<String, dynamic>?;

      final docRef = _firestore.collection(collection).doc(docId);

      switch (type) {
        case 'set':
          batch.set(docRef, data!);
          break;
        case 'update':
          batch.update(docRef, data!);
          break;
        case 'delete':
          batch.delete(docRef);
          break;
      }
    }

    await batch.commit();
  }
}
