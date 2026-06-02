import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../providers/settings_provider.dart';
import '../widgets/settings_section.dart';
import '../widgets/settings_tile.dart';
import '../widgets/toggle_tile.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 8),
        children: [
          // Scanner section
          SettingsSection(title: 'Scanner').animate().fadeIn(duration: 200.ms),
          Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Column(
              children: [
                SettingsTile(
                  icon: Icons.high_quality,
                  title: 'Default Quality',
                  trailing: _buildQualityDropdown(settings, ref, theme),
                ),
                const Divider(height: 1, indent: 56),
                ToggleTile(
                  icon: Icons.auto_fix_high,
                  title: 'Auto-Capture',
                  subtitle: 'Automatically capture when document is detected',
                  value: settings.autoCapture,
                  onChanged: (v) =>
                      ref.read(settingsProvider.notifier).toggleAutoCapture(v),
                ),
                const Divider(height: 1, indent: 56),
                SettingsTile(
                  icon: Icons.flash_on,
                  title: 'Flash Mode',
                  trailing: _buildFlashDropdown(settings, ref, theme),
                ),
                const Divider(height: 1, indent: 56),
                SettingsTile(
                  icon: Icons.palette,
                  title: 'Default Color Mode',
                  trailing: _buildColorModeDropdown(settings, ref, theme),
                ),
              ],
            ),
          ),

          // OCR section
          const SizedBox(height: 8),
          SettingsSection(title: 'OCR').animate().fadeIn(duration: 200.ms, delay: 50.ms),
          Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Column(
              children: [
                SettingsTile(
                  icon: Icons.language,
                  title: 'Default Language',
                  trailing: _buildOcrLanguageDropdown(settings, ref, theme),
                ),
                const Divider(height: 1, indent: 56),
                ToggleTile(
                  icon: Icons.text_fields,
                  title: 'Auto-OCR',
                  subtitle: 'Automatically run OCR on scanned documents',
                  value: settings.autoOcr,
                  onChanged: (v) =>
                      ref.read(settingsProvider.notifier).toggleAutoOcr(v),
                ),
              ],
            ),
          ),

          // PDF section
          const SizedBox(height: 8),
          SettingsSection(title: 'PDF').animate().fadeIn(duration: 200.ms, delay: 100.ms),
          Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Column(
              children: [
                SettingsTile(
                  icon: Icons.description,
                  title: 'Default Page Size',
                  trailing: _buildPageSizeDropdown(settings, ref, theme),
                ),
                const Divider(height: 1, indent: 56),
                SettingsTile(
                  icon: Icons.compress,
                  title: 'Compression Quality',
                  trailing: _buildCompressionDropdown(settings, ref, theme),
                ),
              ],
            ),
          ),

          // Cloud section
          const SizedBox(height: 8),
          SettingsSection(title: 'Cloud').animate().fadeIn(duration: 200.ms, delay: 150.ms),
          Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Column(
              children: [
                ToggleTile(
                  icon: Icons.sync,
                  title: 'Auto-Sync',
                  subtitle: 'Automatically sync documents to cloud',
                  value: settings.autoSync,
                  onChanged: (v) =>
                      ref.read(settingsProvider.notifier).toggleAutoSync(v),
                ),
                const Divider(height: 1, indent: 56),
                ToggleTile(
                  icon: Icons.wifi,
                  title: 'Wi-Fi Only',
                  subtitle: 'Only sync when connected to Wi-Fi',
                  value: settings.wifiOnly,
                  onChanged: (v) =>
                      ref.read(settingsProvider.notifier).toggleWifiOnly(v),
                ),
                const Divider(height: 1, indent: 56),
                SettingsTile(
                  icon: Icons.schedule,
                  title: 'Backup Frequency',
                  trailing: _buildBackupFrequencyDropdown(settings, ref, theme),
                ),
              ],
            ),
          ),

          // Security section
          const SizedBox(height: 8),
          SettingsSection(title: 'Security').animate().fadeIn(duration: 200.ms, delay: 200.ms),
          Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Column(
              children: [
                ToggleTile(
                  icon: Icons.lock,
                  title: 'App Lock',
                  subtitle: 'Require PIN to open the app',
                  value: settings.appLock,
                  onChanged: (v) =>
                      ref.read(settingsProvider.notifier).toggleAppLock(v),
                ),
                const Divider(height: 1, indent: 56),
                ToggleTile(
                  icon: Icons.fingerprint,
                  title: 'Biometric Unlock',
                  subtitle: 'Use fingerprint or face to unlock',
                  value: settings.biometric,
                  onChanged: (v) =>
                      ref.read(settingsProvider.notifier).toggleBiometric(v),
                ),
                const Divider(height: 1, indent: 56),
                SettingsTile(
                  icon: Icons.pin,
                  title: 'Change PIN',
                  onTap: () {
                    // Navigate to PIN setup
                  },
                ),
              ],
            ),
          ),

          // AI section
          const SizedBox(height: 8),
          SettingsSection(title: 'AI').animate().fadeIn(duration: 200.ms, delay: 250.ms),
          Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Column(
              children: [
                ToggleTile(
                  icon: Icons.auto_awesome,
                  title: 'AI Features',
                  subtitle: 'Enable AI-powered features and suggestions',
                  value: settings.aiFeatures,
                  onChanged: (v) =>
                      ref.read(settingsProvider.notifier).toggleAiFeatures(v),
                ),
                const Divider(height: 1, indent: 56),
                SettingsTile(
                  icon: Icons.translate,
                  title: 'AI Language',
                  trailing: _buildAiLanguageDropdown(settings, ref, theme),
                ),
              ],
            ),
          ),

          // About section
          const SizedBox(height: 8),
          SettingsSection(title: 'About').animate().fadeIn(duration: 200.ms, delay: 300.ms),
          Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Column(
              children: [
                SettingsTile(
                  icon: Icons.info_outline,
                  title: 'Version',
                  trailing: Text(
                    '2.4.1',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
                const Divider(height: 1, indent: 56),
                SettingsTile(
                  icon: Icons.star_outline,
                  title: 'Rate App',
                  onTap: () {
                    // Open store rating
                  },
                ),
                const Divider(height: 1, indent: 56),
                SettingsTile(
                  icon: Icons.privacy_tip_outlined,
                  title: 'Privacy Policy',
                  onTap: () {
                    // Open privacy policy
                  },
                ),
                const Divider(height: 1, indent: 56),
                SettingsTile(
                  icon: Icons.article_outlined,
                  title: 'Terms of Service',
                  onTap: () {
                    // Open terms
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildQualityDropdown(SettingsState s, WidgetRef ref, ThemeData theme) {
    return DropdownButton<String>(
      value: s.defaultQuality,
      underline: const SizedBox.shrink(),
      isDense: true,
      items: ['Low', 'Medium', 'High']
          .map((v) => DropdownMenuItem(value: v, child: Text(v)))
          .toList(),
      onChanged: (v) {
        if (v != null) ref.read(settingsProvider.notifier).updateDefaultQuality(v);
      },
    );
  }

  Widget _buildFlashDropdown(SettingsState s, WidgetRef ref, ThemeData theme) {
    return DropdownButton<FlashMode>(
      value: s.flashMode,
      underline: const SizedBox.shrink(),
      isDense: true,
      items: FlashMode.values
          .map((v) => DropdownMenuItem(
                value: v,
                child: Text(v.name.capitalize()),
              ))
          .toList(),
      onChanged: (v) {
        if (v != null) ref.read(settingsProvider.notifier).setFlashMode(v);
      },
    );
  }

  Widget _buildColorModeDropdown(SettingsState s, WidgetRef ref, ThemeData theme) {
    return DropdownButton<ColorMode>(
      value: s.defaultColorMode,
      underline: const SizedBox.shrink(),
      isDense: true,
      items: ColorMode.values
          .map((v) => DropdownMenuItem(
                value: v,
                child: Text(_colorModeLabel(v)),
              ))
          .toList(),
      onChanged: (v) {
        if (v != null) ref.read(settingsProvider.notifier).setColorMode(v);
      },
    );
  }

  Widget _buildOcrLanguageDropdown(SettingsState s, WidgetRef ref, ThemeData theme) {
    return DropdownButton<String>(
      value: s.defaultOcrLanguage,
      underline: const SizedBox.shrink(),
      isDense: true,
      items: ['English', 'Spanish', 'French', 'German', 'Chinese', 'Japanese']
          .map((v) => DropdownMenuItem(value: v, child: Text(v)))
          .toList(),
      onChanged: (v) {
        if (v != null) ref.read(settingsProvider.notifier).setOcrLanguage(v);
      },
    );
  }

  Widget _buildPageSizeDropdown(SettingsState s, WidgetRef ref, ThemeData theme) {
    return DropdownButton<PageSize>(
      value: s.defaultPageSize,
      underline: const SizedBox.shrink(),
      isDense: true,
      items: PageSize.values
          .map((v) => DropdownMenuItem(
                value: v,
                child: Text(v.name.toUpperCase()),
              ))
          .toList(),
      onChanged: (v) {
        if (v != null) ref.read(settingsProvider.notifier).setPageSize(v);
      },
    );
  }

  Widget _buildCompressionDropdown(SettingsState s, WidgetRef ref, ThemeData theme) {
    return DropdownButton<String>(
      value: s.compressionQuality,
      underline: const SizedBox.shrink(),
      isDense: true,
      items: ['Low', 'Medium', 'High']
          .map((v) => DropdownMenuItem(value: v, child: Text(v)))
          .toList(),
      onChanged: (v) {
        if (v != null) ref.read(settingsProvider.notifier).setCompressionQuality(v);
      },
    );
  }

  Widget _buildBackupFrequencyDropdown(SettingsState s, WidgetRef ref, ThemeData theme) {
    return DropdownButton<BackupFrequency>(
      value: s.backupFrequency,
      underline: const SizedBox.shrink(),
      isDense: true,
      items: BackupFrequency.values
          .map((v) => DropdownMenuItem(
                value: v,
                child: Text(v.name.capitalize()),
              ))
          .toList(),
      onChanged: (v) {
        if (v != null) ref.read(settingsProvider.notifier).setBackupFrequency(v);
      },
    );
  }

  Widget _buildAiLanguageDropdown(SettingsState s, WidgetRef ref, ThemeData theme) {
    return DropdownButton<AiLanguage>(
      value: s.aiLanguage,
      underline: const SizedBox.shrink(),
      isDense: true,
      items: AiLanguage.values
          .map((v) => DropdownMenuItem(
                value: v,
                child: Text(v.name.capitalize()),
              ))
          .toList(),
      onChanged: (v) {
        if (v != null) ref.read(settingsProvider.notifier).setAiLanguage(v);
      },
    );
  }

  String _colorModeLabel(ColorMode mode) {
    switch (mode) {
      case ColorMode.color:
        return 'Color';
      case ColorMode.grayscale:
        return 'Grayscale';
      case ColorMode.blackWhite:
        return 'Black & White';
    }
  }
}

extension StringCapitalize on String {
  String capitalize() {
    if (isEmpty) return this;
    return '${this[0].toUpperCase()}${substring(1)}';
  }
}
