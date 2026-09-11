import 'package:cognitive_care_games/features/games/presentation/shared/design_system/app_dimensions.dart';
import 'package:cognitive_care_games/features/games/presentation/shared/widgets/elderly_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  // Wrap widgets in MaterialApp so theme and MediaQuery are available.
  Widget _wrap(final Widget child) => MaterialApp(home: Scaffold(body: child));

  group('ElderlyButton (primary)', () {
    testWidgets('renders label text', (final tester) async {
      await tester.pumpWidget(_wrap(
        ElderlyButton(label: 'Start Game', onPressed: () {}),
      ));

      expect(find.text('Start Game'), findsOneWidget);
    });

    testWidgets('calls onPressed when tapped', (final tester) async {
      var tapped = false;

      await tester.pumpWidget(_wrap(
        ElderlyButton(label: 'Tap Me', onPressed: () => tapped = true),
      ));

      await tester.tap(find.text('Tap Me'));
      expect(tapped, isTrue);
    });

    testWidgets('does not call onPressed when disabled', (final tester) async {
      var tapped = false;

      await tester.pumpWidget(_wrap(
        ElderlyButton(
          label: 'Disabled',
          onPressed: () => tapped = true,
          isEnabled: false,
        ),
      ));

      await tester.tap(find.text('Disabled'), warnIfMissed: false);
      expect(tapped, isFalse);
    });

    testWidgets('meets minimum touch target height of 64 dp', (final tester) async {
      await tester.pumpWidget(_wrap(
        ElderlyButton(label: 'Touch Target Test', onPressed: () {}),
      ));

      final buttonSize = tester.getSize(find.byType(ElderlyButton));
      expect(
        buttonSize.height,
        greaterThanOrEqualTo(AppDimensions.buttonHeightPrimary),
        reason: 'Button height must be at least ${AppDimensions.buttonHeightPrimary}dp',
      );
    });

    testWidgets('renders icon when provided', (final tester) async {
      await tester.pumpWidget(_wrap(
        ElderlyButton(
          label: 'With Icon',
          onPressed: () {},
          icon: Icons.play_arrow,
        ),
      ));

      expect(find.byIcon(Icons.play_arrow), findsOneWidget);
    });

    testWidgets('full-width button expands to fill container', (final tester) async {
      const containerWidth = 300.0;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: containerWidth,
              child: ElderlyButton(
                label: 'Full Width',
                onPressed: () {},
                isFullWidth: true,
              ),
            ),
          ),
        ),
      );

      final buttonSize = tester.getSize(find.byType(ElderlyButton));
      expect(buttonSize.width, equals(containerWidth));
    });
  });

  group('ElderlyButton.secondary', () {
    testWidgets('renders label', (final tester) async {
      await tester.pumpWidget(_wrap(
        ElderlyButton.secondary(label: 'Cancel', onPressed: () {}),
      ));

      expect(find.text('Cancel'), findsOneWidget);
    });

    testWidgets('calls onPressed', (final tester) async {
      var tapped = false;
      await tester.pumpWidget(_wrap(
        ElderlyButton.secondary(label: 'Cancel', onPressed: () => tapped = true),
      ));

      await tester.tap(find.text('Cancel'));
      expect(tapped, isTrue);
    });
  });

  group('ElderlyButton.destructive', () {
    testWidgets('renders label', (final tester) async {
      await tester.pumpWidget(_wrap(
        ElderlyButton.destructive(label: 'Quit', onPressed: () {}),
      ));

      expect(find.text('Quit'), findsOneWidget);
    });
  });

  group('Semantics', () {
    testWidgets('has correct button semantics', (final tester) async {
      await tester.pumpWidget(_wrap(
        ElderlyButton(label: 'Accessible Button', onPressed: () {}),
      ));

      final semantics = tester.getSemantics(find.byType(ElderlyButton));
      expect(semantics.label, contains('Accessible Button'));
    });
  });
}
