import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_constants.dart';

// ── Route Path Constants (re-exported for convenience) ────────────

class AppRoutes {
  AppRoutes._();

  static const String splash = '/';
  static const String home = '/home';
  static const String scanner = '/scanner';
  static const String scannerResult = '/scanner/result';
  static const String documents = '/documents';
  static const String documentDetail = '/documents/detail';
  static const String documentFolder = '/documents/folder';
  static const String ocr = '/ocr';
  static const String ocrResult = '/ocr/result';
  static const String pdfTools = '/pdf-tools';
  static const String pdfCreate = '/pdf-tools/create';
  static const String pdfMerge = '/pdf-tools/merge';
  static const String pdfSplit = '/pdf-tools/split';
  static const String pdfCompress = '/pdf-tools/compress';
  static const String search = '/search';
  static const String cloudSync = '/cloud-sync';
  static const String security = '/security';
  static const String securitySetup = '/security/setup';
  static const String securityVerify = '/security/verify';
  static const String aiFeatures = '/ai-features';
  static const String aiSummary = '/ai-features/summary';
  static const String signature = '/signature';
  static const String signatureDraw = '/signature/draw';
  static const String annotations = '/annotations';
  static const String qrScanner = '/qr-scanner';
  static const String profile = '/profile';
  static const String settings = '/settings';
}

// ── Route Name Constants ──────────────────────────────────────────

class AppRouteNames {
  AppRouteNames._();

  static const String splash = 'splash';
  static const String home = 'home';
  static const String scanner = 'scanner';
  static const String scannerResult = 'scanner-result';
  static const String documents = 'documents';
  static const String documentDetail = 'document-detail';
  static const String documentFolder = 'document-folder';
  static const String ocr = 'ocr';
  static const String ocrResult = 'ocr-result';
  static const String pdfTools = 'pdf-tools';
  static const String pdfCreate = 'pdf-create';
  static const String pdfMerge = 'pdf-merge';
  static const String pdfSplit = 'pdf-split';
  static const String pdfCompress = 'pdf-compress';
  static const String search = 'search';
  static const String cloudSync = 'cloud-sync';
  static const String security = 'security';
  static const String securitySetup = 'security-setup';
  static const String securityVerify = 'security-verify';
  static const String aiFeatures = 'ai-features';
  static const String aiSummary = 'ai-summary';
  static const String signature = 'signature';
  static const String signatureDraw = 'signature-draw';
  static const String annotations = 'annotations';
  static const String qrScanner = 'qr-scanner';
  static const String profile = 'profile';
  static const String settings = 'settings';
}

// ── GoRouter Provider ─────────────────────────────────────────────

/// Provides the application [GoRouter] instance.
///
/// The router is created lazily and can be overridden in tests.
/// It listens to auth and lock state changes via [RiverpodListenable]
/// to trigger route redirects when the user's session state changes.
final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: AppRoutes.home,
    debugLogDiagnostics: true,
    navigatorKey: rootNavigatorKey,
    routes: _routes,
    redirect: _guardRedirect,
    errorBuilder: (context, state) => const _NotFoundScreen(),
  );
});

/// Global navigator key used by GoRouter.
final GlobalKey<NavigatorState> rootNavigatorKey = GlobalKey<NavigatorState>();

// ── Route Definitions ─────────────────────────────────────────────

