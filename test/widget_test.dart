import 'package:fluga/app/arcade_catalog.dart';
import 'package:fluga/app/false_arcade_app.dart';
import 'package:fluga/app/game_level_select_page.dart';
import 'package:fluga/core/level_campaign.dart';
import 'package:fluga/ui/arcade_crash_recovery_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('launches the arcade game picker', (tester) async {
    await tester.pumpWidget(const FalseArcadeApp());

    expect(find.text('FALSE ARCADE'), findsOneWidget);
    final now = DateTime.now();
    final day = DateTime.utc(now.year, now.month, now.day)
        .difference(DateTime.utc(1970))
        .inDays;
    final initial = day % arcadeCatalog.length;
    expect(
      find.text(arcadeCatalog[initial].subtitle.toUpperCase()),
      findsOneWidget,
    );

    await tester.tap(find.bySemanticsLabel('Next game'));
    await tester.pump();
    final next = arcadeCatalog[(initial + 1) % arcadeCatalog.length];
    expect(find.text(next.subtitle.toUpperCase()), findsOneWidget);
    await tester.tap(find.text('PLAY MISSION'));
    await tester.pumpAndSettle();
    expect(
      tester.widget<GameLevelSelectPage>(find.byType(GameLevelSelectPage)).game.id,
      next.id,
    );
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

  testWidgets('ArcadeCrashRecoveryView renders gracefully with diagnostics toggle', (
    tester,
  ) async {
    final details = FlutterErrorDetails(
      exception: Exception('Simulated arcade rendering interruption'),
      stack: StackTrace.current,
    );
    await tester.pumpWidget(ArcadeCrashRecoveryView(details: details));

    expect(find.text('CABINET FAULT DETECTED'), findsOneWidget);
    expect(find.text('REBOOT CABINET'), findsOneWidget);
    expect(find.text('VIEW DIAGNOSTICS'), findsOneWidget);

    // Tap diagnostics toggle
    await tester.tap(find.text('VIEW DIAGNOSTICS'));
    await tester.pump();

    expect(find.text('HIDE DIAGNOSTICS'), findsOneWidget);
    expect(find.textContaining('Simulated arcade rendering interruption'), findsOneWidget);
  });
}

