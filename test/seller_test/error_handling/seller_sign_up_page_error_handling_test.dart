// ignore_for_file: lines_longer_than_80_chars

import 'package:flutter_test/flutter_test.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:food_delivery_app/features/seller_bloc_architecture/seller_sign_up_page/seller_sign_up_page_bloc.dart';
import 'package:food_delivery_app/features/seller_bloc_architecture/seller_sign_up_page/seller_sign_up_page_event.dart';
import 'package:food_delivery_app/features/seller_bloc_architecture/seller_sign_up_page/seller_sign_up_page_state.dart';
import 'package:food_delivery_app/repositories/seller_repository.dart';

class MockSellerRepository extends Mock implements SellerRepository {}

void main() {
  group('SellerSignUpPage - Error Handling Tests', () {
    late SellerSignUpPageBloc bloc;
    late MockSellerRepository mockRepo;

    setUp(() {
      mockRepo = MockSellerRepository();
      bloc = SellerSignUpPageBloc(authRepository: mockRepo);
    });

    tearDown(() {
      bloc.close();
    });

    blocTest<SellerSignUpPageBloc, SellerSignUpPageState>(
      'Handles email-already-in-use and formats friendly error message',
      build: () {
        when(
          () => mockRepo.initiateSignUp(
            name: any(named: 'name'),
            shopName: any(named: 'shopName'),
            businessDetails: any(named: 'businessDetails'),
            phoneNumber: any(named: 'phoneNumber'),
            email: any(named: 'email'),
            password: any(named: 'password'),
            address: any(named: 'address'),
            latitude: any(named: 'latitude'),
            longitude: any(named: 'longitude'),
            googleMapsUrl: any(named: 'googleMapsUrl'),
            fssaiNumber: any(named: 'fssaiNumber'),
            gstNumber: any(named: 'gstNumber'),
          ),
        ).thenThrow(
          Exception(
            '[firebase_auth/email-already-in-use] The email address is already in use by another account.',
          ),
        );
        return bloc;
      },
      seed: () => const SellerSignUpPageState(
        step: SellerSignUpStep.contactPassword,
        name: 'Jane Doe',
        shopName: 'Jane Treats',
        businessDetails: 'Main St',
        phone: '+919876543210',
        email: 'used@example.com',
        password: 'Password@123',
        confirmPassword: 'Password@123',
        termsAccepted: true,
      ),
      act: (bloc) => bloc.add(const SellerSignUpContactSubmitted()),
      expect: () => [
        const SellerSignUpPageState(
          step: SellerSignUpStep.contactPassword,
          name: 'Jane Doe',
          shopName: 'Jane Treats',
          businessDetails: 'Main St',
          phone: '+919876543210',
          email: 'used@example.com',
          password: 'Password@123',
          confirmPassword: 'Password@123',
          termsAccepted: true,
          status: SellerSignUpStatus.loading,
        ),
        const SellerSignUpPageState(
          step: SellerSignUpStep.contactPassword,
          name: 'Jane Doe',
          shopName: 'Jane Treats',
          businessDetails: 'Main St',
          phone: '+919876543210',
          email: 'used@example.com',
          password: 'Password@123',
          confirmPassword: 'Password@123',
          termsAccepted: true,
          status: SellerSignUpStatus.failure,
          errorMessage:
              'The email address is already in use by another account.',
        ),
      ],
    );

    blocTest<SellerSignUpPageBloc, SellerSignUpPageState>(
      'Handles phone-number-already-exists error correctly',
      build: () {
        when(
          () => mockRepo.initiateSignUp(
            name: any(named: 'name'),
            shopName: any(named: 'shopName'),
            businessDetails: any(named: 'businessDetails'),
            phoneNumber: any(named: 'phoneNumber'),
            email: any(named: 'email'),
            password: any(named: 'password'),
            address: any(named: 'address'),
            latitude: any(named: 'latitude'),
            longitude: any(named: 'longitude'),
            googleMapsUrl: any(named: 'googleMapsUrl'),
            fssaiNumber: any(named: 'fssaiNumber'),
            gstNumber: any(named: 'gstNumber'),
          ),
        ).thenThrow(
          Exception('phone-number-already-exists'),
        );
        return bloc;
      },
      seed: () => const SellerSignUpPageState(
        step: SellerSignUpStep.contactPassword,
        name: 'Jane Doe',
        shopName: 'Jane Treats',
        businessDetails: 'Main St',
        phone: '+919876543210',
        email: 'jane@example.com',
        password: 'Password@123',
        confirmPassword: 'Password@123',
        termsAccepted: true,
      ),
      act: (bloc) => bloc.add(const SellerSignUpContactSubmitted()),
      expect: () => [
        const SellerSignUpPageState(
          step: SellerSignUpStep.contactPassword,
          name: 'Jane Doe',
          shopName: 'Jane Treats',
          businessDetails: 'Main St',
          phone: '+919876543210',
          email: 'jane@example.com',
          password: 'Password@123',
          confirmPassword: 'Password@123',
          termsAccepted: true,
          status: SellerSignUpStatus.loading,
        ),
        const SellerSignUpPageState(
          step: SellerSignUpStep.contactPassword,
          name: 'Jane Doe',
          shopName: 'Jane Treats',
          businessDetails: 'Main St',
          phone: '+919876543210',
          email: 'jane@example.com',
          password: 'Password@123',
          confirmPassword: 'Password@123',
          termsAccepted: true,
          status: SellerSignUpStatus.failure,
          errorMessage:
              'This Phone Number is already registered. Please Login.',
        ),
      ],
    );

    blocTest<SellerSignUpPageBloc, SellerSignUpPageState>(
      'Handles network error correctly',
      build: () {
        when(
          () => mockRepo.initiateSignUp(
            name: any(named: 'name'),
            shopName: any(named: 'shopName'),
            businessDetails: any(named: 'businessDetails'),
            phoneNumber: any(named: 'phoneNumber'),
            email: any(named: 'email'),
            password: any(named: 'password'),
            address: any(named: 'address'),
            latitude: any(named: 'latitude'),
            longitude: any(named: 'longitude'),
            googleMapsUrl: any(named: 'googleMapsUrl'),
            fssaiNumber: any(named: 'fssaiNumber'),
            gstNumber: any(named: 'gstNumber'),
          ),
        ).thenThrow(
          Exception('network-request-failed'),
        );
        return bloc;
      },
      seed: () => const SellerSignUpPageState(
        step: SellerSignUpStep.contactPassword,
        name: 'Jane Doe',
        shopName: 'Jane Treats',
        businessDetails: 'Main St',
        phone: '+919876543210',
        email: 'jane@example.com',
        password: 'Password@123',
        confirmPassword: 'Password@123',
        termsAccepted: true,
      ),
      act: (bloc) => bloc.add(const SellerSignUpContactSubmitted()),
      expect: () => [
        const SellerSignUpPageState(
          step: SellerSignUpStep.contactPassword,
          name: 'Jane Doe',
          shopName: 'Jane Treats',
          businessDetails: 'Main St',
          phone: '+919876543210',
          email: 'jane@example.com',
          password: 'Password@123',
          confirmPassword: 'Password@123',
          termsAccepted: true,
          status: SellerSignUpStatus.loading,
        ),
        const SellerSignUpPageState(
          step: SellerSignUpStep.contactPassword,
          name: 'Jane Doe',
          shopName: 'Jane Treats',
          businessDetails: 'Main St',
          phone: '+919876543210',
          email: 'jane@example.com',
          password: 'Password@123',
          confirmPassword: 'Password@123',
          termsAccepted: true,
          status: SellerSignUpStatus.failure,
          errorMessage: 'Please check your internet connection.',
        ),
      ],
    );
  });
}
