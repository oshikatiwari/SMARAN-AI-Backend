import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:cognitive_care_games/features/games/domain/value_objects/difficulty.dart';
import 'package:cognitive_care_games/features/games/domain/value_objects/game_type.dart';

// ── Per-Game Difficulty Provider ──────────────────────────────────────────────

/// NotifierFamily maintaining game-specific difficulty states.
///
/// Ensures Memory Matching difficulty updates do NOT leak into or overwrite
/// Pattern Recognition difficulty state.
class GameDifficultyNotifier extends FamilyNotifier<Difficulty, GameType> {
  @override
  Difficulty build(final GameType arg) => Difficulty.easy;

  void select(final Difficulty d) => state = d;
}

final gameDifficultyProvider =
    NotifierProviderFamily<GameDifficultyNotifier, Difficulty, GameType>(
  GameDifficultyNotifier.new,
);

// ── Backward-compatible global helper ─────────────────────────────────────────

class DifficultyNotifier extends Notifier<Difficulty> {
  @override
  Difficulty build() => ref.watch(gameDifficultyProvider(GameType.memoryMatching));

  void select(final Difficulty d) {
    ref.read(gameDifficultyProvider(GameType.memoryMatching).notifier).select(d);
  }
}

final difficultyProvider =
    NotifierProvider<DifficultyNotifier, Difficulty>(
  DifficultyNotifier.new,
);

// ── GameType provider ─────────────────────────────────────────────────────────

class GameTypeNotifier extends Notifier<GameType> {
  @override
  GameType build() => GameType.memoryMatching;

  void select(final GameType t) => state = t;
}

final gameTypeProvider =
    NotifierProvider<GameTypeNotifier, GameType>(
  GameTypeNotifier.new,
);
