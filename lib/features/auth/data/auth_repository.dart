import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/backend/supabase_config.dart';
import '../../profile/data/profile_repository.dart';

class AuthRepository {
  AuthRepository({ProfileRepository? profileRepository})
      : _profileRepository = profileRepository ?? ProfileRepository();

  final ProfileRepository _profileRepository;
  GoTrueClient get _auth => Supabase.instance.client.auth;

  User? get currentUser => _auth.currentUser;

  Stream<User?> authStateChanges() => _auth.onAuthStateChange.map(
        (event) => event.session?.user,
      );

  Future<void> signIn({
    required String email,
    required String password,
  }) async {
    await _auth.signInWithPassword(email: email, password: password);
  }

  Future<bool> signUp({
    required String name,
    required String email,
    required String password,
    required String language,
    required double heightCm,
    required double currentWeightKg,
    double? targetWeightKg,
    String? whatsappPhone,
  }) async {
    final response = await _auth.signUp(
      email: email,
      password: password,
      data: <String, dynamic>{
        'name': name,
        'language': language,
      },
    );
    final uid = response.user?.id ?? _auth.currentUser?.id;
    if (uid == null) return false;
    await _profileRepository.upsertProfile(
      uid: uid,
      email: email,
      name: name,
      language: language,
      goal: 'general_fitness',
      plan: 'trial',
      heightCm: heightCm,
      currentWeightKg: currentWeightKg,
      targetWeightKg: targetWeightKg,
      whatsappPhone: whatsappPhone,
      includeCreatedAt: true,
    );
    return response.session != null || _auth.currentSession != null;
  }

  Future<void> signOut() => _auth.signOut();

  /// Sends an email OTP the user can paste into the app (avoids deep links).
  Future<void> sendEmailOtp(String email) async {
    final emailTrim = email.trim();
    if (emailTrim.isEmpty) {
      throw Exception('EMAIL_REQUIRED');
    }
    await _auth.signInWithOtp(
      email: emailTrim,
      shouldCreateUser: false,
      // Some Supabase projects default to magic link; this nudges email OTP flows
      // and avoids localhost redirects if magic links are enabled.
      emailRedirectTo: SupabaseConfig.passwordResetRedirectUrl,
    );
  }

  /// Verifies the email OTP and establishes a session.
  Future<void> verifyEmailOtp({
    required String email,
    required String token,
  }) async {
    final emailTrim = email.trim();
    final tokenTrim = token.trim();
    if (emailTrim.isEmpty) throw Exception('EMAIL_REQUIRED');
    if (tokenTrim.isEmpty) throw Exception('OTP_REQUIRED');
    await _auth.verifyOTP(
      type: OtpType.email,
      email: emailTrim,
      token: tokenTrim,
    );
  }

  /// Sends a password recovery email. [redirectTo] must be whitelisted in Supabase.
  Future<void> resetPasswordForEmail(
    String email, {
    String? redirectTo,
  }) async {
    final emailTrim = email.trim();
    if (emailTrim.isEmpty) {
      throw Exception('EMAIL_REQUIRED');
    }
    final effectiveRedirectTo =
        (redirectTo == null || redirectTo.trim().isEmpty)
            ? SupabaseConfig.passwordResetRedirectUrl
            : redirectTo.trim();
    await _auth.resetPasswordForEmail(
      emailTrim,
      redirectTo: effectiveRedirectTo,
    );
  }

  /// Sets a new password for the current session (including recovery flow).
  Future<void> updatePassword(String newPassword) async {
    if (newPassword.length < 6) {
      throw Exception('WEAK_PASSWORD');
    }
    await _auth.updateUser(UserAttributes(password: newPassword));
  }
}
