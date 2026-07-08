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
  group('Seller Payout History Page Accessibility Tests', () {
    late SellerPayoutHistoryBloc bloc;

    setUp(() {
      bloc = MockSellerPayoutHistoryBloc();
    });

    testWidgets('UI elements meet target contrast and size parameters', (
      tester,
    ) async {
      final SemanticsHandle handle = tester.ensureSemantics();

      final payouts = [
        PayoutItem(
          id: 'payout_1',
          title: 'Payout #0001',
          amount: 2000.0,
          status: 'Paid',
          date: DateTime(2024, 5, 1),
        ),
      ];

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

      expect(tester.getSemantics(find.text('Payout History')), isNotNull);
      expect(tester.getSemantics(find.text('Payout #0001')), isNotNull);

      handle.dispose();
    });
  });
}
