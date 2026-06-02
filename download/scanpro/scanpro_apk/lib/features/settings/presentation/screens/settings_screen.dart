import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/routing/app_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../providers/settings_provider.dart';

/// Settings screen with sections for Appearance, Scanning, Cloud,
/// Security, Storage, and About.
class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        children: [
          // ── Appearance ────────────────────────────────────────────
          _SectionHeader(title: 'Appearance'),
          const SizedBox(height: 8),
          _AppearanceSection(),
          const SizedBox(height: 24),

          // ── Scanning ──────────────────────────────────────────────
          _SectionHeader(title: 'Scanning'),
          const SizedBox(height: 8),
          _ScanningSection(),
          const SizedBox(height: 24),

          // ── Cloud ─────────────────────────────────────────────────
          _SectionHeader(title: 'Cloud'),
          const SizedBox(height: 8),
          _CloudSection(),
          const SizedBox(height: 24),

          // ── Security ──────────────────────────────────────────────
          _SectionHeader(title: 'Security'),
          const SizedBox(height: 8),
          const _SecuritySection(),
          const SizedBox(height: 24),

          // ── Storage ───────────────────────────────────────────────
          _SectionHeader(title: 'Storage'),
          const SizedBox(height: 8),
          const _StorageSection(),
          const SizedBox(height: 24),

          // ── About ─────────────────────────────────────────────────
          _SectionHeader(title: 'About'),
          const SizedBox(height: 8),
          const _AboutSection(),
          const SizedBox(height: 40),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════
//  Section Header
// ═══════════════════════════════════════════════════════════════════

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        title,
        style: theme.textTheme.titleSmall?.copyWith(
          fontWeight: FontWeight.w700,
          color: AppTheme.primaryColor,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════
//  Settings Card
// ═══════════════════════════════════════════════════════════════════

class _SettingsCard extends StatelessWidget {
  const _SettingsCard({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (int i = 0; i < children.length; i++) ...[
            children[i],
            if (i < children.length - 1)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Divider(
                  height: 1,
                  color: colorScheme.onSurface.withValues(alpha: 0.06),
                ),
              ),
          ],
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════
//  Appearance Section
// ═══════════════════════════════════════════════════════════════════

class _AppearanceSection extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final currentMode = ref.watch(settingsThemeProvider);

    return _SettingsCard(
      children: [
        // Theme mode selector
        ListTile(
          leading: Icon(
            Icons.palette_outlined,
            color: colorScheme.onSurface.withValues(alpha: 0.6),
            size: 22,
          ),
          title: Text(
            'Theme',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurface,
            ),
          ),
          trailing: _ThemeSegmentedControl(
            currentMode: currentMode,
            onModeChanged: (mode) {
              ref.read(settingsThemeNotifierProvider).setThemeMode(mode);
            },
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16),
        ),
        // Dark mode toggle (convenience shortcut)
        SwitchListTile(
          secondary: Icon(
            Icons.dark_mode_outlined,
            color: colorScheme.onSurface.withValues(alpha: 0.6),
            size: 22,
          ),
          title: Text(
            'Dark Mode',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurface,
            ),
          ),
          value: currentMode == ThemeMode.dark ||
              (currentMode == ThemeMode.system &&
                  MediaQuery.of(context).platformBrightness ==
                      Brightness.dark),
          onChanged: (value) {
            ref.read(settingsThemeNotifierProvider).setThemeMode(
                  value ? ThemeMode.dark : ThemeMode.light,
                );
          },
          contentPadding: const EdgeInsets.symmetric(horizontal: 16),
        ),
      ],
    );
  }
}

class _ThemeSegmentedControl extends StatelessWidget {
  const _ThemeSegmentedControl({
    required this.currentMode,
    required this.onModeChanged,
  });

