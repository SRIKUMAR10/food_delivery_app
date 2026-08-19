import 'package:flutter_test/flutter_test.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:food_delivery_app/features/Delivery Partner Bloc Architecture/Delivery_Forgot_Password_page/Delivery_Forgot_Password_page_bloc.dart';
import 'package:food_delivery_app/features/Delivery Partner Bloc Architecture/Delivery_Forgot_Password_page/Delivery_Forgot_Password_page_event.dart';
import 'package:food_delivery_app/features/Delivery Partner Bloc Architecture/Delivery_Forgot_Password_page/Delivery_Forgot_Password_page_state.dart';
import 'package:food_delivery_app/features/Delivery Partner Bloc Architecture/Delivery_Forgot_Password_page/Delivery_Forgot_Password_page_repository.dart';
import 'package:food_delivery_app/features/Delivery Partner Bloc Architecture/Delivery_Forgot_Password_page/Delivery_Forgot_Password_page_service.dart';

class MockDeliveryForgotPasswordRepository extends Mock
    implements DeliveryForgotPasswordRepositoryBase {}

class MockDeliveryForgotPasswordService extends Mock
    implements DeliveryForgotPasswordServiceBase {}

void main() {
  late MockDeliveryForgotPasswordRepository mockRepository;
  late MockDeliveryForgotPasswordService mockService;
  late DeliveryForgotPasswordBloc bloc;

  setUp(() {
    mockRepository = MockDeliveryForgotPasswordRepository();
    mockService = MockDeliveryForgotPasswordService();
    bloc = DeliveryForgotPasswordBloc(
      repository: mockRepository,
      service: mockService,
    );
  });

  tearDown(() {
    bloc.close();
  });

  group('DeliveryForgotPasswordBloc Unit Tests', () {
    test('initial state is correct', () {
      expect(bloc.state, const DeliveryForgotPasswordState());
    });

    blocTest<DeliveryForgotPasswordBloc, DeliveryForgotPasswordState>(
      'emits updated phone number on PhoneChanged event',
      build: () => bloc,
      act: (b) => b.add(const DeliveryForgotPasswordPhoneChanged('9876543210')),
      expect: () => [
        const DeliveryForgotPasswordState(phoneNumber: '9876543210'),
      ],
    );

    blocTest<DeliveryForgotPasswordBloc, DeliveryForgotPasswordState>(
      'emits updated OTP on OtpChanged event',
      build: () => bloc,
      act: (b) => b.add(const DeliveryForgotPasswordOtpChanged('123456')),
      expect: () => [
        const DeliveryForgotPasswordState(otp: '123456'),
      ],
    );

    blocTest<DeliveryForgotPasswordBloc, DeliveryForgotPasswordState>(
      'emits updated password on PasswordChanged event',
      build: () => bloc,
      act: (b) => b.add(const DeliveryForgotPasswordPasswordChanged('newPassword123')),
      expect: () => [
        const DeliveryForgotPasswordState(password: 'newPassword123'),
      ],
    );

    blocTest<DeliveryForgotPasswordBloc, DeliveryForgotPasswordState>(
      'emits updated confirmPassword on ConfirmPasswordChanged event',
      build: () => bloc,
      act: (b) => b.add(const DeliveryForgotPasswordConfirmPasswordChanged('newPassword123')),
      expect: () => [
        const DeliveryForgotPasswordState(confirmPassword: 'newPassword123'),
      ],
    );

    blocTest<DeliveryForgotPasswordBloc, DeliveryForgotPasswordState>(
      'toggles password visibility on TogglePasswordVisibility event',
      build: () => bloc,
      act: (b) => b.add(const DeliveryForgotPasswordTogglePasswordVisibility()),
      expect: () => [
        const DeliveryForgotPasswordState(isPasswordVisible: true),
      ],
    );

    blocTest<DeliveryForgotPasswordBloc, DeliveryForgotPasswordState>(
      'toggles confirm password visibility on ToggleConfirmPasswordVisibility event',
      build: () => bloc,
      act: (b) => b.add(const DeliveryForgotPasswordToggleConfirmPasswordVisibility()),
      expect: () => [
        const DeliveryForgotPasswordState(isConfirmPasswordVisible: true),
      ],
    );

    blocTest<DeliveryForgotPasswordBloc, DeliveryForgotPasswordState>(
      'emits error state if phone validation fails when requesting OTP',
      build: () {
        when(() => mockService.validatePhone(any())).thenReturn('Invalid phone number');
        return bloc;
      },
      act: (b) => b.add(const DeliveryForgotPasswordSendOtpRequested()),
      expect: () => [
        const DeliveryForgotPasswordState(
          status: DeliveryForgotPasswordStatus.otpSendFailure,
          phoneError: 'Invalid phone number',
          errorMessage: 'Invalid phone number',
        ),
      ],
    );

    blocTest<DeliveryForgotPasswordBloc, DeliveryForgotPasswordState>(
      'emits otpSent state on successful sendOtp request',
      build: () {
        when(() => mockService.validatePhone(any())).thenReturn(null);
        when(
          () => mockRepository.sendOtp(
            phoneNumber: any(named: 'phoneNumber'),
            onCodeSent: any(named: 'onCodeSent'),
            onVerificationFailed: any(named: 'onVerificationFailed'),
          ),
        ).thenAnswer((invocation) async {
          final onCodeSent = invocation.namedArguments[#onCodeSent] as void Function(String, int?);
          onCodeSent('mock_ver_id', null);
        });
        return bloc;
      },
      seed: () => const DeliveryForgotPasswordState(phoneNumber: '9876543210'),
      act: (b) => b.add(const DeliveryForgotPasswordSendOtpRequested()),
      wait: const Duration(milliseconds: 600),
      expect: () => [
        const DeliveryForgotPasswordState(
          phoneNumber: '9876543210',
          status: DeliveryForgotPasswordStatus.otpSending,
        ),
        const DeliveryForgotPasswordState(
          phoneNumber: '9876543210',
          status: DeliveryForgotPasswordStatus.otpSent,
          verificationId: 'mock_ver_id',
        ),
      ],
    );

    blocTest<DeliveryForgotPasswordBloc, DeliveryForgotPasswordState>(
      'emits otpSendFailure state on sendOtp request failure callback',
      build: () {
        when(() => mockService.validatePhone(any())).thenReturn(null);
        when(
          () => mockRepository.sendOtp(
            phoneNumber: any(named: 'phoneNumber'),
            onCodeSent: any(named: 'onCodeSent'),
            onVerificationFailed: any(named: 'onVerificationFailed'),
          ),
        ).thenAnswer((invocation) async {
          final onVerificationFailed = invocation.namedArguments[#onVerificationFailed]
              as void Function(FirebaseAuthException);
          onVerificationFailed(FirebaseAuthException(
            code: 'invalid-phone-number',
            message: 'Invalid phone format.',
          ));
        });
        return bloc;
      },
      seed: () => const DeliveryForgotPasswordState(phoneNumber: '9876543210'),
      act: (b) => b.add(const DeliveryForgotPasswordSendOtpRequested()),
      wait: const Duration(milliseconds: 600),
      expect: () => [
        const DeliveryForgotPasswordState(
          phoneNumber: '9876543210',
          status: DeliveryForgotPasswordStatus.otpSending,
        ),
        const DeliveryForgotPasswordState(
          phoneNumber: '9876543210',
          status: DeliveryForgotPasswordStatus.otpSendFailure,
          errorMessage: 'Invalid phone format.',
        ),
      ],
    );

    blocTest<DeliveryForgotPasswordBloc, DeliveryForgotPasswordState>(
      'emits failure state on form validation failure during submission',
      build: () {
        when(() => mockService.validatePhone(any())).thenReturn('Phone error');
        when(() => mockService.validateOtp(any())).thenReturn('OTP error');
        when(() => mockService.validatePassword(any())).thenReturn('Password error');
        when(() => mockService.validateConfirmPassword(any(), any()))
            .thenReturn('Confirm password error');
        return bloc;
      },
      act: (b) => b.add(const DeliveryForgotPasswordSubmitted()),
      expect: () => [
        const DeliveryForgotPasswordState(
          status: DeliveryForgotPasswordStatus.failure,
          phoneError: 'Phone error',
          otpError: 'OTP error',
          passwordError: 'Password error',
          confirmPasswordError: 'Confirm password error',
          errorMessage: 'Please fix validation errors.',
        ),
      ],
    );

    blocTest<DeliveryForgotPasswordBloc, DeliveryForgotPasswordState>(
      'emits success state on successful verification and password update',
      build: () {
        when(() => mockService.validatePhone(any())).thenReturn(null);
        when(() => mockService.validateOtp(any())).thenReturn(null);
        when(() => mockService.validatePassword(any())).thenReturn(null);
        when(() => mockService.validateConfirmPassword(any(), any())).thenReturn(null);
        when(
          () => mockRepository.verifyOtpAndUpdatePassword(
            verificationId: any(named: 'verificationId'),
            smsCode: any(named: 'smsCode'),
            phoneNumber: any(named: 'phoneNumber'),
            newPassword: any(named: 'newPassword'),
          ),
        ).thenAnswer((_) async {});
        return bloc;
      },
      seed: () => const DeliveryForgotPasswordState(
        phoneNumber: '9876543210',
        otp: '123456',
        password: 'password123',
        confirmPassword: 'password123',
        verificationId: 'mock_ver_id',
      ),
      act: (b) => b.add(const DeliveryForgotPasswordSubmitted()),
      expect: () => [
        const DeliveryForgotPasswordState(
          phoneNumber: '9876543210',
          otp: '123456',
          password: 'password123',
          confirmPassword: 'password123',
          verificationId: 'mock_ver_id',
          status: DeliveryForgotPasswordStatus.submitting,
        ),
        const DeliveryForgotPasswordState(
          phoneNumber: '9876543210',
          otp: '123456',
          password: 'password123',
          confirmPassword: 'password123',
          verificationId: 'mock_ver_id',
          status: DeliveryForgotPasswordStatus.success,
        ),
      ],
    );
  });
}
