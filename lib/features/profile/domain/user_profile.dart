class UserProfile {
  const UserProfile({
    required this.uid,
    required this.email,
    required this.name,
    required this.language,
    required this.goal,
    required this.plan,
    this.planExpiresAt,
    this.featureFlags = const <String, dynamic>{},
    this.photoUrl,
    this.whatsappPhone,
    this.heightCm,
    this.currentWeightKg,
    this.targetWeightKg,
    this.bmi,
    this.bmiStatus,
    this.lastWeightLogAt,
  });

  final String uid;
  final String email;
  final String name;
  final String language;
  final String goal;
  final String plan;
  final DateTime? planExpiresAt;
  /// Admin-tunable flags, e.g. `{ "admin_plans": true, "challenges": false }`.
  final Map<String, dynamic> featureFlags;
  final String? photoUrl;
  final String? whatsappPhone;
  final double? heightCm;
  final double? currentWeightKg;
  final double? targetWeightKg;
  final double? bmi;
  final String? bmiStatus;
  final DateTime? lastWeightLogAt;

  UserProfile copyWith({
    String? name,
    String? language,
    String? goal,
    String? plan,
    DateTime? planExpiresAt,
    Map<String, dynamic>? featureFlags,
    String? photoUrl,
    String? whatsappPhone,
    double? heightCm,
    double? currentWeightKg,
    double? targetWeightKg,
    double? bmi,
    String? bmiStatus,
    DateTime? lastWeightLogAt,
  }) {
    return UserProfile(
      uid: uid,
      email: email,
      name: name ?? this.name,
      language: language ?? this.language,
      goal: goal ?? this.goal,
      plan: plan ?? this.plan,
      planExpiresAt: planExpiresAt ?? this.planExpiresAt,
      featureFlags: featureFlags ?? this.featureFlags,
      photoUrl: photoUrl ?? this.photoUrl,
      whatsappPhone: whatsappPhone ?? this.whatsappPhone,
      heightCm: heightCm ?? this.heightCm,
      currentWeightKg: currentWeightKg ?? this.currentWeightKg,
      targetWeightKg: targetWeightKg ?? this.targetWeightKg,
      bmi: bmi ?? this.bmi,
      bmiStatus: bmiStatus ?? this.bmiStatus,
      lastWeightLogAt: lastWeightLogAt ?? this.lastWeightLogAt,
    );
  }
}
