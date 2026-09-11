import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:cognitive_care_games/features/games/domain/entities/game_config.dart';
import 'package:cognitive_care_games/features/games/domain/value_objects/session_status.dart';
import 'package:cognitive_care_games/features/games/presentation/providers/game_event_bus.dart';
import 'package:cognitive_care_games/features/games/presentation/providers/metrics_state_notifier.dart';
import 'package:cognitive_care_games/features/games/presentation/providers/session_state_notifier.dart';
import 'package:cognitive_care_games/features/games/presentation/shared/design_system/app_colors.dart';
import 'package:cognitive_care_games/features/games/presentation/shared/design_system/app_dimensions.dart';
import 'package:cognitive_care_games/features/games/presentation/shared/design_system/app_text_styles.dart';
import 'package:cognitive_care_games/features/games/presentation/shared/widgets/elderly_button.dart';
import 'package:cognitive_care_games/features/games/presentation/shared/widgets/game_hud_widget.dart';
import 'package:cognitive_care_games/features/games/presentation/memory_matching/flame/memory_matching_game.dart';
import 'memory_game_result_screen.dart';

/// The active Memory Matching game screen.
///
/// Architecture:
///   - Wraps [MemoryMatchingGame] in a [GameWidget].
///   - Overlays the Flutter [GameHudWidget] at the top (timer, attempts, errors).
///   - Listens to [metricsNotifierProvider] — navigates to result screen when
///     [MetricsState.isFinished] becomes true.
///   - Passes [MemoryMatchingGame] reference to HUD for hint/quit callbacks.
///
/// The game and HUD communicate exclusively through [GameEventBus].
/// No Riverpod providers are read inside Flame components.
class MemoryGameScreen extends ConsumerStatefulWidget {
  const MemoryGameScreen({super.key, required this.config});

  final GameConfig config;

  @override
  ConsumerState<MemoryGameScreen> createState() => _MemoryGameScreenState();
}

class _MemoryGameScreenState extends ConsumerState<MemoryGameScreen> {
  late MemoryMatchingGame _game;

  /// True once the result screen navigation has been initiated.
  bool _navigated = false;

  /// True once the time-limit expiry callback has been scheduled.
  /// Guards against re-scheduling on every rebuild while elapsed >= limit.
  bool _timeoutFired = false;

  @override
  void initState() {
    super.initState();
    final bus = ref.read(gameEventBusProvider);
    _game = MemoryMatchingGame(
      config: widget.config,
      eventBus: bus,
    );
  }

  @override
  Widget build(final BuildContext context) {
    // Watch metrics — navigate when game finishes (complete OR abandoned).
    ref.listen<MetricsState>(metricsNotifierProvider, (_, final next) {
      if (next.isFinished && !_navigated) {
        _navigated = true;
        // Determine correct terminal status from completionRate.
        final status = next.completionRate >= 1.0
            ? SessionStatus.completed
            : SessionStatus.abandoned;
        _navigateToResult(status);
      }
    });

    final metrics = ref.watch(metricsNotifierProvider);
    final elapsed = ref.watch(gameTimerProvider).asData?.value ?? 0;

    // Time-limit expiry: trigger abandon when elapsed >= limit.
    // _timeoutFired ensures the callback is scheduled exactly once, even if
    // the widget rebuilds multiple times while elapsed >= limit.
    final limit = widget.config.timeLimitSeconds;
    if (limit > 0 && elapsed >= limit && !_navigated && !_timeoutFired) {
      _timeoutFired = true;
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
              child: GameWidget<MemoryMatchingGame>(
                game: _game,
              ),
            ),

            // ── Flutter HUD overlay ────────────────────────────────────────
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: GameHudWidget(
                elapsedSeconds: elapsed,
                attempts: metrics.attempts,
                errors: metrics.errors,
                hintsUsed: metrics.hintsUsed,
                timeLimitSeconds: widget.config.timeLimitSeconds > 0
                    ? widget.config.timeLimitSeconds
                    : null,
                onHintPressed: () => _game.onHintRequested(),
              ),
            ),

            // ── Quit button (bottom-right) ─────────────────────────────────
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
          'Your progress will be saved as incomplete.',
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
        // MetricsState.isFinished will become true → ref.listen triggers navigation.
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
          builder: (_) => const MemoryGameResultScreen(),
        ),
      );
    });
  }
}
