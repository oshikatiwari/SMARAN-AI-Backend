import 'package:drift/drift.dart';

/// Drift table definition for game configuration values.
///
/// Seeded once at database open time (via AppDatabase.onCreate).
/// One row = the layout and timing parameters for one (game_type, difficulty)
/// combination. There are 6 rows total: 2 games × 3 difficulties.
///
/// These values drive:
///   Memory Matching  — grid layout (columns × rows = card count / 2 pairs)
///   Pattern Recognition — round count and display timing
///
/// The table is read-only at runtime; never written to by game logic.
class GameConfigs extends Table {
  /// Composite natural key: (game_type, difficulty).
  /// id is still a surrogate UUID for consistent FK patterns.
  TextColumn get id => text().withLength(min: 36, max: 36)();

  /// 'memory_matching' | 'pattern_recognition'
  TextColumn get gameType => text().withLength(min: 1, max: 64)();

  /// 'easy' | 'medium' | 'hard'
  TextColumn get difficulty => text().withLength(min: 1, max: 16)();

  // ── Memory Matching layout ─────────────────────────────────────────────

  /// Number of columns in the card grid.
  /// Easy=3, Medium=4, Hard=4
  IntColumn get gridColumns => integer()();

  /// Number of rows in the card grid.
  /// Easy=4, Medium=4, Hard=5
  IntColumn get gridRows => integer()();

  // ── Pattern Recognition rounds ─────────────────────────────────────────

  /// Total rounds per session.
  /// Easy=5, Medium=8, Hard=12
  IntColumn get totalRounds => integer()();

  // ── Shared timing ──────────────────────────────────────────────────────

  /// Maximum session time limit in seconds. 0 = no limit.
  /// Easy=180, Medium=120, Hard=90
  IntColumn get timeLimitSeconds => integer()();

  /// Milliseconds each sequence tile is displayed during reveal phase
  /// (Pattern Recognition) or milliseconds a matched pair highlights
  /// before settling (Memory Matching).
  /// Easy=1200, Medium=900, Hard=600
  IntColumn get revealDurationMs => integer()();

  @override
  Set<Column<Object>> get primaryKey => {id};

  @override
  List<String> get customConstraints => [
        // Enforce unique (game_type, difficulty) — prevents duplicate config rows
        'UNIQUE (game_type, difficulty)',
      ];
}
