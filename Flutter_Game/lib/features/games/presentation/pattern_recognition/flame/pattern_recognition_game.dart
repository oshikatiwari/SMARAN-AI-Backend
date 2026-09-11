import 'dart:async';

import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart' show Color;

import 'package:cognitive_care_games/features/games/domain/entities/game_config.dart';
import 'package:cognitive_care_games/features/games/domain/value_objects/pattern_type.dart';
import 'package:cognitive_care_games/features/games/presentation/providers/game_event_bus.dart';
import 'components/answer_row_component.dart';
import 'components/pattern_controller.dart';
import 'components/sequence_display_component.dart';
import 'components/sequence_tile_component.dart' show SequenceTileComponent;

/// The Pattern Recognition [FlameGame].
///
/// Architecture:
///   - Receives [config], [patternType], and [eventBus] via constructor.
///   - Drives [PatternController] for sequence generation and answer validation.
///   - Shows [SequenceDisplayComponent] → waits for reveal → enables
///     [AnswerRowComponent] → player taps → emits result event.
///   - Emits [CorrectAnswerEvent], [IncorrectAnswerEvent], [HintRequestedEvent],
///     [GameCompleteEvent], and [GameAbandonedEvent] to [eventBus].
///
/// Round lifecycle:
///   _startRound() → reveal animation → _onRevealComplete() →
///   player taps tile → _onTileSelected() → show result →
///   wait [revealDurationMs] → _startRound() (or _onGameComplete())
class PatternRecognitionGame extends FlameGame {
  PatternRecognitionGame({
    required this.config,
    required this.patternType,
    required this.eventBus,
  });

  final GameConfig config;
  final PatternType patternType;
  final GameEventBus eventBus;

  late PatternController _controller;

  SequenceDisplayComponent? _displayComponent;
  AnswerRowComponent? _answerRow;

  /// Subscription to [eventBus.stream] — stored so it can be cancelled in
  /// [onRemove] and avoid dangling listeners after the game is disposed.
  StreamSubscription<GameEvent>? _eventSubscription;

  int _elapsedMs = 0;
  bool _isGameOver = false;
  int _hintsUsed = 0;

  // ── FlameGame overrides ────────────────────────────────────────────────────

  @override
  Color backgroundColor() => const Color(0xFFE8E8E0);

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    _controller = PatternController(
      difficulty: config.difficulty,
      patternType: patternType,
    );

    // Subscribe to tile-selected events from SequenceTileComponent.
    // The subscription is stored and cancelled in onRemove().
    _eventSubscription = eventBus.stream.listen((final event) {
      if (event is PatternTileSelectedEvent) {
        _onTileSelected(event.symbol);
      }
    });

    _startRound();
  }

  @override
  void onRemove() {
    _eventSubscription?.cancel();
    _eventSubscription = null;
    super.onRemove();
  }

  @override
  void update(final double dt) {
    super.update(dt);
    if (!_isGameOver) {
      _elapsedMs += (dt * 1000).round();
    }
  }

  // ── Round management ───────────────────────────────────────────────────────

  void _startRound() {
    // Remove previous round's components.
    _displayComponent?.removeFromParent();
    _answerRow?.removeFromParent();

    final round = _controller.nextRound();
    if (round == null) {
      _onGameComplete();
      return;
    }

    // Build sequence display.
    _displayComponent = SequenceDisplayComponent(
      sequence: round.sequence,
      canvasSize: size,
      revealDurationMs: config.revealDurationMs,
      onRevealComplete: _onRevealComplete,
      eventBus: eventBus,
    );
    add(_displayComponent!);

    // Build answer row (disabled until reveal completes).
    _answerRow = AnswerRowComponent(
      options: round.options,
      canvasSize: size,
      eventBus: eventBus,
    );
    add(_answerRow!);
  }

  void _onRevealComplete() {
    _answerRow?.enable();
  }

  void _onTileSelected(final String selectedSymbol) {
    final round = _controller.activeRound;
    if (round == null || _isGameOver) return;

    // Disable answer row immediately to prevent double-tap.
    _answerRow?.disable();

    final result = _controller.submitAnswer(selectedSymbol);

    // Show visual result on answer row.
    _answerRow?.showResult(
      selectedValue: selectedSymbol,
      correctValue: round.correctAnswer,
      isCorrect: result.isCorrect,
    );

    // Also reveal the correct answer on the sequence display.
    _displayComponent?.showAnswer(round.correctAnswer);

    if (result.isCorrect) {
      eventBus.sink.add(CorrectAnswerEvent(
        roundNumber: result.roundNumber,
        attemptNumber: result.attemptNumber,
      ));
    } else {
      eventBus.sink.add(IncorrectAnswerEvent(
        roundNumber: result.roundNumber,
        attemptNumber: result.attemptNumber,
      ));
    }

    // Wait revealDurationMs then start next round.
    final delaySeconds = config.revealDurationMs / 1000.0;
    add(
      TimerComponent(
        period: delaySeconds,
        onTick: () {
          if (!_isGameOver) _startRound();
        },
        removeOnFinish: true,
      ),
    );
  }

  // ── Completion ─────────────────────────────────────────────────────────────

  void _onGameComplete() {
    if (_isGameOver) return;
    _isGameOver = true;

    eventBus.sink.add(GameCompleteEvent(
      elapsedMs: _elapsedMs,
      totalAttempts: _controller.totalAttempts,
      totalErrors: _controller.errors,
      hintsUsed: _hintsUsed,
      completionRate: 1.0,
    ));
  }

  /// Called by the Flutter HUD hint button.
  void onHintRequested() {
    if (_isGameOver) return;
    final round = _controller.activeRound;
    if (round == null) return;

    _hintsUsed++;
    eventBus.sink.add(HintRequestedEvent(hintsUsedSoFar: _hintsUsed));

    // Re-highlight the sequence tiles briefly.
    _displayComponent?.children
        .whereType<SequenceTileComponent>()
        .forEach((final t) => t.highlight());

    add(TimerComponent(
      period: config.revealDurationMs / 1000.0 * 0.6,
      onTick: () => _displayComponent?.children
          .whereType<SequenceTileComponent>()
          .forEach((final t) => t.resetToNormal()),
      removeOnFinish: true,
    ));
  }

  /// Called by the Flutter HUD Quit button.
  void onAbandon() {
    if (_isGameOver) return;
    _isGameOver = true;

    eventBus.sink.add(GameAbandonedEvent(
      elapsedMs: _elapsedMs,
      completionRate: _controller.completionRate,
    ));
  }
}
