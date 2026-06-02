import 'package:flutter/material.dart';

/// A reusable error display widget with an optional retry button.
///
/// Displays an icon, title, subtitle, and a "Try Again" action.
/// Designed to replace the default Flutter error screens in
/// feature pages and async content areas.
class AppErrorWidget extends StatelessWidget {
  const AppErrorWidget({
    super.key,
    required this.message,
    this.title = 'Something went wrong',
    this.icon,
    this.onRetry,
    this.retryLabel = 'Try Again',
    this.isCompact = false,
  });

  /// The primary error description shown as the subtitle.
  final String message;

  /// A short heading above the message.
  final String title;

  /// Custom icon; defaults to an error outline.
  final IconData? icon;

  /// Called when the user taps the retry button.
  /// If `null`, the retry button is hidden.
  final VoidCallback? onRetry;

  /// Label for the retry button.
  final String retryLabel;

  /// When `true`, uses a more compact layout suitable for
  /// embedding inside cards or constrained areas.
  final bool isCompact;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    if (isCompact) return _buildCompact(context, theme, colorScheme);
    return _buildFull(context, theme, colorScheme);
  }

  // ── Full Layout ─────────────────────────────────────────────────

  Widget _buildFull(
    BuildContext context,
    ThemeData theme,
    ColorScheme colorScheme,
  ) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 48),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon ?? Icons.error_outline_rounded,
              size: 72,
              color: colorScheme.error.withValues(alpha: 0.7),
            ),
            const SizedBox(height: 24),
            Text(
              title,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: colorScheme.onSurface,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              message,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurface.withValues(alpha: 0.6),
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            if (onRetry != null) ...[
              const SizedBox(height: 24),
              SizedBox(
                width: 180,
                child: ElevatedButton.icon(
                  onPressed: onRetry,
                  icon: const Icon(Icons.refresh_rounded, size: 20),
                  label: Text(retryLabel),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  // ── Compact Layout ──────────────────────────────────────────────

  Widget _buildCompact(
    BuildContext context,
    ThemeData theme,
    ColorScheme colorScheme,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.error.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: colorScheme.error.withValues(alpha: 0.15),
        ),
      ),
      child: Row(
        children: [
          Icon(
            icon ?? Icons.error_outline_rounded,
            size: 28,
            color: colorScheme.error,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  message,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          if (onRetry != null) ...[
            const SizedBox(width: 8),
            IconButton(
              onPressed: onRetry,
              icon: Icon(
                Icons.refresh_rounded,
                size: 22,
                color: colorScheme.primary,
              ),
              tooltip: retryLabel,
            ),
          ],
        ],
      ),
    );
  }
}

// ── Specialised Error Widgets ─────────────────────────────────────

/// Error widget tailored for network / connectivity issues.
class NetworkErrorWidget extends StatelessWidget {
  const NetworkErrorWidget({super.key, this.onRetry});

  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    return AppErrorWidget(
      title: 'No Internet Connection',
      message: 'Please check your network settings and try again.',
      icon: Icons.wifi_off_rounded,
      onRetry: onRetry,
    );
  }
}

/// Error widget for server / API failures.
class ServerErrorWidget extends StatelessWidget {
  const ServerErrorWidget({super.key, this.onRetry});

  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    return AppErrorWidget(
      title: 'Server Error',
      message:
          'We\'re having trouble connecting to our servers. Please try again later.',
      icon: Icons.cloud_off_rounded,
      onRetry: onRetry,
    );
  }
}

/// Error widget for permission-denied scenarios.
class PermissionErrorWidget extends StatelessWidget {
  const PermissionErrorWidget({
    super.key,
    this.onRetry,
    this.permissionName = 'required permission',
  });

  final VoidCallback? onRetry;
  final String permissionName;

  @override
  Widget build(BuildContext context) {
    return AppErrorWidget(
      title: 'Permission Required',
      message:
          'ScanPro needs $permissionName to continue. Please grant the permission in your device settings.',
      icon: Icons.lock_outline_rounded,
      onRetry: onRetry,
      retryLabel: 'Open Settings',
    );
  }
}

/// Error widget for storage / disk-full scenarios.
class StorageErrorWidget extends StatelessWidget {
  const StorageErrorWidget({super.key, this.onRetry});

  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    return AppErrorWidget(
      title: 'Storage Full',
      message:
          'Your device storage is full. Please free up space and try again.',
      icon: Icons.folder_off_rounded,
      onRetry: onRetry,
    );
  }
}
