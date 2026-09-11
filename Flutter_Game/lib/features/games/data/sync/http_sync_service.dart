import 'package:cognitive_care_games/features/games/domain/repositories/i_game_result_repository.dart';
import 'package:cognitive_care_games/features/games/domain/repositories/i_game_session_repository.dart';
import 'i_sync_service.dart';

/// HTTP-backed implementation of [ISyncService].
///
/// ── STATUS: STUB — backend endpoints not yet available ───────────────────
///
/// This class is a compile-time verified stub. Every method throws
/// [UnimplementedError] until the backend team fills in the HTTP calls.
///
/// TO ACTIVATE:
///   In [repository_providers.dart], change [syncServiceProvider] to:
///     return HttpSyncService(
///       sessionRepository: sessionRepo,
///       resultRepository: resultRepo,
///       baseUrl: 'https://your-api-host/api/v1',
///     );
///   Then implement [syncPending] using:
///     POST /game-sessions  — body: GameSession serialised via DTO
///     POST /game-results   — body: GameResult serialised via DTO
///
/// CONTRACT GUARANTEES (must be preserved in the implementation):
///   1. If the device is offline, catch the network exception and leave rows
///      as [SyncStatus.unsynced] for the next sync attempt.
///   2. On HTTP 200/201: call repo.markSynced(id).
///   3. On HTTP 4xx (non-retryable): call repo.markSyncFailed(id).
///   4. On HTTP 5xx or timeout (retryable): leave as [SyncStatus.unsynced].
///   5. Never throw from [syncPending] — always swallow and log.
///   6. Never block the game write path — call from a post-frame callback
///      or background isolate.
///
/// ZERO OTHER FILES CHANGE when this stub is activated.
/// The domain layer, use-cases, Riverpod providers, Flame components,
/// and Flutter screens are all unaffected.
final class HttpSyncService implements ISyncService {
  const HttpSyncService({
    required IGameSessionRepository sessionRepository,
    required IGameResultRepository resultRepository,
    required String baseUrl,
  })  : _sessionRepository = sessionRepository,
        _resultRepository = resultRepository,
        _baseUrl = baseUrl;

  final IGameSessionRepository _sessionRepository;
  final IGameResultRepository _resultRepository;

  /// Base URL for the backend API, e.g. 'https://api.example.com/v1'
  final String _baseUrl;

  // ── ISyncService ──────────────────────────────────────────────────────────

  /// Syncs all unsynced sessions and results to the backend.
  ///
  /// Implementation checklist (fill in when backend is ready):
  ///   [ ] GET pending sessions via _sessionRepository.getPendingSessions()
  ///   [ ] POST each to $_baseUrl/game-sessions
  ///   [ ] On success: _sessionRepository.markSynced(session.id)
  ///   [ ] On non-retryable error: _sessionRepository.markSyncFailed(session.id)
  ///   [ ] Repeat for results via _resultRepository
  @override
  Future<void> syncPending() async {
    throw UnimplementedError(
      'HttpSyncService.syncPending() is not yet implemented. '
      'See http_sync_service.dart for implementation instructions.',
    );
  }

  /// Returns the total count of unsynced sessions + results.
  @override
  Future<int> pendingCount() async {
    final pendingSessions = await _sessionRepository.getPendingSessions();
    final pendingResults = await _resultRepository.getPendingResults();
    return pendingSessions.length + pendingResults.length;
  }

  // ── Future: HTTP helper methods ───────────────────────────────────────────
  // Add _postSession(GameSession) and _postResult(GameResult) here.
  // Use package:http or package:dio — add the dependency to pubspec.yaml
  // at that time. Do NOT add http/dio now (YAGNI — not yet required).
}
