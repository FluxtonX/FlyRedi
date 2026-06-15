import 'package:flutter/material.dart';
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

  void _showErrorSnackBar(String message) {
    Get.snackbar(
      'Error',
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: const Color(0xFFE11D48),
      colorText: Colors.white,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      borderRadius: 12,
      duration: const Duration(seconds: 3),
      icon: const Icon(Icons.error_outline_rounded, color: Colors.white),
    );
  }

  void _showSuccessSnackBar(String message) {
    Get.snackbar(
      'Success',
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: const Color(0xFF10B981),
      colorText: Colors.white,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      borderRadius: 12,
      duration: const Duration(seconds: 3),
      icon: const Icon(Icons.check_circle_outline_rounded, color: Colors.white),
    );
  }
}
