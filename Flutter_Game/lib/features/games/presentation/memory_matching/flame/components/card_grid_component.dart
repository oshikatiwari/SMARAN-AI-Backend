import 'dart:math';

import 'package:flame/components.dart';

import 'package:cognitive_care_games/features/games/domain/entities/game_config.dart';
import 'package:cognitive_care_games/features/games/presentation/providers/game_event_bus.dart';
import 'package:cognitive_care_games/features/games/presentation/shared/design_system/app_dimensions.dart';
import 'card_component.dart';

/// Lays out [CardComponent]s in a grid for the given [GameConfig].
///
/// Responsibilities:
///   - Computes card size from available canvas area and grid dimensions.
///   - Creates and positions all [CardComponent]s.
///   - Enforces [AppDimensions.cardMinWidth] / [cardMinHeight] floor.
///   - Exposes [cards] list so [MemoryMatchingGame] can look up cards by id.
///
/// Symbols are assigned in shuffled pairs so each symbol appears exactly twice.
class CardGridComponent extends PositionComponent {
  CardGridComponent({
    required this.config,
    required this.eventBus,
    required this.canvasSize,
  });

  final GameConfig config;
  final GameEventBus eventBus;

  /// Total canvas size (width, height) — used to compute card dimensions.
  final Vector2 canvasSize;

  final List<CardComponent> _cards = [];

  List<CardComponent> get cards => List.unmodifiable(_cards);

  // ── Symbols pool (enough for 10 pairs — Hard difficulty maximum) ──────────
  static const List<String> _symbolPool = [
    '🌟', '🎯', '🌈', '🎵', '🌺',
    '🦋', '🐢', '🌙', '☀️', '🍎',
  ];

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    _buildGrid();
  }

  void _buildGrid() {
    final cols = config.gridColumns;
    final rows = config.gridRows;
    final totalCards = cols * rows;
    final totalPairs = totalCards ~/ 2;

    // Compute card dimensions from available canvas space
    final hPad = AppDimensions.screenPaddingH * 2;
    final vPad = AppDimensions.hudHeight + AppDimensions.screenPaddingV * 2;
    final availableWidth = canvasSize.x - hPad;
    final availableHeight = canvasSize.y - vPad;

    final gapX = AppDimensions.cardGap;
    final gapY = AppDimensions.cardGap;

    final rawCardW = (availableWidth - gapX * (cols - 1)) / cols;
    final rawCardH = (availableHeight - gapY * (rows - 1)) / rows;

    final cardW = max(rawCardW, AppDimensions.cardMinWidth);
    final cardH = max(rawCardH, AppDimensions.cardMinHeight);

    // Generate shuffled pairs — returns both the unique symbol list (for
    // pairId lookup) and the shuffled flat list (for card rendering).
    final (:selected, :symbols) = _generateShuffledSymbols(totalPairs);

    // Origin: top of game area (below HUD)
    final originX = (canvasSize.x - (cols * cardW + (cols - 1) * gapX)) / 2;
    final originY = AppDimensions.hudHeight + AppDimensions.screenPaddingV;

    for (var i = 0; i < totalCards; i++) {
      final col = i % cols;
      final row = i ~/ cols;

      final x = originX + col * (cardW + gapX);
      final y = originY + row * (cardH + gapY);

      final card = CardComponent(
        cardId: i,
        // pairId is derived from the actual symbol at position i after shuffle,
        // so it is always in sync with what the player sees on the card face.
        pairId: selected.indexOf(symbols[i]),
        symbol: symbols[i],
        eventBus: eventBus,
        position: Vector2(x, y),
        size: Vector2(cardW, cardH),
      );

      _cards.add(card);
      add(card);
    }
  }

  /// Generates a shuffled list of [totalPairs * 2] symbols where each symbol
  /// appears exactly twice, and returns both:
  ///   - [selected]: the [totalPairs] unique symbols in their canonical order
  ///     (used as the pairId lookup table: pairId == selected.indexOf(symbol)).
  ///   - [symbols]: the shuffled flat list of [totalPairs * 2] symbols that
  ///     maps one-to-one onto card positions in the grid.
  static ({List<String> selected, List<String> symbols})
      _generateShuffledSymbols(final int totalPairs) {
    final selected = _symbolPool.take(totalPairs).toList();
    final pairs = [...selected, ...selected];
    pairs.shuffle(Random());
    return (selected: selected, symbols: pairs);
  }

  /// Blocks or unblocks tap input on all cards.
  /// Called by [MemoryMatchingGame] while evaluating a flip pair.
  void setTapBlocked(final bool blocked) {
    for (final card in _cards) {
      card.isTapBlocked = blocked;
    }
  }

  /// Looks up a [CardComponent] by its [cardId].
  CardComponent? cardById(final int id) {
    try {
      return _cards.firstWhere((final c) => c.cardId == id);
    } catch (_) {
      return null;
    }
  }
}
