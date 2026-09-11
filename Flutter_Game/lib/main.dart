import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'features/games/presentation/memory_matching/screens/memory_game_menu_screen.dart';
import 'features/games/presentation/pattern_recognition/screens/pattern_game_menu_screen.dart';
import 'features/games/presentation/providers/database_provider.dart';
import 'features/games/presentation/providers/locale_provider.dart';
import 'features/games/presentation/shared/design_system/app_colors.dart';
import 'features/games/presentation/shared/design_system/app_dimensions.dart';
import 'features/games/presentation/shared/design_system/app_text_styles.dart';
import 'l10n/app_localizations.dart';

/// Application entry point.
///
/// [ProviderScope] at root — only one, never nested (except test overrides).
/// [_DatabasePrewarmObserver] eagerly opens the Drift DB so game screens load instantly.
void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    ProviderScope(
      observers: const [_DatabasePrewarmObserver()],
      child: const CognitiveCareApp(),
    ),
  );
}

class CognitiveCareApp extends ConsumerWidget {
  const CognitiveCareApp({super.key});

  @override
  Widget build(final BuildContext context, final WidgetRef ref) {
    final currentLocale = ref.watch(localeProvider);

    return MaterialApp(
      title: 'Cognitive Care Games',
      debugShowCheckedModeBanner: false,
      locale: currentLocale,
      // ── Localisation ──────────────────────────────────────────────────────
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      theme: _buildTheme(),
      home: const GameSelectionScreen(),
      routes: {
        MemoryGameMenuScreen.routeName: (_) => const MemoryGameMenuScreen(),
        PatternGameMenuScreen.routeName: (_) => const PatternGameMenuScreen(),
      },
    );
  }

  ThemeData _buildTheme() {
    return ThemeData(
      useMaterial3: true,
      colorScheme: const ColorScheme(
        brightness: Brightness.light,
        primary: AppColors.primary,
        onPrimary: AppColors.onPrimary,
        secondary: AppColors.secondary,
        onSecondary: AppColors.onSecondary,
        error: AppColors.error,
        onError: AppColors.onError,
        surface: AppColors.surface,
        onSurface: AppColors.textPrimary,
      ),
      scaffoldBackgroundColor: AppColors.background,
      textTheme: const TextTheme(
        displayLarge: AppTextStyles.displayLarge,
        headlineMedium: AppTextStyles.headlineMedium,
        headlineSmall: AppTextStyles.headlineSmall,
        bodyLarge: AppTextStyles.bodyLarge,
        bodyMedium: AppTextStyles.bodyMedium,
        labelLarge: AppTextStyles.labelLarge,
        labelMedium: AppTextStyles.labelMedium,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          minimumSize: const Size(
            AppDimensions.buttonMinWidth,
            AppDimensions.buttonHeightPrimary,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppDimensions.buttonBorderRadius),
          ),
          textStyle: AppTextStyles.labelLarge,
        ),
      ),
      cardTheme: CardThemeData(
        elevation: AppDimensions.cardElevation,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimensions.cardBorderRadius),
        ),
        color: AppColors.surface,
      ),
    );
  }
}

/// Home screen — lets the user choose which game to play.
///
/// This screen is the entry point from the dashboard module.
class GameSelectionScreen extends ConsumerWidget {
  const GameSelectionScreen({super.key});

