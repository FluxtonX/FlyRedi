import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../../../core/logging/app_logger.dart';
import '../../../../core/utils/error_handler.dart';
import '../../data/datasources/auth_firebase_data_source.dart';
import '../../data/datasources/auth_local_data_source.dart';
import '../../data/models/login_request.dart';
import '../../data/models/register_request.dart';
import '../../data/models/forgot_password_request.dart';
import '../../data/models/user_profile.dart';

enum AuthState { idle, loading, success, error }

/// Replaces the old GetX [AuthController].
/// Manages authentication state throughout the app's lifetime.
class AuthProvider extends ChangeNotifier {
  final AuthFirebaseDataSource _remoteDataSource;
  final AuthLocalDataSource _localDataSource;

  AuthProvider({
    required AuthFirebaseDataSource remoteDataSource,
    required AuthLocalDataSource localDataSource,
  })  : _remoteDataSource = remoteDataSource,
        _localDataSource = localDataSource {
    _autoLogin();
  }

  AuthState _state = AuthState.idle;
  UserProfile? _user;
  String? _errorMessage;
  bool _isEndingExpiredSession = false;

  AuthState get state => _state;
  UserProfile? get user => _user;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _user != null;
  bool get isLoading => _state == AuthState.loading;

  // ── Auto Login ──────────────────────────────────────────────────────────────

  void _autoLogin() {
    try {
      if (_localDataSource.isLoggedIn()) {
        final cached = _localDataSource.getUser();
        if (cached != null) {
          _user = cached;
          AppLogger.auth('Auto-login: loaded cached profile uid=${cached.id}');
          // Silently refresh from Firestore in background
          _refreshProfile();
          _remoteDataSource.setupFirebaseMessaging();
          notifyListeners();
        }
      }
    } catch (e) {
      AppLogger.error('AuthProvider._autoLogin', e);
    }
  }

  // ── Login ───────────────────────────────────────────────────────────────────

  Future<bool> login(String email, String password) async {
    _setState(AuthState.loading);
    AppLogger.auth('login: $email');

    try {
      final profile = await _remoteDataSource.login(
        LoginRequest(email: email, password: password),
      );
      _user = profile;
      await _localDataSource.saveUser(profile);
      await _remoteDataSource.setupFirebaseMessaging();

      AppLogger.auth('login success uid=${profile.id}');
      _setState(AuthState.success);
      return true;
    } catch (e) {
      AppLogger.error('AuthProvider.login', e);
      _errorMessage = ErrorHandler.handle(e);
      _setState(AuthState.error);
      return false;
    }
  }

  // ── Register ────────────────────────────────────────────────────────────────

  Future<bool> register(String name, String email, String password) async {
    _setState(AuthState.loading);
    AppLogger.auth('register: $email');

    try {
      final profile = await _remoteDataSource.register(
        RegisterRequest(displayName: name, email: email, password: password),
      );
      _user = profile;
      await _localDataSource.saveUser(profile);
      await _remoteDataSource.setupFirebaseMessaging();

      AppLogger.auth('register success uid=${profile.id}');
      _setState(AuthState.success);
      return true;
    } catch (e) {
      AppLogger.error('AuthProvider.register', e);
      _errorMessage = ErrorHandler.handle(e);
      _setState(AuthState.error);
      return false;
    }
  }

  // ── Google Sign-In ──────────────────────────────────────────────────────────

  Future<bool> loginWithGoogle() async {
    _setState(AuthState.loading);
    AppLogger.auth('Google sign-in');

    try {
      final profile = await _remoteDataSource.signInWithGoogle();
      _user = profile;
      await _localDataSource.saveUser(profile);
      await _remoteDataSource.setupFirebaseMessaging();

      AppLogger.auth('Google sign-in success uid=${profile.id}');
      _setState(AuthState.success);
      return true;
    } catch (e) {
      AppLogger.error('AuthProvider.loginWithGoogle', e);
      _errorMessage = ErrorHandler.handle(e);
      _setState(AuthState.error);
      return false;
    }
  }

  // ── Forgot Password ─────────────────────────────────────────────────────────

  Future<bool> forgotPassword(String email) async {
    _setState(AuthState.loading);
    AppLogger.auth('forgot password: $email');

    try {
      await _remoteDataSource.forgotPassword(
        ForgotPasswordRequest(email: email),
      );
      AppLogger.auth('password reset email sent');
      _setState(AuthState.success);
      return true;
    } catch (e) {
      AppLogger.error('AuthProvider.forgotPassword', e);
      _errorMessage = ErrorHandler.handle(e);
      _setState(AuthState.error);
      return false;
    }
  }

  // ── Refresh Profile ─────────────────────────────────────────────────────────

  Future<void> _refreshProfile() async {
    try {
      final profile = await _remoteDataSource.getProfile();
      _user = profile;
      await _localDataSource.saveUser(profile);
      AppLogger.auth('profile refreshed uid=${profile.id}');
      notifyListeners();
    } catch (e) {
      AppLogger.error('AuthProvider._refreshProfile', e);
    }
  }

  Future<void> refreshProfile() => _refreshProfile();

  // ── Update Profile State ────────────────────────────────────────────────────

  Future<void> updateProfileState(UserProfile profile) async {
    _user = profile;
    await _localDataSource.saveUser(profile);
    notifyListeners();
  }

  // ── Logout ──────────────────────────────────────────────────────────────────

  Future<void> logout() async {
    _setState(AuthState.loading);
    AppLogger.auth('logout uid=${_user?.id}');

    try {
      await _remoteDataSource.logout();
    } catch (e) {
      AppLogger.error('AuthProvider.logout (remote)', e);
    }

    await _localDataSource.clearSession();
    _user = null;
    AppLogger.auth('logged out');
    _setState(AuthState.idle);
  }

  // ── Session Expired ─────────────────────────────────────────────────────────

  Future<void> handleSessionExpired() async {
    if (_isEndingExpiredSession) return;
    _isEndingExpiredSession = true;

    AppLogger.auth('session expired — forcing sign out');

    try {
      await FirebaseAuth.instance.signOut();
    } catch (_) {}

    await _localDataSource.clearSession();
    _user = null;
    _isEndingExpiredSession = false;
    notifyListeners();
  }

  // ── Helpers ─────────────────────────────────────────────────────────────────

  void clearError() {
    _errorMessage = null;
    if (_state == AuthState.error) _state = AuthState.idle;
    notifyListeners();
  }

  void _setState(AuthState s) {
    _state = s;
    AppLogger.provider('AuthProvider', s.name);
    notifyListeners();
  }
}
