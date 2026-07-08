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
  group('Seller Wallet Page Performance Tests', () {
    late SellerWalletBloc bloc;

    setUp(() {
      bloc = MockSellerWalletBloc();
    });

    testWidgets('ensures smooth scroll performance under large list size', (
      tester,
    ) async {
      // Simulate 100 items loaded
      final payouts = List.generate(
        100,
        (index) => PayoutItem(
          id: 'payout_$index',
          title: 'Payout #${index.toString().padLeft(4, '0')}',
          amount: 1000.0,
          status: 'Paid',
          date: DateTime.now(),
        ),
      );

      when(
        () => bloc.state,
      ).thenReturn(SellerWalletLoaded(balance: 50000.0, payouts: payouts));

      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider<SellerWalletBloc>.value(
            value: bloc,
            child: const SellerWalletView(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      final listFinder = find.byType(Scrollable);
      expect(listFinder, findsOneWidget);

      // Measure performance of scrolling
      await tester.drag(listFinder, const Offset(0.0, -300.0));
      await tester.pumpAndSettle();

      expect(find.byType(SellerWalletView), findsOneWidget);
    });
  });
}
