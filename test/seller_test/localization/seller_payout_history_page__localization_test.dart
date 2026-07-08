import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mocktail/mocktail.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:food_delivery_app/features/seller_bloc_architecture/seller_payout_history_page/seller_payout_history_page__ui.dart';
import 'package:food_delivery_app/features/seller_bloc_architecture/seller_payout_history_page/seller_payout_history_page__bloc.dart';
import 'package:food_delivery_app/features/seller_bloc_architecture/seller_payout_history_page/seller_payout_history_page__event.dart';
import 'package:food_delivery_app/features/seller_bloc_architecture/seller_payout_history_page/seller_payout_history_page__state.dart';
import 'package:food_delivery_app/features/seller_bloc_architecture/seller_wallet_page/seller_wallet_page__state.dart';

class MockSellerPayoutHistoryBloc
    extends MockBloc<SellerPayoutHistoryEvent, SellerPayoutHistoryState>
    implements SellerPayoutHistoryBloc {}

void main() {
  group('Seller Payout History Localization Tests', () {
    late SellerPayoutHistoryBloc bloc;

    setUp(() {
      bloc = MockSellerPayoutHistoryBloc();
    });

    Widget createLocalizedApp(Locale locale) {
      return MaterialApp(
        locale: locale,
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: [locale],
        home: BlocProvider<SellerPayoutHistoryBloc>.value(
          value: bloc,
          child: const SellerPayoutHistoryView(),
        ),
      );
    }

    testWidgets(
      'formats currency and dates correctly in Indian English locale',
      (tester) async {
        final payouts = [
          PayoutItem(
            id: 'payout_1',
            title: 'Payout #0001',
            amount: 12680.00,
            status: 'Paid',
            date: DateTime(2024, 5, 1),
          ),
        ];

        when(
          () => bloc.state,
        ).thenReturn(SellerPayoutHistoryLoaded(payouts: payouts));

        await tester.pumpWidget(createLocalizedApp(const Locale('en', 'IN')));
        await tester.pump(); // Start entry animation

        expect(find.text('₹12,680'), findsOneWidget);
      },
    );
  });
}
