import 'package:flutter_riverpod/flutter_riverpod.dart';

enum FlashMode { auto, on, off }
enum ColorMode { color, grayscale, blackWhite }
enum PageSize { a4, letter, legal }
enum BackupFrequency { hourly, daily, weekly, monthly }
enum AiLanguage { english, spanish, french, german, chinese, japanese }

class SettingsState {
  // Scanner
  final String defaultQuality;
  final bool autoCapture;
  final FlashMode flashMode;
  final ColorMode defaultColorMode;

  // OCR
  final String defaultOcrLanguage;
  final bool autoOcr;

  // PDF
  final PageSize defaultPageSize;
  final String compressionQuality;

  // Cloud
  final bool autoSync;
  final bool wifiOnly;
  final BackupFrequency backupFrequency;

  // Security
  final bool appLock;
  final bool biometric;
  final bool hasPin;

  // AI
  final bool aiFeatures;
  final AiLanguage aiLanguage;

  const SettingsState({
    this.defaultQuality = 'High',
    this.autoCapture = true,
    this.flashMode = FlashMode.auto,
    this.defaultColorMode = ColorMode.color,
    this.defaultOcrLanguage = 'English',
    this.autoOcr = false,
    this.defaultPageSize = PageSize.a4,
    this.compressionQuality = 'Medium',
    this.autoSync = true,
    this.wifiOnly = true,
    this.backupFrequency = BackupFrequency.daily,
    this.appLock = false,
    this.biometric = false,
    this.hasPin = false,
    this.aiFeatures = true,
    this.aiLanguage = AiLanguage.english,
  });

  SettingsState copyWith({
    String? defaultQuality,
    bool? autoCapture,
    FlashMode? flashMode,
    ColorMode? defaultColorMode,
    String? defaultOcrLanguage,
    bool? autoOcr,
    PageSize? defaultPageSize,
    String? compressionQuality,
    bool? autoSync,
    bool? wifiOnly,
    BackupFrequency? backupFrequency,
    bool? appLock,
    bool? biometric,
    bool? hasPin,
    bool? aiFeatures,
    AiLanguage? aiLanguage,
  }) {
    return SettingsState(
      defaultQuality: defaultQuality ?? this.defaultQuality,
      autoCapture: autoCapture ?? this.autoCapture,
      flashMode: flashMode ?? this.flashMode,
      defaultColorMode: defaultColorMode ?? this.defaultColorMode,
      defaultOcrLanguage: defaultOcrLanguage ?? this.defaultOcrLanguage,
      autoOcr: autoOcr ?? this.autoOcr,
      defaultPageSize: defaultPageSize ?? this.defaultPageSize,
      compressionQuality: compressionQuality ?? this.compressionQuality,
      autoSync: autoSync ?? this.autoSync,
      wifiOnly: wifiOnly ?? this.wifiOnly,
      backupFrequency: backupFrequency ?? this.backupFrequency,
      appLock: appLock ?? this.appLock,
      biometric: biometric ?? this.biometric,
      hasPin: hasPin ?? this.hasPin,
      aiFeatures: aiFeatures ?? this.aiFeatures,
      aiLanguage: aiLanguage ?? this.aiLanguage,
    );
  }
}

class SettingsNotifier extends StateNotifier<SettingsState> {
  SettingsNotifier() : super(const SettingsState());

  void updateDefaultQuality(String quality) {
    state = state.copyWith(defaultQuality: quality);
  }

  void toggleAutoCapture(bool value) {
    state = state.copyWith(autoCapture: value);
  }

  void setFlashMode(FlashMode mode) {
    state = state.copyWith(flashMode: mode);
  }

  void setColorMode(ColorMode mode) {
    state = state.copyWith(defaultColorMode: mode);
  }

  void setOcrLanguage(String language) {
    state = state.copyWith(defaultOcrLanguage: language);
  }

  void toggleAutoOcr(bool value) {
    state = state.copyWith(autoOcr: value);
  }

  void setPageSize(PageSize size) {
    state = state.copyWith(defaultPageSize: size);
  }

  void setCompressionQuality(String quality) {
    state = state.copyWith(compressionQuality: quality);
  }

  void toggleAutoSync(bool value) {
    state = state.copyWith(autoSync: value);
  }

  void toggleWifiOnly(bool value) {
    state = state.copyWith(wifiOnly: value);
  }

  void setBackupFrequency(BackupFrequency frequency) {
    state = state.copyWith(backupFrequency: frequency);
  }

  void toggleAppLock(bool value) {
    state = state.copyWith(appLock: value);
  }

  void toggleBiometric(bool value) {
    state = state.copyWith(biometric: value);
  }

  void setHasPin(bool value) {
    state = state.copyWith(hasPin: value);
  }

  void toggleAiFeatures(bool value) {
    state = state.copyWith(aiFeatures: value);
  }

  void setAiLanguage(AiLanguage language) {
    state = state.copyWith(aiLanguage: language);
  }
}

final settingsProvider = StateNotifierProvider<SettingsNotifier, SettingsState>(
  (ref) => SettingsNotifier(),
);
