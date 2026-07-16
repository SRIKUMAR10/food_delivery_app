import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:food_delivery_app/features/seller_bloc_architecture/disputes_refunds_page_/disputes_refunds_page_repository.dart';
import 'package:food_delivery_app/features/seller_bloc_architecture/disputes_refunds_page_/disputes_refunds_page_service.dart';

class MockDisputesRefundsService extends Mock implements DisputesRefundsService {}

void main() {
  group('DisputesRefundsRepository', () {
    late DisputesRefundsRepository repository;
    late MockDisputesRefundsService mockService;

    setUp(() {
      mockService = MockDisputesRefundsService();
      repository = DisputesRefundsRepository(service: mockService);
    });

    test('getDisputes calls service fetchDisputes', () async {
      when(() => mockService.fetchDisputes(any())).thenAnswer((_) async => []);
      await repository.getDisputes('seller1');
      verify(() => mockService.fetchDisputes('seller1')).called(1);
    });
  });
}
