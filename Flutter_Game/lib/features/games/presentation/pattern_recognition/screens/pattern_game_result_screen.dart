import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:cognitive_care_games/features/games/presentation/providers/session_state_notifier.dart';
import 'package:cognitive_care_games/features/games/presentation/shared/design_system/app_colors.dart';
import 'package:cognitive_care_games/features/games/presentation/shared/design_system/app_text_styles.dart';
import 'package:cognitive_care_games/features/games/presentation/shared/widgets/game_result_metrics_widget.dart';

/// Post-game result screen for Pattern Recognition.
///
/// Structurally identical to [MemoryGameResultScreen] — consumes the same
/// [GameResultMetricsWidget] with the same [GameResult] schema.
/// Both games produce identical result structures.
class PatternGameResultScreen extends ConsumerWidget {
  const PatternGameResultScreen({super.key});

  @override
  Widget build(final BuildContext context, final WidgetRef ref) {
    final sessionState = ref.watch(sessionNotifierProvider);

    if (sessionState.isLoading) {
      return const Scaffold(
        backgroundColor: AppColors.background,
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (sessionState.hasError) {
      return Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.onPrimary,
          title: const Text('Pattern Recognition',
              style: AppTextStyles.headlineMedium),
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.error_outline, color: AppColors.error, size: 48),
                const SizedBox(height: 16),
                Text(
                  sessionState.errorMessage ?? 'An error occurred.',
                  style: AppTextStyles.bodyLarge,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () => Navigator.of(context)
                      .popUntil((final r) => r.isFirst),
                  child: const Text('Back to Menu'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final session = sessionState.session;
    final result = sessionState.result;

    if (session == null || result == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.of(context).popUntil((final r) => r.isFirst);
      });
      return const SizedBox.shrink();
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.onPrimary,
        automaticallyImplyLeading: false,
        title: const Text('Your Results', style: AppTextStyles.headlineMedium),
      ),
      body: SafeArea(
        child: GameResultMetricsWidget(
          session: session,
          result: result,
          onPlayAgain: () => Navigator.of(context).popUntil(
            (final r) =>
                r.settings.name == '/games/pattern-recognition/menu' ||
                r.isFirst,
          ),
          onBackToMenu: () =>
              Navigator.of(context).popUntil((final r) => r.isFirst),
        ),
      ),
    );
  }
}
