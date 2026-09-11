import 'package:cognitive_care_games/features/games/domain/entities/game_config.dart';
import 'package:cognitive_care_games/features/games/domain/value_objects/difficulty.dart';
import 'package:cognitive_care_games/features/games/domain/value_objects/game_type.dart';

/// Repository contract for game configuration data.
///
/// Implementations:
///   [LocalGameConfigRepository] (Milestone 4) — backed by Drift.
///   Future: concrete HTTP implementation uses GET /games and
///           GET /games/{id}/config — zero changes to this interface.
///
/// All methods are async because implementations may be backed by disk I/O
/// or (in future) network calls.
abstract interface class IGameConfigRepository {
  /// Returns the [GameConfig] for the given [gameType] and [difficulty].
  ///
  /// Returns null if no config row exists (should not happen after seeding;
  /// callers should treat null as a fatal configuration error).
  Future<GameConfig?> getConfig({
    required GameType gameType,
    required Difficulty difficulty,
  });

  /// Returns all seeded config rows.
  /// Used by the difficulty selector to pre-validate available configs.
  Future<List<GameConfig>> getAllConfigs();
}
