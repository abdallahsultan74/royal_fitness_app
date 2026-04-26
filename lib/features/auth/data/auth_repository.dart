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
    await _enforceMobileUserOnly();
  }

  Future<bool> signUp({
    required String name,
    required String email,
    required String password,
    required String language,
    required double heightCm,
    required double currentWeightKg,
    DateTime? dateOfBirth,
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
      dateOfBirth: dateOfBirth,
      heightCm: heightCm,
      currentWeightKg: currentWeightKg,
      targetWeightKg: targetWeightKg,
      whatsappPhone: whatsappPhone,
      includeCreatedAt: true,
    );
    return response.session != null || _auth.currentSession != null;
  }

  Future<void> signOut() => _auth.signOut();

  Future<void> _enforceMobileUserOnly() async {
    final uid = _auth.currentUser?.id;
    if (uid == null) return;
    final role = await _profileRepository.fetchProfileRole(uid: uid);
    final isStaff = role == 'admin' || role == 'coach';
    if (isStaff) {
      await signOut();
      throw Exception('STAFF_NOT_ALLOWED');
    }
  }

  /// Normalizes pasted OTP: extracts `token`/`code` from URLs, maps Arabic/Persian
  /// digits to Latin, collapses spaced digit groups (e.g. "123 456").
  static String normalizeEmailOtpInput(String raw) {
    var s = raw.trim();
    if (s.isEmpty) return s;

    final asUri = Uri.tryParse(s);
    if (asUri != null) {
      if (asUri.hasQuery) {
        final q = asUri.queryParameters;
        final fromQuery = q['token'] ?? q['code'] ?? q['otp'];
        if (fromQuery != null && fromQuery.isNotEmpty) {
          s = fromQuery;
        }
      }
      if (asUri.fragment.isNotEmpty) {
        final frag = Uri.splitQueryString(asUri.fragment);
        final fromFrag = frag['token'] ?? frag['code'] ?? frag['otp'];
        if (fromFrag != null && fromFrag.isNotEmpty) {
          s = fromFrag;
        }
      }
    }

    final embedded = RegExp(r'(?:[?&#])(?:token|code|otp)=([^&\s#]+)')
        .firstMatch(raw);
    if (embedded != null) {
      try {
        s = Uri.decodeQueryComponent(embedded.group(1)!);
      } catch (_) {
        s = embedded.group(1)!;
      }
    }

    const arabicIndic = '٠١٢٣٤٥٦٧٨٩';
    const persianDigits = '۰۱۲۳۴۵۶۷۸۹';
    const latin = '0123456789';
    for (var i = 0; i < 10; i++) {
      s = s.replaceAll(arabicIndic[i], latin[i]).replaceAll(
            persianDigits[i],
            latin[i],
          );
    }

    final allDigits = RegExp(r'\d').allMatches(s).map((m) => m.group(0)!).join();
    if (allDigits.length >= 6) {
      return allDigits.length > 10 ? allDigits.substring(0, 10) : allDigits;
    }
    return s.trim();
  }

  /// Sends an email OTP the user can paste into the app (avoids deep links).
  Future<void> sendEmailOtp(String email) async {
    final emailTrim = email.trim();
    if (emailTrim.isEmpty) {
      throw Exception('EMAIL_REQUIRED');
    }
    // Do not pass [emailRedirectTo]: including redirect_to on /otp tends to bias
    // the default "Magic link" template toward link-only emails. OTP delivery
    // still works; deep links for this flow are handled elsewhere if needed.
    await _auth.signInWithOtp(
      email: emailTrim,
      shouldCreateUser: false,
    );
  }

  /// Verifies the email OTP and establishes a session.
  Future<void> verifyEmailOtp({
    required String email,
    required String token,
  }) async {
    final emailTrim = email.trim();
    if (emailTrim.isEmpty) throw Exception('EMAIL_REQUIRED');
    final normalized = normalizeEmailOtpInput(token);
    if (normalized.isEmpty) throw Exception('OTP_REQUIRED');

    AuthException? last;
    for (final type in [OtpType.email, OtpType.magiclink]) {
      try {
        await _auth.verifyOTP(
          type: type,
          email: emailTrim,
          token: normalized,
        );
        await _enforceMobileUserOnly();
        return;
      } on AuthException catch (e) {
        last = e;
      }
    }
    throw last ?? AuthException('OTP verify failed');
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
