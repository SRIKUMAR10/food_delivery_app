import 'package:flutter_test/flutter_test.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:food_delivery_app/core/models/delivery_partner_model.dart';
import 'package:food_delivery_app/features/Delivery Partner Bloc Architecture/Delivery_OTP_Verification_page/Delivery_OTP_Verification_page_bloc.dart';
import 'package:food_delivery_app/features/Delivery Partner Bloc Architecture/Delivery_OTP_Verification_page/Delivery_OTP_Verification_page_event.dart';
import 'package:food_delivery_app/features/Delivery Partner Bloc Architecture/Delivery_OTP_Verification_page/Delivery_OTP_Verification_page_state.dart';
import 'package:food_delivery_app/features/Delivery Partner Bloc Architecture/Delivery_OTP_Verification_page/Delivery_OTP_Verification_page_repository.dart';

class MockDeliveryOtpVerificationRepository
    implements DeliveryOtpVerificationRepositoryBase {
  final bool shouldFail;

  MockDeliveryOtpVerificationRepository({this.shouldFail = false});

  @override
  Future<DeliveryPartnerModel> verifyOtpAndCreateAccount({
    required String verificationId,
    required String smsCode,
    required String name,
    required String phone,
    required String email,
    required String password,
  }) async {
    if (shouldFail) {
      throw Exception('Invalid OTP code');
    }
    return DeliveryPartnerModel(
      id: 'mock_partner_uid',
      phoneNumber: phone,
      displayName: name,
      email: email,
      status: 'pending',
      isActive: false,
      isPhoneVerified: true,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }

  @override
  Future<String> resendOtp({required String phone}) async {
    if (shouldFail) {
      throw Exception('Resend failed');
    }
    return 'new_v_id_999';
  }
}

void main() {
  group('DeliveryOtpVerificationBloc Unit Tests', () {
    late MockDeliveryOtpVerificationRepository repo;

    setUp(() {
      repo = MockDeliveryOtpVerificationRepository();
    });

    test('initial state initializes timer and state values', () {
      final bloc = DeliveryOtpVerificationBloc(
        repository: repo,
        verificationId: 'v_id_123',
        name: 'John Partner',
        phone: '9876543210',
        email: 'john@example.com',
        password: 'password123',
      );

      expect(bloc.state.status, DeliveryOtpStatus.initial);
      expect(bloc.state.verificationId, 'v_id_123');
      expect(bloc.state.phone, '9876543210');
      bloc.close();
    });

    blocTest<DeliveryOtpVerificationBloc, DeliveryOtpVerificationState>(
      'emits success state on valid 6-digit OTP entry and submit',
      build: () => DeliveryOtpVerificationBloc(
        repository: repo,
        verificationId: 'v_id_123',
        name: 'John Partner',
        phone: '9876543210',
        email: 'john@example.com',
        password: 'password123',
      ),
      act: (bloc) {
        bloc.add(const DeliveryOtpChangedEvent('123456'));
        bloc.add(const DeliveryOtpVerifySubmittedEvent());
      },
      expect: () => [
        isA<DeliveryOtpVerificationState>().having(
          (s) => s.otp,
          'otp',
          '123456',
        ),
        isA<DeliveryOtpVerificationState>().having(
          (s) => s.status,
          'status',
          DeliveryOtpStatus.loading,
        ),
        isA<DeliveryOtpVerificationState>().having(
          (s) => s.status,
          'status',
          DeliveryOtpStatus.success,
        ),
      ],
    );

    blocTest<DeliveryOtpVerificationBloc, DeliveryOtpVerificationState>(
      'emits failure state when OTP verification fails',
      build: () => DeliveryOtpVerificationBloc(
        repository: MockDeliveryOtpVerificationRepository(shouldFail: true),
        verificationId: 'v_id_123',
        name: 'John Partner',
        phone: '9876543210',
        email: 'john@example.com',
        password: 'password123',
      ),
      act: (bloc) {
        bloc.add(const DeliveryOtpChangedEvent('123456'));
        bloc.add(const DeliveryOtpVerifySubmittedEvent());
      },
      verify: (bloc) {
        expect(bloc.state.status, DeliveryOtpStatus.failure);
        expect(bloc.state.errorMessage, contains('Invalid OTP code'));
      },
    );
  });
}
