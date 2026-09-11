/// Abstract contract for the offline-to-backend synchronisation service.
///
/// This interface is the ONLY touch-point between the games module and any
/// future network layer. Implementing it (Milestone 12 scaffolds it; a future
/// sprint fills in HTTP calls) requires zero changes to:
///   - game logic
///   - Flame components
///   - Riverpod providers
///   - domain use-cases
///   - repository implementations
///
/// Sync lifecycle:
///   1. Rows are written with syncStatus = 'unsynced' by the game write path.
///   2. [syncPending()] is called by a background trigger (app resume, timer).
///   3. For each pending row: POST to backend, then call repo.markSynced(id)
///      or repo.markSyncFailed(id).
///
/// The current implementation is [NoOpSyncService] — it satisfies this
/// interface but performs no work.
abstract interface class ISyncService {
  /// Processes all pending (unsynced) sessions and results.
  ///
  /// Implementations must:
  ///   - Be safe to call when offline (handle network errors gracefully)
  ///   - Never block the game write path (call from a background isolate or
  ///     post-frame callback)
  ///   - Mark rows [SyncStatus.syncFailed] on non-retryable errors
  ///   - Leave rows [SyncStatus.unsynced] on transient errors (retry next call)
  Future<void> syncPending();

  /// Returns the count of rows still pending synchronisation.
  /// Used by a future sync status indicator in the app shell (not this module).
  Future<int> pendingCount();
}
