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

class MockPermissionRepository extends Mock
    implements DeliveryWalletPageRepositoryBase {}

class MockPermissionService extends Mock
    implements DeliveryWalletPageServiceBase {}

class MockPermissionBloc
    extends MockBloc<DeliveryWalletPageEvent, DeliveryWalletPageState>
    implements DeliveryWalletPageBloc {}

void main() {
  test('withdraw permission is enforced by balance validation', () async {
    final repository = MockPermissionRepository();
    final service = MockPermissionService();
    final bloc = DeliveryWalletPageBloc(
      repository: repository,
      service: service,
    );
    final states = <DeliveryWalletPageState>[];
    final subscription = bloc.stream.listen(states.add);
    bloc.emit(
      const DeliveryWalletPageState(status: DeliveryWalletStatus.loaded),
    );
    bloc.add(const DeliveryWalletWithdrawRequestedEvent(999999));
    await Future<void>.delayed(Duration.zero);
    expect(states.last.errorMessage, contains('exceeds'));
    verifyNever(() => repository.withdraw(any()));
    await subscription.cancel();
    await bloc.close();
  });

  testWidgets('authorized wallet role can reach the withdrawal action', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1280, 1000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    final bloc = MockPermissionBloc();
    when(() => bloc.state).thenReturn(
      const DeliveryWalletPageState(status: DeliveryWalletStatus.loaded),
    );
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(body: DeliveryWalletPage(bloc: bloc)),
      ),
    );
    expect(find.byKey(const Key('dp_wallet_withdraw_button')), findsOneWidget);
  });
}
