import 'package:cognitive_care_games/features/games/data/drift/app_database.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:uuid/uuid.dart';

import '../../helpers/test_database_helper.dart';

void main() {
  late AppDatabase db;
  const uuid = Uuid();

  setUp(() {
    db = openTestDatabaseForTest();
  });

  tearDown(() async {
    await db.close();
  });

  // ── GameSessions ─────────────────────────────────────────────────────────

  group('GameSessions table', () {
    test('inserts a session and retrieves it by id', () async {
      final id = uuid.v4();
      final now = DateTime.now().millisecondsSinceEpoch;

      await db.gameSessionsDao.insertSession(
        GameSessionsCompanion.insert(
          id: id,
          gameType: 'memory_matching',
          difficulty: 'easy',
          startTime: now,
          status: 'in_progress',
        ),
      );

      final result = await db.gameSessionsDao.getSessionById(id);

      expect(result, isNotNull);
      expect(result!.id, equals(id));
      expect(result.gameType, equals('memory_matching'));
      expect(result.difficulty, equals('easy'));
      expect(result.status, equals('in_progress'));
      // Default sync_status must be 'unsynced' — core offline-first invariant
      expect(result.syncStatus, equals('unsynced'));
      expect(result.endTime, isNull);
    });

    test('updateSessionStatus sets status to completed', () async {
      final id = uuid.v4();
      final start = DateTime.now().millisecondsSinceEpoch;

      await db.gameSessionsDao.insertSession(
        GameSessionsCompanion.insert(
          id: id,
          gameType: 'pattern_recognition',
          difficulty: 'medium',
          startTime: start,
          status: 'in_progress',
        ),
      );

      final end = start + 60000;
      await db.gameSessionsDao.updateSessionStatus(
        id: id,
        status: 'completed',
        endTime: end,
      );

      final updated = await db.gameSessionsDao.getSessionById(id);
      expect(updated!.status, equals('completed'));
      expect(updated.endTime, equals(end));
    });

    test('markSynced sets sync_status to synced', () async {
      final id = uuid.v4();

      await db.gameSessionsDao.insertSession(
        GameSessionsCompanion.insert(
          id: id,
          gameType: 'memory_matching',
          difficulty: 'hard',
          startTime: DateTime.now().millisecondsSinceEpoch,
          status: 'completed',
        ),
      );

      await db.gameSessionsDao.markSynced(id);

      final row = await db.gameSessionsDao.getSessionById(id);
      expect(row!.syncStatus, equals('synced'));
    });

    test('getPendingSessions returns only unsynced rows', () async {
      final id1 = uuid.v4();
      final id2 = uuid.v4();
      final now = DateTime.now().millisecondsSinceEpoch;

      await db.gameSessionsDao.insertSession(
        GameSessionsCompanion.insert(
          id: id1,
          gameType: 'memory_matching',
          difficulty: 'easy',
          startTime: now,
          status: 'completed',
        ),
      );
      await db.gameSessionsDao.insertSession(
        GameSessionsCompanion.insert(
          id: id2,
          gameType: 'memory_matching',
          difficulty: 'easy',
          startTime: now,
          status: 'completed',
        ),
      );
      await db.gameSessionsDao.markSynced(id1);

      final pending = await db.gameSessionsDao.getPendingSessions();
      expect(pending.length, equals(1));
      expect(pending.first.id, equals(id2));
    });
  });

  // ── GameResults ──────────────────────────────────────────────────────────

  group('GameResults table', () {
    late String sessionId;

    setUp(() async {
      sessionId = uuid.v4();
      await db.gameSessionsDao.insertSession(
        GameSessionsCompanion.insert(
          id: sessionId,
          gameType: 'memory_matching',
          difficulty: 'easy',
          startTime: DateTime.now().millisecondsSinceEpoch,
          status: 'completed',
        ),
      );
    });

    test('inserts a result and retrieves it by sessionId', () async {
      final resultId = uuid.v4();

      await db.gameResultsDao.insertResult(
        GameResultsCompanion.insert(
          id: resultId,
          sessionId: sessionId,
          accuracy: 0.8,
          responseTimeMs: 45000,
          attempts: 10,
          errors: 2,
          hintsUsed: 1,
          completionRate: 1.0,
          createdAt: DateTime.now().millisecondsSinceEpoch,
        ),
      );

      final result = await db.gameResultsDao.getResultBySession(sessionId);

      expect(result, isNotNull);
      expect(result!.sessionId, equals(sessionId));
      expect(result.accuracy, closeTo(0.8, 0.001));
      expect(result.attempts, equals(10));
      expect(result.errors, equals(2));
      expect(result.hintsUsed, equals(1));
      expect(result.completionRate, closeTo(1.0, 0.001));
      // Core offline-first invariant
      expect(result.syncStatus, equals('unsynced'));
    });

    test('accuracy is stored as a REAL value in [0.0, 1.0]', () async {
      await db.gameResultsDao.insertResult(
        GameResultsCompanion.insert(
          id: uuid.v4(),
          sessionId: sessionId,
          accuracy: 0.333,
          responseTimeMs: 30000,
          attempts: 3,
          errors: 2,
          hintsUsed: 0,
          completionRate: 0.6,
          createdAt: DateTime.now().millisecondsSinceEpoch,
        ),
      );

      final result = await db.gameResultsDao.getResultBySession(sessionId);
      expect(result!.accuracy, greaterThanOrEqualTo(0.0));
      expect(result.accuracy, lessThanOrEqualTo(1.0));
    });
  });

  // ── GameConfigs ──────────────────────────────────────────────────────────

  group('GameConfigs seed data', () {
    test('6 config rows seeded on database creation', () async {
      final configs = await db.gameConfigsDao.getAllConfigs();
      expect(configs.length, equals(6));
    });

    test('memory_matching easy config has gridColumns=3, gridRows=4', () async {
      final config = await db.gameConfigsDao.getConfig(
        gameType: 'memory_matching',
        difficulty: 'easy',
      );

      expect(config, isNotNull);
      expect(config!.gridColumns, equals(3));
      expect(config.gridRows, equals(4));
      expect(config.timeLimitSeconds, equals(180));
      expect(config.revealDurationMs, equals(1200));
    });

    test('pattern_recognition hard config has totalRounds=12', () async {
      final config = await db.gameConfigsDao.getConfig(
        gameType: 'pattern_recognition',
        difficulty: 'hard',
      );

      expect(config, isNotNull);
      expect(config!.totalRounds, equals(12));
      expect(config.timeLimitSeconds, equals(90));
      expect(config.revealDurationMs, equals(600));
    });

    test('all 6 difficulty/game combinations are present', () async {
      final games = ['memory_matching', 'pattern_recognition'];
      final difficulties = ['easy', 'medium', 'hard'];

      for (final game in games) {
        for (final diff in difficulties) {
          final config = await db.gameConfigsDao.getConfig(
            gameType: game,
            difficulty: diff,
          );
          expect(
            config,
            isNotNull,
            reason: 'Missing config for $game / $diff',
          );
        }
      }
    });
  });
}
