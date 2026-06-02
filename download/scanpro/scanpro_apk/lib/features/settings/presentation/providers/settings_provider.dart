import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:scanpro/core/constants/app_constants.dart';
import 'package:scanpro/di/app_module.dart';
import 'package:shared_preferences/shared_preferences.dart';

// ═══════════════════════════════════════════════════════════════════
//  Theme Provider
// ═══════════════════════════════════════════════════════════════════

/// Provides the current [ThemeMode] with persistence.
/// Delegates to the core [themeModeProvider] in app_module.
final settingsThemeProvider = Provider<ThemeMode>((ref) {
  return ref.watch(themeModeProvider);
});

/// Notifier to change the theme mode from settings.
final settingsThemeNotifierProvider =
    Provider<ThemeModeNotifier>((ref) {
  return ref.watch(themeModeProvider.notifier);
});

// ═══════════════════════════════════════════════════════════════════
//  Language Provider
// ═══════════════════════════════════════════════════════════════════

/// Supported languages in the app.
class AppLanguage {
  const AppLanguage({
    required this.code,
    required this.name,
    required this.nativeName,
  });

  final String code;
  final String name;
  final String nativeName;
}

/// All supported languages.
const supportedLanguages = [
  AppLanguage(code: 'en', name: 'English', nativeName: 'English'),
  AppLanguage(code: 'es', name: 'Spanish', nativeName: 'Español'),
  AppLanguage(code: 'fr', name: 'French', nativeName: 'Français'),
  AppLanguage(code: 'de', name: 'German', nativeName: 'Deutsch'),
  AppLanguage(code: 'it', name: 'Italian', nativeName: 'Italiano'),
  AppLanguage(code: 'pt', name: 'Portuguese', nativeName: 'Português'),
  AppLanguage(code: 'zh', name: 'Chinese', nativeName: '中文'),
  AppLanguage(code: 'ja', name: 'Japanese', nativeName: '日本語'),
  AppLanguage(code: 'ko', name: 'Korean', nativeName: '한국어'),
  AppLanguage(code: 'ar', name: 'Arabic', nativeName: 'العربية'),
  AppLanguage(code: 'hi', name: 'Hindi', nativeName: 'हिन्दी'),
  AppLanguage(code: 'ru', name: 'Russian', nativeName: 'Русский'),
];

/// State notifier for the application language.
class LanguageNotifier extends StateNotifier<AppLanguage> {
  LanguageNotifier(this._prefs) : super(supportedLanguages.first) {
    _init();
  }

  final SharedPreferences _prefs;

  void _init() {
    final saved = _prefs.getString(AppConstants.prefsLanguageKey);
    if (saved != null) {
      final match = supportedLanguages.where((l) => l.code == saved);
      if (match.isNotEmpty) state = match.first;
    }
  }

  void setLanguage(AppLanguage language) {
    state = language;
    _prefs.setString(AppConstants.prefsLanguageKey, language.code);
  }
}

/// Provides the current application language.
final languageProvider =
    StateNotifierProvider<LanguageNotifier, AppLanguage>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return LanguageNotifier(prefs);
});

// ═══════════════════════════════════════════════════════════════════
//  Notification Settings
// ═══════════════════════════════════════════════════════════════════

/// Notification preferences state.
class NotificationSettings {
  const NotificationSettings({
    this.pushNotifications = true,
    this.scanComplete = true,
    this.syncComplete = true,
    this.tipsAndTricks = false,
  });

  final bool pushNotifications;
  final bool scanComplete;
  final bool syncComplete;
  final bool tipsAndTricks;

  NotificationSettings copyWith({
    bool? pushNotifications,
    bool? scanComplete,
    bool? syncComplete,
    bool? tipsAndTricks,
  }) {
    return NotificationSettings(
      pushNotifications: pushNotifications ?? this.pushNotifications,
      scanComplete: scanComplete ?? this.scanComplete,
      syncComplete: syncComplete ?? this.syncComplete,
      tipsAndTricks: tipsAndTricks ?? this.tipsAndTricks,
    );
  }
}

/// State notifier for notification settings.
class NotificationSettingsNotifier
    extends StateNotifier<NotificationSettings> {
  NotificationSettingsNotifier(this._prefs)
      : super(const NotificationSettings()) {
    _init();
  }

  final SharedPreferences _prefs;

  void _init() {
    state = NotificationSettings(
      pushNotifications:
          _prefs.getBool('notif_push') ?? true,
      scanComplete: _prefs.getBool('notif_scan') ?? true,
      syncComplete: _prefs.getBool('notif_sync') ?? true,
      tipsAndTricks: _prefs.getBool('notif_tips') ?? false,
    );
  }

  void setPushNotifications(bool value) {
    state = state.copyWith(pushNotifications: value);
    _prefs.setBool('notif_push', value);
  }

  void setScanComplete(bool value) {
    state = state.copyWith(scanComplete: value);
    _prefs.setBool('notif_scan', value);
  }

  void setSyncComplete(bool value) {
    state = state.copyWith(syncComplete: value);
    _prefs.setBool('notif_sync', value);
  }

  void setTipsAndTricks(bool value) {
    state = state.copyWith(tipsAndTricks: value);
    _prefs.setBool('notif_tips', value);
  }
}

/// Provides notification settings.
final notificationSettingsProvider = StateNotifierProvider<
    NotificationSettingsNotifier, NotificationSettings>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return NotificationSettingsNotifier(prefs);
});

