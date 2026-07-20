import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/logging/app_logger.dart';
import '../../../auth/data/datasources/auth_firebase_data_source.dart';



class OnboardingProvider extends ChangeNotifier {
  final AuthFirebaseDataSource _authDataSource;

  static const String _localOnboardingCompletedKey = 'local_onboarding_completed';

  OnboardingProvider(this._authDataSource);

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  Future<bool> getLocalOnboardingStatus() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_localOnboardingCompletedKey) ?? false;
  }

  Future<void> completeOnboarding({
    required String role,
    required bool notificationsEnabled,
    required String displayName,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      // 1. Save locally
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_localOnboardingCompletedKey, true);
      AppLogger.info('Onboarding local completion set');

      // 2. Save remotely
      await _authDataSource.completeOnboarding(
        role: role,
        notificationsEnabled: notificationsEnabled,
        displayName: displayName,
      );
      AppLogger.info('Onboarding remote completion set');
    } catch (e) {
      AppLogger.error('OnboardingProvider.completeOnboarding', e);
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> completeLocalOnly() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_localOnboardingCompletedKey, true);
    AppLogger.info('Onboarding local-only completion set');
  }
}
