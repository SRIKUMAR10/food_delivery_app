import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:food_delivery_app/features/Delivery Partner Bloc Architecture/Delivery_Dashboard_page/Delivery_Dashboard_page_bloc.dart';
import 'package:food_delivery_app/features/Delivery Partner Bloc Architecture/Delivery_Dashboard_page/Delivery_Dashboard_page_event.dart';
import 'package:food_delivery_app/features/Delivery Partner Bloc Architecture/Delivery_Dashboard_page/Delivery_Dashboard_page_repository.dart';
import 'package:food_delivery_app/features/Delivery Partner Bloc Architecture/Delivery_Dashboard_page/Delivery_Dashboard_page_state.dart';

class FakeDashboardRepository implements DeliveryDashboardRepositoryBase {
  @override
  Future<DeliveryDashboardState> loadDashboardData() async =>
      const DeliveryDashboardState();

  @override
  Stream<DeliveryDashboardState> watchDashboard() async* {
    yield const DeliveryDashboardState();
  }

  @override
  Future<bool> saveOnlineStatus(bool isOnline) async => isOnline;

  @override
  Future<void> updatePartnerStatus({
    required bool isOnline,
    bool? isAvailable,
    bool? isBusy,
    String? currentOrderId,
  }) async {}

  @override
  Future<bool> getOnlineStatus() async => false;
}

void main() {
  test('probe dashboard bloc transitions to loaded', () async {
    SharedPreferences.setMockInitialValues({});
    final bloc = DeliveryDashboardPageBloc(repository: FakeDashboardRepository());
    final states = <DeliveryDashboardStatus>[];
    final sub = bloc.stream.listen((s) => states.add(s.status));
    bloc.add(const DeliveryDashboardInitEvent());
    await Future<void>.delayed(const Duration(milliseconds: 100));
    expect(states, contains(DeliveryDashboardStatus.loaded));
    await sub.cancel();
    await bloc.close();
  });
}