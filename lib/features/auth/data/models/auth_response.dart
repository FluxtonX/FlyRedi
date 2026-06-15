import 'user_profile.dart';

class AuthResponse {
  final String accessToken;
  final String? refreshToken;
  final String userId;
  final UserProfile user;

  AuthResponse({
    required this.accessToken,
    this.refreshToken,
    required this.userId,
    required this.user,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    return AuthResponse(
      accessToken: json['accessToken'] ?? '',
      refreshToken: json['refreshToken'],
      userId: json['userId'] ?? '',
      user: UserProfile.fromJson(json['user'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'accessToken': accessToken,
      'refreshToken': refreshToken,
      'userId': userId,
      'user': user.toJson(),
    };
  }
}
