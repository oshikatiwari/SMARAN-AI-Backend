import 'package:equatable/equatable.dart';

/// The types of pattern sequences available in the Pattern Recognition game.
///
/// Extensibility contract:
///   To add a new pattern type (e.g. spatial, musical):
///     1. Add a new enum value here.
///     2. Add a case to [PatternController._generateSequence()] (Milestone 9).
///     3. No other files need changes — the interface is closed to modification,
///        open to extension.
///
/// Current types:
///   [numeric]  — arithmetic sequences (e.g. 2, 4, 6, ?)
///   [color]    — color repetition patterns (e.g. Red, Blue, Red, ?)
///   [shape]    — geometric shape patterns (e.g. Circle, Square, Triangle, ?)
enum PatternType {
  numeric,
  color,
  shape;

  /// Deserialises from a stored string value.
  static PatternType fromString(final String value) {
    return switch (value) {
      'numeric' => PatternType.numeric,
      'color' => PatternType.color,
      'shape' => PatternType.shape,
      _ => throw ArgumentError('Unknown PatternType value: $value'),
    };
  }

  /// Serialises to a stored string value.
  String get value => name;

  /// Human-readable label for the pattern type selector.
  String get displayLabel => switch (this) {
        PatternType.numeric => 'Numbers',
        PatternType.color => 'Colors',
        PatternType.shape => 'Shapes',
      };

  /// Description shown to the player before a round begins.
  String get instruction => switch (this) {
        PatternType.numeric => 'What number comes next?',
        PatternType.color => 'What color comes next?',
        PatternType.shape => 'What shape comes next?',
      };
}

/// Value object wrapping [PatternType].
final class PatternTypeValue extends Equatable {
  const PatternTypeValue(this.type);

  final PatternType type;

  @override
  List<Object?> get props => [type];

  @override
  String toString() => 'PatternTypeValue(${type.value})';
}
