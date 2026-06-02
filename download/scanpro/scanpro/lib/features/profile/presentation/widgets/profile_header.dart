import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../providers/profile_provider.dart';

class ProfileHeader extends StatelessWidget {
  final UserProfile profile;

  const ProfileHeader({
    super.key,
    required this.profile,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      children: [
        // Avatar
        Container(
          width: 96,
          height: 96,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              colors: [
                theme.colorScheme.primary,
                theme.colorScheme.tertiary,
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(
                color: theme.colorScheme.primary.withValues(alpha: 0.3),
                blurRadius: 12,
                spreadRadius: 2,
              ),
            ],
          ),
          child: profile.photoUrl != null
              ? ClipOval(
                  child: Image.network(
                    profile.photoUrl!,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => _buildInitials(theme),
                  ),
                )
              : _buildInitials(theme),
        ).animate().scale(
              duration: 400.ms,
              begin: const Offset(0.5, 0.5),
              end: const Offset(1, 1),
              curve: Curves.easeOutBack,
            ),
        const SizedBox(height: 16),
        // Name
        Text(
          profile.displayName,
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ).animate().fadeIn(duration: 300.ms, delay: 100.ms),
        const SizedBox(height: 4),
        // Email
        Text(
          profile.email,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ).animate().fadeIn(duration: 300.ms, delay: 150.ms),
        const SizedBox(height: 12),
        // Subscription badge
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: profile.isPremium
                ? Colors.amber.withValues(alpha: 0.15)
                : theme.colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: profile.isPremium
                  ? Colors.amber
                  : theme.colorScheme.outlineVariant,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                profile.isPremium ? Icons.workspace_premium : Icons.person,
                size: 14,
                color: profile.isPremium
                    ? Colors.amber.shade700
                    : theme.colorScheme.onSurfaceVariant,
              ),
              const SizedBox(width: 4),
              Text(
                profile.isPremium ? 'Premium' : 'Free',
                style: theme.textTheme.labelSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: profile.isPremium
                      ? Colors.amber.shade700
                      : theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ).animate().fadeIn(duration: 300.ms, delay: 200.ms),
      ],
    );
  }

  Widget _buildInitials(ThemeData theme) {
    final initials = profile.displayName
        .split(' ')
        .map((e) => e.isNotEmpty ? e[0] : '')
        .take(2)
        .join()
        .toUpperCase();

    return Center(
      child: Text(
        initials,
        style: theme.textTheme.headlineMedium?.copyWith(
          color: theme.colorScheme.onPrimary,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
