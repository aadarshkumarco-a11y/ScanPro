/// Text style definitions for ScanPro.
///
/// Provides semantic text style getters that adapt to the active
/// theme's TextTheme, ensuring consistent typography throughout
/// the application.
library;

import 'package:flutter/material.dart';

/// Application text styles built on top of Material 3 TextTheme.
///
/// Usage:
/// ```dart
/// Text('Hello', style: AppTextStyles.headline(context));
/// ```
class AppTextStyles {
  AppTextStyles._();

  // ── Headlines ─────────────────────────────────────────────────

  /// Large headline (e.g., onboarding title).
  static TextStyle headlineLarge(BuildContext context) {
    return Theme.of(context).textTheme.headlineLarge!.copyWith(
          fontWeight: FontWeight.bold,
          letterSpacing: -0.5,
        );
  }

  /// Medium headline (e.g., screen title).
  static TextStyle headlineMedium(BuildContext context) {
    return Theme.of(context).textTheme.headlineMedium!.copyWith(
          fontWeight: FontWeight.w700,
          letterSpacing: -0.25,
        );
  }

  /// Small headline (e.g., section header).
  static TextStyle headlineSmall(BuildContext context) {
    return Theme.of(context).textTheme.headlineSmall!.copyWith(
          fontWeight: FontWeight.w600,
        );
  }

  // ── Titles ────────────────────────────────────────────────────

  /// Large title (e.g., card title).
  static TextStyle titleLarge(BuildContext context) {
    return Theme.of(context).textTheme.titleLarge!.copyWith(
          fontWeight: FontWeight.w600,
        );
  }

  /// Medium title (e.g., list item title).
  static TextStyle titleMedium(BuildContext context) {
    return Theme.of(context).textTheme.titleMedium!.copyWith(
          fontWeight: FontWeight.w500,
        );
  }

  /// Small title (e.g., tab label).
  static TextStyle titleSmall(BuildContext context) {
    return Theme.of(context).textTheme.titleSmall!.copyWith(
          fontWeight: FontWeight.w500,
          letterSpacing: 0.1,
        );
  }

  // ── Body ──────────────────────────────────────────────────────

  /// Large body text (e.g., primary content).
  static TextStyle bodyLarge(BuildContext context) {
    return Theme.of(context).textTheme.bodyLarge!.copyWith(
          fontWeight: FontWeight.w400,
          height: 1.5,
        );
  }

  /// Medium body text (e.g., standard content).
  static TextStyle bodyMedium(BuildContext context) {
    return Theme.of(context).textTheme.bodyMedium!.copyWith(
          fontWeight: FontWeight.w400,
          height: 1.5,
        );
  }

  /// Small body text (e.g., helper text).
  static TextStyle bodySmall(BuildContext context) {
    return Theme.of(context).textTheme.bodySmall!.copyWith(
          fontWeight: FontWeight.w400,
          height: 1.4,
        );
  }

  // ── Labels ────────────────────────────────────────────────────

  /// Large label (e.g., button text).
  static TextStyle labelLarge(BuildContext context) {
    return Theme.of(context).textTheme.labelLarge!.copyWith(
          fontWeight: FontWeight.w600,
          letterSpacing: 0.5,
        );
  }

  /// Medium label (e.g., chip text).
  static TextStyle labelMedium(BuildContext context) {
    return Theme.of(context).textTheme.labelMedium!.copyWith(
          fontWeight: FontWeight.w500,
          letterSpacing: 0.5,
        );
  }

  /// Small label (e.g., caption, overline).
  static TextStyle labelSmall(BuildContext context) {
    return Theme.of(context).textTheme.labelSmall!.copyWith(
          fontWeight: FontWeight.w500,
          letterSpacing: 0.5,
        );
  }

  // ── Special Styles ────────────────────────────────────────────

  /// Monospace style for OCR text display.
  static TextStyle monospace(BuildContext context) {
    return Theme.of(context).textTheme.bodyMedium!.copyWith(
          fontFamily: 'RobotoMono',
          fontWeight: FontWeight.w400,
          height: 1.6,
          letterSpacing: 0.0,
        );
  }

  /// Caption style for metadata (date, file size).
  static TextStyle caption(BuildContext context) {
    return Theme.of(context).textTheme.bodySmall!.copyWith(
          fontWeight: FontWeight.w400,
          color: Theme.of(context).colorScheme.onSurfaceVariant,
          letterSpacing: 0.15,
        );
  }

  /// Style for prominent numbers (statistics, counters).
  static TextStyle statistic(BuildContext context) {
    return Theme.of(context).textTheme.headlineMedium!.copyWith(
          fontWeight: FontWeight.w800,
          fontFeatures: [const FontFeature.tabularFigures()],
        );
  }
}
