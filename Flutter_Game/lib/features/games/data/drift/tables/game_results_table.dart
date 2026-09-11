import 'package:drift/drift.dart';

import 'game_sessions_table.dart';

/// Drift table definition for game results (per-session metrics).
///
/// One row = the computed metrics for one completed game session.
/// Foreign-keyed to [GameSessions] via [sessionId].
///
/// Metric definitions:
///   accuracy        — correct outcomes / total attempts, range [0.0, 1.0]
///   responseTimeMs  — total elapsed milliseconds for the session
///   attempts        — total number of flip pairs (MM) or answer submits (PR)
///   errors          — number of mismatches (MM) or wrong answers (PR)
///   hintsUsed       — number of hint requests during the session
///   completionRate  — rounds/pairs completed / total rounds/pairs, [0.0, 1.0]
///
/// [syncStatus] is set to 'unsynced' at INSERT and updated by ISyncService.
class GameResults extends Table {
  /// Primary key — client-generated UUID v4.
  TextColumn get id => text().withLength(min: 36, max: 36)();

  /// Foreign key → GameSessions.id
  TextColumn get sessionId => text()
      .references(GameSessions, #id, onDelete: KeyAction.cascade)
      .withLength(min: 36, max: 36)();

  /// Correct outcomes / total attempts. Stored as REAL [0.0, 1.0].
  RealColumn get accuracy => real()();

  /// Total session duration in milliseconds.
  IntColumn get responseTimeMs => integer()();

  /// Total attempt count (flip pairs or answer submissions).
  IntColumn get attempts => integer()();

  /// Mismatch / wrong answer count.
  IntColumn get errors => integer()();

  /// Number of times the player used the hint feature.
  IntColumn get hintsUsed => integer()();

  /// Completed rounds or pairs / total rounds or pairs. Stored as REAL [0.0, 1.0].
  RealColumn get completionRate => real()();

  /// Sync lifecycle state. 'unsynced' | 'synced' | 'sync_failed'
  TextColumn get syncStatus => text()
      .withDefault(const Constant('unsynced'))
      .withLength(min: 1, max: 16)();

  /// UTC epoch milliseconds when this result row was created.
  IntColumn get createdAt => integer()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}
