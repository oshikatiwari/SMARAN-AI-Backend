import 'package:flame/components.dart';

import 'package:cognitive_care_games/features/games/presentation/providers/game_event_bus.dart';
import 'package:cognitive_care_games/features/games/presentation/shared/design_system/app_dimensions.dart';
import 'sequence_tile_component.dart';

/// Displays the pattern sequence (all tiles except the answer).
///
/// Tiles are revealed one-by-one with a [revealIntervalSeconds] delay
/// (driven by [TimerComponent]) so the player has time to process each
/// element individually — important for elderly/cognitively impaired users.
///
/// When reveal is complete, [onRevealComplete] is called so
/// [PatternRecognitionGame] can enable the answer row.
class SequenceDisplayComponent extends PositionComponent {
  SequenceDisplayComponent({
    required this.sequence,
    required this.canvasSize,
    required this.revealDurationMs,
    required this.onRevealComplete,
    required this.eventBus,
  });

  final List<String> sequence;
  final Vector2 canvasSize;
  final int revealDurationMs;
  final VoidCallback onRevealComplete;
  final GameEventBus eventBus;

  final List<SequenceTileComponent> _tiles = [];
  bool _revealComplete = false;

  bool get isRevealComplete => _revealComplete;

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    _buildTiles();
    _scheduleReveal();
  }

  void _buildTiles() {
    final tileSize = AppDimensions.tileMinSize;
    final gap = AppDimensions.tileGap;
    final totalWidth = sequence.length * tileSize + (sequence.length - 1) * gap;
    final startX = (canvasSize.x - totalWidth) / 2;

    // Position sequence row in upper-middle of the game area (below HUD).
    final startY = AppDimensions.hudHeight +
        (canvasSize.y - AppDimensions.hudHeight) * 0.15;

    for (var i = 0; i < sequence.length; i++) {
      final tile = SequenceTileComponent(
        symbol: sequence[i],
        tileIndex: i,
        isInteractive: false,
        eventBus: eventBus,
        position: Vector2(startX + i * (tileSize + gap), startY),
        size: Vector2(tileSize, tileSize),
        initialState: TileState.disabled, // hidden until revealed
      );
      _tiles.add(tile);
      add(tile);
    }

    // Also add a "?" placeholder tile at the end (the missing answer slot)
    final questionTile = SequenceTileComponent(
      symbol: '?',
      tileIndex: sequence.length,
      isInteractive: false,
      eventBus: eventBus,
      position: Vector2(
        startX + sequence.length * (tileSize + gap),
        startY,
      ),
      size: Vector2(tileSize, tileSize),
      initialState: TileState.normal,
    );
    add(questionTile);
  }

  void _scheduleReveal() {
    // Reveal each tile sequentially with [revealIntervalSeconds] between them.
    final revealIntervalSeconds = revealDurationMs / 1000.0 * 0.8;
    double delay = 0.3; // initial pause before first reveal

    for (var i = 0; i < _tiles.length; i++) {
      final index = i;
      add(
        TimerComponent(
          period: delay,
          onTick: () => _revealTile(index),
          removeOnFinish: true,
        ),
      );
      delay += revealIntervalSeconds;
    }

    // After all tiles revealed, notify game to enable answer row.
    add(
      TimerComponent(
        period: delay + 0.2,
        onTick: () {
          _revealComplete = true;
          onRevealComplete();
        },
        removeOnFinish: true,
      ),
    );
  }

  void _revealTile(final int index) {
    if (index >= _tiles.length) return;
    _tiles[index].highlight();

    // De-highlight after a short moment (single-tile focus effect).
    add(
      TimerComponent(
        period: 0.3,
        onTick: () => _tiles[index].resetToNormal(),
        removeOnFinish: true,
      ),
    );
  }

  /// Replaces the "?" tile with the correct answer symbol after round ends.
  void showAnswer(final String answer) {
    // Find and update the question mark tile (last child).
    final questionTile = children
        .whereType<SequenceTileComponent>()
        .lastOrNull;
    if (questionTile != null) {
      // Rebuild as correct-state tile (symbol shown)
      questionTile.setState(TileState.correct);
    }
  }
}

typedef VoidCallback = void Function();
