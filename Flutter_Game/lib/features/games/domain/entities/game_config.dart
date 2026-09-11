import 'package:equatable/equatable.dart';

import 'package:cognitive_care_games/features/games/domain/value_objects/difficulty.dart';
import 'package:cognitive_care_games/features/games/domain/value_objects/game_type.dart';

/// Domain entity representing the layout and timing configuration for one
/// (game type × difficulty) combination.
///
/// Owned by the domain layer — has no Drift or HTTP imports.
/// Mapped to/from [GameConfig] Drift row in the data layer (Milestone 4).
///
/// Immutable: use [copyWith] to produce modified instances.
final class GameConfig extends Equatable {
  const GameConfig({
    required this.id,
    required this.gameType,
    required this.difficulty,
    required this.gridColumns,
    required this.gridRows,
    required this.totalRounds,
    required this.timeLimitSeconds,
    required this.revealDurationMs,
  });

  /// Surrogate UUID — matches the Drift row id.
  final String id;

  final GameType gameType;
  final Difficulty difficulty;

  // ── Memory Matching layout ──────────────────────────────────────────────

  /// Grid columns. 0 for Pattern Recognition (not applicable).
  final int gridColumns;

  /// Grid rows. 0 for Pattern Recognition (not applicable).
  final int gridRows;

  // ── Pattern Recognition rounds ──────────────────────────────────────────

  /// Total rounds. 0 for Memory Matching (not applicable).
  final int totalRounds;

  // ── Shared timing ───────────────────────────────────────────────────────

  /// Session time limit in seconds. 0 = no limit.
  final int timeLimitSeconds;

  /// Milliseconds each tile/card is revealed.
  final int revealDurationMs;

  // ── Derived helpers ─────────────────────────────────────────────────────

  /// Total cards on the Memory Matching board.
  /// Returns 0 if this config is for Pattern Recognition.
  int get totalCards => gridColumns * gridRows;

  /// Card pairs in Memory Matching.
  int get totalPairs => totalCards ~/ 2;

  /// Whether a time limit is enforced.
  bool get hasTimeLimit => timeLimitSeconds > 0;

  // ── copyWith ─────────────────────────────────────────────────────────────

  GameConfig copyWith({
    String? id,
    GameType? gameType,
    Difficulty? difficulty,
    int? gridColumns,
    int? gridRows,
    int? totalRounds,
    int? timeLimitSeconds,
    int? revealDurationMs,
  }) =>
      GameConfig(
        id: id ?? this.id,
        gameType: gameType ?? this.gameType,
        difficulty: difficulty ?? this.difficulty,
        gridColumns: gridColumns ?? this.gridColumns,
        gridRows: gridRows ?? this.gridRows,
        totalRounds: totalRounds ?? this.totalRounds,
        timeLimitSeconds: timeLimitSeconds ?? this.timeLimitSeconds,
        revealDurationMs: revealDurationMs ?? this.revealDurationMs,
      );

  @override
  List<Object?> get props => [
        id,
        gameType,
        difficulty,
        gridColumns,
        gridRows,
        totalRounds,
        timeLimitSeconds,
        revealDurationMs,
      ];

  @override
  String toString() =>
      'GameConfig(gameType: ${gameType.value}, difficulty: ${difficulty.value}, '
      'grid: ${gridColumns}x$gridRows, rounds: $totalRounds, '
      'timeLimit: ${timeLimitSeconds}s)';
}
