import 'package:cognitive_care_games/features/games/presentation/memory_matching/flame/components/match_controller.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('MatchController', () {
    late MatchController ctrl;

    setUp(() => ctrl = MatchController(totalPairs: 3));

    // ── First card ──────────────────────────────────────────────────────────

    test('first flip returns FlipResultType.firstCard', () {
      final result = ctrl.registerFlip(cardId: 0, pairId: 0);
      expect(result.isFirstCard, isTrue);
      expect(result.cardId1, equals(0));
    });

    test('first flip does not increment attemptNumber', () {
      ctrl.registerFlip(cardId: 0, pairId: 0);
      expect(ctrl.attemptNumber, equals(0));
    });

    // ── Match ───────────────────────────────────────────────────────────────

    test('two cards with same pairId return FlipResultType.match', () {
      ctrl.registerFlip(cardId: 0, pairId: 1);
      final result = ctrl.registerFlip(cardId: 3, pairId: 1);
      expect(result.isMatch, isTrue);
      expect(result.cardId1, equals(0));
      expect(result.cardId2, equals(3));
      expect(result.attemptNumber, equals(1));
    });

    test('matchedPairs increments after confirmMatch', () {
      ctrl.registerFlip(cardId: 0, pairId: 1);
      ctrl.registerFlip(cardId: 3, pairId: 1);
      ctrl.confirmMatch();
      expect(ctrl.matchedPairs, equals(1));
    });

    test('isEvaluating is true after second flip, false after confirmMatch', () {
      ctrl.registerFlip(cardId: 0, pairId: 1);
      ctrl.registerFlip(cardId: 3, pairId: 1);
      expect(ctrl.isEvaluating, isTrue);
      ctrl.confirmMatch();
      expect(ctrl.isEvaluating, isFalse);
    });

    // ── Mismatch ────────────────────────────────────────────────────────────

    test('two cards with different pairIds return FlipResultType.mismatch', () {
      ctrl.registerFlip(cardId: 0, pairId: 0);
      final result = ctrl.registerFlip(cardId: 1, pairId: 1);
      expect(result.isMismatch, isTrue);
      expect(result.attemptNumber, equals(1));
    });

    test('errors are tracked by caller — controller just counts attempts', () {
      ctrl.registerFlip(cardId: 0, pairId: 0);
      ctrl.registerFlip(cardId: 1, pairId: 1); // mismatch attempt 1
      ctrl.confirmMismatch();
      ctrl.registerFlip(cardId: 2, pairId: 2);
      ctrl.registerFlip(cardId: 5, pairId: 2); // match attempt 2
      ctrl.confirmMatch();
      expect(ctrl.attemptNumber, equals(2));
      expect(ctrl.matchedPairs, equals(1));
    });

    // ── Blocked ─────────────────────────────────────────────────────────────

    test('registerFlip while isEvaluating returns blocked', () {
      ctrl.registerFlip(cardId: 0, pairId: 0);
      ctrl.registerFlip(cardId: 1, pairId: 1); // second flip → evaluating
      final blocked = ctrl.registerFlip(cardId: 2, pairId: 2);
      expect(blocked.type, equals(FlipResultType.blocked));
    });

    // ── Win condition ───────────────────────────────────────────────────────

    test('isGameComplete is false when fewer than totalPairs matched', () {
      ctrl.registerFlip(cardId: 0, pairId: 0);
      ctrl.registerFlip(cardId: 3, pairId: 0);
      ctrl.confirmMatch();
      expect(ctrl.isGameComplete, isFalse);
    });

    test('isGameComplete is true when all pairs matched', () {
      for (var i = 0; i < 3; i++) {
        ctrl.registerFlip(cardId: i * 2, pairId: i);
        ctrl.registerFlip(cardId: i * 2 + 1, pairId: i);
        ctrl.confirmMatch();
      }
      expect(ctrl.isGameComplete, isTrue);
      expect(ctrl.matchedPairs, equals(3));
    });

    // ── Reset ───────────────────────────────────────────────────────────────

    test('reset clears all state', () {
      ctrl.registerFlip(cardId: 0, pairId: 0);
      ctrl.registerFlip(cardId: 1, pairId: 0);
      ctrl.confirmMatch();
      ctrl.reset();
      expect(ctrl.matchedPairs, equals(0));
      expect(ctrl.attemptNumber, equals(0));
      expect(ctrl.isEvaluating, isFalse);
      expect(ctrl.isGameComplete, isFalse);
    });
  });
}
