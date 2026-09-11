/// Spatial constants for the elderly-friendly design system.
///
/// Elderly-friendly touch target rules enforced here:
/// - Minimum interactive element: 64 × 64 dp
///   (exceeds Apple HIG 44pt and Google Material 48dp minimum — chosen because
///   motor impairment studies recommend 60–80 dp for dementia/elderly users).
/// - Minimum button height: 64 dp.
/// - Card minimum dimension: 72 dp per side (accommodates fingertip ≈ 9–10mm).
/// - Minimum spacing between interactive targets: 12 dp (prevents mis-taps).
///
/// Usage rule: Import [AppDimensions] from design_system; never hard-code
/// numeric sizes in widget or Flame component files.
abstract final class AppDimensions {
  // --------------------------------------------------------------------------
  // Touch Targets
  // --------------------------------------------------------------------------

  /// Absolute minimum touch target side length — 64 dp.
  static const double touchTargetMin = 64.0;

  /// Preferred touch target for primary game elements — 72 dp.
  static const double touchTargetPreferred = 72.0;

  /// Minimum gap between adjacent interactive elements — 12 dp.
  static const double touchTargetGap = 12.0;

  // --------------------------------------------------------------------------
  // Button Dimensions
  // --------------------------------------------------------------------------

  /// Primary button height — 64 dp (equals touch target minimum).
  static const double buttonHeightPrimary = 64.0;

  /// Secondary / difficulty-selector button height — 56 dp.
  static const double buttonHeightSecondary = 56.0;

  /// Minimum button width — 120 dp.
  static const double buttonMinWidth = 120.0;

  /// Button corner radius — rounded to reduce sharp edges.
  static const double buttonBorderRadius = 16.0;

  // --------------------------------------------------------------------------
  // Cards (Memory Matching)
  // --------------------------------------------------------------------------

  /// Card width per difficulty:
  /// Easy  → 3×4 grid on typical phone (~360dp wide) → ~88 dp per card
  /// Medium → 4×4 grid → ~80 dp per card
  /// Hard  → 4×5 grid → ~80 dp per card
  /// These are floor values; actual sizes are computed at runtime from
  /// available game canvas width divided by column count.

  /// Absolute minimum card width — never go below this.
  static const double cardMinWidth = 72.0;

  /// Absolute minimum card height — never go below this.
  static const double cardMinHeight = 72.0;

  /// Card corner radius.
  static const double cardBorderRadius = 12.0;

  /// Gap between adjacent cards in the grid.
  static const double cardGap = 8.0;

  /// Card border width (face-up state).
  static const double cardBorderWidth = 2.0;

  // --------------------------------------------------------------------------
  // Sequence Tiles (Pattern Recognition)
  // --------------------------------------------------------------------------

  /// Minimum tile size for display sequence tiles (non-interactive).
  static const double tileMinSize = 64.0;

  /// Minimum tile size for answer row tiles (interactive).
  static const double answerTileMinSize = 72.0;

  /// Gap between tiles in sequence display.
  static const double tileGap = 10.0;

  /// Tile corner radius.
  static const double tileBorderRadius = 12.0;

  // --------------------------------------------------------------------------
  // HUD (Heads-Up Display) Bar
  // --------------------------------------------------------------------------

  /// HUD bar height at top of game screen.
  static const double hudHeight = 72.0;

  /// Horizontal padding inside HUD.
  static const double hudPaddingH = 16.0;

  /// Vertical padding inside HUD.
  static const double hudPaddingV = 8.0;

  // --------------------------------------------------------------------------
  // Screen Padding / Margins
  // --------------------------------------------------------------------------

  /// Outer horizontal padding on all game screens.
  static const double screenPaddingH = 20.0;

  /// Outer vertical padding on all game screens.
  static const double screenPaddingV = 24.0;

  /// Standard spacing unit between sections on a screen.
  static const double spacingLarge = 32.0;
  static const double spacingMedium = 20.0;
  static const double spacingSmall = 12.0;
  static const double spacingXSmall = 8.0;

  // --------------------------------------------------------------------------
  // Icon Sizes
  // --------------------------------------------------------------------------

  /// Minimum icon size in game UI — large enough for elderly users.
  static const double iconSizePrimary = 32.0;

  /// Secondary icon (inside labels etc.).
  static const double iconSizeSecondary = 24.0;

  // --------------------------------------------------------------------------
  // Elevation / Shadow
  // --------------------------------------------------------------------------

  /// Card resting elevation (subtle depth cue).
  static const double cardElevation = 4.0;

  /// Button resting elevation.
  static const double buttonElevation = 2.0;

  /// Pressed / tapped elevation.
  static const double elevationPressed = 0.0;
}
