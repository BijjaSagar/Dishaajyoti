# Session Management and Security Implementation

## Overview

This document describes the comprehensive session management and security implementation for the DishaAjyoti Flutter application, fulfilling requirements 11.1, 11.2, 11.3, 11.4, and 11.5.

## Features Implemented

### 1. Session Timeout Logic (30 minutes inactivity)

**Requirement: 11.1, 11.2**

- Automatic session timeout after 30 minutes of user inactivity
- Activity tracking on every user interaction
- Periodic session validation (every minute)
- Session warning notification when 5 minutes remain

**Implementation:**
- `AuthProvider._startSessionTimer()`: Monitors session activity every minute
- `AuthService.isSessionExpired()`: Checks if 30 minutes have elapsed since last activity
- `SessionManager.hasInactivityTimeout()`: Utility method for timeout validation

### 2. Session Persistence (7 days)

**Requirement: 11.2**

- Sessions persist for up to 7 days even when the app is closed
- Automatic session invalidation after 7 days of inactivity
- Session validation on app launch and resume

**Implementation:**
- `AuthService.validateAndRefreshSession()`: Validates session persistence window
- `SessionManager.isWithinPersistenceWindow()`: Checks 7-day persistence
- Last activity timestamp stored in secure storage

### 3. Auto-logout on Session Expiration

**Requirement: 11.3**

- Automatic logout when session expires due to:
  - 30 minutes of inactivity
  - 7 days since last activity
  - Token expiration without successful refresh
- User-friendly error messages on session expiration
- Automatic navigation to login screen

**Implementation:**
- `AuthProvider._handleSessionExpired()`: Handles session expiration
- `AuthProvider.handleAppLifecycleChange()`: Validates session on app resume
- `AppLifecycleObserver`: Monitors app lifecycle state changes

### 4. Token Refresh Mechanism

**Requirement: 11.4**

- Automatic token refresh when token is about to expire (5 minutes before expiration)
- Refresh token stored securely and used for obtaining new access tokens
- Automatic retry of failed requests after token refresh
- Token expiry tracking and validation

**Implementation:**
- `AuthService.refreshToken()`: Refreshes authentication tokens
- `AuthService.isTokenExpired()`: Checks token expiration status
- `ApiService._refreshToken()`: Handles token refresh in API interceptor
- Automatic retry of 401 requests after successful token refresh

### 5. Secure Storage for Sensitive Data

**Requirement: 11.5**

- All sensitive data stored using Flutter Secure Storage (encrypted)
- Secure storage of:
  - Authentication tokens
  - Refresh tokens
  - User ID
  - Token expiry timestamps
  - Last activity timestamps
- Security utilities for data protection

**Implementation:**
- `FlutterSecureStorage`: Used throughout for encrypted storage
- `SecurityUtils`: Comprehensive security utility class
- `SessionManager`: Centralized session data management

## Architecture

### Core Components

#### 1. AuthService (`lib/services/auth_service.dart`)
- Handles authentication operations
- Manages token storage and refresh
- Validates session state
- Provides session persistence logic

#### 2. AuthProvider (`lib/providers/auth_provider.dart`)
- State management for authentication
- Session timeout monitoring
- Activity tracking
- Lifecycle management integration

#### 3. SessionManager (`lib/utils/session_manager.dart`)
- Centralized session validation
- Session status reporting
- Activity tracking utilities
- Session data management

#### 4. SecurityUtils (`lib/utils/security_utils.dart`)
- Data hashing and encryption utilities
- Token validation
- Session integrity checks
- Security best practices

#### 5. AppLifecycleObserver (`lib/utils/app_lifecycle_observer.dart`)
- Monitors app lifecycle state changes
- Triggers session validation on app resume
- Updates activity on app pause

## Security Features

### Token Management
- JWT tokens with 15-minute expiration
- Refresh tokens for extended sessions
- Automatic token refresh before expiration
- Secure token storage using platform-specific encryption

### Session Validation
- Multi-level session validation:
  1. Token existence check
  2. Token format validation
  3. Token expiration check
  4. Inactivity timeout check
  5. Persistence window check
  6. Session integrity validation

### Data Protection
- All sensitive data encrypted at rest
- Secure storage using platform keychain/keystore
- Token sanitization in logs
- Hash-based data integrity checks

## Usage Examples

### Updating User Activity

```dart
// In any user interaction handler
final authProvider = context.read<AuthProvider>();
await authProvider.updateActivity();
```

