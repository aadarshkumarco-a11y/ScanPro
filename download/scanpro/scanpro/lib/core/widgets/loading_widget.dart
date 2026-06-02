/// Reusable loading indicator widget with optional message.
///
/// Displays a centered circular progress indicator with an
/// optional descriptive message below it.
library;

import 'package:flutter/material.dart';

import '../theme/dimensions.dart';

/// A centered loading spinner with an optional message.
///
/// Example:
/// ```dart
/// if (isLoading) const LoadingWidget(message: 'Scanning document...');
/// ```
class LoadingWidget extends StatelessWidget {
  /// Optional message displayed below the spinner.
  final String? message;

  /// Size of the progress indicator.
  final double size;

  /// Stroke width of the circular indicator.
  final double strokeWidth;

  const LoadingWidget({
    super.key,
    this.message,
    this.size = 40.0,
    this.strokeWidth = 3.0,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: size,
            height: size,
            child: CircularProgressIndicator(
              strokeWidth: strokeWidth,
              color: colorScheme.primary,
            ),
          ),
          if (message != null) ...[
            const SizedBox(height: Dimensions.spacing16),
            Text(
              message!,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }
}

/// A full-screen loading overlay that dims the background.
class LoadingOverlay extends StatelessWidget {
  final Widget child;
  final bool isLoading;
  final String? message;

  const LoadingOverlay({
    super.key,
    required this.child,
    required this.isLoading,
    this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,
        if (isLoading)
          Positioned.fill(
            child: Container(
              color: Colors.black.withValues(alpha: 0.3),
              child: LoadingWidget(message: message),
            ),
          ),
      ],
    );
  }
}
