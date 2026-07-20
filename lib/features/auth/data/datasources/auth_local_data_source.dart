import '../../../../core/storage/storage_service.dart';
import '../models/user_profile.dart';

/// Local data source for auth — persists user session to [StorageService].
/// Token caching removed: Firebase Auth SDK manages ID token lifecycle.
class AuthLocalDataSource {
  final StorageService _storageService;

  AuthLocalDataSource({required StorageService storageService})
      : _storageService = storageService;

  Future<void> saveUser(UserProfile user) async {
    await _storageService.saveUser(user);
  }

  UserProfile? getUser() => _storageService.getUser();

  String? getUserId() => _storageService.getUserId();

  bool isLoggedIn() => _storageService.isLoggedIn();

  Future<void> clearSession() async {
    await _storageService.clearAll();
  }
}