  @override
  Widget build(final BuildContext context, final WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.onPrimary,
        title: Text(
          l10n.appTitle,
          style: AppTextStyles.headlineMedium,
        ),
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
              // ── Elderly-Friendly Language Selector Bar ───────────────────
              const _ElderlyLanguageSelector(),
              const SizedBox(height: AppDimensions.spacingMedium),

              Text(
                l10n.gameSelectionTitle,
                style: AppTextStyles.displayLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppDimensions.spacingSmall),
              Text(
                l10n.gameSelectionSubtitle,
                style: AppTextStyles.bodyLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppDimensions.spacingLarge),

              // ── Memory Matching card ──────────────────────────────────────
              _GameCard(
                title: l10n.memoryMatchingTitle,
                description: l10n.memoryMatchingDescription,
                icon: Icons.grid_view_rounded,
                onTap: () => Navigator.pushNamed(
                  context,
                  MemoryGameMenuScreen.routeName,
                ),
              ),

              const SizedBox(height: AppDimensions.spacingMedium),

              // ── Pattern Recognition card ──────────────────────────────────
              _GameCard(
                title: l10n.patternRecognitionTitle,
                description: l10n.patternRecognitionDescription,
                icon: Icons.pattern_rounded,
                onTap: () => Navigator.pushNamed(
                  context,
                  PatternGameMenuScreen.routeName,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Simple, elderly-friendly language selector for switching active application locale.
class _ElderlyLanguageSelector extends ConsumerWidget {
  const _ElderlyLanguageSelector();

  static const _supportedLanguages = [
    (locale: Locale('en'), label: 'English'),
    (locale: Locale('hi'), label: 'हिन्दी'),
    (locale: Locale('as'), label: 'অসমীয়া'),
    (locale: Locale('kha'), label: 'খাসী'),
    (locale: Locale('lus'), label: 'Mizo'),
  ];

  @override
  Widget build(final BuildContext context, final WidgetRef ref) {
    final currentLocale = ref.watch(localeProvider);

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: _supportedLanguages.map((lang) {
          final isSelected =
              currentLocale.languageCode == lang.locale.languageCode;
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: ChoiceChip(
              label: Text(
                lang.label,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight:
                      isSelected ? FontWeight.bold : FontWeight.normal,
                  color: isSelected
                      ? AppColors.onPrimary
                      : AppColors.textPrimary,
                ),
              ),
              selected: isSelected,
              selectedColor: AppColors.primary,
              backgroundColor: AppColors.surface,
              showCheckmark: false,
              padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              onSelected: (selected) {
                if (selected) {
                  ref.read(localeProvider.notifier).setLocale(lang.locale);
                }
              },
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _GameCard extends StatelessWidget {
  const _GameCard({
    required this.title,
    required this.description,
    required this.icon,
    required this.onTap,
  });

  final String title;
  final String description;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(final BuildContext context) {
    return Semantics(
      button: true,
      label: title,
      child: Card(
        color: AppColors.surface,
        elevation: AppDimensions.cardElevation,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimensions.cardBorderRadius),
        ),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppDimensions.cardBorderRadius),
          splashFactory: NoSplash.splashFactory,
          child: Padding(
            padding: const EdgeInsets.all(AppDimensions.spacingMedium),
            child: Row(
              children: [
                Container(
                  width: AppDimensions.touchTargetPreferred,
                  height: AppDimensions.touchTargetPreferred,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withAlpha(20),
                    borderRadius: BorderRadius.circular(
                      AppDimensions.buttonBorderRadius,
                    ),
                  ),
                  child: Icon(
                    icon,
                    color: AppColors.primary,
                    size: AppDimensions.iconSizePrimary,
                  ),
                ),
                const SizedBox(width: AppDimensions.spacingMedium),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title, style: AppTextStyles.headlineSmall),
                      const SizedBox(height: 4),
                      Text(description, style: AppTextStyles.bodyMedium),
                    ],
                  ),
                ),
                const Icon(
                  Icons.chevron_right_rounded,
                  color: AppColors.primary,
                  size: AppDimensions.iconSizePrimary,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Pre-warms the database provider so game screens open without delay.
base class _DatabasePrewarmObserver extends ProviderObserver {
  const _DatabasePrewarmObserver();

  @override
  void didAddProvider(
    final ProviderObserverContext context,
    final Object? value,
  ) {
    if (context.provider == databaseProvider) {
      context.container.read(databaseProvider.future).ignore();
    }
  }
}
