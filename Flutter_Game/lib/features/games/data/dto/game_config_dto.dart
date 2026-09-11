import 'package:drift/drift.dart';

import 'package:cognitive_care_games/features/games/data/drift/app_database.dart'
    hide GameSession, GameResult;
import 'package:cognitive_care_games/features/games/domain/entities/game_config.dart'
    as domain;
import 'package:cognitive_care_games/features/games/domain/value_objects/difficulty.dart';
import 'package:cognitive_care_games/features/games/domain/value_objects/game_type.dart';

extension GameConfigDto on domain.GameConfig {
  GameConfigsCompanion toCompanion() => GameConfigsCompanion(
        id: Value(id),
        gameType: Value(gameType.value),
        difficulty: Value(difficulty.value),
        gridColumns: Value(gridColumns),
        gridRows: Value(gridRows),
        totalRounds: Value(totalRounds),
        timeLimitSeconds: Value(timeLimitSeconds),
        revealDurationMs: Value(revealDurationMs),
      );
}

domain.GameConfig gameConfigFromRow(final GameConfig row) => domain.GameConfig(
      id: row.id,
      gameType: GameType.fromString(row.gameType),
      difficulty: Difficulty.fromString(row.difficulty),
      gridColumns: row.gridColumns,
      gridRows: row.gridRows,
      totalRounds: row.totalRounds,
      timeLimitSeconds: row.timeLimitSeconds,
      revealDurationMs: row.revealDurationMs,
    );
