import 'package:flutter/material.dart';

class NumberPad extends StatelessWidget {
  final void Function(String digit) onDigitPressed;
  final VoidCallback onBackspace;
  final VoidCallback? onBiometricPressed;

  const NumberPad({
    super.key,
    required this.onDigitPressed,
    required this.onBackspace,
    this.onBiometricPressed,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildRow(context, ['1', '2', '3']),
        const SizedBox(height: 8),
        _buildRow(context, ['4', '5', '6']),
        const SizedBox(height: 8),
        _buildRow(context, ['7', '8', '9']),
        const SizedBox(height: 8),
        _buildBottomRow(context, theme),
      ],
    );
  }

  Widget _buildRow(BuildContext context, List<String> digits) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: digits.map((digit) => _buildDigitButton(context, digit)).toList(),
    );
  }

  Widget _buildBottomRow(BuildContext context, ThemeData theme) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        onBiometricPressed != null
            ? _buildActionButton(
                context,
                icon: Icons.fingerprint,
                onTap: onBiometricPressed!,
                color: theme.colorScheme.primary,
              )
            : const SizedBox(width: 72, height: 72),
        _buildDigitButton(context, '0'),
        _buildActionButton(
          context,
          icon: Icons.backspace_outlined,
          onTap: onBackspace,
          color: theme.colorScheme.onSurfaceVariant,
        ),
      ],
    );
  }

  Widget _buildDigitButton(BuildContext context, String digit) {
    final theme = Theme.of(context);

    return SizedBox(
      width: 72,
      height: 72,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => onDigitPressed(digit),
          customBorder: const CircleBorder(),
          child: Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: theme.colorScheme.outlineVariant,
                width: 1,
              ),
            ),
            child: Center(
              child: Text(
                digit,
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w500,
                  color: theme.colorScheme.onSurface,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActionButton(
    BuildContext context, {
    required IconData icon,
    required VoidCallback onTap,
    required Color color,
  }) {
    return SizedBox(
      width: 72,
      height: 72,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          customBorder: const CircleBorder(),
          child: Center(
            child: Icon(icon, color: color, size: 28),
          ),
        ),
      ),
    );
  }
}
