import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../providers/qr_provider.dart';

class ScanResultSheet extends StatelessWidget {
  final QrScanResult result;
  final VoidCallback onDismiss;

  const ScanResultSheet({
    super.key,
    required this.result,
    required this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return DraggableScrollableSheet(
      initialChildSize: 0.55,
      maxChildSize: 0.7,
      minChildSize: 0.3,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(20),
            ),
          ),
          child: ListView(
            controller: scrollController,
            padding: const EdgeInsets.all(20),
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.outlineVariant,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              // Type indicator
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      _typeIcon(result.type),
                      size: 16,
                      color: theme.colorScheme.onPrimaryContainer,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      _typeLabel(result.type),
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: theme.colorScheme.onPrimaryContainer,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ).animate().fadeIn(duration: 200.ms),
              const SizedBox(height: 16),
              // Title
              Text(
                result.title ?? result.rawValue,
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ).animate().fadeIn(duration: 300.ms, delay: 100.ms),
              if (result.subtitle != null) ...[
                const SizedBox(height: 4),
                Text(
                  result.subtitle!,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
              const SizedBox(height: 16),
              // Raw value display
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: SelectableText(
                  result.rawValue,
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontFamily: 'monospace',
                  ),
                ),
              ).animate().fadeIn(duration: 300.ms, delay: 200.ms),
              const SizedBox(height: 24),
              // Action buttons
              _buildActions(context, theme),
              const SizedBox(height: 16),
              // Scan again button
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: onDismiss,
                  child: const Text('Scan Again'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildActions(BuildContext context, ThemeData theme) {
    final actions = <Widget>[];

    if (result.type == QrType.url) {
      actions.add(_ActionButton(
        icon: Icons.open_in_browser,
        label: 'Open',
        onTap: () {
          // In production, launch URL
          onDismiss();
        },
      ));
    }

    if (result.type == QrType.contact) {
      actions.add(_ActionButton(
        icon: Icons.person_add,
        label: 'Add Contact',
        onTap: () {
          // In production, parse vCard and add contact
          onDismiss();
        },
      ));
    }

    if (result.type == QrType.wifi) {
      actions.add(_ActionButton(
        icon: Icons.wifi,
        label: 'Connect',
        onTap: () {
          // In production, connect to WiFi
          onDismiss();
        },
      ));
    }

    if (result.type == QrType.phone) {
      actions.add(_ActionButton(
        icon: Icons.phone,
        label: 'Call',
        onTap: () {
          // In production, make phone call
          onDismiss();
        },
      ));
    }

    if (result.type == QrType.email) {
      actions.add(_ActionButton(
        icon: Icons.email,
        label: 'Send Email',
        onTap: () {
          // In production, compose email
          onDismiss();
        },
      ));
    }

    // Always show Copy and Share
    actions.addAll([
      _ActionButton(
        icon: Icons.copy,
        label: 'Copy',
        onTap: () {
          Clipboard.setData(ClipboardData(text: result.rawValue));
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Copied to clipboard'),
              behavior: SnackBarBehavior.floating,
            ),
          );
        },
      ),
      _ActionButton(
        icon: Icons.share,
        label: 'Share',
        onTap: () {
          // In production, use share_plus
        },
      ),
    ]);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: actions,
    ).animate().fadeIn(duration: 300.ms, delay: 300.ms);
  }

  IconData _typeIcon(QrType type) {
    switch (type) {
      case QrType.url:
        return Icons.language;
      case QrType.text:
        return Icons.text_fields;
      case QrType.contact:
        return Icons.person;
      case QrType.wifi:
        return Icons.wifi;
      case QrType.email:
        return Icons.email;
      case QrType.phone:
        return Icons.phone;
      case QrType.sms:
        return Icons.sms;
      case QrType.barcode:
        return Icons.barcode_reader;
    }
  }

  String _typeLabel(QrType type) {
    switch (type) {
      case QrType.url:
        return 'URL';
      case QrType.text:
        return 'Text';
      case QrType.contact:
        return 'Contact';
      case QrType.wifi:
        return 'WiFi';
      case QrType.email:
        return 'Email';
      case QrType.phone:
        return 'Phone';
      case QrType.sms:
        return 'SMS';
      case QrType.barcode:
        return 'Barcode';
    }
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer,
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 20,
                color: theme.colorScheme.onPrimaryContainer,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              label,
              style: theme.textTheme.labelSmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
