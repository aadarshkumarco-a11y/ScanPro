import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../providers/security_provider.dart';
import '../widgets/pin_dot.dart';
import '../widgets/number_pad.dart';

class PinSetupScreen extends ConsumerStatefulWidget {
  const PinSetupScreen({super.key});

  @override
  ConsumerState<PinSetupScreen> createState() => _PinSetupScreenState();
}

class _PinSetupScreenState extends ConsumerState<PinSetupScreen> {
  String _enteredPin = '';
  String _firstPin = '';
  bool _isConfirming = false;
  bool _isComplete = false;

  void _onDigitPressed(String digit) {
    if (_enteredPin.length >= 6) return;
    setState(() {
      _enteredPin += digit;
    });
    if (_enteredPin.length == 6) {
      _handlePinComplete();
    }
  }

  void _onBackspace() {
    if (_enteredPin.isEmpty) return;
    setState(() {
      _enteredPin = _enteredPin.substring(0, _enteredPin.length - 1);
    });
  }

  void _handlePinComplete() {
    if (!_isConfirming) {
      setState(() {
        _firstPin = _enteredPin;
        _enteredPin = '';
        _isConfirming = true;
      });
    } else {
      if (_enteredPin == _firstPin) {
        ref.read(pinProvider.notifier).addDigit('');
        setState(() => _isComplete = true);
        _showSuccessDialog();
      } else {
        setState(() {
          _enteredPin = '';
          _firstPin = '';
          _isConfirming = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('PINs do not match. Please try again.'),
            backgroundColor: Theme.of(context).colorScheme.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        icon: Icon(
          Icons.check_circle,
          color: Theme.of(context).colorScheme.primary,
          size: 48,
        ),
        title: const Text('PIN Set Successfully'),
        content: const Text(
          'Your PIN has been set. You can use it to unlock the app.',
        ),
        actions: [
          FilledButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pop();
            },
            child: const Text('Done'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text('Set Up PIN'),
      ),
      body: SafeArea(
        child: Column(
          children: [
            const Spacer(flex: 1),
            Text(
              _isConfirming ? 'Confirm your PIN' : 'Create a 6-digit PIN',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ).animate().fadeIn(duration: 300.ms),
            const SizedBox(height: 8),
            Text(
              _isConfirming
                  ? 'Re-enter the PIN to confirm'
                  : 'This PIN will be used to unlock ScanPro',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 40),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                6,
                (index) => Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: PinDot(isFilled: index < _enteredPin.length),
                ),
              ),
            ),
            const Spacer(flex: 1),
            NumberPad(
              onDigitPressed: _onDigitPressed,
              onBackspace: _onBackspace,
            ).animate().fadeIn(duration: 400.ms),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}
