import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:food_delivery_app/repositories/seller_repository.dart';

class MockSellerRepository extends Mock implements SellerRepository {}

void main() {
  group('SellerSignUp Repository Test', () {
    late MockSellerRepository repository;

    setUp(() {
      repository = MockSellerRepository();
    });

    test('initiateSignUp is called with correct parameters', () async {
      when(() => repository.initiateSignUp(
            name: any(named: 'name'),
            shopName: any(named: 'shopName'),
            businessDetails: any(named: 'businessDetails'),
            phoneNumber: any(named: 'phoneNumber'),
            email: any(named: 'email'),
            password: any(named: 'password'),
          )).thenAnswer((_) async {});

      await repository.initiateSignUp(
        name: 'Test',
        shopName: 'Shop',
        businessDetails: 'Food',
        phoneNumber: '+919876543210',
        email: 'test@test.com',
        password: 'pass123',
      );

      verify(() => repository.initiateSignUp(
            name: 'Test',
            shopName: 'Shop',
            businessDetails: 'Food',
            phoneNumber: '+919876543210',
            email: 'test@test.com',
            password: 'pass123',
          )).called(1);
    });

    test('confirmSignUpOtp is called with correct parameters', () async {
      when(() => repository.confirmSignUpOtp(
            otpCode: any(named: 'otpCode'),
            phoneNumber: any(named: 'phoneNumber'),
            verificationId: any(named: 'verificationId'),
            name: any(named: 'name'),
            shopName: any(named: 'shopName'),
            businessDetails: any(named: 'businessDetails'),
            email: any(named: 'email'),
            password: any(named: 'password'),
          )).thenAnswer((_) async => true);

      final result = await repository.confirmSignUpOtp(
        otpCode: '123456',
        phoneNumber: '+919876543210',
        verificationId: 'test-verification-id',
        name: 'Test',
        shopName: 'Shop',
        businessDetails: 'Food',
        email: 'test@test.com',
        password: 'pass123',
      );

      expect(result, isTrue);
      verify(() => repository.confirmSignUpOtp(
            otpCode: '123456',
            phoneNumber: '+919876543210',
            verificationId: 'test-verification-id',
            name: 'Test',
            shopName: 'Shop',
            businessDetails: 'Food',
            email: 'test@test.com',
            password: 'pass123',
          )).called(1);
    });
  });
}
