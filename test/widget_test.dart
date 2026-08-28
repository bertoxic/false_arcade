import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:fluga/main.dart';

void main() {
  setUp(
    () => SharedPreferences.setMockInitialValues({
      'false_arcade.game_tutorials.v1': [
        'not_yet',
        'edge_load',
        'false_habit',
        'numberfall',
        'fall_due',
        'future_debt',
      ],
    }),
  );

  testWidgets('launches the arcade game picker', (WidgetTester tester) async {
    await tester.pumpWidget(const NotYetApp());

    expect(find.text('FALSE ARCADE'), findsOneWidget);
    expect(find.text('NOT YET'), findsOneWidget);
    expect(find.text('EDGELOAD'), findsOneWidget);
    expect(find.text('FALSE HABIT'), findsOneWidget);
    expect(find.text('NUMBERFALL'), findsOneWidget);
    expect(find.text('FALL DUE'), findsOneWidget);
    expect(find.text('FUTURE DEBT'), findsOneWidget);
  });

  testWidgets('opens every game from the arcade', (WidgetTester tester) async {
    Future<void> openAndCheck(String title, String launchLabel) async {
      await tester.pumpWidget(const SizedBox());
      await tester.pump();
      await tester.pumpWidget(const NotYetApp());
      final gameTitle = find.text(title);
      await tester.ensureVisible(gameTitle);
      await tester.tap(gameTitle);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 350));
      await tester.tap(find.text('PLAY'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 350));
      expect(find.text(launchLabel), findsOneWidget);
    }

    await openAndCheck('NOT YET', 'ENTER THE BREACH');
    await openAndCheck('EDGELOAD', 'START RUN');
    await openAndCheck('FALSE HABIT', 'START HEIST');
    await openAndCheck('NUMBERFALL', 'ENTER THE NUMBER');
    await openAndCheck('FALL DUE', 'ENTER THE LEDGER');
    await openAndCheck('FUTURE DEBT', 'START RUN');
  });

  testWidgets('shows a complete tutorial before a game is first played', (
    WidgetTester tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    await tester.pumpWidget(const NotYetApp());
    await tester.tap(find.text('EDGELOAD'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 350));
    await tester.tap(find.text('PLAY'));
    await tester.pump();

    expect(find.text('TRAINING SIMULATION'), findsOneWidget);
    expect(find.text('STEAL AND EXTRACT'), findsOneWidget);

    await tester.tap(find.text('NEXT'));
    await tester.pump();
    await tester.tap(find.text('NEXT'));
    await tester.pump();
    expect(find.text('BEGIN LEVEL'), findsOneWidget);
    await tester.tap(find.text('BEGIN LEVEL'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 350));

    expect(find.text('START RUN'), findsOneWidget);
  });

  testWidgets('False Habit exits to the arcade from its launch screen', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const NotYetApp());
    final gameTitle = find.text('FALSE HABIT');
    await tester.ensureVisible(gameTitle);
    await tester.tap(gameTitle);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 350));
    await tester.tap(find.text('PLAY'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 350));

    expect(find.text('START HEIST'), findsOneWidget);
    await tester.tap(find.byTooltip('Exit game'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 350));

    expect(find.text('FALSE ARCADE'), findsOneWidget);
    expect(find.text('START HEIST'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Fall Due keeps jumping separate from borrowing', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const NotYetApp());
    await tester.pump();
    final gameTitle = find.text('FALL DUE');
    await tester.ensureVisible(gameTitle);
    await tester.tap(gameTitle);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 350));
    await tester.tap(find.text('PLAY'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 350));
    await tester.tap(find.text('ENTER THE LEDGER'));
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.text('JUMP'), findsOneWidget);
    expect(find.text('BORROW'), findsOneWidget);

    await tester.tap(find.text('JUMP'));
    await tester.pump(const Duration(milliseconds: 100));
    expect(tester.takeException(), isNull);
  });

  testWidgets('Future Debt commits borrowing only after a hold', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const SizedBox());
    await tester.pump();
    await tester.pumpWidget(const NotYetApp());
    await tester.pump();
    await tester.ensureVisible(find.text('FUTURE DEBT'));
    await tester.tap(find.text('FUTURE DEBT'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 350));
    await tester.tap(find.text('PLAY'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 350));
    await tester.tap(find.text('START RUN'));
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.text('STACK'), findsOneWidget);
    final gesture = await tester.startGesture(
      tester.getCenter(find.text('RUSH')),
    );
    for (var frame = 0; frame < 14; frame++) {
      await tester.pump(const Duration(milliseconds: 40));
    }
    await gesture.up();
    await tester.pump();

    expect(find.textContaining('FUTURE RUSH:'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Future Debt pauses and resumes its run', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const SizedBox());
    await tester.pump();
    await tester.pumpWidget(const NotYetApp());
    await tester.ensureVisible(find.text('FUTURE DEBT'));
    await tester.tap(find.text('FUTURE DEBT'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 350));
    await tester.tap(find.text('PLAY'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 350));
    await tester.tap(find.text('START RUN'));
    await tester.pump(const Duration(milliseconds: 100));

    await tester.tap(find.byIcon(Icons.pause_rounded));
    await tester.pump();
    expect(find.text('RUN PAUSED'), findsOneWidget);

    await tester.tap(find.text('RESUME'));
    await tester.pump();
    expect(find.text('RUN PAUSED'), findsNothing);
    expect(tester.takeException(), isNull);
  });
}
