import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_constants.dart';
import '../../domain/entities/signature.dart';
import '../providers/signature_provider.dart';
import '../widgets/signature_card.dart';

/// Signatures list screen.
///
/// Displays all saved signatures as cards with the option to
/// set a default, delete, or create a new signature.
class SignatureScreen extends ConsumerStatefulWidget {
  const SignatureScreen({super.key});

  @override
  ConsumerState<SignatureScreen> createState() => _SignatureScreenState();
}

class _SignatureScreenState extends ConsumerState<SignatureScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(
        () => ref.read(signatureProvider.notifier).loadSignatures());
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final signatureState = ref.watch(signatureProvider);
    const primaryColor = Color(0xFF4D2DAB);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Signatures'),
        centerTitle: true,
        leading: IconButton(
          onPressed: () => context.pop(),
          icon: const Icon(Icons.arrow_back_rounded),
        ),
      ),
      body: signatureState.signatures.isEmpty
          ? _buildEmptyState(theme, colorScheme, primaryColor)
          : Column(
              children: [
                // ── Header ──────────────────────────────────────────
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  margin: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF4D2DAB), Color(0xFF6B4EC0)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(
                          Icons.draw_rounded,
                          color: Colors.white,
                          size: 22,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${signatureState.signatures.length} Signature${signatureState.signatures.length == 1 ? '' : 's'}',
                              style: theme.textTheme.titleSmall?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            Text(
                              signatureState.defaultSignature != null
                                  ? 'Default: ${signatureState.defaultSignature!.name}'
                                  : 'No default set',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: Colors.white.withValues(alpha: 0.85),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // ── Error ───────────────────────────────────────────
                if (signatureState.errorMessage != null)
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 16),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: colorScheme.errorContainer,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.error_outline_rounded,
                            color: colorScheme.error, size: 20),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            signatureState.errorMessage!,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: colorScheme.onErrorContainer,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                // ── Signature List ─────────────────────────────────
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: signatureState.signatures.length,
                    itemBuilder: (context, index) {
                      final signature = signatureState.signatures[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: SignatureCard(
                          signature: signature,
                          primaryColor: primaryColor,
                          onSetDefault: () => ref
                              .read(signatureProvider.notifier)
                              .setDefaultSignature(signature.id),
                          onDelete: () =>
                              _confirmDelete(context, signature),
                          onTap: () {
                            // View / apply signature.
                          },
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push(AppConstants.signatureDrawRoute),
        backgroundColor: primaryColor,
        icon: const Icon(Icons.add_rounded, color: Colors.white),
        label: const Text(
          'New Signature',
          style: TextStyle(color: Colors.white),
        ),
      ),
    );
  }

  /// Builds the empty state when no signatures exist.
  Widget _buildEmptyState(
    ThemeData theme,
    ColorScheme colorScheme,
    Color primaryColor,
  ) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: primaryColor.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.draw_rounded,
                size: 48,
                color: primaryColor.withValues(alpha: 0.5),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'No Signatures Yet',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Create your first signature to quickly sign '
              'documents and PDFs.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurface.withValues(alpha: 0.6),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: () => context.push(AppConstants.signatureDrawRoute),
              icon: const Icon(Icons.add_rounded),
              label: const Text('Create Signature'),
              style: FilledButton.styleFrom(
                backgroundColor: primaryColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Shows a confirmation dialog before deleting a signature.
  void _confirmDelete(BuildContext context, Signature signature) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Signature'),
        content: Text(
          'Are you sure you want to delete "${signature.name}"? '
          'This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              ref
                  .read(signatureProvider.notifier)
                  .deleteSignature(signature.id);
            },
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
