import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flutter/material.dart'
    show Paint, PaintingStyle, RRect, Rect, Radius, TextDirection, TextPainter, TextSpan, TextStyle;

import 'package:cognitive_care_games/features/games/presentation/providers/game_event_bus.dart';
import 'package:cognitive_care_games/features/games/presentation/shared/design_system/app_colors.dart';
import 'package:cognitive_care_games/features/games/presentation/shared/design_system/app_dimensions.dart';
import 'card_flip_animation.dart';

/// Card states that drive visual rendering.
enum CardState {
  /// Face-down and interactive — player has not yet tapped this card.
  faceDown,

  /// Mid-flip animation (either revealing or hiding).
  flipping,

  /// Face-up and awaiting match evaluation.
  revealed,

  /// Matched — stays face-up permanently, slightly highlighted.
  matched,

  /// Mismatched — face-up briefly, then flips back to faceDown.
  mismatched,
}

/// A single interactive card in the Memory Matching game.
///
/// Responsibilities:
///   - Renders face-down (card back) or face-up (card symbol) based on state.
///   - Drives [CardFlipAnimation] on each tap.
///   - Fires [CardFlippedEvent] on the [GameEventBus] when tapped.
///   - Accepts [onTapBlocked] from [CardGridComponent] to prevent tapping
///     while two cards are already face-up.
///
/// Flame design:
///   Extends [PositionComponent] + [TapCallbacks] — no game-loop coupling.
///   [MemoryMatchingGame] positions this component; it does not position itself.
///
/// Minimum size: [AppDimensions.cardMinWidth] × [AppDimensions.cardMinHeight]
/// enforced at construction time in [CardGridComponent].
class CardComponent extends PositionComponent with TapCallbacks {
  CardComponent({
    required this.cardId,
    required this.pairId,
    required this.symbol,
    required this.eventBus,
    super.position,
    super.size,
  }) : _flipAnimation = CardFlipAnimation(flipDurationSeconds: 0.35);

  /// Unique index within the grid (0..N-1). Used to identify the card in events.
  final int cardId;

  /// Identifies which pair this card belongs to (0..totalPairs-1).
  /// Two cards with the same [pairId] are a match.
  final int pairId;

  /// The symbol displayed on this card's face (emoji, letter, or number).
  final String symbol;

  /// Event bus reference — injected by [CardGridComponent].
  /// The card never imports Riverpod directly.
  final GameEventBus eventBus;

  CardState _state = CardState.faceDown;
  final CardFlipAnimation _flipAnimation;

  /// Set to true by [CardGridComponent] when two cards are currently
  /// face-up awaiting evaluation. Prevents a third card from being tapped.
  bool isTapBlocked = false;

  // ── State API (called by MatchController via MemoryMatchingGame) ──────────

  CardState get state => _state;
  bool get isFaceUp => _flipAnimation.isFaceUp;
  bool get isMatched => _state == CardState.matched;

  /// Flip the card face-up (called when player taps it).
  void reveal() {
    if (_state != CardState.faceDown) return;
    _state = CardState.flipping;
    _flipAnimation.startFlip(toFaceUp: true);
  }

  /// Called after mismatch evaluation — flips the card back face-down.
  void flipBack() {
    if (_state != CardState.mismatched) return;
    _state = CardState.flipping;
    _flipAnimation.startFlip(toFaceUp: false);
  }

  /// Called when this card is part of a successful match.
  void markMatched() {
    _state = CardState.matched;
  }

  /// Called by [MatchController] when this card is in a mismatched pair.
  void markMismatched() {
    _state = CardState.mismatched;
  }

  // ── Flame overrides ────────────────────────────────────────────────────────

  @override
  void update(final double dt) {
    super.update(dt);
    _flipAnimation.update(dt);

    // Once a flip animation completes, settle into the correct logical state.
    if (!_flipAnimation.isAnimating && _state == CardState.flipping) {
      _state = _flipAnimation.isFaceUp ? CardState.revealed : CardState.faceDown;
    }
  }

  @override
  void render(final Canvas canvas) {
    final rect = Rect.fromLTWH(0, 0, size.x, size.y);
    final rrect = RRect.fromRectAndRadius(
      rect,
      const Radius.circular(AppDimensions.cardBorderRadius),
    );

    // Apply horizontal squish for flip animation
    final scaleX = _flipAnimation.scaleX;
    canvas.save();
    canvas.translate(size.x / 2, size.y / 2);
    canvas.scale(scaleX, 1.0);
    canvas.translate(-size.x / 2, -size.y / 2);

    if (_flipAnimation.isFaceUp) {
      _renderFace(canvas, rrect);
    } else {
      _renderBack(canvas, rrect);
    }

    canvas.restore();
  }

  void _renderBack(final Canvas canvas, final RRect rrect) {
    // Card back: deep blue with subtle pattern dots
    final bgPaint = Paint()
      ..color = _state == CardState.matched
          ? AppColors.cardMatched
          : AppColors.cardBack;
    canvas.drawRRect(rrect, bgPaint);

    // Dot pattern on back
    final dotPaint = Paint()
      ..color = AppColors.cardBackPattern
      ..style = PaintingStyle.fill;

    final dotRadius = size.x * 0.05;
    final spacing = size.x * 0.25;
    for (var row = 1; row <= 2; row++) {
      for (var col = 1; col <= 2; col++) {
        canvas.drawCircle(
          Offset(col * spacing, row * (size.y * 0.33)),
          dotRadius,
          dotPaint,
        );
      }
    }
  }

  void _renderFace(final Canvas canvas, final RRect rrect) {
    // Card face background
    Color bgColor;
    switch (_state) {
      case CardState.matched:
        bgColor = AppColors.cardMatched.withAlpha(50);
      case CardState.mismatched:
        bgColor = AppColors.cardMismatched.withAlpha(50);
      default:
        bgColor = AppColors.cardFace;
    }

    final bgPaint = Paint()..color = bgColor;
    canvas.drawRRect(rrect, bgPaint);

    // Border
    final borderColor = _state == CardState.matched
        ? AppColors.cardMatched
        : _state == CardState.mismatched
            ? AppColors.cardMismatched
            : AppColors.cardFaceBorder;
    final borderPaint = Paint()
      ..color = borderColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = AppDimensions.cardBorderWidth;
    canvas.drawRRect(rrect, borderPaint);

    // Symbol text — drawn using a TextPainter
    _drawSymbol(canvas);
  }

  void _drawSymbol(final Canvas canvas) {
    final textPainter = TextPainter(
      text: TextSpan(
        text: symbol,
        style: TextStyle(
          fontSize: size.x * 0.45,
          color: _state == CardState.matched
              ? AppColors.cardMatched
              : AppColors.textPrimary,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();

    textPainter.paint(
      canvas,
      Offset(
        (size.x - textPainter.width) / 2,
        (size.y - textPainter.height) / 2,
      ),
    );
  }

  // ── Tap handling ───────────────────────────────────────────────────────────

  @override
  void onTapDown(final TapDownEvent event) {
    // Ignore taps if blocked, already face-up, or matched.
    if (isTapBlocked) return;
    if (_state != CardState.faceDown) return;

    eventBus.sink.add(CardFlippedEvent(cardId: cardId));
    reveal();
  }
}
