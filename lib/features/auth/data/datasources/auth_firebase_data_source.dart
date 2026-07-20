import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../../../../core/constants/firestore_constants.dart';
import '../../../../core/logging/app_logger.dart';
import '../models/user_profile.dart';
import '../models/login_request.dart';
import '../models/register_request.dart';
import '../models/forgot_password_request.dart';

/// Remote data source backed entirely by Firebase (Auth + Firestore).
/// Replaces the old REST-based [AuthRemoteDataSource].
class AuthFirebaseDataSource {
  final fb.FirebaseAuth _auth = fb.FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // ── Login ──────────────────────────────────────────────────────────────────

  Future<UserProfile> login(LoginRequest request) async {
    AppLogger.auth('login attempt: ${request.email}');

    final credential = await _auth.signInWithEmailAndPassword(
      email: request.email.trim(),
      password: request.password,
    );

    final user = credential.user;
    if (user == null) throw Exception('Login failed: Firebase user is null.');

    AppLogger.auth('Firebase sign-in success uid=${user.uid}');
    return await _fetchOrCreateProfile(user);
  }

  // ── Register ───────────────────────────────────────────────────────────────

  Future<UserProfile> register(RegisterRequest request) async {
    AppLogger.auth('register attempt: ${request.email}');

    final credential = await _auth.createUserWithEmailAndPassword(
      email: request.email.trim(),
      password: request.password,
    );

    final user = credential.user;
    if (user == null) throw Exception('Registration failed: Firebase user is null.');

    await user.updateDisplayName(request.displayName.trim());
    AppLogger.auth('Firebase register success uid=${user.uid}');

    return await _createProfile(user, displayName: request.displayName.trim());
  }

  // ── Forgot Password ────────────────────────────────────────────────────────

  Future<void> forgotPassword(ForgotPasswordRequest request) async {
    AppLogger.auth('password reset email → ${request.email}');
    await _auth.sendPasswordResetEmail(email: request.email.trim());
    AppLogger.auth('password reset email sent');
  }

  // ── Sign Out ───────────────────────────────────────────────────────────────

  Future<void> logout() async {
    AppLogger.auth('signing out uid=${_auth.currentUser?.uid}');
    await GoogleSignIn().signOut();
    await _auth.signOut();
    AppLogger.auth('signed out');
  }

  // ── Google Sign-In ─────────────────────────────────────────────────────────

  Future<UserProfile> signInWithGoogle() async {
    AppLogger.auth('Google sign-in started');

    final googleUser = await GoogleSignIn().signIn();
    if (googleUser == null) throw Exception('Google sign-in cancelled.');

    final googleAuth = await googleUser.authentication;
    final credential = fb.GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    final userCredential = await _auth.signInWithCredential(credential);
    final user = userCredential.user;
    if (user == null) throw Exception('Google sign-in failed: Firebase user is null.');

    AppLogger.auth('Google sign-in success uid=${user.uid}');
    return await _fetchOrCreateProfile(user);
  }

  // ── Profile ────────────────────────────────────────────────────────────────

