import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_constants.dart';
import '../providers/security_provider.dart';

/// Lock screen displayed when the app requires authentication.
///
/// Supports both biometric (fingerprint/face) and PIN verification.
/// Shows a PIN entry pad with 6-dot indicator, plus a biometric
/// button if enabled.
class SecurityVerifyScreen extends ConsumerStatefulWidget {
  const SecurityVerifyScreen({super.key});

  @override
  ConsumerState<SecurityVerifyScreen> createState() =>
      _SecurityVerifyScreenState();
}

class _SecurityVerifyScreenState extends ConsumerState<SecurityVerifyScreen>
    with SingleTickerProviderStateMixin {
  String _enteredPin = '';
  String? _errorMessage;
  bool _isShaking = false;
  bool _isBiometricAvailable = false;

  static const Color _primaryColor = Color(0xFF4D2DAB);

  late AnimationController _shakeController;
  late Animation<double> _shakeAnimation;

  @override
  void initState() {
    super.initState();
    _shakeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _shakeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _shakeController, curve: Curves.elasticIn),
    );
    _checkBiometric();
  }

  @override
  void dispose() {
    _shakeController.dispose();
    super.dispose();
  }

  Future<void> _checkBiometric() async {
    final settings = ref.read(securityProvider).settings;
    if (settings.isBiometricEnabled) {
      // Try biometric auth on first display.
      final success = await ref
          .read(securityProvider.notifier)
          .authenticateBiometric();
      if (success && mounted) {
        await _onUnlockSuccess();
      }
      if (mounted) {
        setState(() {
          _isBiometricAvailable = true;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final securityState = ref.watch(securityProvider);
    final settings = securityState.settings;

    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: colorScheme.surface,
        body: SafeArea(
          child: Column(
            children: [
              const Spacer(flex: 1),

              // ── App Icon ────────────────────────────────────────────
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: _primaryColor.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.document_scanner_rounded,
                  color: _primaryColor,
                  size: 56,
                ),
              ),
              const SizedBox(height: 24),

              // ── Title ───────────────────────────────────────────────
              Text(
                AppConstants.appName,
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: _primaryColor,
                ),
              ),
              const SizedBox(height: 8),

              Text(
                settings.isBiometricEnabled
                    ? 'Use PIN or biometric to unlock'
                    : 'Enter your PIN to unlock',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurface.withValues(alpha: 0.6),
                ),
              ),
              const SizedBox(height: 32),

              // ── PIN Dots (with shake) ───────────────────────────────
              AnimatedBuilder(
                animation: _shakeAnimation,
                builder: (context, child) {
                  final offset = _isShaking
                      ? _shakeAnimation.value *
                          10 *
                          ((_shakeAnimation.value * 4).round() % 2 == 0
                              ? 1
                              : -1)
                      : 0.0;
                  return Transform.translate(
                    offset: Offset(offset, 0),
                    child: child,
                  );
                },
                child: _PinDots(
                  length: _enteredPin.length,
                  total: AppConstants.pinLength,
                  primaryColor: _primaryColor,
                  hasError: _errorMessage != null,
                ),
              ),
              const SizedBox(height: 8),

              // ── Error Message ───────────────────────────────────────
              SizedBox(
                height: 20,
                child: _errorMessage != null
                    ? Text(
                        _errorMessage!,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colorScheme.error,
                          fontWeight: FontWeight.w500,
                        ),
                      )
                    : null,
              ),

              const Spacer(flex: 1),

              // ── Number Pad ──────────────────────────────────────────
              _NumberPad(
                onDigit: _onDigit,
                onBackspace: _onBackspace,
                onBiometric: _isBiometricAvailable ? _onBiometric : null,
                showBiometric: _isBiometricAvailable,
                primaryColor: _primaryColor,
              ),

              // ── Forgot PIN ──────────────────────────────────────────
              TextButton(
                onPressed: _onForgotPin,
                child: Text(
                  'Forgot PIN?',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: _primaryColor,
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  /// Handles a digit press.
  void _onDigit(String digit) {
    if (_enteredPin.length >= AppConstants.pinLength) return;

    setState(() {
      _errorMessage = null;
      _enteredPin += digit;
    });

    if (_enteredPin.length == AppConstants.pinLength) {
      _verifyPin();
    }
  }

  /// Handles backspace.
  void _onBackspace() {
    if (_enteredPin.isEmpty) return;
    setState(() {
      _errorMessage = null;
      _enteredPin = _enteredPin.substring(0, _enteredPin.length - 1);
    });
  }

  /// Verifies the entered PIN.
  Future<void> _verifyPin() async {
    final isCorrect = await ref
        .read(securityProvider.notifier)
        .verifyPin(_enteredPin);

    if (isCorrect) {
      await _onUnlockSuccess();
    } else {
      _onPinError();
    }
  }

  /// Handles successful unlock.
  Future<void> _onUnlockSuccess() async {
    await ref.read(securityProvider.notifier).unlockApp();
    if (mounted) {
      context.go(AppConstants.homeRoute);
    }
  }

  /// Handles PIN error with shake animation.
  void _onPinError() {
    final state = ref.read(securityProvider);
    final remaining = AppConstants.maxPinAttempts -
        state.failedPinAttempts;

    setState(() {
      _isShaking = true;
      _errorMessage = remaining > 0
          ? 'Incorrect PIN. $remaining attempt${remaining == 1 ? '' : 's'} remaining.'
          : 'Too many failed attempts. Please try again later.';
      _enteredPin = '';
    });

    _shakeController.forward(from: 0).then((_) {
      if (mounted) {
        setState(() {
          _isShaking = false;
        });
      }
    });
  }

  /// Handles biometric button press.
  Future<void> _onBiometric() async {
    final success = await ref
        .read(securityProvider.notifier)
        .authenticateBiometric();

    if (success) {
      await _onUnlockSuccess();
    } else {
      setState(() {
        _errorMessage = 'Biometric authentication failed';
      });
    }
  }

  /// Handles "Forgot PIN" press.
  void _onForgotPin() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Forgot PIN?'),
        content: const Text(
          'To reset your PIN, you will need to clear all app data. '
          'This will delete all locally stored documents and settings. '
          'Cloud-synced documents can be recovered after re-signing in.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              // In production, this would trigger a data reset.
            },
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Reset App'),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════
//  PIN Dots
// ═══════════════════════════════════════════════════════════════════════

class _PinDots extends StatelessWidget {
  const _PinDots({
    required this.length,
    required this.total,
    required this.primaryColor,
    this.hasError = false,
  });

  final int length;
  final int total;
  final Color primaryColor;
  final bool hasError;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(total, (index) {
        final isFilled = index < length;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: const EdgeInsets.symmetric(horizontal: 10),
          width: 18,
          height: 18,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: hasError
                ? Theme.of(context).colorScheme.error
                : isFilled
                    ? primaryColor
                    : Colors.transparent,
            border: Border.all(
              color: hasError
                  ? Theme.of(context).colorScheme.error
                  : isFilled
                      ? primaryColor
                      : primaryColor.withValues(alpha: 0.3),
              width: 2,
            ),
          ),
        );
      }),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════
//  Number Pad
// ═══════════════════════════════════════════════════════════════════════

class _NumberPad extends StatelessWidget {
  const _NumberPad({
    required this.onDigit,
    required this.onBackspace,
    required this.primaryColor,
    this.onBiometric,
    this.showBiometric = false,
  });

  final ValueChanged<String> onDigit;
  final VoidCallback onBackspace;
  final VoidCallback? onBiometric;
  final bool showBiometric;
  final Color primaryColor;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildRow(['1', '2', '3']),
          const SizedBox(height: 12),
          _buildRow(['4', '5', '6']),
          const SizedBox(height: 12),
          _buildRow(['7', '8', '9']),
          const SizedBox(height: 12),
          _buildBottomRow(),
        ],
      ),
    );
  }

  Widget _buildRow(List<String> digits) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: digits.map((d) => _DigitButton(
            digit: d,
            onTap: () => onDigit(d),
            primaryColor: primaryColor,
          )).toList(),
    );
  }

  Widget _buildBottomRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        if (showBiometric && onBiometric != null)
          _ActionButton(
            icon: Icons.fingerprint_rounded,
            onTap: onBiometric!,
            primaryColor: primaryColor,
          )
        else
          const SizedBox(width: 72, height: 72),
        _DigitButton(
          digit: '0',
          onTap: () => onDigit('0'),
          primaryColor: primaryColor,
        ),
        _ActionButton(
          icon: Icons.backspace_outlined,
          onTap: onBackspace,
          primaryColor: primaryColor,
        ),
      ],
    );
  }
}

class _DigitButton extends StatelessWidget {
  const _DigitButton({
    required this.digit,
    required this.onTap,
    required this.primaryColor,
  });

  final String digit;
  final VoidCallback onTap;
  final Color primaryColor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(36),
        child: Container(
          width: 72,
          height: 72,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: primaryColor.withValues(alpha: 0.2),
              width: 1.5,
            ),
          ),
          child: Center(
            child: Text(
              digit,
              style: theme.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.w500,
                color: primaryColor,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.icon,
    required this.onTap,
    required this.primaryColor,
  });

  final IconData icon;
  final VoidCallback onTap;
  final Color primaryColor;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(36),
        child: SizedBox(
          width: 72,
          height: 72,
          child: Icon(
            icon,
            color: primaryColor.withValues(alpha: 0.6),
            size: 28,
          ),
        ),
      ),
    );
  }
}
