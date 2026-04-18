class SupabaseConfig {
  static const String url = 'https://thndmcqsjoejqnvfbnto.supabase.co';
  static const String anonKey =
      'sb_publishable_hzfActSYdeTmIKRRfLHeOw_zS-eQndC';

  /// Used by [AuthRepository.resetPasswordForEmail]. Add this exact URL to
  /// Supabase Dashboard → Authentication → URL Configuration → Redirect URLs.
  /// Android/iOS deep links open the app so recovery session can complete in-app.
  static const String passwordResetRedirectUrl =
      'com.royalfitness.royal_fitness://reset-password';
}
