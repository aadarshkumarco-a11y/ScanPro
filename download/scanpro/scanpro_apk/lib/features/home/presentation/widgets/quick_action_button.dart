import 'package:flutter/material.dart';
import 'package:scanpro/core/theme/app_theme.dart';

/// Circular quick-action button with an icon, label, and gradient
/// background. Used on the home dashboard for primary shortcuts
/// (Scan, OCR, PDF Tools, QR).
class QuickActionButton extends StatelessWidget {
  const QuickActionButton({
    super.key,
    required this.icon,
    required this.label,
    required this.onTap,
    this.gradientColors = const [
      AppTheme.primaryColor,
      AppTheme.primaryLightColor,
    ],
    this.size = 60,
    this.iconSize = 28,
  });

  /// The icon displayed inside the circular button.
  final IconData icon;

  /// Short label rendered below the circle.
  final String label;

  /// Callback when the button is tapped.
  final VoidCallback onTap;

  /// Gradient colours for the circular background.
  final List<Color> gradientColors;

  /// Diameter of the circular button.
  final double size;

  /// Size of the icon inside the circle.
  final double iconSize;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(size / 2),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: gradientColors,
              ),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: gradientColors.first.withValues(alpha: 0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Icon(
              icon,
              color: Colors.white,
              size: iconSize,
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: size + 16,
            child: Text(
              label,
              style: theme.textTheme.labelMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: colorScheme.onSurface,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
