import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../shared/services/api_service.dart';
import '../models/user_profile.dart';

class ProfileRepository {
  // GET /api/auth/profile
  Future<UserProfile> getProfile() async {
    final http.Response response = await ApiService.get('/api/auth/profile');
    if (response.statusCode == 200) {
      return UserProfile.fromJson(jsonDecode(response.body));
    }
    throw Exception('Failed to load profile: ${response.statusCode}');
  }

  // PUT /api/auth/profile
  Future<UserProfile> updateProfile({
    String? displayName,
    String? phoneNumber,
  }) async {
    final body = <String, dynamic>{};
    if (displayName != null) body['displayName'] = displayName;
    if (phoneNumber != null) body['phoneNumber'] = phoneNumber;

    final http.Response response =
        await ApiService.put('/api/auth/profile', body: body);
    if (response.statusCode == 200) {
      return UserProfile.fromJson(jsonDecode(response.body));
    }
    throw Exception(
      'Failed to update profile: ${response.statusCode} - ${response.body}',
    );
  }

  // GET /api/auth/profile/stats
  Future<ProfileStats> getStats() async {
    final http.Response response =
        await ApiService.get('/api/auth/profile/stats');
    if (response.statusCode == 200) {
      return ProfileStats.fromJson(jsonDecode(response.body));
    }
    throw Exception('Failed to load stats: ${response.statusCode}');
  }

  // PATCH /api/auth/profile/notifications
  Future<void> updateNotifications({required bool enabled}) async {
    final http.Response response = await ApiService.patch(
      '/api/auth/profile/notifications',
      body: {'notificationsEnabled': enabled},
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to update notifications: ${response.statusCode}');
    }
  }

  // PATCH /api/auth/profile/settings
  Future<void> updateSettings(Map<String, dynamic> settings) async {
    final http.Response response = await ApiService.patch(
      '/api/auth/profile/settings',
      body: {'settings': settings},
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to update settings: ${response.statusCode}');
    }
  }

  // DELETE /api/auth/account
  Future<void> deleteAccount() async {
    final http.Response response = await ApiService.delete('/api/auth/account');
    if (response.statusCode != 200) {
      throw Exception('Failed to delete account: ${response.statusCode}');
    }
  }
}
