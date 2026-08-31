import 'package:flutter_test/flutter_test.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:food_delivery_app/features/buyer_bloc_architecture/buyer_login_page/buyer_login_page_bloc.dart';
import 'package:food_delivery_app/features/buyer_bloc_architecture/buyer_login_page/buyer_login_page_event.dart';
import 'package:food_delivery_app/features/buyer_bloc_architecture/buyer_login_page/buyer_login_page_state.dart';
import 'package:food_delivery_app/features/buyer_bloc_architecture/buyer_login_page/buyer_login_page_repository.dart';

class MockBuyerLoginRepository extends Mock implements BuyerLoginRepository {}

void main() {
  late MockBuyerLoginRepository mockRepository;

  setUp(() {
    mockRepository = MockBuyerLoginRepository();
    when(() => mockRepository.checkNetworkConnectivity()).thenAnswer((_) async => true);
  });

  group('BuyerLoginBloc Unit & KYC Gate Tests', () {
    test('initial state has default values', () {
      final bloc = BuyerLoginBloc(repository: mockRepository);
      expect(bloc.state.status, equals(BuyerLoginStatus.initial));
      expect(bloc.state.isKycCompleted, isFalse);
      expect(bloc.state.phone, isEmpty);
      expect(bloc.state.password, isEmpty);
    });

    blocTest<BuyerLoginBloc, BuyerLoginState>(
      'emits updated phone when BuyerLoginPhoneChanged is added',
      build: () => BuyerLoginBloc(repository: mockRepository),
      act: (bloc) => bloc.add(const BuyerLoginPhoneChanged('+919876543210')),
      expect: () => [
        isA<BuyerLoginState>().having((s) => s.phone, 'phone', '+919876543210'),
      ],
    );

    blocTest<BuyerLoginBloc, BuyerLoginState>(
      'emits updated password and toggles visibility',
      build: () => BuyerLoginBloc(repository: mockRepository),
      act: (bloc) {
        bloc.add(const BuyerLoginPasswordChanged('Secret@123'));
        bloc.add(const BuyerLoginTogglePasswordVisibility());
      },
      expect: () => [
        isA<BuyerLoginState>().having((s) => s.password, 'password', 'Secret@123'),
        isA<BuyerLoginState>().having((s) => s.isPasswordObscured, 'isPasswordObscured', isFalse),
      ],
    );

    blocTest<BuyerLoginBloc, BuyerLoginState>(
      'fails when phone is empty',
      build: () => BuyerLoginBloc(repository: mockRepository),
      act: (bloc) => bloc.add(const BuyerLoginSubmitted(phone: '', password: 'pwd')),
      expect: () => [
        isA<BuyerLoginState>()
            .having((s) => s.status, 'status', BuyerLoginStatus.failure)
            .having((s) => s.errorMessage, 'errorMessage', 'Please enter your phone number or email.'),
      ],
    );

    blocTest<BuyerLoginBloc, BuyerLoginState>(
      'fails when password is empty',
      build: () => BuyerLoginBloc(repository: mockRepository),
      act: (bloc) => bloc.add(const BuyerLoginSubmitted(phone: '+919876543210', password: '')),
      expect: () => [
        isA<BuyerLoginState>()
            .having((s) => s.status, 'status', BuyerLoginStatus.failure)
            .having((s) => s.errorMessage, 'errorMessage', 'Please enter your password.'),
      ],
    );

    blocTest<BuyerLoginBloc, BuyerLoginState>(
      'successful login with uncompleted KYC emits isKycCompleted: false and prefill profile data',
      build: () {
        when(() => mockRepository.login(phone: '+919876543210', password: 'Password@123'))
            .thenAnswer((_) async => 'buyer_uid_101');
        when(() => mockRepository.checkKycAndOnboardingStatus('buyer_uid_101'))
            .thenAnswer((_) async => const BuyerAuthProfileStatus(
                  isKycCompleted: false,
                  fullName: 'Srikumar Rajan',
                  email: 'srikumar@example.com',
                  phone: '+919876543210',
                  imageUrl: 'https://example.com/avatar.jpg',
                  isPhoneVerified: true,
                ));
        return BuyerLoginBloc(repository: mockRepository);
      },
      act: (bloc) => bloc.add(const BuyerLoginSubmitted(
        phone: '+919876543210',
        password: 'Password@123',
      )),
      expect: () => [
        isA<BuyerLoginState>().having((s) => s.status, 'status', BuyerLoginStatus.loading),
        isA<BuyerLoginState>()
            .having((s) => s.status, 'status', BuyerLoginStatus.success)
            .having((s) => s.userId, 'userId', 'buyer_uid_101')
            .having((s) => s.isKycCompleted, 'isKycCompleted', isFalse)
            .having((s) => s.fullName, 'fullName', 'Srikumar Rajan')
            .having((s) => s.email, 'email', 'srikumar@example.com')
            .having((s) => s.phone, 'phone', '+919876543210')
            .having((s) => s.isPhoneVerified, 'isPhoneVerified', isTrue),
      ],
    );

    blocTest<BuyerLoginBloc, BuyerLoginState>(
      'successful login with completed KYC emits isKycCompleted: true',
      build: () {
        when(() => mockRepository.login(phone: '+919876543210', password: 'Password@123'))
            .thenAnswer((_) async => 'buyer_uid_102');
        when(() => mockRepository.checkKycAndOnboardingStatus('buyer_uid_102'))
            .thenAnswer((_) async => const BuyerAuthProfileStatus(
                  isKycCompleted: true,
                  fullName: 'Verified Buyer',
                  email: 'verified@example.com',
                  phone: '+919876543210',
                  isPhoneVerified: true,
                ));
        return BuyerLoginBloc(repository: mockRepository);
      },
      act: (bloc) => bloc.add(const BuyerLoginSubmitted(
        phone: '+919876543210',
        password: 'Password@123',
      )),
      expect: () => [
        isA<BuyerLoginState>().having((s) => s.status, 'status', BuyerLoginStatus.loading),
        isA<BuyerLoginState>()
            .having((s) => s.status, 'status', BuyerLoginStatus.success)
            .having((s) => s.userId, 'userId', 'buyer_uid_102')
            .having((s) => s.isKycCompleted, 'isKycCompleted', isTrue),
      ],
    );
  });
}
