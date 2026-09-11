import 'package:cognitive_care_games/features/games/domain/entities/game_session.dart';
import 'package:cognitive_care_games/features/games/domain/repositories/i_game_session_repository.dart';
import 'package:cognitive_care_games/features/games/domain/value_objects/game_type.dart';
import 'package:cognitive_care_games/features/games/data/drift/daos/game_sessions_dao.dart';
import 'package:cognitive_care_games/features/games/data/dto/game_session_dto.dart';

/// Local (Drift-backed) implementation of [IGameSessionRepository].
///
/// Every write succeeds offline — Drift's WAL-mode SQLite guarantees
/// ACID writes without any network dependency.
///
/// Sync markers ([markSynced], [markSyncFailed]) are called only by the
/// future [ISyncService] — never by game logic or UI.
final class LocalGameSessionRepository implements IGameSessionRepository {
  const LocalGameSessionRepository(this._dao);

  final GameSessionsDao _dao;

  // ── Writes ──────────────────────────────────────────────────────────────

  @override
  Future<void> save(GameSession session) =>
      _dao.insertSession(session.toCompanion());

  @override
  Future<void> update(GameSession session) async {
    // Use the targeted status-only update path — more efficient than
    // a full row replace when only lifecycle fields change.
    await _dao.updateSessionStatus(
      id: session.id,
      status: session.status.value,
      endTime: session.endTime,
      syncStatus: session.syncStatus.value,
    );
  }

  @override
  Future<void> markSynced(String id) => _dao.markSynced(id);

  @override
  Future<void> markSyncFailed(String id) => _dao.markSyncFailed(id);

  // ── Reads ───────────────────────────────────────────────────────────────

  @override
  Future<GameSession?> getById(String id) async {
    final row = await _dao.getSessionById(id);
    return row != null ? gameSessionFromRow(row) : null;
  }

  @override
  Future<List<GameSession>> getByGame(GameType gameType) async {
    final rows = await _dao.getSessionsByGame(gameType.value);
    return rows.map<GameSession>(gameSessionFromRow).toList();
  }

  @override
  Future<List<GameSession>> getPendingSessions() async {
    final rows = await _dao.getPendingSessions();
    return rows.map<GameSession>(gameSessionFromRow).toList();
  }
}
