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
  group('Security Permission Verification Tests', () {
    late SellerWalletBloc bloc;

    setUp(() {
      bloc = MockSellerWalletBloc();
    });

    testWidgets(
      'shows unauthorized warning when state is restricted or forbidden error occurs',
      (tester) async {
        // Simulate permission exception state
        when(() => bloc.state).thenReturn(
          const SellerWalletError('403 Forbidden: Seller access revoked'),
        );

        await tester.pumpWidget(
          MaterialApp(
            home: BlocProvider<SellerWalletBloc>.value(
              value: bloc,
              child: const SellerWalletView(),
            ),
          ),
        );

        await tester.pumpAndSettle();

        expect(
          find.text('403 Forbidden: Seller access revoked'),
          findsOneWidget,
        );
      },
    );
  });
}
