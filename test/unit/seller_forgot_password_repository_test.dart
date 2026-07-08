import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:food_delivery_app/repositories/seller_repository.dart';

class MockSellerRepository extends Mock implements SellerRepository {}

void main() {
  group('SellerForgotPassword Repository Test', () {
    late MockSellerRepository repository;

    setUp(() {
      repository = MockSellerRepository();
    });

    test('verify sendPasswordResetEmail is called correctly', () async {
      when(() => repository.sendPasswordResetEmail(any())).thenAnswer((_) async => Future.value());
      
      await repository.sendPasswordResetEmail('test@test.com');

      verify(() => repository.sendPasswordResetEmail('test@test.com')).called(1);
    });
  });
}
