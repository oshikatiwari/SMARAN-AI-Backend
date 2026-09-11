import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:cognitive_care_games/features/games/data/repositories/local_game_config_repository.dart';
import 'package:cognitive_care_games/features/games/data/repositories/local_game_result_repository.dart';
import 'package:cognitive_care_games/features/games/data/repositories/local_game_session_repository.dart';
import 'package:cognitive_care_games/features/games/data/sync/i_sync_service.dart';
import 'package:cognitive_care_games/features/games/data/sync/no_op_sync_service.dart';
import 'package:cognitive_care_games/features/games/domain/repositories/i_game_config_repository.dart';
import 'package:cognitive_care_games/features/games/domain/repositories/i_game_result_repository.dart';
import 'package:cognitive_care_games/features/games/domain/repositories/i_game_session_repository.dart';
import 'database_provider.dart';

/// Provides [IGameSessionRepository] backed by [LocalGameSessionRepository].
///
/// Returns [AsyncValue] because it depends on the async [databaseProvider].
/// Downstream use-case providers await this via [ref.watch(...).requireValue].
///
/// To swap implementations (e.g., for tests):
///   ProviderScope(
///     overrides: [
///       gameSessionRepositoryProvider.overrideWith((_) =>
///           LocalGameSessionRepository(testDb.gameSessionsDao)),
///     ],
///   )
final gameSessionRepositoryProvider =
    FutureProvider<IGameSessionRepository>((final ref) async {
  final db = await ref.watch(databaseProvider.future);
  return LocalGameSessionRepository(db.gameSessionsDao);
});

/// Provides [IGameResultRepository] backed by [LocalGameResultRepository].
final gameResultRepositoryProvider =
    FutureProvider<IGameResultRepository>((final ref) async {
  final db = await ref.watch(databaseProvider.future);
  return LocalGameResultRepository(db.gameResultsDao);
});

/// Provides [IGameConfigRepository] backed by [LocalGameConfigRepository].
final gameConfigRepositoryProvider =
    FutureProvider<IGameConfigRepository>((final ref) async {
  final db = await ref.watch(databaseProvider.future);
  return LocalGameConfigRepository(db.gameConfigsDao);
});

/// Provides [ISyncService] — currently the no-op implementation.
///
/// Swap [NoOpSyncService] for [HttpSyncService] here when the backend is
/// ready. Zero other files change.
final syncServiceProvider = FutureProvider<ISyncService>((final ref) async {
  final sessionRepo = await ref.watch(gameSessionRepositoryProvider.future);
  final resultRepo = await ref.watch(gameResultRepositoryProvider.future);
  return NoOpSyncService(
    sessionRepository: sessionRepo,
    resultRepository: resultRepo,
  );
});
