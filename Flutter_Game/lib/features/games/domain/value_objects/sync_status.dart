import 'package:equatable/equatable.dart';

/// Lifecycle state for offline-first synchronisation.
///
/// Every [GameSession] and [GameResult] row is created with [unsynced].
/// The future [ISyncService] transitions rows to [synced] or [syncFailed].
///
/// This enum is the domain representation of the 'sync_status' text column
/// stored in Drift tables. The [value] getter serialises to the stored string.
enum SyncStatus {
  /// Written at INSERT time. Rows with this status are pending sync.
  unsynced,

  /// Set by ISyncService after a successful backend POST.
  synced,

  /// Set by ISyncService after a failed backend POST.
  /// The sync service may retry [syncFailed] rows in a future pass.
  syncFailed;

  /// Deserialises from the Drift column string.
  static SyncStatus fromString(final String value) {
    return switch (value) {
      'unsynced' => SyncStatus.unsynced,
      'synced' => SyncStatus.synced,
      'sync_failed' => SyncStatus.syncFailed,
      _ => throw ArgumentError('Unknown SyncStatus value: $value'),
    };
  }

  /// Serialises to the Drift column string.
  String get value => switch (this) {
        SyncStatus.unsynced => 'unsynced',
        SyncStatus.synced => 'synced',
        SyncStatus.syncFailed => 'sync_failed',
      };
}

/// Value object wrapping [SyncStatus].
final class SyncStatusValue extends Equatable {
  const SyncStatusValue(this.status);

  final SyncStatus status;

  @override
  List<Object?> get props => [status];

  @override
  String toString() => 'SyncStatusValue(${status.value})';
}
