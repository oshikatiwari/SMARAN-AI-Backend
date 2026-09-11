import 'package:flutter/material.dart';

import 'package:cognitive_care_games/features/games/presentation/shared/design_system/app_colors.dart';
import 'package:cognitive_care_games/features/games/presentation/shared/design_system/app_dimensions.dart';
import 'package:cognitive_care_games/features/games/presentation/shared/design_system/app_text_styles.dart';

/// Displays the attempt and error counts for the active game session.
///
/// Presentational only — values are passed in as plain integers.
/// Riverpod wires live values in Milestone 6.
///
/// Layout:
///   [attempts icon] [attempt count]   [errors icon] [error count]
///
/// Both counts are displayed in the HUD style (large, white, high-contrast).
class AttemptCounterWidget extends StatelessWidget {
  const AttemptCounterWidget({
    super.key,
    required this.attempts,
    required this.errors,
  });

  /// Total number of flip pairs attempted (MM) or answers submitted (PR).
  final int attempts;

  /// Number of wrong answers or mismatches.
  final int errors;

  @override
  Widget build(final BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _CountChip(
          icon: Icons.touch_app_outlined,
          value: attempts,
          semanticLabel: '$attempts attempts',
        ),
        const SizedBox(width: AppDimensions.spacingSmall),
        _CountChip(
          icon: Icons.close_rounded,
          value: errors,
          semanticLabel: '$errors errors',
          highlightWhenNonZero: true,
        ),
      ],
    );
  }
}

/// A single icon + number chip for the HUD counter display.
class _CountChip extends StatelessWidget {
  const _CountChip({
    required this.icon,
    required this.value,
    required this.semanticLabel,
    this.highlightWhenNonZero = false,
  });

  final IconData icon;
  final int value;
  final String semanticLabel;

  /// When true, the chip turns amber if [value] > 0 (draws attention to errors).
  final bool highlightWhenNonZero;

  @override
  Widget build(final BuildContext context) {
    final isHighlighted = highlightWhenNonZero && value > 0;

    return Semantics(
      label: semanticLabel,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: isHighlighted ? AppColors.secondary : AppColors.hudText,
            size: AppDimensions.iconSizeSecondary,
          ),
          const SizedBox(width: 4),
          Text(
            '$value',
            style: AppTextStyles.hudValue.copyWith(
              color: isHighlighted ? AppColors.secondary : AppColors.hudText,
            ),
          ),
        ],
      ),
    );
  }
}

/// Standalone hint counter chip — used inside [GameHudWidget] when a game
/// supports the hint feature.
class HintCounterWidget extends StatelessWidget {
  const HintCounterWidget({super.key, required this.hintsUsed});

  final int hintsUsed;

  @override
  Widget build(final BuildContext context) {
    return Semantics(
      label: '$hintsUsed hints used',
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.lightbulb_outline_rounded,
            color: hintsUsed > 0 ? AppColors.secondary : AppColors.hudText,
            size: AppDimensions.iconSizeSecondary,
          ),
          const SizedBox(width: 4),
          Text(
            '$hintsUsed',
            style: AppTextStyles.hudValue.copyWith(
              color: hintsUsed > 0 ? AppColors.secondary : AppColors.hudText,
            ),
          ),
        ],
      ),
    );
  }
}
