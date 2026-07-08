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
  group('State Restoration Tests', () {
    late SellerWalletBloc bloc;

    setUp(() {
      bloc = MockSellerWalletBloc();
    });

    testWidgets(
      'retains loaded data when rebuilt during routing lifecycle events',
      (tester) async {
        when(
          () => bloc.state,
        ).thenReturn(const SellerWalletLoaded(balance: 7500.0, payouts: []));

        await tester.pumpWidget(
          MaterialApp(
            home: BlocProvider<SellerWalletBloc>.value(
              value: bloc,
              child: const SellerWalletView(),
            ),
          ),
        );

        await tester.pumpAndSettle();
        expect(find.text('₹7,500.00'), findsOneWidget);

        // Re-trigger layout rebuild to simulate navigation pop/push cycles
        await tester.pumpWidget(
          MaterialApp(
            home: BlocProvider<SellerWalletBloc>.value(
              value: bloc,
              child: const SellerWalletView(),
            ),
          ),
        );

        await tester.pumpAndSettle();
        expect(find.text('₹7,500.00'), findsOneWidget);
      },
    );
  });
}
