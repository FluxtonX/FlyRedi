import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:get/get.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../data/datasources/auth_local_data_source.dart';
import '../../data/models/login_request.dart';
import '../../data/models/register_request.dart';
import '../../data/models/forgot_password_request.dart';
import '../../data/models/user_profile.dart';
import '../../../../core/utils/error_handler.dart';

class AuthController extends GetxController {
  final AuthRepository _authRepository;
  final AuthLocalDataSource _localDataSource;

  AuthController({
    required AuthRepository authRepository,
    required AuthLocalDataSource localDataSource,
  })  : _authRepository = authRepository,
        _localDataSource = localDataSource;

  final Rxn<UserProfile> userProfile = Rxn<UserProfile>();
  final RxBool isLoading = false.obs;
  final RxnString errorMessage = RxnString();
  bool _isEndingExpiredSession = false;

  bool get isAuthenticated => userProfile.value != null;

  @override
  void onInit() {
    super.onInit();
    autoLogin();
  }

  Future<void> autoLogin() async {
    try {
      if (_localDataSource.isLoggedIn()) {
        final cachedUser = _localDataSource.getUser();
        if (cachedUser != null) {
          userProfile.value = cachedUser;
          // Asynchronously fetch fresh profile details in background
          refreshProfile();
          _setupFirebaseMessaging();
        }
      }
    } catch (_) {
      // Silent catch on autologin loading
    }
  }

  Future<bool> login(String email, String password) async {
    isLoading.value = true;
    errorMessage.value = null;

    try {
      final response = await _authRepository.login(
        LoginRequest(email: email, password: password),
      );
      userProfile.value = response.user;
      isLoading.value = false;

      _setupFirebaseMessaging();
      Get.offAllNamed('/home');
      return true;
    } catch (e) {
      isLoading.value = false;
      final parsedError = ErrorHandler.handle(e);
      errorMessage.value = parsedError;
      _showErrorSnackBar(parsedError);
      return false;
    }
  }

  Future<bool> register(String name, String email, String password) async {
    isLoading.value = true;
    errorMessage.value = null;

    try {
      final response = await _authRepository.register(
        RegisterRequest(displayName: name, email: email, password: password),
      );
      userProfile.value = response.user;
      isLoading.value = false;

      _setupFirebaseMessaging();
      _showSuccessSnackBar('Account created successfully!');
      await Future.delayed(const Duration(milliseconds: 700));
      Get.offAllNamed('/home');
      return true;
    } catch (e) {
      isLoading.value = false;
      final parsedError = ErrorHandler.handle(e);
      errorMessage.value = parsedError;
      _showErrorSnackBar(parsedError);
      return false;
    }
  }

  Future<bool> forgotPassword(String email) async {
    isLoading.value = true;
    errorMessage.value = null;

    try {
      await _authRepository.forgotPassword(
        ForgotPasswordRequest(email: email),
      );
      isLoading.value = false;
      _showSuccessSnackBar('Reset password link sent successfully!');
      return true;
    } catch (e) {
      isLoading.value = false;
      final parsedError = ErrorHandler.handle(e);
      errorMessage.value = parsedError;
      _showErrorSnackBar(parsedError);
      return false;
    }
  }

  Future<void> refreshProfile() async {
    try {
      final profile = await _authRepository.getProfile();
      userProfile.value = profile;
    } catch (e) {
      // Let global interceptor handle errors
    }
  }

  Future<void> updateProfileState(UserProfile profile) async {
    userProfile.value = profile;
    await _localDataSource.saveUser(profile);
  }

  Future<void> logout() async {
    isLoading.value = true;
    try {
      await _authRepository.logout();
    } catch (_) {
      await _localDataSource.clearSession();
    } finally {
      userProfile.value = null;
      isLoading.value = false;
      Get.offAllNamed('/login');
    }
  }

  Future<void> _setupFirebaseMessaging() async {
    try {
      FirebaseMessaging messaging = FirebaseMessaging.instance;
      NotificationSettings settings = await messaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );

      if (settings.authorizationStatus == AuthorizationStatus.authorized ||
          settings.authorizationStatus == AuthorizationStatus.provisional) {
        String? token = await messaging.getToken();
        if (token != null) {
          print('\n\n================================= FCM TOKEN =================================');
          print(token);
          print('=============================================================================\n\n');
          debugPrint('FCM Token: $token');
          await _authRepository.updateFcmToken(token);
        }
      }
    } catch (e) {
      debugPrint('Error setting up Firebase Messaging: $e');
    }
  }

  Future<void> handleSessionExpired() async {
    if (_isEndingExpiredSession) return;
    _isEndingExpiredSession = true;

    try {
      await FirebaseAuth.instance.signOut();
    } catch (_) {}

    try {
      await _localDataSource.clearSession();
    } catch (_) {}

    userProfile.value = null;
    isLoading.value = false;

    if (Get.currentRoute != '/login') {
      Get.offAllNamed('/login');
      Get.snackbar(
        'Session expired',
        'Please sign in again.',
        snackPosition: SnackPosition.BOTTOM,
        
        colorText: Colors.white,
        margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        borderRadius: 12,
        duration: const Duration(seconds: 3),
        icon: Icon(Icons.error_outline_rounded, color: Colors.white),
      );
    }

    _isEndingExpiredSession = false;
  }

  void _showErrorSnackBar(String message) {
    Get.snackbar(
      'Error',
      message,
      snackPosition: SnackPosition.BOTTOM,
      
      colorText: Colors.white,
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      borderRadius: 12,
      duration: const Duration(seconds: 3),
      icon: Icon(Icons.error_outline_rounded, color: Colors.white),
    );
  }

  void _showSuccessSnackBar(String message) {
    Get.snackbar(
      'Success',
      message,
      snackPosition: SnackPosition.BOTTOM,
      
      colorText: Colors.white,
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      borderRadius: 12,
      duration: const Duration(seconds: 3),
      icon: Icon(Icons.check_circle_outline_rounded, color: Colors.white),
    );
  }
}
