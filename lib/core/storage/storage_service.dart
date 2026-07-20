import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../features/auth/data/models/user_profile.dart';

/// Local persistence layer backed by [SharedPreferences].
///
/// Initialized once in [main] before [runApp] via [StorageService.init].
/// Injected via Provider — no longer extends GetxService.
class StorageService {
  late final SharedPreferences _prefs;

  static const String _userIdKey = 'user_id';
  static const String _userProfileKey = 'user_profile';
  static const String _isLoggedInKey = 'is_logged_in';

  Future<StorageService> init() async {
    _prefs = await SharedPreferences.getInstance();
    return this;
  }

  // ── User Session ───────────────────────────────────────────────────────────

  Future<void> saveUser(UserProfile user) async {
    await _prefs.setString(_userProfileKey, jsonEncode(user.toJson()));
    await _prefs.setString(_userIdKey, user.id);
    await _prefs.setBool(_isLoggedInKey, true);
  }

  UserProfile? getUser() {
    final userJson = _prefs.getString(_userProfileKey);
    if (userJson == null) return null;
    try {
      return UserProfile.fromJson(jsonDecode(userJson));
    } catch (_) {
      return null;
    }
  }

  String? getUserId() => _prefs.getString(_userIdKey);

  bool isLoggedIn() => _prefs.getBool(_isLoggedInKey) ?? false;

  Future<void> clearAll() async {
    await _prefs.remove(_userIdKey);
    await _prefs.remove(_userProfileKey);
    await _prefs.setBool(_isLoggedInKey, false);
  }

  // ── Generic Cache ──────────────────────────────────────────────────────────
  // Used for lightweight caching (theme preference, dashboard cache, etc.)

  Future<void> saveCache(String key, dynamic data) async {
    await _prefs.setString(key, jsonEncode(data));
  }

  dynamic getCache(String key) {
    final str = _prefs.getString(key);
    if (str == null) return null;
    try {
      return jsonDecode(str);
    } catch (_) {
      return null;
    }
  }

  Future<void> removeCache(String key) async {
    await _prefs.remove(key);
  }
}
