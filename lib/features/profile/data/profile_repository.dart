import 'package:supabase_flutter/supabase_flutter.dart';

import '../domain/user_profile.dart';

class ProfileRepository {
  ProfileRepository();

  SupabaseClient get _client => Supabase.instance.client;
  User get _user => _client.auth.currentUser!;

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
      if (includeCreatedAt) 'created_at': DateTime.now().toUtc().toIso8601String(),
      'updated_at': DateTime.now().toUtc().toIso8601String(),
    };
    await _client.from('profiles').upsert(data);
  }
}
