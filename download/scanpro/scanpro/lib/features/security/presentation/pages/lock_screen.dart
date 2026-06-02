import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../providers/security_provider.dart';
import '../widgets/pin_dot.dart';
import '../widgets/number_pad.dart';

class LockScreen extends ConsumerStatefulWidget {
  const LockScreen({super.key});

  @override
  ConsumerState<LockScreen> createState() => _LockScreenState();
}

class _LockScreenState extends ConsumerState<LockScreen> {
  String _enteredPin = '';
  bool _isShaking = false;

  void _onDigitPressed(String digit) {
    if (_enteredPin.length >= 6) return;
    setState(() {
      _enteredPin += digit;
    });
    if (_enteredPin.length == 6) {
      _verifyPin();
    }
  }

  void _onBackspace() {
    if (_enteredPin.isEmpty) return;
    setState(() {
      _enteredPin = _enteredPin.substring(0, _enteredPin.length - 1);
    });
  }

  Future<void> _verifyPin() async {
    ref.read(lockStateProvider.notifier).startAuthentication();
    await Future.delayed(const Duration(milliseconds: 300));
    if (_enteredPin == '123456') {
      ref.read(lockStateProvider.notifier).unlock();
    } else {
      ref.read(lockStateProvider.notifier).authenticationFailed();
      setState(() {
        _isShaking = true;
        _enteredPin = '';
      });
      await Future.delayed(const Duration(milliseconds: 600));
      setState(() => _isShaking = false);
    }
  }

  Future<void> _authenticateBiometric() async {
    await ref.read(biometricProvider.notifier).authenticate();
    ref.read(lockStateProvider.notifier).unlock();
  }

  @override
  Widget build(BuildContext context) {
    final lockState = ref.watch(lockStateProvider);
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: SafeArea(
        child: Column(
          children: [
            const Spacer(flex: 2),
            Icon(
              Icons.document_scanner,
              size: 64,
              color: theme.colorScheme.primary,
            )
                .animate()
                .fadeIn(duration: 600.ms)
                .scale(begin: const Offset(0.5, 0.5), end: const Offset(1, 1)),
            const SizedBox(height: 16),
            Text(
              'ScanPro',
              style: theme.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.primary,
              ),
            ).animate().fadeIn(duration: 600.ms, delay: 200.ms),
            const SizedBox(height: 8),
            Text(
              'Enter your PIN to unlock',
              style: theme.textTheme.bodyLarge?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ).animate().fadeIn(duration: 600.ms, delay: 300.ms),
            if (lockState.errorMessage.isNotEmpty) ...[
              const SizedBox(height: 12),
              Text(
                lockState.errorMessage,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.error,
                ),
              ).animate().shake(duration: 500.ms),
            ],
            const SizedBox(height: 40),
            _buildPinDots(theme),
            const Spacer(flex: 1),
            NumberPad(
              onDigitPressed: _onDigitPressed,
              onBackspace: _onBackspace,
              onBiometricPressed:
                  ref.watch(biometricProvider).isAvailable
                      ? _authenticateBiometric
                      : null,
            ).animate().fadeIn(duration: 400.ms, delay: 500.ms),
            const SizedBox(height: 16),
            TextButton(
              onPressed: () {},
              child: Text(
                'Forgot PIN?',
                style: TextStyle(color: theme.colorScheme.primary),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildPinDots(ThemeData theme) {
    final dotsWidget = Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        6,
        (index) => Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: PinDot(isFilled: index < _enteredPin.length),
        ),
      ),
    );

    if (_isShaking) {
      return dotsWidget.animate().shake(
            hz: 8,
            offset: const Offset(10, 0),
            duration: 500.ms,
          );
    }
    return dotsWidget.animate().fadeIn(duration: 400.ms, delay: 400.ms);
  }
}
