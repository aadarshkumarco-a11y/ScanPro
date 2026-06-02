import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../providers/signature_provider.dart';
import '../widgets/signature_card.dart';
import 'signature_create_screen.dart';

class SignatureScreen extends ConsumerWidget {
  const SignatureScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final signatureState = ref.watch(signatureProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Signatures')),
      body: signatureState.isLoading
          ? const Center(child: CircularProgressIndicator())
          : signatureState.signatures.isEmpty
              ? _buildEmptyState(theme)
              : _buildSignatureList(context, ref, signatureState, theme),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _navigateToCreate(context),
        icon: const Icon(Icons.draw),
        label: const Text('New Signature'),
      ),
    );
  }

  Widget _buildEmptyState(ThemeData theme) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.draw_outlined,
              size: 72,
              color: theme.colorScheme.outlineVariant,
            ).animate().fadeIn(duration: 400.ms),
            const SizedBox(height: 16),
            Text(
              'No Signatures Yet',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ).animate().fadeIn(duration: 400.ms, delay: 100.ms),
            const SizedBox(height: 8),
            Text(
              'Create your first signature to quickly\nsign documents on the go.',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ).animate().fadeIn(duration: 400.ms, delay: 200.ms),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.add),
              label: const Text('Create Signature'),
            ).animate().fadeIn(duration: 400.ms, delay: 300.ms),
          ],
        ),
      ),
    );
  }

  Widget _buildSignatureList(
    BuildContext context,
    WidgetRef ref,
    SignatureState state,
    ThemeData theme,
  ) {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
      itemCount: state.signatures.length,
      itemBuilder: (context, index) {
        final signature = state.signatures[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: SignatureCard(
            signature: signature,
            isActive: signature.id == state.activeSignatureId,
            onTap: () {
              ref.read(signatureProvider.notifier).setActiveSignature(signature.id);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Signature "${signature.name}" selected'),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            onDelete: () => _confirmDelete(context, ref, signature),
          ),
        ).animate().fadeIn(
              duration: 300.ms,
              delay: Duration(milliseconds: index * 50),
            ),
      ),
    );
  }

  void _navigateToCreate(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const SignatureCreateScreen()),
    );
  }

  void _confirmDelete(
    BuildContext context,
    WidgetRef ref,
    SignatureModel signature,
  ) {
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
              ref.read(signatureProvider.notifier).deleteSignature(signature.id);
              Navigator.of(ctx).pop();
            },
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(ctx).colorScheme.error,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
