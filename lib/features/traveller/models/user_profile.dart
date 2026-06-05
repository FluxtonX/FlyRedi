class UserProfile {
  final String id;
  final String firebaseId;
  final String email;
  final String displayName;
  final String phoneNumber;
  final String photoURL;
  final String role;
  final String plan;
  final bool notificationsEnabled;
  final bool onboardingCompleted;
  final Map<String, dynamic> settings;
  final Map<String, dynamic> alertPreferences;

  UserProfile({
    required this.id,
    required this.firebaseId,
    required this.email,
    required this.displayName,
    required this.phoneNumber,
    required this.photoURL,
    required this.role,
    required this.plan,
    required this.notificationsEnabled,
    required this.onboardingCompleted,
    required this.settings,
    required this.alertPreferences,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id'] ?? '',
      firebaseId: json['firebaseId'] ?? '',
      email: json['email'] ?? '',
      displayName: json['displayName'] ?? '',
      phoneNumber: json['phoneNumber'] ?? '',
      photoURL: json['photoURL'] ?? '',
      role: json['role'] ?? 'User',
      plan: json['plan'] ?? 'Free',
      notificationsEnabled: json['notificationsEnabled'] ?? true,
      onboardingCompleted: json['onboardingCompleted'] ?? false,
      settings: Map<String, dynamic>.from(json['settings'] ?? {}),
      alertPreferences: Map<String, dynamic>.from(json['alertPreferences'] ?? {}),
    );
  }

  String get initials {
    final parts = displayName.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
    }
    if (displayName.isNotEmpty) return displayName[0].toUpperCase();
    if (email.isNotEmpty) return email[0].toUpperCase();
    return '?';
  }

  UserProfile copyWith({
    String? displayName,
    String? phoneNumber,
    String? photoURL,
    bool? notificationsEnabled,
    Map<String, dynamic>? settings,
    Map<String, dynamic>? alertPreferences,
  }) {
    return UserProfile(
      id: id,
      firebaseId: firebaseId,
      email: email,
      displayName: displayName ?? this.displayName,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      photoURL: photoURL ?? this.photoURL,
      role: role,
      plan: plan,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      onboardingCompleted: onboardingCompleted,
      settings: settings ?? this.settings,
      alertPreferences: alertPreferences ?? this.alertPreferences,
    );
  }
}

class ProfileStats {
  final int savedTrips;
  final int caseVaultItems;
  final int savedCases;
  final int academyClasses;
  final bool conciergeActive;

  ProfileStats({
    required this.savedTrips,
    required this.caseVaultItems,
    required this.savedCases,
    required this.academyClasses,
    required this.conciergeActive,
  });

  factory ProfileStats.fromJson(Map<String, dynamic> json) {
    return ProfileStats(
      savedTrips: json['savedTrips'] ?? 0,
      caseVaultItems: json['caseVaultItems'] ?? 0,
      savedCases: json['savedCases'] ?? 0,
      academyClasses: json['academyClasses'] ?? 0,
      conciergeActive: json['conciergeActive'] ?? false,
    );
  }
}
