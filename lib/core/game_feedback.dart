import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Persisted player-facing controls for non-visual game feedback.
@immutable
class GameFeedbackSettings {
  const GameFeedbackSettings({
    this.musicEnabled = true,
    this.soundEnabled = true,
    this.hapticsEnabled = true,
  });

  final bool musicEnabled;
  final bool soundEnabled;
  final bool hapticsEnabled;

  GameFeedbackSettings copyWith({
    bool? musicEnabled,
    bool? soundEnabled,
    bool? hapticsEnabled,
  }) => GameFeedbackSettings(
    musicEnabled: musicEnabled ?? this.musicEnabled,
    soundEnabled: soundEnabled ?? this.soundEnabled,
    hapticsEnabled: hapticsEnabled ?? this.hapticsEnabled,
  );
}

/// One small gateway for all tactile and system-sound feedback.
///
/// Games call these methods instead of talking to [HapticFeedback] directly,
/// which makes player preferences immediate and consistent across the arcade.
/// Sound effects intentionally use the platform's lightweight click channel:
/// it keeps shot feedback low-latency and avoids a heavyweight audio player
/// for a single, short arcade tick.
abstract final class GameFeedback {
  static const _musicKey = 'false_arcade.feedback.music';
  static const _soundKey = 'false_arcade.feedback.sound';
  static const _hapticsKey = 'false_arcade.feedback.haptics';

  static final ValueNotifier<GameFeedbackSettings> settings = ValueNotifier(
    const GameFeedbackSettings(),
  );
  static DateTime _lastShotSound = DateTime.fromMillisecondsSinceEpoch(0);

  static Future<void> load() async {
    final preferences = await SharedPreferences.getInstance();
    settings.value = GameFeedbackSettings(
      musicEnabled: preferences.getBool(_musicKey) ?? true,
      soundEnabled: preferences.getBool(_soundKey) ?? true,
      hapticsEnabled: preferences.getBool(_hapticsKey) ?? true,
    );
  }

  static Future<void> setMusicEnabled(bool enabled) =>
      _update(musicEnabled: enabled);

  static Future<void> setSoundEnabled(bool enabled) =>
      _update(soundEnabled: enabled);

  static Future<void> setHapticsEnabled(bool enabled) =>
      _update(hapticsEnabled: enabled);

  static Future<void> _update({
    bool? musicEnabled,
    bool? soundEnabled,
    bool? hapticsEnabled,
  }) async {
    final next = settings.value.copyWith(
      musicEnabled: musicEnabled,
      soundEnabled: soundEnabled,
      hapticsEnabled: hapticsEnabled,
    );
    settings.value = next;
    final preferences = await SharedPreferences.getInstance();
    await Future.wait([
      preferences.setBool(_musicKey, next.musicEnabled),
      preferences.setBool(_soundKey, next.soundEnabled),
      preferences.setBool(_hapticsKey, next.hapticsEnabled),
    ]);
  }

  static void selection() {
    if (settings.value.hapticsEnabled) {
      unawaited(HapticFeedback.selectionClick());
    }
  }

  static void lightImpact() {
    if (settings.value.hapticsEnabled) {
      unawaited(HapticFeedback.lightImpact());
    }
  }

  static void mediumImpact() {
    if (settings.value.hapticsEnabled) {
      unawaited(HapticFeedback.mediumImpact());
    }
  }

  static void heavyImpact() {
    if (settings.value.hapticsEnabled) {
      unawaited(HapticFeedback.heavyImpact());
    }
  }

  /// A quiet, throttled firing tick. This is intentionally not played for
  /// every boosted projectile in a spread, only once per fire action.
  static void shot() {
    if (!settings.value.soundEnabled) return;
    final now = DateTime.now();
    if (now.difference(_lastShotSound).inMilliseconds < 85) return;
    _lastShotSound = now;
    unawaited(SystemSound.play(SystemSoundType.click));
  }

  static void pickup() {
    if (!settings.value.soundEnabled) return;
    unawaited(SystemSound.play(SystemSoundType.click));
  }
}
