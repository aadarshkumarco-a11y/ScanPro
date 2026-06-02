import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_constants.dart';
import '../../features/home/presentation/screens/home_screen.dart';
import '../../features/documents/presentation/screens/documents_screen.dart';
import '../../features/documents/presentation/screens/document_detail_screen.dart';
import '../../features/documents/presentation/screens/folder_screen.dart';
import '../../features/scanner/presentation/screens/scanner_screen.dart';
import '../../features/scanner/presentation/screens/scan_result_screen.dart';
import '../../features/ocr/presentation/screens/ocr_screen.dart';
import '../../features/ocr/presentation/screens/ocr_result_screen.dart';
import '../../features/pdf_tools/presentation/screens/pdf_tools_screen.dart';
import '../../features/pdf_tools/presentation/screens/create_pdf_screen.dart';
import '../../features/pdf_tools/presentation/screens/merge_pdf_screen.dart';
import '../../features/pdf_tools/presentation/screens/split_pdf_screen.dart';
import '../../features/pdf_tools/presentation/screens/compress_pdf_screen.dart';
import '../../features/search/presentation/screens/search_screen.dart';
import '../../features/cloud_sync/presentation/screens/cloud_sync_screen.dart';
import '../../features/security/presentation/screens/security_screen.dart';
import '../../features/security/presentation/screens/pin_setup_screen.dart';
import '../../features/security/presentation/screens/security_verify_screen.dart';
import '../../features/ai_features/presentation/screens/ai_features_screen.dart';
import '../../features/ai_features/presentation/screens/ai_summary_screen.dart';
import '../../features/ai_features/presentation/screens/ai_categorize_screen.dart';
import '../../features/ai_features/presentation/screens/ai_smart_rename_screen.dart';
import '../../features/signature/presentation/screens/signature_screen.dart';
import '../../features/signature/presentation/screens/signature_draw_screen.dart';
import '../../features/annotations/presentation/screens/annotations_screen.dart';
import '../../features/qr_scanner/presentation/screens/qr_scanner_screen.dart';
import '../../features/profile/presentation/screens/profile_screen.dart';
import '../../features/settings/presentation/screens/settings_screen.dart';

// ── Route Path Constants ──────────────────────────────────────────

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
  static const String aiCategorize = '/ai-features/categorize';
  static const String aiSmartRename = '/ai-features/rename';
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
  static const String aiCategorize = 'ai-categorize';
  static const String aiSmartRename = 'ai-smart-rename';
  static const String signature = 'signature';
  static const String signatureDraw = 'signature-draw';
  static const String annotations = 'annotations';
  static const String qrScanner = 'qr-scanner';
  static const String profile = 'profile';
  static const String settings = 'settings';
}

