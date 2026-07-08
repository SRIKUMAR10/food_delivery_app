import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mocktail/mocktail.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:food_delivery_app/features/seller_bloc_architecture/seller_request_payout_page/seller_request_payout_page__ui.dart';
import 'package:food_delivery_app/features/seller_bloc_architecture/seller_request_payout_page/seller_request_payout_page__bloc.dart';
import 'package:food_delivery_app/features/seller_bloc_architecture/seller_request_payout_page/seller_request_payout_page__event.dart';
import 'package:food_delivery_app/features/seller_bloc_architecture/seller_request_payout_page/seller_request_payout_page__state.dart';

class MockSellerRequestPayoutBloc
    extends MockBloc<SellerRequestPayoutEvent, SellerRequestPayoutState>
    implements SellerRequestPayoutBloc {}

void main() {
  group('State Restoration Tests', () {
    late SellerRequestPayoutBloc bloc;

    setUp(() {
      bloc = MockSellerRequestPayoutBloc();
    });

    testWidgets(
      'retains loaded data when rebuilt during routing lifecycle events',
      (tester) async {
        when(() => bloc.state).thenReturn(
          const SellerRequestPayoutLoaded(
            balance: 12680.00,
            bankAccounts: ['HDFC Bank • 1234'],
          ),
        );

        await tester.pumpWidget(
          MaterialApp(
            home: BlocProvider<SellerRequestPayoutBloc>.value(
              value: bloc,
              child: const SellerRequestPayoutView(),
            ),
          ),
        );

        await tester.pumpAndSettle();
        expect(find.text('₹12,680.00'), findsOneWidget);

        // Re-trigger layout rebuild to simulate navigation cycles
        await tester.pumpWidget(
          MaterialApp(
            home: BlocProvider<SellerRequestPayoutBloc>.value(
              value: bloc,
              child: const SellerRequestPayoutView(),
            ),
          ),
        );

        await tester.pumpAndSettle();
        expect(find.text('₹12,680.00'), findsOneWidget);
      },
    );
  });
}
