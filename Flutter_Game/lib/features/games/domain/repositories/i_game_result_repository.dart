import 'package:cognitive_care_games/features/games/domain/entities/game_result.dart';

/// Repository contract for game result (metrics) persistence.
///
/// Results are write-once — once saved, only sync_status transitions.
/// No update path for metric fields (immutable audit trail).
///
/// Implementations:
///   [LocalGameResultRepository] (Milestone 4) — backed by Drift.
///   Future: sync layer calls [getPendingResults] and marks rows synced
///           via [markSynced] / [markSyncFailed] after POST /game-results.
abstract interface class IGameResultRepository {
  /// Persists a new [GameResult].
  /// Called once when a session ends (completed or abandoned).
  Future<void> save(GameResult result);

  /// Returns the result for [sessionId], or null if not yet saved.
  Future<GameResult?> getBySession(String sessionId);

  /// Returns all persisted results, newest first.
  Future<List<GameResult>> getAll();

  /// Returns all results with [SyncStatus.unsynced].
  Future<List<GameResult>> getPendingResults();

  /// Marks a result row as [SyncStatus.synced].
  Future<void> markSynced(String id);

  /// Marks a result row as [SyncStatus.syncFailed].
  Future<void> markSyncFailed(String id);
}
