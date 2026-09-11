import 'package:equatable/equatable.dart';

import 'package:cognitive_care_games/features/games/domain/value_objects/sync_status.dart';

/// Domain entity carrying all six per-session metrics.
///
/// This is the canonical metrics schema shared by BOTH games. The AI-analysis
/// module and dashboard consume [GameResult] instances through the module's
/// public barrel export — they never query Drift rows directly.
///
/// Metric definitions (match the Drift game_results table schema exactly):
///   [accuracy]       — correct outcomes / total attempts, range [0.0, 1.0]
///   [responseTimeMs] — total elapsed milliseconds for the session
///   [attempts]       — total flip pairs (Memory Matching) or answer submits
///                      (Pattern Recognition)
///   [errors]         — mismatch count (MM) or wrong answer count (PR)
///   [hintsUsed]      — number of hint requests during the session
///   [completionRate] — completed objectives / total objectives, [0.0, 1.0]
///
/// Validation is enforced by [RecordGameResult] use-case before persistence.
///
/// Immutable: use [copyWith] to produce modified instances.
final class GameResult extends Equatable {
  const GameResult({
    required this.id,
    required this.sessionId,
    required this.accuracy,
    required this.responseTimeMs,
    required this.attempts,
    required this.errors,
    required this.hintsUsed,
    required this.completionRate,
    required this.syncStatus,
    required this.createdAt,
  });

  /// Client-generated UUID v4.
  final String id;

  /// Foreign key → GameSession.id
  final String sessionId;

  /// Correct outcomes / total attempts. Range: [0.0, 1.0].
  final double accuracy;

  /// Total session duration in milliseconds.
  final int responseTimeMs;

  /// Total attempt count.
  final int attempts;

  /// Mismatch / wrong answer count.
  final int errors;

  /// Number of hints used.
  final int hintsUsed;

  /// Objectives completed / total objectives. Range: [0.0, 1.0].
  final double completionRate;

  final SyncStatus syncStatus;

  /// UTC epoch milliseconds when this row was created.
  final int createdAt;

  // ── Derived helpers ─────────────────────────────────────────────────────

  /// Correct attempts = total attempts minus errors.
  int get correctAttempts => attempts - errors;

  /// Session duration formatted as "mm:ss" for display.
  String get formattedDuration {
    final totalSeconds = responseTimeMs ~/ 1000;
    final minutes = totalSeconds ~/ 60;
    final seconds = totalSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:'
        '${seconds.toString().padLeft(2, '0')}';
  }

  // ── copyWith ─────────────────────────────────────────────────────────────

  GameResult copyWith({
    String? id,
    String? sessionId,
    double? accuracy,
    int? responseTimeMs,
    int? attempts,
    int? errors,
    int? hintsUsed,
    double? completionRate,
    SyncStatus? syncStatus,
    int? createdAt,
  }) =>
      GameResult(
        id: id ?? this.id,
        sessionId: sessionId ?? this.sessionId,
        accuracy: accuracy ?? this.accuracy,
        responseTimeMs: responseTimeMs ?? this.responseTimeMs,
        attempts: attempts ?? this.attempts,
        errors: errors ?? this.errors,
        hintsUsed: hintsUsed ?? this.hintsUsed,
        completionRate: completionRate ?? this.completionRate,
        syncStatus: syncStatus ?? this.syncStatus,
        createdAt: createdAt ?? this.createdAt,
      );

  @override
  List<Object?> get props => [
        id,
        sessionId,
        accuracy,
        responseTimeMs,
        attempts,
        errors,
        hintsUsed,
        completionRate,
        syncStatus,
        createdAt,
      ];

  @override
  String toString() =>
      'GameResult(sessionId: $sessionId, accuracy: $accuracy, '
      'attempts: $attempts, errors: $errors, hints: $hintsUsed, '
      'completion: $completionRate)';
}
