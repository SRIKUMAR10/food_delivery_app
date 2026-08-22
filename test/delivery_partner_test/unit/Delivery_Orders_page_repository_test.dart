import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:food_delivery_app/features/Delivery%20Partner%20Bloc%20Architecture/Delivery_Orders_page/Delivery_Orders_page_repository.dart';
import 'package:food_delivery_app/features/Delivery%20Partner%20Bloc%20Architecture/Delivery_Orders_page/Delivery_Orders_page_service.dart';
import 'package:food_delivery_app/features/Delivery%20Partner%20Bloc%20Architecture/Delivery_Orders_page/Delivery_Orders_page_state.dart';

class MockDeliveryOrdersService extends Mock
    implements DeliveryOrdersServiceBase {}

class MockFirebaseFirestore extends Mock implements FirebaseFirestore {}
class MockFirebaseAuth extends Mock implements FirebaseAuth {}
class MockUser extends Mock implements User {}
class MockCollectionReference extends Mock
    implements CollectionReference<Map<String, dynamic>> {}
class MockDocumentReference extends Mock
    implements DocumentReference<Map<String, dynamic>> {}
class MockTransaction extends Mock implements Transaction {}
class MockDocumentSnapshot extends Mock
    implements DocumentSnapshot<Map<String, dynamic>> {}

Map<String, dynamic> rawOrder({
  String id = 'ORD12345',
  String status = 'accepted',
  double amount = 486.50,
  String customer = 'Priya Sharma',
  String restaurant = 'Green Bowl Kitchen',
  String paymentType = 'Cash',
}) {
  return {
    'orderId': id,
    'customerName': customer,
    'restaurantName': restaurant,
    'pickupAddress': '42 Anna Salai, Chennai',
    'deliveryAddress': '21 MG Road, Velachery',
    'amount': amount,
    'itemsCount': 3,
    'status': status,
    'distance': 2.4,
    'time': '10:30 AM',
    'paymentType': paymentType,
    'phoneNumber': '9840112233',
    'etaMins': 18,
    'lateMins': 0,
    'priority': false,
    'restaurantRating': 4.5,
    'expectedTip': 20.0,
    'preparationTimeMins': 12,
    'deliveryBonus': 10.0,
  };
}

