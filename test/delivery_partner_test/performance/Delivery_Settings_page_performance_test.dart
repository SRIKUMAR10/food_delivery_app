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
      const DeliverySettingsState(status: DeliverySettingsStatus.loaded),
    );
  });

  testWidgets('DeliverySettingsPage renders within performance thresholds', (tester) async {
    final stopwatch = Stopwatch()..start();

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: DeliverySettingsPage(bloc: mockBloc),
        ),
      ),
    );
    await tester.pumpAndSettle();
    stopwatch.stop();

    expect(stopwatch.elapsedMilliseconds, lessThan(3000));
    expect(find.byKey(const Key('dp_settings_page')), findsOneWidget);
  });
}
