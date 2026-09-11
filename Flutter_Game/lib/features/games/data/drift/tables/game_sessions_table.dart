import 'package:drift/drift.dart';

/// Drift table definition for game sessions.
///
/// One row = one play-through of a single game (Memory Matching or Pattern
/// Recognition), at a specific difficulty, from start to end.
///
/// [sync_status] is set to 'unsynced' at INSERT time and updated by the future
/// ISyncService. Values: 'unsynced' | 'synced' | 'sync_failed'.
class GameSessions extends Table {
  /// Primary key — client-generated UUID v4 (offline-first; no server needed).
  TextColumn get id => text().withLength(min: 36, max: 36)();

  /// Which game produced this session.
  /// Values: 'memory_matching' | 'pattern_recognition'
  TextColumn get gameType => text().withLength(min: 1, max: 64)();

  /// Selected difficulty level.
  /// Values: 'easy' | 'medium' | 'hard'
  TextColumn get difficulty => text().withLength(min: 1, max: 16)();

  /// UTC epoch milliseconds when the session started.
  IntColumn get startTime => integer()();

  /// UTC epoch milliseconds when the session ended.
  /// Null while session is still in progress.
  IntColumn get endTime => integer().nullable()();

  /// Session lifecycle state.
  /// Values: 'in_progress' | 'completed' | 'abandoned'
  TextColumn get status => text().withLength(min: 1, max: 32)();

  /// Sync lifecycle state for offline-first architecture.
  /// Values: 'unsynced' | 'synced' | 'sync_failed'
  TextColumn get syncStatus => text()
      .withDefault(const Constant('unsynced'))
      .withLength(min: 1, max: 16)();

  @override
  Set<Column<Object>> get primaryKey => {id};
}
