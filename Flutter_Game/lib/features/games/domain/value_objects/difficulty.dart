import 'package:equatable/equatable.dart';

/// Difficulty level for a game session.
///
/// Each level carries its own layout and timing parameters so the game
/// engine can query them without touching the database or config layer.
/// These values mirror the seeded [GameConfigs] rows created in Milestone 2
/// and must be kept in sync if config defaults change.
///
/// Extension [DifficultyConfig] exposes per-difficulty constants as
/// strongly-typed getters — no magic numbers in game logic or UI code.
enum Difficulty {
  easy,
  medium,
  hard;

  /// Deserialises the string stored in Drift rows back to [Difficulty].
  /// Throws [ArgumentError] for unknown values (defensive — schema is closed).
  static Difficulty fromString(final String value) {
    return switch (value.toLowerCase()) {
      'easy' => Difficulty.easy,
      'medium' => Difficulty.medium,
      'hard' => Difficulty.hard,
      _ => throw ArgumentError('Unknown Difficulty value: $value'),
    };
  }

  /// Serialises to the string stored in Drift rows.
  String get value => name; // 'easy' | 'medium' | 'hard'
}

/// Per-difficulty layout and timing constants.
///
/// These are the source-of-truth values for the domain layer.
/// The Drift [GameConfigs] table is seeded from these same numbers.
extension DifficultyConfig on Difficulty {
  // ── Memory Matching ──────────────────────────────────────────────────────

  /// Number of card grid columns.
  int get gridColumns => switch (this) {
        Difficulty.easy => 3,
        Difficulty.medium => 4,
        Difficulty.hard => 4,
      };

  /// Number of card grid rows.
  int get gridRows => switch (this) {
        Difficulty.easy => 4,
        Difficulty.medium => 4,
        Difficulty.hard => 5,
      };

  /// Total card pairs = (gridColumns × gridRows) / 2.
  int get totalPairs => (gridColumns * gridRows) ~/ 2;

  /// Total cards on the board = gridColumns × gridRows.
  int get totalCards => gridColumns * gridRows;

  // ── Pattern Recognition ──────────────────────────────────────────────────

  /// Number of rounds per Pattern Recognition session.
  int get totalRounds => switch (this) {
        Difficulty.easy => 5,
        Difficulty.medium => 8,
        Difficulty.hard => 12,
      };

  // ── Shared ────────────────────────────────────────────────────────────────

  /// Maximum session duration in seconds. 0 means no hard limit.
  int get timeLimitSeconds => switch (this) {
        Difficulty.easy => 180,
        Difficulty.medium => 120,
        Difficulty.hard => 90,
      };

  /// Milliseconds each sequence tile is shown (Pattern Recognition reveal)
  /// or milliseconds a matched card pair highlights before settling (Memory Matching).
  int get revealDurationMs => switch (this) {
        Difficulty.easy => 1200,
        Difficulty.medium => 900,
        Difficulty.hard => 600,
      };

  /// Human-readable label for the difficulty selector UI.
  String get displayLabel => switch (this) {
        Difficulty.easy => 'Easy',
        Difficulty.medium => 'Medium',
        Difficulty.hard => 'Hard',
      };
}

/// Value object wrapping [Difficulty] for use in domain entities.
///
/// Equatable so entities that contain it compare by value correctly.
final class DifficultyValue extends Equatable {
  const DifficultyValue(this.level);

  final Difficulty level;

  @override
  List<Object?> get props => [level];

  @override
  String toString() => 'DifficultyValue(${level.value})';
}
