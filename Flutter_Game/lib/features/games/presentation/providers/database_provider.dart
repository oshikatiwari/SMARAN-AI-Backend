import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:cognitive_care_games/features/games/data/drift/app_database.dart';

/// Provides the [AppDatabase] singleton for the entire app.
///
/// Uses [AsyncNotifier] because opening a Drift database requires an async
/// file system call ([path_provider.getApplicationDocumentsDirectory]).
/// All downstream providers must await this before constructing repositories.
///
/// [AppDatabase] is never closed at runtime — it lives for the app lifetime.
/// Tests override this provider with [openTestDatabase()] via [ProviderScope]
/// overrides to get an isolated in-memory database.
///
/// Downstream consumers use:
///   final db = await ref.watch(databaseProvider.future);
class _DatabaseNotifier extends AsyncNotifier<AppDatabase> {
  @override
  Future<AppDatabase> build() => openAppDatabase();
}

final databaseProvider =
    AsyncNotifierProvider<_DatabaseNotifier, AppDatabase>(
  _DatabaseNotifier.new,
);
