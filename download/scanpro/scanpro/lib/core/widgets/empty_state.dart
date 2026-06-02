/// Reusable empty state widget with icon, title, subtitle, and action.
///
/// Displays a centered illustration-like layout for when a screen
/// or list has no content to show.
library;

import 'package:flutter/material.dart';

import '../theme/dimensions.dart';

/// An empty state display with icon, title, subtitle, and optional action.
///
/// Example:
/// ```dart
/// EmptyState(
///   icon: Icons.document_scanner_outlined,
///   title: 'No Documents',
///   subtitle: 'Scan your first document to get started',
///   actionLabel: 'Start Scanning',
///   onAction: () => context.go('/scan'),
/// )
/// ```
class EmptyState extends StatelessWidget {
  /// Icon displayed at the top of the empty state.
  final IconData icon;

  /// Title text displayed prominently.
  final String title;

  /// Subtitle text with additional context or guidance.
  final String subtitle;

  /// Optional action button label.
  final String? actionLabel;

  /// Optional action button callback.
  final VoidCallback? onAction;

  const EmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    this.actionLabel,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: Dimensions.paddingExtraLarge,
          vertical: Dimensions.paddingLarge,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: colorScheme.primaryContainer.withValues(alpha: 0.3),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: Dimensions.iconExtraLarge,
                color: colorScheme.primary,
              ),
            ),
            const SizedBox(height: Dimensions.spacing24),
            Text(
              title,
              style: textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
                color: colorScheme.onSurface,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: Dimensions.spacing8),
            Text(
              subtitle,
              style: textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: Dimensions.spacing32),
              FilledButton(
                onPressed: onAction,
                child: Text(actionLabel!),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
