import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flutter/material.dart'
    show Paint, PaintingStyle, RRect, Rect, Radius, TextDirection, TextPainter, TextSpan, TextStyle;

import 'package:cognitive_care_games/features/games/presentation/providers/game_event_bus.dart';
import 'package:cognitive_care_games/features/games/presentation/shared/design_system/app_colors.dart';
import 'package:cognitive_care_games/features/games/presentation/shared/design_system/app_dimensions.dart';

/// Visual state of a [SequenceTileComponent].
enum TileState {
  /// Default — neutral appearance.
  normal,

  /// Highlighted during sequence reveal animation.
  highlighted,

  /// Player selected this answer option (before validation result).
  selected,

  /// Correct answer revealed after submission.
  correct,

  /// Incorrect answer revealed after submission.
  incorrect,

  /// Disabled — not interactive (display tiles, or locked answer row).
  disabled,
}

/// A single tile used in both the sequence display and the answer row.
///
/// Display tiles: [isInteractive] = false — just shows the symbol.
/// Answer tiles:  [isInteractive] = true — fires an event on tap.
///
/// Minimum size: [AppDimensions.tileMinSize] for display,
///               [AppDimensions.answerTileMinSize] for answer tiles.
class SequenceTileComponent extends PositionComponent with TapCallbacks {
  SequenceTileComponent({
    required this.symbol,
    required this.tileIndex,
    required this.isInteractive,
    required this.eventBus,
    super.position,
    super.size,
    TileState initialState = TileState.normal,
  }) : _state = initialState;

  final String symbol;

  /// Position within the sequence (0-indexed) or option index in answer row.
  final int tileIndex;

  final bool isInteractive;
  final GameEventBus eventBus;

  TileState _state;
  bool _tapEnabled = true;

  TileState get state => _state;

  // ── State API ──────────────────────────────────────────────────────────────

  void setState(final TileState newState) => _state = newState;

  void highlight() => _state = TileState.highlighted;
  void resetToNormal() => _state = TileState.normal;
  void markCorrect() => _state = TileState.correct;
  void markIncorrect() => _state = TileState.incorrect;
  void disable() {
    _state = TileState.disabled;
    _tapEnabled = false;
  }

  void enable() {
    _state = TileState.normal;
    _tapEnabled = true;
  }

  // ── Flame overrides ────────────────────────────────────────────────────────

  @override
  void render(final Canvas canvas) {
    final rect = Rect.fromLTWH(0, 0, size.x, size.y);
    final rrect = RRect.fromRectAndRadius(
      rect,
      const Radius.circular(AppDimensions.tileBorderRadius),
    );

    _drawBackground(canvas, rrect);
    _drawBorder(canvas, rrect);
    _drawSymbol(canvas);
  }

  void _drawBackground(final Canvas canvas, final RRect rrect) {
    final color = switch (_state) {
      TileState.normal => AppColors.tileDefault,
      TileState.highlighted => AppColors.tileSelected.withAlpha(180),
      TileState.selected => AppColors.tileSelected,
      TileState.correct => AppColors.tileCorrect,
      TileState.incorrect => AppColors.tileIncorrect,
      TileState.disabled => AppColors.tileDefault.withAlpha(100),
    };
    canvas.drawRRect(rrect, Paint()..color = color);
  }

  void _drawBorder(final Canvas canvas, final RRect rrect) {
    final borderColor = switch (_state) {
      TileState.correct => AppColors.success,
      TileState.incorrect => AppColors.error,
      TileState.highlighted || TileState.selected => AppColors.primary,
      _ => AppColors.border,
    };
    canvas.drawRRect(
      rrect,
      Paint()
        ..color = borderColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = AppDimensions.cardBorderWidth,
    );
  }

  void _drawSymbol(final Canvas canvas) {
    final textColor = switch (_state) {
      TileState.selected ||
      TileState.correct ||
      TileState.incorrect =>
        AppColors.onPrimary,
      TileState.disabled => AppColors.textDisabled,
      _ => AppColors.textPrimary,
    };

    final textPainter = TextPainter(
      text: TextSpan(
        text: symbol,
        style: TextStyle(
          fontSize: size.x * 0.45,
          color: textColor,
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
    if (!isInteractive || !_tapEnabled) return;

    // Visual feedback — answer row will update state after validation.
    _state = TileState.selected;

    eventBus.sink.add(PatternTileSelectedEvent(
      tileIndex: tileIndex,
      symbol: symbol,
    ));
  }
}

/// Internal event fired when the player taps an answer tile.
/// Declared in [game_event_bus.dart] to satisfy the sealed class constraint.
