import 'dart:ui';
import 'package:flutter/widgets.dart';

import 'app/false_arcade_app.dart';
import 'core/arcade_achievements.dart';
import 'core/arcade_leaderboard.dart';
import 'core/game_feedback.dart';
import 'ui/arcade_crash_recovery_view.dart';

export 'app/false_arcade_app.dart'
    show ArcadeHomePage, FalseArcadeApp, NotYetApp;
export 'games/not_yet/not_yet_game.dart'
    show GamePhase, LevelSpec, RealityGame, RealityGamePage, RealityGameTuning;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Production error boundary for framework layout/render errors
  FlutterError.onError = (FlutterErrorDetails details) {
    FlutterError.presentError(details);
  };

  // Production error boundary for uncaught async exceptions
  PlatformDispatcher.instance.onError = (Object error, StackTrace stack) {
    debugPrint('Arcade Async Fault: $error\n$stack');
    return true; // Prevents abrupt OS process crash
  };

  // Graceful custom error boundary widget replacing Flutter's grey screen of death
  ErrorWidget.builder = (FlutterErrorDetails details) {
    return ArcadeCrashRecoveryView(details: details);
  };

  // Safe storage initialization: never fail to boot if disk read is interrupted
  try {
    await Future.wait([
      GameFeedback.load(),
      ArcadeLeaderboard.load(),
      ArcadeAchievements.load(),
    ]);
  } catch (e, st) {
    debugPrint('Arcade Cold-Boot Warning: $e\n$st');
  }

  runApp(const FalseArcadeApp());
}
