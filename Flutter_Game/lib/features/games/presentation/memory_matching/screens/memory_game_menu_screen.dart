import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:cognitive_care_games/features/games/domain/value_objects/difficulty.dart';
import 'package:cognitive_care_games/features/games/domain/value_objects/game_type.dart';
import 'package:cognitive_care_games/features/games/presentation/providers/difficulty_provider.dart';
import 'package:cognitive_care_games/features/games/presentation/providers/session_state_notifier.dart';
import 'package:cognitive_care_games/features/games/presentation/shared/design_system/app_colors.dart';
import 'package:cognitive_care_games/features/games/presentation/shared/design_system/app_dimensions.dart';
import 'package:cognitive_care_games/features/games/presentation/shared/design_system/app_text_styles.dart';
import 'package:cognitive_care_games/features/games/presentation/shared/widgets/difficulty_selector_widget.dart';
import 'package:cognitive_care_games/features/games/presentation/shared/widgets/elderly_button.dart';
import 'memory_game_screen.dart';

/// Menu screen for Memory Matching — difficulty selection + start button.
///
/// State:
///   [difficultyProvider] — which difficulty is currently selected.
///   [sessionNotifierProvider] — read (not watched) at start tap only.
///
/// Navigation:
///   Start → [MemoryGameScreen] (pushes; game screen pops itself on completion)
///   Back  → Navigator.pop
class MemoryGameMenuScreen extends ConsumerWidget {
  const MemoryGameMenuScreen({super.key});

  static const routeName = '/games/memory-matching/menu';

  @override
  Widget build(final BuildContext context, final WidgetRef ref) {
    final selectedDifficulty = ref.watch(difficultyProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.onPrimary,
        title: const Text('Memory Matching', style: AppTextStyles.headlineMedium),
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
              // ── Game description ─────────────────────────────────────────
              const _GameDescription(),

              const SizedBox(height: AppDimensions.spacingLarge),

              // ── Difficulty selector ──────────────────────────────────────
              DifficultySelectorWidget(
                selectedDifficulty: selectedDifficulty,
                onSelected: (final d) =>
                    ref.read(difficultyProvider.notifier).select(d),
              ),

              const SizedBox(height: AppDimensions.spacingSmall),

              // ── Grid size info card ──────────────────────────────────────
              _DifficultyInfoCard(difficulty: selectedDifficulty),

              const Spacer(),

              // ── Start button ─────────────────────────────────────────────
              ElderlyButton(
                label: 'Start Game',
                onPressed: () => _startGame(context, ref, selectedDifficulty),
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
  ) async {
    // Reset session state from any previous play.
    ref.read(sessionNotifierProvider.notifier).reset();

    final config = await ref.read(sessionNotifierProvider.notifier).startSession(
          gameType: GameType.memoryMatching,
          difficulty: difficulty,
        );

    if (config == null || !context.mounted) return;

    await Navigator.push<void>(
      context,
      MaterialPageRoute<void>(
        builder: (_) => MemoryGameScreen(config: config),
      ),
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.grid_view_rounded,
                  color: AppColors.primary,
                  size: AppDimensions.iconSizePrimary,
                  semanticLabel: 'Memory game icon',
                ),
                const SizedBox(width: AppDimensions.spacingSmall),
                const Text('How to Play', style: AppTextStyles.headlineSmall),
              ],
            ),
            const SizedBox(height: AppDimensions.spacingSmall),
            const Text(
              'Flip cards to find matching pairs. '
              'Remember where each card is to make matches quickly.',
              style: AppTextStyles.bodyLarge,
            ),
          ],
        ),
      ),
    );
  }
}

class _DifficultyInfoCard extends StatelessWidget {
  const _DifficultyInfoCard({required this.difficulty});

  final Difficulty difficulty;

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
          _InfoItem(
            icon: Icons.grid_4x4_rounded,
            label: 'Grid',
            value: '${difficulty.gridColumns}×${difficulty.gridRows}',
          ),
          _InfoItem(
            icon: Icons.style_rounded,
            label: 'Pairs',
            value: '${difficulty.totalPairs}',
          ),
          _InfoItem(
            icon: Icons.timer_outlined,
            label: 'Time',
            value: difficulty.timeLimitSeconds > 0
                ? '${difficulty.timeLimitSeconds}s'
                : '∞',
          ),
        ],
      ),
    );
  }
}

class _InfoItem extends StatelessWidget {
  const _InfoItem({
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
