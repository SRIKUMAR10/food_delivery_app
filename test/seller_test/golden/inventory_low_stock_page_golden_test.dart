import 'package:golden_toolkit/golden_toolkit.dart';
import 'package:food_delivery_app/features/seller_bloc_architecture/inventory_low_stock/inventory_low_stock_page_ui.dart';

void main() {
  testGoldens('InventoryLowStockPage should look correct', (tester) async {
    final builder = DeviceBuilder()
      ..overrideDevicesForAllScenarios(
        devices: [Device.phone, Device.tabletLandscape],
      )
      ..addScenario(
        widget: const InventoryLowStockPage(),
        name: 'default page',
      );

    await tester.pumpDeviceBuilder(builder);
    await screenMatchesGolden(tester, 'inventory_low_stock_page');
  });
}
