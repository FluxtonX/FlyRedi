import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../shared/services/api_service.dart';

class OnboardingRepository {
  Future<bool> getOnboardingStatus() async {
    try {
      final http.Response response =
          await ApiService.get('/api/auth/onboarding');
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['onboardingCompleted'] == true;
      }
      return false;
    } catch (_) {
      return false;
    }
  }

  Future<void> completeOnboarding({
    String? role,
    bool? notificationsEnabled,
    String? displayName,
  }) async {
    final body = {
      if (role != null) 'role': role,
      if (notificationsEnabled != null) 'notificationsEnabled': notificationsEnabled,
      if (displayName != null) 'displayName': displayName,
    };

    final http.Response response =
        await ApiService.patch('/api/auth/onboarding', body: body);

    if (response.statusCode != 200) {
      throw Exception(
        'Failed to complete onboarding: ${response.statusCode} - ${response.body}',
      );
    }
  }
}