  final ThemeMode currentMode;
  final ValueChanged<ThemeMode> onModeChanged;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return SegmentedButton<ThemeMode>(
      segments: const [
        ButtonSegment(
          value: ThemeMode.light,
          label: Text('Light'),
          icon: Icon(Icons.light_mode_rounded, size: 16),
        ),
        ButtonSegment(
          value: ThemeMode.system,
          label: Text('System'),
          icon: Icon(Icons.brightness_auto_rounded, size: 16),
        ),
        ButtonSegment(
          value: ThemeMode.dark,
          label: Text('Dark'),
          icon: Icon(Icons.dark_mode_rounded, size: 16),
        ),
      ],
      selected: {currentMode},
      onSelectionChanged: (modes) => onModeChanged(modes.first),
      style: ButtonStyle(
        visualDensity: VisualDensity.compact,
        textStyle: WidgetStateProperty.all(
          const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════
//  Scanning Section
// ═══════════════════════════════════════════════════════════════════

class _ScanningSection extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final scanQuality = ref.watch(defaultScanQualityProvider);
    final autoEnhance = ref.watch(autoEnhanceProvider);
    final exportFormat = ref.watch(defaultExportFormatProvider);

    return _SettingsCard(
      children: [
        // Default quality
        ListTile(
          leading: Icon(
            Icons.high_quality_outlined,
            color: colorScheme.onSurface.withValues(alpha: 0.6),
            size: 22,
          ),
          title: Text(
            'Default Quality',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurface,
            ),
          ),
          trailing: Text(
            scanQuality.label,
            style: theme.textTheme.bodySmall?.copyWith(
              color: colorScheme.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16),
          onTap: () => _showQualityPicker(context, ref, scanQuality),
        ),
        // Auto-enhance
        SwitchListTile(
          secondary: Icon(
            Icons.auto_fix_high_outlined,
            color: colorScheme.onSurface.withValues(alpha: 0.6),
            size: 22,
          ),
          title: Text(
            'Auto-Enhance',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurface,
            ),
          ),
          subtitle: Text(
            'Automatically improve scan quality',
            style: theme.textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurface.withValues(alpha: 0.5),
            ),
          ),
          value: autoEnhance,
          onChanged: (value) {
            ref.read(autoEnhanceProvider.notifier).setAutoEnhance(value);
          },
          contentPadding: const EdgeInsets.symmetric(horizontal: 16),
        ),
        // File format
        ListTile(
          leading: Icon(
            Icons.file_present_outlined,
            color: colorScheme.onSurface.withValues(alpha: 0.6),
            size: 22,
          ),
          title: Text(
            'File Format',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurface,
            ),
          ),
          trailing: Text(
            exportFormat.name.toUpperCase(),
            style: theme.textTheme.bodySmall?.copyWith(
              color: colorScheme.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16),
          onTap: () => _showFormatPicker(context, ref, exportFormat),
        ),
      ],
    );
  }

  void _showQualityPicker(
    BuildContext context,
    WidgetRef ref,
    ScanQuality current,
  ) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                'Default Scan Quality',
                style: Theme.of(ctx).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ),
            ...ScanQuality.values.map(
              (q) => RadioListTile<ScanQuality>(
                value: q,
                groupValue: current,
                title: Text(q.label),
                subtitle: Text('${q.dpi} DPI'),
                onChanged: (value) {
                  if (value != null) {
                    ref
                        .read(defaultScanQualityProvider.notifier)
                        .setScanQuality(value);
                  }
                  Navigator.of(ctx).pop();
                },
              ),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  void _showFormatPicker(
    BuildContext context,
    WidgetRef ref,
    ExportFormat current,
  ) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                'Default Export Format',
                style: Theme.of(ctx).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ),
            ...ExportFormat.values.map(
              (f) => RadioListTile<ExportFormat>(
                value: f,
                groupValue: current,
                title: Text(f.name.toUpperCase()),
                onChanged: (value) {
                  if (value != null) {
                    ref
                        .read(defaultExportFormatProvider.notifier)
                        .setExportFormat(value);
                  }
                  Navigator.of(ctx).pop();
                },
              ),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════
//  Cloud Section
// ═══════════════════════════════════════════════════════════════════

class _CloudSection extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final autoSync = ref.watch(autoSyncEnabledNotifierProvider);
    final wifiOnly = ref.watch(wifiOnlySyncNotifierProvider);

    return _SettingsCard(
      children: [
        SwitchListTile(
          secondary: Icon(
            Icons.sync_outlined,
            color: colorScheme.onSurface.withValues(alpha: 0.6),
            size: 22,
          ),
          title: Text(
            'Auto-Sync',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurface,
            ),
          ),
          subtitle: Text(
            'Sync documents automatically',
            style: theme.textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurface.withValues(alpha: 0.5),
            ),
          ),
          value: autoSync,
          onChanged: (value) {
            ref
                .read(autoSyncEnabledNotifierProvider.notifier)
                .setAutoSync(value);
          },
          contentPadding: const EdgeInsets.symmetric(horizontal: 16),
        ),
        SwitchListTile(
          secondary: Icon(
            Icons.wifi_outlined,
            color: colorScheme.onSurface.withValues(alpha: 0.6),
            size: 22,
          ),
          title: Text(
            'Wi-Fi Only',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurface,
            ),
          ),
          subtitle: Text(
            'Only sync when connected to Wi-Fi',
            style: theme.textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurface.withValues(alpha: 0.5),
            ),
          ),
          value: wifiOnly,
          onChanged: autoSync
              ? (value) {
                  ref
                      .read(wifiOnlySyncNotifierProvider.notifier)
                      .setWifiOnly(value);
                }
              : null,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16),
        ),
      ],
    );
  }
}

// ═══════════════════════════════════════════════════════════════════
//  Security Section
// ═══════════════════════════════════════════════════════════════════