// ═══════════════════════════════════════════════════════════════════
//  Scan Quality Provider
// ═══════════════════════════════════════════════════════════════════

/// Scan quality levels.
enum ScanQuality {
  low('Low', 150, 0.6),
  medium('Medium', 300, 0.85),
  high('High', 600, 0.95);

  const ScanQuality(this.label, this.dpi, this.jpegQuality);

  final String label;
  final int dpi;
  final double jpegQuality;
}

/// State notifier for default scan quality.
class ScanQualityNotifier extends StateNotifier<ScanQuality> {
  ScanQualityNotifier(this._prefs) : super(ScanQuality.medium) {
    _init();
  }

  final SharedPreferences _prefs;

  void _init() {
    final saved = _prefs.getString(AppConstants.prefsDefaultScanQualityKey);
    if (saved != null) {
      final match = ScanQuality.values.where((q) => q.name == saved);
      if (match.isNotEmpty) state = match.first;
    }
  }

  void setScanQuality(ScanQuality quality) {
    state = quality;
    _prefs.setString(AppConstants.prefsDefaultScanQualityKey, quality.name);
  }
}

/// Provides the default scan quality setting.
final defaultScanQualityProvider =
    StateNotifierProvider<ScanQualityNotifier, ScanQuality>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return ScanQualityNotifier(prefs);
});

// ═══════════════════════════════════════════════════════════════════
//  Auto Sync Provider
// ═══════════════════════════════════════════════════════════════════

/// State notifier for auto-sync enabled preference.
class AutoSyncNotifier extends StateNotifier<bool> {
  AutoSyncNotifier(this._prefs) : super(true) {
    _init();
  }

  final SharedPreferences _prefs;

  void _init() {
    state = _prefs.getBool(AppConstants.prefsAutoSyncKey) ?? true;
  }

  void setAutoSync(bool value) {
    state = value;
    _prefs.setBool(AppConstants.prefsAutoSyncKey, value);
  }
}

/// Provides whether auto-sync is enabled.
final autoSyncEnabledNotifierProvider =
    StateNotifierProvider<AutoSyncNotifier, bool>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return AutoSyncNotifier(prefs);
});

// ═══════════════════════════════════════════════════════════════════
//  Auto-Enhance Provider
// ═══════════════════════════════════════════════════════════════════

/// State notifier for auto-enhance preference.
class AutoEnhanceNotifier extends StateNotifier<bool> {
  AutoEnhanceNotifier(this._prefs) : super(true) {
    _init();
  }

  final SharedPreferences _prefs;

  void _init() {
    state = _prefs.getBool('auto_enhance') ?? true;
  }

  void setAutoEnhance(bool value) {
    state = value;
    _prefs.setBool('auto_enhance', value);
  }
}

/// Provides whether auto-enhance is enabled.
final autoEnhanceProvider =
    StateNotifierProvider<AutoEnhanceNotifier, bool>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return AutoEnhanceNotifier(prefs);
});

// ═══════════════════════════════════════════════════════════════════
//  WiFi-Only Sync Provider
// ═══════════════════════════════════════════════════════════════════

/// State notifier for WiFi-only sync preference.
class WifiOnlySyncNotifier extends StateNotifier<bool> {
  WifiOnlySyncNotifier(this._prefs) : super(false) {
    _init();
  }

  final SharedPreferences _prefs;

  void _init() {
    state = _prefs.getBool(AppConstants.prefsWifiOnlySyncKey) ?? false;
  }

  void setWifiOnly(bool value) {
    state = value;
    _prefs.setBool(AppConstants.prefsWifiOnlySyncKey, value);
  }
}

/// Provides whether WiFi-only sync is enabled.
final wifiOnlySyncNotifierProvider =
    StateNotifierProvider<WifiOnlySyncNotifier, bool>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return WifiOnlySyncNotifier(prefs);
});

// ═══════════════════════════════════════════════════════════════════
//  File Format Provider
// ═══════════════════════════════════════════════════════════════════

/// Default export file format.
enum ExportFormat { pdf, jpg, png }

/// State notifier for default export format.
class ExportFormatNotifier extends StateNotifier<ExportFormat> {
  ExportFormatNotifier(this._prefs) : super(ExportFormat.pdf) {
    _init();
  }

  final SharedPreferences _prefs;

  void _init() {
    final saved = _prefs.getString(AppConstants.prefsDefaultExportFormatKey);
    if (saved != null) {
      final match = ExportFormat.values.where((f) => f.name == saved);
      if (match.isNotEmpty) state = match.first;
    }
  }

  void setExportFormat(ExportFormat format) {
    state = format;
    _prefs.setString(AppConstants.prefsDefaultExportFormatKey, format.name);
  }
}

/// Provides the default export format.
final defaultExportFormatProvider =
    StateNotifierProvider<ExportFormatNotifier, ExportFormat>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return ExportFormatNotifier(prefs);
});

// ═══════════════════════════════════════════════════════════════════
//  Security Settings Providers
// ═══════════════════════════════════════════════════════════════════

/// Whether biometric authentication is enabled.
final biometricEnabledProvider = StateProvider<bool>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return prefs.getBool(AppConstants.secureStorageBiometricKey) ?? false;
});

/// Whether the app lock (PIN) is enabled.
final appLockEnabledProvider = StateProvider<bool>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return prefs.getBool('app_lock_enabled') ?? false;
});
