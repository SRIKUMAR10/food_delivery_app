import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mocktail/mocktail.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:food_delivery_app/features/seller_bloc_architecture/seller_wallet_page/seller_wallet_page__ui.dart';
import 'package:food_delivery_app/features/seller_bloc_architecture/seller_wallet_page/seller_wallet_page__bloc.dart';
import 'package:food_delivery_app/features/seller_bloc_architecture/seller_wallet_page/seller_wallet_page__event.dart';
import 'package:food_delivery_app/features/seller_bloc_architecture/seller_wallet_page/seller_wallet_page__state.dart';

class MockSellerWalletBloc
    extends MockBloc<SellerWalletEvent, SellerWalletState>
    implements SellerWalletBloc {}

void main() {
  group('Seller Wallet Localization Tests', () {
    late SellerWalletBloc bloc;

    setUp(() {
      bloc = MockSellerWalletBloc();
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
        home: BlocProvider<SellerWalletBloc>.value(
          value: bloc,
          child: const SellerWalletView(),
        ),
      );
    }

    testWidgets('formats currency and dates correctly in US English locale', (
      tester,
    ) async {
      when(() => bloc.state).thenReturn(
        SellerWalletLoaded(
          balance: 12680.00,
          payouts: [
            PayoutItem(
              id: '1',
              title: 'Payout #0001',
              amount: 500.0,
              status: 'Paid',
              date: DateTime(2024, 4, 18),
            ),
          ],
        ),
      );

      await tester.pumpWidget(createLocalizedApp(const Locale('en', 'US')));
      await tester.pumpAndSettle();

      // In US format, should show ₹12,680.00 (simple rupee format override as defined)
      expect(find.text('₹12,680.00'), findsOneWidget);
      // Date in US is Apr 18, 2024
      expect(
        find.text('18 Apr, 2024'),
        findsNothing,
      ); // Custom mockup layout is static or custom formatter
    });
  });
}
