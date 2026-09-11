import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:cognitive_care_games/features/games/domain/value_objects/difficulty.dart';
import 'package:cognitive_care_games/features/games/domain/value_objects/game_type.dart';
import 'package:cognitive_care_games/features/games/domain/value_objects/pattern_type.dart';
import 'package:cognitive_care_games/features/games/presentation/providers/difficulty_provider.dart';
import 'package:cognitive_care_games/features/games/presentation/providers/session_state_notifier.dart';
import 'package:cognitive_care_games/features/games/presentation/shared/design_system/app_colors.dart';
import 'package:cognitive_care_games/features/games/presentation/shared/design_system/app_dimensions.dart';
import 'package:cognitive_care_games/features/games/presentation/shared/design_system/app_text_styles.dart';
import 'package:cognitive_care_games/features/games/presentation/shared/widgets/difficulty_selector_widget.dart';
import 'package:cognitive_care_games/features/games/presentation/shared/widgets/elderly_button.dart';
import 'pattern_game_screen.dart';

/// Notifier for selected [PatternType] — autoDispose resets on nav away.
class _PatternTypeNotifier extends Notifier<PatternType> {
  @override
  PatternType build() => PatternType.numeric;
  void select(final PatternType p) => state = p;
}

final selectedPatternTypeProvider =
    NotifierProvider.autoDispose<_PatternTypeNotifier, PatternType>(
  _PatternTypeNotifier.new,
);

/// Menu screen for Pattern Recognition — difficulty + pattern type + start.
class PatternGameMenuScreen extends ConsumerWidget {
  const PatternGameMenuScreen({super.key});

  static const routeName = '/games/pattern-recognition/menu';

  @override
  Widget build(final BuildContext context, final WidgetRef ref) {
    final selectedDifficulty = ref.watch(difficultyProvider);
    final selectedPattern = ref.watch(selectedPatternTypeProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.onPrimary,
        title: const Text('Pattern Recognition', style: AppTextStyles.headlineMedium),
        elevation: 0,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimensions.screenPaddingH,
            vertical: AppDimensions.screenPaddingV,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const _GameDescription(),
              const SizedBox(height: AppDimensions.spacingMedium),

              // ── Pattern type selector ────────────────────────────────────
              const Text('Pattern Type', style: AppTextStyles.headlineSmall),
              const SizedBox(height: AppDimensions.spacingSmall),
              _PatternTypeSelectorWidget(
                selected: selectedPattern,
                onSelected: (final p) =>
                    ref.read(selectedPatternTypeProvider.notifier).select(p),
              ),

              const SizedBox(height: AppDimensions.spacingMedium),

              // ── Difficulty selector ──────────────────────────────────────
              DifficultySelectorWidget(
                selectedDifficulty: selectedDifficulty,
                onSelected: (final d) =>
                    ref.read(difficultyProvider.notifier).select(d),
              ),

              const SizedBox(height: AppDimensions.spacingSmall),
              _DifficultyInfoCard(
                difficulty: selectedDifficulty,
                patternType: selectedPattern,
              ),

              const Spacer(),

              ElderlyButton(
                label: 'Start Game',
                onPressed: () => _startGame(
                  context,
                  ref,
                  selectedDifficulty,
                  selectedPattern,
                ),
                isFullWidth: true,
                icon: Icons.play_arrow_rounded,
              ),
              const SizedBox(height: AppDimensions.spacingSmall),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _startGame(
    final BuildContext context,
    final WidgetRef ref,
    final Difficulty difficulty,
    final PatternType patternType,
  ) async {
    ref.read(sessionNotifierProvider.notifier).reset();

    final config = await ref
        .read(sessionNotifierProvider.notifier)
        .startSession(
          gameType: GameType.patternRecognition,
          difficulty: difficulty,
        );

    if (config == null || !context.mounted) return;

    await Navigator.push<void>(
      context,
      MaterialPageRoute<void>(
        builder: (_) => PatternGameScreen(
          config: config,
          patternType: patternType,
        ),
      ),
    );
  }
}

// ── Pattern Type Selector ─────────────────────────────────────────────────────

class _PatternTypeSelectorWidget extends StatelessWidget {
  const _PatternTypeSelectorWidget({
    required this.selected,
    required this.onSelected,
  });

  final PatternType selected;
  final ValueChanged<PatternType> onSelected;

  @override
  Widget build(final BuildContext context) {
    return Row(
      children: PatternType.values.map((final p) {
        final isSelected = p == selected;
        return Expanded(
          child: Padding(
            padding: EdgeInsets.only(
              right: p != PatternType.values.last
                  ? AppDimensions.touchTargetGap
                  : 0,
            ),
            child: Semantics(
              button: true,
              selected: isSelected,
              label: '${p.displayLabel} pattern type',
              child: ConstrainedBox(
                constraints: const BoxConstraints(
                  minHeight: AppDimensions.buttonHeightSecondary,
                ),
                child: ElevatedButton(
                  onPressed: () => onSelected(p),
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        isSelected ? AppColors.primary : AppColors.surface,
                    foregroundColor:
                        isSelected ? AppColors.onPrimary : AppColors.primary,
                    elevation: isSelected
                        ? AppDimensions.buttonElevation
                        : AppDimensions.elevationPressed,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(
                        AppDimensions.buttonBorderRadius,
                      ),
                      side: BorderSide(
                        color: AppColors.primary,
                        width: AppDimensions.cardBorderWidth,
                      ),
                    ),
                    splashFactory: NoSplash.splashFactory,
                  ),
                  child: Text(p.displayLabel, style: AppTextStyles.labelMedium),
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

class _GameDescription extends StatelessWidget {
  const _GameDescription();

  @override
  Widget build(final BuildContext context) {
    return Card(
      color: AppColors.surface,
      elevation: AppDimensions.cardElevation,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDimensions.cardBorderRadius),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.spacingMedium),
        child: Row(
          children: [
            Icon(
              Icons.pattern_rounded,
              color: AppColors.primary,
              size: AppDimensions.iconSizePrimary,
              semanticLabel: 'Pattern game icon',
            ),
            const SizedBox(width: AppDimensions.spacingSmall),
            const Expanded(
              child: Text(
                'Watch the pattern, then choose what comes next.',
                style: AppTextStyles.bodyLarge,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DifficultyInfoCard extends StatelessWidget {
  const _DifficultyInfoCard({
    required this.difficulty,
    required this.patternType,
  });

  final Difficulty difficulty;
  final PatternType patternType;

  @override
  Widget build(final BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.spacingSmall),
      decoration: BoxDecoration(
        color: AppColors.primary.withAlpha(20),
        borderRadius: BorderRadius.circular(AppDimensions.cardBorderRadius),
        border: Border.all(color: AppColors.primary.withAlpha(60)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _InfoChip(
            icon: Icons.loop_rounded,
            label: 'Rounds',
            value: '${difficulty.totalRounds}',
          ),
          _InfoChip(
            icon: Icons.timer_outlined,
            label: 'Time',
            value: '${difficulty.timeLimitSeconds}s',
          ),
          _InfoChip(
            icon: Icons.category_outlined,
            label: 'Type',
            value: patternType.displayLabel,
          ),
        ],
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  const _InfoChip({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(final BuildContext context) {
    return Semantics(
      label: '$label: $value',
      child: Column(
        children: [
          Icon(icon, color: AppColors.primary, size: AppDimensions.iconSizeSecondary),
          const SizedBox(height: 4),
          Text(value, style: AppTextStyles.headlineSmall),
          Text(label, style: AppTextStyles.bodyMedium),
        ],
      ),
    );
  }
}
