import 'package:cognitive_care_games/features/games/data/drift/app_database.dart'
    hide GameResult;
import 'package:cognitive_care_games/features/games/data/repositories/local_game_result_repository.dart';
import 'package:cognitive_care_games/features/games/domain/entities/game_result.dart';
import 'package:cognitive_care_games/features/games/domain/value_objects/sync_status.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:uuid/uuid.dart';

import '../../helpers/test_database_helper.dart';

const _sessionId = '00000000-0000-0000-0000-000000000001';

void main() {
  late AppDatabase db;
  late LocalGameResultRepository repo;
  const uuid = Uuid();

  setUp(() async {
    db = openTestDatabaseForTest();
    repo = LocalGameResultRepository(db.gameResultsDao);

    // Every result needs a parent session row due to the FK constraint.
    await db.gameSessionsDao.insertSession(
      GameSessionsCompanion.insert(
        id: _sessionId,
        gameType: 'memory_matching',
        difficulty: 'easy',
        startTime: DateTime.now().millisecondsSinceEpoch,
        status: 'completed',
      ),
    );
  });

  tearDown(() async => db.close());

  GameResult _makeResult({
    double accuracy = 0.75,
    int attempts = 8,
    int errors = 2,
    int hintsUsed = 1,
    double completionRate = 1.0,
    int responseTimeMs = 30000,
    String? sessionId,
  }) =>
      GameResult(
        id: uuid.v4(),
        sessionId: sessionId ?? _sessionId,
        accuracy: accuracy,
        responseTimeMs: responseTimeMs,
        attempts: attempts,
        errors: errors,
        hintsUsed: hintsUsed,
        completionRate: completionRate,
        syncStatus: SyncStatus.unsynced,
        createdAt: DateTime.now().millisecondsSinceEpoch,
      );

  // ── save / getBySession ──────────────────────────────────────────────────

  group('save and getBySession', () {
    test('saves and retrieves all metric fields correctly', () async {
      final result = _makeResult(
        accuracy: 0.875,
        attempts: 8,
        errors: 1,
        hintsUsed: 2,
        completionRate: 1.0,
        responseTimeMs: 42000,
      );
      await repo.save(result);

      final found = await repo.getBySession(_sessionId);

      expect(found, isNotNull);
      expect(found!.accuracy, closeTo(0.875, 0.001));
      expect(found.attempts, equals(8));
      expect(found.errors, equals(1));
      expect(found.hintsUsed, equals(2));
      expect(found.completionRate, closeTo(1.0, 0.001));
      expect(found.responseTimeMs, equals(42000));
    });

    test('syncStatus is unsynced after save', () async {
      await repo.save(_makeResult());
      final found = await repo.getBySession(_sessionId);
      expect(found!.syncStatus, equals(SyncStatus.unsynced));
    });

    test('getBySession returns null when no result exists', () async {
      final found = await repo.getBySession(uuid.v4());
      expect(found, isNull);
    });

    test('accuracy = 0.0 boundary is preserved', () async {
      await repo.save(_makeResult(accuracy: 0.0));
      final found = await repo.getBySession(_sessionId);
      expect(found!.accuracy, closeTo(0.0, 0.001));
    });

    test('accuracy = 1.0 boundary is preserved', () async {
      await repo.save(_makeResult(accuracy: 1.0, errors: 0));
      final found = await repo.getBySession(_sessionId);
      expect(found!.accuracy, closeTo(1.0, 0.001));
    });
  });

  // ── markSynced / markSyncFailed ──────────────────────────────────────────

  group('sync status transitions', () {
    test('markSynced sets syncStatus to synced', () async {
      final result = _makeResult();
      await repo.save(result);
      await repo.markSynced(result.id);

      final found = await repo.getBySession(_sessionId);
      expect(found!.syncStatus, equals(SyncStatus.synced));
    });

    test('markSyncFailed sets syncStatus to syncFailed', () async {
      final result = _makeResult();
      await repo.save(result);
      await repo.markSyncFailed(result.id);

      final found = await repo.getBySession(_sessionId);
      expect(found!.syncStatus, equals(SyncStatus.syncFailed));
    });
  });

  // ── getPendingResults ────────────────────────────────────────────────────

  group('getPendingResults', () {
    test('returns only unsynced rows', () async {
      // Need two session rows for two separate result inserts
      const sid2 = '00000000-0000-0000-0000-000000000002';
      await db.gameSessionsDao.insertSession(
        GameSessionsCompanion.insert(
          id: sid2,
          gameType: 'memory_matching',
          difficulty: 'medium',
          startTime: DateTime.now().millisecondsSinceEpoch,
          status: 'completed',
        ),
      );

      final r1 = _makeResult();
      final r2 = _makeResult(sessionId: sid2);

      await repo.save(r1);
      await repo.save(r2);
      await repo.markSynced(r1.id);

      final pending = await repo.getPendingResults();
      expect(pending.length, equals(1));
      expect(pending.first.id, equals(r2.id));
    });
  });

  // ── getAll ───────────────────────────────────────────────────────────────

  group('getAll', () {
    test('returns all results newest first', () async {
      await repo.save(_makeResult());
      final all = await repo.getAll();
      expect(all.length, equals(1));
    });
  });
}
