import 'package:cognitive_care_games/features/games/data/drift/app_database.dart'
    hide GameSession;
import 'package:cognitive_care_games/features/games/data/repositories/local_game_session_repository.dart';
import 'package:cognitive_care_games/features/games/domain/entities/game_session.dart';
import 'package:cognitive_care_games/features/games/domain/value_objects/difficulty.dart';
import 'package:cognitive_care_games/features/games/domain/value_objects/game_type.dart';
import 'package:cognitive_care_games/features/games/domain/value_objects/session_status.dart';
import 'package:cognitive_care_games/features/games/domain/value_objects/sync_status.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:uuid/uuid.dart';

import '../../helpers/test_database_helper.dart';

void main() {
  late AppDatabase db;
  late LocalGameSessionRepository repo;
  const uuid = Uuid();

  setUp(() {
    db = openTestDatabaseForTest();
    repo = LocalGameSessionRepository(db.gameSessionsDao);
  });

  tearDown(() async => db.close());

  GameSession _makeSession({
    String? id,
    GameType gameType = GameType.memoryMatching,
    Difficulty difficulty = Difficulty.easy,
    SessionStatus status = SessionStatus.inProgress,
  }) {
    final now = DateTime.now().millisecondsSinceEpoch;
    return GameSession(
      id: id ?? uuid.v4(),
      gameType: gameType,
      difficulty: difficulty,
      startTime: now,
      status: status,
      syncStatus: SyncStatus.unsynced,
    );
  }

  // ── save / getById ───────────────────────────────────────────────────────

  group('save and getById', () {
    test('persists a session and retrieves it', () async {
      final session = _makeSession();
      await repo.save(session);

      final found = await repo.getById(session.id);

      expect(found, isNotNull);
      expect(found!.id, equals(session.id));
      expect(found.gameType, equals(GameType.memoryMatching));
      expect(found.difficulty, equals(Difficulty.easy));
      expect(found.status, equals(SessionStatus.inProgress));
    });

    test('syncStatus defaults to unsynced on save', () async {
      final session = _makeSession();
      await repo.save(session);

      final found = await repo.getById(session.id);
      expect(found!.syncStatus, equals(SyncStatus.unsynced));
    });

    test('getById returns null for unknown id', () async {
      final found = await repo.getById(uuid.v4());
      expect(found, isNull);
    });
  });

  // ── update ───────────────────────────────────────────────────────────────

  group('update', () {
    test('transitions session to completed with endTime', () async {
      final session = _makeSession();
      await repo.save(session);

      final endTime = session.startTime + 60000;
      final updated = session.copyWith(
        status: SessionStatus.completed,
        endTime: endTime,
      );
      await repo.update(updated);

      final found = await repo.getById(session.id);
      expect(found!.status, equals(SessionStatus.completed));
      expect(found.endTime, equals(endTime));
    });

    test('transitions session to abandoned', () async {
      final session = _makeSession();
      await repo.save(session);

      await repo.update(session.copyWith(status: SessionStatus.abandoned));

      final found = await repo.getById(session.id);
      expect(found!.status, equals(SessionStatus.abandoned));
    });
  });

  // ── markSynced / markSyncFailed ──────────────────────────────────────────

  group('sync status transitions', () {
    test('markSynced sets syncStatus to synced', () async {
      final session = _makeSession();
      await repo.save(session);
      await repo.markSynced(session.id);

      final found = await repo.getById(session.id);
      expect(found!.syncStatus, equals(SyncStatus.synced));
    });

    test('markSyncFailed sets syncStatus to syncFailed', () async {
      final session = _makeSession();
      await repo.save(session);
      await repo.markSyncFailed(session.id);

      final found = await repo.getById(session.id);
      expect(found!.syncStatus, equals(SyncStatus.syncFailed));
    });
  });

  // ── getPendingSessions ───────────────────────────────────────────────────

  group('getPendingSessions', () {
    test('returns only unsynced sessions', () async {
      final s1 = _makeSession();
      final s2 = _makeSession();
      final s3 = _makeSession();

      await repo.save(s1);
      await repo.save(s2);
      await repo.save(s3);

      await repo.markSynced(s1.id);
      await repo.markSyncFailed(s2.id);

      final pending = await repo.getPendingSessions();
      expect(pending.length, equals(1));
      expect(pending.first.id, equals(s3.id));
    });

    test('returns empty list when all sessions are synced', () async {
      final s = _makeSession();
      await repo.save(s);
      await repo.markSynced(s.id);

      final pending = await repo.getPendingSessions();
      expect(pending, isEmpty);
    });
  });

  // ── getByGame ─────────────────────────────────────────────────────────────

  group('getByGame', () {
    test('filters sessions by game type', () async {
      await repo.save(_makeSession(gameType: GameType.memoryMatching));
      await repo.save(_makeSession(gameType: GameType.memoryMatching));
      await repo.save(_makeSession(gameType: GameType.patternRecognition));

      final mm = await repo.getByGame(GameType.memoryMatching);
      final pr = await repo.getByGame(GameType.patternRecognition);

      expect(mm.length, equals(2));
      expect(pr.length, equals(1));
    });
  });
}
