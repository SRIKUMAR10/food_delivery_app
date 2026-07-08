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
  group('Seller Request Payout Page Performance Tests', () {
    late SellerRequestPayoutBloc bloc;

    setUp(() {
      bloc = MockSellerRequestPayoutBloc();
    });

    testWidgets(
      'ensures smooth performance during loading and input rendering',
      (tester) async {
        when(() => bloc.state).thenReturn(
          const SellerRequestPayoutLoaded(
            balance: 12680.00,
            bankAccounts: [
              'HDFC Bank • 1234',
              'ICICI Bank • 5678',
              'SBI Bank • 9012',
            ],
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

        final listFinder = find.byType(Scrollable);
        expect(listFinder, findsOneWidget);

        await tester.drag(listFinder, const Offset(0.0, -100.0));
        await tester.pumpAndSettle();

        expect(find.byType(SellerRequestPayoutView), findsOneWidget);
      },
    );
  });
}
