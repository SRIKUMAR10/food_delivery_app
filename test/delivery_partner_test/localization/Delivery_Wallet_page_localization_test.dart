import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:food_delivery_app/features/Delivery%20Partner%20Bloc%20Architecture/Delivery_Wallet_page/Delivery_Wallet_page_bloc.dart';
import 'package:food_delivery_app/features/Delivery%20Partner%20Bloc%20Architecture/Delivery_Wallet_page/Delivery_Wallet_page_event.dart';
import 'package:food_delivery_app/features/Delivery%20Partner%20Bloc%20Architecture/Delivery_Wallet_page/Delivery_Wallet_page_state.dart';
import 'package:food_delivery_app/features/Delivery%20Partner%20Bloc%20Architecture/Delivery_Wallet_page/Delivery_Wallet_page_ui.dart';

class MockWalletBloc
    extends MockBloc<DeliveryWalletPageEvent, DeliveryWalletPageState>
    implements DeliveryWalletPageBloc {}

void main() {
  late MockWalletBloc bloc;

  setUp(() {
    bloc = MockWalletBloc();
    when(() => bloc.state).thenReturn(
      const DeliveryWalletPageState(
        status: DeliveryWalletStatus.loaded,
        localeCode: 'en',
      ),
    );
  });

  Widget page() => MaterialApp(
    home: Scaffold(body: DeliveryWalletPage(bloc: bloc)),
  );

  void desktop(WidgetTester tester) {
    tester.view.physicalSize = const Size(1280, 1000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
  }

  group('DeliveryWalletPage Localization Tests', () {
    testWidgets('renders English strings by default', (tester) async {
      desktop(tester);
      await tester.pumpWidget(page());
      expect(find.text('My Wallet'), findsWidgets);
      expect(find.text('Transaction History'), findsOneWidget);
      expect(find.text('Payment Methods'), findsOneWidget);
    });

    testWidgets('renders Tamil strings when state locale is Tamil', (
      tester,
    ) async {
      desktop(tester);
      when(() => bloc.state).thenReturn(
        const DeliveryWalletPageState(
          status: DeliveryWalletStatus.loaded,
          localeCode: 'ta',
        ),
      );
      await tester.pumpWidget(page());
      expect(find.text('என் வாலட்'), findsWidgets);
      expect(find.text('பரிவர்த்தனை வரலாறு'), findsOneWidget);
      expect(find.text('கட்டண முறைகள்'), findsOneWidget);
    });

    test('unknown locale lookup falls back to English', () {
      expect(DeliveryWalletStrings.of('walletTitle', 'fr'), 'My Wallet');
      expect(DeliveryWalletStrings.of('withdraw', 'hi'), 'Withdraw');
    });
  });
}
