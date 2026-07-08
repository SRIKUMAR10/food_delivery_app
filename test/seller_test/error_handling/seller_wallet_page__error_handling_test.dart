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
  group('Error Handling UI Tests', () {
    late SellerWalletBloc bloc;

    setUp(() {
      bloc = MockSellerWalletBloc();
    });

    testWidgets('triggers LoadWalletData event on clicking Retry button', (
      tester,
    ) async {
      when(
        () => bloc.state,
      ).thenReturn(const SellerWalletError('Network Timed Out'));

      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider<SellerWalletBloc>.value(
            value: bloc,
            child: const SellerWalletView(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Network Timed Out'), findsOneWidget);
      final retryButton = find.text('Retry');
      expect(retryButton, findsOneWidget);

      await tester.tap(retryButton);
      await tester.pumpAndSettle();

      verify(() => bloc.add(const LoadWalletData())).called(1);
    });
  });
}
