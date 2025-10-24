import '../models/profile_model.dart';
import '../utils/constants.dart';
import 'api_service.dart';

/// Profile service for creating and updating user profiles
class ProfileService {
  final ApiService _apiService;

  ProfileService({ApiService? apiService})
      : _apiService = apiService ?? ApiService();

  /// Create a new user profile
  ///
  /// Requirements: 5.4
  Future<Profile> createProfile({
    required String name,
    required String phone,
    required DateTime dateOfBirth,
    required String timeOfBirth,
    required String placeOfBirth,
    required String career,
    required String goals,
    required String challenges,
  }) async {
    try {
      final response = await _apiService.post(
        AppConstants.profileEndpoint,
        data: {
          'name': name,
          'phone': phone,
          'dateOfBirth': dateOfBirth.toIso8601String(),
          'timeOfBirth': timeOfBirth,
          'placeOfBirth': placeOfBirth,
          'career': career,
          'goals': goals,
          'challenges': challenges,
        },
      );

      return Profile.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }

  /// Update existing user profile
  ///
  /// Requirements: 5.4
  Future<Profile> updateProfile({
    required String profileId,
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
    try {
      final data = <String, dynamic>{};

      if (name != null) data['name'] = name;
      if (phone != null) data['phone'] = phone;
      if (dateOfBirth != null)
        data['dateOfBirth'] = dateOfBirth.toIso8601String();
      if (timeOfBirth != null) data['timeOfBirth'] = timeOfBirth;
      if (placeOfBirth != null) data['placeOfBirth'] = placeOfBirth;
      if (career != null) data['career'] = career;
      if (goals != null) data['goals'] = goals;
      if (challenges != null) data['challenges'] = challenges;
      if (preferences != null) data['preferences'] = preferences;

      final response = await _apiService.put(
        '${AppConstants.profileEndpoint}/$profileId',
        data: data,
      );

      return Profile.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }

  /// Get user profile by ID
  Future<Profile> getProfile(String profileId) async {
    try {
      final response = await _apiService.get(
        '${AppConstants.profileEndpoint}/$profileId',
      );

      return Profile.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }

  /// Get current user's profile
  Future<Profile> getCurrentProfile() async {
    try {
      final response = await _apiService.get(
        '${AppConstants.profileEndpoint}/me',
      );

      return Profile.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }

  /// Delete user profile
  Future<void> deleteProfile(String profileId) async {
    try {
      await _apiService.delete(
        '${AppConstants.profileEndpoint}/$profileId',
      );
    } catch (e) {
      rethrow;
    }
  }

  /// Update profile preferences
  Future<Profile> updatePreferences({
    required String profileId,
    required Map<String, dynamic> preferences,
  }) async {
    try {
      final response = await _apiService.put(
        '${AppConstants.profileEndpoint}/$profileId/preferences',
        data: {'preferences': preferences},
      );

      return Profile.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }
}
