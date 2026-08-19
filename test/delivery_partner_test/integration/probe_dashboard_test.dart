import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:food_delivery_app/features/Delivery Partner Bloc Architecture/Delivery_Dashboard_page/Delivery_Dashboard_page_bloc.dart';
import 'package:food_delivery_app/features/Delivery Partner Bloc Architecture/Delivery_Dashboard_page/Delivery_Dashboard_page_event.dart';

void main() {
  testWidgets('probe dashboard bloc in widget env', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final bloc = DeliveryDashboardPageBloc();
    bloc.add(const DeliveryDashboardInitEvent());
    for (var i = 0; i < 20; i++) {
      await tester.pump(const Duration(milliseconds: 500));
      print('t${i * 500}: ${bloc.state.status}');
      if (bloc.state.status.toString().contains('loaded')) break;
    }
    print('FINAL: ${bloc.state.status}');
    await bloc.close();
  });
}
