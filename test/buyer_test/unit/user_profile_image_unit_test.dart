import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:food_delivery_app/core/services/i_auth_service.dart';
import 'package:food_delivery_app/core/repositories/i_user_profile_repository.dart';
import 'package:food_delivery_app/features/buyer_bloc_architecture/user_profile_image/user_profile_image_Bloc.dart';
import 'package:food_delivery_app/features/buyer_bloc_architecture/user_profile_image/user_profile_models.dart';

class MockAuthService extends Mock implements IAuthService {}
class MockUserProfileRepository extends Mock implements IUserProfileRepository {}

void main() {
  setUpAll(() {
    registerFallbackValue(UserProfile.empty());
  });

  group('UserProfileBloc Unit Tests', () {
    late MockAuthService mockAuthService;
    late MockUserProfileRepository mockProfileRepository;
    late UserProfileBloc profileBloc;

    const mockProfile = UserProfile(
      name: 'John Doe',
      email: 'john@example.com',
      phone: '+919876543210',
      address: '123 Main Street',
      homeAddress: '123 Main Street, Home',
      workAddress: '456 Tech Park, Work',
      otherAddress: '',
      selectedAddressType: 'Home',
    );

    setUp(() {
      mockAuthService = MockAuthService();
      mockProfileRepository = MockUserProfileRepository();

      when(() => mockAuthService.currentUserId).thenReturn('test_user_123');
      when(() => mockAuthService.currentUserDisplayName).thenReturn('John Doe');
      when(() => mockAuthService.currentUserEmail).thenReturn('john@example.com');
      when(() => mockAuthService.currentUserPhotoUrl).thenReturn(null);

      when(() => mockProfileRepository.watchProfile('test_user_123'))
          .thenAnswer((_) => Stream.value(mockProfile));

      profileBloc = UserProfileBloc(
        authService: mockAuthService,
        profileRepository: mockProfileRepository,
      );
    });

    tearDown(() {
      profileBloc.close();
    });

    test('initial state is ProfileInitial', () {
      expect(profileBloc.state, isA<ProfileInitial>());
    });

    test('LoadProfileStarted emits ProfileLoading and streams ProfileLoaded', () async {
      profileBloc.add(const LoadProfileStarted());

      await expectLater(
        profileBloc.stream,
        emitsInOrder([
          isA<ProfileLoading>(),
          isA<ProfileLoaded>().having(
            (s) => s.profile.name,
            'name',
            'John Doe',
          ),
        ]),
      );

      verify(() => mockProfileRepository.watchProfile('test_user_123')).called(1);
    });

    test('LoadProfileStarted emits ProfileError when unauthenticated', () async {
      when(() => mockAuthService.currentUserId).thenReturn(null);

      profileBloc.add(const LoadProfileStarted());

      await expectLater(
        profileBloc.stream,
        emitsInOrder([
          isA<ProfileLoading>(),
          isA<ProfileError>().having(
            (s) => s.message,
            'message',
            'User not logged in',
          ),
        ]),
      );
    });

    test('ProfileSaved updates repository and emits ProfileLoaded with success message', () async {
      when(() => mockProfileRepository.saveProfile(any(), any()))
          .thenAnswer((_) async {});

      profileBloc.add(const LoadProfileStarted());
      await profileBloc.stream.firstWhere((s) => s is ProfileLoaded);

      const updatedProfile = UserProfile(
        name: 'Johnathan Doe',
        email: 'john@example.com',
        phone: '+919876543210',
        address: '999 New Avenue',
      );

      final saveExpectation = expectLater(
        profileBloc.stream,
        emitsInOrder([
          isA<ProfileLoaded>().having((s) => s.isSaving, 'isSaving', true),
          isA<ProfileLoaded>().having((s) => s.successMessage, 'successMessage', 'Profile saved successfully!'),
        ]),
      );

      profileBloc.add(const ProfileSaved(updatedProfile));
      await saveExpectation;

      verify(() => mockProfileRepository.saveProfile('test_user_123', updatedProfile)).called(1);
    });

    test('ProfileImageUploadProgress updates uploadProgress state', () async {
      profileBloc.add(const LoadProfileStarted());
      await profileBloc.stream.firstWhere((s) => s is ProfileLoaded);

      final progressExpectation = expectLater(
        profileBloc.stream,
        emits(isA<ProfileLoaded>().having((s) => s.uploadProgress, 'uploadProgress', 0.75)),
      );

      profileBloc.add(const ProfileImageUploadProgress(0.75));
      await progressExpectation;
    });

    test('SignOutRequested triggers auth sign out and emits SignOutSuccess', () async {
      when(() => mockAuthService.signOut()).thenAnswer((_) async {});

      final signoutExpectation = expectLater(
        profileBloc.stream,
        emits(isA<SignOutSuccess>()),
      );

      profileBloc.add(const SignOutRequested());
      await signoutExpectation;

      verify(() => mockAuthService.signOut()).called(1);
    });
  });
}
