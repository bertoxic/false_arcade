import 'dart:math' as math;
import 'package:flutter/foundation.dart';
import 'game_feedback.dart';
import 'arcade_achievements.dart';

/// Manages the arcade Fever / Overdrive hyper-state.
///
/// Rapid player performance events charge the gauge. When filled, the game
/// enters an electrifying, high-multiplier Fever state for 7 seconds.
class ArcadeFever {
  static final ValueNotifier<double> energyNotifier = ValueNotifier(0.0);
  static final ValueNotifier<bool> activeNotifier = ValueNotifier(false);

  static double _energy = 0.0;
  static double _feverTimer = 0.0;
  static String _previousMusicTheme = 'arcade_theme';

  static double get energy => _energy;
  static bool get isActive => _feverTimer > 0;
  static double get remainingRatio =>
      _feverTimer > 0 ? (_feverTimer / 7.0).clamp(0.0, 1.0) : 0.0;

  static void reset() {
    _energy = 0.0;
    _feverTimer = 0.0;
    energyNotifier.value = 0.0;
    activeNotifier.value = false;
  }

  /// Charges the Fever gauge by [amount] (between 0.05 and 0.35).
  static void charge(double amount, {String currentMusicTheme = 'arcade_theme'}) {
    if (isActive) return; // Already in fever mode
    _energy = math.min(1.0, _energy + amount);
    energyNotifier.value = _energy;

    if (_energy >= 1.0) {
      _activate(currentMusicTheme);
    }
  }

  static void _activate(String musicTheme) {
    _energy = 1.0;
    _feverTimer = 7.0;
    _previousMusicTheme = musicTheme;
    activeNotifier.value = true;
    energyNotifier.value = 1.0;

    GameFeedback.feverStart();
    GameFeedback.playMusic('fever_theme');
    ArcadeAchievements.unlock('fever_overdrive');
  }

  /// Ticks the Fever system by delta time [dt] (in seconds).
  static void tick(double dt) {
    if (isActive) {
      _feverTimer = math.max(0.0, _feverTimer - dt);
      if (_feverTimer <= 0) {
        _energy = 0.0;
        energyNotifier.value = 0.0;
        activeNotifier.value = false;
        // Resume underlying game theme
        GameFeedback.playMusic(_previousMusicTheme);
      }
    } else if (_energy > 0) {
      // Natural slow decay if player stops chaining actions
      _energy = math.max(0.0, _energy - dt * 0.045);
      energyNotifier.value = _energy;
    }
  }
}
