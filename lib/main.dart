import 'package:flutter/widgets.dart';

import 'app/false_arcade_app.dart';
import 'core/game_feedback.dart';

export 'app/false_arcade_app.dart'
    show ArcadeHomePage, FalseArcadeApp, NotYetApp;
export 'games/not_yet/not_yet_game.dart'
    show GamePhase, LevelSpec, RealityGame, RealityGamePage, RealityGameTuning;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await GameFeedback.load();
  runApp(const FalseArcadeApp());
}
