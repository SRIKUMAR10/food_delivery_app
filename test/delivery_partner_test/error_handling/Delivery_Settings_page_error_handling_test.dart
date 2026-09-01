import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:food_delivery_app/features/Delivery Partner Bloc Architecture/Delivery_Settings_page/Delivery_Settings_page_bloc.dart';
import 'package:food_delivery_app/features/Delivery Partner Bloc Architecture/Delivery_Settings_page/Delivery_Settings_page_event.dart';
import 'package:food_delivery_app/features/Delivery Partner Bloc Architecture/Delivery_Settings_page/Delivery_Settings_page_repository.dart';
import 'package:food_delivery_app/features/Delivery Partner Bloc Architecture/Delivery_Settings_page/Delivery_Settings_page_service.dart';
import 'package:food_delivery_app/features/Delivery Partner Bloc Architecture/Delivery_Settings_page/Delivery_Settings_page_state.dart';
import 'package:food_delivery_app/features/Delivery Partner Bloc Architecture/Delivery_Settings_page/Delivery_Settings_page_ui.dart';
import '../../font_loader_helper.dart';

class MockDeliverySettingsRepository extends Mock
    implements DeliverySettingsRepositoryBase {}

class MockDeliverySettingsService extends Mock
    implements DeliverySettingsServiceBase {}

void main() {
  late MockDeliverySettingsRepository mockRepo;
  late MockDeliverySettingsService mockService;

  setUpAll(() {
    overrideFontAssetLoading();
  });

  setUp(() {
    mockRepo = MockDeliverySettingsRepository();
    mockService = MockDeliverySettingsService();
  });

  testWidgets('shows error state when network fails and retries on action', (tester) async {
    tester.view.physicalSize = const Size(1280, 1000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    when(() => mockService.checkNetworkConnectivity()).thenAnswer((_) async => false);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: DeliverySettingsPage(
            repository: mockRepo,
            service: mockService,
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('dp_settings_error')), findsOneWidget);
    expect(find.text('Network connection unavailable'), findsOneWidget);

    when(() => mockService.checkNetworkConnectivity()).thenAnswer((_) async => true);
    when(() => mockRepo.fetchSettings()).thenAnswer((_) async => const DeliverySettingsState(status: DeliverySettingsStatus.loaded));
    when(() => mockRepo.watchSettings()).thenAnswer((_) => const Stream.empty());

    await tester.tap(find.byKey(const Key('dp_settings_retry')));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('dp_settings_page')), findsOneWidget);
  });
}
