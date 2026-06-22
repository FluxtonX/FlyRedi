import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_data_source.dart';
import '../datasources/auth_local_data_source.dart';
import '../models/login_request.dart';
import '../models/register_request.dart';
import '../models/forgot_password_request.dart';
import '../models/user_profile.dart';
import '../models/auth_response.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource _remoteDataSource;
  final AuthLocalDataSource _localDataSource;

  AuthRepositoryImpl({
    required AuthRemoteDataSource remoteDataSource,
    required AuthLocalDataSource localDataSource,
  })  : _remoteDataSource = remoteDataSource,
        _localDataSource = localDataSource;

  @override
  Future<AuthResponse> login(LoginRequest request) async {
    final response = await _remoteDataSource.login(request);
    await _localDataSource.saveToken(response.accessToken, refreshToken: response.refreshToken);
    await _localDataSource.saveUser(response.user);
    return response;
  }

  @override
  Future<AuthResponse> register(RegisterRequest request) async {
    final response = await _remoteDataSource.register(request);
    await _localDataSource.saveToken(response.accessToken, refreshToken: response.refreshToken);
    await _localDataSource.saveUser(response.user);
    return response;
  }

  @override
  Future<void> forgotPassword(ForgotPasswordRequest request) async {
    await _remoteDataSource.forgotPassword(request);
  }

  @override
  Future<void> logout() async {
    await _remoteDataSource.logout();
    await _localDataSource.clearSession();
  }

  @override
  Future<UserProfile> getProfile() async {
    final userProfile = await _remoteDataSource.getProfile();
    await _localDataSource.saveUser(userProfile);
    return userProfile;
  }

  @override
  Future<void> updateFcmToken(String token) async {
    await _remoteDataSource.updateFcmToken(token);
  }
}
