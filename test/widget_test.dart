import 'package:fluga/app/arcade_catalog.dart';
import 'package:fluga/app/false_arcade_app.dart';
import 'package:fluga/core/level_campaign.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('launches the arcade game picker', (tester) async {
    await tester.pumpWidget(const FalseArcadeApp());

    expect(find.text('FALSE ARCADE'), findsOneWidget);
    expect(find.text('NOT YET'), findsWidgets);
    expect(find.text('EDGELOAD'), findsWidgets);
    expect(tester.takeException(), isNull);
  });

  testWidgets('every catalog entry mounts a playable game page', (
    tester,
  ) async {
    for (final game in arcadeCatalog) {
      final level = GameLevelGenerator.generate(game.id, 1);
      await tester.pumpWidget(
        MaterialApp(home: game.levelPageBuilder(level, (_) {}, null)),
      );
      await tester.pump();

      expect(find.byTooltip('Exit game'), findsOneWidget);
      expect(tester.takeException(), isNull);

      await tester.pumpWidget(const SizedBox());
      await tester.pump();
    }
  });
}
