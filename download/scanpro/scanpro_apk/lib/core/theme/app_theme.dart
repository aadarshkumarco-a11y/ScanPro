import 'package:flutter/material.dart';

/// Complete Material 3 theme configuration for ScanPro.
///
/// Primary color: Indigo `#4D2DAB`.
/// Provides both light and dark theme builders along with
/// reusable colour constants, text styles, and component themes.
class AppTheme {
  AppTheme._();

  // ── Brand Colours ───────────────────────────────────────────────
  static const Color primaryColor = Color(0xFF4D2DAB);
  static const Color primaryLightColor = Color(0xFF7B5FC7);
  static const Color primaryDarkColor = Color(0xFF3A1F8E);
  static const Color secondaryColor = Color(0xFF00BFA6);
  static const Color secondaryLightColor = Color(0xFF5DF2D6);
  static const Color secondaryDarkColor = Color(0xFF008C7A);
  static const Color accentColor = Color(0xFFFF6B6B);
  static const Color surfaceLightColor = Color(0xFFFAFAFE);
  static const Color surfaceDarkColor = Color(0xFF1A1A2E);
  static const Color errorColor = Color(0xFFD32F2F);
  static const Color warningColor = Color(0xFFFFA726);
  static const Color successColor = Color(0xFF4CAF50);
  static const Color infoColor = Color(0xFF42A5F5);

  // ── Light Theme ─────────────────────────────────────────────────
  static ThemeData lightTheme() {
    final ColorScheme colorScheme = ColorScheme.fromSeed(
      seedColor: primaryColor,
      brightness: Brightness.light,
      primary: primaryColor,
      onPrimary: Colors.white,
      secondary: secondaryColor,
      onSecondary: Colors.white,
      error: errorColor,
      onError: Colors.white,
      surface: surfaceLightColor,
      onSurface: const Color(0xFF1C1B1F),
      surfaceContainerHighest: const Color(0xFFE8E0F0),
    );

    return _buildTheme(colorScheme, Brightness.light);
  }

  // ── Dark Theme ──────────────────────────────────────────────────
  static ThemeData darkTheme() {
    final ColorScheme colorScheme = ColorScheme.fromSeed(
      seedColor: primaryColor,
      brightness: Brightness.dark,
      primary: primaryLightColor,
      onPrimary: Colors.white,
      secondary: secondaryLightColor,
      onSecondary: const Color(0xFF003329),
      error: const Color(0xFFEF9A9A),
      onError: const Color(0xFF690005),
      surface: surfaceDarkColor,
      onSurface: const Color(0xFFE6E1E5),
      surfaceContainerHighest: const Color(0xFF2B2740),
    );

    return _buildTheme(colorScheme, Brightness.dark);
  }

  // ── Shared Theme Builder ────────────────────────────────────────
  static ThemeData _buildTheme(ColorScheme colorScheme, Brightness brightness) {
    final bool isLight = brightness == Brightness.light;

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      brightness: brightness,

      // ── Scaffold ───────────────────────────────────────────────
      scaffoldBackgroundColor: colorScheme.surface,

      // ── AppBar ─────────────────────────────────────────────────
      appBarTheme: AppBarTheme(
        elevation: 0,
        scrolledUnderElevation: 1,
        centerTitle: false,
        backgroundColor: colorScheme.surface,
        foregroundColor: colorScheme.onSurface,
        titleTextStyle: TextStyle(
          fontFamily: 'Inter',
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: colorScheme.onSurface,
        ),
        iconTheme: IconThemeData(
          color: colorScheme.onSurface,
          size: 24,
        ),
      ),

      // ── Card ───────────────────────────────────────────────────
      cardTheme: CardThemeData(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(
            color: isLight
                ? const Color(0xFFE0E0E0)
                : const Color(0xFF3C3850),
            width: 1,
          ),
        ),
        color: isLight
            ? Colors.white
            : const Color(0xFF252340),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        clipBehavior: Clip.antiAlias,
      ),

      // ── ElevatedButton ─────────────────────────────────────────
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 0,
          backgroundColor: colorScheme.primary,
          foregroundColor: colorScheme.onPrimary,
          disabledBackgroundColor:
              isLight ? const Color(0xFFE0E0E0) : const Color(0xFF3C3850),
          disabledForegroundColor:
              isLight ? const Color(0xFF9E9E9E) : const Color(0xFF6C6880),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          minimumSize: const Size(double.infinity, 50),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: const TextStyle(
            fontFamily: 'Inter',
            fontSize: 16,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
      ),

