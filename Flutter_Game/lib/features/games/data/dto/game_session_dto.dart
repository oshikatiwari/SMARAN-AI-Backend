import 'package:drift/drift.dart';

// Import Drift-generated data class, hiding the name clash with domain entity.
import 'package:cognitive_care_games/features/games/data/drift/app_database.dart'
    hide GameResult, GameConfig;
// Import domain entity under an alias so both can coexist.
import 'package:cognitive_care_games/features/games/domain/entities/game_session.dart'
    as domain;
import 'package:cognitive_care_games/features/games/domain/value_objects/difficulty.dart';
import 'package:cognitive_care_games/features/games/domain/value_objects/game_type.dart';
import 'package:cognitive_care_games/features/games/domain/value_objects/session_status.dart';
import 'package:cognitive_care_games/features/games/domain/value_objects/sync_status.dart';

/// Mapper between [domain.GameSession] domain entity and the Drift-generated
/// [GameSession] row type.
extension GameSessionDto on domain.GameSession {
  /// Full companion — used for both INSERT and full-row UPDATE.
  GameSessionsCompanion toCompanion() => GameSessionsCompanion(
        id: Value(id),
        gameType: Value(gameType.value),
        difficulty: Value(difficulty.value),
        startTime: Value(startTime),
        endTime: Value(endTime),
        status: Value(status.value),
        syncStatus: Value(syncStatus.value),
      );

  /// Partial companion for status-only updates.
  GameSessionsCompanion toStatusCompanion() => GameSessionsCompanion(
        id: Value(id),
        status: Value(status.value),
        endTime: Value(endTime),
        syncStatus: Value(syncStatus.value),
      );
}

/// Converts a Drift-generated [GameSession] row to a [domain.GameSession] entity.
domain.GameSession gameSessionFromRow(final GameSession row) =>
    domain.GameSession(
      id: row.id,
      gameType: GameType.fromString(row.gameType),
      difficulty: Difficulty.fromString(row.difficulty),
      startTime: row.startTime,
      endTime: row.endTime,
      status: SessionStatus.fromString(row.status),
      syncStatus: SyncStatus.fromString(row.syncStatus),
    );
