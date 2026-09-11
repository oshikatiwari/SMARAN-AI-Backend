import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import 'package:cognitive_care_games/features/games/data/services/smaran_ai_service.dart';
import 'package:cognitive_care_games/features/games/domain/entities/game_config.dart';
import 'package:cognitive_care_games/features/games/domain/entities/game_result.dart';
import 'package:cognitive_care_games/features/games/domain/entities/game_session.dart';
import 'package:cognitive_care_games/features/games/domain/usecases/start_game_session.dart';
import 'package:cognitive_care_games/features/games/domain/value_objects/difficulty.dart';
import 'package:cognitive_care_games/features/games/domain/value_objects/game_type.dart';
import 'package:cognitive_care_games/features/games/domain/value_objects/session_status.dart';
import 'package:cognitive_care_games/features/games/domain/value_objects/sync_status.dart';
import 'package:cognitive_care_games/features/games/presentation/providers/difficulty_provider.dart';
import 'package:cognitive_care_games/features/games/presentation/providers/metrics_state_notifier.dart';
import 'package:cognitive_care_games/features/games/presentation/providers/usecase_providers.dart';

// ── State ─────────────────────────────────────────────────────────────────────

final class SessionState extends Equatable {
  const SessionState({
    this.session,
    this.config,
    this.result,
    this.errorMessage,
    this.isLoading = false,
    this.aiResponse,
  });

  final GameSession? session;
  final GameConfig? config;
  final GameResult? result;
  final String? errorMessage;
  final bool isLoading;
  final SmaranAiResponse? aiResponse;

  bool get hasActiveSession =>
      session != null && session!.status == SessionStatus.inProgress;

  bool get isCompleted =>
      session != null && session!.status == SessionStatus.completed;

  bool get hasError => errorMessage != null;

  SessionState copyWith({
    GameSession? session,
    GameConfig? config,
    GameResult? result,
    String? errorMessage,
    bool clearError = false,
    bool? isLoading,
    SmaranAiResponse? aiResponse,
  }) =>
      SessionState(
        session: session ?? this.session,
        config: config ?? this.config,
        result: result ?? this.result,
        errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
        isLoading: isLoading ?? this.isLoading,
        aiResponse: aiResponse ?? this.aiResponse,
      );

  @override
  List<Object?> get props =>
      [session, config, result, errorMessage, isLoading, aiResponse];
}

// ── Notifier ──────────────────────────────────────────────────────────────────

/// Riverpod 3.x: Notifier<T> directly (autoDispose on provider declaration).
class SessionStateNotifier extends Notifier<SessionState> {
  static const _uuid = Uuid();

  @override
  SessionState build() => const SessionState();

  Future<GameConfig?> startSession({
    required GameType gameType,
    required Difficulty difficulty,
  }) async {
    state = state.copyWith(isLoading: true, clearError: true);

    try {
      final getConfig = await ref.read(getGameConfigProvider.future);
      final config = await getConfig.execute(
        gameType: gameType,
        difficulty: difficulty,
      );

      final startUseCase = await ref.read(startGameSessionProvider.future);
      final session = await startUseCase.execute(
        sessionId: _uuid.v4(),
        gameType: gameType,
        difficulty: difficulty,
      );

      state = state.copyWith(
        session: session,
        config: config,
        isLoading: false,
      );

      return config;
    } on DomainException catch (e) {
      state = state.copyWith(errorMessage: e.message, isLoading: false);
      return null;
    } catch (e) {
      state = state.copyWith(
        errorMessage: 'Unexpected error starting session: $e',
        isLoading: false,
      );
      return null;
    }
  }

  Future<void> endSession({required SessionStatus finalStatus}) async {
    final currentSession = state.session;
    if (currentSession == null) return;
    if (currentSession.status.isTerminal) return;

    state = state.copyWith(isLoading: true, clearError: true);

    try {
      final metrics = ref.read(metricsNotifierProvider);
      final endTimeMs = DateTime.now().millisecondsSinceEpoch;

      final endUseCase = await ref.read(endGameSessionProvider.future);
      final updatedSession = await endUseCase.execute(
        sessionId: currentSession.id,
        finalStatus: finalStatus,
        endTimeMs: endTimeMs,
      );

      final accuracy = metrics.accuracy;
      final completionRate = finalStatus == SessionStatus.completed
          ? 1.0
          : metrics.completionRate.clamp(0.0, 1.0);

      final gameResult = GameResult(
        id: _uuid.v4(),
        sessionId: currentSession.id,
        accuracy: accuracy,
        responseTimeMs: metrics.elapsedMs > 0
            ? metrics.elapsedMs
            : endTimeMs - currentSession.startTime,
        attempts: metrics.attempts,
        errors: metrics.errors,
        hintsUsed: metrics.hintsUsed,
        completionRate: completionRate,
        syncStatus: SyncStatus.unsynced,
        createdAt: endTimeMs,
      );

      // Local persistence occurs first: record game result to local DB.
      final recordUseCase = await ref.read(recordGameResultProvider.future);
      final savedResult = await recordUseCase.execute(gameResult);

      // AI Integration: Send metrics to SMARAN AI backend POST /predict-difficulty.
      //
      // Compliance Rules:
      // - Runs AFTER local GameResult persistence (Rule 5 & Rule 8).
      // - Omits patient_id (Rule 9).
      // - Omits attempts (Rule 10).
      // - Fails gracefully if backend unavailable/offline, without breaking game flow or local saving (Rule 11 & Rule 12).
      SmaranAiResponse? aiResponse;
      try {
        final aiService = ref.read(smaranAiServiceProvider);
        aiResponse = await aiService.predictDifficulty(
          gameType: currentSession.gameType,
          currentDifficulty: currentSession.difficulty,
          result: savedResult,
        );

        if (aiResponse != null) {
          // Store the recommended difficulty in difficultyProvider so the next game session automatically picks it up (Rule 7).
          ref
              .read(difficultyProvider.notifier)
              .select(aiResponse.recommendedDifficulty);
        }
      } catch (_) {
        // AI call failure is handled gracefully — local game result remains saved.
      }

      state = state.copyWith(
        session: updatedSession,
        result: savedResult,
        aiResponse: aiResponse,
        isLoading: false,
      );
    } on DomainException catch (e) {
      state = state.copyWith(errorMessage: e.message, isLoading: false);
    } catch (e) {
      state = state.copyWith(
        errorMessage: 'Failed to save game result: $e',
        isLoading: false,
      );
    }
  }

  void clearError() => state = state.copyWith(clearError: true);

  void reset() => state = const SessionState();
}

/// App-lifetime provider.
///
/// [startSession] and [endSession] perform async DB work while no widget is
/// listening (game menus only `ref.read` the notifier), so an autoDispose
/// provider would be disposed mid-await and throw "Ref used after dispose",
/// deadening the Start Game button and result persistence. State is instead
/// cleared explicitly via [SessionStateNotifier.reset] on every Start Game.
final sessionNotifierProvider =
    NotifierProvider<SessionStateNotifier, SessionState>(
  SessionStateNotifier.new,
);
