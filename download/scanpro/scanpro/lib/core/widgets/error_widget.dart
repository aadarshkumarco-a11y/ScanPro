/// Reusable error display widget with retry action.
///
/// Shows an error icon, message, and an optional retry button
/// for recoverable error states in screens and features.
library;

import 'package:flutter/material.dart';

import '../theme/dimensions.dart';

/// An error state widget with icon, message, and optional retry.
///
/// Example:
/// ```dart
/// ErrorWidget(
///   message: 'Failed to load documents',
///   onRetry: () => ref.invalidate(documentsProvider),
/// )
/// ```
class AppErrorWidget extends StatelessWidget {
  /// Error message to display.
  final String message;

  /// Optional callback when the retry button is pressed.
  final VoidCallback? onRetry;

  /// Optional custom icon (defaults to error outline).
  final IconData icon;

  /// Optional retry button label.
  final String retryLabel;

  const AppErrorWidget({
    super.key,
    required this.message,
    this.onRetry,
    this.icon = Icons.error_outline_rounded,
    this.retryLabel = 'Retry',
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(Dimensions.paddingLarge),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: Dimensions.iconExtraLarge,
              color: colorScheme.error,
            ),
            const SizedBox(height: Dimensions.spacing16),
            Text(
              message,
              style: textTheme.bodyLarge?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
              maxLines: 4,
              overflow: TextOverflow.ellipsis,
            ),
            if (onRetry != null) ...[
              const SizedBox(height: Dimensions.spacing24),
              FilledButton.tonal(
                onPressed: onRetry,
                child: Text(retryLabel),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
