import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:cognitive_care_games/features/games/domain/entities/game_config.dart';
import 'package:cognitive_care_games/features/games/domain/value_objects/pattern_type.dart';
import 'package:cognitive_care_games/features/games/domain/value_objects/session_status.dart';
import 'package:cognitive_care_games/features/games/presentation/providers/game_event_bus.dart';
import 'package:cognitive_care_games/features/games/presentation/providers/metrics_state_notifier.dart';
import 'package:cognitive_care_games/features/games/presentation/providers/session_state_notifier.dart';
import 'package:cognitive_care_games/features/games/presentation/shared/design_system/app_colors.dart';
import 'package:cognitive_care_games/features/games/presentation/shared/design_system/app_dimensions.dart';
import 'package:cognitive_care_games/features/games/presentation/shared/design_system/app_text_styles.dart';
import 'package:cognitive_care_games/features/games/presentation/shared/widgets/elderly_button.dart';
import 'package:cognitive_care_games/features/games/presentation/shared/widgets/game_timer_widget.dart';
import 'package:cognitive_care_games/features/games/presentation/pattern_recognition/flame/pattern_recognition_game.dart';
import 'pattern_game_result_screen.dart';

/// Active Pattern Recognition game screen.
///
/// Identical structural pattern to [MemoryGameScreen]:
///   Flame [GameWidget] + Flutter HUD overlay + quit button.
/// Uses [PatternRecognitionGame] instead of [MemoryMatchingGame].
class PatternGameScreen extends ConsumerStatefulWidget {
  const PatternGameScreen({
    super.key,
    required this.config,
    required this.patternType,
  });

  final GameConfig config;
  final PatternType patternType;

  @override
  ConsumerState<PatternGameScreen> createState() => _PatternGameScreenState();
}

class _PatternGameScreenState extends ConsumerState<PatternGameScreen> {
  late PatternRecognitionGame _game;
  bool _navigated = false;
  int _currentRound = 0;

  @override
  void initState() {
    super.initState();
    final bus = ref.read(gameEventBusProvider);
    _game = PatternRecognitionGame(
      config: widget.config,
      patternType: widget.patternType,
      eventBus: bus,
    );

    // Track current round for HUD RoundIndicator.
    bus.stream.listen((final event) {
      if (!mounted) return;
      if (event is CorrectAnswerEvent || event is IncorrectAnswerEvent) {
        setState(() {
          _currentRound = event is CorrectAnswerEvent
              ? event.roundNumber
              : (event as IncorrectAnswerEvent).roundNumber;
        });
      }
    });
  }

