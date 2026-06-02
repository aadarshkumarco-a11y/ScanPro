/// Main dependency injection container for ScanPro.
///
/// This file serves as the central registry for all Riverpod providers,
/// aggregating feature-specific modules and exposing core infrastructure
/// providers such as Firebase authentication, Hive storage, and network
/// connectivity monitoring.
///
/// Usage:
/// ```dart
///   // In main.dart
///   final container = ProviderContainer();
///   runApp(UncontrolledProviderContainer(container: container, child: App()));
/// ```
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

import 'modules/scanner_module.dart';
import 'modules/ocr_module.dart';
import 'modules/pdf_module.dart';
import 'modules/sync_module.dart';
import 'modules/security_module.dart';
import 'modules/ai_module.dart';

// ---------------------------------------------------------------------------
// Core Infrastructure Providers
// ---------------------------------------------------------------------------

/// Provides the [FirebaseAuth] singleton used across the app.
final firebaseAuthProvider = Provider<FirebaseAuth>((ref) {
  return FirebaseAuth.instance;
});

/// Reactive stream provider that emits the current [User] whenever the
/// Firebase authentication state changes. Emits `null` when signed out.
final authStateProvider = StreamProvider<User?>((ref) {
  return ref.watch(firebaseAuthProvider).authStateChanges();
});

/// Convenience provider that resolves to the currently signed-in [User],
/// or `null` if no user is authenticated.
final currentUserProvider = Provider<User?>((ref) {
  return ref.watch(authStateProvider).value;
});

/// Whether the user is currently authenticated (non-null user).
final isAuthenticatedProvider = Provider<bool>((ref) {
  return ref.watch(authStateProvider).value != null;
});

/// Provides the Hive [Box] used for general app preferences and cached data.
final hiveBoxProvider = Provider<Box>((ref) {
  throw UnimplementedError(
    'hiveBoxProvider must be overridden in main.dart with the opened box.',
  );
});

/// Provides the Hive [Box] dedicated to securely storing authentication
/// tokens and session data.
final authBoxProvider = Provider<Box>((ref) {
  throw UnimplementedError(
    'authBoxProvider must be overridden in main.dart with the opened box.',
  );
});

/// Provides [Connectivity] for monitoring network state changes.
final connectivityProvider = Provider<Connectivity>((ref) {
  return Connectivity();
});

/// Reactive stream of [ConnectivityResult] representing the current
/// network status. UI layers can watch this to react to connectivity changes.
final connectivityStateProvider = StreamProvider<ConnectivityResult>((ref) {
  return ref.watch(connectivityProvider).onConnectivityChanged;
});

/// Whether the device currently has any form of network connectivity.
final isOnlineProvider = Provider<bool>((ref) {
  final result = ref.watch(connectivityStateProvider).value;
  return result != null && result != ConnectivityResult.none;
});

// ---------------------------------------------------------------------------
// Module Re-exports
// All feature-specific providers are accessible through the modules below.
// ---------------------------------------------------------------------------

// Scanner module
export 'modules/scanner_module.dart';

// OCR module
export 'modules/ocr_module.dart';

// PDF module
export 'modules/pdf_module.dart';

// Sync module
export 'modules/sync_module.dart';

// Security module
export 'modules/security_module.dart';

// AI module
export 'modules/ai_module.dart';
