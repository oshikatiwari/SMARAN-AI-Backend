import 'dart:math';

import 'package:cognitive_care_games/features/games/domain/value_objects/difficulty.dart';
import 'package:cognitive_care_games/features/games/domain/value_objects/pattern_type.dart';

/// Pure-Dart sequence generation and answer validation engine.
///
/// No Flame, Flutter, or Drift imports — fully unit-testable in isolation.
///
/// Responsibilities:
///   - Generates a [PatternRound] for a given [PatternType] and [Difficulty].
///   - Validates the player's answer.
///   - Tracks round number, attempt count, correct count, and errors.
///
/// Extensibility:
///   To add a new [PatternType] (e.g. PatternType.spatial):
///     1. Add the enum value in domain/value_objects/pattern_type.dart.
///     2. Add a case to [_generateRound] here.
///     3. No other files change.
final class PatternController {
  PatternController({
    required this.difficulty,
    required this.patternType,
  });

  final Difficulty difficulty;
  final PatternType patternType;

  int _currentRound = 0;
  int _totalAttempts = 0;
  int _correctAnswers = 0;
  int _errors = 0;

  PatternRound? _activeRound;

  // ── Public API ─────────────────────────────────────────────────────────────

  int get currentRound => _currentRound;
  int get totalRounds => difficulty.totalRounds;
  int get totalAttempts => _totalAttempts;
  int get correctAnswers => _correctAnswers;
  int get errors => _errors;
  bool get isComplete => _currentRound >= difficulty.totalRounds;
  PatternRound? get activeRound => _activeRound;

  /// Accuracy: correct / attempts, 0.0 when no attempts.
  double get accuracy =>
      _totalAttempts == 0 ? 0.0 : _correctAnswers / _totalAttempts;

  /// Completion rate: rounds completed / total rounds.
  double get completionRate =>
      difficulty.totalRounds == 0 ? 0.0 : _currentRound / difficulty.totalRounds;

  /// Generates and returns the next round. Returns null if no rounds remain.
  PatternRound? nextRound() {
    if (isComplete) return null;
    _currentRound++;
    _activeRound = _generateRound(_currentRound);
    return _activeRound;
  }

  /// Validates [playerAnswer] against the active round's [correctAnswer].
  ///
  /// Returns [AnswerResult.correct] or [AnswerResult.incorrect].
  /// Increments attempt and error counters.
  AnswerResult submitAnswer(final String playerAnswer) {
    final round = _activeRound;
    if (round == null) {
      return AnswerResult(
        isCorrect: false,
        attemptNumber: _totalAttempts,
        roundNumber: _currentRound,
        correctAnswer: '',
      );
    }

    _totalAttempts++;
    final isCorrect = playerAnswer == round.correctAnswer;
    if (isCorrect) {
      _correctAnswers++;
    } else {
      _errors++;
    }

    return AnswerResult(
      isCorrect: isCorrect,
      attemptNumber: _totalAttempts,
      roundNumber: _currentRound,
      correctAnswer: round.correctAnswer,
    );
  }

  /// Resets to initial state — called when the player restarts.
  void reset() {
    _currentRound = 0;
    _totalAttempts = 0;
    _correctAnswers = 0;
    _errors = 0;
    _activeRound = null;
  }

  // ── Private round generation ───────────────────────────────────────────────

  PatternRound _generateRound(final int roundNumber) {
    return switch (patternType) {
      PatternType.numeric => _numericRound(roundNumber),
      PatternType.color => _colorRound(roundNumber),
      PatternType.shape => _shapeRound(roundNumber),
    };
  }

  /// Arithmetic sequence: [start, start+step, start+step*2, ?]
  /// Difficulty scales the step range and sequence length.
  PatternRound _numericRound(final int roundNumber) {
    final rng = Random(roundNumber * 31 + difficulty.index * 7);

    final seqLength = _sequenceLengthFor();
    final start = rng.nextInt(10) + 1;
    final step = rng.nextInt(_maxStepFor()) + 1;

    final sequence = List.generate(seqLength, (final i) => '${start + i * step}');
    final answer = '${start + seqLength * step}';

    // Distractors: answer ± small offsets
    final distractors = <String>{};
    distractors.add(answer);
    while (distractors.length < 4) {
      final offset = rng.nextInt(3) + 1;
      distractors.add('${int.parse(answer) + offset}');
      distractors.add('${int.parse(answer) - offset}');
    }
    final options = distractors.take(4).toList()..shuffle(rng);

    return PatternRound(
      sequence: sequence,
      correctAnswer: answer,
      options: options,
      patternType: PatternType.numeric,
    );
  }

