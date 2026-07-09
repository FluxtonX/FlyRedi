import 'package:flutter/foundation.dart';

class ApiConstants {
  static const String baseUrl = kReleaseMode
      ? 'https://skyright-backend.onrender.com'
      : 'http://10.0.2.2:3000'; // Use 'http://localhost:3000' for iOS / macOS and 'http://10.0.2.2:3000' for Android Emulator

  // Authentication Endpoints
  static const String syncUser = '/api/auth/sync';
  static const String profile = '/api/auth/profile';
  static const String stats = '/api/auth/profile/stats';
  static const String settings = '/api/auth/profile/settings';
  static const String notifications = '/api/auth/profile/notifications';
  static const String updateFcmToken = '/api/auth/fcm-token';
  static const String account = '/api/auth/account';

  // Flight Endpoints
  static const String flightStatus = '/api/flights/status';
  static const String flightLivePosition = '/api/flights/live-position';
}

