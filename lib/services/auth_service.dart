import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/user_model.dart';
import '../utils/constants.dart';
import 'api_service.dart';

/// Authentication service for login, register, logout, and password reset
class AuthService {
  final ApiService _apiService;
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  AuthService({ApiService? apiService})
      : _apiService = apiService ?? ApiService();

  /// Register a new user
  ///
  /// Requirements: 3.4, 3.5
  Future<AuthResponse> register({
    required String email,
    required String password,
    required String passwordConfirmation,
    String? name,
  }) async {
    try {
      final response = await _apiService.post(
        AppConstants.registerEndpoint,
        data: {
          'email': email,
          'password': password,
          'passwordConfirmation': passwordConfirmation,
          if (name != null) 'name': name,
        },
      );

      final authResponse = AuthResponse.fromJson(response.data);

      // Store tokens securely
      await _storeTokens(
        authResponse.token,
        authResponse.refreshToken,
        authResponse.user.id,
      );

      return authResponse;
    } catch (e) {
      rethrow;
    }
  }

  /// Login with email and password
  ///
  /// Requirements: 4.1, 4.2
  Future<AuthResponse> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _apiService.post(
        AppConstants.loginEndpoint,
        data: {
          'email': email,
          'password': password,
        },
      );

      final authResponse = AuthResponse.fromJson(response.data);

      // Store tokens securely
      await _storeTokens(
        authResponse.token,
        authResponse.refreshToken,
        authResponse.user.id,
      );

      return authResponse;
    } catch (e) {
      rethrow;
    }
  }

  /// Logout current user
  Future<void> logout() async {
    try {
      // Call logout endpoint to invalidate token on server
      await _apiService.post(AppConstants.logoutEndpoint);
    } catch (e) {
      // Continue with local logout even if server call fails
      // ignore: avoid_print
      print('Logout API call failed: $e');
    } finally {
      // Clear all stored tokens and user data
      await _clearTokens();
    }
  }

  /// Request password reset
  ///
  /// Requirements: 4.4
  Future<void> resetPassword({required String email}) async {
    try {
      await _apiService.post(
        AppConstants.resetPasswordEndpoint,
        data: {'email': email},
      );
    } catch (e) {
      rethrow;
    }
  }

  /// Check if user is authenticated
  Future<bool> isAuthenticated() async {
    final token = await _secureStorage.read(key: AppConstants.authTokenKey);
    return token != null;
  }

  /// Get current auth token
  Future<String?> getAuthToken() async {
    return await _secureStorage.read(key: AppConstants.authTokenKey);
  }

  /// Get current user ID
  Future<String?> getUserId() async {
    return await _secureStorage.read(key: AppConstants.userIdKey);
  }

  /// Store authentication tokens securely
  Future<void> _storeTokens(
      String token, String refreshToken, String userId) async {
    await _secureStorage.write(key: AppConstants.authTokenKey, value: token);
    await _secureStorage.write(
        key: AppConstants.refreshTokenKey, value: refreshToken);
    await _secureStorage.write(key: AppConstants.userIdKey, value: userId);

    // Store token expiry time (default 15 minutes from now)
    final tokenExpiry = DateTime.now().add(const Duration(minutes: 15));
    await _secureStorage.write(
      key: AppConstants.tokenExpiryKey,
      value: tokenExpiry.toIso8601String(),
    );

    // Update last activity timestamp
    await _secureStorage.write(
      key: AppConstants.lastActivityKey,
      value: DateTime.now().toIso8601String(),
    );
  }

  /// Clear all authentication tokens
  Future<void> _clearTokens() async {
    await _secureStorage.delete(key: AppConstants.authTokenKey);
    await _secureStorage.delete(key: AppConstants.refreshTokenKey);
    await _secureStorage.delete(key: AppConstants.userIdKey);
    await _secureStorage.delete(key: AppConstants.lastActivityKey);
    await _secureStorage.delete(key: AppConstants.tokenExpiryKey);
  }

  /// Check if session has expired due to inactivity
  Future<bool> isSessionExpired() async {
    final lastActivityStr =
        await _secureStorage.read(key: AppConstants.lastActivityKey);
    if (lastActivityStr == null) return true;

    final lastActivity = DateTime.parse(lastActivityStr);
    final now = DateTime.now();
    final difference = now.difference(lastActivity);

    return difference.inMinutes > AppConstants.sessionTimeoutMinutes;
  }

  /// Update last activity timestamp
  Future<void> updateActivity() async {
    await _secureStorage.write(
      key: AppConstants.lastActivityKey,
      value: DateTime.now().toIso8601String(),
    );
  }

  /// Refresh authentication token
  ///
  /// Requirements: 11.4
  Future<AuthResponse?> refreshToken() async {
    try {
      final refreshToken =
          await _secureStorage.read(key: AppConstants.refreshTokenKey);
      if (refreshToken == null) return null;

      final response = await _apiService.post(
        AppConstants.refreshTokenEndpoint,
        data: {'refreshToken': refreshToken},
      );

      final authResponse = AuthResponse.fromJson(response.data);

      // Store new tokens securely
      await _storeTokens(
        authResponse.token,
        authResponse.refreshToken,
        authResponse.user.id,
      );

      return authResponse;
    } catch (e) {
      // If refresh fails, clear tokens
      await _clearTokens();
      return null;
    }
  }

  /// Check if token is expired based on stored expiration time
  ///
  /// Requirements: 11.2, 11.3
  Future<bool> isTokenExpired() async {
    final tokenExpiryStr =
        await _secureStorage.read(key: AppConstants.tokenExpiryKey);
    if (tokenExpiryStr == null) return true;

    final tokenExpiry = DateTime.parse(tokenExpiryStr);
    final now = DateTime.now();

    // Consider token expired if less than 5 minutes remaining
    return now.isAfter(tokenExpiry.subtract(const Duration(minutes: 5)));
  }

  /// Validate and refresh session if needed
  ///
  /// Requirements: 11.1, 11.2, 11.4
  Future<bool> validateAndRefreshSession() async {
    // Check if authenticated
    if (!await isAuthenticated()) return false;

    // Check session persistence (7 days)
    final lastActivityStr =
        await _secureStorage.read(key: AppConstants.lastActivityKey);
    if (lastActivityStr != null) {
      final lastActivity = DateTime.parse(lastActivityStr);
      final now = DateTime.now();
      final daysSinceActivity = now.difference(lastActivity).inDays;

      // If more than 7 days, session is invalid
      if (daysSinceActivity >= AppConstants.sessionPersistenceDays) {
        await _clearTokens();
        return false;
      }
    }

    // Check if token needs refresh
    if (await isTokenExpired()) {
      final refreshed = await refreshToken();
      return refreshed != null;
    }

    // Check inactivity timeout
    if (await isSessionExpired()) {
      await _clearTokens();
      return false;
    }

    return true;
  }

  /// Get refresh token
  Future<String?> getRefreshToken() async {
    return await _secureStorage.read(key: AppConstants.refreshTokenKey);
  }
}

/// Authentication response model
class AuthResponse {
  final String token;
  final String refreshToken;
  final User user;
  final int expiresIn;

  AuthResponse({
    required this.token,
    required this.refreshToken,
    required this.user,
    required this.expiresIn,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    return AuthResponse(
      token: json['token'] as String,
      refreshToken: json['refreshToken'] as String,
      user: User.fromJson(json['user'] as Map<String, dynamic>),
      expiresIn: json['expiresIn'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'token': token,
      'refreshToken': refreshToken,
      'user': user.toJson(),
      'expiresIn': expiresIn,
    };
  }
}
