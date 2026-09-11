import 'package:equatable/equatable.dart';

import 'package:cognitive_care_games/features/games/domain/value_objects/difficulty.dart';
import 'package:cognitive_care_games/features/games/domain/value_objects/game_type.dart';
import 'package:cognitive_care_games/features/games/domain/value_objects/session_status.dart';
import 'package:cognitive_care_games/features/games/domain/value_objects/sync_status.dart';

/// Domain entity representing one play-through of a game.
///
/// A session is created when the player taps "Start" and is updated when
/// the game ends (completed or abandoned). [GameResult] is a separate entity
/// containing the metrics for this session.
///
/// Immutable: use [copyWith] to produce updated instances.
final class GameSession extends Equatable {
  const GameSession({
    required this.id,
    required this.gameType,
    required this.difficulty,
    required this.startTime,
    required this.status,
    required this.syncStatus,
    this.endTime,
  });

  /// Client-generated UUID v4. Never null, never server-assigned.
  final String id;

  final GameType gameType;
  final Difficulty difficulty;

  /// UTC timestamp when this session started (milliseconds since epoch).
  final int startTime;

  /// UTC timestamp when this session ended. Null while [status] is [SessionStatus.inProgress].
  final int? endTime;

  final SessionStatus status;
  final SyncStatus syncStatus;

  // ── Derived helpers ─────────────────────────────────────────────────────

  /// Elapsed milliseconds. Returns 0 if the session has no end time yet.
  int get elapsedMs => endTime != null ? endTime! - startTime : 0;

  /// Whether the session is still running.
  bool get isInProgress => status == SessionStatus.inProgress;

  /// Whether the player finished all game objectives.
  bool get isCompleted => status == SessionStatus.completed;

  // ── copyWith ─────────────────────────────────────────────────────────────

  GameSession copyWith({
    String? id,
    GameType? gameType,
    Difficulty? difficulty,
    int? startTime,
    int? endTime,
    SessionStatus? status,
    SyncStatus? syncStatus,
  }) =>
      GameSession(
        id: id ?? this.id,
        gameType: gameType ?? this.gameType,
        difficulty: difficulty ?? this.difficulty,
        startTime: startTime ?? this.startTime,
        endTime: endTime ?? this.endTime,
        status: status ?? this.status,
        syncStatus: syncStatus ?? this.syncStatus,
      );

  @override
  List<Object?> get props => [
        id,
        gameType,
        difficulty,
        startTime,
        endTime,
        status,
        syncStatus,
      ];

  @override
  String toString() =>
      'GameSession(id: $id, game: ${gameType.value}, '
      'difficulty: ${difficulty.value}, status: ${status.value})';
}
