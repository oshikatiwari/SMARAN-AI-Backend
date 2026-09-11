import 'package:cognitive_care_games/features/games/domain/entities/game_result.dart';
import 'package:cognitive_care_games/features/games/domain/repositories/i_game_result_repository.dart';
import 'package:cognitive_care_games/features/games/domain/usecases/record_game_result.dart';
import 'package:cognitive_care_games/features/games/domain/usecases/start_game_session.dart'
    show DomainException;
import 'package:cognitive_care_games/features/games/domain/value_objects/sync_status.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:uuid/uuid.dart';

import 'record_game_result_test.mocks.dart';

@GenerateMocks([IGameResultRepository])
void main() {
  late MockIGameResultRepository mockRepo;
  late RecordGameResult useCase;
  const uuid = Uuid();

  setUp(() {
    mockRepo = MockIGameResultRepository();
    useCase = RecordGameResult(mockRepo);
    when(mockRepo.save(any)).thenAnswer((_) async {});
  });

  GameResult _validResult({
    double accuracy = 0.8,
    int attempts = 10,
    int errors = 2,
    int hintsUsed = 1,
    double completionRate = 1.0,
    int responseTimeMs = 45000,
  }) =>
      GameResult(
        id: uuid.v4(),
        sessionId: uuid.v4(),
        accuracy: accuracy,
        responseTimeMs: responseTimeMs,
        attempts: attempts,
        errors: errors,
        hintsUsed: hintsUsed,
        completionRate: completionRate,
        syncStatus: SyncStatus.unsynced,
        createdAt: DateTime.now().millisecondsSinceEpoch,
      );

  // ── Happy path ─────────────────────────────────────────────────────────

  test('saves a valid result and returns it', () async {
    final result = _validResult();
    final saved = await useCase.execute(result);

    expect(saved, equals(result));
    verify(mockRepo.save(result)).called(1);
  });

  test('accuracy = 0.0 is valid', () async {
    final result = _validResult(accuracy: 0.0, errors: 10);
    await expectLater(useCase.execute(result), completes);
  });

  test('accuracy = 1.0 is valid', () async {
    final result = _validResult(accuracy: 1.0, errors: 0);
    await expectLater(useCase.execute(result), completes);
  });

  test('completionRate = 0.0 is valid (abandoned session)', () async {
    final result = _validResult(completionRate: 0.0, attempts: 0, errors: 0);
    await expectLater(useCase.execute(result), completes);
  });

  test('zero attempts with zero errors is valid (abandoned immediately)', () async {
    final result = _validResult(attempts: 0, errors: 0, accuracy: 0.0, completionRate: 0.0);
    await expectLater(useCase.execute(result), completes);
  });

  // ── Validation failures ────────────────────────────────────────────────

  test('throws DomainException when id is empty', () {
    final result = GameResult(
      id: '',
      sessionId: uuid.v4(),
      accuracy: 0.8,
      responseTimeMs: 1000,
      attempts: 5,
      errors: 1,
      hintsUsed: 0,
      completionRate: 1.0,
      syncStatus: SyncStatus.unsynced,
      createdAt: DateTime.now().millisecondsSinceEpoch,
    );
    expect(
      () => useCase.execute(result),
      throwsA(isA<DomainException>()),
    );
  });

  test('throws DomainException when accuracy > 1.0', () {
    expect(
      () => useCase.execute(_validResult(accuracy: 1.1)),
      throwsA(isA<DomainException>()),
    );
  });

  test('throws DomainException when accuracy < 0.0', () {
    expect(
      () => useCase.execute(_validResult(accuracy: -0.1)),
      throwsA(isA<DomainException>()),
    );
  });

  test('throws DomainException when completionRate > 1.0', () {
    expect(
      () => useCase.execute(_validResult(completionRate: 1.5)),
      throwsA(isA<DomainException>()),
    );
  });

  test('throws DomainException when errors > attempts', () {
    expect(
      () => useCase.execute(_validResult(attempts: 3, errors: 5)),
      throwsA(isA<DomainException>()),
    );
  });

  test('throws DomainException when attempts < 0', () {
    expect(
      () => useCase.execute(_validResult(attempts: -1, errors: 0)),
      throwsA(isA<DomainException>()),
    );
  });

  test('throws DomainException when hintsUsed < 0', () {
    expect(
      () => useCase.execute(_validResult(hintsUsed: -1)),
      throwsA(isA<DomainException>()),
    );
  });

  test('throws DomainException when responseTimeMs < 0', () {
    expect(
      () => useCase.execute(_validResult(responseTimeMs: -1)),
      throwsA(isA<DomainException>()),
    );
  });

  test('does not call repository.save when validation fails', () async {
    try {
      await useCase.execute(_validResult(accuracy: 2.0));
    } catch (_) {}
    verifyNever(mockRepo.save(any));
  });

  // ── syncStatus invariant ───────────────────────────────────────────────

  test('result passed to repository has syncStatus = unsynced', () async {
    final result = _validResult();
    await useCase.execute(result);

    final captured = verify(mockRepo.save(captureAny)).captured.first as GameResult;
    expect(captured.syncStatus, equals(SyncStatus.unsynced));
  });
}
