import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mocktail/mocktail.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:food_delivery_app/features/seller_bloc_architecture/seller_wallet_page/seller_wallet_page__ui.dart';
import 'package:food_delivery_app/features/seller_bloc_architecture/seller_wallet_page/seller_wallet_page__bloc.dart';
import 'package:food_delivery_app/features/seller_bloc_architecture/seller_wallet_page/seller_wallet_page__event.dart';
import 'package:food_delivery_app/features/seller_bloc_architecture/seller_wallet_page/seller_wallet_page__state.dart';

import '../../font_loader_helper.dart';

class MockSellerWalletBloc
    extends MockBloc<SellerWalletEvent, SellerWalletState>
    implements SellerWalletBloc {}

void main() {
  setUpAll(() {
    overrideFontAssetLoading();
  });

  group('Seller Wallet Page Golden Tests', () {
    late SellerWalletBloc bloc;

    setUp(() {
      bloc = MockSellerWalletBloc();
    });

    testWidgets('Golden Test - Loaded Wallet View', (tester) async {
      when(() => bloc.state).thenReturn(
        SellerWalletLoaded(
          balance: 12680.00,
          payouts: [
            PayoutItem(
              id: '1',
              title: 'Payout #0002',
              amount: 4000.0,
              status: 'Paid',
              date: DateTime(2024, 5, 1),
            ),
          ],
        ),
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

      await expectLater(
        find.byType(SellerWalletView),
        matchesGoldenFile('goldens/seller_wallet_loaded.png'),
      );
    });
  });
}
