import 'package:cognitive_care_games/features/games/domain/repositories/i_game_result_repository.dart';
import 'package:cognitive_care_games/features/games/domain/repositories/i_game_session_repository.dart';
import 'i_sync_service.dart';

/// No-operation implementation of [ISyncService].
///
/// This is the production implementation until the backend is ready.
/// It satisfies the interface contract, makes zero network calls,
/// writes nothing to the database, and always succeeds.
///
/// Replacement strategy (Milestone 12 / future sprint):
///   1. Create [HttpSyncService] implementing [ISyncService].
///   2. In [syncServiceProvider] (Milestone 6), swap [NoOpSyncService]
///      for [HttpSyncService] via a provider override.
///   3. Delete [NoOpSyncService] or keep for test overrides.
///   Zero other files change.
final class NoOpSyncService implements ISyncService {
  const NoOpSyncService({
    required IGameSessionRepository sessionRepository,
    required IGameResultRepository resultRepository,
  })  : _sessionRepository = sessionRepository,
        _resultRepository = resultRepository;

  // Repositories are injected so HttpSyncService can reuse the same
  // constructor signature — drop-in replacement with zero refactor.
  // ignore: unused_field
  final IGameSessionRepository _sessionRepository;
  // ignore: unused_field
  final IGameResultRepository _resultRepository;

  @override
  Future<void> syncPending() async {
    // No-op: offline-first, no backend available yet.
    // Rows remain unsynced — this is the correct behaviour at this stage.
  }

  @override
  Future<int> pendingCount() async {
    final pendingSessions = await _sessionRepository.getPendingSessions();
    final pendingResults = await _resultRepository.getPendingResults();
    return pendingSessions.length + pendingResults.length;
  }
}
