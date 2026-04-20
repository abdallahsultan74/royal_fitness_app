import '../../features/profile/domain/user_profile.dart';

/// Subscription tiers that may receive coach-assigned plans and related RPC data.
bool isCoachContentPlanTier(String plan) {
  final p = plan.trim().toLowerCase();
  return p == 'pro' || p == 'premium' || p == 'royal' || p == 'elite';
}

/// Whether the user should see coach-assigned training plans / gated challenge enrollment.
bool hasActiveCoachContentAccess(UserProfile? profile) {
  if (profile == null) return false;
  if (!isCoachContentPlanTier(profile.plan)) return false;
  final exp = profile.planExpiresAt;
  if (exp != null && !exp.toUtc().isAfter(DateTime.now().toUtc())) {
    return false;
  }
  return true;
}

/// Per-user UI flags from [UserProfile.featureFlags]. When absent, [defaultWhenAllowed] applies.
bool coachFeatureEnabled(
  UserProfile? profile,
  String key, {
  bool defaultWhenAllowed = true,
}) {
  if (profile == null) return defaultWhenAllowed;
  if (!hasActiveCoachContentAccess(profile)) return false;
  final flags = profile.featureFlags;
  if (!flags.containsKey(key)) return defaultWhenAllowed;
  final v = flags[key];
  if (v is bool) return v;
  if (v is String) {
    final s = v.toLowerCase();
    if (s == 'false' || s == '0') return false;
    if (s == 'true' || s == '1') return true;
  }
  return defaultWhenAllowed;
}
