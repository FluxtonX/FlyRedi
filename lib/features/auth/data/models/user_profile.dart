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

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'firebaseId': firebaseId,
      'email': email,
      'displayName': displayName,
      'phoneNumber': phoneNumber,
      'photoURL': photoURL,
      'role': role,
      'plan': plan,
      'notificationsEnabled': notificationsEnabled,
      'onboardingCompleted': onboardingCompleted,
      'settings': settings,
      'alertPreferences': alertPreferences,
    };
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

  bool get hasUnlimitedFlightMonitoring {
    return plan == 'Plus' || plan == 'Concierge Pass' || role == 'Admin';
  }

  UserProfile copyWith({
    String? id,
    String? firebaseId,
    String? email,
    String? displayName,
    String? phoneNumber,
    String? photoURL,
    String? role,
    String? plan,
    bool? notificationsEnabled,
    bool? onboardingCompleted,
    Map<String, dynamic>? settings,
    Map<String, dynamic>? alertPreferences,
  }) {
    return UserProfile(
      id: id ?? this.id,
      firebaseId: firebaseId ?? this.firebaseId,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      photoURL: photoURL ?? this.photoURL,
      role: role ?? this.role,
      plan: plan ?? this.plan,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      onboardingCompleted: onboardingCompleted ?? this.onboardingCompleted,
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

  // ── Monthly Usage Fields ──────────────────────────────────────────────────
  final int flightsMonitored;
  final int flightsMonitoredMax;
  final int claimsFiled;
  final int claimsFiledMax;
  final int aiComplaintLetters;
  final int aiComplaintLettersMax;
  final int aiAssistantQuestions;
  final int aiAssistantQuestionsMax;
  final int documentUploads;
  final int documentUploadsMax;

  ProfileStats({
    required this.savedTrips,
    required this.caseVaultItems,
    required this.savedCases,
    required this.academyClasses,
    required this.conciergeActive,
    this.flightsMonitored = 0,
    this.flightsMonitoredMax = 2,
    this.claimsFiled = 0,
    this.claimsFiledMax = 1,
    this.aiComplaintLetters = 0,
    this.aiComplaintLettersMax = 1,
    this.aiAssistantQuestions = 0,
    this.aiAssistantQuestionsMax = 5,
    this.documentUploads = 0,
    this.documentUploadsMax = 5,
  });

  factory ProfileStats.fromJson(Map<String, dynamic> json) {
    return ProfileStats(
      savedTrips: json['savedTrips'] ?? 0,
      caseVaultItems: json['caseVaultItems'] ?? 0,
      savedCases: json['savedCases'] ?? 0,
      academyClasses: json['academyClasses'] ?? 0,
      conciergeActive: json['conciergeActive'] ?? false,
      flightsMonitored: json['flightsMonitored'] ?? json['savedTrips'] ?? 0,
      flightsMonitoredMax: json['flightsMonitoredMax'] ?? 2,
      claimsFiled: json['claimsFiled'] ?? json['savedCases'] ?? 0,
      claimsFiledMax: json['claimsFiledMax'] ?? 1,
      aiComplaintLetters: json['aiComplaintLetters'] ?? 0,
      aiComplaintLettersMax: json['aiComplaintLettersMax'] ?? 1,
      aiAssistantQuestions: json['aiAssistantQuestions'] ?? 0,
      aiAssistantQuestionsMax: json['aiAssistantQuestionsMax'] ?? 5,
      documentUploads: json['documentUploads'] ?? json['caseVaultItems'] ?? 0,
      documentUploadsMax: json['documentUploadsMax'] ?? 5,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'savedTrips': savedTrips,
      'caseVaultItems': caseVaultItems,
      'savedCases': savedCases,
      'academyClasses': academyClasses,
      'conciergeActive': conciergeActive,
      'flightsMonitored': flightsMonitored,
      'flightsMonitoredMax': flightsMonitoredMax,
      'claimsFiled': claimsFiled,
      'claimsFiledMax': claimsFiledMax,
      'aiComplaintLetters': aiComplaintLetters,
      'aiComplaintLettersMax': aiComplaintLettersMax,
      'aiAssistantQuestions': aiAssistantQuestions,
      'aiAssistantQuestionsMax': aiAssistantQuestionsMax,
      'documentUploads': documentUploads,
      'documentUploadsMax': documentUploadsMax,
    };
  }
}
