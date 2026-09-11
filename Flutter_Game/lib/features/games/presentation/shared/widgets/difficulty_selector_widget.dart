import 'package:flutter/material.dart';

import 'package:cognitive_care_games/features/games/domain/value_objects/difficulty.dart';
import 'package:cognitive_care_games/features/games/presentation/shared/design_system/app_colors.dart';
import 'package:cognitive_care_games/features/games/presentation/shared/design_system/app_dimensions.dart';
import 'package:cognitive_care_games/features/games/presentation/shared/design_system/app_text_styles.dart';

/// Three-button difficulty selector — Easy / Medium / Hard.
///
/// Uses [ElderlyButton]-equivalent sizing directly (avoids importing
/// [ElderlyButton] to keep coupling minimal; both derive from the same
/// design system constants).
///
/// Design decisions:
///   - All three buttons visible simultaneously — no dropdown.
///   - Selected state uses [AppColors.primary] fill with white text.
///   - Unselected state uses outlined style (same as ElderlyButton.secondary).
///   - Minimum tap target: [AppDimensions.buttonHeightSecondary] × full width.
///   - Buttons are evenly spaced in a Row; each expands to fill 1/3 of width.
///
/// Callback:
///   [onSelected] is called every time the player taps a button, even if
///   it is already the current selection (idempotent — safe for the notifier).
class DifficultySelectorWidget extends StatelessWidget {
  const DifficultySelectorWidget({
    super.key,
    required this.selectedDifficulty,
    required this.onSelected,
    this.isEnabled = true,
  });

  final Difficulty selectedDifficulty;
  final ValueChanged<Difficulty> onSelected;

  /// Set to false during an active game session (prevents mid-game changes).
  final bool isEnabled;

  @override
  Widget build(final BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text(
          'Select Difficulty',
          style: AppTextStyles.headlineSmall,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: AppDimensions.spacingSmall),
        Row(
          children: Difficulty.values.map((final difficulty) {
            final isSelected = difficulty == selectedDifficulty;
            return Expanded(
              child: Padding(
                padding: EdgeInsets.only(
                  right: difficulty != Difficulty.values.last
                      ? AppDimensions.touchTargetGap
                      : 0,
                ),
                child: _DifficultyButton(
                  difficulty: difficulty,
                  isSelected: isSelected,
                  isEnabled: isEnabled,
                  onTap: () => onSelected(difficulty),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}

class _DifficultyButton extends StatelessWidget {
  const _DifficultyButton({
    required this.difficulty,
    required this.isSelected,
    required this.isEnabled,
    required this.onTap,
  });

  final Difficulty difficulty;
  final bool isSelected;
  final bool isEnabled;
  final VoidCallback onTap;

  @override
  Widget build(final BuildContext context) {
    final effectiveCallback = isEnabled ? onTap : null;

    return Semantics(
      button: true,
      selected: isSelected,
      enabled: isEnabled,
      label: '${difficulty.displayLabel} difficulty',
      child: ConstrainedBox(
        constraints: const BoxConstraints(
          minHeight: AppDimensions.buttonHeightSecondary,
          minWidth: AppDimensions.touchTargetMin,
        ),
        child: Material(
          color: isSelected ? AppColors.primary : AppColors.surface,
          borderRadius: BorderRadius.circular(AppDimensions.buttonBorderRadius),
          elevation: isSelected
              ? AppDimensions.buttonElevation
              : AppDimensions.elevationPressed,
          child: InkWell(
            onTap: effectiveCallback,
            borderRadius:
                BorderRadius.circular(AppDimensions.buttonBorderRadius),
            splashFactory: NoSplash.splashFactory,
            child: Container(
              decoration: BoxDecoration(
                borderRadius:
                    BorderRadius.circular(AppDimensions.buttonBorderRadius),
                border: isSelected
                    ? null
                    : Border.all(
                        color: isEnabled
                            ? AppColors.primary
                            : AppColors.textDisabled,
                        width: AppDimensions.cardBorderWidth,
                      ),
              ),
              alignment: Alignment.center,
              padding: const EdgeInsets.symmetric(
                horizontal: AppDimensions.spacingSmall,
                vertical: AppDimensions.spacingXSmall,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    difficulty.displayLabel,
                    style: AppTextStyles.labelMedium.copyWith(
                      color: isSelected
                          ? AppColors.onPrimary
                          : (isEnabled
                              ? AppColors.primary
                              : AppColors.textDisabled),
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    _subtitleFor(difficulty),
                    style: AppTextStyles.bodyMedium.copyWith(
                      fontSize: 13,
                      color: isSelected
                          ? AppColors.onPrimary.withAlpha(200)
                          : AppColors.textSecondary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  String _subtitleFor(final Difficulty d) => switch (d) {
        Difficulty.easy => '3 min',
        Difficulty.medium => '2 min',
        Difficulty.hard => '90 sec',
      };
}
