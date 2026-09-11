import 'package:cognitive_care_games/features/games/domain/entities/game_result.dart';
import 'package:cognitive_care_games/features/games/domain/repositories/i_game_result_repository.dart';
import 'package:cognitive_care_games/features/games/data/drift/daos/game_results_dao.dart';
import 'package:cognitive_care_games/features/games/data/dto/game_result_dto.dart';

/// Local (Drift-backed) implementation of [IGameResultRepository].
///
/// Result rows are write-once (immutable audit trail). Only the
/// [syncStatus] column is ever updated post-insert.
final class LocalGameResultRepository implements IGameResultRepository {
  const LocalGameResultRepository(this._dao);

  final GameResultsDao _dao;

  // ── Writes ──────────────────────────────────────────────────────────────

  @override
  Future<void> save(GameResult result) =>
      _dao.insertResult(result.toCompanion());

  @override
  Future<void> markSynced(String id) => _dao.markSynced(id);

  @override
  Future<void> markSyncFailed(String id) => _dao.markSyncFailed(id);

  // ── Reads ───────────────────────────────────────────────────────────────

  @override
  Future<GameResult?> getBySession(String sessionId) async {
    final row = await _dao.getResultBySession(sessionId);
    return row != null ? gameResultFromRow(row) : null;
  }

  @override
  Future<List<GameResult>> getAll() async {
    final rows = await _dao.getAllResults();
    return rows.map<GameResult>(gameResultFromRow).toList();
  }

  @override
  Future<List<GameResult>> getPendingResults() async {
    final rows = await _dao.getPendingResults();
    return rows.map<GameResult>(gameResultFromRow).toList();
  }
}
