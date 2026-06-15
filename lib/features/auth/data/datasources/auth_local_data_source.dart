import '../../../../core/storage/storage_service.dart';
import '../models/user_profile.dart';

class AuthLocalDataSource {
  final StorageService _storageService;

  AuthLocalDataSource({required StorageService storageService})
      : _storageService = storageService;

  Future<void> saveToken(String token, {String? refreshToken}) async {
    await _storageService.saveToken(token, refreshToken: refreshToken);
  }

  String? getToken() {
    return _storageService.getToken();
  }

  String? getRefreshToken() {
    return _storageService.getRefreshToken();
  }

  Future<void> saveUser(UserProfile user) async {
    await _storageService.saveUser(user);
  }

  UserProfile? getUser() {
    return _storageService.getUser();
  }

  String? getUserId() {
    return _storageService.getUserId();
  }

  bool isLoggedIn() {
    return _storageService.isLoggedIn();
  }

  Future<void> clearSession() async {
    await _storageService.clearAll();
  }
}
