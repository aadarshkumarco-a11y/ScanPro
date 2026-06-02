import 'package:flutter/material.dart';

class PinDot extends StatelessWidget {
  final bool isFilled;
  final double size;
  final Color? filledColor;
  final Color? emptyColor;

  const PinDot({
    super.key,
    required this.isFilled,
    this.size = 16,
    this.filledColor,
    this.emptyColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final filled = filledColor ?? theme.colorScheme.primary;
    final empty = emptyColor ?? theme.colorScheme.outlineVariant;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isFilled ? filled : Colors.transparent,
        border: Border.all(
          color: isFilled ? filled : empty,
          width: 2,
        ),
      ),
    );
  }
}
