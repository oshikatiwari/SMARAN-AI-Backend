import 'package:cognitive_care_games/features/games/domain/entities/game_config.dart';
import 'package:cognitive_care_games/features/games/domain/repositories/i_game_config_repository.dart';
import 'package:cognitive_care_games/features/games/domain/value_objects/difficulty.dart';
import 'package:cognitive_care_games/features/games/domain/value_objects/game_type.dart';
import 'start_game_session.dart' show DomainException;

/// Use-case: fetches the [GameConfig] for a (game type × difficulty) pair.
///
/// Called by [SessionNotifier] at game start to load grid dimensions and
/// timing parameters. The result is passed into the Flame game constructor
/// so the game engine never queries the repository directly.
///
/// Throws [DomainException] if no config row is found (indicates a missing
/// seed or misconfigured database — treated as a fatal setup error).
final class GetGameConfig {
  const GetGameConfig(this._configRepository);

  final IGameConfigRepository _configRepository;

  /// Returns the [GameConfig] for [gameType] + [difficulty].
  /// Throws [DomainException] if not found.
  Future<GameConfig> execute({
    required GameType gameType,
    required Difficulty difficulty,
  }) async {
    final config = await _configRepository.getConfig(
      gameType: gameType,
      difficulty: difficulty,
    );

    if (config == null) {
      throw DomainException(
        'No config found for ${gameType.value} / ${difficulty.value}. '
        'Database seed may be missing.',
      );
    }

    return config;
  }
}
