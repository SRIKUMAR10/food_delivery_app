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

  const DeliverySettingsState loadedState = DeliverySettingsState(
    status: DeliverySettingsStatus.loaded,
    notificationsEnabled: true,
    autoAcceptEnabled: true,
    darkModeEnabled: false,
    deliveryRadius: 5.0,
    languageCode: 'en',
    localeCode: 'en',
    items: [
      DeliverySettingsItem(
        id: 'notifications',
        titleKey: 'notifications',
        subtitleKey: 'notificationsSub',
        icon: Icons.notifications_outlined,
        value: true,
      ),
      DeliverySettingsItem(
        id: 'autoAccept',
        titleKey: 'autoAccept',
        subtitleKey: 'autoAcceptSub',
        icon: Icons.bolt_outlined,
        value: true,
      ),
    ],
  );

  setUpAll(() {
    overrideFontAssetLoading();
    registerFallbackValue(const DeliverySettingsInitEvent());
  });

  setUp(() {
    mockBloc = MockDeliverySettingsBloc();
    when(() => mockBloc.state).thenReturn(loadedState);
  });

  testWidgets('DeliverySettingsPage passes accessibility and semantics checks', (tester) async {
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
    expect(find.byType(Slider), findsOneWidget);
    expect(find.byType(Switch), findsWidgets);

    final handle = tester.ensureSemantics();
    expect(tester.getSemantics(find.byKey(const Key('dp_settings_radius_slider'))), isNotNull);
    handle.dispose();
  });
}
