import 'package:cognitive_care_games/features/games/domain/value_objects/difficulty.dart';
import 'package:cognitive_care_games/features/games/domain/value_objects/pattern_type.dart';
import 'package:cognitive_care_games/features/games/presentation/pattern_recognition/flame/components/pattern_controller.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  // Helper: builds a controller and advances through all rounds.
  PatternController _makeCtrl({
    Difficulty difficulty = Difficulty.easy,
    PatternType type = PatternType.numeric,
  }) =>
      PatternController(difficulty: difficulty, patternType: type);

  group('PatternController — round generation', () {
    test('nextRound returns null when all rounds are exhausted', () {
      final ctrl = _makeCtrl(difficulty: Difficulty.easy); // 5 rounds
      for (var i = 0; i < 5; i++) {
        expect(ctrl.nextRound(), isNotNull);
      }
      expect(ctrl.nextRound(), isNull);
      expect(ctrl.isComplete, isTrue);
    });

    test('each round has exactly 4 options', () {
      final ctrl = _makeCtrl();
      final round = ctrl.nextRound()!;
      expect(round.options.length, equals(4));
    });

    test('correct answer is always among the options', () {
      final ctrl = _makeCtrl();
      for (var i = 0; i < 5; i++) {
        final round = ctrl.nextRound()!;
        expect(round.options, contains(round.correctAnswer));
      }
    });

    test('numeric round sequence has correct length for Easy (3 elements)', () {
      final ctrl = _makeCtrl(difficulty: Difficulty.easy, type: PatternType.numeric);
      final round = ctrl.nextRound()!;
      expect(round.sequence.length, equals(3));
    });

    test('numeric round sequence has correct length for Hard (5 elements)', () {
      final ctrl = _makeCtrl(difficulty: Difficulty.hard, type: PatternType.numeric);
      final round = ctrl.nextRound()!;
      expect(round.sequence.length, equals(5));
    });

    test('color round sequence elements are all emoji strings', () {
      final ctrl = _makeCtrl(type: PatternType.color);
      final round = ctrl.nextRound()!;
      for (final item in round.sequence) {
        expect(item, isNotEmpty);
      }
    });

    test('shape round has correct pattern type', () {
      final ctrl = _makeCtrl(type: PatternType.shape);
      final round = ctrl.nextRound()!;
      expect(round.patternType, equals(PatternType.shape));
    });

    test('rounds for Medium difficulty total 8', () {
      final ctrl = _makeCtrl(difficulty: Difficulty.medium);
      var count = 0;
      while (ctrl.nextRound() != null) {
        count++;
      }
      expect(count, equals(8));
    });

    test('rounds for Hard difficulty total 12', () {
      final ctrl = _makeCtrl(difficulty: Difficulty.hard);
      var count = 0;
      while (ctrl.nextRound() != null) {
        count++;
      }
      expect(count, equals(12));
    });
  });

  group('PatternController — answer submission', () {
    test('correct answer increments correctAnswers', () {
      final ctrl = _makeCtrl();
      final round = ctrl.nextRound()!;
      ctrl.submitAnswer(round.correctAnswer);
      expect(ctrl.correctAnswers, equals(1));
      expect(ctrl.errors, equals(0));
      expect(ctrl.totalAttempts, equals(1));
    });

    test('wrong answer increments errors', () {
      final ctrl = _makeCtrl();
      final round = ctrl.nextRound()!;
      final wrong = round.options.firstWhere((final o) => o != round.correctAnswer);
      ctrl.submitAnswer(wrong);
      expect(ctrl.errors, equals(1));
      expect(ctrl.correctAnswers, equals(0));
    });

    test('submitAnswer returns correct AnswerResult', () {
      final ctrl = _makeCtrl();
      final round = ctrl.nextRound()!;
      final result = ctrl.submitAnswer(round.correctAnswer);
      expect(result.isCorrect, isTrue);
      expect(result.correctAnswer, equals(round.correctAnswer));
      expect(result.roundNumber, equals(1));
      expect(result.attemptNumber, equals(1));
    });

    test('accuracy = correctAnswers / totalAttempts', () {
      final ctrl = _makeCtrl();
      var r = ctrl.nextRound()!;
      ctrl.submitAnswer(r.correctAnswer); // correct

      r = ctrl.nextRound()!;
      final wrong = r.options.firstWhere((final o) => o != r.correctAnswer);
      ctrl.submitAnswer(wrong); // incorrect

      expect(ctrl.accuracy, closeTo(0.5, 0.01));
    });

    test('accuracy is 0.0 when no attempts', () {
      final ctrl = _makeCtrl();
      expect(ctrl.accuracy, equals(0.0));
    });

    test('completionRate advances per round', () {
      final ctrl = _makeCtrl(difficulty: Difficulty.easy); // 5 rounds
      ctrl.nextRound();
      ctrl.submitAnswer('x'); // any answer

      // 1 round done / 5 total = 0.2
      expect(ctrl.completionRate, closeTo(0.2, 0.01));
    });
  });

  group('PatternController — reset', () {
    test('reset clears all counters', () {
      final ctrl = _makeCtrl();
      ctrl.nextRound();
      ctrl.submitAnswer('x');
      ctrl.reset();
      expect(ctrl.currentRound, equals(0));
      expect(ctrl.totalAttempts, equals(0));
      expect(ctrl.correctAnswers, equals(0));
      expect(ctrl.errors, equals(0));
      expect(ctrl.isComplete, isFalse);
    });
  });

  group('PatternController — determinism (seeded RNG)', () {
    test('same round number produces same sequence each time', () {
      final ctrl1 = _makeCtrl(difficulty: Difficulty.easy, type: PatternType.numeric);
      final ctrl2 = _makeCtrl(difficulty: Difficulty.easy, type: PatternType.numeric);

      final round1 = ctrl1.nextRound()!;
      final round2 = ctrl2.nextRound()!;

      expect(round1.sequence, equals(round2.sequence));
      expect(round1.correctAnswer, equals(round2.correctAnswer));
    });
  });
}
