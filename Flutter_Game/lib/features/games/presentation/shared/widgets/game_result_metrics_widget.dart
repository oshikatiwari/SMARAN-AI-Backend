import 'package:flutter/material.dart';

import 'package:cognitive_care_games/features/games/domain/entities/game_result.dart';
import 'package:cognitive_care_games/features/games/domain/entities/game_session.dart';
import 'package:cognitive_care_games/features/games/presentation/shared/design_system/app_colors.dart';
import 'package:cognitive_care_games/features/games/presentation/shared/design_system/app_dimensions.dart';
import 'package:cognitive_care_games/features/games/presentation/shared/design_system/app_text_styles.dart';
import 'elderly_button.dart';

/// Displays the full metrics summary on the post-game result screen.
///
/// Used by both [MemoryGameResultScreen] and [PatternGameResultScreen].
/// Both games pass the same [GameResult] entity — identical rendering,
/// zero code duplication.
///
/// Layout (top-to-bottom):
///   ┌──────────────────────────────────┐
///   │  Completion Banner (✓ or ✗)      │
///   │  Duration            MM:SS       │
///   │  Accuracy             80%        │
///   │  Attempts              10        │
///   │  Errors                 2        │
///   │  Hints Used             1        │
///   │  Completion           100%       │
///   │                                  │
///   │  [Play Again]   [Back to Menu]   │
///   └──────────────────────────────────┘
class GameResultMetricsWidget extends StatelessWidget {
  const GameResultMetricsWidget({
    super.key,
    required this.session,
    required this.result,
    required this.onPlayAgain,
    required this.onBackToMenu,
  });

  final GameSession session;
  final GameResult result;
  final VoidCallback onPlayAgain;
  final VoidCallback onBackToMenu;

  @override
  Widget build(final BuildContext context) {
    final isCompleted = result.completionRate >= 1.0;

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.screenPaddingH,
        vertical: AppDimensions.screenPaddingV,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ── Completion banner ──────────────────────────────────────────
          _CompletionBanner(isCompleted: isCompleted),

          const SizedBox(height: AppDimensions.spacingLarge),

          // ── Metrics grid ───────────────────────────────────────────────
          _MetricsCard(result: result),

          const SizedBox(height: AppDimensions.spacingLarge),

          // ── Actions ────────────────────────────────────────────────────
          ElderlyButton(
            label: 'Play Again',
            onPressed: onPlayAgain,
            isFullWidth: true,
            icon: Icons.replay_rounded,
          ),
          const SizedBox(height: AppDimensions.spacingSmall),
          ElderlyButton.secondary(
            label: 'Back to Menu',
            onPressed: onBackToMenu,
            isFullWidth: true,
            icon: Icons.home_outlined,
          ),
        ],
      ),
    );
  }
}

class _CompletionBanner extends StatelessWidget {
  const _CompletionBanner({required this.isCompleted});

  final bool isCompleted;

  @override
  Widget build(final BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.spacingMedium),
      decoration: BoxDecoration(
        color: isCompleted ? AppColors.success : AppColors.secondary,
        borderRadius: BorderRadius.circular(AppDimensions.cardBorderRadius),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            isCompleted
                ? Icons.check_circle_outline_rounded
                : Icons.timelapse_rounded,
            color: AppColors.onPrimary,
            size: AppDimensions.iconSizePrimary,
            semanticLabel: isCompleted ? 'Completed' : 'Incomplete',
          ),
          const SizedBox(width: AppDimensions.spacingSmall),
          Text(
            isCompleted ? 'Well Done!' : 'Good Try!',
            style: AppTextStyles.headlineMedium.copyWith(
              color: AppColors.onPrimary,
            ),
          ),
        ],
      ),
    );
  }
}

class _MetricsCard extends StatelessWidget {
  const _MetricsCard({required this.result});

  final GameResult result;

  @override
  Widget build(final BuildContext context) {
    return Card(
      elevation: AppDimensions.cardElevation,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDimensions.cardBorderRadius),
      ),
      color: AppColors.surface,
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.spacingMedium),
        child: Column(
          children: [
            _MetricRow(
              label: 'Duration',
              value: result.formattedDuration,
              icon: Icons.timer_outlined,
            ),
            const Divider(color: AppColors.divider, height: AppDimensions.spacingMedium),
            _MetricRow(
              label: 'Accuracy',
              value: '${(result.accuracy * 100).round()}%',
              icon: Icons.track_changes_rounded,
              highlight: result.accuracy >= 0.8,
            ),
            const Divider(color: AppColors.divider, height: AppDimensions.spacingMedium),
            _MetricRow(
              label: 'Attempts',
              value: '${result.attempts}',
              icon: Icons.touch_app_outlined,
            ),
            const Divider(color: AppColors.divider, height: AppDimensions.spacingMedium),
            _MetricRow(
              label: 'Errors',
              value: '${result.errors}',
              icon: Icons.close_rounded,
              highlight: result.errors == 0,
              warningWhenPositive: true,
            ),
            const Divider(color: AppColors.divider, height: AppDimensions.spacingMedium),
            _MetricRow(
              label: 'Hints Used',
              value: '${result.hintsUsed}',
              icon: Icons.lightbulb_outline_rounded,
            ),
            const Divider(color: AppColors.divider, height: AppDimensions.spacingMedium),
            _MetricRow(
              label: 'Completion',
              value: '${(result.completionRate * 100).round()}%',
              icon: Icons.check_circle_outline_rounded,
              highlight: result.completionRate >= 1.0,
            ),
          ],
        ),
      ),
    );
  }
}

class _MetricRow extends StatelessWidget {
  const _MetricRow({
    required this.label,
    required this.value,
    required this.icon,
    this.highlight = false,
    this.warningWhenPositive = false,
  });

  final String label;
  final String value;
  final IconData icon;

  /// When true, the value is displayed in [AppColors.success] green.
  final bool highlight;

  /// When true and the parsed value is > 0, display in [AppColors.error].
  final bool warningWhenPositive;

  @override
  Widget build(final BuildContext context) {
    Color valueColor = AppColors.textPrimary;
    if (highlight) valueColor = AppColors.success;
    if (warningWhenPositive && int.tryParse(value) != null) {
      if ((int.tryParse(value) ?? 0) > 0) valueColor = AppColors.error;
    }

    return Semantics(
      label: '$label: $value',
      child: Row(
        children: [
          Icon(icon, color: AppColors.primary, size: AppDimensions.iconSizeSecondary),
          const SizedBox(width: AppDimensions.spacingSmall),
          Expanded(
            child: Text(label, style: AppTextStyles.bodyLarge),
          ),
          Text(
            value,
            style: AppTextStyles.metricValue.copyWith(color: valueColor),
          ),
        ],
      ),
    );
  }
}
