import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mocktail/mocktail.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:food_delivery_app/features/seller_bloc_architecture/seller_payout_history_page/seller_payout_history_page__ui.dart';
import 'package:food_delivery_app/features/seller_bloc_architecture/seller_payout_history_page/seller_payout_history_page__bloc.dart';
import 'package:food_delivery_app/features/seller_bloc_architecture/seller_payout_history_page/seller_payout_history_page__event.dart';
import 'package:food_delivery_app/features/seller_bloc_architecture/seller_payout_history_page/seller_payout_history_page__state.dart';
import 'package:food_delivery_app/features/seller_bloc_architecture/seller_wallet_page/seller_wallet_page__state.dart';

class MockSellerPayoutHistoryBloc
    extends MockBloc<SellerPayoutHistoryEvent, SellerPayoutHistoryState>
    implements SellerPayoutHistoryBloc {}

void main() {
  group('Seller Payout History Page Performance Tests', () {
    late SellerPayoutHistoryBloc bloc;

    setUp(() {
      bloc = MockSellerPayoutHistoryBloc();
    });

    testWidgets(
      'ensures smooth performance during loading and input rendering',
      (tester) async {
        final payouts = List.generate(
          20,
          (index) => PayoutItem(
            id: 'payout_$index',
            title: 'Payout #00$index',
            amount: 1000.0 * index,
            status: 'Paid',
            date: DateTime(2024, 5, 1),
          ),
        );

        when(
          () => bloc.state,
        ).thenReturn(SellerPayoutHistoryLoaded(payouts: payouts));

        await tester.pumpWidget(
          MaterialApp(
            home: BlocProvider<SellerPayoutHistoryBloc>.value(
              value: bloc,
              child: const SellerPayoutHistoryView(),
            ),
          ),
        );

        await tester.pumpAndSettle();

        final listFinder = find.byType(Scrollable);
        expect(listFinder, findsOneWidget);

        await tester.drag(listFinder, const Offset(0.0, -100.0));
        await tester.pumpAndSettle();

        expect(find.byType(SellerPayoutHistoryView), findsOneWidget);
      },
    );
  });
}