  @override
  Widget build(final BuildContext context) {
    ref.listen<MetricsState>(metricsNotifierProvider, (_, final next) {
      if (next.isFinished && !_navigated) {
        _navigated = true;
        final status = next.completionRate >= 1.0
            ? SessionStatus.completed
            : SessionStatus.abandoned;
        _navigateToResult(status);
      }
    });

    final metrics = ref.watch(metricsNotifierProvider);
    final elapsed = ref.watch(gameTimerProvider).asData?.value ?? 0;

    // Time-limit expiry.
    final limit = widget.config.timeLimitSeconds;
    if (limit > 0 && elapsed >= limit && !_navigated) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!_navigated && mounted) _game.onAbandon();
      });
    }

    return Scaffold(
      backgroundColor: AppColors.gameBoard,
      body: SafeArea(
        child: Stack(
          children: [
            // ── Flame canvas ───────────────────────────────────────────────
            Positioned.fill(
              child: GameWidget<PatternRecognitionGame>(
                game: _game,
              ),
            ),

            // ── HUD with round indicator ───────────────────────────────────
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: _PatternHud(
                elapsedSeconds: elapsed,
                attempts: metrics.attempts,
                errors: metrics.errors,
                hintsUsed: metrics.hintsUsed,
                currentRound: _currentRound,
                totalRounds: widget.config.totalRounds,
                timeLimitSeconds: widget.config.timeLimitSeconds > 0
                    ? widget.config.timeLimitSeconds
                    : null,
                onHintPressed: () => _game.onHintRequested(),
              ),
            ),

            // ── Quit button ────────────────────────────────────────────────
            Positioned(
              bottom: AppDimensions.spacingMedium,
              right: AppDimensions.screenPaddingH,
              child: ElderlyButton.destructive(
                label: 'Quit',
                onPressed: _onQuit,
                icon: Icons.exit_to_app_rounded,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _onQuit() {
    if (_navigated) return;
    showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (final ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text('Quit Game?', style: AppTextStyles.headlineSmall),
        content: const Text(
          'Your progress will be saved.',
          style: AppTextStyles.bodyLarge,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Keep Playing', style: AppTextStyles.labelMedium),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(
              'Quit',
              style: AppTextStyles.labelMedium.copyWith(color: AppColors.error),
            ),
          ),
        ],
      ),
    ).then((final confirmed) {
      if (confirmed == true && mounted) {
        _game.onAbandon();
      }
    });
  }

  void _navigateToResult(final SessionStatus status) {
    ref
        .read(sessionNotifierProvider.notifier)
        .endSession(finalStatus: status);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      Navigator.pushReplacement<void, void>(
        context,
        MaterialPageRoute<void>(
          builder: (_) => const PatternGameResultScreen(),
        ),
      );
    });
  }
}

/// Extended HUD for Pattern Recognition — adds round counter.
class _PatternHud extends StatelessWidget {
  const _PatternHud({
    required this.elapsedSeconds,
    required this.attempts,
    required this.errors,
    required this.hintsUsed,
    required this.currentRound,
    required this.totalRounds,
    required this.onHintPressed,
    this.timeLimitSeconds,
  });

  final int elapsedSeconds;
  final int attempts;
  final int errors;
  final int hintsUsed;
  final int currentRound;
  final int totalRounds;
  final int? timeLimitSeconds;
  final VoidCallback onHintPressed;

  @override
  Widget build(final BuildContext context) {
    return Container(
      height: AppDimensions.hudHeight,
      color: AppColors.hudBackground,
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.hudPaddingH,
        vertical: AppDimensions.hudPaddingV,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Timer
          GameTimerWidget(
            elapsedSeconds: elapsedSeconds,
            timeLimitSeconds: timeLimitSeconds,
            warningThresholdSeconds:
                timeLimitSeconds != null ? timeLimitSeconds! ~/ 3 : null,
            criticalThresholdSeconds:
                timeLimitSeconds != null ? timeLimitSeconds! ~/ 6 : null,
          ),
          // Round counter
          Semantics(
            label: 'Round $currentRound of $totalRounds',
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '$currentRound / $totalRounds',
                  style: AppTextStyles.hudValue,
                ),
                const Text('Round', style: AppTextStyles.hudLabel),
              ],
            ),
          ),
          // Errors
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.close_rounded,
                color: errors > 0
                    ? AppColors.secondary
                    : AppColors.hudText,
                size: AppDimensions.iconSizeSecondary,
              ),
              const SizedBox(width: 4),
              Text(
                '$errors',
                style: AppTextStyles.hudValue.copyWith(
                  color: errors > 0
                      ? AppColors.secondary
                      : AppColors.hudText,
                ),
              ),
            ],
          ),
          // Hint button
          ConstrainedBox(
            constraints: const BoxConstraints(
              minWidth: AppDimensions.touchTargetMin,
              minHeight: AppDimensions.touchTargetMin,
            ),
            child: InkWell(
              onTap: onHintPressed,
              splashFactory: NoSplash.splashFactory,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.lightbulb_outline_rounded,
                    color: AppColors.hudText,
                    size: AppDimensions.iconSizePrimary,
                  ),
                  Text('$hintsUsed', style: AppTextStyles.hudLabel),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
