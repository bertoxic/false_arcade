import 'package:flutter/widgets.dart';

import 'app/false_arcade_app.dart';

export 'app/false_arcade_app.dart'
    show ArcadeHomePage, FalseArcadeApp, NotYetApp;
export 'games/not_yet/not_yet_game.dart'
    show GamePhase, LevelSpec, RealityGame, RealityGamePage, RealityGameTuning;

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const FalseArcadeApp());
}
