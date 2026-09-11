import 'package:cognitive_care_games/features/games/domain/value_objects/difficulty.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Difficulty.fromString', () {
    test('parses "easy" to Difficulty.easy', () {
      expect(Difficulty.fromString('easy'), equals(Difficulty.easy));
    });

    test('parses "medium" to Difficulty.medium', () {
      expect(Difficulty.fromString('medium'), equals(Difficulty.medium));
    });

    test('parses "hard" to Difficulty.hard', () {
      expect(Difficulty.fromString('hard'), equals(Difficulty.hard));
    });

    test('throws ArgumentError for unknown value', () {
      expect(
        () => Difficulty.fromString('extreme'),
        throwsA(isA<ArgumentError>()),
      );
    });
  });

  group('Difficulty.value (serialisation)', () {
    test('easy.value returns "easy"', () {
      expect(Difficulty.easy.value, equals('easy'));
    });

    test('fromString(value) round-trips correctly', () {
      for (final d in Difficulty.values) {
        expect(Difficulty.fromString(d.value), equals(d));
      }
    });
  });

  group('DifficultyConfig extension', () {
    group('Memory Matching grid sizes', () {
      test('easy: 3 columns × 4 rows = 12 cards = 6 pairs', () {
        expect(Difficulty.easy.gridColumns, equals(3));
        expect(Difficulty.easy.gridRows, equals(4));
        expect(Difficulty.easy.totalCards, equals(12));
        expect(Difficulty.easy.totalPairs, equals(6));
      });

      test('medium: 4×4 = 16 cards = 8 pairs', () {
        expect(Difficulty.medium.gridColumns, equals(4));
        expect(Difficulty.medium.gridRows, equals(4));
        expect(Difficulty.medium.totalCards, equals(16));
        expect(Difficulty.medium.totalPairs, equals(8));
      });

      test('hard: 4×5 = 20 cards = 10 pairs', () {
        expect(Difficulty.hard.gridColumns, equals(4));
        expect(Difficulty.hard.gridRows, equals(5));
        expect(Difficulty.hard.totalCards, equals(20));
        expect(Difficulty.hard.totalPairs, equals(10));
      });
    });

    group('Pattern Recognition round counts', () {
      test('easy: 5 rounds', () => expect(Difficulty.easy.totalRounds, equals(5)));
      test('medium: 8 rounds', () => expect(Difficulty.medium.totalRounds, equals(8)));
      test('hard: 12 rounds', () => expect(Difficulty.hard.totalRounds, equals(12)));
    });

    group('Time limits', () {
      test('easy: 180 seconds', () => expect(Difficulty.easy.timeLimitSeconds, equals(180)));
      test('medium: 120 seconds', () => expect(Difficulty.medium.timeLimitSeconds, equals(120)));
      test('hard: 90 seconds', () => expect(Difficulty.hard.timeLimitSeconds, equals(90)));
    });

    group('Reveal durations', () {
      test('easy: 1200 ms', () => expect(Difficulty.easy.revealDurationMs, equals(1200)));
      test('medium: 900 ms', () => expect(Difficulty.medium.revealDurationMs, equals(900)));
      test('hard: 600 ms', () => expect(Difficulty.hard.revealDurationMs, equals(600)));
    });

    test('totalCards is always even (required for card pairs)', () {
      for (final d in Difficulty.values) {
        expect(
          d.totalCards % 2,
          equals(0),
          reason: '${d.value} grid has odd card count — cannot form pairs',
        );
      }
    });
  });
}
