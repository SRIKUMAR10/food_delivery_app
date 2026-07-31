import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:food_delivery_app/features/Delivery%20Partner%20Bloc%20Architecture/Delivery_Pickup%20Confirmation_page/Delivery_Pickup%20Confirmation_page_repository.dart';
import 'package:food_delivery_app/features/Delivery%20Partner%20Bloc%20Architecture/Delivery_Pickup%20Confirmation_page/Delivery_Pickup%20Confirmation_page_service.dart';
import 'package:food_delivery_app/features/Delivery%20Partner%20Bloc%20Architecture/Delivery_Pickup%20Confirmation_page/Delivery_Pickup%20Confirmation_page_state.dart';

class MockPickupConfirmationService extends Mock
    implements DeliveryPickupConfirmationServiceBase {}

Map<String, dynamic> rawData() => {
  'orderId': '#ORD12345',
  'pickupLocationName': 'Green Mart',
  'pickupAddress': '24, Anna Salai, Chennai - 600002',
  'pickupContactName': 'Priya Sharma',
  'pickupContactPhone': '+919876543210',
  'pickupInstructions': 'Show the order code at the counter.',
  'customerName': 'Mike Johnson',
  'customerAddress': '12, Beach Road, Chennai - 600001',
  'customerPhone': '+919876543211',
  'pickupTime': '12:05 PM',
  'paymentType': 'Cash on Delivery',
  'orderAmount': 486.50,
  'walletBalance': 2450.00,
};

void main() {
  late MockPickupConfirmationService mockService;

  setUp(() {
    mockService = MockPickupConfirmationService();
    registerFallbackValue('#ORD12345');
  });

  group('DeliveryPickupConfirmationRepository Tests', () {
    test(
      'fetchPickupConfirmationDetails maps service data into a model',
      () async {
        when(
          () => mockService.fetchPickupConfirmationData(any()),
        ).thenAnswer((_) async => rawData());

        final repository = DeliveryPickupConfirmationRepository(
          service: mockService,
        );
        final model = await repository.fetchPickupConfirmationDetails(
          '#ORD12345',
        );

        expect(model, isA<PickupConfirmationModel>());
        expect(model.orderId, '#ORD12345');
        expect(model.pickupLocationName, 'Green Mart');
        expect(model.pickupAddress, '24, Anna Salai, Chennai - 600002');
        expect(model.pickupContactName, 'Priya Sharma');
        expect(model.pickupContactPhone, '+919876543210');
        expect(model.pickupInstructions, 'Show the order code at the counter.');
        expect(model.customerName, 'Mike Johnson');
        expect(model.customerAddress, '12, Beach Road, Chennai - 600001');
        expect(model.customerPhone, '+919876543211');
        expect(model.pickupTime, '12:05 PM');
        expect(model.paymentType, 'Cash on Delivery');
        expect(model.orderAmount, 486.50);
        expect(model.walletBalance, 2450.00);
        verify(
          () => mockService.fetchPickupConfirmationData('#ORD12345'),
        ).called(1);
      },
    );

    test('startDelivery delegates to service and maps the result', () async {
      when(
        () => mockService.startDeliveryData(any()),
      ).thenAnswer((_) async => rawData());

      final repository = DeliveryPickupConfirmationRepository(
        service: mockService,
      );
      final model = await repository.startDelivery('#ORD12345');

      expect(model.orderId, '#ORD12345');
      expect(model.customerName, 'Mike Johnson');
      verify(() => mockService.startDeliveryData('#ORD12345')).called(1);
    });

    test('maps missing numeric fields to safe defaults', () async {
      when(
        () => mockService.fetchPickupConfirmationData(any()),
      ).thenAnswer((_) async => {'orderId': '#ORD99999'});

      final repository = DeliveryPickupConfirmationRepository(
        service: mockService,
      );
      final model = await repository.fetchPickupConfirmationDetails(
        '#ORD99999',
      );

      expect(model.orderId, '#ORD99999');
      expect(model.pickupLocationName, isEmpty);
      expect(model.orderAmount, 0.0);
      expect(model.walletBalance, 0.0);
      expect(model.paymentType, 'Cash on Delivery');
    });

    test('uses default order id when raw payload omits it', () async {
      when(
        () => mockService.fetchPickupConfirmationData(any()),
      ).thenAnswer((_) async => <String, dynamic>{});

      final repository = DeliveryPickupConfirmationRepository(
        service: mockService,
      );
      final model = await repository.fetchPickupConfirmationDetails('');

      expect(model.orderId, '#ORD12345');
    });
  });
}
