import 'package:flutter_test/flutter_test.dart';
import 'package:golden_toolkit/golden_toolkit.dart';
import 'package:flutter/material.dart';
import 'package:food_delivery_app/features/seller_bloc_architecture/seller_onboard_page/seller_onboard_page_ui.dart';

void main() {
  setUpAll(() async {
    await loadAppFonts();
  });

  group('SellerOnboardPageUI Golden Tests', () {
    testGoldens('Initial UI looks correct on multiple device sizes', (
      tester,
    ) async {
      final builder = DeviceBuilder()
        ..overrideDevicesForAllScenarios(
          devices: [
            Device.phone,
            Device.iphone11,
            Device.tabletPortrait,
            Device.tabletLandscape,
          ],
        )
        ..addScenario(
          widget: const MaterialApp(home: SellerOnboardPageUI()),
          name: 'initial_state',
        );

      await tester.pumpDeviceBuilder(builder);

      await screenMatchesGolden(tester, 'seller_onboard_page_initial');
    });
  });
}
