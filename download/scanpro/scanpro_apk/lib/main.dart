import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/theme/app_theme.dart';
import 'core/routing/app_router.dart';
import 'di/app_module.dart';

void main() async {
  final container = await initializeApp();
  runApp(UncontrolledProviderScope(
    container: container,
    child: const ScanProApp(),
  ));
}

/// Root widget for ScanPro.
///
/// Uses [MaterialApp.router] with [GoRouter] for navigation
/// and [Riverpod] for state management.
class ScanProApp extends ConsumerWidget {
  const ScanProApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);
    final router = ref.watch(appRouterProvider);

    return MaterialApp.router(
      title: 'ScanPro',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme(),
      darkTheme: AppTheme.darkTheme(),
      themeMode: themeMode,
      routerConfig: router,
    );
  }
}
