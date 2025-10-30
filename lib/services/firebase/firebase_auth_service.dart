import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'firebase_service_manager.dart';

/// Service class for handling Firebase Authentication operations
/// Supports email/password, phone, Google, and Apple Sign-In
class FirebaseAuthService {
  // Singleton instance
  static final FirebaseAuthService _instance = FirebaseAuthService._internal();
  factory FirebaseAuthService() => _instance;
  FirebaseAuthService._internal();

  static FirebaseAuthService get instance => _instance;

  // Firebase instances
  final FirebaseAuth _auth = FirebaseServiceManager.instance.auth;
  final FirebaseFirestore _firestore =
      FirebaseServiceManager.instance.firestore;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  // Phone verification
  String? _verificationId;
  int? _resendToken;

  /// Sign up with email and password
  /// Creates a new user account and user profile in Firestore
  Future<UserCredential> signUpWithEmail({
    required String email,
    required String password,
    required String name,
    String? phone,
  }) async {
    try {
      // Create user account
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Update display name
      await userCredential.user?.updateDisplayName(name);

      // Create user profile in Firestore
      await _createUserProfile(
        userId: userCredential.user!.uid,
        email: email,
        name: name,
        phone: phone,
      );

      debugPrint('User signed up successfully: ${userCredential.user?.uid}');
      return userCredential;
    } on FirebaseAuthException catch (e) {
      debugPrint('Sign up error: ${e.code} - ${e.message}');
      rethrow;
    }
  }

