import '../ui/screen_shake.dart';

/// Adapter interface for micro-hitstop (frame freeze) on high-impact arcade collisions.
abstract final class ArcadeHitstop {
  static bool get isActive => ArcadeHitStop.isActive;

  /// Freezes simulation advancement for [duration].
  static void freeze([Duration duration = const Duration(milliseconds: 40)]) {
    ArcadeHitStop.freeze(duration.inMilliseconds / 1000.0);
  }

  /// Cancels any active hitstop immediately.
  static void cancel() {
    ArcadeHitStop.cancel();
  }

  /// Ticks hit stop timer by [seconds]. Returns `true` if currently frozen.
  static bool tick(double seconds) => ArcadeHitStop.tick(seconds);
}
