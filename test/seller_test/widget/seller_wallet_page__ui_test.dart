import 'package:firebase_core/firebase_core.dart';
import '../../mock_firebase.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mocktail/mocktail.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:food_delivery_app/features/seller_bloc_architecture/seller_wallet_page/seller_wallet_page__ui.dart';
import 'package:food_delivery_app/features/seller_bloc_architecture/seller_wallet_page/seller_wallet_page__bloc.dart';
import 'package:food_delivery_app/features/seller_bloc_architecture/seller_wallet_page/seller_wallet_page__event.dart';
import 'package:food_delivery_app/features/seller_bloc_architecture/seller_wallet_page/seller_wallet_page__state.dart';

class MockSellerWalletBloc
    extends MockBloc<SellerWalletEvent, SellerWalletState>
    implements SellerWalletBloc {}

void main() {
  setUpAll(() async {
    setupFirebaseAuthMocks();
    await Firebase.initializeApp();
  });

  group('SellerWalletPage Widget Tests', () {
    late SellerWalletBloc bloc;

    setUp(() {
      bloc = MockSellerWalletBloc();
    });

    Widget createTestWidget() {
      return MaterialApp(
        home: BlocProvider<SellerWalletBloc>.value(
          value: bloc,
          child: const SellerWalletView(),
        ),
      );
    }

    testWidgets('renders skeleton loader when state is loading', (
      tester,
    ) async {
      when(() => bloc.state).thenReturn(const SellerWalletLoading());

      await tester.pumpWidget(createTestWidget());

      expect(
        find.byKey(const ValueKey('loading_wallet_skeleton')),
        findsOneWidget,
      );
    });

    testWidgets('renders error message and retry button when state is error', (
      tester,
    ) async {
      when(
        () => bloc.state,
      ).thenReturn(const SellerWalletError('Some API failure'));

      await tester.pumpWidget(createTestWidget());

      expect(find.text('Failed to load Wallet'), findsOneWidget);
      expect(find.text('Some API failure'), findsOneWidget);
      expect(find.text('Retry'), findsOneWidget);
    });

    testWidgets('renders balance card and payout items when state is loaded', (
      tester,
    ) async {
      final payouts = [
        PayoutItem(
          id: '1',
          title: 'Payout #0002',
          amount: 4000.0,
          status: 'Paid',
          date: DateTime(2024, 5, 1),
        ),
      ];

      when(
        () => bloc.state,
      ).thenReturn(SellerWalletLoaded(balance: 12680.00, payouts: payouts));

      await tester.pumpWidget(createTestWidget());
      await tester.pump();

      expect(find.text('Available Balance'), findsOneWidget);
      expect(find.text('₹12,680.00'), findsOneWidget);
      expect(find.text('Withdruw'), findsOneWidget);
      expect(find.text('Transactions'), findsOneWidget);
      expect(find.text('Payout History'), findsOneWidget);
      expect(find.text('Payout #0002'), findsOneWidget);
    });
  });
}
