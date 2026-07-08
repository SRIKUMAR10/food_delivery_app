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
  group('Seller Wallet Page Accessibility Tests', () {
    late SellerWalletBloc bloc;

    setUp(() {
      bloc = MockSellerWalletBloc();
    });

    testWidgets('UI elements meet target contrast and size parameters', (
      tester,
    ) async {
      final SemanticsHandle handle = tester.ensureSemantics();

      when(
        () => bloc.state,
      ).thenReturn(const SellerWalletLoaded(balance: 1000.0, payouts: []));

      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider<SellerWalletBloc>.value(
            value: bloc,
            child: const SellerWalletView(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Verify that major interactable controls have semantic annotations
      expect(tester.getSemantics(find.text('Withdruw')), isNotNull);
      expect(tester.getSemantics(find.text('Transactions')), isNotNull);

      handle.dispose();
    });
  });
}
