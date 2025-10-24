import 'dart:async';
import 'package:flutter/widgets.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';
import '../utils/constants.dart';

/// Authentication state provider
///
/// Manages user authentication state, session management, and auto-logout
/// Requirements: 3.6, 4.2, 11.1, 11.2, 11.3, 11.4, 11.5
class AuthProvider with ChangeNotifier {
  final AuthService _authService;
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  User? _user;
  bool _isAuthenticated = false;
  bool _isLoading = false;
  String? _error;
  Timer? _sessionTimer;
  DateTime? _lastActivity;

  AuthProvider({AuthService? authService})
      : _authService = authService ?? AuthService() {
    _initializeAuth();
  }

  // Getters
  User? get user => _user;
  bool get isAuthenticated => _isAuthenticated;
  bool get isLoading => _isLoading;
  String? get error => _error;
  DateTime? get lastActivity => _lastActivity;

  /// Initialize authentication state on app start
  ///
  /// Requirements: 11.1, 11.2, 11.3
  Future<void> _initializeAuth() async {
    try {
      final isValid = await _authService.validateAndRefreshSession();
      if (isValid) {
        _isAuthenticated = true;
        _lastActivity = DateTime.now();
        _startSessionTimer();
        notifyListeners();
      } else {
        await logout();
      }
    } catch (e) {
      debugPrint('Error initializing auth: $e');
      await logout();
    }
  }

  /// Register a new user
  ///
  /// Requirements: 3.4, 3.5, 3.6
  Future<bool> register({
    required String email,
    required String password,
    required String passwordConfirmation,
    String? name,
  }) async {
    _setLoading(true);
    _clearError();

    try {
      final response = await _authService.register(
        email: email,
        password: password,
        passwordConfirmation: passwordConfirmation,
        name: name,
      );

      _user = response.user;
      _isAuthenticated = true;
      _lastActivity = DateTime.now();
      _startSessionTimer();

      notifyListeners();
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Login with email and password
  ///
  /// Requirements: 4.1, 4.2
  Future<bool> login({
    required String email,
    required String password,
  }) async {
    _setLoading(true);
    _clearError();

    try {
      final response = await _authService.login(
        email: email,
        password: password,
      );

      _user = response.user;
      _isAuthenticated = true;
      _lastActivity = DateTime.now();
      _startSessionTimer();

      notifyListeners();
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Logout current user
  Future<void> logout() async {
    _setLoading(true);

    try {
      await _authService.logout();
    } catch (e) {
      debugPrint('Logout error: $e');
    } finally {
      _user = null;
      _isAuthenticated = false;
      _lastActivity = null;
      _stopSessionTimer();
      _clearError();
      _setLoading(false);
      notifyListeners();
    }
  }

  /// Request password reset
  ///
  /// Requirements: 4.4
  Future<bool> resetPassword({required String email}) async {
    _setLoading(true);
    _clearError();

    try {
      await _authService.resetPassword(email: email);
      notifyListeners();
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Update user activity timestamp
  ///
  /// Requirements: 11.1, 11.2
  Future<void> updateActivity() async {
    _lastActivity = DateTime.now();
    await _authService.updateActivity();
    _resetSessionTimer();
  }

  /// Start session timeout timer
  ///
  /// Requirements: 11.2, 11.3
  void _startSessionTimer() {
    _stopSessionTimer();
    _sessionTimer = Timer.periodic(
      const Duration(minutes: 1),
      (timer) async {
        final isExpired = await _authService.isSessionExpired();
        if (isExpired) {
          await _handleSessionExpired();
        } else {
          // Check if session is about to expire (5 minutes warning)
          final remaining = await getRemainingSessionTime();
          if (remaining <= 5 && remaining > 0) {
            _notifySessionWarning(remaining);
          }
        }
      },
    );
  }

  /// Notify listeners about session warning
  void _notifySessionWarning(int remainingMinutes) {
    // This can be used by UI to show a warning dialog
    // The UI can listen to this through a callback or stream
    debugPrint('Session warning: $remainingMinutes minutes remaining');
  }

  /// Stop session timeout timer
  void _stopSessionTimer() {
    _sessionTimer?.cancel();
    _sessionTimer = null;
  }

  /// Reset session timer
  void _resetSessionTimer() {
    _startSessionTimer();
  }

  /// Handle session expiration
  ///
  /// Requirements: 11.3, 11.4
  Future<void> _handleSessionExpired() async {
    _stopSessionTimer();
    await logout();
    _setError(AppConstants.sessionExpiredMessage);
  }

  /// Check if session is valid
  ///
  /// Requirements: 11.1, 11.2
  Future<bool> isSessionValid() async {
    if (!_isAuthenticated) return false;
    return !(await _authService.isSessionExpired());
  }

  /// Get remaining session time in minutes
  Future<int> getRemainingSessionTime() async {
    final lastActivityStr =
        await _secureStorage.read(key: AppConstants.lastActivityKey);
    if (lastActivityStr == null) return 0;

    final lastActivity = DateTime.parse(lastActivityStr);
    final now = DateTime.now();
    final elapsed = now.difference(lastActivity).inMinutes;
    final remaining = AppConstants.sessionTimeoutMinutes - elapsed;

    return remaining > 0 ? remaining : 0;
  }

  /// Handle app lifecycle changes (resume/pause)
  ///
  /// Requirements: 11.1, 11.2, 11.3, 11.4
  Future<void> handleAppLifecycleChange(AppLifecycleState state) async {
    if (!_isAuthenticated) return;

    switch (state) {
      case AppLifecycleState.resumed:
        // Validate and refresh session when app resumes
        final isValid = await _authService.validateAndRefreshSession();
        if (!isValid) {
          await _handleSessionExpired();
        } else {
          await updateActivity();
        }
        break;
      case AppLifecycleState.paused:
        // Update activity timestamp when app goes to background
        await updateActivity();
        break;
      default:
        break;
    }
  }

  /// Refresh authentication token
  ///
  /// Requirements: 11.4
  Future<bool> refreshAuthToken() async {
    try {
      final response = await _authService.refreshToken();
      if (response != null) {
        _user = response.user;
        await updateActivity();
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('Token refresh error: $e');
      return false;
    }
  }

  /// Set loading state
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  /// Set error message
  void _setError(String error) {
    _error = error;
    notifyListeners();
  }

  /// Clear error message
  void _clearError() {
    _error = null;
  }

  @override
  void dispose() {
    _stopSessionTimer();
    super.dispose();
  }
}
