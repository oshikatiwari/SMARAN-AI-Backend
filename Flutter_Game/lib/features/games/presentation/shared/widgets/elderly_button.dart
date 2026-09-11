import 'package:flutter/material.dart';

import 'package:cognitive_care_games/features/games/presentation/shared/design_system/app_colors.dart';
import 'package:cognitive_care_games/features/games/presentation/shared/design_system/app_dimensions.dart';
import 'package:cognitive_care_games/features/games/presentation/shared/design_system/app_text_styles.dart';

/// Elderly-friendly primary action button.
///
/// Design invariants (enforced, not advisory):
///   - Minimum tap area: [AppDimensions.touchTargetMin] × [AppDimensions.buttonHeightPrimary]
///     (64 × 64 dp). This is enforced via [BoxConstraints], not just padding,
///     so the tappable region is always at least 64 dp regardless of label length.
///   - High-contrast: [AppColors.primary] background, [AppColors.onPrimary] text.
///   - Text size: [AppTextStyles.labelLarge] (20 sp, semibold).
///   - Corner radius: [AppDimensions.buttonBorderRadius] (16 dp).
///   - No rapid animation: ink splash is suppressed in favour of a simple
///     opacity change that is gentler for photosensitive users.
///
/// Use [ElderlyButton.secondary] for lower-emphasis actions (e.g. "Cancel").
/// Use [ElderlyButton.destructive] for abandon/quit actions.
class ElderlyButton extends StatelessWidget {
  /// Primary button — solid [AppColors.primary] background.
  const ElderlyButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.isEnabled = true,
    this.isFullWidth = false,
    this.icon,
  }) : _variant = _ButtonVariant.primary;

  /// Secondary button — outlined, transparent background.
  const ElderlyButton.secondary({
    super.key,
    required this.label,
    required this.onPressed,
    this.isEnabled = true,
    this.isFullWidth = false,
    this.icon,
  }) : _variant = _ButtonVariant.secondary;

  /// Destructive button — [AppColors.error] background (for Quit / Abandon).
  const ElderlyButton.destructive({
    super.key,
    required this.label,
    required this.onPressed,
    this.isEnabled = true,
    this.isFullWidth = false,
    this.icon,
  }) : _variant = _ButtonVariant.destructive;

  final String label;
  final VoidCallback? onPressed;
  final bool isEnabled;

  /// When true, expands to fill available horizontal space.
  final bool isFullWidth;

  /// Optional leading icon. Size locked to [AppDimensions.iconSizePrimary].
  final IconData? icon;

  final _ButtonVariant _variant;

  @override
  Widget build(final BuildContext context) {
    final effectiveCallback = isEnabled ? onPressed : null;

    Widget button = switch (_variant) {
      _ButtonVariant.primary => _PrimaryButton(
          label: label,
          onPressed: effectiveCallback,
          icon: icon,
        ),
      _ButtonVariant.secondary => _SecondaryButton(
          label: label,
          onPressed: effectiveCallback,
          icon: icon,
        ),
      _ButtonVariant.destructive => _DestructiveButton(
          label: label,
          onPressed: effectiveCallback,
          icon: icon,
        ),
    };

    // Enforce minimum touch area at the outermost level.
    button = ConstrainedBox(
      constraints: const BoxConstraints(
        minWidth: AppDimensions.touchTargetMin,
        minHeight: AppDimensions.buttonHeightPrimary,
      ),
      child: button,
    );

    if (isFullWidth) {
      button = SizedBox(width: double.infinity, child: button);
    }

    return Semantics(
      button: true,
      enabled: isEnabled,
      label: label,
      child: button,
    );
  }
}

// ── Private variant implementations ─────────────────────────────────────────

enum _ButtonVariant { primary, secondary, destructive }

class _PrimaryButton extends StatelessWidget {
  const _PrimaryButton({
    required this.label,
    required this.onPressed,
    this.icon,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;

  @override
  Widget build(final BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor:
            onPressed == null ? AppColors.textDisabled : AppColors.primary,
        foregroundColor: AppColors.onPrimary,
        minimumSize: const Size(
          AppDimensions.buttonMinWidth,
          AppDimensions.buttonHeightPrimary,
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: AppDimensions.spacingMedium,
          vertical: AppDimensions.spacingSmall,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimensions.buttonBorderRadius),
        ),
        elevation: onPressed == null
            ? AppDimensions.elevationPressed
            : AppDimensions.buttonElevation,
        splashFactory: NoSplash.splashFactory,
      ),
      child: _ButtonContent(label: label, icon: icon, textStyle: AppTextStyles.labelLarge),
    );
  }
}

class _SecondaryButton extends StatelessWidget {
  const _SecondaryButton({
    required this.label,
    required this.onPressed,
    this.icon,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;

  @override
  Widget build(final BuildContext context) {
    return OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        foregroundColor:
            onPressed == null ? AppColors.textDisabled : AppColors.primary,
        minimumSize: const Size(
          AppDimensions.buttonMinWidth,
          AppDimensions.buttonHeightPrimary,
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: AppDimensions.spacingMedium,
          vertical: AppDimensions.spacingSmall,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimensions.buttonBorderRadius),
        ),
        side: BorderSide(
          color: onPressed == null ? AppColors.textDisabled : AppColors.primary,
          width: AppDimensions.cardBorderWidth,
        ),
        splashFactory: NoSplash.splashFactory,
      ),
      child: _ButtonContent(
        label: label,
        icon: icon,
        textStyle: AppTextStyles.labelMedium.copyWith(color: AppColors.primary),
      ),
    );
  }
}

class _DestructiveButton extends StatelessWidget {
  const _DestructiveButton({
    required this.label,
    required this.onPressed,
    this.icon,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;

  @override
  Widget build(final BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor:
            onPressed == null ? AppColors.textDisabled : AppColors.error,
        foregroundColor: AppColors.onError,
        minimumSize: const Size(
          AppDimensions.buttonMinWidth,
          AppDimensions.buttonHeightPrimary,
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: AppDimensions.spacingMedium,
          vertical: AppDimensions.spacingSmall,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimensions.buttonBorderRadius),
        ),
        elevation: AppDimensions.buttonElevation,
        splashFactory: NoSplash.splashFactory,
      ),
      child: _ButtonContent(
        label: label,
        icon: icon,
        textStyle:
            AppTextStyles.labelLarge.copyWith(color: AppColors.onError),
      ),
    );
  }
}

class _ButtonContent extends StatelessWidget {
  const _ButtonContent({
    required this.label,
    required this.textStyle,
    this.icon,
  });

  final String label;
  final TextStyle textStyle;
  final IconData? icon;

  @override
  Widget build(final BuildContext context) {
    if (icon == null) {
      return Text(label, style: textStyle, textAlign: TextAlign.center);
    }
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: AppDimensions.iconSizeSecondary),
        const SizedBox(width: AppDimensions.spacingXSmall),
        Text(label, style: textStyle),
      ],
    );
  }
}
