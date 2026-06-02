import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';

import '../../domain/entities/signature.dart';

/// Card to display a saved signature.
///
/// Shows the signature image preview, name, creation date,
/// default badge, and action buttons.
class SignatureCard extends StatelessWidget {
  const SignatureCard({
    super.key,
    required this.signature,
    required this.primaryColor,
    this.onTap,
    this.onSetDefault,
    this.onDelete,
  });

  /// The signature entity to display.
  final Signature signature;

  /// The primary color for the app.
  final Color primaryColor;

  /// Callback when the card is tapped.
  final VoidCallback? onTap;

  /// Callback to set this signature as default.
  final VoidCallback? onSetDefault;

  /// Callback to delete this signature.
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: signature.isDefault
            ? BorderSide(color: primaryColor, width: 2)
            : BorderSide.none,
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Header Row ────────────────────────────────────────
              Row(
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        // Signature name.
                        Expanded(
                          child: Text(
                            signature.name,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        // Default badge.
                        if (signature.isDefault) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: primaryColor.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              'Default',
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: primaryColor,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),

                  // Action buttons.
                  if (!signature.isDefault && onSetDefault != null)
                    IconButton(
                      onPressed: onSetDefault,
                      icon: Icon(
                        Icons.star_outline_rounded,
                        color: primaryColor.withValues(alpha: 0.6),
                        size: 20,
                      ),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(
                        minWidth: 32,
                        minHeight: 32,
                      ),
                      tooltip: 'Set as default',
                    ),
                  if (onDelete != null)
                    IconButton(
                      onPressed: onDelete,
                      icon: Icon(
                        Icons.delete_outline_rounded,
                        color: colorScheme.error.withValues(alpha: 0.6),
                        size: 20,
                      ),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(
                        minWidth: 32,
                        minHeight: 32,
                      ),
                      tooltip: 'Delete',
                    ),
                ],
              ),
              const SizedBox(height: 8),

              // ── Signature Image Preview ───────────────────────────
              Container(
                width: double.infinity,
                height: 80,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: colorScheme.outlineVariant.withValues(alpha: 0.3),
                  ),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: _buildSignatureImage(),
                ),
              ),
              const SizedBox(height: 4),

              // ── Date ──────────────────────────────────────────────
              Text(
                _formatDate(signature.createdAt),
                style: theme.textTheme.labelSmall?.copyWith(
                  color: colorScheme.onSurface.withValues(alpha: 0.4),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Builds the signature image from base64 data.
  Widget _buildSignatureImage() {
    try {
      final bytes = base64Decode(signature.imageData);
      return Image.memory(
        bytes,
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) => _placeholder(),
      );
    } catch (e) {
      return _placeholder();
    }
  }

  /// Placeholder when the image cannot be decoded.
  Widget _placeholder() {
    return Center(
      child: Icon(
        Icons.draw_rounded,
        color: Colors.grey.withValues(alpha: 0.3),
        size: 32,
      ),
    );
  }

  String _formatDate(DateTime dt) {
    return '${dt.month}/${dt.day}/${dt.year}';
  }
}
