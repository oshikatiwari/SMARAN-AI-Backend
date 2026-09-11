import 'package:cognitive_care_games/features/games/domain/entities/game_session.dart';
import 'package:cognitive_care_games/features/games/domain/value_objects/game_type.dart';
import 'package:cognitive_care_games/features/games/domain/value_objects/session_status.dart';

/// Repository contract for game session persistence.
///
/// Implementations:
///   [LocalGameSessionRepository] (Milestone 4) — backed by Drift.
///   Future: sync layer calls [getPendingSessions] and marks rows synced
///           via [markSynced] / [markSyncFailed] after POST /game-sessions.
abstract interface class IGameSessionRepository {
  /// Persists a new [GameSession].
  /// Called once when the player taps "Start".
  Future<void> save(GameSession session);

  /// Updates an existing [GameSession] (status transition + endTime).
  /// Called when the session reaches a terminal [SessionStatus].
  Future<void> update(GameSession session);

  /// Returns the session with [id], or null if not found.
  Future<GameSession?> getById(String id);

  /// Returns all sessions for [gameType], newest first.
  Future<List<GameSession>> getByGame(GameType gameType);

  /// Returns all sessions with [SyncStatus.unsynced].
  /// Used by [ISyncService] to determine what needs to be posted.
  Future<List<GameSession>> getPendingSessions();

  /// Marks a session row as [SyncStatus.synced] after successful POST.
  Future<void> markSynced(String id);

  /// Marks a session row as [SyncStatus.syncFailed] after a failed POST.
  Future<void> markSyncFailed(String id);
}
