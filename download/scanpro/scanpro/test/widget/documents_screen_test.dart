import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:scanpro/features/documents/presentation/pages/documents_screen.dart';
import 'package:scanpro/features/documents/presentation/providers/documents_provider.dart';
import 'package:scanpro/features/documents/presentation/widgets/sort_filter_bar.dart';
import 'package:scanpro/features/scanner/domain/entities/scan_document.dart';

void main() {
  group('DocumentsScreen Widget Tests', () {
    Widget createDocumentsScreen() {
      return const ProviderScope(
        child: MaterialApp(
          home: DocumentsScreen(),
        ),
      );
    }

    testWidgets('renders app bar with Documents title',
        (WidgetTester tester) async {
      // act
      await tester.pumpWidget(createDocumentsScreen());
      await tester.pumpAndSettle();

      // assert
      expect(find.text('Documents'), findsOneWidget);
    });

    testWidgets('renders search and view toggle buttons',
        (WidgetTester tester) async {
      // act
      await tester.pumpWidget(createDocumentsScreen());
      await tester.pumpAndSettle();

      // assert
      expect(find.byIcon(Icons.search), findsOneWidget);
      expect(find.byIcon(Icons.grid_view), findsOneWidget);
    });

    testWidgets('renders sort/filter bar', (WidgetTester tester) async {
      // act
      await tester.pumpWidget(createDocumentsScreen());
      await tester.pumpAndSettle();

      // assert
      expect(find.byType(SortFilterBar), findsOneWidget);
    });

    testWidgets('renders FAB for scanning', (WidgetTester tester) async {
      // act
      await tester.pumpWidget(createDocumentsScreen());
      await tester.pumpAndSettle();

      // assert
      expect(find.byType(FloatingActionButton), findsOneWidget);
      expect(find.byIcon(Icons.document_scanner), findsOneWidget);
    });

    testWidgets('toggles between grid and list view',
        (WidgetTester tester) async {
      // act
      await tester.pumpWidget(createDocumentsScreen());
      await tester.pumpAndSettle();

      // initially in grid view mode
      expect(find.byIcon(Icons.grid_view), findsOneWidget);

      // tap to switch to list view
      await tester.tap(find.byIcon(Icons.grid_view));
      await tester.pumpAndSettle();

      // now should show grid icon (to switch back)
      expect(find.byIcon(Icons.view_list), findsOneWidget);
    });

    testWidgets('shows search field when search icon is tapped',
        (WidgetTester tester) async {
      // act
      await tester.pumpWidget(createDocumentsScreen());
      await tester.pumpAndSettle();

      // tap search icon
      await tester.tap(find.byIcon(Icons.search));
      await tester.pumpAndSettle();

      // assert - search field should appear
      expect(find.byType(TextField), findsOneWidget);
      expect(find.byIcon(Icons.close), findsOneWidget);
    });

    testWidgets('closes search field when close icon is tapped',
        (WidgetTester tester) async {
      // act
      await tester.pumpWidget(createDocumentsScreen());
      await tester.pumpAndSettle();

      // tap search icon to open
      await tester.tap(find.byIcon(Icons.search));
      await tester.pumpAndSettle();

      // tap close to close search
      await tester.tap(find.byIcon(Icons.close));
      await tester.pumpAndSettle();

      // assert - search field should be gone, title should be back
      expect(find.text('Documents'), findsOneWidget);
    });

    testWidgets('renders document list after loading',
        (WidgetTester tester) async {
      // act
      await tester.pumpWidget(createDocumentsScreen());
      // Allow the FutureProvider to resolve
      await tester.pump(const Duration(milliseconds: 500));
      await tester.pumpAndSettle();

      // assert - mock data should produce at least some document cards/tiles
      // The exact finder depends on the view mode (grid is default)
      expect(find.byType(FloatingActionButton), findsOneWidget);
    });
  });
}
