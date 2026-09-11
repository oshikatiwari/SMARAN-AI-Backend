import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:cognitive_care_games/features/games/domain/value_objects/difficulty.dart';
import 'package:cognitive_care_games/features/games/domain/value_objects/game_type.dart';

// ── Difficulty provider ───────────────────────────────────────────────────────

/// In Riverpod 3.x, StateProvider was removed. Use Notifier instead.
class DifficultyNotifier extends Notifier<Difficulty> {
  @override
  Difficulty build() => Difficulty.easy;

  void select(final Difficulty d) => state = d;
}

final difficultyProvider =
    NotifierProvider.autoDispose<DifficultyNotifier, Difficulty>(
  DifficultyNotifier.new,
);

// ── GameType provider ─────────────────────────────────────────────────────────

class GameTypeNotifier extends Notifier<GameType> {
  @override
  GameType build() => GameType.memoryMatching;

  void select(final GameType t) => state = t;
}

final gameTypeProvider =
    NotifierProvider.autoDispose<GameTypeNotifier, GameType>(
  GameTypeNotifier.new,
);
