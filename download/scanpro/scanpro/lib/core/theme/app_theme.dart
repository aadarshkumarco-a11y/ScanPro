/// Material 3 ThemeData configuration for ScanPro.
///
/// Provides both light and dark themes with consistent styling,
/// and Riverpod providers for theme mode persistence.
library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';

import '../constants/db_constants.dart';
import 'color_schemes.dart';
import 'dimensions.dart';

/// Provider that persists and exposes the current [ThemeMode].
final themeModeProvider = StateNotifierProvider<ThemeModeNotifier, ThemeMode>((ref) {
  return ThemeModeNotifier();
});

/// Notifier that reads/writes theme preference to Hive.
class ThemeModeNotifier extends StateNotifier<ThemeMode> {
  ThemeModeNotifier() : super(ThemeMode.system) {
    _loadFromStorage();
  }

  Future<void> _loadFromStorage() async {
    final box = await Hive.openBox(DbConstants.settingsBox);
    final saved = box.get(DbConstants.themeModeKey) as String?;
    if (saved != null) {
      state = ThemeMode.values.firstWhere(
        (mode) => mode.name == saved,
        orElse: () => ThemeMode.system,
      );
    }
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    state = mode;
    final box = await Hive.openBox(DbConstants.settingsBox);
    await box.put(DbConstants.themeModeKey, mode.name);
  }

  void toggle() {
    final next = switch (state) {
      ThemeMode.light => ThemeMode.dark,
      ThemeMode.dark => ThemeMode.system,
      ThemeMode.system => ThemeMode.light,
    };
    setThemeMode(next);
  }
}

/// Builds the light [ThemeData] for ScanPro.
ThemeData buildLightTheme() {
  return _buildTheme(lightColorScheme);
}

/// Builds the dark [ThemeData] for ScanPro.
ThemeData buildDarkTheme() {
  return _buildTheme(darkColorScheme);
}

ThemeData _buildTheme(ColorScheme colorScheme) {
  final isDark = colorScheme.brightness == Brightness.dark;

  return ThemeData(
    useMaterial3: true,
    colorScheme: colorScheme,
    brightness: colorScheme.brightness,

    // ── Scaffold ──────────────────────────────────────────────
    scaffoldBackgroundColor: colorScheme.surface,

    // ── AppBar ────────────────────────────────────────────────
    appBarTheme: AppBarTheme(
      elevation: Dimensions.appBarElevation,
      centerTitle: false,
      backgroundColor: colorScheme.surface,
      foregroundColor: colorScheme.onSurface,
      surfaceTintColor: Colors.transparent,
      systemOverlayStyle: isDark ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark,
    ),

    // ── Cards ─────────────────────────────────────────────────
    cardTheme: CardTheme(
      elevation: Dimensions.cardElevation,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(Dimensions.cardCornerRadius),
      ),
      color: colorScheme.surfaceContainerLow,
      surfaceTintColor: Colors.transparent,
    ),

    // ── Elevated Button ───────────────────────────────────────
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        minimumSize: const Size.fromHeight(Dimensions.buttonHeight),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(Dimensions.buttonCornerRadius),
        ),
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
        textStyle: const TextStyle(fontWeight: FontWeight.w600, letterSpacing: 0.5),
      ),
    ),

    // ── Outlined Button ───────────────────────────────────────
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        minimumSize: const Size.fromHeight(Dimensions.buttonHeight),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(Dimensions.buttonCornerRadius),
        ),
        side: BorderSide(color: colorScheme.outline),
        textStyle: const TextStyle(fontWeight: FontWeight.w600, letterSpacing: 0.5),
      ),
    ),

    // ── Text Button ───────────────────────────────────────────
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        textStyle: const TextStyle(fontWeight: FontWeight.w600, letterSpacing: 0.5),
      ),
    ),

    // ── Input Decoration ──────────────────────────────────────
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: colorScheme.surfaceContainerHighest.withOpacity(0.5),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(Dimensions.inputBorderRadius),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(Dimensions.inputBorderRadius),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(Dimensions.inputBorderRadius),
        borderSide: BorderSide(color: colorScheme.primary, width: 2.0),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(Dimensions.inputBorderRadius),
        borderSide: BorderSide(color: colorScheme.error, width: 1.5),
      ),
      contentPadding: const EdgeInsets.symmetric(
        horizontal: Dimensions.paddingMedium,
        vertical: Dimensions.paddingSmall + 4,
      ),
    ),

    // ── Bottom Navigation ─────────────────────────────────────
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      type: BottomNavigationBarType.fixed,
      backgroundColor: colorScheme.surface,
      selectedItemColor: colorScheme.primary,
      unselectedItemColor: colorScheme.onSurfaceVariant,
      elevation: 0,
    ),

    // ── Navigation Bar (M3) ───────────────────────────────────
    navigationBarTheme: NavigationBarThemeData(
      elevation: 0,
      backgroundColor: colorScheme.surface,
      indicatorColor: colorScheme.primaryContainer,
      labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
    ),

    // ── Chip ──────────────────────────────────────────────────
    chipTheme: ChipThemeData(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(Dimensions.chipBorderRadius),
      ),
      side: BorderSide(color: colorScheme.outlineVariant),
    ),

    // ── Floating Action Button ────────────────────────────────
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: colorScheme.primary,
      foregroundColor: colorScheme.onPrimary,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(Dimensions.radiusLarge),
      ),
    ),

    // ── Divider ───────────────────────────────────────────────
    dividerTheme: DividerThemeData(
      color: colorScheme.outlineVariant,
      thickness: Dimensions.dividerThickness,
      space: 0,
    ),

    // ── Dialog ────────────────────────────────────────────────
    dialogTheme: DialogTheme(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(Dimensions.radiusExtraLarge),
      ),
      backgroundColor: colorScheme.surfaceContainerHigh,
    ),

    // ── Snack Bar ─────────────────────────────────────────────
    snackBarTheme: SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(Dimensions.radiusMedium),
      ),
    ),

    // ── Switch ────────────────────────────────────────────────
    switchTheme: SwitchThemeData(
      thumbColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) return colorScheme.primary;
        return colorScheme.outline;
      }),
    ),
  );
}
