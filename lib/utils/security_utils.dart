import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'constants.dart';

/// Security utilities for session management and data protection
///
/// Requirements: 11.5
class SecurityUtils {
  static final SecurityUtils _instance = SecurityUtils._internal();
  factory SecurityUtils() => _instance;
  SecurityUtils._internal();

  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  /// Generate a secure hash for sensitive data
  ///
  /// Requirements: 11.5
  String generateHash(String data) {
    final bytes = utf8.encode(data);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  /// Store sensitive data securely
  ///
  /// Requirements: 11.5
  Future<void> storeSecureData(String key, String value) async {
    await _secureStorage.write(key: key, value: value);
  }

  /// Retrieve sensitive data securely
  ///
  /// Requirements: 11.5
  Future<String?> getSecureData(String key) async {
    return await _secureStorage.read(key: key);
  }

  /// Delete sensitive data
  ///
  /// Requirements: 11.5
  Future<void> deleteSecureData(String key) async {
    await _secureStorage.delete(key: key);
  }

  /// Clear all secure storage
  ///
  /// Requirements: 11.5
  Future<void> clearAllSecureData() async {
    await _secureStorage.deleteAll();
  }

  /// Validate token format (basic JWT validation)
  ///
  /// Requirements: 11.5
  bool isValidTokenFormat(String token) {
    // Basic JWT format check: header.payload.signature
    final parts = token.split('.');
    if (parts.length != 3) return false;

    // Check if each part is base64 encoded
    try {
      for (final part in parts) {
        base64Url.decode(base64Url.normalize(part));
      }
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Extract token expiry from JWT payload
  ///
  /// Requirements: 11.4, 11.5
  DateTime? extractTokenExpiry(String token) {
    try {
      final parts = token.split('.');
      if (parts.length != 3) return null;

      // Decode payload
      final payload = parts[1];
      final normalized = base64Url.normalize(payload);
      final decoded = utf8.decode(base64Url.decode(normalized));
      final json = jsonDecode(decoded) as Map<String, dynamic>;

      // Extract expiry timestamp (exp claim)
      if (json.containsKey('exp')) {
        final exp = json['exp'] as int;
        return DateTime.fromMillisecondsSinceEpoch(exp * 1000);
      }

      return null;
    } catch (e) {
      return null;
    }
  }

  /// Check if device is rooted/jailbroken (basic check)
  ///
  /// Requirements: 11.5
  Future<bool> isDeviceCompromised() async {
    // This is a placeholder for actual root/jailbreak detection
    // In production, use packages like flutter_jailbreak_detection
    // or safe_device for comprehensive checks
    return false;
  }

  /// Generate a device fingerprint for session binding
  ///
  /// Requirements: 11.5
  Future<String> generateDeviceFingerprint() async {
    // In production, this should include:
    // - Device ID
    // - Platform version
    // - App version
    // - Other device-specific identifiers
    final timestamp = DateTime.now().millisecondsSinceEpoch.toString();
    return generateHash(timestamp);
  }

  /// Validate session integrity
  ///
  /// Requirements: 11.1, 11.5
  Future<bool> validateSessionIntegrity() async {
    // Check if all required session data exists
    final token = await _secureStorage.read(key: AppConstants.authTokenKey);
    final refreshToken =
        await _secureStorage.read(key: AppConstants.refreshTokenKey);
    final userId = await _secureStorage.read(key: AppConstants.userIdKey);
    final lastActivity =
        await _secureStorage.read(key: AppConstants.lastActivityKey);

    if (token == null ||
        refreshToken == null ||
        userId == null ||
        lastActivity == null) {
      return false;
    }

    // Validate token format
    if (!isValidTokenFormat(token)) {
      return false;
    }

    return true;
  }

  /// Sanitize sensitive data from logs
  ///
  /// Requirements: 11.5
  String sanitizeForLogging(String data) {
    // Remove or mask sensitive information
    final patterns = {
      'token': r'token["\s:]+([^",\s}]+)',
      'password': r'password["\s:]+([^",\s}]+)',
      'email': r'\b[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Z|a-z]{2,}\b',
    };

    String sanitized = data;
    patterns.forEach((key, pattern) {
      sanitized = sanitized.replaceAll(RegExp(pattern), '$key: [REDACTED]');
    });

    return sanitized;
  }
}
