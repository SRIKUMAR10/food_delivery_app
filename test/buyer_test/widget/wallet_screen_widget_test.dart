import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mocktail/mocktail.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:food_delivery_app/api_service/RazorpayApiService.dart';
import 'package:food_delivery_app/core/services/i_auth_service.dart';
import 'package:food_delivery_app/features/buyer_bloc_architecture/WalletScreen/WalletScreen_Bloc.dart';
import 'package:food_delivery_app/features/buyer_bloc_architecture/WalletScreen/WalletScreen_UI.dart';

class MockWalletDatabase extends Mock implements WalletDatabase {}
class MockRazorpayApiService extends Mock implements RazorpayApiService {}
class MockAuthService extends Mock implements IAuthService {}

void main() {
  group('Wallet Screen Widget Tests', () {
    late MockWalletDatabase mockDatabase;
    late MockRazorpayApiService mockRazorpay;
    late MockAuthService mockAuth;
    void Function(PaymentFailureResponse)? capturedOnFailure;
    void Function(PaymentSuccessResponse)? capturedOnSuccess;

    setUp(() {
      mockDatabase = MockWalletDatabase();
      mockRazorpay = MockRazorpayApiService();
      mockAuth = MockAuthService();

      when(() => mockAuth.currentUserId).thenReturn('test_buyer_123');
      when(() => mockAuth.authStateChanges)
          .thenAnswer((_) => Stream.value('test_buyer_123'));
      when(() => mockDatabase.authService).thenReturn(mockAuth);
      when(() => mockDatabase.getInitialBalance()).thenAnswer((_) async => 450.0);
      when(() => mockDatabase.getWalletBalanceStream())
          .thenAnswer((_) => Stream.value(450.0));
      when(() => mockDatabase.getTransactionsStream())
          .thenAnswer((_) => Stream.value([
                {
                  'amount': 450.0,
                  'title': 'Wallet Top-up',
                  'isCredit': true,
                  'status': 'success',
                  'createdAt': DateTime.now(),
                },
              ]));
      when(() => mockRazorpay.initialize(
            onSuccess: any(named: 'onSuccess'),
            onFailure: any(named: 'onFailure'),
          )).thenAnswer((invocation) {
            capturedOnSuccess = invocation.namedArguments[#onSuccess];
            capturedOnFailure = invocation.namedArguments[#onFailure];
          });
      when(() => mockRazorpay.startPayment(
            amount: any(named: 'amount'),
            email: any(named: 'email'),
            orderId: any(named: 'orderId'),
            name: any(named: 'name'),
            description: any(named: 'description'),
          )).thenAnswer((_) {});
    });

    Widget createTestWidget() {
      return MultiRepositoryProvider(
        providers: [
          RepositoryProvider<IAuthService>.value(value: mockAuth),
          RepositoryProvider<RazorpayApiService>.value(value: mockRazorpay),
        ],
        child: MaterialApp(
          home: BlocProvider(
            create: (_) => WalletBloc(mockDatabase, mockRazorpay),
            child: const Scaffold(
              body: SizedBox(
                width: 500,
                height: 1000,
                child: WalletView(),
              ),
            ),
          ),
        ),
      );
    }

    testWidgets('renders wallet balance, recharge options, and transactions', (tester) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      expect(find.text('Wallet'), findsWidgets);
      expect(find.text('Total Balance'), findsWidgets);
      expect(find.text('Quick Top-up'), findsWidgets);
      expect(find.text('Recent Transactions'), findsWidgets);
    });

    testWidgets('quick top-up chips selection updates button and toggles selection', (tester) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Initially, Add Money button is present with default text
      expect(find.text('Add Money'), findsOneWidget);

      // Tap on ₹500 chip
      final chip500 = find.text('₹500');
      expect(chip500, findsWidgets);
      await tester.tap(chip500.first);
      await tester.pumpAndSettle();

      // Button updates to 'Add ₹500' and chip shows 'Selected'
      expect(find.text('Add ₹500'), findsOneWidget);
      expect(find.text('Selected'), findsOneWidget);

      // Tap on ₹500 chip again to toggle / deselect
      await tester.tap(chip500.first);
      await tester.pumpAndSettle();

      // Reverts to default 'Add Money'
      expect(find.text('Add Money'), findsOneWidget);
    });

    testWidgets('tapping Add Money with selected chip initiates payment', (tester) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      when(() => mockRazorpay.createOrder(
            amount: any(named: 'amount'),
            receipt: any(named: 'receipt'),
          )).thenAnswer((_) async => {
            'orderId': 'order_123',
            'amount': 20000,
          });

      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Select ₹200 chip
      final chip200 = find.text('₹200');
      await tester.tap(chip200.first);
      await tester.pumpAndSettle();

      // Tap 'Add ₹200' button
      final addBtn = find.text('Add ₹200');
      expect(addBtn, findsOneWidget);
      await tester.tap(addBtn);
      await tester.pump();

      verify(() => mockRazorpay.createOrder(
            amount: 200.0,
            receipt: any(named: 'receipt'),
          )).called(1);
    });

    testWidgets('tapping Add Money without selection opens custom amount modal', (tester) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      final addMoneyBtn = find.text('Add Money');
      expect(addMoneyBtn, findsOneWidget);
      await tester.tap(addMoneyBtn);
      await tester.pumpAndSettle();

      // Custom amount bottom sheet elements
      expect(find.text('Enter Amount'), findsOneWidget);
      expect(find.text('Min: ₹10  |  Max: ₹50,000'), findsOneWidget);
      expect(find.text('Proceed'), findsOneWidget);
    });

    testWidgets('entering custom amount in modal initiates payment and preserves Add Money button for re-editing', (tester) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      when(() => mockRazorpay.createOrder(
            amount: any(named: 'amount'),
            receipt: any(named: 'receipt'),
          )).thenAnswer((_) async => {
            'orderId': 'order_8000',
            'amount': 800000,
          });

      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Open custom amount modal
      final addMoneyBtn = find.text('Add Money');
      await tester.tap(addMoneyBtn);
      await tester.pumpAndSettle();

      // Enter 8000
      final textField = find.byType(TextField);
      expect(textField, findsOneWidget);
      await tester.enterText(textField, '8000');
      await tester.pumpAndSettle();

      // Tap Proceed
      final proceedBtn = find.text('Proceed');
      await tester.tap(proceedBtn);
      await tester.pump();

      verify(() => mockRazorpay.createOrder(
            amount: 8000.0,
            receipt: any(named: 'receipt'),
          )).called(1);

      await tester.pump();

      // Simulate user clicking "Yes, exit" on Razorpay dialog (Payment Cancelled)
      capturedOnFailure?.call(PaymentFailureResponse(
        Razorpay.PAYMENT_CANCELLED,
        'Payment cancelled by user',
        null,
      ));

      await tester.pumpAndSettle();

      // The button should remain 'Add Money' so user can tap to re-enter or edit
      expect(find.text('Add Money'), findsOneWidget);
      expect(find.text('Add ₹8000'), findsNothing);

      // Tapping Add Money again opens the modal again cleanly
      await tester.tap(find.text('Add Money'));
      await tester.pumpAndSettle();
      expect(find.text('Enter Amount'), findsOneWidget);
    });
  });
}
