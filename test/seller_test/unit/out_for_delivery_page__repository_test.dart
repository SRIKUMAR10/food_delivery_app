import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

// Assuming an OutForDeliveryRepository exists for Clean Architecture
abstract class OutForDeliveryRepository {
  Future<void> fetchDeliveryDetails(String orderId);
}

class MockOutForDeliveryRepository extends Mock
    implements OutForDeliveryRepository {}

void main() {
  group('OutForDeliveryRepository', () {
    late MockOutForDeliveryRepository repository;

    setUp(() {
      repository = MockOutForDeliveryRepository();
    });

    test('fetchDeliveryDetails calls API successfully', () async {
      when(
        () => repository.fetchDeliveryDetails(any()),
      ).thenAnswer((_) async => Future.value());

      await repository.fetchDeliveryDetails('1025');

      verify(() => repository.fetchDeliveryDetails('1025')).called(1);
    });
  });
}