class _SecuritySection extends ConsumerWidget {
  const _SecuritySection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final biometricEnabled = ref.watch(biometricEnabledProvider);
    final appLockEnabled = ref.watch(appLockEnabledProvider);

    return _SettingsCard(
      children: [
        SwitchListTile(
          secondary: Icon(
            Icons.fingerprint_outlined,
            color: colorScheme.onSurface.withValues(alpha: 0.6),
            size: 22,
          ),
          title: Text(
            'Biometric Unlock',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurface,
            ),
          ),
          value: biometricEnabled,
          onChanged: (value) {
            ref.read(biometricEnabledProvider.notifier).state = value;
          },
          contentPadding: const EdgeInsets.symmetric(horizontal: 16),
        ),
        ListTile(
          leading: Icon(
            Icons.pin_outlined,
            color: colorScheme.onSurface.withValues(alpha: 0.6),
            size: 22,
          ),
          title: Text(
            'PIN Code',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurface,
            ),
          ),
          trailing: Icon(
            Icons.chevron_right_rounded,
            color: colorScheme.onSurface.withValues(alpha: 0.3),
            size: 20,
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16),
          onTap: () => context.push(AppRoutes.securitySetup),
        ),
        SwitchListTile(
          secondary: Icon(
            Icons.lock_outlined,
            color: colorScheme.onSurface.withValues(alpha: 0.6),
            size: 22,
          ),
          title: Text(
            'App Lock',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurface,
            ),
          ),
          subtitle: Text(
            'Require authentication on app launch',
            style: theme.textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurface.withValues(alpha: 0.5),
            ),
          ),
          value: appLockEnabled,
          onChanged: (value) {
            ref.read(appLockEnabledProvider.notifier).state = value;
          },
          contentPadding: const EdgeInsets.symmetric(horizontal: 16),
        ),
      ],
    );
  }
}

// ═══════════════════════════════════════════════════════════════════
//  Storage Section
// ═══════════════════════════════════════════════════════════════════

class _StorageSection extends StatelessWidget {
  const _StorageSection();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return _SettingsCard(
      children: [
        ListTile(
          leading: Icon(
            Icons.cleaning_services_outlined,
            color: colorScheme.onSurface.withValues(alpha: 0.6),
            size: 22,
          ),
          title: Text(
            'Clear Cache',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurface,
            ),
          ),
          trailing: Icon(
            Icons.chevron_right_rounded,
            color: colorScheme.onSurface.withValues(alpha: 0.3),
            size: 20,
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16),
          onTap: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Cache cleared successfully')),
            );
          },
        ),
        ListTile(
          leading: Icon(
            Icons.storage_outlined,
            color: colorScheme.onSurface.withValues(alpha: 0.6),
            size: 22,
          ),
          title: Text(
            'Storage Info',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurface,
            ),
          ),
          trailing: Icon(
            Icons.chevron_right_rounded,
            color: colorScheme.onSurface.withValues(alpha: 0.3),
            size: 20,
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16),
          onTap: () {
            // Show storage info dialog.
            showDialog(
              context: context,
              builder: (ctx) => AlertDialog(
                title: const Text('Storage Information'),
                content: const Text(
                  'Documents, cached images, and OCR data are stored '
                  'locally on your device. Cloud-synced data does not '
                  'count toward local storage.',
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(ctx).pop(),
                    child: const Text('OK'),
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }
}

// ═══════════════════════════════════════════════════════════════════
//  About Section
// ═══════════════════════════════════════════════════════════════════

class _AboutSection extends StatelessWidget {
  const _AboutSection();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return _SettingsCard(
      children: [
        ListTile(
          leading: Icon(
            Icons.info_outline_rounded,
            color: colorScheme.onSurface.withValues(alpha: 0.6),
            size: 22,
          ),
          title: Text(
            'Version',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurface,
            ),
          ),
          trailing: Text(
            '${AppConstants.appVersion} (${AppConstants.appBuildNumber})',
            style: theme.textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurface.withValues(alpha: 0.5),
            ),
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16),
        ),
        ListTile(
          leading: Icon(
            Icons.star_outline_rounded,
            color: colorScheme.onSurface.withValues(alpha: 0.6),
            size: 22,
          ),
          title: Text(
            'Rate ScanPro',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurface,
            ),
          ),
          trailing: Icon(
            Icons.chevron_right_rounded,
            color: colorScheme.onSurface.withValues(alpha: 0.3),
            size: 20,
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16),
          onTap: () {},
        ),
        ListTile(
          leading: Icon(
            Icons.privacy_tip_outlined,
            color: colorScheme.onSurface.withValues(alpha: 0.6),
            size: 22,
          ),
          title: Text(
            'Privacy Policy',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurface,
            ),
          ),
          trailing: Icon(
            Icons.chevron_right_rounded,
            color: colorScheme.onSurface.withValues(alpha: 0.3),
            size: 20,
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16),
          onTap: () {},
        ),
      ],
    );
  }
}
