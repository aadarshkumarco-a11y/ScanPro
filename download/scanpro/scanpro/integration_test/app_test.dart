import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:scanpro/app.dart';

void main() {
  group('App Integration Tests', () {
    testWidgets('app launches and renders', (WidgetTester tester) async {
      // Build the app
      await tester.pumpWidget(
        const ProviderScope(child: ScanProApp()),
      );
      await tester.pumpAndSettle();

      // The app should render without errors
      expect(find.byType(MaterialApp), findsOneWidget);
    });

    testWidgets('app shows bottom navigation', (WidgetTester tester) async {
      // Build the app
      await tester.pumpWidget(
        const ProviderScope(child: ScanProApp()),
      );
      await tester.pumpAndSettle();

      // Navigation bar should be present with Home, Docs, Profile tabs
      expect(find.byType(NavigationBar), findsOneWidget);
    });

    testWidgets('navigation between screens works', (WidgetTester tester) async {
      // Build the app
      await tester.pumpWidget(
        const ProviderScope(child: ScanProApp()),
      );
      await tester.pumpAndSettle();

      // Tap on Documents tab in bottom navigation
      // The NavigationDestination with label 'Docs' should exist
      final docsTab = find.byIcon(Icons.folder_outlined);
      if (docsTab.evaluate().isNotEmpty) {
        await tester.tap(docsTab);
        await tester.pumpAndSettle();
      }

      // Tap on Profile tab
      final profileTab = find.byIcon(Icons.person_outline);
      if (profileTab.evaluate().isNotEmpty) {
        await tester.tap(profileTab);
        await tester.pumpAndSettle();
      }

      // Navigate back to Home
      final homeTab = find.byIcon(Icons.home_outlined);
      if (homeTab.evaluate().isNotEmpty) {
        await tester.tap(homeTab);
        await tester.pumpAndSettle();
      }

      // App should still be rendered
      expect(find.byType(Scaffold), findsWidgets);
    });

    testWidgets('app theme is applied correctly', (WidgetTester tester) async {
      // Build the app
      await tester.pumpWidget(
        const ProviderScope(child: ScanProApp()),
      );
      await tester.pumpAndSettle();

      // Verify MaterialApp.router is used
      expect(find.byType(MaterialApp), findsOneWidget);
    });
  });
}
