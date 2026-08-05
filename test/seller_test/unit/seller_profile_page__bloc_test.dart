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
  group('SellerProfilePageBloc', () {
    late SellerProfilePageBloc bloc;
    late MockAuthService mockAuthService;
    late MockProfileRepository mockProfileRepository;

    setUp(() {
      mockAuthService = MockAuthService();
      mockProfileRepository = MockProfileRepository();
      when(() => mockAuthService.currentUserId).thenReturn('seller_1');
      bloc = SellerProfilePageBloc(
        authService: mockAuthService,
        profileRepository: mockProfileRepository,
      );
    });

    tearDown(() {
      bloc.close();
    });

    test('initial state is ProfileInitial', () {
      expect(bloc.state, isA<ProfileInitial>());
    });

    blocTest<SellerProfilePageBloc, SellerProfilePageState>(
      'emits [ProfileLoading, ProfileLoaded] when LoadProfile is added',
      build: () {
        when(() => mockProfileRepository.loadProfile('seller_1'))
            .thenAnswer((_) async => {'seller': null});
        return bloc;
      },
      act: (bloc) => bloc.add(LoadProfile()),
      expect: () => [
        isA<ProfileLoading>(),
        isA<ProfileLoaded>(),
      ],
    );

    blocTest<SellerProfilePageBloc, SellerProfilePageState>(
      'emits [ProfileLoading, ProfileError] when profile loading fails',
      build: () {
        when(() => mockProfileRepository.loadProfile('seller_1'))
            .thenThrow(Exception('Failed to load profile'));
        return bloc;
      },
      act: (bloc) => bloc.add(LoadProfile()),
      expect: () => [
        isA<ProfileLoading>(),
        isA<ProfileError>(),
      ],
    );

    blocTest<SellerProfilePageBloc, SellerProfilePageState>(
      'emits [ProfileInitial] when LogoutRequested is added',
      build: () => bloc,
      act: (bloc) => bloc.add(LogoutRequested()),
      expect: () => [
        isA<ProfileInitial>(),
      ],
    );
  });
}
