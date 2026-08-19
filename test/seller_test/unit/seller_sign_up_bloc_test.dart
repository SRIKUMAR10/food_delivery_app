import 'package:flutter_test/flutter_test.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:food_delivery_app/features/seller_bloc_architecture/seller_sign_up_page/seller_sign_up_page_bloc.dart';
import 'package:food_delivery_app/features/seller_bloc_architecture/seller_sign_up_page/seller_sign_up_page_event.dart';
import 'package:food_delivery_app/features/seller_bloc_architecture/seller_sign_up_page/seller_sign_up_page_state.dart';
import 'package:food_delivery_app/repositories/seller_repository.dart';

class MockSellerRepository extends Mock implements SellerRepository {}

void main() {
  group('SellerSignUpPageBloc', () {
    late SellerSignUpPageBloc bloc;
    late MockSellerRepository mockRepository;

    setUp(() {
      mockRepository = MockSellerRepository();
      bloc = SellerSignUpPageBloc(authRepository: mockRepository);
    });

    tearDown(() {
      bloc.close();
    });

    test('initial state is correct', () {
      expect(bloc.state, const SellerSignUpPageState());
    });

    blocTest<SellerSignUpPageBloc, SellerSignUpPageState>(
      'emits correct state when name changed',
      build: () => bloc,
      act: (bloc) => bloc.add(const SellerSignUpNameChanged('Test Store')),
      expect: () => [
        const SellerSignUpPageState(name: 'Test Store'),
      ],
    );

    blocTest<SellerSignUpPageBloc, SellerSignUpPageState>(
      'emits correct state when email changed',
      build: () => bloc,
      act: (bloc) => bloc.add(const SellerSignUpEmailChanged('test@test.com')),
      expect: () => [
        const SellerSignUpPageState(email: 'test@test.com'),
      ],
    );

    blocTest<SellerSignUpPageBloc, SellerSignUpPageState>(
      'emits correct state when password changed',
      build: () => bloc,
      act: (bloc) => bloc.add(const SellerSignUpPasswordChanged('pass123')),
      expect: () => [
        const SellerSignUpPageState(password: 'pass123'),
      ],
    );

    blocTest<SellerSignUpPageBloc, SellerSignUpPageState>(
      'emits failure on personal details submitted with empty fields',
      build: () => bloc,
      act: (bloc) => bloc.add(const SellerSignUpPersonalDetailsSubmitted()),
      expect: () => [
        const SellerSignUpPageState(
          status: SellerSignUpStatus.failure,
          errorMessage: 'Please fill all fields.',
          nameError: 'Name must be at least 2 characters.',
          shopNameError: 'Shop name must be at least 2 characters.',
          businessDetailsError: 'Enter business details.',
        ),
      ],
    );
  });
}
