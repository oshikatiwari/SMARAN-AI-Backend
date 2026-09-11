import 'package:cognitive_care_games/features/games/domain/value_objects/difficulty.dart';
import 'package:cognitive_care_games/features/games/presentation/shared/widgets/difficulty_selector_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Widget _wrap({
    required Difficulty selected,
    required ValueChanged<Difficulty> onSelected,
    bool isEnabled = true,
  }) =>
      MaterialApp(
        home: Scaffold(
          body: DifficultySelectorWidget(
            selectedDifficulty: selected,
            onSelected: onSelected,
            isEnabled: isEnabled,
          ),
        ),
      );

  group('DifficultySelectorWidget', () {
    testWidgets('renders all three difficulty labels', (final tester) async {
      await tester.pumpWidget(_wrap(
        selected: Difficulty.easy,
        onSelected: (_) {},
      ));

      expect(find.text('Easy'), findsOneWidget);
      expect(find.text('Medium'), findsOneWidget);
      expect(find.text('Hard'), findsOneWidget);
    });

    testWidgets('calls onSelected with Easy when Easy tapped', (final tester) async {
      Difficulty? selected;

      await tester.pumpWidget(_wrap(
        selected: Difficulty.medium,
        onSelected: (d) => selected = d,
      ));

      await tester.tap(find.text('Easy'));
      expect(selected, equals(Difficulty.easy));
    });

    testWidgets('calls onSelected with Medium when Medium tapped', (final tester) async {
      Difficulty? selected;

      await tester.pumpWidget(_wrap(
        selected: Difficulty.easy,
        onSelected: (d) => selected = d,
      ));

      await tester.tap(find.text('Medium'));
      expect(selected, equals(Difficulty.medium));
    });

    testWidgets('calls onSelected with Hard when Hard tapped', (final tester) async {
      Difficulty? selected;

      await tester.pumpWidget(_wrap(
        selected: Difficulty.easy,
        onSelected: (d) => selected = d,
      ));

      await tester.tap(find.text('Hard'));
      expect(selected, equals(Difficulty.hard));
    });

    testWidgets('does not call onSelected when disabled', (final tester) async {
      var callCount = 0;

      await tester.pumpWidget(_wrap(
        selected: Difficulty.easy,
        onSelected: (_) => callCount++,
        isEnabled: false,
      ));

      await tester.tap(find.text('Medium'), warnIfMissed: false);
      expect(callCount, equals(0));
    });

    testWidgets('calls onSelected even when tapping currently selected difficulty',
        (final tester) async {
      var callCount = 0;

      await tester.pumpWidget(_wrap(
        selected: Difficulty.easy,
        onSelected: (_) => callCount++,
      ));

      await tester.tap(find.text('Easy'));
      expect(callCount, equals(1));
    });

    testWidgets('shows time subtitle for each difficulty', (final tester) async {
      await tester.pumpWidget(_wrap(
        selected: Difficulty.easy,
        onSelected: (_) {},
      ));

      expect(find.text('3 min'), findsOneWidget);
      expect(find.text('2 min'), findsOneWidget);
      expect(find.text('90 sec'), findsOneWidget);
    });
  });
}
