/// Spacing, padding, and sizing constants for ScanPro UI.
///
/// Centralizes all dimension values for consistent layout across
/// screens and components. Follows an 8dp grid system.
library;

class Dimensions {
  Dimensions._();

  // ── Spacing (8dp grid) ────────────────────────────────────────
  static const double spacing2 = 2.0;
  static const double spacing4 = 4.0;
  static const double spacing6 = 6.0;
  static const double spacing8 = 8.0;
  static const double spacing10 = 10.0;
  static const double spacing12 = 12.0;
  static const double spacing16 = 16.0;
  static const double spacing20 = 20.0;
  static const double spacing24 = 24.0;
  static const double spacing32 = 32.0;
  static const double spacing40 = 40.0;
  static const double spacing48 = 48.0;
  static const double spacing56 = 56.0;
  static const double spacing64 = 64.0;

  // ── Padding ───────────────────────────────────────────────────
  static const double paddingSmall = 8.0;
  static const double paddingMedium = 16.0;
  static const double paddingLarge = 24.0;
  static const double paddingExtraLarge = 32.0;
  static const double paddingScreen = 16.0;
  static const double paddingCard = 16.0;
  static const double paddingDialog = 24.0;
  static const double paddingListItem = 12.0;

  // ── Border Radius ─────────────────────────────────────────────
  static const double radiusSmall = 4.0;
  static const double radiusMedium = 8.0;
  static const double radiusLarge = 12.0;
  static const double radiusExtraLarge = 16.0;
  static const double radiusXxLarge = 24.0;
  static const double radiusCircular = 100.0;

  // ── Icon Sizes ────────────────────────────────────────────────
  static const double iconSmall = 16.0;
  static const double iconMedium = 24.0;
  static const double iconLarge = 32.0;
  static const double iconExtraLarge = 48.0;

  // ── Button Dimensions ─────────────────────────────────────────
  static const double buttonHeight = 48.0;
  static const double buttonHeightSmall = 36.0;
  static const double buttonHeightLarge = 56.0;
  static const double buttonIconSize = 20.0;
  static const double buttonCornerRadius = 12.0;
  static const double fabSize = 56.0;
  static const double fabSmallSize = 40.0;

  // ── Card Dimensions ───────────────────────────────────────────
  static const double cardElevation = 1.0;
  static const double cardElevationHover = 4.0;
  static const double cardCornerRadius = 12.0;
  static const double cardPadding = 16.0;
  static const double documentCardHeight = 180.0;
  static const double documentCardWidth = 140.0;

  // ── App Bar ───────────────────────────────────────────────────
  static const double appBarHeight = 56.0;
  static const double appBarElevation = 0.0;

  // ── Bottom Navigation ─────────────────────────────────────────
  static const double bottomNavHeight = 64.0;

  // ── Divider ──────────────────────────────────────────────────
  static const double dividerThickness = 1.0;
  static const double dividerIndent = 16.0;

  // ── Thumbnail ─────────────────────────────────────────────────
  static const double thumbnailSize = 56.0;
  static const double thumbnailBorderRadius = 8.0;

  // ── Chip ──────────────────────────────────────────────────────
  static const double chipHeight = 32.0;
  static const double chipBorderRadius = 16.0;

  // ── Input ─────────────────────────────────────────────────────
  static const double inputHeight = 56.0;
  static const double inputBorderRadius = 12.0;
  static const double inputIconSize = 24.0;

  // ── Avatar ────────────────────────────────────────────────────
  static const double avatarSmall = 32.0;
  static const double avatarMedium = 48.0;
  static const double avatarLarge = 72.0;
  static const double avatarBorderRadius = 100.0;

  // ── Animation ─────────────────────────────────────────────────
  static const Duration animationDuration = Duration(milliseconds: 300);
  static const Duration animationDurationFast = Duration(milliseconds: 150);
  static const Duration animationDurationSlow = Duration(milliseconds: 500);
}