  /// Sign in with email and password
  Future<UserCredential> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      final userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      debugPrint('User signed in successfully: ${userCredential.user?.uid}');
      return userCredential;
    } on FirebaseAuthException catch (e) {
      debugPrint('Sign in error: ${e.code} - ${e.message}');
      rethrow;
    }
  }

  /// Send OTP for phone number verification
  /// Returns a Future that completes when OTP is sent
  Future<void> sendOTP({
    required String phoneNumber,
    required Function(String verificationId) onCodeSent,
    required Function(String error) onError,
    Function(PhoneAuthCredential credential)? onAutoVerify,
  }) async {
    try {
      await _auth.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        timeout: const Duration(seconds: 60),
        verificationCompleted: (PhoneAuthCredential credential) async {
          debugPrint('Phone verification completed automatically');
          if (onAutoVerify != null) {
            onAutoVerify(credential);
          } else {
            // Auto sign in if callback not provided
            await _auth.signInWithCredential(credential);
          }
        },
        verificationFailed: (FirebaseAuthException e) {
          debugPrint('Phone verification failed: ${e.code} - ${e.message}');
          onError(e.message ?? 'Verification failed');
        },
        codeSent: (String verificationId, int? resendToken) {
          debugPrint('OTP sent successfully');
          _verificationId = verificationId;
          _resendToken = resendToken;
          onCodeSent(verificationId);
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          debugPrint('Auto retrieval timeout');
          _verificationId = verificationId;
        },
        forceResendingToken: _resendToken,
      );
    } catch (e) {
      debugPrint('Error sending OTP: $e');
      onError(e.toString());
    }
  }

  /// Sign in with phone number using OTP
  Future<UserCredential> signInWithPhone({
    required String verificationId,
    required String smsCode,
    String? name,
  }) async {
    try {
      // Create credential
      final credential = PhoneAuthProvider.credential(
        verificationId: verificationId,
        smsCode: smsCode,
      );

      // Sign in with credential
      final userCredential = await _auth.signInWithCredential(credential);

      // Create user profile if new user
      if (userCredential.additionalUserInfo?.isNewUser ?? false) {
        await _createUserProfile(
          userId: userCredential.user!.uid,
          phone: userCredential.user!.phoneNumber,
          name: name,
        );
      }

      debugPrint('User signed in with phone: ${userCredential.user?.uid}');
      return userCredential;
    } on FirebaseAuthException catch (e) {
      debugPrint('Phone sign in error: ${e.code} - ${e.message}');
      rethrow;
    }
  }

  /// Sign in with Google
  Future<UserCredential> signInWithGoogle() async {
    try {
      // Trigger the Google Sign-In flow
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser == null) {
        throw FirebaseAuthException(
          code: 'sign_in_canceled',
          message: 'Google Sign-In cancelled by user',
        );
      }

      // Obtain the auth details from the request
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      // Verify we have the required tokens
      if (googleAuth.accessToken == null || googleAuth.idToken == null) {
        throw FirebaseAuthException(
          code: 'missing-auth-token',
          message: 'Failed to obtain authentication tokens from Google',
        );
      }

      // Create a new credential
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Sign in to Firebase with the Google credential
      final userCredential = await _auth.signInWithCredential(credential);

      // Create or update user profile in Firestore
      await _createOrUpdateUserProfile(userCredential.user!);

      debugPrint('User signed in with Google: ${userCredential.user?.uid}');
      return userCredential;
    } on FirebaseAuthException catch (e) {
      debugPrint('Google sign in error: ${e.code} - ${e.message}');
      rethrow;
    } on PlatformException catch (e) {
      debugPrint(
          'Platform exception during Google sign in: ${e.code} - ${e.message}');
      // Convert platform exception to Firebase auth exception for consistent handling
      throw FirebaseAuthException(
        code: 'sign_in_failed',
        message: e.message ??
            'Google Sign-In failed. Please check your configuration.',
      );
    } catch (e) {
      debugPrint('Google sign in error: $e');
      throw FirebaseAuthException(
        code: 'unknown',
        message:
            'An unexpected error occurred during Google Sign-In: ${e.toString()}',
      );
    }
  }

  /// Sign in with Apple
  Future<UserCredential> signInWithApple() async {
    try {
      // Request Apple ID credential
      final appleCredential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
      );

      // Create OAuth credential
      final oauthCredential = OAuthProvider('apple.com').credential(
        idToken: appleCredential.identityToken,
        accessToken: appleCredential.authorizationCode,
      );

      // Sign in to Firebase with the Apple credential
      final userCredential = await _auth.signInWithCredential(oauthCredential);

      // Create or update user profile with Apple data
      String? displayName;
      if (appleCredential.givenName != null ||
          appleCredential.familyName != null) {
        displayName =
            '${appleCredential.givenName ?? ''} ${appleCredential.familyName ?? ''}'
                .trim();
      }

      await _createOrUpdateUserProfile(
        userCredential.user!,
        displayName: displayName,
      );

      debugPrint('User signed in with Apple: ${userCredential.user?.uid}');
      return userCredential;
    } on FirebaseAuthException catch (e) {
      debugPrint('Apple sign in error: ${e.code} - ${e.message}');
      rethrow;
    } on SignInWithAppleAuthorizationException catch (e) {
      debugPrint('Apple authorization error: ${e.code} - ${e.message}');
      throw FirebaseAuthException(
        code: e.code.toString(),
        message: e.message,
      );
    } catch (e) {
      debugPrint('Apple sign in error: $e');
      rethrow;
    }
  }

  /// Link Google account to existing user
  Future<UserCredential> linkWithGoogle() async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        throw FirebaseAuthException(
          code: 'ERROR_NO_USER',
          message: 'No user is currently signed in',
        );
      }

      // Trigger the Google Sign-In flow
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser == null) {
        throw FirebaseAuthException(
          code: 'ERROR_ABORTED_BY_USER',
          message: 'Google Sign-In cancelled by user',
        );
      }

      // Obtain the auth details
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      // Create credential
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Link credential to current user
      final userCredential = await user.linkWithCredential(credential);

      debugPrint('Google account linked successfully');
      return userCredential;
    } on FirebaseAuthException catch (e) {
      debugPrint('Link Google error: ${e.code} - ${e.message}');
      rethrow;
    }
  }

  /// Link Apple account to existing user
  Future<UserCredential> linkWithApple() async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        throw FirebaseAuthException(
          code: 'ERROR_NO_USER',
          message: 'No user is currently signed in',
        );
      }

      // Request Apple ID credential
      final appleCredential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
      );

      // Create OAuth credential
      final oauthCredential = OAuthProvider('apple.com').credential(
        idToken: appleCredential.identityToken,
        accessToken: appleCredential.authorizationCode,
      );

      // Link credential to current user
      final userCredential = await user.linkWithCredential(oauthCredential);

      debugPrint('Apple account linked successfully');
      return userCredential;
    } on FirebaseAuthException catch (e) {
      debugPrint('Link Apple error: ${e.code} - ${e.message}');
      rethrow;
    }
  }

  /// Get list of linked authentication providers
  List<String> getLinkedProviders() {
    final user = _auth.currentUser;
    if (user == null) return [];

    return user.providerData.map((info) => info.providerId).toList();
  }

  /// Reset password via email
  Future<void> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
      debugPrint('Password reset email sent to: $email');
    } on FirebaseAuthException catch (e) {
      debugPrint('Password reset error: ${e.code} - ${e.message}');
      rethrow;
    }
  }

  /// Sign out current user
  Future<void> signOut() async {
    try {
      // Sign out from Google if signed in
      if (await _googleSignIn.isSignedIn()) {
        await _googleSignIn.signOut();
      }

      // Sign out from Firebase
      await _auth.signOut();
      debugPrint('User signed out successfully');
    } catch (e) {
      debugPrint('Sign out error: $e');
      rethrow;
    }
  }

  /// Get current user
  User? getCurrentUser() {
    return _auth.currentUser;
  }

  /// Listen to auth state changes
  Stream<User?> authStateChanges() {
    return _auth.authStateChanges();
  }

  /// Listen to user changes (includes token refresh)
  Stream<User?> userChanges() {
    return _auth.userChanges();
  }

  /// Create user profile in Firestore
  Future<void> _createUserProfile({
    required String userId,
    String? email,
    String? name,
    String? phone,
  }) async {
    try {
      await _firestore.collection('users').doc(userId).set({
        'email': email,
        'name': name ?? '',
        'phone': phone,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
        'subscription': {
          'type': 'free',
          'expiresAt': null,
        },
        'preferences': {
          'language': 'en',
          'chartStyle': 'northIndian',
          'notifications': true,
        },
      }, SetOptions(merge: true));

      debugPrint('User profile created in Firestore: $userId');
    } catch (e) {
      debugPrint('Error creating user profile: $e');
      // Don't rethrow - profile creation failure shouldn't block authentication
    }
  }

  /// Create or update user profile from Firebase User
  Future<void> _createOrUpdateUserProfile(
    User user, {
    String? displayName,
  }) async {
    try {
      final userRef = _firestore.collection('users').doc(user.uid);
      final userDoc = await userRef.get();

      final data = {
        'email': user.email,
        'name': displayName ?? user.displayName ?? '',
        'phone': user.phoneNumber,
        'updatedAt': FieldValue.serverTimestamp(),
      };

      if (!userDoc.exists) {
        // New user - set default values
        data['createdAt'] = FieldValue.serverTimestamp();
        data['subscription'] = {
          'type': 'free',
          'expiresAt': null,
        };
        data['preferences'] = {
          'language': 'en',
          'chartStyle': 'northIndian',
          'notifications': true,
        };
      }

      await userRef.set(data, SetOptions(merge: true));
      debugPrint('User profile updated in Firestore: ${user.uid}');
    } catch (e) {
      debugPrint('Error updating user profile: $e');
      // Don't rethrow - profile update failure shouldn't block authentication
    }
  }

  /// Reload current user data
  Future<void> reloadUser() async {
    await _auth.currentUser?.reload();
  }

  /// Update user display name
  Future<void> updateDisplayName(String displayName) async {
    try {
      await _auth.currentUser?.updateDisplayName(displayName);
      await reloadUser();
      debugPrint('Display name updated: $displayName');
    } catch (e) {
      debugPrint('Error updating display name: $e');
      rethrow;
    }
  }

  /// Update user email
  Future<void> updateEmail(String email) async {
    try {
      await _auth.currentUser?.updateEmail(email);
      await reloadUser();
      debugPrint('Email updated: $email');
    } catch (e) {
      debugPrint('Error updating email: $e');
      rethrow;
    }
  }

  /// Update user password
  Future<void> updatePassword(String newPassword) async {
    try {
      await _auth.currentUser?.updatePassword(newPassword);
      debugPrint('Password updated successfully');
    } catch (e) {
      debugPrint('Error updating password: $e');
      rethrow;
    }
  }

  /// Delete user account
  Future<void> deleteAccount() async {
    try {
      final userId = _auth.currentUser?.uid;

      // Delete user profile from Firestore
      if (userId != null) {
        await _firestore.collection('users').doc(userId).delete();
      }

      // Delete Firebase Auth account
      await _auth.currentUser?.delete();
      debugPrint('User account deleted successfully');
    } catch (e) {
      debugPrint('Error deleting account: $e');
      rethrow;
    }
  }

  /// Re-authenticate user with email and password
  /// Required before sensitive operations like email/password change
  Future<void> reauthenticateWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        throw FirebaseAuthException(
          code: 'ERROR_NO_USER',
          message: 'No user is currently signed in',
        );
      }

      final credential = EmailAuthProvider.credential(
        email: email,
        password: password,
      );

      await user.reauthenticateWithCredential(credential);
      debugPrint('User re-authenticated successfully');
    } catch (e) {
      debugPrint('Re-authentication error: $e');
      rethrow;
    }
  }
}
