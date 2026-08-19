import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:food_delivery_app/features/Delivery%20Partner%20Bloc%20Architecture/Delivery_Order_Details_page/Delivery_Order_Details_page_service.dart';
import '../../mock_firebase.dart';

void main() {
  group('DeliveryOrderDetailsService - Customer Drop Details Enrichment', () {
    late FakeFirebaseFirestore fakeFirestore;
    late DeliveryOrderDetailsService service;

    const buyerId = 'buyer_abc_123';
    const buyerName = 'Arun Kumar';
    const buyerPhone = '+919876543210';
    const buyerProfileAddress = '45, Anna Street, Erode, Tamil Nadu';
    const orderDeliveryAddress = '12, Gandhi Road, Erode, Tamil Nadu 638001';

    setUpAll(() async {
      setupFirebaseAuthMocks();
      await Firebase.initializeApp();
    });

    setUp(() {
      fakeFirestore = FakeFirebaseFirestore();
      service = DeliveryOrderDetailsService(firestore: fakeFirestore);
    });

    Future<void> _seedBuyer() async {
      await fakeFirestore.collection('buyer_user').doc(buyerId).set({
        'name': buyerName,
        'phone': buyerPhone,
        'address': buyerProfileAddress,
      });
    }

    Future<void> _seedSeller(String sellerId) async {
      await fakeFirestore.collection('sellers').doc(sellerId).set({
        'shopName': 'ahbi',
        'phoneNumber': '+918888888888',
        'address': 'ahbi Store, Main Road',
      });
    }

    // ── Scenario 1: Order has deliveryAddress + customerId → order address used ──
    test('uses order deliveryAddress as primary', () async {
      const sellerId = 'seller_1';
      await _seedBuyer();
      await _seedSeller(sellerId);

      await fakeFirestore.collection('orders').doc('ORD001').set({
        'customerId': buyerId,
        'customerName': '',
        'deliveryAddress': orderDeliveryAddress,
        'customerPhone': '',
        'sellerId': sellerId,
        'status': 'Pending',
        'amount': 500,
      });

      final result = await service.fetchOrderDetailsData('ORD001');

      expect(result['customerName'], buyerName);
      expect(result['dropoffAddress'], orderDeliveryAddress);
      expect(result['customerPhone'], buyerPhone);
      expect(result['restaurantName'], 'ahbi');
    });

    // ── Scenario 2: Order does NOT contain deliveryAddress → buyer profile address fallback ──
    test('falls back to buyer profile address when order has no deliveryAddress', () async {
      const sellerId = 'seller_1';
      await _seedBuyer();
      await _seedSeller(sellerId);

      await fakeFirestore.collection('orders').doc('ORD002').set({
        'customerId': buyerId,
        'customerName': '',
        'customerPhone': '',
        'sellerId': sellerId,
        'status': 'Pending',
        'amount': 300,
      });

      final result = await service.fetchOrderDetailsData('ORD002');

      expect(result['customerName'], buyerName);
      expect(result['dropoffAddress'], buyerProfileAddress);
      expect(result['customerPhone'], buyerPhone);
    });

    // ── Scenario 3: Missing Buyer ID → controlled fallback, no crash ──
    test('handles missing buyerId gracefully', () async {
      const sellerId = 'seller_1';
      await _seedSeller(sellerId);

      await fakeFirestore.collection('orders').doc('ORD003').set({
        'sellerId': sellerId,
        'status': 'Pending',
        'amount': 200,
      });

      final result = await service.fetchOrderDetailsData('ORD003');

      expect(result['customerName'], 'Customer');
      expect(result['dropoffAddress'], '');
      expect(result['customerPhone'], '');
      expect(result['restaurantName'], 'ahbi');
    });

    // ── Scenario 4: Buyer document missing → controlled fallback, no crash ──
    test('handles missing buyer document gracefully', () async {
      const sellerId = 'seller_1';
      await _seedSeller(sellerId);

      await fakeFirestore.collection('orders').doc('ORD004').set({
        'customerId': 'non_existent_buyer',
        'customerName': '',
        'customerPhone': '',
        'sellerId': sellerId,
        'status': 'Pending',
        'amount': 150,
      });

      final result = await service.fetchOrderDetailsData('ORD004');

      expect(result['customerName'], 'Customer');
      expect(result['dropoffAddress'], '');
      expect(result['customerPhone'], '');
    });

    // ── Scenario 5: Buyer name missing in profile → fallback to 'Customer' ──
    test('falls back to Customer when buyer name is empty', () async {
      const sellerId = 'seller_1';
      await _seedSeller(sellerId);
      await fakeFirestore.collection('buyer_user').doc(buyerId).set({
        'phone': buyerPhone,
        'address': buyerProfileAddress,
      });

      await fakeFirestore.collection('orders').doc('ORD005').set({
        'customerId': buyerId,
        'customerName': '',
        'customerPhone': '',
        'sellerId': sellerId,
        'deliveryAddress': '',
        'status': 'Pending',
        'amount': 400,
      });

      final result = await service.fetchOrderDetailsData('ORD005');

      expect(result['customerName'], 'Customer');
      expect(result['customerPhone'], buyerPhone);
      expect(result['dropoffAddress'], buyerProfileAddress);
    });

    // ── Scenario 6: Buyer phone missing → empty, no crash ──
    test('handles missing buyer phone gracefully', () async {
      const sellerId = 'seller_1';
      await _seedSeller(sellerId);
      await fakeFirestore.collection('buyer_user').doc(buyerId).set({
        'name': buyerName,
        'address': buyerProfileAddress,
      });

      await fakeFirestore.collection('orders').doc('ORD006').set({
        'customerId': buyerId,
        'customerName': '',
        'customerPhone': '',
        'sellerId': sellerId,
        'deliveryAddress': orderDeliveryAddress,
        'status': 'Pending',
        'amount': 250,
      });

      final result = await service.fetchOrderDetailsData('ORD006');

      expect(result['customerName'], buyerName);
      expect(result['dropoffAddress'], orderDeliveryAddress);
      expect(result['customerPhone'], '');
    });

    // ── Scenario 7: Multiple orders, different buyers → each shows correct buyer ──
    test('different orders resolve correct buyer data', () async {
      const secondBuyerId = 'buyer_xyz_456';
      const secondBuyerName = 'Priya Sharma';
      const secondBuyerPhone = '+918765432109';
      const secondOrderAddress = '22, MG Road, Salem, Tamil Nadu';

      const sellerId = 'seller_1';
      await _seedBuyer();
      await _seedSeller(sellerId);
      await fakeFirestore.collection('buyer_user').doc(secondBuyerId).set({
        'name': secondBuyerName,
        'phone': secondBuyerPhone,
        'address': '10, Lake View, Salem',
      });

      await fakeFirestore.collection('orders').doc('ORD007').set({
        'customerId': buyerId,
        'customerName': '',
        'deliveryAddress': orderDeliveryAddress,
        'customerPhone': '',
        'sellerId': sellerId,
        'status': 'Pending',
        'amount': 500,
      });

      await fakeFirestore.collection('orders').doc('ORD008').set({
        'customerId': secondBuyerId,
        'customerName': '',
        'deliveryAddress': secondOrderAddress,
        'customerPhone': '',
        'sellerId': sellerId,
        'status': 'Pending',
        'amount': 750,
      });

      final result1 = await service.fetchOrderDetailsData('ORD007');
      final result2 = await service.fetchOrderDetailsData('ORD008');

      expect(result1['customerName'], buyerName);
      expect(result1['dropoffAddress'], orderDeliveryAddress);
      expect(result1['customerPhone'], buyerPhone);

      expect(result2['customerName'], secondBuyerName);
      expect(result2['dropoffAddress'], secondOrderAddress);
      expect(result2['customerPhone'], secondBuyerPhone);
    });

    // ── Scenario 8: Real-time stream updates correctly ──
    test('watchOrderDetailsData emits enriched order data', () async {
      const sellerId = 'seller_1';
      await _seedBuyer();
      await _seedSeller(sellerId);

      final orderRef = fakeFirestore.collection('orders').doc('ORD009');
      await orderRef.set({
        'customerId': buyerId,
        'customerName': '',
        'deliveryAddress': orderDeliveryAddress,
        'customerPhone': '',
        'sellerId': sellerId,
        'status': 'Pending',
        'amount': 500,
      });

      final stream = service.watchOrderDetailsData('ORD009');
      final results = await stream.take(1).toList();

      expect(results, isNotEmpty);
      expect(results.first['customerName'], buyerName);
      expect(results.first['dropoffAddress'], orderDeliveryAddress);
      expect(results.first['customerPhone'], buyerPhone);
    });

    // ── Scenario 9: Pickup details continue working ──
    test('pickup details remain unaffected', () async {
      const sellerId = 'seller_1';
      await _seedBuyer();
      await _seedSeller(sellerId);

      await fakeFirestore.collection('orders').doc('ORD010').set({
        'customerId': buyerId,
        'customerName': '',
        'deliveryAddress': orderDeliveryAddress,
        'customerPhone': '',
        'sellerId': sellerId,
        'status': 'Pending',
        'amount': 600,
      });

      final result = await service.fetchOrderDetailsData('ORD010');

      expect(result['restaurantName'], 'ahbi');
      expect(result['pickupAddress'], 'ahbi Store, Main Road');
      expect(result['merchantPhone'], '+918888888888');
    });

    // ── Scenario 10: Order has all customer data → no unnecessary Firestore reads ──
    test('reuses order-level customer data when fully populated', () async {
      const sellerId = 'seller_1';
      await _seedBuyer();
      await _seedSeller(sellerId);

      await fakeFirestore.collection('orders').doc('ORD011').set({
        'customerId': buyerId,
        'customerName': buyerName,
        'deliveryAddress': orderDeliveryAddress,
        'customerPhone': buyerPhone,
        'sellerId': sellerId,
        'status': 'Pending',
        'amount': 500,
      });

      final result = await service.fetchOrderDetailsData('ORD011');

      expect(result['customerName'], buyerName);
      expect(result['dropoffAddress'], orderDeliveryAddress);
      expect(result['customerPhone'], buyerPhone);
    });
  });
}
