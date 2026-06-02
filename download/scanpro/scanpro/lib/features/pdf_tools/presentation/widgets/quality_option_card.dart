import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:scanpro/features/pdf_tools/presentation/providers/pdf_provider.dart';

class QualityOptionCard extends StatelessWidget {
  final CompressionQuality quality;
  final String label;
  final String description;
  final String detail;
  final String reductionEstimate;
  final bool isSelected;
  final VoidCallback onTap;

  const QualityOptionCard({
    super.key,
    required this.quality,
    required this.label,
    required this.description,
    required this.detail,
    required this.reductionEstimate,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primaryColor = const Color(0xFF4D2DAB);

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected
              ? primaryColor.withOpacity(0.08)
              : theme.colorScheme.surfaceContainerLow,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? primaryColor : theme.colorScheme.outlineVariant,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected
              ? [BoxShadow(color: primaryColor.withOpacity(0.15), blurRadius: 8, offset: const Offset(0, 2))]
              : null,
        ),
        child: Column(
          children: [
            _buildIcon(theme),
            const SizedBox(height: 8),
            Text(
              label,
              style: theme.textTheme.titleSmall?.copyWith(
                color: isSelected ? primaryColor : theme.colorScheme.onSurface,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              description,
              style: theme.textTheme.labelSmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              detail,
              style: theme.textTheme.labelSmall?.copyWith(
                color: isSelected ? primaryColor : theme.colorScheme.outline,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: isSelected
                    ? primaryColor.withOpacity(0.15)
                    : theme.colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                '-$reductionEstimate',
                style: theme.textTheme.labelSmall?.copyWith(
                  color: isSelected ? primaryColor : Colors.green,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    )
        .animate(target: isSelected ? 1.0 : 0.0)
        .scale(begin: const Offset(1, 1), end: const Offset(1.03, 1.03), duration: 200.ms);
  }

  Widget _buildIcon(ThemeData theme) {
    final primaryColor = const Color(0xFF4D2DAB);
    IconData icon;
    switch (quality) {
      case CompressionQuality.low:
        icon = Icons.speed;
        break;
      case CompressionQuality.medium:
        icon = Icons.balance;
        break;
      case CompressionQuality.high:
        icon = Icons.high_quality_outlined;
    }
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        color: isSelected
            ? primaryColor.withOpacity(0.15)
            : theme.colorScheme.surfaceContainerHighest,
        shape: BoxShape.circle,
      ),
      child: Icon(
        icon,
        size: 18,
        color: isSelected ? primaryColor : theme.colorScheme.onSurfaceVariant,
      ),
    );
  }
}
