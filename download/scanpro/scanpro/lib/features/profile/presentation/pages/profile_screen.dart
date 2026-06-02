import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../providers/profile_provider.dart';
import '../widgets/profile_header.dart';
import '../widgets/stat_card.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileState = ref.watch(profileProvider);
    final theme = Theme.of(context);

    if (profileState.isLoading && profileState.profile == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final profile = profileState.profile;
    if (profile == null) {
      return Scaffold(
        body: Center(
          child: Text('Failed to load profile', style: theme.textTheme.bodyLarge),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        actions: [
          IconButton(
            onPressed: () {
              // Edit profile
            },
            icon: const Icon(Icons.edit_outlined),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          ProfileHeader(profile: profile),
          const SizedBox(height: 24),

          // Account section
          Text(
            'Account',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ).animate().fadeIn(duration: 300.ms, delay: 200.ms),
          const SizedBox(height: 12),
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: Icon(
                    Icons.workspace_premium,
                    color: profile.isPremium
                        ? Colors.amber
                        : theme.colorScheme.onSurfaceVariant,
                  ),
                  title: const Text('Subscription'),
                  subtitle: Text(
                    profile.isPremium
                        ? 'Premium · Expires ${_formatDate(profile.subscriptionExpiry)}'
                        : 'Free Tier',
                  ),
                  trailing: profile.isPremium
                      ? null
                      : FilledButton.tonal(
                          onPressed: () {},
                          child: const Text('Upgrade'),
                        ),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.cloud_outlined),
                  title: const Text('Storage'),
                  subtitle: Text(
                    '${profile.storageUsedFormatted} of ${profile.storageTotalFormatted} used',
                  ),
                  trailing: Text(
                    '${(profile.storageFraction * 100).toStringAsFixed(0)}%',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ).animate().fadeIn(duration: 300.ms, delay: 250.ms),

          const SizedBox(height: 24),

          // Stats section
          Text(
            'Your Activity',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ).animate().fadeIn(duration: 300.ms, delay: 300.ms),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: StatCard(
                  icon: Icons.description,
                  value: '${profile.totalDocuments}',
                  label: 'Documents',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: StatCard(
                  icon: Icons.document_scanner,
                  value: '${profile.totalScans}',
                  label: 'Scans',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: StatCard(
                  icon: Icons.text_fields,
                  value: '${profile.ocrCount}',
                  label: 'OCR',
                ),
              ),
            ],
          ).animate().fadeIn(duration: 300.ms, delay: 350.ms),

          const SizedBox(height: 24),

          // Linked accounts
          Text(
            'Linked Accounts',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ).animate().fadeIn(duration: 300.ms, delay: 400.ms),
          const SizedBox(height: 12),
          ...profile.linkedAccounts.map(
            (account) => Card(
              child: ListTile(
                leading: _buildProviderIcon(account.provider),
                title: Text(account.displayName),
                subtitle: Text(account.email),
                trailing: account.isConnected
                    ? Text(
                        'Connected',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: Colors.green,
                          fontWeight: FontWeight.w500,
                        ),
                      )
                    : TextButton(
                        onPressed: () {},
                        child: const Text('Connect'),
                      ),
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Sign out
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: profileState.isSigningOut
                  ? null
                  : () => _confirmSignOut(context, ref),
              icon: profileState.isSigningOut
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.logout),
              label: const Text('Sign Out'),
              style: OutlinedButton.styleFrom(
                foregroundColor: theme.colorScheme.error,
                side: BorderSide(color: theme.colorScheme.error),
              ),
            ),
          ).animate().fadeIn(duration: 300.ms, delay: 500.ms),

          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildProviderIcon(String provider) {
    switch (provider) {
      case 'google':
        return Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: const Center(
            child: Text(
              'G',
              style: TextStyle(
                color: Colors.red,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        );
      default:
        return const CircleAvatar(child: Icon(Icons.link));
    }
  }

  void _confirmSignOut(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Sign Out'),
        content: const Text(
          'Are you sure you want to sign out? You will need to sign in again to access your documents.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              ref.read(profileProvider.notifier).signOut();
            },
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(ctx).colorScheme.error,
            ),
            child: const Text('Sign Out'),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime dt) {
    return '${dt.day}/${dt.month}/${dt.year}';
  }
}
