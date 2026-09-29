import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

/// Centralized trauma-based screen shake for high-impact arcade collisions.
abstract final class ArcadeShake {
  static final ValueNotifier<double> traumaNotifier = ValueNotifier(0.0);
  static double _trauma = 0.0;
  static double _time = 0.0;

  /// Add trauma to the screen shake system. Trauma is clamped between 0 and 1.
  /// Standard light hit: 0.2, medium blast: 0.45, heavy explosion / margin call: 0.8.
  static void shake([double amount = 0.45]) {
    _trauma = math.min(1.0, _trauma + amount);
    traumaNotifier.value = _trauma;
  }

  static void update(double dt) {
    if (_trauma > 0) {
      _trauma = math.max(0.0, _trauma - dt * 1.55);
      _time += dt;
      traumaNotifier.value = _trauma;
    }
  }

  /// Calculates the 2D offset based on current trauma squared.
  static Offset get offset {
    if (_trauma <= 0) return Offset.zero;
    final shakePower = _trauma * _trauma;
    final maxDist = shakePower * 14.0;
    final dx = maxDist * math.sin(_time * 48.0);
    final dy = maxDist * math.cos(_time * 54.0);
    return Offset(dx, dy);
  }
}

/// Dynamic full-screen color flash for explosions, settlements, margin calls, or critical events.
abstract final class ArcadeFlash {
  static final ValueNotifier<Color?> flashNotifier = ValueNotifier(null);
  static double _remaining = 0.0;
  static double _totalDuration = 0.18;
  static Color _baseColor = Colors.white;
  static Timer? _fadeTimer;

  static void flash([Color color = Colors.white, double duration = 0.18]) {
    _baseColor = color;
    _totalDuration = math.max(0.04, duration);
    _remaining = _totalDuration;
    flashNotifier.value = color.withValues(alpha: 0.35);

    // Guaranteed autonomous fade-out so color flash NEVER gets stuck under any condition
    _fadeTimer?.cancel();
    _fadeTimer = Timer.periodic(const Duration(milliseconds: 16), (timer) {
      update(0.016);
      if (flashNotifier.value == null) {
        timer.cancel();
        _fadeTimer = null;
      }
    });
  }

  static void update(double dt) {
    if (_remaining <= 0) {
      if (flashNotifier.value != null) flashNotifier.value = null;
      _fadeTimer?.cancel();
      _fadeTimer = null;
      return;
    }
    _remaining = math.max(0.0, _remaining - dt);
    if (_remaining <= 0) {
      flashNotifier.value = null;
      _fadeTimer?.cancel();
      _fadeTimer = null;
    } else {
      final ratio = (_remaining / _totalDuration).clamp(0.0, 1.0);
      flashNotifier.value = _baseColor.withValues(alpha: ratio * 0.35);
    }
  }

  static void reset() {
    _remaining = 0.0;
    _fadeTimer?.cancel();
    _fadeTimer = null;
    flashNotifier.value = null;
  }
}

/// Micro freeze-frame / hit-stop for impactful strikes and detonations.
abstract final class ArcadeHitStop {
  static double _freezeRemaining = 0.0;

  /// Freezes simulation advancement for [seconds] (typical 0.04 to 0.08).
  static void freeze([double seconds = 0.06]) {
    _freezeRemaining = math.max(_freezeRemaining, seconds);
  }

  /// Ticks hit stop timer. Returns `true` if currently frozen.
  static bool tick(double dt) {
    if (_freezeRemaining > 0) {
      _freezeRemaining = math.max(0.0, _freezeRemaining - dt);
      return true;
    }
    return false;
  }
}

/// A wrapper widget that translates its child based on active [ArcadeShake].
class ArcadeShakeView extends StatefulWidget {
  const ArcadeShakeView({super.key, required this.child});

  final Widget child;

  @override
  State<ArcadeShakeView> createState() => _ArcadeShakeViewState();
}

class _ArcadeShakeViewState extends State<ArcadeShakeView>
    with SingleTickerProviderStateMixin {
  late final Ticker _ticker;
  double _lastTick = 0;

  @override
  void initState() {
    super.initState();
    _ticker = createTicker(_onTick);
    ArcadeShake.traumaNotifier.addListener(_onActivityChanged);
    ArcadeFlash.flashNotifier.addListener(_onActivityChanged);
  }

  void _onTick(Duration elapsed) {
    final now = elapsed.inMicroseconds / 1000000.0;
    final dt = (_lastTick == 0) ? 0.016 : (now - _lastTick).clamp(0.001, 0.05);
    _lastTick = now;

    ArcadeShake.update(dt);
    ArcadeFlash.update(dt);

    final isStillActive = ArcadeShake.traumaNotifier.value > 0 ||
        ArcadeFlash.flashNotifier.value != null;
    if (!isStillActive && _ticker.isActive) {
      _ticker.stop();
      _lastTick = 0;
    }
    if (mounted) setState(() {});
  }

  void _onActivityChanged() {
    final needsAnimation = ArcadeShake.traumaNotifier.value > 0 ||
        ArcadeFlash.flashNotifier.value != null;
    if (needsAnimation && !_ticker.isActive) {
      _lastTick = 0;
      _ticker.start();
    }
  }

  @override
  void dispose() {
    ArcadeShake.traumaNotifier.removeListener(_onActivityChanged);
    ArcadeFlash.flashNotifier.removeListener(_onActivityChanged);
    _ticker.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final offset = ArcadeShake.offset;
    return Transform.translate(
      offset: offset,
      child: widget.child,
    );
  }
}
