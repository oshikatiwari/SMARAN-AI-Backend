import 'package:flutter/material.dart';

import 'app_colors.dart';

/// Elderly-friendly typography scale.
///
/// Design constraints enforced here:
/// - Minimum body font size: 18 sp (WCAG 2.1 large-text threshold is 18pt/24px;
///   18 sp on a 160 dpi device ≈ 18pt — meets the threshold).
/// - Minimum touch-area label size: 18 sp.
/// - Font weight for interactive labels: w600 or higher for legibility.
/// - Line height: 1.4× for body text to aid reading with mild visual impairment.
/// - No italic styles — italics reduce readability for cognitively impaired users.
///
/// Usage rule: Import [AppTextStyles] from design_system; never hard-code
/// TextStyle parameters in widget files.
abstract final class AppTextStyles {
  // --------------------------------------------------------------------------
  // Display / Headlines — used on result screens, game titles
  // --------------------------------------------------------------------------

  /// Screen title. 32 sp, bold.
  static const TextStyle displayLarge = TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
    height: 1.2,
    letterSpacing: 0.0,
  );

  /// Section heading. 26 sp, semibold.
  static const TextStyle headlineMedium = TextStyle(
    fontSize: 26,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
    height: 1.3,
    letterSpacing: 0.0,
  );

  /// Sub-heading / card label. 22 sp, semibold.
  static const TextStyle headlineSmall = TextStyle(
    fontSize: 22,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
    height: 1.3,
  );

  // --------------------------------------------------------------------------
  // Body — used for instructions, feedback messages
  // --------------------------------------------------------------------------

  /// Primary body text. 20 sp — above the 18 sp minimum for elderly users.
  static const TextStyle bodyLarge = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w400,
    color: AppColors.textPrimary,
    height: 1.4,
  );

  /// Secondary body text. 18 sp — minimum allowed body size.
  static const TextStyle bodyMedium = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w400,
    color: AppColors.textSecondary,
    height: 1.4,
  );

  // --------------------------------------------------------------------------
  // Labels — used on buttons, tiles, HUD counters
  // --------------------------------------------------------------------------

  /// Primary button label. 20 sp, semibold.
  static const TextStyle labelLarge = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    color: AppColors.onPrimary,
    height: 1.2,
    letterSpacing: 0.5,
  );

  /// Secondary button / chip label. 18 sp, semibold.
  static const TextStyle labelMedium = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
    height: 1.2,
    letterSpacing: 0.3,
  );

  // --------------------------------------------------------------------------
  // HUD — metrics overlay (timer, attempts, errors)
  // --------------------------------------------------------------------------

  /// HUD counter value. 22 sp, bold, white — readable on dark HUD bar.
  static const TextStyle hudValue = TextStyle(
    fontSize: 22,
    fontWeight: FontWeight.w700,
    color: AppColors.hudText,
    height: 1.0,
  );

  /// HUD label beneath counter. 14 sp, regular, white.
  static const TextStyle hudLabel = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: AppColors.hudText,
    height: 1.0,
  );

  // --------------------------------------------------------------------------
  // Card / Tile Content
  // --------------------------------------------------------------------------

  /// Large card symbol / number. 36 sp, bold.
  static const TextStyle cardSymbol = TextStyle(
    fontSize: 36,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
    height: 1.0,
  );

  /// Pattern tile value. 28 sp, bold.
  static const TextStyle tileValue = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
    height: 1.0,
  );

  /// Pattern tile value when selected (on dark background).
  static const TextStyle tileValueSelected = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.w700,
    color: AppColors.tileSelectedText,
    height: 1.0,
  );

  // --------------------------------------------------------------------------
  // Result Screen
  // --------------------------------------------------------------------------

  /// Metric value on result screen. 30 sp, bold.
  static const TextStyle metricValue = TextStyle(
    fontSize: 30,
    fontWeight: FontWeight.w700,
    color: AppColors.primary,
    height: 1.1,
  );

  /// Metric label on result screen. 16 sp, regular.
  static const TextStyle metricLabel = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    color: AppColors.textSecondary,
    height: 1.2,
  );
}
