import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:food_delivery_app/features/Delivery Partner Bloc Architecture/Delivery_Settings_page/Delivery_Settings_page_bloc.dart';
import 'package:food_delivery_app/features/Delivery Partner Bloc Architecture/Delivery_Settings_page/Delivery_Settings_page_event.dart';
import 'package:food_delivery_app/features/Delivery Partner Bloc Architecture/Delivery_Settings_page/Delivery_Settings_page_state.dart';
import 'package:food_delivery_app/features/Delivery Partner Bloc Architecture/Delivery_Settings_page/Delivery_Settings_page_ui.dart';
import '../../font_loader_helper.dart';

class MockDeliverySettingsBloc
    extends MockBloc<DeliverySettingsEvent, DeliverySettingsState>
    implements DeliverySettingsBloc {}

void main() {
  late MockDeliverySettingsBloc mockBloc;

  setUpAll(() {
    overrideFontAssetLoading();
  });

  setUp(() {
    mockBloc = MockDeliverySettingsBloc();
    when(() => mockBloc.state).thenReturn(
      const DeliverySettingsState(
        status: DeliverySettingsStatus.loaded,
        partnerId: 'DP-PRO-8842',
        vehicleType: 'Honda Activa 6G',
        vehicleNumber: 'TN-09-CB-4521',
        bankName: 'HDFC Bank',
        bankAccountNumber: '501004920',
        bankAccountStatus: 'Active',
      ),
    );
  });

  testWidgets('renders desktop and mobile layouts consistently', (tester) async {
    tester.view.physicalSize = const Size(1280, 1000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: DeliverySettingsPage(bloc: mockBloc),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('dp_settings_page')), findsOneWidget);
    expect(find.byKey(const Key('dp_settings_preferences_card')), findsOneWidget);
    expect(find.byKey(const Key('dp_settings_account_card')), findsOneWidget);
  });
}
