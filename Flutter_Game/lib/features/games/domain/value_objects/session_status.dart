import 'package:equatable/equatable.dart';

/// Lifecycle state of a [GameSession].
///
/// Transitions:
///   inProgress → completed   (player finishes all pairs/rounds)
///   inProgress → abandoned   (player quits mid-session)
///
/// [abandoned] sessions still have their partial metrics persisted so
/// completionRate can reflect partial play.
enum SessionStatus {
  inProgress,
  completed,
  abandoned;

  /// Deserialises from the Drift column string.
  static SessionStatus fromString(final String value) {
    return switch (value) {
      'in_progress' => SessionStatus.inProgress,
      'completed' => SessionStatus.completed,
      'abandoned' => SessionStatus.abandoned,
      _ => throw ArgumentError('Unknown SessionStatus value: $value'),
    };
  }

  /// Serialises to the Drift column string.
  String get value => switch (this) {
        SessionStatus.inProgress => 'in_progress',
        SessionStatus.completed => 'completed',
        SessionStatus.abandoned => 'abandoned',
      };

  /// Whether this status represents a terminal state (no further transitions).
  bool get isTerminal =>
      this == SessionStatus.completed || this == SessionStatus.abandoned;
}

/// Value object wrapping [SessionStatus].
final class SessionStatusValue extends Equatable {
  const SessionStatusValue(this.status);

  final SessionStatus status;

  @override
  List<Object?> get props => [status];

  @override
  String toString() => 'SessionStatusValue(${status.value})';
}
