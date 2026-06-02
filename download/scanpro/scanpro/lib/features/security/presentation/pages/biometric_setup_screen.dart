import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../providers/security_provider.dart';

class BiometricSetupScreen extends ConsumerStatefulWidget {
  const BiometricSetupScreen({super.key});

  @override
  ConsumerState<BiometricSetupScreen> createState() =>
      _BiometricSetupScreenState();
}

class _BiometricSetupScreenState extends ConsumerState<BiometricSetupScreen> {
  bool _isTesting = false;
  bool _testSuccess = false;

  Future<void> _testBiometric() async {
    setState(() {
      _isTesting = true;
      _testSuccess = false;
    });
    await ref.read(biometricProvider.notifier).authenticate();
    final state = ref.read(biometricProvider);
    setState(() {
      _isTesting = false;
      _testSuccess = !state.isAuthenticating;
    });
    if (mounted && _testSuccess) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Biometric authentication successful!'),
          backgroundColor: Theme.of(context).colorScheme.primary,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final bioState = ref.watch(biometricProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Biometric Setup'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (!bioState.isAvailable) ...[
            _buildUnavailableCard(theme),
          ] else ...[
            _buildAvailabilityCard(theme, bioState),
            const SizedBox(height: 24),
            _buildFingerprintSection(theme, bioState),
            if (bioState.faceUnlockAvailable) ...[
              const SizedBox(height: 16),
              _buildFaceUnlockSection(theme, bioState),
            ],
            const SizedBox(height: 24),
            _buildTestButton(theme),
          ],
        ],
      ),
    );
  }

  Widget _buildUnavailableCard(ThemeData theme) {
    return Card(
      color: theme.colorScheme.errorContainer,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Icon(
              Icons.fingerprint,
              size: 48,
              color: theme.colorScheme.onErrorContainer,
            ),
            const SizedBox(height: 12),
            Text(
              'Biometrics Not Available',
              style: theme.textTheme.titleMedium?.copyWith(
                color: theme.colorScheme.onErrorContainer,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Your device does not support biometric authentication, '
              'or no biometrics are enrolled. Please set up fingerprint '
              'or face recognition in your device settings.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onErrorContainer,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    ).animate().fadeIn(duration: 400.ms);
  }

  Widget _buildAvailabilityCard(ThemeData theme, BiometricState bioState) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Icon(
              Icons.verified_user,
              size: 48,
              color: theme.colorScheme.primary,
            ),
            const SizedBox(height: 12),
            Text(
              'Biometrics Available',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Your device supports biometric authentication. '
              'Enable the methods you prefer below.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    ).animate().fadeIn(duration: 400.ms);
  }

  Widget _buildFingerprintSection(ThemeData theme, BiometricState bioState) {
    return Card(
      child: SwitchListTile(
        secondary: Icon(
          Icons.fingerprint,
          color: theme.colorScheme.primary,
          size: 32,
        ),
        title: const Text('Fingerprint Unlock'),
        subtitle: const Text('Use your fingerprint to unlock the app'),
        value: bioState.isEnabled,
        onChanged: (value) {
          ref.read(biometricProvider.notifier).toggleFingerprint(value);
        },
      ),
    );
  }

  Widget _buildFaceUnlockSection(ThemeData theme, BiometricState bioState) {
    return Card(
      child: SwitchListTile(
        secondary: Icon(
          Icons.face,
          color: theme.colorScheme.primary,
          size: 32,
        ),
        title: const Text('Face Unlock'),
        subtitle: const Text('Use face recognition to unlock the app'),
        value: bioState.faceUnlockEnabled,
        onChanged: (value) {
          ref.read(biometricProvider.notifier).toggleFaceUnlock(value);
        },
      ),
    );
  }

  Widget _buildTestButton(ThemeData theme) {
    return FilledButton.icon(
      onPressed: bioState.isEnabled || bioState.faceUnlockEnabled
          ? _isTesting
              ? null
              : _testBiometric
          : null,
      icon: _isTesting
          ? SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: theme.colorScheme.onPrimary,
              ),
            )
          : const Icon(Icons.fingerprint),
      label: Text(_isTesting ? 'Authenticating...' : 'Test Biometric'),
    ).animate().fadeIn(duration: 400.ms, delay: 200.ms);
  }
}
