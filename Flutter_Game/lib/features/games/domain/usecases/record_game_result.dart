import 'package:cognitive_care_games/features/games/domain/entities/game_result.dart';
import 'package:cognitive_care_games/features/games/domain/repositories/i_game_result_repository.dart';
import 'start_game_session.dart' show DomainException;

/// Use-case: validates and persists a [GameResult] after a session ends.
///
/// This is the single validation gate for all metric values. Every field
/// is checked before the repository is called — if validation fails, no
/// partial row is ever written.
///
/// Called by [SessionNotifier.endSession()] after [EndGameSession.execute()].
final class RecordGameResult {
  const RecordGameResult(this._resultRepository);

  final IGameResultRepository _resultRepository;

  /// Validates [result] and persists it.
  ///
  /// Validation rules:
  ///   - [result.id] must be non-empty
  ///   - [result.sessionId] must be non-empty
  ///   - [result.accuracy] must be in [0.0, 1.0]
  ///   - [result.completionRate] must be in [0.0, 1.0]
  ///   - [result.attempts] must be ≥ 0
  ///   - [result.errors] must be ≥ 0
  ///   - [result.errors] must be ≤ [result.attempts]
  ///   - [result.hintsUsed] must be ≥ 0
  ///   - [result.responseTimeMs] must be ≥ 0
  ///
  /// Throws [DomainException] if any rule is violated.
  Future<GameResult> execute(GameResult result) async {
    _validate(result);
    await _resultRepository.save(result);
    return result;
  }

  void _validate(GameResult r) {
    if (r.id.trim().isEmpty) {
      throw const DomainException('GameResult id must not be empty.');
    }
    if (r.sessionId.trim().isEmpty) {
      throw const DomainException('GameResult sessionId must not be empty.');
    }
    if (r.accuracy < 0.0 || r.accuracy > 1.0) {
      throw DomainException(
        'accuracy must be in [0.0, 1.0]. Got: ${r.accuracy}',
      );
    }
    if (r.completionRate < 0.0 || r.completionRate > 1.0) {
      throw DomainException(
        'completionRate must be in [0.0, 1.0]. Got: ${r.completionRate}',
      );
    }
    if (r.attempts < 0) {
      throw DomainException(
        'attempts must be ≥ 0. Got: ${r.attempts}',
      );
    }
    if (r.errors < 0) {
      throw DomainException(
        'errors must be ≥ 0. Got: ${r.errors}',
      );
    }
    if (r.errors > r.attempts) {
      throw DomainException(
        'errors (${r.errors}) cannot exceed attempts (${r.attempts}).',
      );
    }
    if (r.hintsUsed < 0) {
      throw DomainException(
        'hintsUsed must be ≥ 0. Got: ${r.hintsUsed}',
      );
    }
    if (r.responseTimeMs < 0) {
      throw DomainException(
        'responseTimeMs must be ≥ 0. Got: ${r.responseTimeMs}',
      );
    }
  }
}
