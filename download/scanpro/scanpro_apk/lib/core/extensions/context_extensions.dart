import 'package:flutter/material.dart';

/// Convenient [BuildContext] extensions for quick access to frequently
/// used theme, media-query, and colour values.
///
/// Usage:
/// ```dart
/// final colors = context.colorScheme;
/// final width = context.width;
/// final isDark = context.isDarkMode;
/// ```
extension BuildContextExtensions on BuildContext {
  // ── Theme ───────────────────────────────────────────────────────

  /// The current [ThemeData].
  ThemeData get theme => Theme.of(this);

  /// The current [ColorScheme].
  ColorScheme get colorScheme => Theme.of(this).colorScheme;

  /// The current [TextTheme].
  TextTheme get textTheme => Theme.of(this).textTheme;

  /// Whether the current theme brightness is dark.
  bool get isDarkMode => Theme.of(this).brightness == Brightness.dark;

  /// Whether the current theme brightness is light.
  bool get isLightMode => !isDarkMode;

  // ── Media Query ─────────────────────────────────────────────────

  /// The current [MediaQueryData].
  MediaQueryData get mediaQuery => MediaQuery.of(this);

  /// Screen width in logical pixels.
  double get width => mediaQuery.size.width;

  /// Screen height in logical pixels.
  double get height => mediaQuery.size.height;

  /// The current [Size] of the screen.
  Size get screenSize => mediaQuery.size;

  /// The shortest side of the screen (useful for responsive breakpoints).
  double get shortestSide => mediaQuery.size.shortestSide;

  /// The longest side of the screen.
  double get longestSide => mediaQuery.size.longestSide;

  /// The current device pixel ratio.
  double get devicePixelRatio => mediaQuery.devicePixelRatio;

  /// The current text scale factor set by the user.
  double get textScaleFactor => mediaQuery.textScaleFactor;

  /// The top padding (status bar / notch).
  double get paddingTop => mediaQuery.padding.top;

  /// The bottom padding (system navigation bar / safe area).
  double get paddingBottom => mediaQuery.padding.bottom;

  /// The view insets (e.g., keyboard height).
  double get viewInsetBottom => mediaQuery.viewInsets.bottom;

  /// Whether the keyboard is currently visible.
  bool get isKeyboardVisible => mediaQuery.viewInsets.bottom > 0;

  /// The status bar height.
  double get statusBarHeight => mediaQuery.padding.top;

  /// The navigation bar height.
  double get navigationBarHeight => mediaQuery.padding.bottom;

  // ── Responsive Breakpoints ──────────────────────────────────────

  /// Whether the screen is a small phone (width < 360).
  bool get isSmallPhone => width < 360;

  /// Whether the screen is a regular phone (360 ≤ width < 600).
  bool get isPhone => width >= 360 && width < 600;

  /// Whether the screen is a small tablet (600 ≤ width < 840).
  bool get isSmallTablet => width >= 600 && width < 840;

  /// Whether the screen is a large tablet (width ≥ 840).
  bool get isLargeTablet => width >= 840;

  /// Whether the screen is in landscape orientation.
  bool get isLandscape => width > height;

  /// Whether the screen is in portrait orientation.
  bool get isPortrait => height >= width;

  // ── Colour Shortcuts ────────────────────────────────────────────

  /// Primary colour from the current colour scheme.
  Color get primary => colorScheme.primary;

  /// On-primary colour (text/icons on primary background).
  Color get onPrimary => colorScheme.onPrimary;

  /// Secondary colour from the current colour scheme.
  Color get secondary => colorScheme.secondary;

  /// On-secondary colour.
  Color get onSecondary => colorScheme.onSecondary;

  /// Error colour from the current colour scheme.
  Color get error => colorScheme.error;

  /// On-error colour.
  Color get onError => colorScheme.onError;

  /// Surface colour.
  Color get surface => colorScheme.surface;

  /// On-surface colour.
  Color get onSurface => colorScheme.onSurface;

  /// Background colour (same as surface in M3).
  Color get background => colorScheme.surface;

  /// On-background colour.
  Color get onBackground => colorScheme.onSurface;

  // ── Semantic Colours ────────────────────────────────────────────

  /// Brand primary colour – always Indigo regardless of theme.
  Color get brandPrimary => const Color(0xFF4D2DAB);

  /// Brand secondary colour – always Teal regardless of theme.
  Color get brandSecondary => const Color(0xFF00BFA6);

  /// Brand accent / destructive colour.
  Color get brandAccent => const Color(0xFFFF6B6B);

  /// Warning colour.
  Color get warningColor => const Color(0xFFFFA726);

  /// Success colour.
  Color get successColor => const Color(0xFF4CAF50);

  /// Info colour.
  Color get infoColor => const Color(0xFF42A5F5);

  // ── Dividers & Borders ──────────────────────────────────────────

  /// A subtle border / divider colour appropriate for the current theme.
  Color get dividerColor => isDarkMode
      ? const Color(0xFF3C3850)
      : const Color(0xFFE0E0E0);

  /// A disabled / hint colour for the current theme.
  Color get hintColor => isDarkMode
      ? const Color(0xFF6C6880)
      : const Color(0xFF9E9E9E);

  /// A card background colour for the current theme.
  Color get cardColor => isDarkMode
      ? const Color(0xFF252340)
      : Colors.white;

  /// An input field fill colour for the current theme.
  Color get inputFillColor => isDarkMode
      ? const Color(0xFF2B2740)
      : const Color(0xFFF5F3FF);

  // ── Navigation ──────────────────────────────────────────────────

  /// Pops the top route off the navigation stack, if possible.
  void pop<T extends Object?>([T? result]) => Navigator.of(this).pop(result);

  /// Whether the current route can be popped.
  bool get canPop => Navigator.of(this).canPop();

  // ── Overlay / Focus ─────────────────────────────────────────────

  /// Dismisses the on-screen keyboard.
  void hideKeyboard() => FocusScope.of(this).unfocus();

  // ── SnackBar ────────────────────────────────────────────────────

  /// Shows a [SnackBar] with the given [message].
  void showSnackBar(
    String message, {
    Duration duration = const Duration(seconds: 3),
    SnackBarAction? action,
  }) {
    ScaffoldMessenger.of(this).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: duration,
        action: action,
      ),
    );
  }

  /// Shows an error [SnackBar] styled in red.
  void showErrorSnackBar(
    String message, {
    Duration duration = const Duration(seconds: 4),
  }) {
    ScaffoldMessenger.of(this).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: duration,
        backgroundColor: error,
      ),
    );
  }

  /// Shows a success [SnackBar] styled in green.
  void showSuccessSnackBar(
    String message, {
    Duration duration = const Duration(seconds: 3),
  }) {
    ScaffoldMessenger.of(this).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: duration,
        backgroundColor: successColor,
      ),
    );
  }
}
