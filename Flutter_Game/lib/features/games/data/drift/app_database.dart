import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

import 'daos/game_configs_dao.dart';
import 'daos/game_results_dao.dart';
import 'daos/game_sessions_dao.dart';
import 'tables/game_configs_table.dart';
import 'tables/game_results_table.dart';
import 'tables/game_sessions_table.dart';

part 'app_database.g.dart';

/// The single Drift database for the Games Module.
///
/// Lifecycle:
///   - Opened once at app start via [openAppDatabase] factory.
///   - Seeded with [GameConfigs] rows in [_onCreateSeedConfigs] on first launch.
///   - Schema upgrades are handled in [migration].
///
/// Access pattern:
///   - Never imported directly in UI or domain code.
///   - Exposed exclusively through Riverpod's [databaseProvider] (Milestone 6).
///   - DAOs are the only public API; raw table access is forbidden outside this file.
///
/// Schema version history:
///   v1 — initial schema (game_sessions, game_results, game_configs)
@DriftDatabase(
  tables: [GameSessions, GameResults, GameConfigs],
  daos: [GameSessionsDao, GameResultsDao, GameConfigsDao],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase(super.e);

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (m) async {
          await m.createAll();
          await _onCreateSeedConfigs();
        },
        onUpgrade: (m, from, to) async {
          // Future schema migrations go here.
          // Each version bump adds a case; older cases are never deleted.
        },
      );

  // ── Seed Data ────────────────────────────────────────────────────────────

  /// Seeds the 6 canonical config rows (2 games × 3 difficulties) on first
  /// database creation. These values match the Phase 0 blueprint.
  ///
  /// Config schema:
  ///   Memory Matching  — gridColumns × gridRows defines the card grid.
  ///     Easy   → 3×4  = 12 cards = 6 pairs
  ///     Medium → 4×4  = 16 cards = 8 pairs
  ///     Hard   → 4×5  = 20 cards = 10 pairs
  ///
  ///   Pattern Recognition — totalRounds defines rounds per session.
  ///     Easy   → 5 rounds
  ///     Medium → 8 rounds
  ///     Hard   → 12 rounds
  ///
  ///   timeLimitSeconds: 0 means no hard time limit enforced.
  ///   revealDurationMs: how long each sequence tile is shown during reveal.
  Future<void> _onCreateSeedConfigs() async {
    const uuid = Uuid();
    final configs = [
      // ── Memory Matching ─────────────────────────────────────────────────
      _configEntry(
        id: uuid.v4(),
        gameType: 'memory_matching',
        difficulty: 'easy',
        gridColumns: 3,
        gridRows: 4,
        totalRounds: 0, // not used by Memory Matching; 0 = n/a
        timeLimitSeconds: 180,
        revealDurationMs: 1200,
      ),
      _configEntry(
        id: uuid.v4(),
        gameType: 'memory_matching',
        difficulty: 'medium',
        gridColumns: 4,
        gridRows: 4,
        totalRounds: 0,
        timeLimitSeconds: 120,
        revealDurationMs: 900,
      ),
      _configEntry(
        id: uuid.v4(),
        gameType: 'memory_matching',
        difficulty: 'hard',
        gridColumns: 4,
        gridRows: 5,
        totalRounds: 0,
        timeLimitSeconds: 90,
        revealDurationMs: 600,
      ),
      // ── Pattern Recognition ──────────────────────────────────────────────
      _configEntry(
        id: uuid.v4(),
        gameType: 'pattern_recognition',
        difficulty: 'easy',
        gridColumns: 0, // not used by Pattern Recognition; 0 = n/a
        gridRows: 0,
        totalRounds: 5,
        timeLimitSeconds: 180,
        revealDurationMs: 1200,
      ),
      _configEntry(
        id: uuid.v4(),
        gameType: 'pattern_recognition',
        difficulty: 'medium',
        gridColumns: 0,
        gridRows: 0,
        totalRounds: 8,
        timeLimitSeconds: 120,
        revealDurationMs: 900,
      ),
      _configEntry(
        id: uuid.v4(),
        gameType: 'pattern_recognition',
        difficulty: 'hard',
        gridColumns: 0,
        gridRows: 0,
        totalRounds: 12,
        timeLimitSeconds: 90,
        revealDurationMs: 600,
      ),
    ];

    for (final config in configs) {
      await gameConfigsDao.upsertConfig(config);
    }
  }

  GameConfigsCompanion _configEntry({
    required String id,
    required String gameType,
    required String difficulty,
    required int gridColumns,
    required int gridRows,
    required int totalRounds,
    required int timeLimitSeconds,
    required int revealDurationMs,
  }) =>
      GameConfigsCompanion.insert(
        id: id,
        gameType: gameType,
        difficulty: difficulty,
        gridColumns: gridColumns,
        gridRows: gridRows,
        totalRounds: totalRounds,
        timeLimitSeconds: timeLimitSeconds,
        revealDurationMs: revealDurationMs,
      );
}

// ── Database Connection Factories ─────────────────────────────────────────

/// Opens the production database backed by a real SQLite file in the
/// app's documents directory.
///
/// Used by [databaseProvider] in the app's ProviderScope.
Future<AppDatabase> openAppDatabase() async {
  final dbFolder = await getApplicationDocumentsDirectory();
  final file = File(p.join(dbFolder.path, 'cognitive_care_games.db'));
  return AppDatabase(NativeDatabase(file));
}

/// Opens an in-memory database for unit and widget tests.
///
/// Each test should call this independently so tests are isolated.
/// Usage:
///   final db = openTestDatabase();
///   addTearDown(db.close);
AppDatabase openTestDatabase() => AppDatabase(NativeDatabase.memory());
