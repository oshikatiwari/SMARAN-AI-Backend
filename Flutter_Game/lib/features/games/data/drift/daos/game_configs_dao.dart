import 'package:drift/drift.dart';

import 'package:cognitive_care_games/features/games/data/drift/app_database.dart';
import 'package:cognitive_care_games/features/games/data/drift/tables/game_configs_table.dart';

part 'game_configs_dao.g.dart';

/// Data Access Object for the [GameConfigs] table.
///
/// Config rows are seeded in [AppDatabase.onCreate] and are read-only
/// at runtime. The only write path is seeding — no game logic calls
/// insert/update on this table.
///
/// Future: [GET /games/{id}/config] response will be mapped to a
/// GameConfigsCompanion and upserted here by the concrete sync service,
/// with zero changes to this DAO.
@DriftAccessor(tables: [GameConfigs])
class GameConfigsDao extends DatabaseAccessor<AppDatabase>
    with _$GameConfigsDaoMixin {
  GameConfigsDao(super.db);

  // ── Reads ───────────────────────────────────────────────────────────────

  /// Returns the config row for the given [gameType] + [difficulty] pair.
  /// Returns null only if the seed data is missing (should never happen).
  Future<GameConfig?> getConfig({
    required String gameType,
    required String difficulty,
  }) =>
      (select(gameConfigs)
            ..where(
              (t) =>
                  t.gameType.equals(gameType) &
                  t.difficulty.equals(difficulty),
            ))
          .getSingleOrNull();

  /// Returns all config rows. Useful for pre-loading configs on app start.
  Future<List<GameConfig>> getAllConfigs() => select(gameConfigs).get();

  // ── Seed / Upsert ───────────────────────────────────────────────────────

  /// Inserts or replaces a config row.
  /// Used only during database seeding (onCreate) and future sync.
  Future<void> upsertConfig(GameConfigsCompanion entry) =>
      into(gameConfigs).insertOnConflictUpdate(entry);
}
