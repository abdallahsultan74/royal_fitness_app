import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

/// Centralized lightweight tap feedback (haptic + click sound).
class RoyalFeedback {
  static Future<void> tap(BuildContext context) async {
    // Haptic can throw on some platforms; keep it best-effort.
    try {
      await HapticFeedback.selectionClick();
    } catch (_) {}
    try {
      await SystemSound.play(SystemSoundType.click);
    } catch (_) {}
  }
}