  Future<UserProfile> getProfile() async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) throw Exception('Not authenticated.');

    AppLogger.firestore('READ', '${FirestoreConstants.usersCollection}/$uid');

    final doc = await _db
        .collection(FirestoreConstants.usersCollection)
        .doc(uid)
        .get();

    if (!doc.exists || doc.data() == null) {
      // Profile missing — recreate from Firebase Auth user data
      final fbUser = _auth.currentUser!;
      return await _createProfile(fbUser);
    }

    AppLogger.firestoreResponse('${FirestoreConstants.usersCollection}/$uid');
    return UserProfile.fromJson({'id': uid, ...doc.data()!});
  }

  Future<UserProfile> updateProfile({
    String? displayName,
    String? phoneNumber,
    String? plan,
  }) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) throw Exception('Not authenticated.');

    final updates = <String, dynamic>{
      FirestoreConstants.fieldUpdatedAt: FieldValue.serverTimestamp(),
      if (displayName != null) FirestoreConstants.fieldDisplayName: displayName,
      if (phoneNumber != null) FirestoreConstants.fieldPhoneNumber: phoneNumber,
      if (plan != null) 'plan': plan,
    };

    AppLogger.firestore('UPDATE', '${FirestoreConstants.usersCollection}/$uid');
    await _db
        .collection(FirestoreConstants.usersCollection)
        .doc(uid)
        .update(updates);

    if (displayName != null) {
      await _auth.currentUser?.updateDisplayName(displayName);
    }

    return await getProfile();
  }

  Future<void> updateNotifications({required bool enabled}) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) throw Exception('Not authenticated.');

    AppLogger.firestore('UPDATE notifications', '${FirestoreConstants.usersCollection}/$uid');
    await _db
        .collection(FirestoreConstants.usersCollection)
        .doc(uid)
        .update({
      FirestoreConstants.fieldNotificationsEnabled: enabled,
      FirestoreConstants.fieldUpdatedAt: FieldValue.serverTimestamp(),
    });
  }

  Future<void> updateSettings(Map<String, dynamic> settings) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) throw Exception('Not authenticated.');

    AppLogger.firestore('UPDATE settings', '${FirestoreConstants.usersCollection}/$uid');
    await _db
        .collection(FirestoreConstants.usersCollection)
        .doc(uid)
        .update({
      FirestoreConstants.fieldSettings: settings,
      FirestoreConstants.fieldUpdatedAt: FieldValue.serverTimestamp(),
    });
  }

  // ── FCM Token ──────────────────────────────────────────────────────────────

  Future<void> updateFcmToken(String token) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return;

    AppLogger.fcm('Saving FCM token for uid=$uid');
    await _db
        .collection(FirestoreConstants.usersCollection)
        .doc(uid)
        .update({
      FirestoreConstants.fieldFcmToken: token,
      FirestoreConstants.fieldUpdatedAt: FieldValue.serverTimestamp(),
    });
    AppLogger.fcm('FCM token saved');
  }

  // ── Onboarding ────────────────────────────────────────────────────────────

  Future<void> completeOnboarding({
    String? role,
    bool? notificationsEnabled,
    String? displayName,
  }) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) throw Exception('Not authenticated.');

    final updates = <String, dynamic>{
      FirestoreConstants.fieldOnboardingCompleted: true,
      FirestoreConstants.fieldUpdatedAt: FieldValue.serverTimestamp(),
      if (role != null) FirestoreConstants.fieldRole: role,
      if (notificationsEnabled != null)
        FirestoreConstants.fieldNotificationsEnabled: notificationsEnabled,
      if (displayName != null) FirestoreConstants.fieldDisplayName: displayName,
    };

    AppLogger.firestore('UPDATE onboarding', '${FirestoreConstants.usersCollection}/$uid');
    await _db
        .collection(FirestoreConstants.usersCollection)
        .doc(uid)
        .update(updates);

    if (displayName != null) {
      await _auth.currentUser?.updateDisplayName(displayName);
    }
  }

  // ── Delete Account ─────────────────────────────────────────────────────────

  Future<void> deleteAccount() async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) throw Exception('Not authenticated.');

    AppLogger.auth('deleting account uid=$uid');

    // Delete all subcollections then the user document
    final batch = _db.batch();
    final userRef = _db.collection(FirestoreConstants.usersCollection).doc(uid);

    for (final sub in [
      FirestoreConstants.tripsCollection,
      FirestoreConstants.alertsCollection,
      FirestoreConstants.claimsCollection,
      FirestoreConstants.activityCollection,
    ]) {
      final snaps = await userRef.collection(sub).get();
      for (final doc in snaps.docs) {
        batch.delete(doc.reference);
      }
    }
    batch.delete(userRef);
    await batch.commit();

    await _auth.currentUser?.delete();
    AppLogger.auth('account deleted uid=$uid');
  }

  // ── Setup FCM on login ─────────────────────────────────────────────────────

  Future<void> setupFirebaseMessaging() async {
    try {
      final messaging = FirebaseMessaging.instance;
      final settings = await messaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );

      if (settings.authorizationStatus == AuthorizationStatus.authorized ||
          settings.authorizationStatus == AuthorizationStatus.provisional) {
        final token = await messaging.getToken();
        if (token != null) {
          AppLogger.fcm('FCM token obtained');
          await updateFcmToken(token);
        }
      }
    } catch (e) {
      AppLogger.error('AuthFirebaseDataSource.setupFirebaseMessaging', e);
    }
  }

  // ── Private helpers ────────────────────────────────────────────────────────

  /// Fetches the Firestore profile for [user], or creates it if missing.
  Future<UserProfile> _fetchOrCreateProfile(fb.User user) async {
    AppLogger.firestore(
      'READ',
      '${FirestoreConstants.usersCollection}/${user.uid}',
    );

    final doc = await _db
        .collection(FirestoreConstants.usersCollection)
        .doc(user.uid)
        .get();

    if (doc.exists && doc.data() != null) {
      AppLogger.firestoreResponse(
        '${FirestoreConstants.usersCollection}/${user.uid}',
        info: 'profile found',
      );
      return UserProfile.fromJson({'id': user.uid, ...doc.data()!});
    }

    AppLogger.auth('no Firestore profile found — creating');
    return await _createProfile(user);
  }

  /// Creates a default profile document in Firestore for [user].
  Future<UserProfile> _createProfile(
    fb.User user, {
    String? displayName,
  }) async {
    final name = displayName ??
        user.displayName ??
        user.email?.split('@').first ??
        'User';

    final profile = UserProfile(
      id: user.uid,
      firebaseId: user.uid,
      email: user.email ?? '',
      displayName: name,
      phoneNumber: user.phoneNumber ?? '',
      photoURL: user.photoURL ?? '',
      role: 'Traveller',
      plan: 'Free',
      notificationsEnabled: true,
      onboardingCompleted: false,
      settings: {},
      alertPreferences: {},
    );

    final data = profile.toJson()
      ..remove('id')
      ..addAll({
        FirestoreConstants.fieldCreatedAt: FieldValue.serverTimestamp(),
        FirestoreConstants.fieldUpdatedAt: FieldValue.serverTimestamp(),
      });

    AppLogger.firestore(
      'CREATE',
      '${FirestoreConstants.usersCollection}/${user.uid}',
    );

    await _db
        .collection(FirestoreConstants.usersCollection)
        .doc(user.uid)
        .set(data);

    AppLogger.auth('Firestore profile created for uid=${user.uid}');
    return profile;
  }
}
