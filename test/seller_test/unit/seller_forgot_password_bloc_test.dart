import 'package:flutter_test/flutter_test.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:food_delivery_app/features/seller_bloc_architecture/seller_forgot_password/seller_forgot_password_bloc.dart';
import 'package:food_delivery_app/features/seller_bloc_architecture/seller_forgot_password/seller_forgot_password_event.dart';
import 'package:food_delivery_app/features/seller_bloc_architecture/seller_forgot_password/seller_forgot_password_state.dart';
import 'package:food_delivery_app/repositories/seller_repository.dart';

class MockSellerRepository extends Mock implements SellerRepository {}

void main() {
  group('SellerForgotPasswordBloc', () {
    late SellerForgotPasswordBloc bloc;
    late MockSellerRepository mockRepository;

    setUp(() {
      mockRepository = MockSellerRepository();
      bloc = SellerForgotPasswordBloc(authRepository: mockRepository);
    });

    tearDown(() {
      bloc.close();
    });

    test('initial state is correct', () {
      expect(bloc.state, const SellerForgotPasswordState());
    });

    blocTest<SellerForgotPasswordBloc, SellerForgotPasswordState>(
      'emits correct state when phone changed',
      build: () => bloc,
      act: (bloc) => bloc.add(const SellerForgotPasswordPhoneChanged('9876543210')),
      expect: () => [
        const SellerForgotPasswordState(phoneNumber: '9876543210'),
      ],
    );

    blocTest<SellerForgotPasswordBloc, SellerForgotPasswordState>(
      'emits correct state when otp changed',
      build: () => bloc,
      act: (bloc) => bloc.add(const SellerForgotPasswordOtpChanged('123456')),
      expect: () => [
        const SellerForgotPasswordState(otp: '123456'),
      ],
    );

    blocTest<SellerForgotPasswordBloc, SellerForgotPasswordState>(
      'emits correct state when password changed',
      build: () => bloc,
      act: (bloc) => bloc.add(const SellerForgotPasswordPasswordChanged('NewPass123!')),
      expect: () => [
        const SellerForgotPasswordState(password: 'NewPass123!'),
      ],
    );

    blocTest<SellerForgotPasswordBloc, SellerForgotPasswordState>(
      'emits correct state when confirm password changed',
      build: () => bloc,
      act: (bloc) => bloc.add(const SellerForgotPasswordConfirmPasswordChanged('NewPass123!')),
      expect: () => [
        const SellerForgotPasswordState(confirmPassword: 'NewPass123!'),
      ],
    );

    blocTest<SellerForgotPasswordBloc, SellerForgotPasswordState>(
      'toggles password and confirm password visibility',
      build: () => bloc,
      act: (bloc) {
        bloc.add(const SellerForgotPasswordTogglePasswordVisibility());
        bloc.add(const SellerForgotPasswordToggleConfirmPasswordVisibility());
      },
      expect: () => [
        const SellerForgotPasswordState(isPasswordVisible: true),
        const SellerForgotPasswordState(
          isPasswordVisible: true,
          isConfirmPasswordVisible: true,
        ),
      ],
    );

    blocTest<SellerForgotPasswordBloc, SellerForgotPasswordState>(
      'emits [otpSendFailure] when phone number is invalid',
      build: () => bloc,
      act: (bloc) => bloc.add(const SellerForgotPasswordSendOtpRequested()),
      expect: () => [
        const SellerForgotPasswordState(
          status: SellerForgotPasswordStatus.otpSendFailure,
          phoneError: 'Please enter your mobile number',
          errorMessage: 'Please enter your mobile number',
        ),
      ],
    );

    blocTest<SellerForgotPasswordBloc, SellerForgotPasswordState>(
      'emits [otpSending, otpSent] when phone number is valid and OTP sent',
      setUp: () {
        when(() => mockRepository.sendOtp(any()))
            .thenAnswer((_) async => 'mock_verification_id');
      },
      build: () => bloc,
      seed: () => const SellerForgotPasswordState(phoneNumber: '9876543210'),
      act: (bloc) => bloc.add(const SellerForgotPasswordSendOtpRequested()),
      expect: () => [
        const SellerForgotPasswordState(
          phoneNumber: '9876543210',
          status: SellerForgotPasswordStatus.otpSending,
        ),
        const SellerForgotPasswordState(
          phoneNumber: '9876543210',
          status: SellerForgotPasswordStatus.otpSent,
          verificationId: 'mock_verification_id',
        ),
      ],
    );

    blocTest<SellerForgotPasswordBloc, SellerForgotPasswordState>(
      'emits [failure] on empty fields submit',
      build: () => bloc,
      act: (bloc) => bloc.add(const SellerForgotPasswordSubmitted()),
      expect: () => [
        const SellerForgotPasswordState(
          status: SellerForgotPasswordStatus.failure,
          phoneError: 'Please enter your mobile number',
          otpError: 'Please enter the 6-digit OTP code',
          passwordError: 'Please enter a new password',
          confirmPasswordError: 'Please confirm your new password',
          errorMessage: 'Please enter your mobile number',
        ),
      ],
    );

    blocTest<SellerForgotPasswordBloc, SellerForgotPasswordState>(
      'emits [submitting, success] on valid phone, OTP, matching passwords and submit',
      setUp: () {
        when(() => mockRepository.resetPasswordWithPhoneOtp(
              verificationId: any(named: 'verificationId'),
              smsCode: any(named: 'smsCode'),
              phoneNumber: any(named: 'phoneNumber'),
              newPassword: any(named: 'newPassword'),
            )).thenAnswer((_) async {});
      },
      build: () => bloc,
      seed: () => const SellerForgotPasswordState(
        phoneNumber: '9876543210',
        otp: '123456',
        password: 'Password123!',
        confirmPassword: 'Password123!',
        verificationId: 'mock_verification_id',
      ),
      act: (bloc) => bloc.add(const SellerForgotPasswordSubmitted()),
      expect: () => [
        const SellerForgotPasswordState(
          phoneNumber: '9876543210',
          otp: '123456',
          password: 'Password123!',
          confirmPassword: 'Password123!',
          verificationId: 'mock_verification_id',
          status: SellerForgotPasswordStatus.submitting,
        ),
        const SellerForgotPasswordState(
          phoneNumber: '9876543210',
          otp: '123456',
          password: 'Password123!',
          confirmPassword: 'Password123!',
          verificationId: 'mock_verification_id',
          status: SellerForgotPasswordStatus.success,
        ),
      ],
    );
  });
}
