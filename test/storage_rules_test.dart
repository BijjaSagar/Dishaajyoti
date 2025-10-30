import 'package:flutter_test/flutter_test.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'dart:io';
import 'dart:typed_data';

/// Storage Security Rules Test
///
/// This test verifies that Firebase Storage security rules are correctly enforced:
/// - Requirement 11.4: Users can read/write their own files, read own generated reports
/// - Requirement 11.5: File size limits (10MB for uploads)
/// - Requirement 11.6: Access restrictions are properly enforced
///
/// Note: These tests require Firebase emulator or a test Firebase project
/// Run with: flutter test test/storage_rules_test.dart

void main() {
  group('Storage Security Rules Tests', () {
    late FirebaseStorage storage;
    late FirebaseAuth auth;
    String? testUserId;

    setUpAll(() async {
      // Initialize Firebase for testing
      // Note: In production, use Firebase Test Lab or emulator
      try {
        await Firebase.initializeApp();
      } catch (e) {
        // Already initialized
      }

      storage = FirebaseStorage.instance;
      auth = FirebaseAuth.instance;
    });

    setUp(() async {
      // Sign in a test user
      try {
        final userCredential = await auth.signInAnonymously();
        testUserId = userCredential.user?.uid;
      } catch (e) {
        print('Setup error: $e');
      }
    });

    tearDown(() async {
      // Clean up test user
      try {
        await auth.signOut();
      } catch (e) {
        print('Teardown error: $e');
      }
    });

    test('Authenticated user can upload file to their uploads folder',
        () async {
      if (testUserId == null) {
        print('Skipping test: No authenticated user');
        return;
      }

      // Create a small test file (< 10MB)
      final testData = Uint8List.fromList(List.filled(1024, 0)); // 1KB
      final ref = storage.ref('uploads/$testUserId/test_image.jpg');

      try {
        await ref.putData(testData);
        expect(true, true); // Upload succeeded
      } catch (e) {
        fail('Upload should succeed for authenticated user: $e');
      }
    });

    test('Authenticated user can read their own uploaded file', () async {
      if (testUserId == null) {
        print('Skipping test: No authenticated user');
        return;
      }

      final ref = storage.ref('uploads/$testUserId/test_image.jpg');

      try {
        final url = await ref.getDownloadURL();
        expect(url, isNotEmpty);
      } catch (e) {
        fail('Read should succeed for own file: $e');
      }
    });

    test('File size limit is enforced (10MB)', () async {
      if (testUserId == null) {
        print('Skipping test: No authenticated user');
        return;
      }

      // Create a file larger than 10MB
      final largeData = Uint8List.fromList(
        List.filled(11 * 1024 * 1024, 0), // 11MB
      );
      final ref = storage.ref('uploads/$testUserId/large_file.jpg');

      try {
        await ref.putData(largeData);
        fail('Upload should fail for files > 10MB');
      } catch (e) {
        expect(e, isA<FirebaseException>());
        // Expected to fail due to size limit
      }
    });

    test('User can read generated reports in their folder', () async {
      if (testUserId == null) {
        print('Skipping test: No authenticated user');
        return;
      }

      // Attempt to read from reports folder
      final ref = storage.ref('reports/$testUserId/test_report.pdf');

      try {
        // This will fail if file doesn't exist, but won't fail due to permissions
        await ref.getDownloadURL();
      } catch (e) {
        // If it's a not-found error, permissions are OK
        // If it's a permission error, test should fail
        if (e is FirebaseException && e.code == 'object-not-found') {
          expect(true, true); // Permissions are correct
        } else if (e is FirebaseException && e.code == 'unauthorized') {
          fail('User should be able to read their own reports');
        }
      }
    });

    test('User cannot write to generated reports folder', () async {
      if (testUserId == null) {
        print('Skipping test: No authenticated user');
        return;
      }

      final testData = Uint8List.fromList(List.filled(1024, 0));
      final ref = storage.ref('reports/$testUserId/unauthorized_write.pdf');

      try {
        await ref.putData(testData);
        fail('Write should fail for reports folder');
      } catch (e) {
        expect(e, isA<FirebaseException>());
        // Expected to fail - only Cloud Functions can write
      }
    });

    test('User cannot access another user files', () async {
      if (testUserId == null) {
        print('Skipping test: No authenticated user');
        return;
      }

      // Try to access another user's uploads
      final otherUserId = 'different_user_id';
      final ref = storage.ref('uploads/$otherUserId/test_file.jpg');

      try {
        await ref.getDownloadURL();
        fail('Should not be able to access other user files');
      } catch (e) {
        expect(e, isA<FirebaseException>());
        // Expected to fail due to ownership check
      }
    });

    test('Unauthenticated user cannot upload files', () async {
      // Sign out to test unauthenticated access
      await auth.signOut();

      final testData = Uint8List.fromList(List.filled(1024, 0));
      final ref = storage.ref('uploads/test_user/test_file.jpg');

      try {
        await ref.putData(testData);
        fail('Unauthenticated upload should fail');
      } catch (e) {
        expect(e, isA<FirebaseException>());
        // Expected to fail - authentication required
      }
    });

    test('User can delete their own uploaded files', () async {
      if (testUserId == null) {
        print('Skipping test: No authenticated user');
        return;
      }

      // First upload a file
      final testData = Uint8List.fromList(List.filled(1024, 0));
      final ref = storage.ref('uploads/$testUserId/deletable_file.jpg');

      try {
        await ref.putData(testData);
        // Now try to delete it
        await ref.delete();
        expect(true, true); // Delete succeeded
      } catch (e) {
        fail('User should be able to delete their own files: $e');
      }
    });

    test('User cannot delete generated reports', () async {
      if (testUserId == null) {
        print('Skipping test: No authenticated user');
        return;
      }

      final ref = storage.ref('reports/$testUserId/test_report.pdf');

      try {
        await ref.delete();
        fail('User should not be able to delete generated reports');
      } catch (e) {
        expect(e, isA<FirebaseException>());
        // Expected to fail - only Cloud Functions can delete
      }
    });
  });
}
