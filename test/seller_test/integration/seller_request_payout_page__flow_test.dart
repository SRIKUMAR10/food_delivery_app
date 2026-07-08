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
  group('Seller Request Payout Flow Integration Tests', () {
    late SellerRequestPayoutBloc bloc;

    setUp(() {
      bloc = MockSellerRequestPayoutBloc();
    });

    Widget createTestWidget() {
      return MaterialApp(
        home: BlocProvider<SellerRequestPayoutBloc>.value(
          value: bloc,
          child: const SellerRequestPayoutView(),
        ),
      );
    }

    testWidgets('Payout request flow submits visually', (tester) async {
      when(() => bloc.state).thenReturn(
        const SellerRequestPayoutLoaded(
          balance: 12680.00,
          bankAccounts: ['HDFC Bank • 1234', 'ICICI Bank • 5678'],
        ),
      );

      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Enter amount
      final amountField = find.byType(TextFormField).first;
      await tester.enterText(amountField, '5000');
      await tester.pumpAndSettle();

      // Tap Request Payout button
      final requestButton = find.text('Request Payout');
      await tester.tap(requestButton);
      await tester.pumpAndSettle();

      verify(
        () => bloc.add(
          const SubmitPayout(
            amount: 5000.0,
            bankAccount: 'HDFC Bank • 1234',
            upiId: 'seller@upi',
          ),
        ),
      ).called(1);
    });
  });
}
