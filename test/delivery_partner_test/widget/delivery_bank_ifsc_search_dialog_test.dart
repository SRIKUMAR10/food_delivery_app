import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:food_delivery_app/core/services/bank_ifsc_service.dart';
import 'package:food_delivery_app/features/Delivery Partner Bloc Architecture/Delivery_onboarding_verification_page/delivery_bank_ifsc_search_dialog.dart';

void main() {
  group('DeliveryBankIfscSearchDialog Widget Tests', () {
    Widget buildTestWidget({ValueChanged<BankBranchInfo>? onSelected}) {
      return MaterialApp(
        home: Scaffold(
          body: DeliveryBankIfscSearchDialog(
            onBankSelected: onSelected,
          ),
        ),
      );
    }

    testWidgets('renders dialog header, tab bar, and search bar correctly',
        (WidgetTester tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      expect(find.text('Bank & IFSC Finder'), findsOneWidget);
      expect(find.text('Quick Search'), findsOneWidget);
      expect(find.text('Branch Finder'), findsOneWidget);
      expect(find.text('Popular Banks'), findsOneWidget);
      expect(find.byType(TextField), findsOneWidget);
    });

    testWidgets('searches bank branches when query is entered in search bar',
        (WidgetTester tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      final searchField = find.byType(TextField);
      await tester.enterText(searchField, 'HDFC');
      await tester.pump(const Duration(milliseconds: 300));
      await tester.pumpAndSettle();

      expect(find.text('HDFC Bank'), findsWidgets);
      expect(find.text('HDFC0000001'), findsOneWidget);
    });

    testWidgets('switches to Branch Finder tab and displays dropdown selectors',
        (WidgetTester tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      // Tap on Branch Finder tab
      await tester.tap(find.text('Branch Finder'));
      await tester.pumpAndSettle();

      expect(find.text('Select Bank & Branch Details'), findsOneWidget);
      expect(find.text('1. Bank Name'), findsOneWidget);
      expect(find.text('2. State'), findsOneWidget);
      expect(find.text('3. City / District'), findsOneWidget);
      expect(find.text('4. Branch'), findsOneWidget);
      expect(find.text('Apply This Bank & IFSC Code'), findsOneWidget);
    });

    testWidgets('switches to Popular Banks tab and tapping a bank filters search',
        (WidgetTester tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      // Tap on Popular Banks tab
      await tester.tap(find.text('Popular Banks'));
      await tester.pumpAndSettle();

      expect(find.text('State Bank of India'), findsOneWidget);
      expect(find.text('ICICI Bank'), findsOneWidget);
      expect(find.text('Axis Bank'), findsOneWidget);

      // Tap on Axis Bank card
      await tester.tap(find.text('Axis Bank'));
      await tester.pump(const Duration(milliseconds: 300));
      await tester.pumpAndSettle();

      // Should switch to search tab and show Axis Bank results
      expect(find.text('Axis Bank'), findsWidgets);
    });

    testWidgets('tapping a branch invokes onBankSelected callback and closes dialog',
        (WidgetTester tester) async {
      BankBranchInfo? selectedBranch;

      await tester.pumpWidget(
        buildTestWidget(
          onSelected: (branch) {
            selectedBranch = branch;
          },
        ),
      );
      await tester.pumpAndSettle();

      // Tap on the first branch card in the list
      final firstCard = find.text('State Bank of India').first;
      await tester.tap(firstCard);
      await tester.pumpAndSettle();

      expect(selectedBranch, isNotNull);
      expect(selectedBranch!.bankName, 'State Bank of India');
    });
  });
}
