import 'package:equatable/equatable.dart';

/// The two games owned by this module.
///
/// Adding a third game requires:
///   1. Add a new enum value here.
///   2. Implement a new [FlameGame] subclass (Milestone 7 pattern).
///   3. Seed new [GameConfigs] rows in AppDatabase.
///   No other files need changes.
enum GameType {
  memoryMatching,
  patternRecognition;

  /// Deserialises the string stored in Drift rows.
  static GameType fromString(final String value) {
    return switch (value) {
      'memory_matching' => GameType.memoryMatching,
      'pattern_recognition' => GameType.patternRecognition,
      _ => throw ArgumentError('Unknown GameType value: $value'),
    };
  }

  /// Serialises to the string stored in Drift rows and future API payloads.
  String get value => switch (this) {
        GameType.memoryMatching => 'memory_matching',
        GameType.patternRecognition => 'pattern_recognition',
      };

  /// Human-readable label for game selection UI.
  String get displayLabel => switch (this) {
        GameType.memoryMatching => 'Memory Matching',
        GameType.patternRecognition => 'Pattern Recognition',
      };
}

/// Value object wrapping [GameType].
final class GameTypeValue extends Equatable {
  const GameTypeValue(this.type);

  final GameType type;

  @override
  List<Object?> get props => [type];

  @override
  String toString() => 'GameTypeValue(${type.value})';
}
