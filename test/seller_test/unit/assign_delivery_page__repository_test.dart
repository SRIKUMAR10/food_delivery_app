import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:food_delivery_app/features/seller_bloc_architecture/assign_delivery_page_/assign_delivery_page__service.dart';
import 'package:food_delivery_app/features/seller_bloc_architecture/assign_delivery_page_/assign_delivery_page__repository.dart';
import 'package:food_delivery_app/features/seller_bloc_architecture/assign_delivery_page_/assign_delivery_page__state.dart';

class MockAssignDeliveryService extends Mock implements AssignDeliveryService {}

void main() {
  late MockAssignDeliveryService mockService;
  late AssignDeliveryRepository repository;

  setUp(() {
    mockService = MockAssignDeliveryService();
    repository = AssignDeliveryRepository(service: mockService);
  });

  group('getAvailableRiders', () {
    test('maps raw data to RiderModel list', () async {
      when(() => mockService.fetchAvailableRiders('order_1')).thenAnswer(
        (_) async => [
          {
            'id': 'r1',
            'name': 'John',
            'rating': 4.5,
            'distance': '2.0 km',
            'imageUrl': 'https://example.com/john.jpg',
          },
        ],
      );

      final riders = await repository.getAvailableRiders('order_1');

      expect(riders.length, 1);
      expect(riders.first.id, 'r1');
      expect(riders.first.name, 'John');
      expect(riders.first.rating, 4.5);
      expect(riders.first.distance, '2.0 km');
      expect(riders.first.imageUrl, 'https://example.com/john.jpg');
    });

    test('handles null/empty fields with safe defaults', () async {
      when(() => mockService.fetchAvailableRiders('order_1')).thenAnswer(
        (_) async => [
          {
            'id': null,
            'name': null,
            'rating': null,
            'distance': null,
            'imageUrl': null,
          },
        ],
      );

      final riders = await repository.getAvailableRiders('order_1');

      expect(riders.first.id, '');
      expect(riders.first.name, '');
      expect(riders.first.rating, 0.0);
      expect(riders.first.distance, '');
      expect(riders.first.imageUrl, '');
    });

    test('propagates service errors', () async {
      when(() => mockService.fetchAvailableRiders('order_1')).thenThrow(
        Exception('Firestore error'),
      );

      expect(
        () => repository.getAvailableRiders('order_1'),
        throwsA(isA<Exception>().having(
          (e) => e.toString(),
          'message',
          contains('Firestore error'),
        )),
      );
    });

    test('maps multiple riders correctly', () async {
      when(() => mockService.fetchAvailableRiders('order_1')).thenAnswer(
        (_) async => [
          {
            'id': 'r1',
            'name': 'Rider A',
            'rating': 4.8,
            'distance': '1.5 km',
            'imageUrl': '',
          },
          {
            'id': 'r2',
            'name': 'Rider B',
            'rating': 4.2,
            'distance': '3.0 km',
            'imageUrl': 'https://example.com/b.jpg',
          },
        ],
      );

      final riders = await repository.getAvailableRiders('order_1');

      expect(riders.length, 2);
      expect(riders[0].id, 'r1');
      expect(riders[1].id, 'r2');
    });
  });

  group('watchAvailableRiders', () {
    test('returns a stream of RiderModel lists piped from service', () async {
      final controller = StreamController<List<Map<String, dynamic>>>();

      when(() => mockService.watchAvailableRiders('order_1'))
          .thenAnswer((_) => controller.stream);

      final stream = repository.watchAvailableRiders('order_1');

      controller.add([
        {
          'id': 'r1',
          'name': 'Stream Rider',
          'rating': 4.7,
          'distance': '500 m',
          'imageUrl': 'https://example.com/stream.jpg',
        },
      ]);

      final riders = await stream.first;

      expect(riders.length, 1);
      expect(riders.first.name, 'Stream Rider');
      expect(riders.first.rating, 4.7);

      await controller.close();
    });

    test('emits multiple RiderModel lists as stream updates', () async {
      final controller = StreamController<List<Map<String, dynamic>>>();

      when(() => mockService.watchAvailableRiders('order_1'))
          .thenAnswer((_) => controller.stream);

      final stream = repository.watchAvailableRiders('order_1');

      final future = stream.take(2).toList();

      controller.add([
        {
          'id': 'r1',
          'name': 'First Rider',
          'rating': 5.0,
          'distance': '1 km',
          'imageUrl': '',
        },
      ]);

      controller.add([
        {
          'id': 'r2',
          'name': 'Second Rider',
          'rating': 3.0,
          'distance': '2 km',
          'imageUrl': '',
        },
      ]);

      final results = await future;

      expect(results[0].first.name, 'First Rider');
      expect(results[1].first.name, 'Second Rider');

      await controller.close();
    });
  });

  group('assignRider', () {
    test('delegates to service assignDelivery', () async {
      when(() => mockService.assignDelivery('order_1', 'rider_1', 'Fast!'))
          .thenAnswer((_) async => true);

      final result = await repository.assignRider(
        'order_1',
        'rider_1',
        'Fast!',
      );

      expect(result, isTrue);
      verify(() => mockService.assignDelivery('order_1', 'rider_1', 'Fast!'))
          .called(1);
    });

    test('propagates service errors', () async {
      when(() => mockService.assignDelivery('order_1', 'rider_1', any()))
          .thenThrow(Exception('Transaction failed'));

      expect(
        () => repository.assignRider('order_1', 'rider_1', ''),
        throwsA(isA<Exception>().having(
          (e) => e.toString(),
          'message',
          contains('Transaction failed'),
        )),
      );
    });
  });
}
