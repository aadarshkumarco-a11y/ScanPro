import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:scanpro/features/home/presentation/pages/home_screen.dart';
import 'package:scanpro/features/home/presentation/providers/home_provider.dart';
import 'package:scanpro/features/home/presentation/widgets/quick_action_button.dart';
import 'package:scanpro/features/home/presentation/widgets/recent_document_card.dart';
import 'package:scanpro/features/home/presentation/widgets/storage_info_card.dart';
import 'package:scanpro/features/home/presentation/widgets/premium_banner.dart';

void main() {
  group('HomeScreen Widget Tests', () {
    Widget createHomeScreen() {
      return const ProviderScope(
        child: MaterialApp(
          home: HomeScreen(),
        ),
      );
    }

    testWidgets('renders greeting text', (WidgetTester tester) async {
      // act
      await tester.pumpWidget(createHomeScreen());
      await tester.pumpAndSettle();

      // assert
      expect(find.text('Good morning!'), findsOneWidget);
      expect(find.text('What would you like to do today?'), findsOneWidget);
    });

    testWidgets('renders quick action buttons', (WidgetTester tester) async {
      // act
      await tester.pumpWidget(createHomeScreen());
      await tester.pumpAndSettle();

      // assert - verify all 4 quick action labels are rendered
      expect(find.text('Scan'), findsOneWidget);
      expect(find.text('Import'), findsOneWidget);
      expect(find.text('QR Code'), findsOneWidget);
      expect(find.text('PDF Tools'), findsOneWidget);

      // Verify QuickActionButton widgets exist
      expect(find.byType(QuickActionButton), findsNWidgets(4));
    });

    testWidgets('renders recent documents section',
        (WidgetTester tester) async {
      // act
      await tester.pumpWidget(createHomeScreen());
      await tester.pumpAndSettle();

      // assert
      expect(find.text('Recent Documents'), findsOneWidget);
      expect(find.text('View All'), findsWidgets);

      // Verify recent document cards are rendered (5 mock documents)
      expect(find.byType(RecentDocumentCard), findsNWidgets(5));
    });

    testWidgets('renders premium banner', (WidgetTester tester) async {
      // act
      await tester.pumpWidget(createHomeScreen());
      await tester.pumpAndSettle();

      // assert
      expect(find.byType(PremiumBanner), findsOneWidget);
    });

    testWidgets('renders storage info card', (WidgetTester tester) async {
      // act
      await tester.pumpWidget(createHomeScreen());
      await tester.pumpAndSettle();

      // assert
      expect(find.byType(StorageInfoCard), findsOneWidget);
    });

    testWidgets('renders AI Insights card', (WidgetTester tester) async {
      // act
      await tester.pumpWidget(createHomeScreen());
      await tester.pumpAndSettle();

      // assert
      expect(find.text('AI Insights'), findsOneWidget);
      expect(find.text('Smart suggestions for you'), findsOneWidget);
    });

    testWidgets('renders favorites section when favorites exist',
        (WidgetTester tester) async {
      // act
      await tester.pumpWidget(createHomeScreen());
      await tester.pumpAndSettle();

      // assert - Mock data has 2 favorite documents
      expect(find.text('Favorites'), findsOneWidget);
    });

    testWidgets('renders notification badge with count',
        (WidgetTester tester) async {
      // act
      await tester.pumpWidget(createHomeScreen());
      await tester.pumpAndSettle();

      // assert
      expect(find.text('3'), findsOneWidget);
      expect(find.byIcon(Icons.notifications_outlined), findsOneWidget);
    });

    testWidgets('renders profile avatar', (WidgetTester tester) async {
      // act
      await tester.pumpWidget(createHomeScreen());
      await tester.pumpAndSettle();

      // assert
      expect(find.byIcon(Icons.person), findsOneWidget);
    });
  });
}
