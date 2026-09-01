import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:food_delivery_app/features/Delivery%20Partner%20Bloc%20Architecture/Delivery_Wallet_page/delivery_bank_details_page.dart';
import 'package:food_delivery_app/features/Delivery%20Partner%20Bloc%20Architecture/Delivery_Wallet_page/Delivery_Wallet_page_bloc.dart';
import 'package:food_delivery_app/features/Delivery%20Partner%20Bloc%20Architecture/Delivery_Wallet_page/Delivery_Wallet_page_event.dart';
import 'package:food_delivery_app/features/Delivery%20Partner%20Bloc%20Architecture/Delivery_Wallet_page/Delivery_Wallet_page_state.dart';

import '../../font_loader_helper.dart';

class MockDeliveryWalletPageBloc
    extends MockBloc<DeliveryWalletPageEvent, DeliveryWalletPageState>
    implements DeliveryWalletPageBloc {}

void main() {
  late MockDeliveryWalletPageBloc mockBloc;

  setUpAll(() {
    overrideFontAssetLoading();
  });

  setUp(() {
    mockBloc = MockDeliveryWalletPageBloc();
  });

  tearDown(() {
    mockBloc.close();
  });

  final now = DateTime(2026, 8, 15, 10, 30);

  final loadedStateWithBank = DeliveryWalletPageState(
    status: DeliveryWalletStatus.loaded,
    walletBalance: 15400.0,
    withdrawableAmount: 15300.0,
    totalWithdrawn: 45000.0,
    localeCode: 'en',
    bankAccount: const DeliveryBankAccount(
      bankName: 'HDFC Bank',
      accountHolder: 'Ravi Kumar',
      maskedAccountNumber: '•••• •••• 4821',
      ifscCode: 'HDFC0001234',
      isVerified: true,
    ),
    paymentMethods: const [
      DeliveryPaymentMethod(
        id: 'pm_upi_1',
        type: 'UPI',
        label: 'Google Pay',
        maskedIdentifier: 'ravi@okhdfcbank',
        isDefault: true,
      ),
    ],
    transactions: [
      DeliveryWalletTransaction(
        id: 'tx_payout_1',
        title: 'Bank Payout Settlement',
        date: now,
        amount: -5000.0,
        type: 'withdrawal',
        status: 'completed',
      ),
      DeliveryWalletTransaction(
        id: 'tx_payout_2',
        title: 'Instant Bank Transfer',
        date: now.subtract(const Duration(days: 1)),
        amount: -2500.0,
        type: 'withdrawal',
        status: 'processing',
      ),
      DeliveryWalletTransaction(
        id: 'tx_earning_1',
        title: 'Order Delivery Fare',
        date: now,
        amount: 150.0,
        type: 'income',
        status: 'completed',
      ),
    ],
  );

  final emptyBankState = const DeliveryWalletPageState(
    status: DeliveryWalletStatus.loaded,
    walletBalance: 0.0,
    withdrawableAmount: 0.0,
    totalWithdrawn: 0.0,
    localeCode: 'en',
    bankAccount: null,
    paymentMethods: [],
    transactions: [],
  );

  Widget createTestWidget({
    DeliveryWalletPageState? state,
    Size size = const Size(1200, 900),
  }) {
    when(() => mockBloc.state).thenReturn(state ?? loadedStateWithBank);
    when(() => mockBloc.stream).thenAnswer((_) => Stream.value(state ?? loadedStateWithBank));

    return MaterialApp(
      home: MediaQuery(
        data: MediaQueryData(size: size),
        child: Scaffold(
          body: DeliveryBankDetailsPage(bloc: mockBloc),
        ),
      ),
    );
  }

  group('DeliveryBankDetailsPage Widget Tests', () {
    testWidgets('renders skeleton loader when status is loading', (tester) async {
      tester.view.physicalSize = const Size(1200, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(
        createTestWidget(
          state: const DeliveryWalletPageState(status: DeliveryWalletStatus.loading),
        ),
      );
      await tester.pump();

      expect(find.byType(DeliveryBankDetailsPage), findsOneWidget);
      expect(find.byKey(const Key('dp_bank_details_page')), findsNothing);
    });

    testWidgets('renders error shell and triggers retry on error state', (tester) async {
      tester.view.physicalSize = const Size(1200, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(
        createTestWidget(
          state: const DeliveryWalletPageState(
            status: DeliveryWalletStatus.error,
            errorMessage: 'Network connection lost',
          ),
        ),
      );
      await tester.pump();

      expect(find.text('Network connection lost'), findsOneWidget);
      expect(find.text('Retry'), findsOneWidget);

      await tester.tap(find.text('Retry'));
      await tester.pump();

      verify(() => mockBloc.add(const DeliveryWalletInitEvent())).called(1);
    });

    testWidgets('renders full bank details screen on desktop layout', (tester) async {
      tester.view.physicalSize = const Size(1200, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('dp_bank_details_header')), findsOneWidget);
      expect(find.text('Bank Details & Payouts'), findsOneWidget);
      expect(find.text('HDFC Bank'), findsWidgets);
      expect(find.text('Ravi Kumar'), findsWidgets);
      expect(find.text('HDFC0001234'), findsOneWidget);
      expect(find.text('•••• •••• 4821'), findsWidgets);
      expect(find.text('ravi@okhdfcbank'), findsWidgets);
      expect(find.text('₹15300.00'), findsOneWidget);
      expect(find.text('₹45000.00'), findsOneWidget);
      expect(find.text('256-bit Bank Grade Security'), findsOneWidget);
      expect(find.text('Payout & Settlement Rules'), findsOneWidget);
    });

    testWidgets('renders filtered payout settlements and excludes order income', (tester) async {
      tester.view.physicalSize = const Size(1200, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('dp_bank_settlements_card')), findsOneWidget);
      // Payouts should be visible
      expect(find.text('Bank Payout Settlement'), findsOneWidget);
      expect(find.text('Instant Bank Transfer'), findsOneWidget);
      // Order Delivery Fare must be filtered OUT of bank details screen!
      expect(find.text('Order Delivery Fare'), findsNothing);
    });

    testWidgets('renders prompt when no bank account is linked', (tester) async {
      tester.view.physicalSize = const Size(1200, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(createTestWidget(state: emptyBankState));
      await tester.pumpAndSettle();

      expect(
        find.text(
          'No bank account linked yet. Tap "Update Bank Account" to link your payout account.',
        ),
        findsOneWidget,
      );
      expect(find.text('Not Linked'), findsWidgets);
    });

    testWidgets('renders properly on Mobile screen width', (tester) async {
      tester.view.physicalSize = const Size(400, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(
        createTestWidget(size: const Size(400, 800)),
      );
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('dp_bank_details_header')), findsOneWidget);
      expect(find.byKey(const Key('dp_bank_primary_card')), findsOneWidget);
      expect(find.byKey(const Key('dp_bank_settlements_card')), findsOneWidget);
    });

    testWidgets('renders Tamil localization correctly', (tester) async {
      tester.view.physicalSize = const Size(1200, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      final tamilState = loadedStateWithBank.copyWith(localeCode: 'ta');

      await tester.pumpWidget(createTestWidget(state: tamilState));
      await tester.pumpAndSettle();

      expect(find.text('வங்கி விவரங்கள் & தீர்வு அமைப்புகள்'), findsOneWidget);
      expect(find.text('முதன்மை வங்கி கணக்கு'), findsOneWidget);
      expect(find.text('உடனடி UPI Payout ஐடி'), findsWidgets);
      expect(find.text('சரிபார்க்கப்பட்டது'), findsWidgets);
      expect(find.text('வங்கி தரத்திலான 256-பிட் பாதுகாப்பு'), findsOneWidget);
    });
  });
}
