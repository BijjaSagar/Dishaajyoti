import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'constants.dart';

/// Session manager utility for handling session state and validation
///
/// Requirements: 11.1, 11.2, 11.3, 11.4, 11.5
class SessionManager {
  static final SessionManager _instance = SessionManager._internal();
  factory SessionManager() => _instance;
  SessionManager._internal();

  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  /// Check if session is within persistence window (7 days)
  ///
  /// Requirements: 11.2
  Future<bool> isWithinPersistenceWindow() async {
    final lastActivityStr =
        await _secureStorage.read(key: AppConstants.lastActivityKey);
    if (lastActivityStr == null) return false;

    final lastActivity = DateTime.parse(lastActivityStr);
    final now = DateTime.now();
    final daysSinceActivity = now.difference(lastActivity).inDays;

    return daysSinceActivity < AppConstants.sessionPersistenceDays;
  }

  /// Check if session has timed out due to inactivity (30 minutes)
  ///
  /// Requirements: 11.1, 11.2
  Future<bool> hasInactivityTimeout() async {
    final lastActivityStr =
        await _secureStorage.read(key: AppConstants.lastActivityKey);
    if (lastActivityStr == null) return true;

    final lastActivity = DateTime.parse(lastActivityStr);
    final now = DateTime.now();
    final minutesSinceActivity = now.difference(lastActivity).inMinutes;

    return minutesSinceActivity >= AppConstants.sessionTimeoutMinutes;
  }

  /// Check if token is expired or about to expire
  ///
  /// Requirements: 11.4
  Future<bool> isTokenExpired() async {
    final tokenExpiryStr =
        await _secureStorage.read(key: AppConstants.tokenExpiryKey);
    if (tokenExpiryStr == null) return true;

    final tokenExpiry = DateTime.parse(tokenExpiryStr);
    final now = DateTime.now();

    // Consider token expired if less than 5 minutes remaining
    return now.isAfter(tokenExpiry.subtract(const Duration(minutes: 5)));
  }

  /// Get session status information
  ///
  /// Requirements: 11.1, 11.2
  Future<SessionStatus> getSessionStatus() async {
    final hasToken =
        await _secureStorage.read(key: AppConstants.authTokenKey) != null;
    if (!hasToken) {
      return SessionStatus(
        isValid: false,
        reason: SessionInvalidReason.noToken,
      );
    }

    if (!await isWithinPersistenceWindow()) {
      return SessionStatus(
        isValid: false,
        reason: SessionInvalidReason.persistenceExpired,
      );
    }

    if (await hasInactivityTimeout()) {
      return SessionStatus(
        isValid: false,
        reason: SessionInvalidReason.inactivityTimeout,
      );
    }

    if (await isTokenExpired()) {
      return SessionStatus(
        isValid: false,
        reason: SessionInvalidReason.tokenExpired,
        requiresRefresh: true,
      );
    }

    return SessionStatus(isValid: true);
  }

  /// Update last activity timestamp
  ///
  /// Requirements: 11.1
  Future<void> updateActivity() async {
    await _secureStorage.write(
      key: AppConstants.lastActivityKey,
      value: DateTime.now().toIso8601String(),
    );
  }

  /// Store token expiry time
  ///
  /// Requirements: 11.4, 11.5
  Future<void> storeTokenExpiry(DateTime expiry) async {
    await _secureStorage.write(
      key: AppConstants.tokenExpiryKey,
      value: expiry.toIso8601String(),
    );
  }

  /// Get time until session expires (in minutes)
  ///
  /// Requirements: 11.1, 11.2
  Future<int> getTimeUntilExpiry() async {
    final lastActivityStr =
        await _secureStorage.read(key: AppConstants.lastActivityKey);
    if (lastActivityStr == null) return 0;

    final lastActivity = DateTime.parse(lastActivityStr);
    final now = DateTime.now();
    final elapsed = now.difference(lastActivity).inMinutes;
    final remaining = AppConstants.sessionTimeoutMinutes - elapsed;

    return remaining > 0 ? remaining : 0;
  }

  /// Get time until persistence expires (in days)
  ///
  /// Requirements: 11.2
  Future<int> getTimeUntilPersistenceExpiry() async {
    final lastActivityStr =
        await _secureStorage.read(key: AppConstants.lastActivityKey);
    if (lastActivityStr == null) return 0;

    final lastActivity = DateTime.parse(lastActivityStr);
    final now = DateTime.now();
    final elapsed = now.difference(lastActivity).inDays;
    final remaining = AppConstants.sessionPersistenceDays - elapsed;

    return remaining > 0 ? remaining : 0;
  }

  /// Clear all session data
  ///
  /// Requirements: 11.5
  Future<void> clearSession() async {
    await _secureStorage.delete(key: AppConstants.authTokenKey);
    await _secureStorage.delete(key: AppConstants.refreshTokenKey);
    await _secureStorage.delete(key: AppConstants.userIdKey);
    await _secureStorage.delete(key: AppConstants.tokenExpiryKey);
    await _secureStorage.delete(key: AppConstants.lastActivityKey);
  }
}

/// Session status information
class SessionStatus {
  final bool isValid;
  final SessionInvalidReason? reason;
  final bool requiresRefresh;

  SessionStatus({
    required this.isValid,
    this.reason,
    this.requiresRefresh = false,
  });

  String get message {
    if (isValid) return 'Session is valid';

    switch (reason) {
      case SessionInvalidReason.noToken:
        return 'No authentication token found';
      case SessionInvalidReason.persistenceExpired:
        return 'Session expired after ${AppConstants.sessionPersistenceDays} days';
      case SessionInvalidReason.inactivityTimeout:
        return 'Session timed out after ${AppConstants.sessionTimeoutMinutes} minutes of inactivity';
      case SessionInvalidReason.tokenExpired:
        return 'Authentication token expired';
      default:
        return 'Session is invalid';
    }
  }
}

/// Reasons why a session might be invalid
enum SessionInvalidReason {
  noToken,
  persistenceExpired,
  inactivityTimeout,
  tokenExpired,
}
