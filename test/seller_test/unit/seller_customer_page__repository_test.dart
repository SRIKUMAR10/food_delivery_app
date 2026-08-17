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
        (_) async => {
          'totalCustomers': 500,
          'repeatCustomers': 100,
          'totalRevenue': 15000.0,
          'averageOrderValue': 150.0,
        },
      );

      final stats = await repository.getCustomerStats();

      expect(stats.totalCustomers, 500);
      expect(stats.repeatCustomers, 100);
      expect(stats.totalRevenue, 15000.0);
      expect(stats.averageOrderValue, 150.0);
      verify(() => service.fetchCustomerStats()).called(1);
    });

    test('getCustomers returns mapped CustomerItems from service', () async {
      final mockRaw = [
        {
          'id': 'cust_1',
          'name': 'Mike Ross',
          'orderCount': 12,
          'avatarUrl': 'https://example.com/avatar1.png',
          'phone': '+91 98*** **321',
          'rawPhone': '+91 9876543321',
          'totalSpent': 2500.0,
          'favouriteProducts': [
            {
              'productId': 'p1',
              'productName': 'Biryani',
              'orderCount': 4,
              'price': 250.0,
            }
          ],
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
      expect(customers[0].phone, '+91 98*** **321');
      expect(customers[0].totalSpent, 2500.0);
      expect(customers[0].favouriteProducts.length, 1);
      expect(customers[0].favouriteProducts[0].productName, 'Biryani');
      verify(() => service.fetchCustomerList(offset: 0, limit: 10)).called(1);
    });

    test('watchCustomerData maps stream of data bundle correctly', () async {
      when(() => service.streamCustomerData(sellerId: any(named: 'sellerId'))).thenAnswer(
        (_) => Stream.value({
          'stats': {
            'totalCustomers': 10,
            'repeatCustomers': 3,
            'totalRevenue': 5000.0,
            'averageOrderValue': 200.0,
          },
          'customers': [
            {
              'id': 'c1',
              'name': 'Alice',
              'orderCount': 2,
              'avatarUrl': '',
              'totalSpent': 400.0,
            }
          ],
        }),
      );

      final data = await repository.watchCustomerData().first;

      expect(data.stats.totalCustomers, 10);
      expect(data.stats.repeatCustomers, 3);
      expect(data.customers.length, 1);
      expect(data.customers[0].name, 'Alice');
    });
  });
}
