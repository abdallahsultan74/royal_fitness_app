import 'package:supabase_flutter/supabase_flutter.dart';

import '../domain/user_profile.dart';

class ProfileRepository {
  ProfileRepository();

  SupabaseClient get _client => Supabase.instance.client;
  User get _user => _client.auth.currentUser!;

  double? _toDouble(dynamic value) {
    if (value == null) return null;
    return (value as num?)?.toDouble() ?? double.tryParse(value.toString());
  }

  Stream<UserProfile> watchProfile() {
    final uid = _user.id;
    final stream = _client
        .from('profiles')
        .stream(primaryKey: <String>['id']).eq('id', uid);
    return stream.map((rows) {
      final data = rows.isNotEmpty ? rows.first : <String, dynamic>{};
      return UserProfile(
        uid: uid,
        email: _user.email ?? (data['email']?.toString() ?? ''),
        name: data['name']?.toString() ??
            (_user.userMetadata?['name']?.toString() ?? 'User'),
        language: data['language']?.toString() ?? 'en',
        goal: data['goal']?.toString() ?? 'general_fitness',
        plan: data['plan']?.toString() ?? 'basic',
        photoUrl: data['photo_url']?.toString(),
        heightCm: _toDouble(data['height_cm']),
        currentWeightKg: _toDouble(data['current_weight_kg']),
        targetWeightKg: _toDouble(data['target_weight_kg']),
        bmi: _toDouble(data['bmi']),
        bmiStatus: data['bmi_status']?.toString(),
        lastWeightLogAt:
            DateTime.tryParse(data['last_weight_log_at']?.toString() ?? ''),
      );
    });
  }

  Future<void> upsertProfile({
    String? uid,
    String? email,
    String? name,
    String? language,
    String? goal,
    String? plan,
    String? photoUrl,
    double? heightCm,
    double? currentWeightKg,
    double? targetWeightKg,
    double? bmi,
    String? bmiStatus,
    bool includeCreatedAt = false,
  }) async {
    final data = <String, dynamic>{
      'id': uid ?? _user.id,
      'email': email ?? _user.email,
      if (name != null) 'name': name,
      if (language != null) 'language': language,
      if (goal != null) 'goal': goal,
      if (plan != null) 'plan': plan,
      if (photoUrl != null) 'photo_url': photoUrl,
      if (heightCm != null) 'height_cm': heightCm,
      if (currentWeightKg != null) 'current_weight_kg': currentWeightKg,
      if (targetWeightKg != null) 'target_weight_kg': targetWeightKg,
      if (bmi != null) 'bmi': bmi,
      if (bmiStatus != null) 'bmi_status': bmiStatus,
      if (includeCreatedAt) 'created_at': DateTime.now().toUtc().toIso8601String(),
      'updated_at': DateTime.now().toUtc().toIso8601String(),
    };
    await _client.from('profiles').upsert(data);
  }
}