      // ── OutlinedButton ─────────────────────────────────────────
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: colorScheme.primary,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          minimumSize: const Size(double.infinity, 50),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          side: BorderSide(color: colorScheme.primary, width: 1.5),
          textStyle: const TextStyle(
            fontFamily: 'Inter',
            fontSize: 16,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
      ),

      // ── TextButton ─────────────────────────────────────────────
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: colorScheme.primary,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          textStyle: const TextStyle(
            fontFamily: 'Inter',
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      // ── FloatingActionButton ───────────────────────────────────
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        elevation: 4,
        highlightElevation: 8,
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        extendedPadding: const EdgeInsets.symmetric(horizontal: 20),
        extendedTextStyle: const TextStyle(
          fontFamily: 'Inter',
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
      ),

      // ── BottomNavigationBar ────────────────────────────────────
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        type: BottomNavigationBarType.fixed,
        backgroundColor: isLight ? Colors.white : const Color(0xFF1A1A2E),
        selectedItemColor: colorScheme.primary,
        unselectedItemColor:
            isLight ? const Color(0xFF9E9E9E) : const Color(0xFF6C6880),
        selectedLabelStyle: const TextStyle(
          fontFamily: 'Inter',
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: const TextStyle(
          fontFamily: 'Inter',
          fontSize: 12,
          fontWeight: FontWeight.w400,
        ),
        elevation: 8,
      ),

      // ── NavigationBar (M3) ─────────────────────────────────────
      navigationBarTheme: NavigationBarThemeData(
        elevation: 0,
        backgroundColor: isLight ? Colors.white : const Color(0xFF1A1A2E),
        indicatorColor: colorScheme.primary.withValues(alpha: 0.12),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return TextStyle(
              fontFamily: 'Inter',
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: colorScheme.primary,
            );
          }
          return TextStyle(
            fontFamily: 'Inter',
            fontSize: 12,
            fontWeight: FontWeight.w400,
            color: isLight
                ? const Color(0xFF9E9E9E)
                : const Color(0xFF6C6880),
          );
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return IconThemeData(color: colorScheme.primary, size: 24);
          }
          return IconThemeData(
            color: isLight
                ? const Color(0xFF9E9E9E)
                : const Color(0xFF6C6880),
            size: 24,
          );
        }),
        height: 64,
      ),

      // ── TextField / Input ──────────────────────────────────────
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: isLight
            ? const Color(0xFFF5F3FF)
            : const Color(0xFF2B2740),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colorScheme.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colorScheme.error, width: 1.5),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colorScheme.error, width: 2),
        ),
        hintStyle: TextStyle(
          fontFamily: 'Inter',
          fontSize: 14,
          fontWeight: FontWeight.w400,
          color: isLight
              ? const Color(0xFF9E9E9E)
              : const Color(0xFF6C6880),
        ),
        labelStyle: TextStyle(
          fontFamily: 'Inter',
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: isLight
              ? const Color(0xFF757575)
              : const Color(0xFF9E9E9E),
        ),
        errorStyle: TextStyle(
          fontFamily: 'Inter',
          fontSize: 12,
          fontWeight: FontWeight.w400,
          color: colorScheme.error,
        ),
        prefixIconColor: WidgetStateColor.resolveWith((states) {
          if (states.contains(WidgetState.focused)) {
            return colorScheme.primary;
          }
          return isLight
              ? const Color(0xFF9E9E9E)
              : const Color(0xFF6C6880);
        }),
        suffixIconColor: WidgetStateColor.resolveWith((states) {
          if (states.contains(WidgetState.focused)) {
            return colorScheme.primary;
          }
          return isLight
              ? const Color(0xFF9E9E9E)
              : const Color(0xFF6C6880);
        }),
      ),

      // ── Chip ───────────────────────────────────────────────────
      chipTheme: ChipThemeData(
        backgroundColor: isLight
            ? const Color(0xFFF5F3FF)
            : const Color(0xFF2B2740),
        selectedColor: colorScheme.primary.withValues(alpha: 0.15),
        labelStyle: TextStyle(
          fontFamily: 'Inter',
          fontSize: 13,
          fontWeight: FontWeight.w500,
          color: colorScheme.onSurface,
        ),
        secondaryLabelStyle: TextStyle(
          fontFamily: 'Inter',
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: colorScheme.primary,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        side: BorderSide.none,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      ),

      // ── Dialog ─────────────────────────────────────────────────
      dialogTheme: DialogThemeData(
        elevation: 8,
        backgroundColor: isLight ? Colors.white : const Color(0xFF252340),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        titleTextStyle: TextStyle(
          fontFamily: 'Inter',
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: colorScheme.onSurface,
        ),
        contentTextStyle: TextStyle(
          fontFamily: 'Inter',
          fontSize: 14,
          fontWeight: FontWeight.w400,
          color: colorScheme.onSurface,
        ),
      ),

      // ── BottomSheet ────────────────────────────────────────────
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: isLight ? Colors.white : const Color(0xFF252340),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        showDragHandle: true,
        dragHandleColor: isLight
            ? const Color(0xFFE0E0E0)
            : const Color(0xFF3C3850),
      ),

      // ── Snackbar ───────────────────────────────────────────────
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor:
            isLight ? const Color(0xFF323232) : const Color(0xFFE6E1E5),
        contentTextStyle: TextStyle(
          fontFamily: 'Inter',
          fontSize: 14,
          color: isLight ? Colors.white : const Color(0xFF1C1B1F),
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        elevation: 4,
      ),

      // ── Divider ────────────────────────────────────────────────
      dividerTheme: DividerThemeData(
        color: isLight
            ? const Color(0xFFE0E0E0)
            : const Color(0xFF3C3850),
        thickness: 1,
        space: 1,
      ),

      // ── Switch ─────────────────────────────────────────────────
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return colorScheme.primary;
          }
          return isLight ? Colors.white : const Color(0xFFE6E1E5);
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return colorScheme.primary.withValues(alpha: 0.5);
          }
          return isLight
              ? const Color(0xFFE0E0E0)
              : const Color(0xFF3C3850);
        }),
      ),

      // ── Checkbox ───────────────────────────────────────────────
      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return colorScheme.primary;
          }
          return Colors.transparent;
        }),
        checkColor: WidgetStateProperty.all(Colors.white),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(4),
        ),
        side: BorderSide(
          color: isLight
              ? const Color(0xFF9E9E9E)
              : const Color(0xFF6C6880),
          width: 2,
        ),
      ),

      // ── Slider ─────────────────────────────────────────────────
      sliderTheme: SliderThemeData(
        activeTrackColor: colorScheme.primary,
        inactiveTrackColor: colorScheme.primary.withValues(alpha: 0.2),
        thumbColor: colorScheme.primary,
        overlayColor: colorScheme.primary.withValues(alpha: 0.12),
        trackHeight: 4,
        thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8),
      ),

      // ── ProgressIndicator ──────────────────────────────────────
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: colorScheme.primary,
        linearTrackColor: colorScheme.primary.withValues(alpha: 0.12),
        circularTrackColor: colorScheme.primary.withValues(alpha: 0.12),
      ),

      // ── TabBar ─────────────────────────────────────────────────
      tabBarTheme: TabBarThemeData(
        labelColor: colorScheme.primary,
        unselectedLabelColor:
            isLight ? const Color(0xFF757575) : const Color(0xFF9E9E9E),
        labelStyle: const TextStyle(
          fontFamily: 'Inter',
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: const TextStyle(
          fontFamily: 'Inter',
          fontSize: 14,
          fontWeight: FontWeight.w400,
        ),
        indicatorColor: colorScheme.primary,
        indicatorSize: TabBarIndicatorSize.label,
      ),

      // ── PopupMenu ──────────────────────────────────────────────
      popupMenuTheme: PopupMenuThemeData(
        elevation: 8,
        color:
            isLight ? Colors.white : const Color(0xFF252340),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        textStyle: TextStyle(
          fontFamily: 'Inter',
          fontSize: 14,
          fontWeight: FontWeight.w400,
          color: colorScheme.onSurface,
        ),
      ),

      // ── Tooltip ────────────────────────────────────────────────
      tooltipTheme: TooltipThemeData(
        decoration: BoxDecoration(
          color: isLight
              ? const Color(0xFF323232)
              : const Color(0xFFE6E1E5),
          borderRadius: BorderRadius.circular(8),
        ),
        textStyle: TextStyle(
          fontFamily: 'Inter',
          fontSize: 12,
          color: isLight ? Colors.white : const Color(0xFF1C1B1F),
        ),
        waitDuration: const Duration(seconds: 1),
      ),

      // ── ListTile ───────────────────────────────────────────────
      listTileTheme: ListTileThemeData(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16),
        titleTextStyle: TextStyle(
          fontFamily: 'Inter',
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: colorScheme.onSurface,
        ),
        subtitleTextStyle: TextStyle(
          fontFamily: 'Inter',
          fontSize: 13,
          fontWeight: FontWeight.w400,
          color: isLight
              ? const Color(0xFF757575)
              : const Color(0xFF9E9E9E),
        ),
      ),

      // ── Icon ───────────────────────────────────────────────────
      iconTheme: IconThemeData(
        color: colorScheme.onSurface,
        size: 24,
      ),

      // ── PrimaryIcon ────────────────────────────────────────────
      primaryIconTheme: IconThemeData(
        color: colorScheme.primary,
        size: 24,
      ),

      // ── Text Theme ─────────────────────────────────────────────
      textTheme: TextTheme(
        // Display
        displayLarge: TextStyle(
          fontFamily: 'Inter',
          fontSize: 57,
          fontWeight: FontWeight.w700,
          height: 1.12,
          letterSpacing: -0.25,
          color: colorScheme.onSurface,
        ),
        displayMedium: TextStyle(
          fontFamily: 'Inter',
          fontSize: 45,
          fontWeight: FontWeight.w700,
          height: 1.16,
          letterSpacing: 0,
          color: colorScheme.onSurface,
        ),
        displaySmall: TextStyle(
          fontFamily: 'Inter',
          fontSize: 36,
          fontWeight: FontWeight.w700,
          height: 1.22,
          letterSpacing: 0,
          color: colorScheme.onSurface,
        ),
        // Headline
        headlineLarge: TextStyle(
          fontFamily: 'Inter',
          fontSize: 32,
          fontWeight: FontWeight.w600,
          height: 1.25,
          letterSpacing: 0,
          color: colorScheme.onSurface,
        ),
        headlineMedium: TextStyle(
          fontFamily: 'Inter',
          fontSize: 28,
          fontWeight: FontWeight.w600,
          height: 1.29,
          letterSpacing: 0,
          color: colorScheme.onSurface,
        ),
        headlineSmall: TextStyle(
          fontFamily: 'Inter',
          fontSize: 24,
          fontWeight: FontWeight.w600,
          height: 1.33,
          letterSpacing: 0,
          color: colorScheme.onSurface,
        ),
        // Title
        titleLarge: TextStyle(
          fontFamily: 'Inter',
          fontSize: 22,
          fontWeight: FontWeight.w600,
          height: 1.27,
          letterSpacing: 0,
          color: colorScheme.onSurface,
        ),
        titleMedium: TextStyle(
          fontFamily: 'Inter',
          fontSize: 16,
          fontWeight: FontWeight.w600,
          height: 1.5,
          letterSpacing: 0.15,
          color: colorScheme.onSurface,
        ),
        titleSmall: TextStyle(
          fontFamily: 'Inter',
          fontSize: 14,
          fontWeight: FontWeight.w600,
          height: 1.43,
          letterSpacing: 0.1,
          color: colorScheme.onSurface,
        ),
        // Body
        bodyLarge: TextStyle(
          fontFamily: 'Inter',
          fontSize: 16,
          fontWeight: FontWeight.w400,
          height: 1.5,
          letterSpacing: 0.5,
          color: colorScheme.onSurface,
        ),
        bodyMedium: TextStyle(
          fontFamily: 'Inter',
          fontSize: 14,
          fontWeight: FontWeight.w400,
          height: 1.43,
          letterSpacing: 0.25,
          color: colorScheme.onSurface,
        ),
        bodySmall: TextStyle(
          fontFamily: 'Inter',
          fontSize: 12,
          fontWeight: FontWeight.w400,
          height: 1.33,
          letterSpacing: 0.4,
          color: colorScheme.onSurface,
        ),
        // Label
        labelLarge: TextStyle(
          fontFamily: 'Inter',
          fontSize: 14,
          fontWeight: FontWeight.w600,
          height: 1.43,
          letterSpacing: 0.1,
          color: colorScheme.onSurface,
        ),
        labelMedium: TextStyle(
          fontFamily: 'Inter',
          fontSize: 12,
          fontWeight: FontWeight.w600,
          height: 1.33,
          letterSpacing: 0.5,
          color: colorScheme.onSurface,
        ),
        labelSmall: TextStyle(
          fontFamily: 'Inter',
          fontSize: 11,
          fontWeight: FontWeight.w600,
          height: 1.45,
          letterSpacing: 0.5,
          color: colorScheme.onSurface,
        ),
      ),
    );
  }
}

/// Semantic colour extensions for quick access from `ThemeData`.
extension AppThemeExtension on ThemeData {
  /// Brand primary colour – Indigo #4D2DAB.
  Color get brandPrimary => AppTheme.primaryColor;

  /// Brand secondary colour – Teal #00BFA6.
  Color get brandSecondary => AppTheme.secondaryColor;

  /// Accent / destructive colour – #FF6B6B.
  Color get brandAccent => AppTheme.accentColor;

  /// Warning colour.
  Color get brandWarning => AppTheme.warningColor;

  /// Success colour.
  Color get brandSuccess => AppTheme.successColor;

  /// Info colour.
  Color get brandInfo => AppTheme.infoColor;
}
