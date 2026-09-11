import 'package:cognitive_care_games/features/games/presentation/shared/widgets/game_timer_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Widget _wrap(final Widget child) => MaterialApp(home: Scaffold(body: child));

  group('GameTimerWidget (count-up mode — no limit)', () {
    testWidgets('formats 0 seconds as 00:00', (final tester) async {
      await tester.pumpWidget(
        _wrap(const GameTimerWidget(elapsedSeconds: 0)),
      );
      expect(find.text('00:00'), findsOneWidget);
    });

    testWidgets('formats 65 seconds as 01:05', (final tester) async {
      await tester.pumpWidget(
        _wrap(const GameTimerWidget(elapsedSeconds: 65)),
      );
      expect(find.text('01:05'), findsOneWidget);
    });

    testWidgets('formats 3600 seconds as 60:00', (final tester) async {
      await tester.pumpWidget(
        _wrap(const GameTimerWidget(elapsedSeconds: 3600)),
      );
      expect(find.text('60:00'), findsOneWidget);
    });
  });

  group('GameTimerWidget (countdown mode)', () {
    testWidgets('shows remaining time when limit provided', (final tester) async {
      // 180s limit, 30s elapsed → 150s remaining = 02:30
      await tester.pumpWidget(
        _wrap(const GameTimerWidget(
          elapsedSeconds: 30,
          timeLimitSeconds: 180,
        )),
      );
      expect(find.text('02:30'), findsOneWidget);
    });

    testWidgets('clamps to 00:00 when elapsed exceeds limit', (final tester) async {
      await tester.pumpWidget(
        _wrap(const GameTimerWidget(
          elapsedSeconds: 200,
          timeLimitSeconds: 180,
        )),
      );
      expect(find.text('00:00'), findsOneWidget);
    });
  });

  group('Semantics', () {
    testWidgets('provides timer label for accessibility', (final tester) async {
      await tester.pumpWidget(
        _wrap(const GameTimerWidget(elapsedSeconds: 125)),
      );

      final semantics = tester.getSemantics(find.byType(GameTimerWidget));
      expect(semantics.label, contains('Timer:'));
      expect(semantics.label, contains('02:05'));
    });
  });

  group('_formatSeconds static helper (via widget)', () {
    // Test boundary values by pumping the widget directly
    final testCases = {
      0: '00:00',
      59: '00:59',
      60: '01:00',
      61: '01:01',
      599: '09:59',
      600: '10:00',
    };

    testCases.forEach((seconds, expected) {
      testWidgets('$seconds s → $expected', (final tester) async {
        await tester.pumpWidget(
          _wrap(GameTimerWidget(elapsedSeconds: seconds)),
        );
        expect(find.text(expected), findsOneWidget);
      });
    });
  });
}
