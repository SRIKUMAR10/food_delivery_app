import 'package:flutter_test/flutter_test.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:food_delivery_app/features/seller_bloc_architecture/seller_sign_up/seller_sign_up_bloc.dart';
import 'package:food_delivery_app/features/seller_bloc_architecture/seller_sign_up/seller_sign_up_event.dart';
import 'package:food_delivery_app/features/seller_bloc_architecture/seller_sign_up/seller_sign_up_state.dart';
import 'package:food_delivery_app/repositories/seller_repository.dart';

class MockSellerRepository extends Mock implements SellerRepository {}

void main() {
  late MockSellerRepository mockSellerRepository;

  setUp(() {
    mockSellerRepository = MockSellerRepository();
  });

  group('SellerSignUpBloc', () {
    test('initial state is correct', () {
      final bloc = SellerSignUpBloc(authRepository: mockSellerRepository);
      expect(bloc.state.name, '');
      expect(bloc.state.email, '');
      expect(bloc.state.password, '');
      expect(bloc.state.isPasswordObscured, true);
      expect(bloc.state.status, SellerSignUpStatus.initial);
      expect(bloc.state.errorMessage, isNull);
      bloc.close();
    });

    blocTest<SellerSignUpBloc, SellerSignUpState>(
      'emits updated name when SellerSignUpNameChanged is added',
      build: () => SellerSignUpBloc(authRepository: mockSellerRepository),
      act: (bloc) => bloc.add(const SellerSignUpNameChanged('John Doe')),
      expect: () => [
        const SellerSignUpState(
          name: 'John Doe',
          status: SellerSignUpStatus.initial,
        ),
      ],
    );

    blocTest<SellerSignUpBloc, SellerSignUpState>(
      'emits updated email when SellerSignUpEmailChanged is added',
      build: () => SellerSignUpBloc(authRepository: mockSellerRepository),
      act: (bloc) =>
          bloc.add(const SellerSignUpEmailChanged('seller@example.com')),
      expect: () => [
        const SellerSignUpState(
          email: 'seller@example.com',
          status: SellerSignUpStatus.initial,
        ),
      ],
    );

    blocTest<SellerSignUpBloc, SellerSignUpState>(
      'emits updated password when SellerSignUpPasswordChanged is added',
      build: () => SellerSignUpBloc(authRepository: mockSellerRepository),
      act: (bloc) => bloc.add(const SellerSignUpPasswordChanged('password123')),
      expect: () => [
        const SellerSignUpState(
          password: 'password123',
          status: SellerSignUpStatus.initial,
        ),
      ],
    );

    blocTest<SellerSignUpBloc, SellerSignUpState>(
      'toggles isPasswordObscured when SellerSignUpPasswordVisibilityToggled is added',
      build: () => SellerSignUpBloc(authRepository: mockSellerRepository),
      act: (bloc) => bloc.add(SellerSignUpPasswordVisibilityToggled()),
      expect: () => [const SellerSignUpState(isPasswordObscured: false)],
    );

    blocTest<SellerSignUpBloc, SellerSignUpState>(
      'emits [loading, otpSent] when SellerSignUpSubmitted succeeds',
      setUp: () {
        when(() => mockSellerRepository.initiateSignUp(
              name: any(named: 'name'),
              shopName: any(named: 'shopName'),
              businessDetails: any(named: 'businessDetails'),
              phoneNumber: any(named: 'phoneNumber'),
              email: any(named: 'email'),
              password: any(named: 'password'),
            )).thenAnswer((_) async {});
      },
      build: () => SellerSignUpBloc(authRepository: mockSellerRepository),
      seed: () => const SellerSignUpState(
        name: 'John Doe',
        shopName: 'John Shop',
        businessDetails: 'Restaurant',
        phoneNumber: '9876543210',
        email: 'seller@example.com',
        password: 'password123',
        confirmPassword: 'password123',
      ),
      act: (bloc) => bloc.add(const SellerSignUpSubmitted()),
      expect: () => [
        const SellerSignUpState(
          name: 'John Doe',
          shopName: 'John Shop',
          businessDetails: 'Restaurant',
          phoneNumber: '9876543210',
          email: 'seller@example.com',
          password: 'password123',
          confirmPassword: 'password123',
          status: SellerSignUpStatus.loading,
        ),
        const SellerSignUpState(
          name: 'John Doe',
          shopName: 'John Shop',
          businessDetails: 'Restaurant',
          phoneNumber: '9876543210',
          email: 'seller@example.com',
          password: 'password123',
          confirmPassword: 'password123',
          status: SellerSignUpStatus.otpSent,
        ),
      ],
    );

    blocTest<SellerSignUpBloc, SellerSignUpState>(
      'emits [loading, failure] when SellerSignUpSubmitted fails',
      setUp: () {
        when(() => mockSellerRepository.initiateSignUp(
              name: any(named: 'name'),
              shopName: any(named: 'shopName'),
              businessDetails: any(named: 'businessDetails'),
              phoneNumber: any(named: 'phoneNumber'),
              email: any(named: 'email'),
              password: any(named: 'password'),
            )).thenThrow(Exception('Phone number already registered'));
      },
      build: () => SellerSignUpBloc(authRepository: mockSellerRepository),
      seed: () => const SellerSignUpState(
        name: 'John Doe',
        shopName: 'John Shop',
        businessDetails: 'Restaurant',
        phoneNumber: '9876543210',
        email: 'seller@example.com',
        password: 'password123',
        confirmPassword: 'password123',
      ),
      act: (bloc) => bloc.add(const SellerSignUpSubmitted()),
      expect: () => [
        const SellerSignUpState(
          name: 'John Doe',
          shopName: 'John Shop',
          businessDetails: 'Restaurant',
          phoneNumber: '9876543210',
          email: 'seller@example.com',
          password: 'password123',
          confirmPassword: 'password123',
          status: SellerSignUpStatus.loading,
        ),
        const SellerSignUpState(
          name: 'John Doe',
          shopName: 'John Shop',
          businessDetails: 'Restaurant',
          phoneNumber: '9876543210',
          email: 'seller@example.com',
          password: 'password123',
          confirmPassword: 'password123',
          status: SellerSignUpStatus.failure,
          errorMessage: 'Exception: Phone number already registered',
        ),
      ],
    );
  });
}
