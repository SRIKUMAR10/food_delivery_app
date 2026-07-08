import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mocktail/mocktail.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:food_delivery_app/features/seller_bloc_architecture/seller_request_payout_page/seller_request_payout_page__ui.dart';
import 'package:food_delivery_app/features/seller_bloc_architecture/seller_request_payout_page/seller_request_payout_page__bloc.dart';
import 'package:food_delivery_app/features/seller_bloc_architecture/seller_request_payout_page/seller_request_payout_page__event.dart';
import 'package:food_delivery_app/features/seller_bloc_architecture/seller_request_payout_page/seller_request_payout_page__state.dart';

class MockSellerRequestPayoutBloc
    extends MockBloc<SellerRequestPayoutEvent, SellerRequestPayoutState>
    implements SellerRequestPayoutBloc {}

void main() {
  group('Seller Request Payout Localization Tests', () {
    late SellerRequestPayoutBloc bloc;

    setUp(() {
      bloc = MockSellerRequestPayoutBloc();
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
        home: BlocProvider<SellerRequestPayoutBloc>.value(
          value: bloc,
          child: const SellerRequestPayoutView(),
        ),
      );
    }

    testWidgets('formats currency correctly in US English locale', (
      tester,
    ) async {
      when(() => bloc.state).thenReturn(
        const SellerRequestPayoutLoaded(
          balance: 12680.00,
          bankAccounts: ['HDFC Bank • 1234'],
        ),
      );

      await tester.pumpWidget(createLocalizedApp(const Locale('en', 'US')));
      await tester.pumpAndSettle();

      expect(find.text('₹12,680.00'), findsOneWidget);
    });
  });
}
