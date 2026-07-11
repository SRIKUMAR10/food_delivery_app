import 'package:flutter_test/flutter_test.dart';
import 'package:golden_toolkit/golden_toolkit.dart';
import 'package:food_delivery_app/features/seller_bloc_architecture/new_order_notification/new_order_notification_ui.dart';
import 'package:food_delivery_app/features/seller_bloc_architecture/new_order_notification/new_order_notification_bloc.dart';
import 'package:food_delivery_app/features/seller_bloc_architecture/new_order_notification/new_order_notification_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mocktail/mocktail.dart';

class MockNewOrderNotificationBloc extends Mock
    implements NewOrderNotificationBloc {}

void main() {
  setUpAll(() => loadAppFonts());

  testGoldens('NewOrderNotification UI looks correct', (tester) async {
    final mockBloc = MockNewOrderNotificationBloc();
    when(() => mockBloc.stream).thenAnswer((_) => const Stream.empty());

    final orderData = {
      'orderId': '1025',
      'customer': 'Mike Ross',
      'itemsCount': 2,
      'amount': 780.0,
      'orderType': 'Delivery',
    };
    when(
      () => mockBloc.state,
    ).thenReturn(NewOrderNotificationLoaded(orderData));

    final builder = DeviceBuilder()
      ..overrideDevicesForAllScenarios(
        devices: [Device.phone, Device.iphone11, Device.tabletPortrait],
      )
      ..addScenario(
        widget: BlocProvider<NewOrderNotificationBloc>.value(
          value: mockBloc,
          child: const NewOrderNotificationView(orderId: '1025'),
        ),
        name: 'loaded_state',
      );

    await tester.pumpDeviceBuilder(builder);
    await screenMatchesGolden(tester, 'new_order_notification_ui');
  });
}
