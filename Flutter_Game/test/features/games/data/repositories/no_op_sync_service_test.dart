import 'package:cognitive_care_games/features/games/data/drift/app_database.dart'
    hide GameSession, GameResult;
import 'package:cognitive_care_games/features/games/data/repositories/local_game_result_repository.dart';
import 'package:cognitive_care_games/features/games/data/repositories/local_game_session_repository.dart';
import 'package:cognitive_care_games/features/games/data/sync/no_op_sync_service.dart';
import 'package:cognitive_care_games/features/games/domain/entities/game_result.dart';
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
  late LocalGameSessionRepository sessionRepo;
  late LocalGameResultRepository resultRepo;
  late NoOpSyncService syncService;
  const uuid = Uuid();

  setUp(() {
    db = openTestDatabaseForTest();
    sessionRepo = LocalGameSessionRepository(db.gameSessionsDao);
    resultRepo = LocalGameResultRepository(db.gameResultsDao);
    syncService = NoOpSyncService(
      sessionRepository: sessionRepo,
      resultRepository: resultRepo,
    );
  });

  tearDown(() async => db.close());

  test('syncPending completes without error', () async {
    await expectLater(syncService.syncPending(), completes);
  });

  test('pendingCount reflects unsynced rows', () async {
    final sessionId = uuid.v4();
    final now = DateTime.now().millisecondsSinceEpoch;

    // Insert one unsynced session
    await sessionRepo.save(GameSession(
      id: sessionId,
      gameType: GameType.memoryMatching,
      difficulty: Difficulty.easy,
      startTime: now,
      status: SessionStatus.completed,
      syncStatus: SyncStatus.unsynced,
    ));

    // Insert one unsynced result
    await resultRepo.save(GameResult(
      id: uuid.v4(),
      sessionId: sessionId,
      accuracy: 0.8,
      responseTimeMs: 30000,
      attempts: 5,
      errors: 1,
      hintsUsed: 0,
      completionRate: 1.0,
      syncStatus: SyncStatus.unsynced,
      createdAt: now,
    ));

    final count = await syncService.pendingCount();
    expect(count, equals(2)); // 1 session + 1 result
  });

  test('pendingCount returns 0 when all rows are synced', () async {
    final sessionId = uuid.v4();
    final now = DateTime.now().millisecondsSinceEpoch;

    await sessionRepo.save(GameSession(
      id: sessionId,
      gameType: GameType.patternRecognition,
      difficulty: Difficulty.medium,
      startTime: now,
      status: SessionStatus.completed,
      syncStatus: SyncStatus.unsynced,
    ));
    await sessionRepo.markSynced(sessionId);

    await resultRepo.save(GameResult(
      id: uuid.v4(),
      sessionId: sessionId,
      accuracy: 0.9,
      responseTimeMs: 20000,
      attempts: 8,
      errors: 0,
      hintsUsed: 1,
      completionRate: 1.0,
      syncStatus: SyncStatus.unsynced,
      createdAt: now,
    ));
    // Mark result synced by fetching its id first
    final allResults = await resultRepo.getAll();
    await resultRepo.markSynced(allResults.first.id);

    final count = await syncService.pendingCount();
    expect(count, equals(0));
  });

  test('syncPending does not modify any rows (no-op invariant)', () async {
    final sessionId = uuid.v4();
    final now = DateTime.now().millisecondsSinceEpoch;

    await sessionRepo.save(GameSession(
      id: sessionId,
      gameType: GameType.memoryMatching,
      difficulty: Difficulty.hard,
      startTime: now,
      status: SessionStatus.completed,
      syncStatus: SyncStatus.unsynced,
    ));

    await syncService.syncPending();

    // After syncPending, the no-op must NOT have changed syncStatus
    final session = await sessionRepo.getById(sessionId);
    expect(session!.syncStatus, equals(SyncStatus.unsynced));
  });
}
