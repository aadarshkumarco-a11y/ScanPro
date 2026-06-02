import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_constants.dart';
import '../../domain/entities/security_settings.dart';
import '../providers/security_provider.dart';

/// Security settings hub screen.
///
/// Displays toggles for biometric auth, PIN lock, app lock,
/// auto-lock duration, and vault. Each setting is represented
/// as a section with descriptive icons and switch controls.
class SecurityScreen extends ConsumerStatefulWidget {
  const SecurityScreen({super.key});

  @override
  ConsumerState<SecurityScreen> createState() => _SecurityScreenState();
}

class _SecurityScreenState extends ConsumerState<SecurityScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(securityProvider.notifier).loadSettings());
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final securityState = ref.watch(securityProvider);
    final settings = securityState.settings;
    const primaryColor = Color(0xFF4D2DAB);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Security & Privacy'),
        centerTitle: true,
        leading: IconButton(
          onPressed: () => context.pop(),
          icon: const Icon(Icons.arrow_back_rounded),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Header ────────────────────────────────────────────────
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF4D2DAB), Color(0xFF6B4EC0)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.shield_rounded,
                      color: Colors.white,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Protect Your Documents',
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          settings.hasSecuritySetup
                              ? 'Security is enabled'
                              : 'Set up security to protect your data',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: Colors.white.withValues(alpha: 0.85),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // ── PIN Lock ──────────────────────────────────────────────
            _SectionHeader(
              title: 'PIN Lock',
              icon: Icons.lock_outline_rounded,
              color: primaryColor,
            ),
            const SizedBox(height: 8),
            _SettingsCard(
              children: [
                SwitchListTile(
                  secondary: Icon(
                    Icons.dialpad_rounded,
                    color: settings.isPinEnabled ? primaryColor : colorScheme.onSurface.withValues(alpha: 0.4),
                  ),
                  title: const Text('PIN Lock'),
                  subtitle: Text(
                    settings.isPinEnabled
                        ? 'PIN is set up'
                        : 'Set a 6-digit PIN to secure the app',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                  ),
                  value: settings.isPinEnabled,
                  activeColor: primaryColor,
                  onChanged: null, // PIN setup requires a dedicated flow
                ),
                if (!settings.isPinEnabled)
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 4,
                    ),
                    child: SizedBox(
                      width: double.infinity,
                      child: FilledButton.icon(
                        onPressed: () => context.push(
                          AppConstants.securitySetupRoute,
                        ),
                        icon: const Icon(Icons.add_rounded, size: 18),
                        label: const Text('Set Up PIN'),
                        style: FilledButton.styleFrom(
                          backgroundColor: primaryColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                  ),
                if (settings.isPinEnabled)
                  ListTile(
                    leading: const Icon(Icons.edit_rounded),
                    title: const Text('Change PIN'),
                    trailing: const Icon(Icons.chevron_right_rounded),
                    onTap: () => context.push(
                      AppConstants.securitySetupRoute,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 24),

            // ── Biometric ─────────────────────────────────────────────
            _SectionHeader(
              title: 'Biometric',
              icon: Icons.fingerprint_rounded,
              color: primaryColor,
            ),
            const SizedBox(height: 8),
            _SettingsCard(
              children: [
                SwitchListTile(
                  secondary: Icon(
                    Icons.fingerprint_rounded,
                    color: settings.isBiometricEnabled ? primaryColor : colorScheme.onSurface.withValues(alpha: 0.4),
                  ),
                  title: const Text('Biometric Login'),
                  subtitle: Text(
                    settings.isBiometricEnabled
                        ? 'Use fingerprint or face to unlock'
                        : 'Enable fingerprint or face recognition',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                  ),
                  value: settings.isBiometricEnabled,
                  activeColor: primaryColor,
                  onChanged: settings.isPinEnabled
                      ? (value) async {
                          await ref
                              .read(securityProvider.notifier)
                              .toggleBiometric(value);
                        }
                      : null,
                ),
                if (!settings.isPinEnabled)
                  Padding(
                    padding: const EdgeInsets.only(left: 16, right: 16, bottom: 12),
                    child: Text(
                      'Set up a PIN first to enable biometric login',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colorScheme.error.withValues(alpha: 0.8),
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 24),

            // ── App Lock ──────────────────────────────────────────────
            _SectionHeader(
              title: 'App Lock',
              icon: Icons.lock_clock_rounded,
              color: primaryColor,
            ),
            const SizedBox(height: 8),
            _SettingsCard(
              children: [
                SwitchListTile(
                  secondary: Icon(
                    Icons.lock_clock_rounded,
                    color: settings.isAppLockEnabled ? primaryColor : colorScheme.onSurface.withValues(alpha: 0.4),
                  ),
                  title: const Text('Auto-Lock'),
                  subtitle: Text(
                    settings.isAppLockEnabled
                        ? 'App locks when sent to background'
                        : 'Lock app when sent to background',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                  ),
                  value: settings.isAppLockEnabled,
                  activeColor: primaryColor,
                  onChanged: settings.hasSecuritySetup
                      ? (value) async {
                          await ref
                              .read(securityProvider.notifier)
                              .toggleAppLock(value);
                        }
                      : null,
                ),
                if (settings.isAppLockEnabled) ...[
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.timer_outlined),
                    title: const Text('Auto-Lock After'),
                    trailing: _AutoLockDropdown(
                      currentDuration: settings.autoLockDuration,
                      onChanged: (duration) async {
                        await ref
                            .read(securityProvider.notifier)
                            .updateAutoLockDuration(duration);
                      },
                    ),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 24),

            // ── Vault ─────────────────────────────────────────────────
            _SectionHeader(
              title: 'Secure Vault',
              icon: Icons.folder_special_rounded,
              color: primaryColor,
            ),
            const SizedBox(height: 8),
            _SettingsCard(
              children: [
                SwitchListTile(
                  secondary: Icon(
                    Icons.folder_special_rounded,
                    color: settings.isVaultEnabled ? primaryColor : colorScheme.onSurface.withValues(alpha: 0.4),
                  ),
                  title: const Text('Document Vault'),
                  subtitle: Text(
                    settings.isVaultEnabled
                        ? 'AES-256 encryption enabled for locked documents'
                        : 'Encrypt sensitive documents with AES-256',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                  ),
                  value: settings.isVaultEnabled,
                  activeColor: primaryColor,
                  onChanged: settings.isPinEnabled
                      ? (value) async {
                          await ref
                              .read(securityProvider.notifier)
                              .toggleVault(value);
                        }
                      : null,
                ),
              ],
            ),
            const SizedBox(height: 24),

            // ── Error Display ─────────────────────────────────────────
            if (securityState.errorMessage != null) ...[
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: colorScheme.errorContainer,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.error_outline_rounded,
                      color: colorScheme.error,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        securityState.errorMessage!,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colorScheme.onErrorContainer,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () =>
                          ref.read(securityProvider.notifier).clearError(),
                      icon: Icon(
                        Icons.close_rounded,
                        color: colorScheme.onErrorContainer,
                        size: 18,
                      ),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],

            // ── Info ──────────────────────────────────────────────────
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.info_outline_rounded,
                    color: colorScheme.onSurface.withValues(alpha: 0.5),
                    size: 18,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'All security data is stored locally using '
                      'AES-256 encryption. ScanPro never sends your '
                      'PIN or biometric data to external servers.',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurface.withValues(alpha: 0.5),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════
//  Helper Widgets
// ═══════════════════════════════════════════════════════════════════════

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({
    required this.title,
    required this.icon,
    required this.color,
  });

  final String title;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Icon(icon, size: 20, color: color),
        const SizedBox(width: 8),
        Text(
          title,
          style: theme.textTheme.titleSmall?.copyWith(
            color: color,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

class _SettingsCard extends StatelessWidget {
  const _SettingsCard({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(children: children),
    );
  }
}

class _AutoLockDropdown extends StatelessWidget {
  const _AutoLockDropdown({
    required this.currentDuration,
    required this.onChanged,
  });

  final Duration currentDuration;
  final ValueChanged<Duration> onChanged;

  static const _options = [
    (Duration(minutes: 1), '1 minute'),
    (Duration(minutes: 2), '2 minutes'),
    (Duration(minutes: 5), '5 minutes'),
    (Duration(minutes: 10), '10 minutes'),
    (Duration(minutes: 15), '15 minutes'),
    (Duration(minutes: 30), '30 minutes'),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return DropdownButton<Duration>(
      value: _options.any((o) => o.$1 == currentDuration)
          ? currentDuration
          : const Duration(minutes: 5),
      items: _options
          .map((o) => DropdownMenuItem(
                value: o.$1,
                child: Text(
                  o.$2,
                  style: theme.textTheme.bodySmall,
                ),
              ))
          .toList(),
      onChanged: (value) {
        if (value != null) onChanged(value);
      },
      underline: const SizedBox.shrink(),
      isDense: true,
    );
  }
}
