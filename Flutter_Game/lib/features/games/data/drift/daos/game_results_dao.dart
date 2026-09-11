import 'package:drift/drift.dart';

import 'package:cognitive_care_games/features/games/data/drift/app_database.dart';
import 'package:cognitive_care_games/features/games/data/drift/tables/game_results_table.dart';

part 'game_results_dao.g.dart';

/// Data Access Object for the [GameResults] table.
///
/// All result/metrics persistence goes through this DAO.
///
/// Results are write-once after a session ends — there is no update path
/// for result rows (immutable audit trail). Only [markSynced] and
/// [markSyncFailed] mutate rows post-insert.
@DriftAccessor(tables: [GameResults])
class GameResultsDao extends DatabaseAccessor<AppDatabase>
    with _$GameResultsDaoMixin {
  GameResultsDao(super.db);

  // ── Writes ──────────────────────────────────────────────────────────────

  /// Inserts a new result row.
  /// [syncStatus] defaults to 'unsynced' via the table column default.
  Future<void> insertResult(GameResultsCompanion entry) =>
      into(gameResults).insert(entry);

  /// Marks a result row as synced after successful backend POST.
  Future<int> markSynced(String id) =>
      (update(gameResults)..where((t) => t.id.equals(id))).write(
        const GameResultsCompanion(syncStatus: Value('synced')),
      );

  /// Marks a result row as sync_failed.
  Future<int> markSyncFailed(String id) =>
      (update(gameResults)..where((t) => t.id.equals(id))).write(
        const GameResultsCompanion(syncStatus: Value('sync_failed')),
      );

  // ── Reads ───────────────────────────────────────────────────────────────

  /// Returns the result row for [sessionId], or null if not yet saved.
  Future<GameResult?> getResultBySession(String sessionId) =>
      (select(gameResults)..where((t) => t.sessionId.equals(sessionId)))
          .getSingleOrNull();

  /// Returns all unsynced result rows for the sync service.
  Future<List<GameResult>> getPendingResults() =>
      (select(gameResults)
            ..where((t) => t.syncStatus.equals('unsynced')))
          .get();

  /// Returns all result rows, newest first. Used for analytics/history.
  Future<List<GameResult>> getAllResults() =>
      (select(gameResults)
            ..orderBy([(t) => OrderingTerm.desc(t.createdAt)]))
          .get();

  /// Reactive stream of all results — used by dashboard module (future).
  Stream<List<GameResult>> watchAllResults() =>
      (select(gameResults)
            ..orderBy([(t) => OrderingTerm.desc(t.createdAt)]))
          .watch();
}
