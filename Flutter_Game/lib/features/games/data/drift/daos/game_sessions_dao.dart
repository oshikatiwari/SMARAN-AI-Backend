import 'package:drift/drift.dart';

import 'package:cognitive_care_games/features/games/data/drift/app_database.dart';
import 'package:cognitive_care_games/features/games/data/drift/tables/game_sessions_table.dart';

part 'game_sessions_dao.g.dart';

/// Data Access Object for the [GameSessions] table.
///
/// All session persistence goes through this DAO — no raw SQL or table
/// references in repository implementations.
///
/// Naming convention for query methods:
///   insertSession      — creates a new row
///   updateSession      — replaces a row (used when status / endTime changes)
///   watchAllSessions   — reactive Stream for UI observation
///   getSessionById     — single row lookup
///   getSessionsByGame  — filtered by gameType
///   getPendingSessions — rows where syncStatus = 'unsynced' (for sync service)
@DriftAccessor(tables: [GameSessions])
class GameSessionsDao extends DatabaseAccessor<AppDatabase>
    with _$GameSessionsDaoMixin {
  GameSessionsDao(super.db);

  // ── Writes ──────────────────────────────────────────────────────────────

  /// Inserts a new session row.
  /// [syncStatus] defaults to 'unsynced' via the table column default.
  Future<void> insertSession(GameSessionsCompanion entry) =>
      into(gameSessions).insert(entry);

  /// Replaces an existing session row (full update by primary key).
  Future<bool> updateSession(GameSessionsCompanion entry) =>
      update(gameSessions).replace(entry);

  /// Updates only the status, endTime, and syncStatus fields of a session.
  /// More efficient than a full replace when only the lifecycle fields change.
  Future<int> updateSessionStatus({
    required String id,
    required String status,
    int? endTime,
    String syncStatus = 'unsynced',
  }) =>
      (update(gameSessions)..where((t) => t.id.equals(id))).write(
        GameSessionsCompanion(
          status: Value(status),
          endTime: endTime != null ? Value(endTime) : const Value.absent(),
          syncStatus: Value(syncStatus),
        ),
      );

  /// Marks a session as synced after successful backend POST.
  Future<int> markSynced(String id) =>
      (update(gameSessions)..where((t) => t.id.equals(id))).write(
        const GameSessionsCompanion(syncStatus: Value('synced')),
      );

  /// Marks a session as sync_failed after a failed backend POST.
  Future<int> markSyncFailed(String id) =>
      (update(gameSessions)..where((t) => t.id.equals(id))).write(
        const GameSessionsCompanion(syncStatus: Value('sync_failed')),
      );

  // ── Reads ───────────────────────────────────────────────────────────────

  /// Returns the session row for [id], or null if not found.
  Future<GameSession?> getSessionById(String id) =>
      (select(gameSessions)..where((t) => t.id.equals(id))).getSingleOrNull();

  /// Returns all sessions for a given game type, newest first.
  Future<List<GameSession>> getSessionsByGame(String gameType) =>
      (select(gameSessions)
            ..where((t) => t.gameType.equals(gameType))
            ..orderBy([(t) => OrderingTerm.desc(t.startTime)]))
          .get();

  /// Returns all unsynced sessions (for the sync service to process).
  Future<List<GameSession>> getPendingSessions() =>
      (select(gameSessions)
            ..where((t) => t.syncStatus.equals('unsynced')))
          .get();

  /// Reactive stream of all sessions, newest first.
  /// Used by result history screens if added in future.
  Stream<List<GameSession>> watchAllSessions() =>
      (select(gameSessions)
            ..orderBy([(t) => OrderingTerm.desc(t.startTime)]))
          .watch();
}
