import '../../data/models/login_request.dart';
import '../../data/models/register_request.dart';
import '../../data/models/forgot_password_request.dart';
import '../../data/models/user_profile.dart';
import '../../data/models/auth_response.dart';

abstract class AuthRepository {
  Future<AuthResponse> login(LoginRequest request);
  Future<AuthResponse> register(RegisterRequest request);
  Future<void> forgotPassword(ForgotPasswordRequest request);
  Future<void> logout();
  Future<UserProfile> getProfile();
  Future<void> updateFcmToken(String token);
}
