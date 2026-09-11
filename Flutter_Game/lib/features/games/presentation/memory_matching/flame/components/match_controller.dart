/// Pure-Dart match evaluation engine for the Memory Matching game.
///
/// No Flame, Flutter, or Drift imports. Fully unit-testable in isolation.
///
/// Responsibilities:
///   - Tracks which cards are currently face-up and awaiting evaluation.
///   - Determines match / mismatch when the second card is flipped.
///   - Tracks total pairs matched and attempt count.
///   - Reports win condition via [isGameComplete].
///
/// The [MemoryMatchingGame] calls [registerFlip] and acts on the returned
/// [FlipResult], then emits the appropriate [GameEvent] to the bus.
final class MatchController {
  MatchController({required this.totalPairs});

  final int totalPairs;

  int _matchedPairs = 0;
  int _attemptNumber = 0;

  /// The first card flipped this turn (cardId, pairId). Null between turns.
  _PendingFlip? _firstFlip;

  /// Whether the controller is currently waiting for the mismatch delay
  /// (two face-up, non-matching cards visible). During this window,
  /// [CardComponent.isTapBlocked] must be true.
  bool _isEvaluating = false;

  // ── Public API ─────────────────────────────────────────────────────────────

  int get matchedPairs => _matchedPairs;
  int get attemptNumber => _attemptNumber;
  bool get isGameComplete => _matchedPairs >= totalPairs;
  bool get isEvaluating => _isEvaluating;

  /// Called when a card is tapped (after [CardComponent.reveal()] is called).
  ///
  /// Returns a [FlipResult] describing what happened:
  ///   [FlipResult.firstCard]  — first card of a new turn, no evaluation yet.
  ///   [FlipResult.match]      — both cards match; [MemoryMatchingGame] should
  ///                              call [confirmMatch] after marking cards.
  ///   [FlipResult.mismatch]   — cards don't match; game should wait
  ///                              [revealDurationMs] then call [confirmMismatch].
  ///
  /// If [isEvaluating] is true, returns [FlipResult.blocked] — the caller
  /// should not have allowed the tap (defensive guard).
  FlipResult registerFlip({
    required final int cardId,
    required final int pairId,
  }) {
    if (_isEvaluating) return FlipResult.blocked();

    if (_firstFlip == null) {
      // First card of the turn.
      _firstFlip = _PendingFlip(cardId: cardId, pairId: pairId);
      return FlipResult.firstCard(cardId: cardId);
    }

    // Second card — evaluate.
    final first = _firstFlip!;
    _firstFlip = null;
    _attemptNumber++;
    _isEvaluating = true;

    if (first.pairId == pairId) {
      return FlipResult.match(
        cardId1: first.cardId,
        cardId2: cardId,
        attemptNumber: _attemptNumber,
      );
    } else {
      return FlipResult.mismatch(
        cardId1: first.cardId,
        cardId2: cardId,
        attemptNumber: _attemptNumber,
      );
    }
  }

  /// Called after a matched pair has been visually confirmed (cards stay up).
  void confirmMatch() {
    _matchedPairs++;
    _isEvaluating = false;
  }

  /// Called after the mismatch delay has elapsed (cards have flipped back).
  void confirmMismatch() {
    _isEvaluating = false;
  }

  /// Resets to initial state — called when the player restarts.
  void reset() {
    _matchedPairs = 0;
    _attemptNumber = 0;
    _firstFlip = null;
    _isEvaluating = false;
  }
}

// ── Supporting types ──────────────────────────────────────────────────────────

final class _PendingFlip {
  const _PendingFlip({required this.cardId, required this.pairId});

  final int cardId;
  final int pairId;
}

/// Result of [MatchController.registerFlip].
final class FlipResult {
  const FlipResult._({
    required this.type,
    this.cardId1,
    this.cardId2,
    this.attemptNumber,
  });

  factory FlipResult.firstCard({required final int cardId}) =>
      FlipResult._(type: FlipResultType.firstCard, cardId1: cardId);

  factory FlipResult.match({
    required final int cardId1,
    required final int cardId2,
    required final int attemptNumber,
  }) =>
      FlipResult._(
        type: FlipResultType.match,
        cardId1: cardId1,
        cardId2: cardId2,
        attemptNumber: attemptNumber,
      );

  factory FlipResult.mismatch({
    required final int cardId1,
    required final int cardId2,
    required final int attemptNumber,
  }) =>
      FlipResult._(
        type: FlipResultType.mismatch,
        cardId1: cardId1,
        cardId2: cardId2,
        attemptNumber: attemptNumber,
      );

  factory FlipResult.blocked() =>
      const FlipResult._(type: FlipResultType.blocked);

  final FlipResultType type;
  final int? cardId1;
  final int? cardId2;
  final int? attemptNumber;

  bool get isMatch => type == FlipResultType.match;
  bool get isMismatch => type == FlipResultType.mismatch;
  bool get isFirstCard => type == FlipResultType.firstCard;
}

enum FlipResultType { firstCard, match, mismatch, blocked }
