import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mocktail/mocktail.dart';
import 'package:food_delivery_app/API Service/RazorpayApiService.dart';
import 'package:food_delivery_app/Buyer Bloc Architecture/WalletScreen/WalletScreen_UI.dart';
import 'package:food_delivery_app/Buyer Bloc Architecture/WalletScreen/WalletScreen_Bloc.dart';
import 'package:food_delivery_app/Buyer Bloc Architecture/WalletScreen/WalletScreen_State.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:async';

class MockWalletBloc extends Mock implements WalletBloc {}

class MockWalletDatabase extends Mock implements WalletDatabase {}

class MockRazorpayApiService extends Mock implements RazorpayApiService {}

class MockQuerySnapshot extends Mock implements QuerySnapshot {}

void main() {
  setUpAll(() {
    registerFallbackValue(WalletState());
  });

  group('WalletView Widget Tests', () {
    late MockWalletBloc mockWalletBloc;
    late MockWalletDatabase mockDatabase;
    late MockRazorpayApiService mockRazorpayApiService;
    late StreamController<DocumentSnapshot> walletStreamController;
    late StreamController<QuerySnapshot> transactionsStreamController;

    setUp(() {
      mockWalletBloc = MockWalletBloc();
      mockDatabase = MockWalletDatabase();
      mockRazorpayApiService = MockRazorpayApiService();

      walletStreamController = StreamController<DocumentSnapshot>();
      transactionsStreamController = StreamController<QuerySnapshot>();

      when(() => mockWalletBloc.state).thenReturn(WalletState());
      when(() => mockWalletBloc.stream).thenAnswer((_) => const Stream.empty());
      when(() => mockWalletBloc.database).thenReturn(mockDatabase);

      when(
        () => mockDatabase.getWalletStream(),
      ).thenAnswer((_) => walletStreamController.stream);
      when(
        () => mockDatabase.getTransactionsStream(),
      ).thenAnswer((_) => transactionsStreamController.stream);
      when(() => mockDatabase.currentUserEmail).thenReturn('test@test.com');

      when(
        () => mockRazorpayApiService.initialize(
          onSuccess: any(named: 'onSuccess'),
          onFailure: any(named: 'onFailure'),
        ),
      ).thenReturn(null);
    });

    tearDown(() {
      walletStreamController.close();
      transactionsStreamController.close();
    });

    Widget createWidgetUnderTest() {
      return MaterialApp(
        home: MultiRepositoryProvider(
          providers: [
            RepositoryProvider<RazorpayApiService>.value(
              value: mockRazorpayApiService,
            ),
          ],
          child: BlocProvider<WalletBloc>.value(
            value: mockWalletBloc,
            child: const Scaffold(body: WalletView()),
          ),
        ),
      );
    }

    testWidgets(
      'renders WalletScreen with Quick Top-up and Recent Transactions',
      (WidgetTester tester) async {
        await tester.pumpWidget(createWidgetUnderTest());
        await tester.pumpAndSettle();

        expect(find.text('Wallet'), findsOneWidget);
        expect(find.text('Quick Top-up'), findsOneWidget);
        expect(find.text('Recent Transactions'), findsOneWidget);
        expect(find.text('Add Money'), findsOneWidget);
      },
    );

    testWidgets('shows loading indicator when processing payment', (
      WidgetTester tester,
    ) async {
      when(
        () => mockWalletBloc.state,
      ).thenReturn(WalletState(isLoading: true, pendingAmount: 100));

      await tester.pumpWidget(createWidgetUnderTest());

      // Since Quick Amount Selection shows CircularProgressIndicator for selected amount
      expect(find.byType(CircularProgressIndicator), findsWidgets);
    });

    testWidgets(
      'opens Add Money Bottom Sheet when Add Money button is tapped',
      (WidgetTester tester) async {
        await tester.pumpWidget(createWidgetUnderTest());
        await tester.pumpAndSettle();

        await tester.tap(find.text('Add Money'));
        await tester.pumpAndSettle();

        expect(find.text('Enter Amount'), findsOneWidget);
        expect(find.text('Proceed'), findsOneWidget);
      },
    );

    testWidgets(
      'opens Confirmation Dialog when Quick Top-up amount is tapped',
      (WidgetTester tester) async {
        await tester.pumpWidget(createWidgetUnderTest());
        await tester.pumpAndSettle();

        // Tap on the ₹100 container
        await tester.tap(find.text('₹100'));
        await tester.pumpAndSettle();

        expect(find.text('Confirm Payment'), findsOneWidget);
        expect(find.text('Pay ₹100'), findsOneWidget);
      },
    );
  });
}
