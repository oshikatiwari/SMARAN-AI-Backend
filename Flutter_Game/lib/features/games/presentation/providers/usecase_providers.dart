import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:cognitive_care_games/features/games/data/services/smaran_ai_service.dart';
import 'package:cognitive_care_games/features/games/domain/usecases/get_game_config.dart';
import 'package:cognitive_care_games/features/games/domain/usecases/record_game_result.dart';
import 'package:cognitive_care_games/features/games/domain/usecases/start_game_session.dart';
import 'repository_providers.dart';

/// Provides [StartGameSession] use-case.
final startGameSessionProvider =
    FutureProvider<StartGameSession>((final ref) async {
  final repo = await ref.watch(gameSessionRepositoryProvider.future);
  return StartGameSession(repo);
});

/// Provides [EndGameSession] use-case.
final endGameSessionProvider =
    FutureProvider<EndGameSession>((final ref) async {
  final repo = await ref.watch(gameSessionRepositoryProvider.future);
  return EndGameSession(repo);
});

/// Provides [RecordGameResult] use-case.
final recordGameResultProvider =
    FutureProvider<RecordGameResult>((final ref) async {
  final repo = await ref.watch(gameResultRepositoryProvider.future);
  return RecordGameResult(repo);
});

/// Provides [GetGameConfig] use-case.
final getGameConfigProvider =
    FutureProvider<GetGameConfig>((final ref) async {
  final repo = await ref.watch(gameConfigRepositoryProvider.future);
  return GetGameConfig(repo);
});

/// Provides [SmaranAiService] for backend difficulty prediction.
final smaranAiServiceProvider = Provider<SmaranAiService>((final ref) {
  return SmaranAiService();
});
