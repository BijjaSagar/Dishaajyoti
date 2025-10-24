import 'package:flutter/foundation.dart';
import '../models/profile_model.dart';
import '../services/profile_service.dart';

/// Profile state provider
///
/// Manages user profile data and operations
/// Requirements: 5.4
class ProfileProvider with ChangeNotifier {
  final ProfileService _profileService;

  Profile? _profile;
  bool _isLoading = false;
  String? _error;

  ProfileProvider({ProfileService? profileService})
      : _profileService = profileService ?? ProfileService();

  // Getters
  Profile? get profile => _profile;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get hasProfile => _profile != null;

  /// Create a new user profile
  ///
  /// Requirements: 5.4
  Future<bool> createProfile({
    required String name,
    required String phone,
    required DateTime dateOfBirth,
    required String timeOfBirth,
    required String placeOfBirth,
    required String career,
    required String goals,
    required String challenges,
  }) async {
    _setLoading(true);
    _clearError();

    try {
      final profile = await _profileService.createProfile(
        name: name,
        phone: phone,
        dateOfBirth: dateOfBirth,
        timeOfBirth: timeOfBirth,
        placeOfBirth: placeOfBirth,
        career: career,
        goals: goals,
        challenges: challenges,
      );

      _profile = profile;
      notifyListeners();
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Update existing user profile
  ///
  /// Requirements: 5.4
  Future<bool> updateProfile({
    String? name,
    String? phone,
    DateTime? dateOfBirth,
    String? timeOfBirth,
    String? placeOfBirth,
    String? career,
    String? goals,
    String? challenges,
    Map<String, dynamic>? preferences,
  }) async {
    if (_profile == null) {
      _setError('No profile to update');
      return false;
    }

    _setLoading(true);
    _clearError();

    try {
      final updatedProfile = await _profileService.updateProfile(
        profileId: _profile!.id,
        name: name,
        phone: phone,
        dateOfBirth: dateOfBirth,
        timeOfBirth: timeOfBirth,
        placeOfBirth: placeOfBirth,
        career: career,
        goals: goals,
        challenges: challenges,
        preferences: preferences,
      );

      _profile = updatedProfile;
      notifyListeners();
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Load current user's profile
  Future<bool> loadProfile() async {
    _setLoading(true);
    _clearError();

    try {
      final profile = await _profileService.getCurrentProfile();
      _profile = profile;
      notifyListeners();
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Load profile by ID
  Future<bool> loadProfileById(String profileId) async {
    _setLoading(true);
    _clearError();

    try {
      final profile = await _profileService.getProfile(profileId);
      _profile = profile;
      notifyListeners();
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Update profile preferences
  Future<bool> updatePreferences(Map<String, dynamic> preferences) async {
    if (_profile == null) {
      _setError('No profile to update');
      return false;
    }

    _setLoading(true);
    _clearError();

    try {
      final updatedProfile = await _profileService.updatePreferences(
        profileId: _profile!.id,
        preferences: preferences,
      );

      _profile = updatedProfile;
      notifyListeners();
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Delete current profile
  Future<bool> deleteProfile() async {
    if (_profile == null) {
      _setError('No profile to delete');
      return false;
    }

    _setLoading(true);
    _clearError();

    try {
      await _profileService.deleteProfile(_profile!.id);
      _profile = null;
      notifyListeners();
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Clear profile data (on logout)
  void clearProfile() {
    _profile = null;
    _clearError();
    notifyListeners();
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
}
