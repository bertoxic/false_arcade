import 'dart:math' as math;
import 'package:flutter/widgets.dart';

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

  /// Update the trauma decay by delta time (in seconds).
  static void update(double dt) {
    if (_trauma <= 0) return;
    _time += dt;
    _trauma = math.max(0.0, _trauma - dt * 2.2);
    traumaNotifier.value = _trauma;
  }

  /// Returns current translation offset based on trauma.
  static Offset get offset {
    if (_trauma <= 0) return Offset.zero;
    final shake = _trauma * _trauma;
    final maxDist = 12.0 * shake;
    final dx = maxDist * math.sin(_time * 48.0);
    final dy = maxDist * math.cos(_time * 54.0);
    return Offset(dx, dy);
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
  late final AnimationController _controller;
  double _lastTick = 0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController.unbounded(vsync: this);
    ArcadeShake.traumaNotifier.addListener(_onTraumaChanged);
  }

  void _onTraumaChanged() {
    if (ArcadeShake.traumaNotifier.value > 0 && !_controller.isAnimating) {
      _lastTick = DateTime.now().millisecondsSinceEpoch / 1000.0;
      _controller.repeat();
    }
  }

  @override
  void dispose() {
    ArcadeShake.traumaNotifier.removeListener(_onTraumaChanged);
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final now = DateTime.now().millisecondsSinceEpoch / 1000.0;
        final dt = (_lastTick == 0) ? 0.016 : (now - _lastTick).clamp(0.001, 0.05);
        _lastTick = now;
        ArcadeShake.update(dt);
        if (ArcadeShake.traumaNotifier.value <= 0 && _controller.isAnimating) {
          _controller.stop();
        }
        final offset = ArcadeShake.offset;
        return Transform.translate(
          offset: offset,
          child: child,
        );
      },
      child: widget.child,
    );
  }
}
