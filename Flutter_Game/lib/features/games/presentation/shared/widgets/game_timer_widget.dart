import 'package:flutter/material.dart';

import 'package:cognitive_care_games/features/games/presentation/shared/design_system/app_colors.dart';
import 'package:cognitive_care_games/features/games/presentation/shared/design_system/app_dimensions.dart';
import 'package:cognitive_care_games/features/games/presentation/shared/design_system/app_text_styles.dart';

/// Displays elapsed game time in MM:SS format.
///
/// Accepts [elapsedSeconds] as a plain integer — Riverpod wires
/// the live value in Milestone 6. This widget is purely presentational.
///
/// Colour changes at threshold to give elderly users a gentle warning:
///   [warningThresholdSeconds] → amber background
///   [criticalThresholdSeconds] → red background
///
/// Both thresholds default to null (no colour change) when not provided,
/// which is appropriate when the game has no time limit.
class GameTimerWidget extends StatelessWidget {
  const GameTimerWidget({
    super.key,
    required this.elapsedSeconds,
    this.timeLimitSeconds,
    this.warningThresholdSeconds,
    this.criticalThresholdSeconds,
    this.showIcon = true,
  });

  /// Total elapsed seconds since session started.
  final int elapsedSeconds;

  /// Maximum session duration. Null = no limit.
  final int? timeLimitSeconds;

  /// Seconds remaining below which the widget turns amber. Null = no warning.
  final int? warningThresholdSeconds;

  /// Seconds remaining below which the widget turns red. Null = no critical.
  final int? criticalThresholdSeconds;

  /// Whether to show the clock icon alongside the time. Default: true.
  final bool showIcon;

  @override
  Widget build(final BuildContext context) {
    final remainingSeconds =
        timeLimitSeconds != null ? timeLimitSeconds! - elapsedSeconds : null;

    final displaySeconds =
        timeLimitSeconds != null ? (remainingSeconds ?? 0) : elapsedSeconds;
    final displayText = _formatSeconds(displaySeconds.clamp(0, 99 * 60 + 59));

    final bgColor = _backgroundColor(remainingSeconds);

    return Semantics(
      label: 'Timer: $displayText',
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.symmetric(
          horizontal: AppDimensions.spacingSmall,
          vertical: AppDimensions.spacingXSmall,
        ),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(AppDimensions.tileBorderRadius),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (showIcon) ...[
              Icon(
                Icons.timer_outlined,
                color: AppColors.hudText,
                size: AppDimensions.iconSizeSecondary,
                semanticLabel: 'Timer icon',
              ),
              const SizedBox(width: AppDimensions.spacingXSmall),
            ],
            Text(displayText, style: AppTextStyles.hudValue),
          ],
        ),
      ),
    );
  }

  Color _backgroundColor(final int? remainingSeconds) {
    if (remainingSeconds == null) return Colors.transparent;
    if (criticalThresholdSeconds != null &&
        remainingSeconds <= criticalThresholdSeconds!) {
      return AppColors.error.withAlpha(200);
    }
    if (warningThresholdSeconds != null &&
        remainingSeconds <= warningThresholdSeconds!) {
      return AppColors.secondary.withAlpha(200);
    }
    return Colors.transparent;
  }

  /// Formats [totalSeconds] as MM:SS.
  static String _formatSeconds(final int totalSeconds) {
    final minutes = totalSeconds ~/ 60;
    final seconds = totalSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:'
        '${seconds.toString().padLeft(2, '0')}';
  }
}
