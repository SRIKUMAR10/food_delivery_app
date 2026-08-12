import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:food_delivery_app/features/Delivery%20Partner%20Bloc%20Architecture/Delivery_Delivery%20Completed_page/Delivery_Delivery%20Completed_page_repository.dart';
import 'package:food_delivery_app/features/Delivery%20Partner%20Bloc%20Architecture/Delivery_Delivery%20Completed_page/Delivery_Delivery%20Completed_page_service.dart';
import 'package:food_delivery_app/features/Delivery%20Partner%20Bloc%20Architecture/Delivery_Delivery%20Completed_page/Delivery_Delivery%20Completed_page_state.dart';

class MockDeliveryCompletedService extends Mock
    implements DeliveryCompletedServiceBase {}

Map<String, dynamic> rawData() => {
  'orderId': '#ORD12345',
  'walletBalance': 2450.00,
  'partnerName': 'Ravi Kumar',
  'partnerVehicleNo': 'TN 01 AB 1234',
  'customerName': 'Arun Kumar',
  'deliveryAddress': '12, Beach Road, Chennai - 600001',
  'timeTaken': '32 min',
  'distanceCovered': 5.6,
  'paymentStatus': 'Paid Successfully',
  'paymentMethod': 'UPI • Google Pay',
  'customerRating': 5.0,
  'deliveryEarnings': 120.00,
  'completedAt': 'Today, 4:15 PM',
};

void main() {
  late MockDeliveryCompletedService mockService;

  setUp(() {
    mockService = MockDeliveryCompletedService();
    registerFallbackValue('#ORD12345');
  });

  group('DeliveryCompletedRepository Tests', () {
    test('fetchCompletedOrderDetails maps service data into a model', () async {
      when(
        () => mockService.fetchCompletedOrderData(any()),
      ).thenAnswer((_) async => rawData());

      final repository = DeliveryCompletedRepository(service: mockService);
      final model = await repository.fetchCompletedOrderDetails('#ORD12345');

      expect(model, isA<DeliveryCompletedModel>());
      expect(model.orderId, '#ORD12345');
      expect(model.walletBalance, 2450.00);
      expect(model.partnerName, 'Ravi Kumar');
      expect(model.partnerVehicleNo, 'TN 01 AB 1234');
      expect(model.customerName, 'Arun Kumar');
      expect(model.deliveryAddress, '12, Beach Road, Chennai - 600001');
      expect(model.timeTaken, '32 min');
      expect(model.distanceCovered, 5.6);
      expect(model.paymentStatus, 'Paid Successfully');
      expect(model.paymentMethod, 'UPI • Google Pay');
      expect(model.customerRating, 5.0);
      expect(model.deliveryEarnings, 120.00);
      expect(model.completedAt, 'Today, 4:15 PM');
      verify(() => mockService.fetchCompletedOrderData('#ORD12345')).called(1);
    });

    test('completeOrder delegates to service and maps the result', () async {
      when(
        () => mockService.completeOrderData(any()),
      ).thenAnswer((_) async => rawData());

      final repository = DeliveryCompletedRepository(service: mockService);
      final model = await repository.completeOrder('#ORD12345');

      expect(model.orderId, '#ORD12345');
      expect(model.customerName, 'Arun Kumar');
      expect(model.paymentStatus, 'Paid Successfully');
      verify(() => mockService.completeOrderData('#ORD12345')).called(1);
    });

    test('maps missing numeric fields to safe defaults', () async {
      when(
        () => mockService.fetchCompletedOrderData(any()),
      ).thenAnswer((_) async => {'orderId': '#ORD99999'});

      final repository = DeliveryCompletedRepository(service: mockService);
      final model = await repository.fetchCompletedOrderDetails('#ORD99999');

      expect(model.orderId, '#ORD99999');
      expect(model.customerName, isEmpty);
      expect(model.walletBalance, 0.0);
      expect(model.distanceCovered, 0.0);
      expect(model.deliveryEarnings, 0.0);
      expect(model.customerRating, 0.0);
      expect(model.paymentStatus, isEmpty);
    });

    test('uses an empty order id when raw payload omits it', () async {
      when(
        () => mockService.fetchCompletedOrderData(any()),
      ).thenAnswer((_) async => <String, dynamic>{});

      final repository = DeliveryCompletedRepository(service: mockService);
      final model = await repository.fetchCompletedOrderDetails('');

      expect(model.orderId, isEmpty);
    });
  });
}
