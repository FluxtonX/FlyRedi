import 'dart:convert';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../features/auth/data/models/user_profile.dart';

class StorageService extends GetxService {
  late final SharedPreferences _prefs;

  static const String _accessTokenKey = 'access_token';
  static const String _refreshTokenKey = 'refresh_token';
  static const String _userIdKey = 'user_id';
  static const String _userProfileKey = 'user_profile';
  static const String _isLoggedInKey = 'is_logged_in';

  Future<StorageService> init() async {
    _prefs = await SharedPreferences.getInstance();
    return this;
  }

  Future<void> saveToken(String accessToken, {String? refreshToken}) async {
    await _prefs.setString(_accessTokenKey, accessToken);
    if (refreshToken != null) {
      await _prefs.setString(_refreshTokenKey, refreshToken);
    }
  }

  String? getToken() {
    return _prefs.getString(_accessTokenKey);
  }

  String? getRefreshToken() {
    return _prefs.getString(_refreshTokenKey);
  }

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
    } catch (e) {
      return null;
    }
  }

  String? getUserId() {
    return _prefs.getString(_userIdKey);
  }

  bool isLoggedIn() {
    return _prefs.getBool(_isLoggedInKey) ?? false;
  }

  Future<void> clearAll() async {
    await _prefs.remove(_accessTokenKey);
    await _prefs.remove(_refreshTokenKey);
    await _prefs.remove(_userIdKey);
    await _prefs.remove(_userProfileKey);
    await _prefs.setBool(_isLoggedInKey, false);
  }

  // --- Generic Caching Methods ---

  Future<void> saveCache(String key, dynamic data) async {
    await _prefs.setString(key, jsonEncode(data));
  }

  dynamic getCache(String key) {
    final str = _prefs.getString(key);
    if (str != null) {
      try {
        return jsonDecode(str);
      } catch (e) {
        return null;
      }
    }
    return null;
  }
}
