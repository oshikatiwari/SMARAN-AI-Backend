import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:cognitive_care_games/features/games/presentation/providers/game_event_bus.dart';

// ── State ─────────────────────────────────────────────────────────────────────

/// Accumulates in-session metrics as the game progresses.
final class MetricsState extends Equatable {
  const MetricsState({
    this.attempts = 0,
    this.errors = 0,
    this.hintsUsed = 0,
    this.elapsedMs = 0,
    this.isFinished = false,
    this.completionRate = 0.0,
  });

  final int attempts;
  final int errors;
  final int hintsUsed;
  final int elapsedMs;
  final bool isFinished;
  final double completionRate;

  int get correctAttempts => attempts - errors;

  double get accuracy =>
      attempts == 0 ? 0.0 : correctAttempts / attempts;

  MetricsState copyWith({
    int? attempts,
    int? errors,
    int? hintsUsed,
    int? elapsedMs,
    bool? isFinished,
    double? completionRate,
  }) =>
      MetricsState(
        attempts: attempts ?? this.attempts,
        errors: errors ?? this.errors,
        hintsUsed: hintsUsed ?? this.hintsUsed,
        elapsedMs: elapsedMs ?? this.elapsedMs,
        isFinished: isFinished ?? this.isFinished,
        completionRate: completionRate ?? this.completionRate,
      );

  @override
  List<Object?> get props =>
      [attempts, errors, hintsUsed, elapsedMs, isFinished, completionRate];
}

// ── Notifier ──────────────────────────────────────────────────────────────────

/// Riverpod 3.x: use Notifier<T> directly (autoDispose set on provider).
class MetricsStateNotifier extends Notifier<MetricsState> {
  @override
  MetricsState build() {
    final bus = ref.watch(gameEventBusProvider);
    final subscription = bus.stream.listen(_onEvent);
    ref.onDispose(subscription.cancel);
    return const MetricsState();
  }

  void _onEvent(final GameEvent event) {
    switch (event) {
      case CardFlippedEvent():
        break;

      case CardMatchedEvent(:final attemptNumber):
        state = state.copyWith(attempts: attemptNumber);

      case CardMismatchedEvent(:final attemptNumber):
        state = state.copyWith(
          attempts: attemptNumber,
          errors: state.errors + 1,
        );

      case HintRequestedEvent(:final hintsUsedSoFar):
        state = state.copyWith(hintsUsed: hintsUsedSoFar);

      case CorrectAnswerEvent(:final attemptNumber):
        state = state.copyWith(attempts: attemptNumber);

      case IncorrectAnswerEvent(:final attemptNumber):
        state = state.copyWith(
          attempts: attemptNumber,
          errors: state.errors + 1,
        );

      case GameCompleteEvent(
          :final elapsedMs,
          :final totalAttempts,
          :final totalErrors,
          :final hintsUsed,
          :final completionRate,
        ):
        state = state.copyWith(
          attempts: totalAttempts,
          errors: totalErrors,
          hintsUsed: hintsUsed,
          elapsedMs: elapsedMs,
          isFinished: true,
          completionRate: completionRate,
        );

      case GameAbandonedEvent(:final elapsedMs, :final completionRate):
        state = state.copyWith(
          elapsedMs: elapsedMs,
          isFinished: true,
          completionRate: completionRate,
        );

      // Consumed internally by PatternRecognitionGame — not a metrics signal.
      case PatternTileSelectedEvent():
        break;
    }
  }

  void reset() => state = const MetricsState();
}

/// autoDispose so state clears when the game screen is popped.
final metricsNotifierProvider =
    NotifierProvider.autoDispose<MetricsStateNotifier, MetricsState>(
  MetricsStateNotifier.new,
);

// ── Timer provider ─────────────────────────────────────────────────────────────

/// Live elapsed-seconds stream. autoDispose stops it when screen is popped.
final gameTimerProvider = StreamProvider.autoDispose<int>((final ref) {
  return Stream.periodic(
    const Duration(seconds: 1),
    (final tick) => tick + 1,
  );
});
