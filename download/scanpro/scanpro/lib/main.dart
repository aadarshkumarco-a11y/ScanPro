/// ScanPro application entry point.
///
/// Initializes all required services before the app starts:
/// - Firebase (Auth, Firestore, Storage)
/// - Hive local storage
/// - System UI configuration (status bar, orientation)
/// - Error handling (Flutter and zone-level)
library;

import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';

import 'app.dart';
import 'core/constants/app_constants.dart';
import 'core/constants/db_constants.dart';

void main() async {
  // Ensure Flutter binding is initialized before any async calls.
  WidgetsFlutterBinding.ensureInitialized();

  // Run the entire app inside a zone that catches all uncaught errors.
  await runZonedGuarded<Future<void>>(
    _initializeApp,
    (error, stackTrace) {
      // Report asynchronous errors to Crashlytics.
      if (!kDebugMode) {
        FirebaseCrashlytics.instance.recordError(error, stackTrace);
      }
    },
  );
}

/// Performs all initialization and then runs the app.
Future<void> _initializeApp() async {
  // ── 1. Firebase Initialization ────────────────────────────────
  await Firebase.initializeApp();

  // Pass all uncaught Flutter errors to Crashlytics in release mode.
  if (!kDebugMode) {
    FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;
    // Pass all uncaught async errors to Crashlytics.
    PlatformDispatcher.instance.onError = (error, stack) {
      FirebaseCrashlytics.instance.recordError(error, stack);
      return true;
    };
  }

  // ── 2. Hive Local Storage Initialization ──────────────────────
  final appDocumentDir = await getApplicationDocumentsDirectory();
  Hive.init(appDocumentDir.path);

  // Pre-open frequently used boxes for synchronous access later.
  await _openHiveBoxes();

  // ── 3. System UI Configuration ────────────────────────────────
  await _configureSystemUI();

  // ── 4. Run the App ────────────────────────────────────────────
  runApp(
    const ProviderScope(
      child: ScanProApp(),
    ),
  );
}

/// Pre-opens Hive boxes that are accessed synchronously throughout the app.
Future<void> _openHiveBoxes() async {
  await Hive.openBox(DbConstants.settingsBox);
  await Hive.openBox(DbConstants.preferencesBox);
  await Hive.openBox(DbConstants.authBox);
  await Hive.openBox(DbConstants.onboardingBox);
  await Hive.openBox(DbConstants.cacheBox);
}

/// Configures system chrome (status bar, navigation bar, orientation).
Future<void> _configureSystemUI() async {
  // Set preferred orientations for a document scanning app.
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);

  // Configure status bar and navigation bar appearance.
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      statusBarBrightness: Brightness.light,
      systemNavigationBarColor: Colors.transparent,
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
  );

  // Allow edge-to-edge layout.
  SystemChrome.setEnabledSystemUIMode(
    SystemUiMode.edgeToEdge,
  );
}