void main() {
  late MockDeliveryOrdersService mockService;

  setUp(() {
    mockService = MockDeliveryOrdersService();
  });

  group('DeliveryOrdersPage Repository Tests', () {
    test('fetchOrders maps raw service data into order card models', () async {
      when(
        () => mockService.fetchOrdersData(),
      ).thenAnswer((_) async => {
        'orders': [
          rawOrder(),
          rawOrder(
            id: 'ORD12346',
            customer: 'Arun Prakash',
            restaurant: 'Spice Route',
            status: 'ready',
            paymentType: 'Card',
          ),
          rawOrder(
            id: 'ORD12347',
            customer: 'Meena Krishnan',
            restaurant: 'The Pasta Lab',
            status: 'delivered',
            paymentType: 'Online',
          ),
        ],
      });

      final repository = DeliveryOrdersRepository(service: mockService);
      final orders = await repository.fetchOrders();

      expect(orders, hasLength(3));
      final first = orders.first;
      expect(first.orderId, 'ORD12345');
      expect(first.customerName, 'Priya Sharma');
      expect(first.restaurantName, 'Green Bowl Kitchen');
      expect(first.pickupAddress, '42 Anna Salai, Chennai');
      expect(first.deliveryAddress, '21 MG Road, Velachery');
      expect(first.amount, 486.50);
      expect(first.itemsCount, 3);
      expect(first.distance, 2.4);
      expect(first.time, '10:30 AM');
      expect(first.paymentType, 'Cash');
    });

    test('fetchOrders maps statuses to the correct enum values', () async {
      when(
        () => mockService.fetchOrdersData(),
      ).thenAnswer((_) async => {
        'orders': [
          rawOrder(id: 'o1', status: 'pending'),
          rawOrder(id: 'o2', status: 'active'),
          rawOrder(id: 'o3', status: 'active'),
          rawOrder(id: 'o4', status: 'completed'),
          rawOrder(id: 'o5', status: 'cancelled'),
        ],
      });

      final repository = DeliveryOrdersRepository(service: mockService);
      final orders = await repository.fetchOrders();

      expect(
        orders.where((o) => o.status == DeliveryOrderStatus.pending),
        hasLength(1),
      );
      expect(
        orders.where((o) => o.status == DeliveryOrderStatus.active),
        hasLength(2),
      );
      expect(
        orders.where((o) => o.status == DeliveryOrderStatus.completed),
        hasLength(1),
      );
      expect(
        orders.where((o) => o.status == DeliveryOrderStatus.cancelled),
        hasLength(1),
      );
    });

    test('updateOrderStatus returns the order with the new status', () async {
      when(
        () => mockService.fetchOrdersData(),
      ).thenAnswer((_) async => {'orders': [rawOrder()]});

      final repository = DeliveryOrdersRepository(service: mockService);
      final updated = await repository.updateOrderStatus(
        'ORD12345',
        DeliveryOrderStatus.completed,
      );

      expect(updated.orderId, 'ORD12345');
      expect(updated.status, DeliveryOrderStatus.completed);
      expect(updated.customerName, 'Priya Sharma');
      expect(updated.restaurantName, 'Green Bowl Kitchen');
    });

    test('updateOrderStatus keeps other order fields intact', () async {
      when(
        () => mockService.fetchOrdersData(),
      ).thenAnswer((_) async => {
        'orders': [
          rawOrder(id: 'ORD12346', customer: 'Arun Prakash', status: 'accepted'),
        ],
      });

      final repository = DeliveryOrdersRepository(service: mockService);
      final updated = await repository.updateOrderStatus(
        'ORD12346',
        DeliveryOrderStatus.active,
      );

      expect(updated.orderId, 'ORD12346');
      expect(updated.status, DeliveryOrderStatus.active);
      expect(updated.amount, 486.50);
      expect(updated.itemsCount, 3);
    });

    test('updateOrderStatus falls back to the requested status', () async {
      when(
        () => mockService.fetchOrdersData(),
      ).thenAnswer((_) async => {'orders': <Map<String, dynamic>>[]});

      final repository = DeliveryOrdersRepository(service: mockService);
      final updated = await repository.updateOrderStatus(
        'ORD00000',
        DeliveryOrderStatus.completed,
      );

      expect(updated.orderId, 'ORD00000');
      expect(updated.status, DeliveryOrderStatus.completed);
    });

    test('watchOrders emits the current list of orders', () async {
      when(
        () => mockService.watchOrdersData(),
      ).thenAnswer((_) => Stream.value({
        'orders': [
          rawOrder(),
          rawOrder(id: 'ORD12346', customer: 'Arun Prakash'),
        ],
      }));

      final repository = DeliveryOrdersRepository(service: mockService);
      final emitted = await repository.watchOrders().first;

      expect(emitted, hasLength(2));
      expect(emitted.first.orderId, 'ORD12345');
    });
  });

  group('DeliveryOrdersPage Repository Atomic Assignment Tests', () {
    late MockFirebaseFirestore mockFirestore;
    late MockFirebaseAuth mockAuth;
    late MockUser mockUser;
    late MockCollectionReference ordersCollection;
    late MockCollectionReference assignmentsCollection;
    late MockCollectionReference assignmentsSubCollection;
    late MockDocumentReference orderRef;
    late MockDocumentReference assignmentRef;
    late MockDocumentReference subDocRef;
    late MockTransaction mockTransaction;
    late MockDocumentSnapshot mockSnapshot;

    const partnerUid = 'partner123';

    setUpAll(() {
      registerFallbackValue(MockDocumentReference());
    });

    setUp(() {
      mockFirestore = MockFirebaseFirestore();
      mockAuth = MockFirebaseAuth();
      mockUser = MockUser();
      ordersCollection = MockCollectionReference();
      assignmentsCollection = MockCollectionReference();
      assignmentsSubCollection = MockCollectionReference();
      orderRef = MockDocumentReference();
      assignmentRef = MockDocumentReference();
      subDocRef = MockDocumentReference();
      mockTransaction = MockTransaction();
      mockSnapshot = MockDocumentSnapshot();

      when(() => mockAuth.currentUser).thenReturn(mockUser);
      when(() => mockUser.uid).thenReturn(partnerUid);
      when(() => mockUser.displayName).thenReturn('Ravi Kumar');
      when(() => mockUser.phoneNumber).thenReturn('9876543210');

      when(() => mockFirestore.collection('orders'))
          .thenReturn(ordersCollection);
      when(() => mockFirestore.collection('order_assignments'))
          .thenReturn(assignmentsCollection);
      when(() => ordersCollection.doc('ORD12345')).thenReturn(orderRef);
      when(() => assignmentsCollection.doc(any())).thenReturn(assignmentRef);
      when(() => assignmentRef.id).thenReturn('assignment-1');
      when(() => orderRef.collection('assignments'))
          .thenReturn(assignmentsSubCollection);
      when(() => assignmentsSubCollection.doc(partnerUid))
          .thenReturn(subDocRef);

      when(() => mockTransaction.get(orderRef))
          .thenAnswer((_) async => mockSnapshot);
      when(() => mockTransaction.update(any(), any()))
          .thenReturn(mockTransaction);
      when(() => mockTransaction.set<Map<String, dynamic>>(any(), any()))
          .thenReturn(mockTransaction);
    });

    DeliveryOrdersRepository buildAtomicRepository() {
      return DeliveryOrdersRepository(
        service: mockService,
        firestore: mockFirestore,
        auth: mockAuth,
      );
    }

    test('acceptOrderAtomic throws when the partner is unauthenticated', () async {
      when(() => mockAuth.currentUser).thenReturn(null);

      final repository = buildAtomicRepository();
      expect(
        () => repository.acceptOrderAtomic('ORD12345'),
        throwsA(isA<Exception>()),
      );
    });

    test('acceptOrderAtomic returns false when the order does not exist',
        () async {
      when(() => mockSnapshot.exists).thenReturn(false);
      when(() => mockFirestore.runTransaction<bool>(any())).thenAnswer(
        (invocation) {
          final handler = invocation.positionalArguments.first
              as TransactionHandler<bool>;
          return handler(mockTransaction);
        },
      );

      final repository = buildAtomicRepository();
      final result = await repository.acceptOrderAtomic('ORD12345');

      expect(result, isFalse);
    });

    test('acceptOrderAtomic returns false when already claimed by another partner',
        () async {
      when(() => mockSnapshot.exists).thenReturn(true);
      when(() => mockSnapshot.data()).thenReturn({
        'status': 'ready',
        'riderId': 'other-partner',
      });
      when(() => mockFirestore.runTransaction<bool>(any())).thenAnswer(
        (invocation) {
          final handler = invocation.positionalArguments.first
              as TransactionHandler<bool>;
          return handler(mockTransaction);
        },
      );

      final repository = buildAtomicRepository();
      final result = await repository.acceptOrderAtomic('ORD12345');

      expect(result, isFalse);
    });

    test('acceptOrderAtomic returns false for an ineligible status', () async {
      when(() => mockSnapshot.exists).thenReturn(true);
      when(() => mockSnapshot.data()).thenReturn({'status': 'Delivered'});
      when(() => mockFirestore.runTransaction<bool>(any())).thenAnswer(
        (invocation) {
          final handler = invocation.positionalArguments.first
              as TransactionHandler<bool>;
          return handler(mockTransaction);
        },
      );

      final repository = buildAtomicRepository();
      final result = await repository.acceptOrderAtomic('ORD12345');

      expect(result, isFalse);
    });

    test('acceptOrderAtomic commits the assignment when the order is available',
        () async {
      when(() => mockSnapshot.exists).thenReturn(true);
      when(() => mockSnapshot.data()).thenReturn({
        'status': 'ready_for_pickup',
        'sellerId': 'seller-1',
        'customerId': 'buyer-1',
      });
      when(() => mockFirestore.runTransaction<bool>(any())).thenAnswer(
        (invocation) {
          final handler = invocation.positionalArguments.first
              as TransactionHandler<bool>;
          return handler(mockTransaction);
        },
      );

      final repository = buildAtomicRepository();
      final result = await repository.acceptOrderAtomic('ORD12345');

      expect(result, isTrue);
      verify(() => mockTransaction.update(orderRef, any())).called(1);
      verify(
        () => mockTransaction.set<Map<String, dynamic>>(
          assignmentRef,
          any(),
          any(),
        ),
      ).called(1);
      verify(
        () => mockTransaction.set<Map<String, dynamic>>(
          subDocRef,
          any(),
          any(),
        ),
      ).called(1);
    });

    test('rejectOrder updates rejectedBy and returns true', () async {
      when(() => orderRef.update(any())).thenAnswer((_) async {});

      final repository = buildAtomicRepository();
      final result = await repository.rejectOrder('ORD12345');

      expect(result, isTrue);
      verify(() => orderRef.update(any())).called(1);
    });

    test('rejectOrder throws when unauthenticated', () async {
      when(() => mockAuth.currentUser).thenReturn(null);

      final repository = buildAtomicRepository();
      expect(
        () => repository.rejectOrder('ORD12345'),
        throwsA(isA<Exception>()),
      );
    });

    test('watchOnlineStatus emits true when partnerUid is empty or doc not found', () async {
      when(() => mockAuth.currentUser).thenReturn(null);

      final repository = buildAtomicRepository();
      final stream = repository.watchOnlineStatus();
      expect(await stream.first, isTrue);
    });

    test('updateOnlineStatus updates delivery_partners and riders in firestore', () async {
      final partnersCollection = MockCollectionReference();
      final ridersCollection = MockCollectionReference();
      final partnerDocRef = MockDocumentReference();
      final riderDocRef = MockDocumentReference();

      when(() => mockFirestore.collection('delivery_partners')).thenReturn(partnersCollection);
      when(() => mockFirestore.collection('riders')).thenReturn(ridersCollection);
      when(() => partnersCollection.doc(partnerUid)).thenReturn(partnerDocRef);
      when(() => ridersCollection.doc(partnerUid)).thenReturn(riderDocRef);
      when(() => partnerDocRef.set(any(), any())).thenAnswer((_) async {});
      when(() => riderDocRef.set(any(), any())).thenAnswer((_) async {});

      final repository = buildAtomicRepository();
      await repository.updateOnlineStatus(false);

      verify(() => partnerDocRef.set(any(), any())).called(1);
      verify(() => riderDocRef.set(any(), any())).called(1);
    });
  });
}

