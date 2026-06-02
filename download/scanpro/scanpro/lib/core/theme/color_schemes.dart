/// Material 3 ColorScheme definitions for ScanPro.
///
/// Defines both light and dark color schemes with a premium
/// indigo/purple primary (#4d2dab) for a professional look.
library;

import 'package:flutter/material.dart';

/// Light color scheme with premium indigo primary.
const lightColorScheme = ColorScheme(
  brightness: Brightness.light,
  primary: Color(0xFF4D2DAB),
  onPrimary: Color(0xFFFFFFFF),
  primaryContainer: Color(0xFFE8DDFF),
  onPrimaryContainer: Color(0xFF1E0061),
  secondary: Color(0xFF5F5C71),
  onSecondary: Color(0xFFFFFFFF),
  secondaryContainer: Color(0xFFE5DFF9),
  onSecondaryContainer: Color(0xFF1C192B),
  tertiary: Color(0xFF7B5266),
  onTertiary: Color(0xFFFFFFFF),
  tertiaryContainer: Color(0xFFFFD8E8),
  onTertiaryContainer: Color(0xFF2E1121),
  error: Color(0xFFBA1A1A),
  onError: Color(0xFFFFFFFF),
  errorContainer: Color(0xFFFFDAD6),
  onErrorContainer: Color(0xFF410002),
  surface: Color(0xFFFFFBFF),
  onSurface: Color(0xFF1C1B1F),
  surfaceContainerLowest: Color(0xFFFFFFFF),
  surfaceContainerLow: Color(0xFFF5F0F8),
  surfaceContainer: Color(0xFFEFEAF2),
  surfaceContainerHigh: Color(0xFFEAE4EC),
  surfaceContainerHighest: Color(0xFFE4DFE7),
  onSurfaceVariant: Color(0xFF47464F),
  outline: Color(0xFF787680),
  outlineVariant: Color(0xFFC8C5D0),
  shadow: Color(0xFF000000),
  scrim: Color(0xFF000000),
  inverseSurface: Color(0xFF313034),
  onInverseSurface: Color(0xFFF3EFF4),
  inversePrimary: Color(0xFFD0BCFF),
  surfaceTint: Color(0xFF4D2DAB),
);

/// Dark color scheme with premium indigo primary.
const darkColorScheme = ColorScheme(
  brightness: Brightness.dark,
  primary: Color(0xFFD0BCFF),
  onPrimary: Color(0xFF34198A),
  primaryContainer: Color(0xFF4D2DAB),
  onPrimaryContainer: Color(0xFFE8DDFF),
  secondary: Color(0xFFC9C3DC),
  onSecondary: Color(0xFF312E41),
  secondaryContainer: Color(0xFF484458),
  onSecondaryContainer: Color(0xFFE5DFF9),
  tertiary: Color(0xFFEFB8CE),
  onTertiary: Color(0xFF482536),
  tertiaryContainer: Color(0xFF613B4D),
  onTertiaryContainer: Color(0xFFFFD8E8),
  error: Color(0xFFFFB4AB),
  onError: Color(0xFF690005),
  errorContainer: Color(0xFF93000A),
  onErrorContainer: Color(0xFFFFDAD6),
  surface: Color(0xFF141218),
  onSurface: Color(0xFFE6E0E9),
  surfaceContainerLowest: Color(0xFF0F0D13),
  surfaceContainerLow: Color(0xFF1D1B20),
  surfaceContainer: Color(0xFF211F26),
  surfaceContainerHigh: Color(0xFF2B2930),
  surfaceContainerHighest: Color(0xFF36343B),
  onSurfaceVariant: Color(0xFFC8C5D0),
  outline: Color(0xFF928F99),
  outlineVariant: Color(0xFF47464F),
  shadow: Color(0xFF000000),
  scrim: Color(0xFF000000),
  inverseSurface: Color(0xFFE6E0E9),
  onInverseSurface: Color(0xFF313034),
  inversePrimary: Color(0xFF4D2DAB),
  surfaceTint: Color(0xFFD0BCFF),
);

/// Semantic color tokens derived from the active color scheme.
///
/// These provide named access to commonly used colors for
/// consistent usage across the application.
class AppColors {
  AppColors._();

  /// Scanner accent color (used for scan overlays and crop handles).
  static const Color scannerAccent = Color(0xFF4D2DAB);

  /// Success color for confirmations.
  static const Color success = Color(0xFF2E7D32);

  /// Warning color for caution indicators.
  static const Color warning = Color(0xFFF57C00);

  /// Info color for informational banners.
  static const Color info = Color(0xFF1565C0);

  /// Overlay color for scanner crop area.
  static const Color scannerOverlay = Color(0x99000000);

  /// Crop handle color.
  static const Color cropHandle = Color(0xFF4D2DAB);

  /// Document thumbnail placeholder background.
  static const Color thumbnailPlaceholder = Color(0xFFE8DDFF);
}