### Checking Session Status

```dart
final sessionManager = SessionManager();
final status = await sessionManager.getSessionStatus();

if (!status.isValid) {
  print('Session invalid: ${status.message}');
  if (status.requiresRefresh) {
    // Attempt token refresh
    await authProvider.refreshAuthToken();
  }
}
```

### Manual Token Refresh

```dart
final authProvider = context.read<AuthProvider>();
final success = await authProvider.refreshAuthToken();

if (!success) {
  // Handle refresh failure - logout user
  await authProvider.logout();
}
```

### Session Timeout Warning

```dart
// Show warning dialog when session is about to expire
final remaining = await authProvider.getRemainingSessionTime();

if (remaining <= 5 && remaining > 0) {
  final continue = await SessionTimeoutDialog.show(
    context,
    remainingMinutes: remaining,
  );
  
  if (continue == true) {
    await authProvider.updateActivity();
  } else {
    await authProvider.logout();
  }
}
```

## Configuration

All session-related configuration is centralized in `lib/utils/constants.dart`:

```dart
// Session Configuration
static const int sessionTimeoutMinutes = 30;
static const int sessionPersistenceDays = 7;

// Storage Keys
static const String authTokenKey = 'auth_token';
static const String refreshTokenKey = 'refresh_token';
static const String tokenExpiryKey = 'token_expiry';
static const String lastActivityKey = 'last_activity';
```

## API Integration

### Token Refresh Endpoint

The implementation expects a token refresh endpoint at:
```
POST /api/v1/auth/refresh
```

Request body:
```json
{
  "refreshToken": "string"
}
```

Response:
```json
{
  "token": "string",
  "refreshToken": "string",
  "user": { ... },
  "expiresIn": 900
}
```

### Automatic Token Refresh

The `ApiService` automatically handles token refresh on 401 responses:
1. Detects 401 Unauthorized response
2. Attempts token refresh using refresh token
3. Retries original request with new token
4. Returns response or error

## Testing Recommendations

### Unit Tests
- Session timeout calculation
- Token expiration validation
- Session persistence window checks
- Security utility functions

### Integration Tests
- Complete authentication flow with session management
- Token refresh on API calls
- Session validation on app resume
- Auto-logout scenarios

### Manual Testing Scenarios
1. **Inactivity Timeout**: Leave app idle for 30 minutes, verify auto-logout
2. **Persistence**: Close app, reopen after various time periods (1 hour, 1 day, 8 days)
3. **Token Refresh**: Monitor network calls to verify automatic token refresh
4. **App Lifecycle**: Background app, resume after various time periods
5. **Session Warning**: Wait for 25 minutes of inactivity, verify warning dialog

## Security Best Practices

1. **Never log sensitive data**: Use `SecurityUtils.sanitizeForLogging()` for logs
2. **Validate tokens**: Always validate token format before use
3. **Clear data on logout**: Ensure all secure storage is cleared
4. **Handle refresh failures**: Logout user if token refresh fails
5. **Monitor session integrity**: Regularly validate session data integrity

## Future Enhancements

1. **Biometric Authentication**: Add fingerprint/face ID for quick re-authentication
2. **Multi-device Session Management**: Track and manage sessions across devices
3. **Session Analytics**: Track session duration and user activity patterns
4. **Advanced Security**: Add device fingerprinting and anomaly detection
5. **Offline Session**: Handle session management in offline mode

## Troubleshooting

### Session Expires Too Quickly
- Check `sessionTimeoutMinutes` configuration
- Verify activity updates are being called on user interactions
- Check system time synchronization

### Token Refresh Fails
- Verify refresh token endpoint is correct
- Check refresh token is being stored properly
- Verify backend refresh token validation logic

### Session Not Persisting
- Check `sessionPersistenceDays` configuration
- Verify last activity timestamp is being updated
- Check secure storage permissions on device

## Dependencies

- `flutter_secure_storage: ^9.0.0` - Encrypted storage
- `crypto: ^3.0.3` - Hashing and security utilities
- `provider: ^6.1.1` - State management
- `dio: ^5.4.0` - HTTP client with interceptors

## Compliance

This implementation follows security best practices and complies with:
- OWASP Mobile Security Guidelines
- OAuth 2.0 Token Refresh Flow
- JWT Best Practices
- Platform-specific secure storage standards (iOS Keychain, Android Keystore)
