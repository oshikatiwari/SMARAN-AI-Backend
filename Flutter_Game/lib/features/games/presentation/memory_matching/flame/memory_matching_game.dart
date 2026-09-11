import 'dart:async';
import 'dart:ui' show Color;

import 'package:flame/components.dart';
import 'package:flame/game.dart';

import 'package:cognitive_care_games/features/games/domain/entities/game_config.dart';
import 'package:cognitive_care_games/features/games/presentation/providers/game_event_bus.dart';
import 'components/card_grid_component.dart';
import 'components/match_controller.dart';

/// The Memory Matching [FlameGame].
///
/// Architecture:
///   - Receives [config] and [eventBus] via constructor — no Riverpod reads.
///   - Builds [CardGridComponent] on load.
///   - Listens for [CardFlippedEvent] from cards and drives [MatchController].
///   - Emits [CardMatchedEvent], [CardMismatchedEvent], [GameCompleteEvent],
///     and [HintRequestedEvent] to [eventBus] — [MetricsStateNotifier] consumes them.
///
/// Win condition (Milestone 8):
///   When [MatchController.isGameComplete] is true after a successful match,
///   [_onGameComplete()] fires [GameCompleteEvent].
///
/// Mismatch delay:
///   Uses a [TimerComponent] to wait [config.revealDurationMs] before flipping
///   mismatched cards back. This prevents the game from feeling jerky.
///
/// Flutter HUD:
///   The HUD (timer, attempts, errors) is a Flutter overlay — NOT rendered by
///   Flame. The game screen uses a sibling Positioned widget in the Stack.
class MemoryMatchingGame extends FlameGame {
  MemoryMatchingGame({
    required this.config,
    required this.eventBus,
  });

  final GameConfig config;
  final GameEventBus eventBus;

  late CardGridComponent _grid;
  late MatchController _matchController;

  /// Subscription to [eventBus.stream] — stored so it can be cancelled in
  /// [onRemove] and avoid dangling listeners after the game is disposed.
  StreamSubscription<GameEvent>? _eventSubscription;

  /// Milliseconds since session started. Updated every frame.
  int _elapsedMs = 0;

  /// Whether the game has ended (prevents duplicate GameCompleteEvent).
  bool _isGameOver = false;

  // ── Mismatch delay timer ───────────────────────────────────────────────────
  TimerComponent? _mismatchTimer;
  int? _mismatchCardId1;
  int? _mismatchCardId2;

  // ── Hint tracking (updated by onHintRequested) ────────────────────────────
  int _hintsUsed = 0;

  // ── FlameGame overrides ────────────────────────────────────────────────────

  @override
  Color backgroundColor() => const Color(0xFFE8E8E0); // AppColors.gameBoard

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    _matchController = MatchController(totalPairs: config.totalPairs);

    _grid = CardGridComponent(
      config: config,
      eventBus: eventBus,
      canvasSize: size,
    );
    await add(_grid);

    // Subscribe to card flip events from the bus.
    // The subscription is stored and cancelled in onRemove().
    _eventSubscription = eventBus.stream.listen((final event) {
      if (event is CardFlippedEvent) {
        _onCardFlipped(event.cardId);
      }
    });
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

  // ── Game logic ─────────────────────────────────────────────────────────────

  void _onCardFlipped(final int cardId) {
    final card = _grid.cardById(cardId);
    if (card == null) return;

    final result = _matchController.registerFlip(
      cardId: cardId,
      pairId: card.pairId,
    );

    switch (result.type) {
      case FlipResultType.firstCard:
        // Nothing to evaluate yet — wait for second tap.
        break;

      case FlipResultType.match:
        _grid.setTapBlocked(true);
        _onMatch(result);

      case FlipResultType.mismatch:
        _grid.setTapBlocked(true);
        _onMismatch(result);

      case FlipResultType.blocked:
        // Defensive — should never reach here because CardComponent checks
        // isTapBlocked before firing the event.
        break;
    }
  }

