import 'package:flutter_test/flutter_test.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:mocktail/mocktail.dart';
import 'package:food_delivery_app/features/seller_bloc_architecture/out_for_delivery_page_/out_for_delivery_page__bloc.dart';
import 'package:food_delivery_app/features/seller_bloc_architecture/out_for_delivery_page_/out_for_delivery_page__event.dart';
import 'package:food_delivery_app/features/seller_bloc_architecture/out_for_delivery_page_/out_for_delivery_page__state.dart';

class MockOutForDeliveryRepository extends Mock
    implements OutForDeliveryRepository {}

void main() {
  group('OutForDeliveryPageBloc', () {
    late OutForDeliveryPageBloc bloc;
    late MockOutForDeliveryRepository mockRepository;

    setUp(() {
      mockRepository = MockOutForDeliveryRepository();
      bloc = OutForDeliveryPageBloc(repository: mockRepository);
    });

    tearDown(() {
      bloc.close();
    });

    test('initial state is OutForDeliveryPageInitial', () {
      expect(bloc.state, OutForDeliveryPageInitial());
    });

    blocTest<OutForDeliveryPageBloc, OutForDeliveryPageState>(
      'emits [Loading, Loaded] when FetchDeliveryDetails is added',
      build: () {
        when(() => mockRepository.streamDeliveryDetails('1025')).thenAnswer(
          (_) => Stream.value(
            OutForDeliveryPageData(
              orderId: '1025',
              rider: const RiderDetails(
                id: 'rider_1',
                name: 'Raj',
                phone: '+911234567890',
                imageUrl: '',
                rating: 4.8,
              ),
              currentStatus: DeliveryStatus.outForDelivery,
              customerName: 'Aarav Patel',
              customerPhone: '+919876543210',
              customerId: 'customer_1',
            ),
          ),
        );
        return bloc;
      },
      act: (bloc) => bloc.add(const FetchDeliveryDetails(orderId: '1025')),
      wait: const Duration(milliseconds: 100),
      expect: () => [
        isA<OutForDeliveryPageLoading>(),
        isA<OutForDeliveryPageLoaded>()
            .having(
              (s) => s.orderId,
              'orderId',
              '1025',
            )
            .having(
              (s) => s.customerId,
              'customerId',
              'customer_1',
            )
            .having(
              (s) => s.customerPhone,
              'customerPhone',
              '+919876543210',
            ),
      ],
    );

    blocTest<OutForDeliveryPageBloc, OutForDeliveryPageState>(
      'emits [Loading, Error] when the repository stream errors',
      build: () {
        when(() => mockRepository.streamDeliveryDetails('999'))
            .thenAnswer((_) => Stream.error(Exception('Order not found')));
        return bloc;
      },
      act: (bloc) => bloc.add(const FetchDeliveryDetails(orderId: '999')),
      wait: const Duration(milliseconds: 100),
      expect: () => [
        isA<OutForDeliveryPageLoading>(),
        isA<OutForDeliveryPageError>(),
      ],
    );

    test('calculateDistanceKm computes accurate distance between two coordinates', () {
      // Chennai Central (13.0827, 80.2707) to Marina Beach (13.0499, 80.2824) ~3.8 km
      final dist = OutForDeliveryRepository.calculateDistanceKm(
        13.0827,
        80.2707,
        13.0499,
        80.2824,
      );
      expect(dist, greaterThan(3.0));
      expect(dist, lessThan(5.0));
    });

    test('calculateDynamicEta returns correct ETA for distances', () {
      expect(
        OutForDeliveryRepository.calculateDynamicEta(null, DeliveryStatus.outForDelivery),
        '~5-10 mins',
      );
      expect(
        OutForDeliveryRepository.calculateDynamicEta(0.0, DeliveryStatus.delivered),
        'Delivered',
      );
      expect(
        OutForDeliveryRepository.calculateDynamicEta(2.0, DeliveryStatus.outForDelivery),
        contains('mins'),
      );
    });

    test('formatDistance returns meters for sub-kilometer and km for longer distances', () {
      expect(OutForDeliveryRepository.formatDistance(0.5), '500 m away');
      expect(OutForDeliveryRepository.formatDistance(2.4), '2.4 km away');
      expect(OutForDeliveryRepository.formatDistance(null), 'Location available');
    });

    test('calculateProgressRatio advances across delivery statuses', () {
      expect(OutForDeliveryRepository.calculateProgressRatio(DeliveryStatus.orderAccepted, null), 0.15);
      expect(OutForDeliveryRepository.calculateProgressRatio(DeliveryStatus.paymentReceived, null), 0.30);
      expect(OutForDeliveryRepository.calculateProgressRatio(DeliveryStatus.preparing, null), 0.50);
      expect(OutForDeliveryRepository.calculateProgressRatio(DeliveryStatus.readyForPickup, null), 0.70);
      expect(OutForDeliveryRepository.calculateProgressRatio(DeliveryStatus.delivered, null), 1.0);
      expect(
        OutForDeliveryRepository.calculateProgressRatio(DeliveryStatus.outForDelivery, 0.2),
        greaterThan(
          OutForDeliveryRepository.calculateProgressRatio(DeliveryStatus.outForDelivery, 2.0),
        ),
      );
    });

    test('calculateExpectedDeliveryTime returns a formatted clock string', () {
      final time = OutForDeliveryRepository.calculateExpectedDeliveryTime(
        2.0,
        DeliveryStatus.outForDelivery,
      );
      expect(time, matches(RegExp(r'^\d{1,2}:\d{2} (AM|PM)$')));
    });

    blocTest<OutForDeliveryPageBloc, OutForDeliveryPageState>(
      'ToggleMapFullScreen expands the collapsed map',
      build: () => bloc,
      seed: () => const OutForDeliveryPageLoaded(
        orderId: '1025',
        rider: RiderDetails(
          id: 'rider_1',
          name: 'Raj',
          phone: '+911234567890',
          imageUrl: '',
          rating: 4.8,
        ),
        currentStatus: DeliveryStatus.outForDelivery,
        estimatedTime: '~10 mins',
        distance: '2.4 km away',
        distanceKm: 2.4,
      ),
      act: (bloc) => bloc.add(const ToggleMapFullScreen()),
      expect: () => [
        isA<OutForDeliveryPageLoaded>().having(
          (s) => s.isMapExpanded,
          'isMapExpanded',
          isTrue,
        ),
      ],
    );

    blocTest<OutForDeliveryPageBloc, OutForDeliveryPageState>(
      'ToggleMapFullScreen collapses the expanded map',
      build: () => bloc,
      seed: () => const OutForDeliveryPageLoaded(
        orderId: '1025',
        rider: RiderDetails(
          id: 'rider_1',
          name: 'Raj',
          phone: '+911234567890',
          imageUrl: '',
          rating: 4.8,
        ),
        currentStatus: DeliveryStatus.outForDelivery,
        estimatedTime: '~10 mins',
        distance: '2.4 km away',
        distanceKm: 2.4,
        isMapExpanded: true,
      ),
      act: (bloc) => bloc.add(const ToggleMapFullScreen()),
      expect: () => [
        isA<OutForDeliveryPageLoaded>().having(
          (s) => s.isMapExpanded,
          'isMapExpanded',
          isFalse,
        ),
      ],
    );

    blocTest<OutForDeliveryPageBloc, OutForDeliveryPageState>(
      'computes telemetry (distanceKm, progressRatio, speed, ETA) from streamed data',
      build: () {
        when(() => mockRepository.streamDeliveryDetails('1025')).thenAnswer(
          (_) => Stream.value(
            OutForDeliveryPageData(
              orderId: '1025',
              rider: const RiderDetails(
                id: 'rider_1',
                name: 'Raj',
                phone: '+911234567890',
                imageUrl: '',
                rating: 4.8,
              ),
              currentStatus: DeliveryStatus.outForDelivery,
              riderLat: 13.0827,
              riderLng: 80.2707,
              sellerLat: 13.0827,
              sellerLng: 80.2707,
              customerLat: 13.05,
              customerLng: 80.28,
              driverSpeed: 25.0,
            ),
          ),
        );
        return bloc;
      },
      act: (bloc) => bloc.add(const FetchDeliveryDetails(orderId: '1025')),
      wait: const Duration(milliseconds: 100),
      expect: () => [
        isA<OutForDeliveryPageLoading>(),
        isA<OutForDeliveryPageLoaded>()
            .having((s) => s.distanceKm, 'distanceKm', isNotNull)
            .having(
              (s) => s.progressRatio,
              'progressRatio',
              greaterThanOrEqualTo(0.8),
            )
            .having(
              (s) => s.driverSpeed,
              'driverSpeed',
              moreOrLessEquals(25.0),
            )
            .having(
              (s) => s.expectedDeliveryTime,
              'expectedDeliveryTime',
              isNotNull,
            ),
      ],
    );

    test('copyWith updates isMapExpanded and preserves other fields', () {
      const loaded = OutForDeliveryPageLoaded(
        orderId: '1025',
        rider: RiderDetails(
          id: 'rider_1',
          name: 'Raj',
          phone: '+911234567890',
          imageUrl: '',
          rating: 4.8,
        ),
        currentStatus: DeliveryStatus.outForDelivery,
        estimatedTime: '~10 mins',
        distance: '2.4 km away',
      );

      final expanded = loaded.copyWith(isMapExpanded: true);
      expect(expanded.isMapExpanded, isTrue);
      expect(expanded.orderId, '1025');
      expect(expanded.rider.name, 'Raj');

      final collapsed = expanded.copyWith(isMapExpanded: false);
      expect(collapsed.isMapExpanded, isFalse);
      expect(collapsed.orderId, '1025');
    });
  });

  group('OutForDeliveryRepository order parsing', () {
    test('parses customerId from order document', () async {
      final firestore = FakeFirebaseFirestore();
      await firestore.collection('orders').doc('1025').set({
        'customerId': 'customer_1',
        'customerName': 'Aarav Patel',
        'customerPhone': '+919876543210',
        'status': 'OutForDelivery',
        'totalAmount': 784.70,
      });

      final repository = OutForDeliveryRepository(firestore: firestore);
      final data = await repository.streamDeliveryDetails('1025').first;

      expect(data.customerId, 'customer_1');
      expect(data.customerName, 'Aarav Patel');
      expect(data.customerPhone, '+919876543210');
      expect(data.totalAmount, 784.70);
    });

    test('falls back to buyerId when customerId is missing', () async {
      final firestore = FakeFirebaseFirestore();
      await firestore.collection('orders').doc('1025').set({
        'buyerId': 'buyer_7',
        'customerName': 'Aarav Patel',
        'status': 'OutForDelivery',
      });

      final repository = OutForDeliveryRepository(firestore: firestore);
      final data = await repository.streamDeliveryDetails('1025').first;

      expect(data.customerId, 'buyer_7');
    });

    test('falls back to uid when customer/buyer/user ids are missing', () async {
      final firestore = FakeFirebaseFirestore();
      await firestore.collection('orders').doc('1025').set({
        'uid': 'uid_42',
        'customerName': 'Aarav Patel',
        'status': 'OutForDelivery',
      });

      final repository = OutForDeliveryRepository(firestore: firestore);
      final data = await repository.streamDeliveryDetails('1025').first;

      expect(data.customerId, 'uid_42');
    });

    test('emits placeholder data when order document does not exist', () async {
      final firestore = FakeFirebaseFirestore();
      final repository = OutForDeliveryRepository(firestore: firestore);
      final data = await repository.streamDeliveryDetails('missing').first;

      expect(data.orderId, 'missing');
      expect(data.rider.name, 'Assigning Rider...');
      expect(data.customerId, isNull);
    });
  });
}
