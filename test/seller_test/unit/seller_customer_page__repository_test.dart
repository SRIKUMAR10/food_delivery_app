import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:food_delivery_app/api_service/seller_customer_service.dart';
import 'package:food_delivery_app/repositories/seller_customer_repository.dart';

class MockSellerCustomerService extends Mock implements SellerCustomerService {}

void main() {
  group('SellerCustomerRepository Tests', () {
    late SellerCustomerService service;
    late SellerCustomerRepository repository;

    setUp(() {
      service = MockSellerCustomerService();
      repository = SellerCustomerRepository(service: service);
    });

    test('getCustomerStats returns stats from service', () async {
      when(() => service.fetchCustomerStats()).thenAnswer(
        (_) async => {'totalCustomers': 500, 'repeatCustomers': 100},
      );

      final stats = await repository.getCustomerStats();

      expect(stats.totalCustomers, 500);
      expect(stats.repeatCustomers, 100);
      verify(() => service.fetchCustomerStats()).called(1);
    });

    test('getCustomers returns mapped CustomerItems from service', () async {
      final mockRaw = [
        {
          'id': 'cust_1',
          'name': 'Mike Ross',
          'orderCount': 12,
          'avatarUrl': 'https://example.com/avatar1.png',
        },
      ];

      when(
        () => service.fetchCustomerList(offset: 0, limit: 10),
      ).thenAnswer((_) async => mockRaw);

      final customers = await repository.getCustomers(offset: 0, limit: 10);

      expect(customers.length, 1);
      expect(customers[0].id, 'cust_1');
      expect(customers[0].name, 'Mike Ross');
      expect(customers[0].orderCount, 12);
      expect(customers[0].avatarUrl, 'https://example.com/avatar1.png');
      verify(() => service.fetchCustomerList(offset: 0, limit: 10)).called(1);
    });
  });
}
