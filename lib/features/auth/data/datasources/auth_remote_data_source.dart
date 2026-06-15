import 'package:firebase_auth/firebase_auth.dart' as firebase;
import '../../../../core/network/dio_client.dart';
import '../../../../core/constants/api_constants.dart';
import '../models/login_request.dart';
import '../models/register_request.dart';
import '../models/forgot_password_request.dart';
import '../models/user_profile.dart';
import '../models/auth_response.dart';

class AuthRemoteDataSource {
  final firebase.FirebaseAuth _firebaseAuth = firebase.FirebaseAuth.instance;
  final DioClient _dioClient;

  AuthRemoteDataSource({required DioClient dioClient}) : _dioClient = dioClient;

  Future<AuthResponse> login(LoginRequest request) async {
    // 1. Authenticate with Firebase
    final credential = await _firebaseAuth.signInWithEmailAndPassword(
      email: request.email.trim(),
      password: request.password,
    );

    final firebaseUser = credential.user;
    if (firebaseUser == null) {
      throw Exception('Login failed. Firebase user is null.');
    }

    // 2. Fetch Firebase ID token
    final idToken = await firebaseUser.getIdToken() ?? '';
    final refreshToken = firebaseUser.refreshToken;

    // 3. Sync token with Next.js/Express backend
    final response = await _dioClient.post(ApiConstants.syncUser);
    
    if (response.statusCode == 200) {
      final profile = UserProfile.fromJson(response.data);
      return AuthResponse(
        accessToken: idToken,
        refreshToken: refreshToken,
        userId: profile.id,
        user: profile,
      );
    } else {
      throw Exception('Failed to sync profile with server: ${response.statusCode}');
    }
  }

  Future<AuthResponse> register(RegisterRequest request) async {
    // 1. Create account on Firebase
    final credential = await _firebaseAuth.createUserWithEmailAndPassword(
      email: request.email.trim(),
      password: request.password,
    );

    final firebaseUser = credential.user;
    if (firebaseUser == null) {
      throw Exception('Registration failed. Firebase user is null.');
    }

    // 2. Update display name in Firebase profile
    await firebaseUser.updateDisplayName(request.displayName.trim());

    // 3. Get JWT token
    final idToken = await firebaseUser.getIdToken() ?? '';
    final refreshToken = firebaseUser.refreshToken;

    // 4. Create profile in Express backend
    final response = await _dioClient.post(ApiConstants.syncUser);

    if (response.statusCode == 200) {
      final profile = UserProfile.fromJson(response.data);
      return AuthResponse(
        accessToken: idToken,
        refreshToken: refreshToken,
        userId: profile.id,
        user: profile,
      );
    } else {
      throw Exception('Failed to sync profile on register: ${response.statusCode}');
    }
  }

  Future<void> forgotPassword(ForgotPasswordRequest request) async {
    await _firebaseAuth.sendPasswordResetEmail(email: request.email.trim());
  }

  Future<void> logout() async {
    await _firebaseAuth.signOut();
  }

  Future<UserProfile> getProfile() async {
    final response = await _dioClient.get(ApiConstants.profile);
    if (response.statusCode == 200) {
      return UserProfile.fromJson(response.data);
    } else {
      throw Exception('Failed to fetch user profile: ${response.statusCode}');
    }
  }
}
