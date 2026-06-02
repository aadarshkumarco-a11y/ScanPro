import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_constants.dart';
import '../providers/security_provider.dart';

/// PIN setup screen with 6-digit input, confirmation step,
/// and strength indicator.
///
/// The flow is:
/// 1. User enters a 6-digit PIN.
/// 2. User re-enters the PIN for confirmation.
/// 3. If both match, the PIN is stored securely.
class PinSetupScreen extends ConsumerStatefulWidget {
  const PinSetupScreen({super.key});

  @override
  ConsumerState<PinSetupScreen> createState() => _PinSetupScreenState();
}

class _PinSetupScreenState extends ConsumerState<PinSetupScreen> {
  /// The PIN entered in step 1.
  String _firstPin = '';

  /// The PIN entered in step 2 (confirmation).
  String _confirmPin = '';

  /// Whether we are on the confirmation step.
  bool _isConfirmStep = false;

  /// Whether the PINs matched (for success animation).
  bool _isSuccess = false;

  /// Local error message.
  String? _errorMessage;

  static const Color _primaryColor = Color(0xFF4D2DAB);

  /// The current PIN being built.
  String get _currentPin => _isConfirmStep ? _confirmPin : _firstPin;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(_isConfirmStep ? 'Confirm PIN' : 'Set Up PIN'),
        centerTitle: true,
        leading: IconButton(
          onPressed: () {
            if (_isConfirmStep) {
              setState(() {
                _isConfirmStep = false;
                _confirmPin = '';
                _errorMessage = null;
              });
            } else {
              context.pop();
            }
          },
          icon: const Icon(Icons.arrow_back_rounded),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            const Spacer(flex: 1),

            // ── Icon & Title ──────────────────────────────────────────
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: _isSuccess
                  ? Container(
                      key: const ValueKey('success'),
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.green.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.check_circle_rounded,
                        color: Colors.green,
                        size: 64,
                      ),
                    )
                  : Container(
                      key: const ValueKey('lock'),
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: _primaryColor.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        _isConfirmStep
                            ? Icons.lock_clock_rounded
                            : Icons.lock_outline_rounded,
                        color: _primaryColor,
                        size: 64,
                      ),
                    ),
            ),
            const SizedBox(height: 24),

            // ── Step Indicator ────────────────────────────────────────
            Text(
              _isSuccess
                  ? 'PIN Set Up Successfully!'
                  : _isConfirmStep
                      ? 'Re-enter your PIN to confirm'
                      : 'Enter a 6-digit PIN',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),

            Text(
              _isSuccess
                  ? 'Your documents are now protected'
                  : _isConfirmStep
                      ? 'Make sure it matches your first entry'
                      : 'Choose a strong PIN that isn\'t easy to guess',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurface.withValues(alpha: 0.6),
              ),
            ),
            const SizedBox(height: 32),

            // ── PIN Dots ──────────────────────────────────────────────
            _PinDots(
              length: _currentPin.length,
              total: AppConstants.pinLength,
              primaryColor: _primaryColor,
              hasError: _errorMessage != null,
            ),
            const SizedBox(height: 8),

            // ── Strength Indicator (step 1 only) ──────────────────────
            if (!_isConfirmStep && _firstPin.isNotEmpty) ...[
              const SizedBox(height: 8),
              _PinStrengthIndicator(
                pin: _firstPin,
                primaryColor: _primaryColor,
              ),
            ],

            // ── Error Message ─────────────────────────────────────────
            if (_errorMessage != null) ...[
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Text(
                  _errorMessage!,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.error,
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ],

            const Spacer(flex: 1),

            // ── Number Pad ────────────────────────────────────────────
            _NumberPad(
              onDigit: _onDigit,
              onBackspace: _onBackspace,
              onBiometric: null, // Not available during setup
              showBiometric: false,
              primaryColor: _primaryColor,
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  /// Handles a digit press.
  void _onDigit(String digit) {
    if (_isSuccess) return;
    if (_currentPin.length >= AppConstants.pinLength) return;

    setState(() {
      _errorMessage = null;
      if (_isConfirmStep) {
        _confirmPin += digit;
      } else {
        _firstPin += digit;
      }
    });

    // Auto-advance when PIN is complete.
    if (_currentPin.length == AppConstants.pinLength) {
      _onPinComplete();
    }
  }

  /// Handles backspace press.
  void _onBackspace() {
    if (_isSuccess) return;
    if (_currentPin.isEmpty) return;

    setState(() {
      _errorMessage = null;
      if (_isConfirmStep) {
        _confirmPin = _confirmPin.substring(0, _confirmPin.length - 1);
      } else {
        _firstPin = _firstPin.substring(0, _firstPin.length - 1);
      }
    });
  }

  /// Called when the user has entered all 6 digits.
  Future<void> _onPinComplete() async {
    if (!_isConfirmStep) {
      // Move to confirmation step.
      await Future.delayed(const Duration(milliseconds: 200));
      if (mounted) {
        setState(() {
          _isConfirmStep = true;
        });
      }
    } else {
      // Validate that both PINs match.
      if (_confirmPin != _firstPin) {
        setState(() {
          _errorMessage = 'PINs don\'t match. Please try again.';
          _confirmPin = '';
        });
        return;
      }

      // Attempt to set the PIN.
      final success = await ref
          .read(securityProvider.notifier)
          .setupPin(_firstPin);

      if (success && mounted) {
        setState(() {
          _isSuccess = true;
        });
        await Future.delayed(const Duration(milliseconds: 1500));
        if (mounted) {
          context.pop();
        }
      } else if (mounted) {
        // The use case may have rejected the PIN (trivial pattern, etc.).
        final error =
            ref.read(securityProvider).errorMessage ?? 'Failed to set PIN';
        setState(() {
          _errorMessage = error;
          _firstPin = '';
          _confirmPin = '';
          _isConfirmStep = false;
        });
      }
    }
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
          margin: const EdgeInsets.symmetric(horizontal: 8),
          width: 16,
          height: 16,
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
//  PIN Strength Indicator
// ═══════════════════════════════════════════════════════════════════════

class _PinStrengthIndicator extends StatelessWidget {
  const _PinStrengthIndicator({
    required this.pin,
    required this.primaryColor,
  });

  final String pin;
  final Color primaryColor;

  /// Calculates PIN strength (0.0 to 1.0).
  double get _strength {
    if (pin.length < 4) return 0.2;

    double score = 0.4; // base for having 4+ digits

    // Check for variety of digits.
    final uniqueDigits = pin.split('').toSet().length;
    if (uniqueDigits >= 4) score += 0.2;
    if (uniqueDigits >= 5) score += 0.15;

    // Check for non-sequential patterns.
    bool isSequential = true;
    for (int i = 1; i < pin.length; i++) {
      final diff = int.parse(pin[i]) - int.parse(pin[i - 1]);
      if (diff != 1 && diff != -1) {
        isSequential = false;
        break;
      }
    }
    if (!isSequential) score += 0.15;

    // Check for non-repeating.
    if (!pin.split('').every((c) => c == pin[0])) score += 0.1;

    return score.clamp(0.0, 1.0);
  }

  String get _strengthLabel {
    if (_strength < 0.4) return 'Weak';
    if (_strength < 0.7) return 'Fair';
    return 'Strong';
  }

  Color get _strengthColor {
    if (_strength < 0.4) return Colors.red;
    if (_strength < 0.7) return Colors.orange;
    return Colors.green;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 48),
      child: Column(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: _strength,
              backgroundColor: colorScheme.surfaceContainerHighest,
              valueColor: AlwaysStoppedAnimation(_strengthColor),
              minHeight: 4,
            ),
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Strength:',
                style: theme.textTheme.labelSmall?.copyWith(
                  color: colorScheme.onSurface.withValues(alpha: 0.5),
                ),
              ),
              Text(
                _strengthLabel,
                style: theme.textTheme.labelSmall?.copyWith(
                  color: _strengthColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  ColorScheme get colorScheme => Theme.of(ctx).colorScheme;
  BuildContext get ctx => WidgetsBinding.instance.renderViewElement ?? (throw StateError('No context'));
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
        // Left slot: biometric or empty
        if (showBiometric && onBiometric != null)
          _ActionButton(
            icon: Icons.fingerprint_rounded,
            onTap: onBiometric!,
            primaryColor: primaryColor,
          )
        else
          const SizedBox(width: 72, height: 72),

        // Center: 0
        _DigitButton(
          digit: '0',
          onTap: () => onDigit('0'),
          primaryColor: primaryColor,
        ),

        // Right: backspace
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
