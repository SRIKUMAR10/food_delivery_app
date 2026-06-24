import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:food_delivery_app/features/buyer_bloc_architecture/WalletScreen/WalletScreen_UI.dart';
import 'package:food_delivery_app/features/buyer_bloc_architecture/WalletScreen/WalletScreen_Bloc.dart';
import 'package:food_delivery_app/features/buyer_bloc_architecture/WalletScreen/WalletScreen_State.dart';
import 'package:food_delivery_app/api_service/RazorpayApiService.dart';
import 'package:mocktail/mocktail.dart';

// Create a Mock Bloc
class MockWalletBloc extends Mock implements WalletBloc {
  @override
  WalletState get state => const WalletState();

  @override
  Stream<WalletState> get stream => const Stream.empty();

  @override
  WalletDatabase get database => MockWalletDatabase();
}

class MockWalletDatabase extends Mock implements WalletDatabase {
  @override
  Stream<DocumentSnapshot> getWalletStream() => const Stream.empty();

  @override
  Stream<QuerySnapshot> getTransactionsStream() => const Stream.empty();
}

class MockRazorpayApiService extends Mock implements RazorpayApiService {}

void main() {
  setUpAll(() {
    TestWidgetsFlutterBinding.ensureInitialized();
  });
  group('WalletScreen_UI Widget Tests', () {
    late MockWalletBloc mockWalletBloc;
    late MockRazorpayApiService mockRazorpayApiService;

    setUp(() {
      mockWalletBloc = MockWalletBloc();
      mockRazorpayApiService = MockRazorpayApiService();
      when(
        () => mockRazorpayApiService.initialize(
          onSuccess: any(named: 'onSuccess'),
          onFailure: any(named: 'onFailure'),
        ),
      ).thenAnswer((_) {});
    });

    Widget createWidgetUnderTest() {
      return MaterialApp(
        home: RepositoryProvider<RazorpayApiService>.value(
          value: mockRazorpayApiService,
          child: BlocProvider<WalletBloc>.value(
            value: mockWalletBloc,
            child: const WalletView(),
          ),
        ),
      );
    }

    testWidgets('displays Wallet title and Add Money button', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      expect(find.text('Wallet'), findsWidgets);
      expect(find.text('Add Money'), findsOneWidget);
      expect(find.text('Quick Top-up'), findsOneWidget);
    });

    testWidgets('renders Mobile layout on small screen', (
      WidgetTester tester,
    ) async {
      tester.view.physicalSize = const Size(400, 800);
      tester.view.devicePixelRatio = 1.0;

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      // Mobile layout should display quick top up amounts sequentially.
      expect(find.text('₹100'), findsOneWidget);

      // Reset view
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
    });

    testWidgets('renders Web/Wide layout on large screen', (
      WidgetTester tester,
    ) async {
      tester.view.physicalSize = const Size(1200, 800);
      tester.view.devicePixelRatio = 1.0;

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      // Desktop layout splits content into rows; verifying basic elements exist
      expect(find.text('Wallet'), findsWidgets);
      expect(find.text('Recent Transactions'), findsOneWidget);

      // Reset view
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
    });
  });
}
