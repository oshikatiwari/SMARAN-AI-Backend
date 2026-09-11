import 'package:cognitive_care_games/main.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('App launches without crashing', (final tester) async {
    await tester.pumpWidget(const CognitiveCareApp());
    await tester.pumpAndSettle();
    expect(find.text('Cognitive Care Games'), findsOneWidget);
  });
}
