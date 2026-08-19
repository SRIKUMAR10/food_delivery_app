import 'package:flutter_test/flutter_test.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mocktail/mocktail.dart';
import 'package:food_delivery_app/features/seller_bloc_architecture/seller_dashboard_page/seller_dashboard_repository.dart';

class MockFirebaseAuth extends Mock implements FirebaseAuth {}
class MockUser extends Mock implements User {}

void main() {
  late FakeFirebaseFirestore fakeFirestore;
  late MockFirebaseAuth mockAuth;
  late MockUser mockUser;
  late FirebaseSellerDashboardRepository repository;

  final String sellerId = 'seller123';

  setUp(() {
    fakeFirestore = FakeFirebaseFirestore();
    mockAuth = MockFirebaseAuth();
    mockUser = MockUser();

    when(() => mockAuth.currentUser).thenReturn(mockUser);
    when(() => mockUser.uid).thenReturn(sellerId);

    repository = FirebaseSellerDashboardRepository(
      firestore: fakeFirestore,
      auth: mockAuth,
    );
  });

  group('FirebaseSellerDashboardRepository', () {
    test('returns empty data when no orders or products exist', () async {
      final data = await repository.getDashboardData();

      expect(data.todaysOrdersCount, 0);
      expect(data.pendingOrdersCount, 0);
      expect(data.revenueToday, 0.0);
      expect(data.activeProductsCount, 0);
      expect(data.lowStockCount, 0);
    });

    test('calculates today\'s revenue correctly', () async {
      final now = DateTime.now();

      await fakeFirestore.collection('orders').add({
        'sellerId': sellerId,
        'status': 'Delivered',
        'amount': 500.0,
        'timestamp': now,
      });
      await fakeFirestore.collection('orders').add({
        'sellerId': sellerId,
        'status': 'Completed',
        'amount': 300.0,
        'timestamp': now,
      });
      await fakeFirestore.collection('orders').add({
        'sellerId': sellerId,
        'status': 'Cancelled',
        'amount': 100.0,
        'timestamp': now,
      });

      final data = await repository.getDashboardDataStream().first;

      expect(data.revenueToday, 800.0);
      expect(data.todaysOrdersCount, 3); 
    });

    test('excludes yesterday\'s orders from today\'s count and revenue', () async {
      final yesterday = DateTime.now().subtract(const Duration(days: 1));

      await fakeFirestore.collection('orders').add({
        'sellerId': sellerId,
        'status': 'Delivered',
        'amount': 500.0,
        'timestamp': yesterday,
      });

      final data = await repository.getDashboardDataStream().first;

      expect(data.revenueToday, 0.0);
      expect(data.todaysOrdersCount, 0);
    });

    test('calculates pending orders correctly', () async {
      final now = DateTime.now();
      await fakeFirestore.collection('orders').add({
        'sellerId': sellerId,
        'status': 'New',
        'timestamp': now,
      });
      await fakeFirestore.collection('orders').add({
        'sellerId': sellerId,
        'status': 'Accepted',
        'timestamp': now,
      });
      await fakeFirestore.collection('orders').add({
        'sellerId': sellerId,
        'status': 'Preparing',
        'timestamp': now,
      });
      await fakeFirestore.collection('orders').add({
        'sellerId': sellerId,
        'status': 'OutForDelivery',
        'timestamp': now,
      });

      final data = await repository.getDashboardDataStream().first;

      expect(data.pendingOrdersCount, 3);
    });

    test('calculates active products correctly (excludes inactive)', () async {
      await fakeFirestore.collection('products').add({
        'sellerId': sellerId,
        'isActive': true,
      });
      await fakeFirestore.collection('products').add({
        'sellerId': sellerId,
        'isActive': true,
      });
      await fakeFirestore.collection('products').add({
        'sellerId': sellerId,
        'isActive': false,
      });

      final data = await repository.getDashboardDataStream().first;

      expect(data.activeProductsCount, 2);
    });

    test('calculates low stock correctly', () async {
      await fakeFirestore.collection('products').add({
        'sellerId': sellerId,
        'isActive': true,
        'hasUnlimitedStock': false,
        'availableStock': 5,
        'minimumAlert': 10,
      });
      // unlimited shouldn't count as low stock even if available is low
      await fakeFirestore.collection('products').add({
        'sellerId': sellerId,
        'isActive': true,
        'hasUnlimitedStock': true,
        'availableStock': 0,
        'minimumAlert': 10,
      });
      // enough stock
      await fakeFirestore.collection('products').add({
        'sellerId': sellerId,
        'isActive': true,
        'hasUnlimitedStock': false,
        'availableStock': 20,
        'minimumAlert': 10,
      });

      final data = await repository.getDashboardDataStream().first;

      expect(data.lowStockCount, 1);
    });
  });
}
