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

/// Internal dedicated music player for seamless retro arcade chiptune soundtracks.
abstract final class _MusicPlayer {
  static final bool _isTest =
      !kIsWeb && Platform.environment.containsKey('FLUTTER_TEST');
  static AudioPlayer? _player;
  static String? _currentTheme;
  static bool _isPlaying = false;

  static Future<void> play(String themeName) async {
    if (_isTest) return;
    if (_currentTheme == themeName && _isPlaying) return;
    _currentTheme = themeName;
    if (!GameFeedback.settings.value.musicEnabled) return;
    try {
      _player ??= AudioPlayer();
      await _player!.setReleaseMode(ReleaseMode.loop);
      await _player!.setVolume(0.55);
      await _player!.play(AssetSource('audio/$themeName.wav'));
      _isPlaying = true;
    } catch (_) {}
  }

  static Future<void> stop() async {
    if (_isTest) return;
    try {
      await _player?.stop();
      _isPlaying = false;
      _currentTheme = null;
    } catch (_) {}
  }

  static Future<void> pause() async {
    if (_isTest) return;
    try {
      await _player?.pause();
      _isPlaying = false;
    } catch (_) {}
  }

  static Future<void> resume() async {
    if (_isTest) return;
    if (!GameFeedback.settings.value.musicEnabled) return;
    if (_currentTheme != null) {
      try {
        await _player?.resume();
        _isPlaying = true;
      } catch (_) {
        if (_currentTheme != null) {
          await play(_currentTheme!);
        }
      }
    }
  }

  static void onSettingsChanged(bool enabled) {
    if (_isTest) return;
    if (!enabled) {
      _player?.pause();
      _isPlaying = false;
    } else if (_currentTheme != null) {
      if (_player != null) {
        _player!.resume();
        _isPlaying = true;
      } else {
        play(_currentTheme!);
      }
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

/// One central gateway for all tactile, system sound, and chiptune soundtrack feedback.
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

    if (musicEnabled != null) {
      _MusicPlayer.onSettingsChanged(musicEnabled);
    }

    final preferences = await SharedPreferences.getInstance();
    await Future.wait([
      preferences.setBool(_musicKey, next.musicEnabled),
      preferences.setBool(_soundKey, next.soundEnabled),
      preferences.setBool(_hapticsKey, next.hapticsEnabled),
      preferences.setBool(_crtKey, next.crtEnabled),
    ]);
  }

  // --- Music Controls ---

  /// Plays or transitions to an authentic chiptune soundtrack loop.
  /// Themes: 'arcade_theme', 'battle_theme', 'stealth_theme', 'platform_theme', 'fever_theme'.
  static void playMusic(String themeName) {
    unawaited(_MusicPlayer.play(themeName));
  }

  /// Pauses the current soundtrack without discarding the current theme.
  static void pauseMusic() {
    unawaited(_MusicPlayer.pause());
  }

  /// Resumes the current soundtrack.
  static void resumeMusic() {
    unawaited(_MusicPlayer.resume());
  }

  /// Completely stops background music.
  static void stopMusic() {
    unawaited(_MusicPlayer.stop());
  }

  // --- Haptics ---

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

  // --- Sound Effects ---

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

  /// Rising harmonic scale when chaining combos or reaching multipliers.
  static void combo() {
    lightImpact();
    if (!settings.value.soundEnabled) return;
    _AudioPool.play('combo', poolSize: 2);
  }

  /// Triumphant royal arcade fanfare on achievement unlock.
  static void achievement() {
    heavyImpact();
    if (!settings.value.soundEnabled) return;
    _AudioPool.play('achievement', poolSize: 1);
  }

  /// Melancholic descending buzz on defeat / game over.
  static void defeat() {
    heavyImpact();
    if (!settings.value.soundEnabled) return;
    _AudioPool.play('defeat', poolSize: 1);
  }

  /// Futuristic low-frequency blast when triggering a shockwave or bomb.
  static void shockwave() {
    heavyImpact();
    if (!settings.value.soundEnabled) return;
    _AudioPool.play('shockwave', poolSize: 2);
  }

  /// Electrifying energy surge when triggering Fever Overdrive mode.
  static void feverStart() {
    heavyImpact();
    if (!settings.value.soundEnabled) return;
    _AudioPool.play('fever_start', poolSize: 1);
  }
}
