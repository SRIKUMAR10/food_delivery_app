import 'package:flutter_test/flutter_test.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:food_delivery_app/core/repositories/i_seller_profile_repository.dart';
import 'package:food_delivery_app/core/services/i_auth_service.dart';
import 'package:food_delivery_app/features/seller_bloc_architecture/seller_profile_page/seller_profile_page__bloc.dart';
import 'package:food_delivery_app/features/seller_bloc_architecture/seller_profile_page/seller_profile_page__event.dart';
import 'package:food_delivery_app/features/seller_bloc_architecture/seller_profile_page/seller_profile_page__state.dart';

class MockAuthService extends Mock implements IAuthService {}
class MockProfileRepository extends Mock implements ISellerProfileRepository {}

void main() {
  group('Seller Profile Error Handling Tests', () {
    late SellerProfilePageBloc bloc;
    late MockAuthService mockAuthService;
    late MockProfileRepository mockProfileRepository;

    setUp(() {
      mockAuthService = MockAuthService();
      mockProfileRepository = MockProfileRepository();
      when(() => mockAuthService.currentUserId).thenReturn('seller_1');
      when(() => mockProfileRepository.watchProfile(any()))
          .thenAnswer((_) => const Stream.empty());

      bloc = SellerProfilePageBloc(
        authService: mockAuthService,
        profileRepository: mockProfileRepository,
      );
    });

    tearDown(() {
      bloc.close();
    });

    blocTest<SellerProfilePageBloc, SellerProfilePageState>(
      'emits ProfileError when user is not authenticated',
      build: () {
        when(() => mockAuthService.currentUserId).thenReturn(null);
        return bloc;
      },
      act: (bloc) => bloc.add(LoadProfile()),
      expect: () => [
        isA<ProfileLoading>(),
        isA<ProfileError>().having((e) => e.message, 'message', 'User not authenticated'),
      ],
    );

    blocTest<SellerProfilePageBloc, SellerProfilePageState>(
      'emits ProfileError when repository throws on loadProfile',
      build: () {
        when(() => mockProfileRepository.loadProfile('seller_1'))
            .thenThrow(Exception('Network timeout while connecting to Firestore'));
        return bloc;
      },
      act: (bloc) => bloc.add(LoadProfile()),
      expect: () => [
        isA<ProfileLoading>(),
        isA<ProfileError>().having((e) => e.message, 'message', contains('Network timeout')),
      ],
    );

    blocTest<SellerProfilePageBloc, SellerProfilePageState>(
      'handles updateProfile exception gracefully without crash',
      build: () {
        when(() => mockProfileRepository.updateProfile('seller_1', any()))
            .thenThrow(Exception('Firestore write permission denied'));
        return bloc;
      },
      seed: () => ProfileLoaded(
        storeName: 'Spice Bar',
        email: 'test@spice.com',
        phone: '1234567890',
        profileImageUrl: '',
        notificationsEnabled: true,
        role: 'seller',
        createdAt: DateTime(2025, 1, 1),
        isVerified: true,
      ),
      act: (bloc) => bloc.add(const UpdateLocationDetails(address: '123 New Road')),
      expect: () => [
        isA<ProfileLoaded>().having((s) => s.address, 'address', '123 New Road'), // optimistic update
      ],
    );
  });
}
