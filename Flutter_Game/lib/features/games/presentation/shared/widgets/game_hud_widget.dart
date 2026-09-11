import 'package:flutter/material.dart';

import 'package:cognitive_care_games/features/games/presentation/shared/design_system/app_colors.dart';
import 'package:cognitive_care_games/features/games/presentation/shared/design_system/app_dimensions.dart';
import 'package:cognitive_care_games/features/games/presentation/shared/design_system/app_text_styles.dart';
import 'attempt_counter_widget.dart';
import 'game_timer_widget.dart';

/// Composite HUD bar displayed at the top of both game screens.
///
/// Shows: [timer] | [attempts / errors] | [hints used]
///
/// The HUD sits above the Flame [GameWidget] canvas. Flutter overlays are
/// used because Flame's render system does not have accessibility semantics —
/// keeping the HUD in Flutter ensures screen-reader support and system font
/// scaling work correctly.
///
/// All values are plain integers; Riverpod wires them in Milestone 6.
class GameHudWidget extends StatelessWidget {
  const GameHudWidget({
    super.key,
    required this.elapsedSeconds,
    required this.attempts,
    required this.errors,
    required this.hintsUsed,
    this.timeLimitSeconds,
    this.onHintPressed,
    this.showHintButton = true,
  });

  final int elapsedSeconds;
  final int attempts;
  final int errors;
  final int hintsUsed;

  /// Pass the difficulty's [timeLimitSeconds] to enable countdown mode.
  /// Null = no limit = count-up mode.
  final int? timeLimitSeconds;

  /// Called when the player taps the hint button. Null = hint unavailable.
  final VoidCallback? onHintPressed;

  /// Whether to render the hint button. Set to false for games that don't
  /// support hints.
  final bool showHintButton;

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
          // ── Left: Timer ────────────────────────────────────────────────
          GameTimerWidget(
            elapsedSeconds: elapsedSeconds,
            timeLimitSeconds: timeLimitSeconds,
            warningThresholdSeconds:
                timeLimitSeconds != null ? timeLimitSeconds! ~/ 3 : null,
            criticalThresholdSeconds:
                timeLimitSeconds != null ? timeLimitSeconds! ~/ 6 : null,
          ),

          // ── Centre: Attempts + Errors ──────────────────────────────────
          AttemptCounterWidget(
            attempts: attempts,
            errors: errors,
          ),

          // ── Right: Hints ───────────────────────────────────────────────
          if (showHintButton)
            _HintButton(
              hintsUsed: hintsUsed,
              onPressed: onHintPressed,
            )
          else
            HintCounterWidget(hintsUsed: hintsUsed),
        ],
      ),
    );
  }
}

/// Tappable hint button with used-count badge.
///
/// Enforces [AppDimensions.touchTargetMin] minimum tap area.
class _HintButton extends StatelessWidget {
  const _HintButton({
    required this.hintsUsed,
    this.onPressed,
  });

  final int hintsUsed;
  final VoidCallback? onPressed;

  @override
  Widget build(final BuildContext context) {
    return Semantics(
      button: true,
      enabled: onPressed != null,
      label: 'Hint button, $hintsUsed hints used',
      child: ConstrainedBox(
        constraints: const BoxConstraints(
          minWidth: AppDimensions.touchTargetMin,
          minHeight: AppDimensions.touchTargetMin,
        ),
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(AppDimensions.buttonBorderRadius),
          splashFactory: NoSplash.splashFactory,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.lightbulb_outline_rounded,
                color: onPressed != null
                    ? AppColors.hudText
                    : AppColors.textDisabled,
                size: AppDimensions.iconSizePrimary,
              ),
              Text(
                '$hintsUsed',
                style: AppTextStyles.hudLabel,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// A lightweight "round indicator" for the Pattern Recognition HUD.
///
/// Shows "Round X / Y" in the HUD style — inserted between attempts and
/// hints in the pattern game's HUD configuration.
class RoundIndicatorWidget extends StatelessWidget {
  const RoundIndicatorWidget({
    super.key,
    required this.currentRound,
    required this.totalRounds,
  });

  final int currentRound;
  final int totalRounds;

  @override
  Widget build(final BuildContext context) {
    return Semantics(
      label: 'Round $currentRound of $totalRounds',
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '$currentRound / $totalRounds',
            style: AppTextStyles.hudValue,
          ),
          Text(
            'Round',
            style: AppTextStyles.hudLabel,
          ),
        ],
      ),
    );
  }
}
