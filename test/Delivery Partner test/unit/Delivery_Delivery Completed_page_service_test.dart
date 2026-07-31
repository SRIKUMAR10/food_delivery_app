import 'package:flutter_test/flutter_test.dart';
import 'package:food_delivery_app/features/Delivery%20Partner%20Bloc%20Architecture/Delivery_Delivery%20Completed_page/Delivery_Delivery%20Completed_page_service.dart';

void main() {
  group('DeliveryCompletedService Tests', () {
    late DeliveryCompletedService service;

    setUp(() {
      service = DeliveryCompletedService();
    });

    test(
      'fetchCompletedOrderData returns a valid completed order payload',
      () async {
        final data = await service.fetchCompletedOrderData('#ORD12345');

        expect(data['orderId'], '#ORD12345');
        expect(data['walletBalance'], 2450.00);
        expect(data['partnerName'], 'Ravi Kumar');
        expect(data['partnerVehicleNo'], 'TN 01 AB 1234');
        expect(data['customerName'], 'Arun Kumar');
        expect(data['deliveryAddress'], '12, Beach Road, Chennai - 600001');
        expect(data['timeTaken'], '32 min');
        expect(data['distanceCovered'], 5.6);
        expect(data['paymentStatus'], 'Paid Successfully');
        expect(data['paymentMethod'], 'UPI • Google Pay');
        expect(data['customerRating'], 5.0);
        expect(data['deliveryEarnings'], 120.00);
      },
    );

    test('fetchCompletedOrderData falls back to default order id', () async {
      final data = await service.fetchCompletedOrderData('');

      expect(data['orderId'], '#ORD12345');
    });

    test('completeOrderData returns a valid completed order payload', () async {
      final data = await service.completeOrderData('#ORD12345');

      expect(data['orderId'], '#ORD12345');
      expect(data['customerName'], 'Arun Kumar');
      expect(data['paymentStatus'], 'Paid Successfully');
    });

    test('chunkedMediaUpload yields progress reaching 1.0', () async {
      final progress = await service.chunkedMediaUpload('#ORD12345').toList();

      expect(progress, isNotEmpty);
      expect(progress.first, greaterThan(0.0));
      expect(progress.last, 1.0);
      expect(progress.every((p) => p >= 0.0 && p <= 1.0), isTrue);
    });

    test('validateMedia accepts supported file types', () {
      expect(service.validateMedia('proof.jpg'), isNull);
      expect(service.validateMedia('proof_delivery.jpeg'), isNull);
      expect(service.validateMedia('proof.png'), isNull);
    });

    test('validateMedia rejects missing files and unsupported types', () {
      expect(service.validateMedia(null), isNotNull);
      expect(service.validateMedia(''), isNotNull);
      expect(
        service.validateMedia('receipt.txt'),
        'Unsupported file type: .txt',
      );
      expect(service.validateMedia('video.mp4'), 'Unsupported file type: .mp4');
    });

    test('formatCurrency formats amounts with rupee symbol', () {
      expect(service.formatCurrency(120.0), '₹120.00');
      expect(service.formatCurrency(2450), '₹2450.00');
      expect(service.formatCurrency(0), '₹0.00');
    });

    test('formatDistance formats distance with km suffix', () {
      expect(service.formatDistance(5.6), '5.6 km');
      expect(service.formatDistance(0), '0.0 km');
    });

    test('environment variables expose only safe configuration', () {
      final env = service.getEnvironmentVariables();

      expect(env.containsKey('BASE_URL'), isTrue);
      expect(env.containsKey('COMPLETED_URL'), isTrue);
      expect(
        env.toString().contains(
          RegExp(
            r'(token|password|passwd|secret|api_key)',
            caseSensitive: false,
          ),
        ),
        isFalse,
      );
    });

    test(
      'requestMediaPermission and requestLocationPermission grant access',
      () async {
        expect(await service.requestMediaPermission(), isTrue);
        expect(await service.requestLocationPermission(), isTrue);
      },
    );
  });
}
