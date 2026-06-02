/// ScanPro root application widget.
///
/// Configures MaterialApp with GoRouter navigation, Riverpod
/// state management, and dynamic theme switching (light/dark/system).
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'core/constants/app_constants.dart';
import 'core/theme/app_theme.dart';

/// Provider for the app's [GoRouter] instance.
///
/// Defines the top-level navigation structure. Screens will be
/// added here as features are implemented.
final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/',
    debugLogDiagnostics: kDebugMode,
    routes: [
      GoRoute(
        path: '/',
        name: 'home',
        builder: (context, state) => const _PlaceholderScreen(title: 'Home'),
      ),
      GoRoute(
        path: '/scan',
        name: 'scan',
        builder: (context, state) => const _PlaceholderScreen(title: 'Scanner'),
      ),
      GoRoute(
        path: '/documents',
        name: 'documents',
        builder: (context, state) => const _PlaceholderScreen(title: 'Documents'),
      ),
      GoRoute(
        path: '/settings',
        name: 'settings',
        builder: (context, state) => const _PlaceholderScreen(title: 'Settings'),
      ),
    ],
    errorBuilder: (context, state) => const _PlaceholderScreen(title: 'Page Not Found'),
  );
});

/// Root application widget for ScanPro.
///
/// Watches the [themeModeProvider] for dynamic theme changes
/// and provides the [GoRouter] for navigation.
class ScanProApp extends ConsumerWidget {
  const ScanProApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);
    final router = ref.watch(routerProvider);

    return MaterialApp.router(
      // ── App Identity ──────────────────────────────────────────
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,

      // ── Theme Configuration ───────────────────────────────────
      theme: buildLightTheme(),
      darkTheme: buildDarkTheme(),
      themeMode: themeMode,

      // ── Router ────────────────────────────────────────────────
      routerConfig: router,

      // ── Localization ──────────────────────────────────────────
      locale: const Locale('en', 'US'),
      supportedLocales: const [
        Locale('en', 'US'),
      ],
    );
  }
}

/// Temporary placeholder screen used until feature screens are built.
///
/// This will be replaced by actual screen implementations as
/// features are added (home, scanner, documents, settings, etc.).
class _PlaceholderScreen extends StatelessWidget {
  final String title;

  const _PlaceholderScreen({required this.title});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        backgroundColor: colorScheme.surface,
        surfaceTintColor: Colors.transparent,
      ),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.construction_rounded,
              size: 64,
              color: colorScheme.primary.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 16),
            Text(
              '$title — Coming Soon',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
