import 'package:flame/components.dart';

import 'package:cognitive_care_games/features/games/presentation/providers/game_event_bus.dart';
import 'package:cognitive_care_games/features/games/presentation/shared/design_system/app_dimensions.dart';
import 'sequence_tile_component.dart';

/// Displays the 4 answer-option tiles for the current round.
///
/// Tiles are disabled until [enable()] is called by [PatternRecognitionGame]
/// after the sequence reveal completes (enforces the reveal-then-answer flow).
///
/// After the player selects an answer, [disable()] locks all tiles until
/// the next round begins.
class AnswerRowComponent extends PositionComponent {
  AnswerRowComponent({
    required this.options,
    required this.canvasSize,
    required this.eventBus,
  });

  final List<String> options;
  final Vector2 canvasSize;
  final GameEventBus eventBus;

  final List<SequenceTileComponent> _tiles = [];

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    _buildAnswerTiles();
  }

  void _buildAnswerTiles() {
    final tileSize = AppDimensions.answerTileMinSize;
    final gap = AppDimensions.tileGap;
    final totalWidth = options.length * tileSize + (options.length - 1) * gap;
    final startX = (canvasSize.x - totalWidth) / 2;

    // Position answer row in lower-middle of game area.
    final startY = AppDimensions.hudHeight +
        (canvasSize.y - AppDimensions.hudHeight) * 0.65;

    for (var i = 0; i < options.length; i++) {
      final tile = SequenceTileComponent(
        symbol: options[i],
        tileIndex: i,
        isInteractive: true,
        eventBus: eventBus,
        position: Vector2(startX + i * (tileSize + gap), startY),
        size: Vector2(tileSize, tileSize),
        initialState: TileState.disabled,
      );
      _tiles.add(tile);
      add(tile);
    }
  }

  // ── Answer row lifecycle ───────────────────────────────────────────────────

  /// Called after sequence reveal completes — unlocks the answer tiles.
  void enable() {
    for (final tile in _tiles) {
      tile.enable();
    }
  }

  /// Locks all answer tiles — called when the game is waiting between rounds.
  void disable() {
    for (final tile in _tiles) {
      tile.disable();
    }
  }

  /// Shows the result of the answer:
  ///   [selectedIndex] — tile tapped by the player (marked correct/incorrect).
  ///   [correctValue] — the correct answer (highlighted in green if different).
  void showResult({
    required final String selectedValue,
    required final String correctValue,
    required final bool isCorrect,
  }) {
    for (final tile in _tiles) {
      if (tile.symbol == selectedValue) {
        if (isCorrect) {
          tile.markCorrect();
        } else {
          tile.markIncorrect();
        }
      } else if (!isCorrect && tile.symbol == correctValue) {
        // Highlight the correct answer in green when player got it wrong.
        tile.markCorrect();
      }
      tile.disable();
    }
  }
}
