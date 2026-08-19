import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:food_delivery_app/features/Delivery%20Partner%20Bloc%20Architecture/Delivery_Wallet_page/Delivery_Wallet_page_bloc.dart';
import 'package:food_delivery_app/features/Delivery%20Partner%20Bloc%20Architecture/Delivery_Wallet_page/Delivery_Wallet_page_event.dart';
import 'package:food_delivery_app/features/Delivery%20Partner%20Bloc%20Architecture/Delivery_Wallet_page/Delivery_Wallet_page_repository.dart';
import 'package:food_delivery_app/features/Delivery%20Partner%20Bloc%20Architecture/Delivery_Wallet_page/Delivery_Wallet_page_service.dart';
import 'package:food_delivery_app/features/Delivery%20Partner%20Bloc%20Architecture/Delivery_Wallet_page/Delivery_Wallet_page_state.dart';
import 'package:food_delivery_app/features/Delivery%20Partner%20Bloc%20Architecture/Delivery_Wallet_page/Delivery_Wallet_page_ui.dart';

class MockWalletRepository extends Mock
    implements DeliveryWalletPageRepositoryBase {}

class MockWalletService extends Mock implements DeliveryWalletPageServiceBase {}

class MockWalletBloc
    extends MockBloc<DeliveryWalletPageEvent, DeliveryWalletPageState>
    implements DeliveryWalletPageBloc {}

void main() {
  test('default repository and service implement their contracts', () {
    expect(
      DeliveryWalletPageRepository(),
      isA<DeliveryWalletPageRepositoryBase>(),
    );
    expect(DeliveryWalletPageService(), isA<DeliveryWalletPageServiceBase>());
  });

  test('BLoC keeps injected repository and service references', () {
    final repository = MockWalletRepository();
    final service = MockWalletService();
    final bloc = DeliveryWalletPageBloc(
      repository: repository,
      service: service,
    );
    expect(bloc.repository, same(repository));
    expect(bloc.service, same(service));
    bloc.close();
  });

  testWidgets('page accepts an injected BLoC', (tester) async {
    tester.view.physicalSize = const Size(1280, 1000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    final bloc = MockWalletBloc();
    when(() => bloc.state).thenReturn(
      const DeliveryWalletPageState(status: DeliveryWalletStatus.loaded),
    );
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(body: DeliveryWalletPage(bloc: bloc)),
      ),
    );
    expect(find.byKey(const Key('dp_wallet_page')), findsOneWidget);
    expect(find.text('My Wallet'), findsWidgets);
  });
}
