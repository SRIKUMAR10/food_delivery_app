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
  group('Seller Wallet Snapshot Tree Tests', () {
    late SellerWalletBloc bloc;

    setUp(() {
      bloc = MockSellerWalletBloc();
    });

    testWidgets('loaded state matches exact structural layout snapshots', (
      tester,
    ) async {
      when(
        () => bloc.state,
      ).thenReturn(const SellerWalletLoaded(balance: 12680.00, payouts: []));

      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider<SellerWalletBloc>.value(
            value: bloc,
            child: const SellerWalletView(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Assert precise widget tree properties
      final balanceText = find.text('₹12,680.00');
      expect(balanceText, findsOneWidget);

      final Text textWidget = tester.widget(balanceText);
      expect(textWidget.style?.fontWeight, FontWeight.w800);
      expect(textWidget.style?.color, const Color(0xFF0F172A));
    });
  });
}
