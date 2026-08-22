import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:food_delivery_app/features/Delivery%20Partner%20Bloc%20Architecture/Delivery_Navigation%20Screen_page/Delivery_Navigation%20Screen_page_repository.dart';
import 'package:food_delivery_app/features/Delivery%20Partner%20Bloc%20Architecture/Delivery_Navigation%20Screen_page/Delivery_Navigation%20Screen_page_service.dart';

class MockDeliveryNavigationService extends Mock
    implements DeliveryNavigationServiceBase {}

void main() {
  late DeliveryNavigationRepository repository;
  late MockDeliveryNavigationService mockService;

  Map<String, dynamic> buildOrderPayload() => {
        'orderId': '78945',
        'sellerName': 'Reliance Digital Store, 23, Whites Road, Royapettah, Chennai',
        'sellerAddress': '23, Whites Road, Royapettah, Chennai',
        'customerName': 'Arun Kumar',
        'customerPhone': '+91 98765 43210',
        'deliveryAddress': '45, 3rd Cross Street, Anna Nagar West, Chennai',
        'status': 'On the Way',
      };

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    mockService = MockDeliveryNavigationService();
    repository = DeliveryNavigationRepository(prefs: prefs, service: mockService);
  });

  group('DeliveryNavigationRepository Unit Tests', () {
    test('fetchOrderSummary maps the active order payload into a summary', () async {
      when(() => mockService.fetchActiveOrder()).thenAnswer(
        (_) async => buildOrderPayload(),
      );
      final order = await repository.fetchOrderSummary();

      expect(order.orderId, '#78945');
      expect(order.pickupLabel, 'Reliance Digital Store, 23, Whites Road, Royapettah, Chennai');
      expect(order.pickupAddress, '23, Whites Road, Royapettah, Chennai');
      expect(order.dropLabel, 'Arun Kumar');
      expect(
        order.dropAddress,
        '45, 3rd Cross Street, Anna Nagar West, Chennai',
      );
      expect(order.customerName, 'Arun Kumar');
      expect(order.customerPhone, '+91 98765 43210');
      expect(order.status, 'On the Way');
    });

    test('fetchPickup and fetchDrop return Chennai route points', () async {
      when(() => mockService.fetchActiveOrder()).thenAnswer(
        (_) async => buildOrderPayload(),
      );
      final pickup = await repository.fetchPickup();
      final drop = await repository.fetchDrop();

      expect(pickup.iconKey, 'pickup');
      expect(pickup.label, 'Pickup');
      expect(pickup.address, contains('Whites Road'));
      expect(drop.iconKey, 'drop');
      expect(drop.label, 'Drop');
      expect(drop.address, contains('Anna Nagar West'));
    });

    test('defaultOrder and defaultPickup constants are consistent', () {
      expect(DeliveryNavigationRepository.defaultOrder.orderId, '#ORD-789456');
      expect(DeliveryNavigationRepository.defaultPickup.label, 'Pickup');
      expect(DeliveryNavigationRepository.defaultDrop.label, 'Drop');
    });

    test('audio guidance preference persists across instances', () async {
      expect(await repository.getAudioEnabled(), isFalse);

      await repository.saveAudioEnabled(true);
      expect(await repository.getAudioEnabled(), isTrue);

      final restored = DeliveryNavigationRepository();
      expect(await restored.getAudioEnabled(), isTrue);
    });

    test('emergency mode persists across instances', () async {
      expect(await repository.getEmergencyMode(), isFalse);

      await repository.saveEmergencyMode(true);
      expect(await repository.getEmergencyMode(), isTrue);

      final restored = DeliveryNavigationRepository();
      expect(await restored.getEmergencyMode(), isTrue);
    });

    test('location permission flag persists across instances', () async {
      expect(await repository.getHasLocationPermission(), isFalse);

      await repository.saveHasLocationPermission(true);
      expect(await repository.getHasLocationPermission(), isTrue);

      final restored = DeliveryNavigationRepository();
      expect(await restored.getHasLocationPermission(), isTrue);
    });

    test('locale code defaults to en and persists updates', () async {
      expect(await repository.getLocaleCode(), 'en');

      await repository.saveLocaleCode('ta');
      expect(await repository.getLocaleCode(), 'ta');

      final restored = DeliveryNavigationRepository();
      expect(await restored.getLocaleCode(), 'ta');
    });

    test('fetchActiveOrderData forwards an optional orderId', () async {
      when(
        () => mockService.fetchActiveOrder(orderId: 'ORD-99'),
      ).thenAnswer((_) async => buildOrderPayload());

      final data = await repository.fetchActiveOrderData(orderId: 'ORD-99');

      expect(data, isNotNull);
      expect(data!['orderId'], '78945');
      verify(() => mockService.fetchActiveOrder(orderId: 'ORD-99')).called(1);
    });
  });
}
