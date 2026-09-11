import 'package:drift/drift.dart';

import 'package:cognitive_care_games/features/games/data/drift/app_database.dart'
    hide GameSession, GameConfig;
import 'package:cognitive_care_games/features/games/domain/entities/game_result.dart'
    as domain;
import 'package:cognitive_care_games/features/games/domain/value_objects/sync_status.dart';

extension GameResultDto on domain.GameResult {
  GameResultsCompanion toCompanion() => GameResultsCompanion(
        id: Value(id),
        sessionId: Value(sessionId),
        accuracy: Value(accuracy),
        responseTimeMs: Value(responseTimeMs),
        attempts: Value(attempts),
        errors: Value(errors),
        hintsUsed: Value(hintsUsed),
        completionRate: Value(completionRate),
        syncStatus: Value(syncStatus.value),
        createdAt: Value(createdAt),
      );
}

domain.GameResult gameResultFromRow(final GameResult row) => domain.GameResult(
      id: row.id,
      sessionId: row.sessionId,
      accuracy: row.accuracy,
      responseTimeMs: row.responseTimeMs,
      attempts: row.attempts,
      errors: row.errors,
      hintsUsed: row.hintsUsed,
      completionRate: row.completionRate,
      syncStatus: SyncStatus.fromString(row.syncStatus),
      createdAt: row.createdAt,
    );
