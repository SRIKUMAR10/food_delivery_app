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
  group('Seller Wallet Flow Integration Tests', () {
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

    testWidgets('Withdrawal flow succeeds visually', (tester) async {
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
      ).thenReturn(SellerWalletLoaded(balance: 10000.0, payouts: payouts));

      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Tap on Withdruw button
      await tester.tap(find.text('Withdruw'));
      await tester.pumpAndSettle();

      // Dialog should open
      expect(find.text('Withdraw Funds'), findsOneWidget);
      expect(find.text('Withdraw'), findsOneWidget);

      // Enter amount
      await tester.enterText(find.byType(TextFormField), '2000.0');
      await tester.pumpAndSettle();

      // Tap Withdraw in dialog
      await tester.tap(find.text('Withdraw'));
      await tester.pumpAndSettle();

      verify(() => bloc.add(const InitiateWithdrawal(2000.0))).called(1);
    });
  });
}
