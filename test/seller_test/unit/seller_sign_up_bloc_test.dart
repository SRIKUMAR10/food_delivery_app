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
      'emits correct state when address changed',
      build: () => bloc,
      act: (bloc) => bloc.add(const SellerSignUpAddressChanged('123 Main St, Anna Nagar, Chennai')),
      expect: () => [
        const SellerSignUpPageState(
          address: '123 Main St, Anna Nagar, Chennai',
          businessDetails: '123 Main St, Anna Nagar, Chennai',
        ),
      ],
    );

    blocTest<SellerSignUpPageBloc, SellerSignUpPageState>(
      'emits correct state when coordinates changed',
      build: () => bloc,
      act: (bloc) => bloc.add(const SellerSignUpCoordinatesChanged(
        latitude: 13.0827,
        longitude: 80.2707,
        googleMapsUrl: 'https://www.google.com/maps?q=13.0827,80.2707',
        address: 'Marina Beach, Chennai',
      )),
      expect: () => [
        const SellerSignUpPageState(
          latitude: 13.0827,
          longitude: 80.2707,
          googleMapsUrl: 'https://www.google.com/maps?q=13.0827,80.2707',
          address: 'Marina Beach, Chennai',
          businessDetails: 'Marina Beach, Chennai',
        ),
      ],
    );

    blocTest<SellerSignUpPageBloc, SellerSignUpPageState>(
      'emits correct state when fssai changed',
      build: () => bloc,
      act: (bloc) => bloc.add(const SellerSignUpFssaiChanged('12345678901234')),
      expect: () => [
        const SellerSignUpPageState(fssaiNumber: '12345678901234'),
      ],
    );

    blocTest<SellerSignUpPageBloc, SellerSignUpPageState>(
      'emits correct state when gst changed',
      build: () => bloc,
      act: (bloc) => bloc.add(const SellerSignUpGstChanged('33AAAAA0000A1Z5')),
      expect: () => [
        const SellerSignUpPageState(gstNumber: '33AAAAA0000A1Z5'),
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
          businessDetailsError: 'Enter business details or address.',
          addressError: 'Enter business details or address.',
        ),
      ],
    );
  });
}
