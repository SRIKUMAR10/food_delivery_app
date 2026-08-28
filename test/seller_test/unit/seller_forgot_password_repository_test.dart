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

    test('verify sendOtp is called correctly', () async {
      when(() => repository.sendOtp(any()))
          .thenAnswer((_) async => 'mock_verification_id');

      final result = await repository.sendOtp('+919876543210');

      expect(result, 'mock_verification_id');
      verify(() => repository.sendOtp('+919876543210')).called(1);
    });

    test('verify resetPasswordWithPhoneOtp is called correctly', () async {
      when(() => repository.resetPasswordWithPhoneOtp(
            verificationId: any(named: 'verificationId'),
            smsCode: any(named: 'smsCode'),
            phoneNumber: any(named: 'phoneNumber'),
            newPassword: any(named: 'newPassword'),
          )).thenAnswer((_) async => Future.value());

      await repository.resetPasswordWithPhoneOtp(
        verificationId: 'v123',
        smsCode: '123456',
        phoneNumber: '+919876543210',
        newPassword: 'NewPassword123!',
      );

      verify(() => repository.resetPasswordWithPhoneOtp(
            verificationId: 'v123',
            smsCode: '123456',
            phoneNumber: '+919876543210',
            newPassword: 'NewPassword123!',
          )).called(1);
    });
  });
}
