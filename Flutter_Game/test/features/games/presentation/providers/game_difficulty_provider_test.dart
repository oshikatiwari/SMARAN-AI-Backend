import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:cognitive_care_games/features/games/domain/value_objects/difficulty.dart';
import 'package:cognitive_care_games/features/games/domain/value_objects/game_type.dart';
import 'package:cognitive_care_games/features/games/presentation/providers/difficulty_provider.dart';

void main() {
  group('Per-Game Difficulty Provider (Task 4 Compliance)', () {
    test('Memory Matching and Pattern Recognition start with default Easy difficulty', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final memoryDiff = container.read(gameDifficultyProvider(GameType.memoryMatching));
      final patternDiff = container.read(gameDifficultyProvider(GameType.patternRecognition));

      expect(memoryDiff, equals(Difficulty.easy));
      expect(patternDiff, equals(Difficulty.easy));
    });

    test('Updating Memory Matching difficulty does NOT change Pattern Recognition difficulty', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      // Select Hard for Memory Matching
      container
          .read(gameDifficultyProvider(GameType.memoryMatching).notifier)
          .select(Difficulty.hard);

      final memoryDiff = container.read(gameDifficultyProvider(GameType.memoryMatching));
      final patternDiff = container.read(gameDifficultyProvider(GameType.patternRecognition));

      expect(memoryDiff, equals(Difficulty.hard));
      expect(patternDiff, equals(Difficulty.easy)); // Remains untouched
    });

    test('Updating Pattern Recognition difficulty does NOT change Memory Matching difficulty', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      // Select Medium for Pattern Recognition
      container
          .read(gameDifficultyProvider(GameType.patternRecognition).notifier)
          .select(Difficulty.medium);

      final memoryDiff = container.read(gameDifficultyProvider(GameType.memoryMatching));
      final patternDiff = container.read(gameDifficultyProvider(GameType.patternRecognition));

      expect(memoryDiff, equals(Difficulty.easy)); // Remains untouched
      expect(patternDiff, equals(Difficulty.medium));
    });
  });
}
