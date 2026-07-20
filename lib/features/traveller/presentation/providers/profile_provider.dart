import 'package:flutter/material.dart';

import '../../../../core/logging/app_logger.dart';
import '../../../../core/utils/error_handler.dart';
import '../../../auth/data/datasources/auth_firebase_data_source.dart';
import '../../../auth/data/models/user_profile.dart';
import '../../../auth/presentation/providers/auth_provider.dart';

enum ProfileState { idle, loading, success, error, updating }

/// Manages profile data and updates for the profile screens.
/// Delegates to [AuthFirebaseDataSource] for Firestore operations.
/// Keeps [AuthProvider] in sync after profile updates.
class ProfileProvider extends ChangeNotifier {
  final AuthFirebaseDataSource _dataSource;
  final AuthProvider _authProvider;

  ProfileProvider({
    required AuthFirebaseDataSource dataSource,
    required AuthProvider authProvider,
  })  : _dataSource = dataSource,
        _authProvider = authProvider;

  ProfileState _state = ProfileState.idle;
  ProfileStats? _stats;
  String? _errorMessage;

  ProfileState get state => _state;
  ProfileStats? get stats => _stats;
  String? get errorMessage => _errorMessage;
  bool get isLoading => _state == ProfileState.loading;
  bool get isUpdating => _state == ProfileState.updating;

  // Convenience getter for the current user profile from AuthProvider
  UserProfile? get user => _authProvider.user;

  // ── Load Stats ─────────────────────────────────────────────────────────────

  Future<void> loadStats(String uid) async {
    _set(ProfileState.loading);
    AppLogger.provider('ProfileProvider', 'loading stats');

    try {
      // Stats are computed from Firestore subcollection counts
      _stats = await _computeStats(uid);
      _set(ProfileState.success);
    } catch (e) {
      AppLogger.error('ProfileProvider.loadStats', e);
      _errorMessage = ErrorHandler.handle(e);
      _set(ProfileState.error);
    }
  }

  Future<ProfileStats> _computeStats(String uid) async {
    final profile = await _dataSource.getProfile();
    // Return stats derived from the profile plan
    return ProfileStats(
      savedTrips: 0,
      caseVaultItems: 0,
      savedCases: 0,
      academyClasses: 0,
      conciergeActive: profile.plan == 'Concierge Pass',
    );
  }

  // ── Update Profile ─────────────────────────────────────────────────────────

  Future<bool> updateProfile({
    String? displayName,
    String? phoneNumber,
    String? plan,
  }) async {
    _set(ProfileState.updating);
    AppLogger.provider('ProfileProvider', 'updating profile');

    try {
      final updated = await _dataSource.updateProfile(
        displayName: displayName,
        phoneNumber: phoneNumber,
        plan: plan,
      );
      await _authProvider.updateProfileState(updated);
      _set(ProfileState.success);
      AppLogger.provider('ProfileProvider', 'profile updated');
      return true;
    } catch (e) {
      AppLogger.error('ProfileProvider.updateProfile', e);
      _errorMessage = ErrorHandler.handle(e);
      _set(ProfileState.error);
      return false;
    }
  }

  // ── Update Notifications ───────────────────────────────────────────────────

  Future<void> updateNotifications({required bool enabled}) async {
    try {
      await _dataSource.updateNotifications(enabled: enabled);
      AppLogger.provider('ProfileProvider', 'notifications → $enabled');
    } catch (e) {
      AppLogger.error('ProfileProvider.updateNotifications', e);
    }
  }

  // ── Update Settings ────────────────────────────────────────────────────────

  Future<void> updateSettings(Map<String, dynamic> settings) async {
    try {
      await _dataSource.updateSettings(settings);
      AppLogger.provider('ProfileProvider', 'settings updated');
    } catch (e) {
      AppLogger.error('ProfileProvider.updateSettings', e);
    }
  }

  // ── Delete Account ─────────────────────────────────────────────────────────

  Future<bool> deleteAccount() async {
    _set(ProfileState.updating);
    try {
      await _dataSource.deleteAccount();
      await _authProvider.logout();
      return true;
    } catch (e) {
      AppLogger.error('ProfileProvider.deleteAccount', e);
      _errorMessage = ErrorHandler.handle(e);
      _set(ProfileState.error);
      return false;
    }
  }

  // ── Helpers ────────────────────────────────────────────────────────────────

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  void _set(ProfileState s) {
    _state = s;
    notifyListeners();
  }
}