  /// Color repeating pattern: [A, B, A, B, ?] or [A, A, B, A, A, ?]
  ///
  /// Always produces exactly 4 distinct options: the correct answer plus
  /// 3 distractors drawn from the full [colors] pool (not just the 3-item
  /// palette), guaranteeing 4 unique items even when [answer] is already in
  /// [palette].
  PatternRound _colorRound(final int roundNumber) {
    final rng = Random(roundNumber * 53 + difficulty.index * 11);

    const colors = ['🔴', '🔵', '🟡', '🟢', '🟠', '🟣'];
    final palette = (colors.toList()..shuffle(rng)).take(3).toList();

    final seqLength = _sequenceLengthFor();
    final patternBase = palette.take(2).toList();
    final sequence = List.generate(seqLength, (final i) => patternBase[i % 2]);
    final answer = patternBase[seqLength % 2];

    // Build exactly 3 distinct distractors from the full pool, excluding answer.
    final distractorPool = (colors.toList()..shuffle(rng))
        .where((final c) => c != answer)
        .toList();
    final distractors = distractorPool.take(3).toList();

    final options = [answer, ...distractors]..shuffle(rng);

    return PatternRound(
      sequence: sequence,
      correctAnswer: answer,
      options: options,
      patternType: PatternType.color,
    );
  }

  /// Shape repeating pattern: [○, □, △, ○, □, ?]
  ///
  /// Always produces exactly 4 distinct options: the correct answer plus
  /// 3 distractors drawn from the full [shapes] pool (not just the 3-item
  /// palette), guaranteeing 4 unique items even when [answer] is already in
  /// [palette].
  PatternRound _shapeRound(final int roundNumber) {
    final rng = Random(roundNumber * 79 + difficulty.index * 13);

    const shapes = ['⭕', '🔷', '🔺', '⬛', '🔶', '🔻'];
    final palette = (shapes.toList()..shuffle(rng)).take(3).toList();

    final seqLength = _sequenceLengthFor();
    final patternBase = palette.take(2).toList();
    final sequence = List.generate(seqLength, (final i) => patternBase[i % 2]);
    final answer = patternBase[seqLength % 2];

    // Build exactly 3 distinct distractors from the full pool, excluding answer.
    final distractorPool = (shapes.toList()..shuffle(rng))
        .where((final s) => s != answer)
        .toList();
    final distractors = distractorPool.take(3).toList();

    final options = [answer, ...distractors]..shuffle(rng);

    return PatternRound(
      sequence: sequence,
      correctAnswer: answer,
      options: options,
      patternType: PatternType.shape,
    );
  }

  int _sequenceLengthFor() => switch (difficulty) {
        Difficulty.easy => 3,
        Difficulty.medium => 4,
        Difficulty.hard => 5,
      };

  int _maxStepFor() => switch (difficulty) {
        Difficulty.easy => 3,
        Difficulty.medium => 5,
        Difficulty.hard => 8,
      };
}

// ── Supporting types ──────────────────────────────────────────────────────────

/// A single pattern recognition round.
final class PatternRound {
  const PatternRound({
    required this.sequence,
    required this.correctAnswer,
    required this.options,
    required this.patternType,
  });

  /// The visible sequence tiles (all but the last).
  final List<String> sequence;

  /// The correct answer (the missing last element).
  final String correctAnswer;

  /// 4 answer options (includes the correct answer, shuffled).
  final List<String> options;

  final PatternType patternType;
}

/// Result of [PatternController.submitAnswer].
final class AnswerResult {
  const AnswerResult({
    required this.isCorrect,
    required this.attemptNumber,
    required this.roundNumber,
    required this.correctAnswer,
  });

  final bool isCorrect;
  final int attemptNumber;
  final int roundNumber;
  final String correctAnswer;
}
