import 'package:flutter/scheduler.dart';
import 'package:flutter/widgets.dart';

typedef GameStep = void Function(double seconds);

/// Converts wall-clock frames into bounded fixed simulation steps.
///
/// A fixed step keeps acceleration, collision, and cooldown behaviour stable
/// across 60 Hz, 90 Hz, 120 Hz, and temporarily stalled devices. Excess time
/// is intentionally dropped after [maxSubSteps] to avoid a spiral of death.
class FixedStepClock {
  FixedStepClock({
    this.stepSeconds = 1 / 120,
    this.maxFrameSeconds = 1 / 12,
    this.maxSubSteps = 10,
  }) : assert(stepSeconds > 0),
       assert(maxFrameSeconds >= stepSeconds),
       assert(maxSubSteps > 0);

  final double stepSeconds;
  final double maxFrameSeconds;
  final int maxSubSteps;

  double _accumulator = 0;

  double get interpolationAlpha => (_accumulator / stepSeconds).clamp(0, 1);

  int advance(double frameSeconds, GameStep onStep) {
    if (!frameSeconds.isFinite || frameSeconds <= 0) return 0;
    _accumulator += frameSeconds.clamp(0, maxFrameSeconds);
    var steps = 0;
    while (_accumulator + 1e-10 >= stepSeconds && steps < maxSubSteps) {
      onStep(stepSeconds);
      _accumulator -= stepSeconds;
      steps++;
    }
    if (steps == maxSubSteps && _accumulator >= stepSeconds) {
      _accumulator %= stepSeconds;
    }
    return steps;
  }

  void reset() => _accumulator = 0;
}

/// Owns a Flutter [Ticker] and feeds a [FixedStepClock].
///
/// Pages still own their input and render state; this class only standardises
/// timekeeping and pause/resume semantics.
class GameLoopController with WidgetsBindingObserver {
  GameLoopController({
    required TickerProvider vsync,
    required this.onStep,
    required this.onFrame,
    this.onLifecyclePause,
    FixedStepClock? clock,
  }) : clock = clock ?? FixedStepClock() {
    _ticker = vsync.createTicker(_tick);
    WidgetsBinding.instance.addObserver(this);
  }

  final GameStep onStep;
  final void Function() onFrame;
  final void Function()? onLifecyclePause;
  final FixedStepClock clock;

  late final Ticker _ticker;
  Duration? _previous;
  bool _manualPaused = false;
  bool _lifecyclePaused = false;

  bool get isPaused => _manualPaused || _lifecyclePaused;
  bool get isRunning => _ticker.isActive;

  void start() {
    if (!_ticker.isActive) _ticker.start();
  }

  void setPaused(bool value) {
    if (_manualPaused == value) return;
    _manualPaused = value;
    _syncPauseState();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final paused = switch (state) {
      AppLifecycleState.resumed => false,
      AppLifecycleState.inactive ||
      AppLifecycleState.hidden ||
      AppLifecycleState.paused ||
      AppLifecycleState.detached => true,
    };
    if (_lifecyclePaused == paused) return;
    _lifecyclePaused = paused;
    if (paused) onLifecyclePause?.call();
    _syncPauseState();
  }

  void _syncPauseState() {
    _previous = null;
    clock.reset();
    _ticker.muted = isPaused;
  }

  void _tick(Duration elapsed) {
    final previous = _previous;
    _previous = elapsed;
    if (!isPaused && previous != null) {
      final seconds =
          (elapsed - previous).inMicroseconds / Duration.microsecondsPerSecond;
      clock.advance(seconds, onStep);
    }
    onFrame();
  }

  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _ticker.dispose();
  }
}
