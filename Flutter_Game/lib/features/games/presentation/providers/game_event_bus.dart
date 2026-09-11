import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

// ── Game Event Types ──────────────────────────────────────────────────────────

/// Sealed class hierarchy for all events a Flame game can emit.
///
/// Design decisions:
///   - Sealed so the compiler enforces exhaustive handling in switch statements.
///   - No Flutter or Drift imports — pure Dart so Flame components can import
///     this file without pulling in the Flutter framework.
///   - Events carry only primitive data (ints, bools, strings) so they can
///     cross the Flame/Flutter boundary safely.
///
/// Flame components call: [GameEventBus.sink.add(SomeGameEvent(...))]
/// Riverpod notifiers call: [GameEventBus.stream.listen(...)]
sealed class GameEvent {
  const GameEvent();
}

/// Fired by [CardComponent] when the player taps a face-down card.
final class CardFlippedEvent extends GameEvent {
  const CardFlippedEvent({required this.cardId});

  /// The unique id of the card that was tapped (index in the grid).
  final int cardId;
}

/// Fired by [MatchController] when two flipped cards match.
final class CardMatchedEvent extends GameEvent {
  const CardMatchedEvent({
    required this.cardId1,
    required this.cardId2,
    required this.attemptNumber,
  });

  final int cardId1;
  final int cardId2;
  final int attemptNumber;
}

/// Fired by [MatchController] when two flipped cards do NOT match.
final class CardMismatchedEvent extends GameEvent {
  const CardMismatchedEvent({
    required this.cardId1,
    required this.cardId2,
    required this.attemptNumber,
  });

  final int cardId1;
  final int cardId2;
  final int attemptNumber;
}

/// Fired when the player taps the hint button (reveals un-matched cards briefly).
final class HintRequestedEvent extends GameEvent {
  const HintRequestedEvent({required this.hintsUsedSoFar});

  final int hintsUsedSoFar;
}

/// Fired by [PatternController] when the player submits a correct answer.
final class CorrectAnswerEvent extends GameEvent {
  const CorrectAnswerEvent({
    required this.roundNumber,
    required this.attemptNumber,
  });

  final int roundNumber;
  final int attemptNumber;
}

/// Fired by [PatternController] when the player submits an incorrect answer.
final class IncorrectAnswerEvent extends GameEvent {
  const IncorrectAnswerEvent({
    required this.roundNumber,
    required this.attemptNumber,
  });

  final int roundNumber;
  final int attemptNumber;
}

/// Fired by either game when all win conditions are met.
/// This event triggers the full session-end → metrics-persist flow.
final class GameCompleteEvent extends GameEvent {
  const GameCompleteEvent({
    required this.elapsedMs,
    required this.totalAttempts,
    required this.totalErrors,
    required this.hintsUsed,
    required this.completionRate,
  });

  final int elapsedMs;
  final int totalAttempts;
  final int totalErrors;
  final int hintsUsed;

  /// 1.0 if fully completed, < 1.0 if abandoned mid-game.
  final double completionRate;
}

/// Fired when the player explicitly quits mid-session.
final class GameAbandonedEvent extends GameEvent {
  const GameAbandonedEvent({
    required this.elapsedMs,
    required this.completionRate,
  });

  final int elapsedMs;
  final double completionRate;
}

/// Fired when the player taps an answer tile in Pattern Recognition.
/// Consumed only by [PatternRecognitionGame] — not by [MetricsStateNotifier].
final class PatternTileSelectedEvent extends GameEvent {
  const PatternTileSelectedEvent({
    required this.tileIndex,
    required this.symbol,
  });

  final int tileIndex;
  final String symbol;
}

// ── GameEventBus ──────────────────────────────────────────────────────────────

/// Single-direction event channel from Flame → Riverpod.
///
/// Lifecycle:
///   - Created once per game screen via [gameEventBusProvider].
///   - Passed into the [FlameGame] constructor as a plain Dart object
///     (Flame never imports Riverpod).
///   - [MetricsStateNotifier] subscribes to [stream] in its [build()] method.
///   - [SessionStateNotifier] subscribes to [GameCompleteEvent] and
///     [GameAbandonedEvent] to trigger persistence.
///   - Disposed when the game screen's [ProviderScope] subtree is unmounted
///     (stream subscription is cancelled by Riverpod's ref.onDispose).
///
/// Thread safety: Flame runs on the main isolate. Events are synchronous.
/// Using a broadcast stream (not a single-subscriber stream) so multiple
/// notifiers can listen simultaneously.
class GameEventBus {
  GameEventBus() : _controller = StreamController<GameEvent>.broadcast();

  final StreamController<GameEvent> _controller;

  /// Add an event from Flame. Called by Flame components on the main thread.
  StreamSink<GameEvent> get sink => _controller.sink;

  /// Subscribe to events from Riverpod notifiers.
  Stream<GameEvent> get stream => _controller.stream;

  /// Releases the stream controller. Called by [gameEventBusProvider]'s
  /// ref.onDispose callback.
  void dispose() => _controller.close();
}

// ── Provider ─────────────────────────────────────────────────────────────────

/// Provides a fresh [GameEventBus] scoped to the game screen.
///
/// Each game screen should override this provider (or use autoDispose)
/// so the bus is freshly created for every game session and destroyed
/// when the screen is popped.
final gameEventBusProvider = Provider.autoDispose<GameEventBus>((final ref) {
  final bus = GameEventBus();
  ref.onDispose(bus.dispose);
  return bus;
});
