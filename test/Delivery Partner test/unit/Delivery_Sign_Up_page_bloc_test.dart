import 'package:flutter_test/flutter_test.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:food_delivery_app/core/models/delivery_partner_model.dart';
import 'package:food_delivery_app/features/Delivery Partner Bloc Architecture/Delivery_Sign_Up_page/Delivery_Sign_Up_page_bloc.dart';
import 'package:food_delivery_app/features/Delivery Partner Bloc Architecture/Delivery_Sign_Up_page/Delivery_Sign_Up_page_event.dart';
import 'package:food_delivery_app/features/Delivery Partner Bloc Architecture/Delivery_Sign_Up_page/Delivery_Sign_Up_page_state.dart';
import 'package:food_delivery_app/features/Delivery Partner Bloc Architecture/Delivery_Sign_Up_page/Delivery_Sign_Up_page_repository.dart';
import 'package:food_delivery_app/features/Delivery Partner Bloc Architecture/Delivery_Sign_Up_page/Delivery_Sign_Up_page_service.dart';

class MockDeliverySignUpRepository implements DeliverySignUpRepositoryBase {
  final bool shouldFail;
  final bool duplicatePhone;
  final String verificationId;

  MockDeliverySignUpRepository({
    this.shouldFail = false,
    this.duplicatePhone = false,
    this.verificationId = 'mock_v_id_123',
  });

  @override
  Future<String> sendPhoneOtp({required String phone}) async {
    if (duplicatePhone) {
      throw Exception('This phone number is already registered. Please login.');
    }
    if (shouldFail) {
      throw Exception('Phone verification failed');
    }
    return verificationId;
  }

  @override
  Future<DeliveryPartnerModel> signUp({
    required String name,
    required String phone,
    required String email,
    required String password,
  }) async {
    throw UnimplementedError();
  }
}

class MockDeliverySignUpService implements DeliverySignUpServiceBase {
  final bool isOnline;

  MockDeliverySignUpService({this.isOnline = true});

  @override
  Future<bool> checkNetworkConnectivity() async => isOnline;
}

void main() {
  group('DeliverySignUpPageBloc Unit Tests', () {
    late MockDeliverySignUpRepository repo;
    late MockDeliverySignUpService service;

    setUp(() {
      repo = MockDeliverySignUpRepository();
      service = MockDeliverySignUpService();
    });

    test('initial state is correct', () {
      final bloc = DeliverySignUpPageBloc(repository: repo, service: service);
      expect(bloc.state.status, DeliverySignUpStatus.initial);
    });

    blocTest<DeliverySignUpPageBloc, DeliverySignUpPageState>(
      'emits otpSent state with verificationId on valid submission',
      build: () => DeliverySignUpPageBloc(repository: repo, service: service),
      act: (bloc) {
        bloc.add(const DeliverySignUpNameChanged('John Partner'));
        bloc.add(const DeliverySignUpPhoneChanged('9876543210'));
        bloc.add(const DeliverySignUpEmailChanged('john@example.com'));
        bloc.add(const DeliverySignUpPasswordChanged('password123'));
        bloc.add(const DeliverySignUpConfirmPasswordChanged('password123'));
        bloc.add(const DeliverySignUpTermsToggled());
        bloc.add(const DeliverySignUpSubmitted());
      },
      expect: () => [
        isA<DeliverySignUpPageState>().having(
          (s) => s.name,
          'name',
          'John Partner',
        ),
        isA<DeliverySignUpPageState>().having(
          (s) => s.phone,
          'phone',
          '9876543210',
        ),
        isA<DeliverySignUpPageState>().having(
          (s) => s.email,
          'email',
          'john@example.com',
        ),
        isA<DeliverySignUpPageState>().having(
          (s) => s.password,
          'password',
          'password123',
        ),
        isA<DeliverySignUpPageState>().having(
          (s) => s.confirmPassword,
          'confirmPassword',
          'password123',
        ),
        isA<DeliverySignUpPageState>().having(
          (s) => s.termsAccepted,
          'termsAccepted',
          true,
        ),
        isA<DeliverySignUpPageState>().having(
          (s) => s.status,
          'status',
          DeliverySignUpStatus.loading,
        ),
        isA<DeliverySignUpPageState>()
            .having((s) => s.status, 'status', DeliverySignUpStatus.otpSent)
            .having((s) => s.verificationId, 'verificationId', 'mock_v_id_123'),
      ],
    );

    blocTest<DeliverySignUpPageBloc, DeliverySignUpPageState>(
      'emits failure state when network is offline',
      build: () => DeliverySignUpPageBloc(
        repository: repo,
        service: MockDeliverySignUpService(isOnline: false),
      ),
      act: (bloc) {
        bloc.add(const DeliverySignUpNameChanged('John Partner'));
        bloc.add(const DeliverySignUpPhoneChanged('9876543210'));
        bloc.add(const DeliverySignUpEmailChanged('john@example.com'));
        bloc.add(const DeliverySignUpPasswordChanged('password123'));
        bloc.add(const DeliverySignUpConfirmPasswordChanged('password123'));
        bloc.add(const DeliverySignUpTermsToggled());
        bloc.add(const DeliverySignUpSubmitted());
      },
      verify: (bloc) {
        expect(bloc.state.status, DeliverySignUpStatus.failure);
        expect(bloc.state.errorMessage, contains('No internet connection'));
      },
    );

    blocTest<DeliverySignUpPageBloc, DeliverySignUpPageState>(
      'emits failure when phone number is already registered',
      build: () => DeliverySignUpPageBloc(
        repository: MockDeliverySignUpRepository(duplicatePhone: true),
        service: service,
      ),
      act: (bloc) {
        bloc.add(const DeliverySignUpNameChanged('John Partner'));
        bloc.add(const DeliverySignUpPhoneChanged('9876543210'));
        bloc.add(const DeliverySignUpEmailChanged('john@example.com'));
        bloc.add(const DeliverySignUpPasswordChanged('password123'));
        bloc.add(const DeliverySignUpConfirmPasswordChanged('password123'));
        bloc.add(const DeliverySignUpTermsToggled());
        bloc.add(const DeliverySignUpSubmitted());
      },
      verify: (bloc) {
        expect(bloc.state.status, DeliverySignUpStatus.failure);
        expect(bloc.state.errorMessage,
            contains('This phone number is already registered. Please login.'));
      },
    );
  });
}