List<RouteBase> get _routes => [
      // ── Shell Route (bottom navigation) ─────────────────────────
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return _ShellScaffold(navigationShell: navigationShell);
        },
        branches: [
          // Home tab
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.home,
                name: AppRouteNames.home,
                pageBuilder: (context, state) => const NoTransitionPage(
                  child: _PlaceholderScreen(title: 'Home'),
                ),
              ),
            ],
          ),
          // Documents tab
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.documents,
                name: AppRouteNames.documents,
                pageBuilder: (context, state) => const NoTransitionPage(
                  child: _PlaceholderScreen(title: 'Documents'),
                ),
              ),
            ],
          ),
          // Scanner tab (centre FAB)
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.scanner,
                name: AppRouteNames.scanner,
                pageBuilder: (context, state) => const NoTransitionPage(
                  child: _PlaceholderScreen(title: 'Scanner'),
                ),
              ),
            ],
          ),
          // Profile tab
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.profile,
                name: AppRouteNames.profile,
                pageBuilder: (context, state) => const NoTransitionPage(
                  child: _PlaceholderScreen(title: 'Profile'),
                ),
              ),
            ],
          ),
          // Settings tab
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.settings,
                name: AppRouteNames.settings,
                pageBuilder: (context, state) => const NoTransitionPage(
                  child: _PlaceholderScreen(title: 'Settings'),
                ),
              ),
            ],
          ),
        ],
      ),

      // ── Full-screen routes (outside the shell) ──────────────────

      // Splash
      GoRoute(
        path: AppRoutes.splash,
        name: AppRouteNames.splash,
        builder: (context, state) => const _PlaceholderScreen(title: 'Splash'),
      ),

      // Scanner result
      GoRoute(
        path: AppRoutes.scannerResult,
        name: AppRouteNames.scannerResult,
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: const _PlaceholderScreen(title: 'Scan Result'),
          transitionsBuilder: _slideUpTransition,
        ),
      ),

      // Document detail
      GoRoute(
        path: AppRoutes.documentDetail,
        name: AppRouteNames.documentDetail,
        builder: (context, state) {
          final docId = state.uri.queryParameters['id'] ?? '';
          return _PlaceholderScreen(title: 'Document Detail', subtitle: docId);
        },
      ),

      // Document folder
      GoRoute(
        path: AppRoutes.documentFolder,
        name: AppRouteNames.documentFolder,
        builder: (context, state) {
          final folderId = state.uri.queryParameters['id'] ?? '';
          return _PlaceholderScreen(title: 'Folder', subtitle: folderId);
        },
      ),

      // OCR
      GoRoute(
        path: AppRoutes.ocr,
        name: AppRouteNames.ocr,
        builder: (context, state) => const _PlaceholderScreen(title: 'OCR'),
      ),

      // OCR result
      GoRoute(
        path: AppRoutes.ocrResult,
        name: AppRouteNames.ocrResult,
        builder: (context, state) =>
            const _PlaceholderScreen(title: 'OCR Result'),
      ),

      // PDF Tools
      GoRoute(
        path: AppRoutes.pdfTools,
        name: AppRouteNames.pdfTools,
        builder: (context, state) =>
            const _PlaceholderScreen(title: 'PDF Tools'),
        routes: [
          GoRoute(
            path: 'create',
            name: AppRouteNames.pdfCreate,
            builder: (context, state) =>
                const _PlaceholderScreen(title: 'Create PDF'),
          ),
          GoRoute(
            path: 'merge',
            name: AppRouteNames.pdfMerge,
            builder: (context, state) =>
                const _PlaceholderScreen(title: 'Merge PDFs'),
          ),
          GoRoute(
            path: 'split',
            name: AppRouteNames.pdfSplit,
            builder: (context, state) =>
                const _PlaceholderScreen(title: 'Split PDF'),
          ),
          GoRoute(
            path: 'compress',
            name: AppRouteNames.pdfCompress,
            builder: (context, state) =>
                const _PlaceholderScreen(title: 'Compress PDF'),
          ),
        ],
      ),

      // Search
      GoRoute(
        path: AppRoutes.search,
        name: AppRouteNames.search,
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: const _PlaceholderScreen(title: 'Search'),
          transitionsBuilder: _fadeInTransition,
        ),
      ),

      // Cloud Sync
      GoRoute(
        path: AppRoutes.cloudSync,
        name: AppRouteNames.cloudSync,
        builder: (context, state) =>
            const _PlaceholderScreen(title: 'Cloud Sync'),
      ),

      // Security
      GoRoute(
        path: AppRoutes.security,
        name: AppRouteNames.security,
        builder: (context, state) =>
            const _PlaceholderScreen(title: 'Security'),
        routes: [
          GoRoute(
            path: 'setup',
            name: AppRouteNames.securitySetup,
            builder: (context, state) =>
                const _PlaceholderScreen(title: 'Security Setup'),
          ),
          GoRoute(
            path: 'verify',
            name: AppRouteNames.securityVerify,
            builder: (context, state) =>
                const _PlaceholderScreen(title: 'Verify Identity'),
          ),
        ],
      ),

      // AI Features
      GoRoute(
        path: AppRoutes.aiFeatures,
        name: AppRouteNames.aiFeatures,
        builder: (context, state) =>
            const _PlaceholderScreen(title: 'AI Features'),
        routes: [
          GoRoute(
            path: 'summary',
            name: AppRouteNames.aiSummary,
            builder: (context, state) =>
                const _PlaceholderScreen(title: 'AI Summary'),
          ),
        ],
      ),

      // Signature
      GoRoute(
        path: AppRoutes.signature,
        name: AppRouteNames.signature,
        builder: (context, state) =>
            const _PlaceholderScreen(title: 'Signatures'),
        routes: [
          GoRoute(
            path: 'draw',
            name: AppRouteNames.signatureDraw,
            builder: (context, state) =>
                const _PlaceholderScreen(title: 'Draw Signature'),
          ),
        ],
      ),

      // Annotations
      GoRoute(
        path: AppRoutes.annotations,
        name: AppRouteNames.annotations,
        builder: (context, state) =>
            const _PlaceholderScreen(title: 'Annotations'),
      ),

      // QR Scanner
      GoRoute(
        path: AppRoutes.qrScanner,
        name: AppRouteNames.qrScanner,
        builder: (context, state) =>
            const _PlaceholderScreen(title: 'QR Scanner'),
      ),
    ];

