import 'dart:async';
import 'dart:io' show Platform;

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Internal audio effect pool for responsive, zero-latency arcade audio.
abstract final class _AudioPool {
  static final bool _isTest =
      !kIsWeb && Platform.environment.containsKey('FLUTTER_TEST');
  static final Map<String, List<AudioPlayer>> _pools = {};
  static final Map<String, int> _poolIndices = {};

  static void play(String soundName, {int poolSize = 2}) {
    if (_isTest) return;
    try {
      final pool = _pools.putIfAbsent(soundName, () {
        return List.generate(poolSize, (_) {
          final player = AudioPlayer();
          player.setPlayerMode(PlayerMode.lowLatency);
          return player;
        });
      });
      final idx = (_poolIndices[soundName] ?? 0) % pool.length;
      _poolIndices[soundName] = idx + 1;
      final player = pool[idx];
      unawaited(
        player.stop().then((_) {
          return player.play(AssetSource('audio/$soundName.wav'));
        }).catchError((_) {}),
      );
    } catch (_) {
      // Gracefully silent if platform audio channel is unavailable
    }
  }
}


/// Persisted player-facing controls for non-visual game feedback.
@immutable
class GameFeedbackSettings {
  const GameFeedbackSettings({
    this.musicEnabled = true,
    this.soundEnabled = true,
    this.hapticsEnabled = true,
    this.crtEnabled = true,
  });

  final bool musicEnabled;
  final bool soundEnabled;
  final bool hapticsEnabled;
  final bool crtEnabled;

  GameFeedbackSettings copyWith({
    bool? musicEnabled,
    bool? soundEnabled,
    bool? hapticsEnabled,
    bool? crtEnabled,
  }) => GameFeedbackSettings(
    musicEnabled: musicEnabled ?? this.musicEnabled,
    soundEnabled: soundEnabled ?? this.soundEnabled,
    hapticsEnabled: hapticsEnabled ?? this.hapticsEnabled,
    crtEnabled: crtEnabled ?? this.crtEnabled,
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
  static const _crtKey = 'false_arcade.feedback.crt';

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
      crtEnabled: preferences.getBool(_crtKey) ?? true,
    );
  }

  static Future<void> setMusicEnabled(bool enabled) =>
      _update(musicEnabled: enabled);

  static Future<void> setSoundEnabled(bool enabled) =>
      _update(soundEnabled: enabled);

  static Future<void> setHapticsEnabled(bool enabled) =>
      _update(hapticsEnabled: enabled);

  static Future<void> setCrtEnabled(bool enabled) =>
      _update(crtEnabled: enabled);

  static Future<void> _update({
    bool? musicEnabled,
    bool? soundEnabled,
    bool? hapticsEnabled,
    bool? crtEnabled,
  }) async {
    final next = settings.value.copyWith(
      musicEnabled: musicEnabled,
      soundEnabled: soundEnabled,
      hapticsEnabled: hapticsEnabled,
      crtEnabled: crtEnabled,
    );
    settings.value = next;
    final preferences = await SharedPreferences.getInstance();
    await Future.wait([
      preferences.setBool(_musicKey, next.musicEnabled),
      preferences.setBool(_soundKey, next.soundEnabled),
      preferences.setBool(_hapticsKey, next.hapticsEnabled),
      preferences.setBool(_crtKey, next.crtEnabled),
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

  /// Low-latency laser shot with rapid-fire throttling.
  static void shot() {
    if (!settings.value.soundEnabled) return;
    final now = DateTime.now();
    if (now.difference(_lastShotSound).inMilliseconds < 85) return;
    _lastShotSound = now;
    _AudioPool.play('laser', poolSize: 3);
  }

  /// Bright crystal chime on score pickups or valuable coin extraction.
  static void pickup() {
    if (settings.value.hapticsEnabled) {
      unawaited(HapticFeedback.lightImpact());
    }
    if (!settings.value.soundEnabled) return;
    _AudioPool.play('pickup', poolSize: 2);
  }

  /// Deep bass pulse on debt settlement and consequence resolution.
  static void settlement() {
    heavyImpact();
    if (!settings.value.soundEnabled) return;
    _AudioPool.play('settlement', poolSize: 2);
  }

  /// Heavy explosion punch for volatile drum blast or defeat.
  static void explosion() {
    heavyImpact();
    if (!settings.value.soundEnabled) return;
    _AudioPool.play('explosion', poolSize: 2);
  }

  /// Tactile jump / gravity reversal pulse.
  static void jump() {
    lightImpact();
    if (!settings.value.soundEnabled) return;
    _AudioPool.play('jump', poolSize: 2);
  }

  /// Urgent cyber alarm siren for security breach, margin calls, or high heat.
  static void alarm() {
    mediumImpact();
    if (!settings.value.soundEnabled) return;
    _AudioPool.play('alarm', poolSize: 2);
  }

  /// Ascending 8-bit fanfare when completing a mission or clearing a sector.
  static void victory() {
    heavyImpact();
    if (!settings.value.soundEnabled) return;
    _AudioPool.play('victory', poolSize: 1);
  }
}