  void _onMatch(final FlipResult result) {
    final card1 = _grid.cardById(result.cardId1!);
    final card2 = _grid.cardById(result.cardId2!);

    card1?.markMatched();
    card2?.markMatched();

    _matchController.confirmMatch();
    _grid.setTapBlocked(false);

    eventBus.sink.add(CardMatchedEvent(
      cardId1: result.cardId1!,
      cardId2: result.cardId2!,
      attemptNumber: result.attemptNumber!,
    ));

    if (_matchController.isGameComplete) {
      _onGameComplete();
    }
  }

  void _onMismatch(final FlipResult result) {
    final card1 = _grid.cardById(result.cardId1!);
    final card2 = _grid.cardById(result.cardId2!);

    card1?.markMismatched();
    card2?.markMismatched();

    _mismatchCardId1 = result.cardId1;
    _mismatchCardId2 = result.cardId2;

    eventBus.sink.add(CardMismatchedEvent(
      cardId1: result.cardId1!,
      cardId2: result.cardId2!,
      attemptNumber: result.attemptNumber!,
    ));

    // Wait revealDurationMs, then flip the cards back.
    final delaySeconds = config.revealDurationMs / 1000.0;
    _mismatchTimer?.removeFromParent();
    _mismatchTimer = TimerComponent(
      period: delaySeconds,
      onTick: _onMismatchDelayComplete,
      removeOnFinish: true,
    );
    add(_mismatchTimer!);
  }

  void _onMismatchDelayComplete() {
    final card1 = _grid.cardById(_mismatchCardId1 ?? -1);
    final card2 = _grid.cardById(_mismatchCardId2 ?? -1);

    card1?.flipBack();
    card2?.flipBack();

    _matchController.confirmMismatch();
    _grid.setTapBlocked(false);

    _mismatchCardId1 = null;
    _mismatchCardId2 = null;
  }

  void _onGameComplete() {
    if (_isGameOver) return;
    _isGameOver = true;

    eventBus.sink.add(GameCompleteEvent(
      elapsedMs: _elapsedMs,
      totalAttempts: _matchController.attemptNumber,
      totalErrors: _matchController.attemptNumber - _matchController.matchedPairs,
      hintsUsed: _hintsUsed,
      completionRate: 1.0,
    ));
  }

  /// Called by the Flutter HUD's hint button (via overlay callback).
  ///
  /// Briefly reveals all unmatched face-down cards for [config.revealDurationMs].
  void onHintRequested() {
    if (_isGameOver) return;

    _hintsUsed++;

    // Reveal unmatched face-down cards momentarily.
    final unmatchedFaceDown = _grid.cards
        .where((final c) => !c.isMatched && !c.isFaceUp)
        .toList();

    for (final card in unmatchedFaceDown) {
      card.reveal();
    }

    eventBus.sink.add(HintRequestedEvent(hintsUsedSoFar: _hintsUsed));

    // After reveal duration, flip them back (if not tapped by player).
    final delaySeconds = config.revealDurationMs / 1000.0;
    final hintTimer = TimerComponent(
      period: delaySeconds,
      onTick: () {
        for (final card in unmatchedFaceDown) {
          if (!card.isMatched && card.isFaceUp) {
            card.markMismatched();
            card.flipBack();
          }
        }
      },
      removeOnFinish: true,
    );
    add(hintTimer);
  }

  /// Called by the Flutter HUD's Quit button.
  void onAbandon() {
    if (_isGameOver) return;
    _isGameOver = true;

    final completedPairs = _matchController.matchedPairs;
    final completionRate = config.totalPairs > 0
        ? completedPairs / config.totalPairs
        : 0.0;

    eventBus.sink.add(GameAbandonedEvent(
      elapsedMs: _elapsedMs,
      completionRate: completionRate,
    ));
  }
}