// ── GoRouter Provider ─────────────────────────────────────────────

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
                  child: HomeScreen(),
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
                  child: DocumentsScreen(),
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
                  child: ScannerScreen(),
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
                  child: ProfileScreen(),
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
                  child: SettingsScreen(),
                ),
              ),
            ],
          ),
        ],
      ),

      // ── Full-screen routes (outside the shell) ──────────────────

      // Scanner result
      GoRoute(
        path: AppRoutes.scannerResult,
        name: AppRouteNames.scannerResult,
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: const ScanResultScreen(),
          transitionsBuilder: _slideUpTransition,
        ),
      ),

      // Document detail
      GoRoute(
        path: AppRoutes.documentDetail,
        name: AppRouteNames.documentDetail,
        builder: (context, state) {
          final docId = state.uri.queryParameters['id'] ?? '';
          return DocumentDetailScreen(documentId: docId);
        },
      ),

      // Document folder
      GoRoute(
        path: AppRoutes.documentFolder,
        name: AppRouteNames.documentFolder,
        builder: (context, state) {
          final folderId = state.uri.queryParameters['id'] ?? '';
          final folderName = state.uri.queryParameters['name'] ?? 'Folder';
          return FolderScreen(folderId: folderId, folderName: folderName);
        },
      ),

      // OCR
      GoRoute(
        path: AppRoutes.ocr,
        name: AppRouteNames.ocr,
        builder: (context, state) => const OcrScreen(),
      ),

      // OCR result
      GoRoute(
        path: AppRoutes.ocrResult,
        name: AppRouteNames.ocrResult,
        builder: (context, state) => const OcrResultScreen(),
      ),

      // PDF Tools
      GoRoute(
        path: AppRoutes.pdfTools,
        name: AppRouteNames.pdfTools,
        builder: (context, state) => const PdfToolsScreen(),
        routes: [
          GoRoute(
            path: 'create',
            name: AppRouteNames.pdfCreate,
            builder: (context, state) => const CreatePdfScreen(),
          ),
          GoRoute(
            path: 'merge',
            name: AppRouteNames.pdfMerge,
            builder: (context, state) => const MergePdfScreen(),
          ),
          GoRoute(
            path: 'split',
            name: AppRouteNames.pdfSplit,
            builder: (context, state) => const SplitPdfScreen(),
          ),
          GoRoute(
            path: 'compress',
            name: AppRouteNames.pdfCompress,
            builder: (context, state) => const CompressPdfScreen(),
          ),
        ],
      ),

      // Search
      GoRoute(
        path: AppRoutes.search,
        name: AppRouteNames.search,
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: const SearchScreen(),
          transitionsBuilder: _fadeInTransition,
        ),
      ),

      // Cloud Sync
      GoRoute(
        path: AppRoutes.cloudSync,
        name: AppRouteNames.cloudSync,
        builder: (context, state) => const CloudSyncScreen(),
      ),

      // Security
      GoRoute(
        path: AppRoutes.security,
        name: AppRouteNames.security,
        builder: (context, state) => const SecurityScreen(),
        routes: [
          GoRoute(
            path: 'setup',
            name: AppRouteNames.securitySetup,
            builder: (context, state) => const PinSetupScreen(),
          ),
          GoRoute(
            path: 'verify',
            name: AppRouteNames.securityVerify,
            builder: (context, state) => const SecurityVerifyScreen(),
          ),
        ],
      ),

      // AI Features
      GoRoute(
        path: AppRoutes.aiFeatures,
        name: AppRouteNames.aiFeatures,
        builder: (context, state) => const AiFeaturesScreen(),
        routes: [
          GoRoute(
            path: 'summary',
            name: AppRouteNames.aiSummary,
            builder: (context, state) => const AiSummaryScreen(),
          ),
          GoRoute(
            path: 'categorize',
            name: AppRouteNames.aiCategorize,
            builder: (context, state) => const AiCategorizeScreen(),
          ),
          GoRoute(
            path: 'rename',
            name: AppRouteNames.aiSmartRename,
            builder: (context, state) => const AiSmartRenameScreen(),
          ),
        ],
      ),

      // Signature
      GoRoute(
        path: AppRoutes.signature,
        name: AppRouteNames.signature,
        builder: (context, state) => const SignatureScreen(),
        routes: [
          GoRoute(
            path: 'draw',
            name: AppRouteNames.signatureDraw,
            builder: (context, state) => const SignatureDrawScreen(),
          ),
        ],
      ),

      // Annotations
      GoRoute(
        path: AppRoutes.annotations,
        name: AppRouteNames.annotations,
        builder: (context, state) {
          final docId = state.uri.queryParameters['id'] ?? '';
          return AnnotationsScreen(documentId: docId);
        },
      ),

      // QR Scanner
      GoRoute(
        path: AppRoutes.qrScanner,
        name: AppRouteNames.qrScanner,
        builder: (context, state) => const QrScannerScreen(),
      ),
    ];

// ── Route Guard ───────────────────────────────────────────────────

String? _guardRedirect(BuildContext context, GoRouterState state) {
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
            label: 'Docs',
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