// ── Route Guard ───────────────────────────────────────────────────

/// Global redirect logic.
///
/// Checks:
/// 1. If the app is locked (PIN / biometric required), redirect to
///    the security verify screen – unless already there.
/// 2. If the user is not authenticated and tries to access a
///    protected route, redirect to home.
///
/// Both checks consult Riverpod providers which can be overridden
/// in tests or when the real feature modules are wired up.
String? _guardRedirect(BuildContext context, GoRouterState state) {
  final currentPath = state.matchedLocation;

  // Allow navigation to security screens even when locked.
  final securityPaths = {
    AppRoutes.security,
    AppRoutes.securitySetup,
    AppRoutes.securityVerify,
  };
  if (securityPaths.any((p) => currentPath.startsWith(p))) {
    return null;
  }

  // TODO: Wire up real isAppLockedProvider from security module.
  // For now the guard is a no-op so the app is navigable during
  // early development.

  return null;
}

// ── Custom Transitions ────────────────────────────────────────────

Widget _slideUpTransition(
  BuildContext context,
  Animation<double> animation,
  Animation<double> secondaryAnimation,
  Widget child,
) {
  return SlideTransition(
    position: Tween<Offset>(
      begin: const Offset(0, 1),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOutCubic)),
    child: child,
  );
}

Widget _fadeInTransition(
  BuildContext context,
  Animation<double> animation,
  Animation<double> secondaryAnimation,
  Widget child,
) {
  return FadeTransition(
    opacity: CurvedAnimation(parent: animation, curve: Curves.easeIn),
    child: child,
  );
}

// ── Shell Scaffold (bottom navigation) ────────────────────────────

class _ShellScaffold extends StatelessWidget {
  const _ShellScaffold({required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: NavigationBar(
        selectedIndex: navigationShell.currentIndex,
        onDestinationSelected: (index) {
          navigationShell.goBranch(
            index,
            initialLocation: index == navigationShell.currentIndex,
          );
        },
        backgroundColor: colorScheme.surface,
        indicatorColor: colorScheme.primary.withValues(alpha: 0.12),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home_rounded),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.folder_outlined),
            selectedIcon: Icon(Icons.folder_rounded),
            label: 'Documents',
          ),
          NavigationDestination(
            icon: Icon(Icons.document_scanner_outlined),
            selectedIcon: Icon(Icons.document_scanner_rounded),
            label: 'Scan',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline_rounded),
            selectedIcon: Icon(Icons.person_rounded),
            label: 'Profile',
          ),
          NavigationDestination(
            icon: Icon(Icons.settings_outlined),
            selectedIcon: Icon(Icons.settings_rounded),
            label: 'Settings',
          ),
        ],
      ),
    );
  }
}

// ── Placeholder Screen (used until real screens are wired) ────────

class _PlaceholderScreen extends StatelessWidget {
  const _PlaceholderScreen({
    required this.title,
    this.subtitle,
  });

  final String title;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        leading: Navigator.of(context).canPop()
            ? IconButton(
                onPressed: () => context.pop(),
                icon: const Icon(Icons.arrow_back_rounded),
              )
            : null,
      ),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.construction_rounded,
              size: 64,
              color: colorScheme.primary.withValues(alpha: 0.4),
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: colorScheme.onSurface,
              ),
            ),
            if (subtitle != null) ...[
              const SizedBox(height: 8),
              Text(
                subtitle!,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurface.withValues(alpha: 0.5),
                ),
              ),
            ],
            const SizedBox(height: 8),
            Text(
              'Screen coming soon',
              style: theme.textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurface.withValues(alpha: 0.4),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── 404 Screen ────────────────────────────────────────────────────

class _NotFoundScreen extends StatelessWidget {
  const _NotFoundScreen();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.error_outline_rounded,
              size: 80,
              color: colorScheme.error.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 24),
            Text(
              'Page Not Found',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'The page you are looking for does not exist.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurface.withValues(alpha: 0.6),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => context.go(AppRoutes.home),
              child: const Text('Go Home'),
            ),
          ],
        ),
      ),
    );
  }
}
