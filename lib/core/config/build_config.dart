import 'package:flutter/foundation.dart';

/// Build-time feature flags used to produce a "Client-only" delivery build.
///
/// Enable by passing: `--dart-define=CLIENT_DELIVERY=true`.
class BuildConfig {
  static const bool clientDelivery =
      bool.fromEnvironment('CLIENT_DELIVERY', defaultValue: false);

  /// When false, disable Supabase Realtime subscriptions (channels / postgres changes).
  /// Client delivery builds must not use Realtime.
  static bool get realtimeEnabled => !clientDelivery;

  /// Staff-only messaging (compose/send to admin/coach). Not allowed in client delivery.
  static bool get staffMessagingEnabled => !clientDelivery;

  /// Client app must not seed/sync shared catalog data into the backend (e.g. exercises).
  /// Kept enabled only for debug/dev convenience.
  static bool get exerciseSeedEnabled => !clientDelivery && kDebugMode;
}

