/// BuildContext extension methods for common Flutter lookups.
///
/// Provides convenient shortcuts for accessing [MediaQuery], [Theme],
/// [Navigator], and other inherited widgets without verbose boilerplate.
library;

import 'package:flutter/material.dart';

extension ContextExtensions on BuildContext {
  // ── MediaQuery ────────────────────────────────────────────────

  /// The current [MediaQueryData].
  MediaQueryData get mediaQuery => MediaQuery.of(this);

  /// Screen width in logical pixels.
  double get screenWidth => mediaQuery.size.width;

  /// Screen height in logical pixels.
  double get screenHeight => mediaQuery.size.height;

  /// Current [Size] of the screen.
  Size get screenSize => mediaQuery.size;

  /// Top padding (status bar, notch).
  double get paddingTop => mediaQuery.padding.top;

  /// Bottom padding (home indicator, system navigation).
  double get paddingBottom => mediaQuery.padding.bottom;

  /// Device pixel ratio.
  double get devicePixelRatio => mediaQuery.devicePixelRatio;

  /// Whether the device is in landscape orientation.
  bool get isLandscape => mediaQuery.orientation == Orientation.landscape;

  /// Whether the device is in portrait orientation.
  bool get isPortrait => mediaQuery.orientation == Orientation.portrait;

  /// Whether the screen width qualifies as a tablet (>= 600dp).
  bool get isTablet => screenWidth >= 600;

  /// Whether the screen width qualifies as a small phone (< 360dp).
  bool get isSmallPhone => screenWidth < 360;

  // ── Theme ─────────────────────────────────────────────────────

  /// The current [ThemeData].
  ThemeData get theme => Theme.of(this);

  /// The current [ColorScheme].
  ColorScheme get colorScheme => Theme.of(this).colorScheme;

  /// The current [TextTheme].
  TextTheme get textTheme => Theme.of(this).textTheme;

  /// Whether the current theme brightness is dark.
  bool get isDarkMode => Theme.of(this).brightness == Brightness.dark;

  // ── Navigation ────────────────────────────────────────────────

  /// Pops the top route off the navigator stack.
  void pop<T extends Object?>([T? result]) => Navigator.of(this).pop(result);

  /// Whether the navigator can pop the current route.
  bool get canPop => Navigator.of(this).canPop();

  // ── Scaffold ──────────────────────────────────────────────────

  /// Shows a [SnackBar] in the current [ScaffoldMessenger].
  ScaffoldFeatureController<SnackBar, SnackBarClosedReason> showSnackBar(
    String message, {
    Duration duration = const Duration(seconds: 4),
    SnackBarAction? action,
  }) {
    return ScaffoldMessenger.of(this).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: duration,
        action: action,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  /// Shows an error [SnackBar] with red background.
  ScaffoldFeatureController<SnackBar, SnackBarClosedReason> showErrorSnackBar(
    String message, {
    Duration duration = const Duration(seconds: 4),
  }) {
    return ScaffoldMessenger.of(this).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: duration,
        backgroundColor: colorScheme.error,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  /// Shows a success [SnackBar] with green background.
  ScaffoldFeatureController<SnackBar, SnackBarClosedReason> showSuccessSnackBar(
    String message, {
    Duration duration = const Duration(seconds: 3),
  }) {
    return ScaffoldMessenger.of(this).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: duration,
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  // ── Focus ─────────────────────────────────────────────────────

  /// Unfocuses any focused input field.
  void unfocus() => FocusScope.of(this).unfocus();
}
