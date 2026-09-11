import 'package:cognitive_care_games/features/games/domain/entities/game_session.dart';
import 'package:cognitive_care_games/features/games/domain/repositories/i_game_session_repository.dart';
import 'package:cognitive_care_games/features/games/domain/usecases/start_game_session.dart';
import 'package:cognitive_care_games/features/games/domain/value_objects/difficulty.dart';
import 'package:cognitive_care_games/features/games/domain/value_objects/game_type.dart';
import 'package:cognitive_care_games/features/games/domain/value_objects/session_status.dart';
import 'package:cognitive_care_games/features/games/domain/value_objects/sync_status.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:uuid/uuid.dart';

import 'start_game_session_test.mocks.dart';

@GenerateMocks([IGameSessionRepository])
void main() {
  late MockIGameSessionRepository mockRepo;
  late StartGameSession startUseCase;
  late EndGameSession endUseCase;
  const uuid = Uuid();

  setUp(() {
    mockRepo = MockIGameSessionRepository();
    startUseCase = StartGameSession(mockRepo);
    endUseCase = EndGameSession(mockRepo);
    when(mockRepo.save(any)).thenAnswer((_) async {});
    when(mockRepo.update(any)).thenAnswer((_) async {});
  });

  // ── StartGameSession ───────────────────────────────────────────────────

  group('StartGameSession', () {
    test('returns session with correct fields and inProgress status', () async {
      final id = uuid.v4();
      final session = await startUseCase.execute(
        sessionId: id,
        gameType: GameType.memoryMatching,
        difficulty: Difficulty.easy,
      );

      expect(session.id, equals(id));
      expect(session.gameType, equals(GameType.memoryMatching));
      expect(session.difficulty, equals(Difficulty.easy));
      expect(session.status, equals(SessionStatus.inProgress));
      expect(session.syncStatus, equals(SyncStatus.unsynced));
      expect(session.endTime, isNull);
    });

    test('calls repository.save exactly once', () async {
      await startUseCase.execute(
        sessionId: uuid.v4(),
        gameType: GameType.patternRecognition,
        difficulty: Difficulty.medium,
      );
      verify(mockRepo.save(any)).called(1);
    });

    test('throws DomainException for empty sessionId', () {
      expect(
        () => startUseCase.execute(
          sessionId: '',
          gameType: GameType.memoryMatching,
          difficulty: Difficulty.easy,
        ),
        throwsA(isA<DomainException>()),
      );
    });

    test('throws DomainException for whitespace-only sessionId', () {
      expect(
        () => startUseCase.execute(
          sessionId: '   ',
          gameType: GameType.memoryMatching,
          difficulty: Difficulty.easy,
        ),
        throwsA(isA<DomainException>()),
      );
    });
  });

  // ── EndGameSession ─────────────────────────────────────────────────────

  group('EndGameSession', () {
    late GameSession existingSession;

    setUp(() {
      final id = uuid.v4();
      existingSession = GameSession(
        id: id,
        gameType: GameType.memoryMatching,
        difficulty: Difficulty.easy,
        startTime: DateTime.now().millisecondsSinceEpoch - 30000,
        status: SessionStatus.inProgress,
        syncStatus: SyncStatus.unsynced,
      );
      when(mockRepo.getById(id))
          .thenAnswer((_) async => existingSession);
    });

    test('transitions session to completed', () async {
      final updated = await endUseCase.execute(
        sessionId: existingSession.id,
        finalStatus: SessionStatus.completed,
        endTimeMs: existingSession.startTime + 45000,
      );

      expect(updated.status, equals(SessionStatus.completed));
      expect(updated.endTime, equals(existingSession.startTime + 45000));
    });

    test('transitions session to abandoned', () async {
      final updated = await endUseCase.execute(
        sessionId: existingSession.id,
        finalStatus: SessionStatus.abandoned,
      );

      expect(updated.status, equals(SessionStatus.abandoned));
      expect(updated.endTime, isNotNull);
    });

    test('throws DomainException for non-terminal status', () {
      expect(
        () => endUseCase.execute(
          sessionId: existingSession.id,
          finalStatus: SessionStatus.inProgress, // not terminal
        ),
        throwsA(isA<DomainException>()),
      );
    });

    test('throws DomainException when session not found', () {
      when(mockRepo.getById(any)).thenAnswer((_) async => null);

      expect(
        () => endUseCase.execute(
          sessionId: uuid.v4(),
          finalStatus: SessionStatus.completed,
        ),
        throwsA(isA<DomainException>()),
      );
    });

    test('calls repository.update exactly once on success', () async {
      await endUseCase.execute(
        sessionId: existingSession.id,
        finalStatus: SessionStatus.completed,
      );
      verify(mockRepo.update(any)).called(1);
    });
  });
}
