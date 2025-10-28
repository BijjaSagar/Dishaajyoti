import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/foundation.dart';

/// Central service manager for all Firebase operations
/// Implements singleton pattern for consistent Firebase service access
class FirebaseServiceManager {
  // Singleton instance
  static final FirebaseServiceManager _instance =
      FirebaseServiceManager._internal();

  factory FirebaseServiceManager() => _instance;

  FirebaseServiceManager._internal();

  // Convenience getter for singleton instance
  static FirebaseServiceManager get instance => _instance;

  // Firebase service instances
  FirebaseAuth? _auth;
  FirebaseFirestore? _firestore;
  FirebaseStorage? _storage;
  FirebaseFunctions? _functions;

  // Initialization state
  bool _isInitialized = false;

  /// Initialize all Firebase services
  /// Should be called once during app startup
  Future<void> initialize() async {
    if (_isInitialized) {
      debugPrint('Firebase already initialized');
      return;
    }

    try {
      // Initialize Firebase Core
      await Firebase.initializeApp();

      // Initialize service instances
      _auth = FirebaseAuth.instance;
      _firestore = FirebaseFirestore.instance;
      _storage = FirebaseStorage.instance;
      _functions = FirebaseFunctions.instance;

      // Configure Firestore settings
      _firestore!.settings = const Settings(
        persistenceEnabled: true,
        cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
      );

      // Use emulators in debug mode (optional)
      if (kDebugMode) {
        // Uncomment to use local emulators during development
        // _auth!.useAuthEmulator('localhost', 9099);
        // _firestore!.useFirestoreEmulator('localhost', 8080);
        // _storage!.useStorageEmulator('localhost', 9199);
        // _functions!.useFunctionsEmulator('localhost', 5001);
      }

      _isInitialized = true;
      debugPrint('Firebase initialized successfully');
    } catch (e) {
      debugPrint('Error initializing Firebase: $e');
      rethrow;
    }
  }

  /// Check if Firebase is initialized and available
  bool get isFirebaseAvailable => _isInitialized;

  /// Get Firebase Authentication instance
  FirebaseAuth get auth {
    _checkInitialization();
    return _auth!;
  }

  /// Get Firestore Database instance
  FirebaseFirestore get firestore {
    _checkInitialization();
    return _firestore!;
  }

  /// Get Firebase Storage instance
  FirebaseStorage get storage {
    _checkInitialization();
    return _storage!;
  }

  /// Get Cloud Functions instance
  FirebaseFunctions get functions {
    _checkInitialization();
    return _functions!;
  }

  /// Get current authenticated user
  User? get currentUser => _auth?.currentUser;

  /// Check if user is authenticated
  bool get isAuthenticated => currentUser != null;

  /// Get current user ID
  String? get currentUserId => currentUser?.uid;

  /// Check if Firebase services are initialized
  void _checkInitialization() {
    if (!_isInitialized) {
      throw StateError(
        'FirebaseServiceManager not initialized. Call initialize() first.',
      );
    }
  }

  /// Sign out and clear local cache
  Future<void> signOut() async {
    try {
      await _auth?.signOut();
      debugPrint('User signed out successfully');
    } catch (e) {
      debugPrint('Error signing out: $e');
      rethrow;
    }
  }

  /// Dispose resources (if needed)
  void dispose() {
    // Clean up resources if necessary
    debugPrint('FirebaseServiceManager disposed');
  }
}
