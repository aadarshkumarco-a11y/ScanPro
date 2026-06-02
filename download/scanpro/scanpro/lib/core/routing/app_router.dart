/// GoRouter configuration for ScanPro with auth & security guards,
/// ShellRoute for bottom navigation, and all application routes.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../di/injection.dart';
import '../../di/modules/security_module.dart';

/// Application-wide [GoRouter]. Refreshes when auth or lock state changes.
final appRouterProvider = Provider<GoRouter>((ref) {
  final isAppLocked = ref.watch(isAppLockedProvider);
  final isAuthenticated = ref.watch(isAuthenticatedProvider);
  return GoRouter(
    initialLocation: '/',
    debugLogDiagnostics: true,
    refreshListenable: _RiverpodListenable(ref),
    redirect: (context, state) {
      final path = state.matchedLocation;
      // Security lock guard: only allow lock-related paths when locked.
      if (isAppLocked) {
        const allowed = ['/security/lock', '/security/pin-setup', '/security/biometric-setup'];
        return allowed.contains(path) ? null : '/security/lock';
      }
      // Auth guard: unauthenticated users can only access public paths.
      if (!isAuthenticated) {
        const public = ['/', '/security/lock', '/security/pin-setup', '/security/biometric-setup'];
        return public.contains(path) ? null : '/';
      }
      return null;
    },
    routes: [
      // ShellRoute — Bottom Navigation (Home, Documents, Profile)
      ShellRoute(
        builder: (context, state, child) => _MainScaffold(child: child),
        routes: [
          GoRoute(path: '/', name: 'home', builder: _s('HomeScreen')),
          GoRoute(
            path: '/documents', name: 'documents',
            builder: _s('DocumentsScreen'),
            routes: [
              GoRoute(path: 'trash', name: 'trash', builder: _s('TrashScreen')),
              GoRoute(path: ':id', name: 'documentDetail', builder: _sid('DocumentDetailScreen')),
              GoRoute(path: 'folder/:id', name: 'folderView', builder: _sid('FolderViewScreen')),
            ],
          ),
          GoRoute(path: '/profile', name: 'profile', builder: _s('ProfileScreen')),
          GoRoute(path: '/settings', name: 'settings', builder: _s('SettingsScreen')),
        ],
      ),
      // Scanner
      GoRoute(
        path: '/scanner', name: 'scanner', builder: _s('CameraScreen'),
        routes: [
          GoRoute(path: 'crop', name: 'crop', builder: _s('CropScreen')),
          GoRoute(path: 'enhance', name: 'enhance', builder: _s('EnhanceScreen')),
          GoRoute(path: 'batch', name: 'batchScan', builder: _s('BatchScanScreen')),
        ],
      ),
      // OCR
      GoRoute(
        path: '/ocr', name: 'ocr', builder: _s('OCRScreen'),
        routes: [
          GoRoute(path: 'result/:id', name: 'ocrResult', builder: _sid('OCRResultScreen')),
        ],
      ),
      // PDF
      GoRoute(path: '/pdf/merge', name: 'pdfMerge', builder: _s('PDFMergeScreen')),
      GoRoute(path: '/pdf/split', name: 'pdfSplit', builder: _s('PDFSplitScreen')),
      GoRoute(path: '/pdf/compress', name: 'pdfCompress', builder: _s('PDFCompressScreen')),
      GoRoute(path: '/pdf/viewer/:id', name: 'pdfViewer', builder: _sid('PDFViewerScreen')),
      GoRoute(path: '/pdf/editor/:id', name: 'pdfEditor', builder: _sid('PDFEditorScreen')),
      // Search & Sync
      GoRoute(path: '/search', name: 'search', builder: _s('SearchScreen')),
      GoRoute(path: '/sync', name: 'sync', builder: _s('SyncScreen')),
      // Security
      GoRoute(path: '/security/lock', name: 'lock', builder: _s('LockScreen')),
      GoRoute(path: '/security/pin-setup', name: 'pinSetup', builder: _s('PinSetupScreen')),
      GoRoute(path: '/security/biometric-setup', name: 'biometricSetup', builder: _s('BiometricSetupScreen')),
      // AI
      GoRoute(path: '/ai/summary/:id', name: 'aiSummary', builder: _sid('AISummaryScreen')),
      GoRoute(path: '/ai/extract/:id', name: 'aiExtract', builder: _sid('AIExtractScreen')),
      // Signature
      GoRoute(path: '/signature', name: 'signature', builder: _s('SignatureScreen')),
      GoRoute(path: '/signature/create', name: 'signatureCreate', builder: _s('SignatureCreateScreen')),
      // Annotations & QR
      GoRoute(path: '/annotations/:id', name: 'annotations', builder: _sid('AnnotationsScreen')),
      GoRoute(path: '/qr-scanner', name: 'qrScanner', builder: _s('QRScannerScreen')),
    ],
  );
});

// --- Route builder helpers ---

/// Builder for routes without path parameters.
GoRouterWidgetBuilder _s(String name) =>
    (_, __) => _PlaceholderScreen(name);

/// Builder for routes with a single `:id` path parameter.
GoRouterWidgetBuilder _sid(String name) =>
    (_, state) => _PlaceholderScreen(name, param: state.pathParameters['id']);

// --- Riverpod ↔ GoRouter bridge ---

/// Bridges Riverpod state changes to [GoRouter.refreshListenable].
class _RiverpodListenable extends ChangeNotifier {
  _RiverpodListenable(Ref ref) {
    ref.listen(isAppLockedProvider, (_, __) => notifyListeners());
    ref.listen(isAuthenticatedProvider, (_, __) => notifyListeners());
  }
}

// --- Bottom Navigation Shell ---

/// Root scaffold with persistent bottom navigation bar for tab routes.
class _MainScaffold extends StatelessWidget {
  const _MainScaffold({required this.child});
  final Widget child;

  static const _tabs = [
    (icon: Icons.home_outlined, label: 'Home', path: '/'),
    (icon: Icons.folder_outlined, label: 'Docs', path: '/documents'),
    (icon: Icons.person_outline, label: 'Profile', path: '/profile'),
  ];

  @override
  Widget build(BuildContext context) {
    final currentPath = GoRouterState.of(context).matchedLocation;
    final index = _tabs.indexWhere((t) => currentPath.startsWith(t.path)).clamp(0, 2);
    return Scaffold(
      body: child,
      bottomNavigationBar: NavigationBar(
        selectedIndex: index,
        onDestinationSelected: (i) => context.go(_tabs[i].path),
        destinations: _tabs
            .map((t) => NavigationDestination(icon: Icon(t.icon), label: t.label))
            .toList(),
      ),
    );
  }
}

// --- Placeholder Screen (temporary, replaced by real screens) ---

/// Dev-only placeholder showing the route name and optional ID param.
class _PlaceholderScreen extends StatelessWidget {
  const _PlaceholderScreen(this.name, {this.param});
  final String name;
  final String? param;

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: Text(name)),
    body: Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.construction, size: 48, color: Colors.grey.shade400),
          const SizedBox(height: 16),
          Text(name, style: Theme.of(context).textTheme.headlineSmall),
          if (param != null) ...[
            const SizedBox(height: 8),
            Text('ID: $param', style: Theme.of(context).textTheme.bodyMedium),
          ],
        ],
      ),
    ),
  );
}
