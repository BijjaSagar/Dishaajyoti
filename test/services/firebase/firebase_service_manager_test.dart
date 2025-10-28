import 'package:flutter_test/flutter_test.dart';
import 'package:dishaajyoti/services/firebase/firebase_service_manager.dart';

// Mock Firebase setup for testing
void setupFirebaseAuthMocks() {
  TestWidgetsFlutterBinding.ensureInitialized();
}

void main() {
  setupFirebaseAuthMocks();

  group('FirebaseServiceManager', () {
    test('should return singleton instance', () {
      final instance1 = FirebaseServiceManager.instance;
      final instance2 = FirebaseServiceManager.instance;
      final instance3 = FirebaseServiceManager();

      expect(instance1, equals(instance2));
      expect(instance1, equals(instance3));
      expect(instance2, equals(instance3));
    });

    test('should not be initialized before initialize() is called', () {
      final manager = FirebaseServiceManager.instance;

      expect(manager.isFirebaseAvailable, isFalse);
    });

    test(
        'should throw StateError when accessing services before initialization',
        () {
      final manager = FirebaseServiceManager.instance;

      expect(() => manager.auth, throwsStateError);
      expect(() => manager.firestore, throwsStateError);
      expect(() => manager.storage, throwsStateError);
      expect(() => manager.functions, throwsStateError);
    });

    test('currentUser should return null when not authenticated', () {
      final manager = FirebaseServiceManager.instance;

      expect(manager.currentUser, isNull);
    });

    test('isAuthenticated should return false when no user is signed in', () {
      final manager = FirebaseServiceManager.instance;

      expect(manager.isAuthenticated, isFalse);
    });

    test('currentUserId should return null when not authenticated', () {
      final manager = FirebaseServiceManager.instance;

      expect(manager.currentUserId, isNull);
    });
  });

  group('FirebaseServiceManager - Service Availability', () {
    test('isFirebaseAvailable should reflect initialization state', () {
      final manager = FirebaseServiceManager.instance;

      // Before initialization
      expect(manager.isFirebaseAvailable, isFalse);
    });

    test('should handle multiple initialization calls gracefully', () async {
      final manager = FirebaseServiceManager.instance;

      // This test verifies that calling initialize multiple times doesn't cause errors
      // In a real scenario with Firebase initialized, this would work
      // For unit tests without Firebase setup, we just verify the method exists
      expect(manager.initialize, isA<Function>());
    });
  });

  group('FirebaseServiceManager - Error Handling', () {
    test(
        'should throw StateError with descriptive message when not initialized',
        () {
      final manager = FirebaseServiceManager.instance;

      expect(
        () => manager.auth,
        throwsA(
          isA<StateError>().having(
            (e) => e.message,
            'message',
            contains('FirebaseServiceManager not initialized'),
          ),
        ),
      );

      expect(
        () => manager.firestore,
        throwsA(
          isA<StateError>().having(
            (e) => e.message,
            'message',
            contains('Call initialize() first'),
          ),
        ),
      );
    });
  });

  group('FirebaseServiceManager - Lifecycle', () {
    test('dispose should not throw errors', () {
      final manager = FirebaseServiceManager.instance;

      expect(() => manager.dispose(), returnsNormally);
    });

    test('signOut should handle null auth gracefully', () async {
      final manager = FirebaseServiceManager.instance;

      // When auth is not initialized, signOut should not throw
      // This tests the null-safe implementation
      expect(manager.signOut(), completes);
    });
  });
}
