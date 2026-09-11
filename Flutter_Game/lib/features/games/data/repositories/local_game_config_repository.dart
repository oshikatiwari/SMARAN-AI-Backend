import 'package:cognitive_care_games/features/games/domain/entities/game_config.dart';
import 'package:cognitive_care_games/features/games/domain/repositories/i_game_config_repository.dart';
import 'package:cognitive_care_games/features/games/domain/value_objects/difficulty.dart';
import 'package:cognitive_care_games/features/games/domain/value_objects/game_type.dart';
import 'package:cognitive_care_games/features/games/data/drift/daos/game_configs_dao.dart';
import 'package:cognitive_care_games/features/games/data/dto/game_config_dto.dart';

/// Local (Drift-backed) implementation of [IGameConfigRepository].
///
/// All reads come from the [GameConfigs] table which is seeded in
/// [AppDatabase.onCreate]. At runtime this is read-only.
///
/// Future: when GET /games/{id}/config is wired, the sync service will call
/// [GameConfigsDao.upsertConfig] to refresh rows. This class then returns
/// the updated values with zero changes.
final class LocalGameConfigRepository implements IGameConfigRepository {
  const LocalGameConfigRepository(this._dao);

  final GameConfigsDao _dao;

  @override
  Future<GameConfig?> getConfig({
    required GameType gameType,
    required Difficulty difficulty,
  }) async {
    final row = await _dao.getConfig(
      gameType: gameType.value,
      difficulty: difficulty.value,
    );
    return row != null ? gameConfigFromRow(row) : null;
  }

  @override
  Future<List<GameConfig>> getAllConfigs() async {
    final rows = await _dao.getAllConfigs();
    return rows.map<GameConfig>(gameConfigFromRow).toList();
  }
}
