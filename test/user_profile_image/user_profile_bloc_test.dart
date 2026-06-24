// test/user_profile_image/user_profile_bloc_test.dart

import 'package:bloc_test/bloc_test.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:food_delivery_app/features/buyer_bloc_architecture/user_profile_image/user_profile_image.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mocktail/mocktail.dart';

class MockFirebaseAuth extends Mock implements FirebaseAuth {}

class MockUser extends Mock implements User {}

class MockFirebaseStorage extends Mock implements FirebaseStorage {}

class MockImagePicker extends Mock implements ImagePicker {}

void main() {
  setUpAll(() {
    TestWidgetsFlutterBinding.ensureInitialized();
  });

  late MockFirebaseAuth mockAuth;
  late FakeFirebaseFirestore fakeFirestore;
  late MockFirebaseStorage mockStorage;
  late MockImagePicker mockImagePicker;
  late MockUser mockUser;

  setUp(() {
    mockAuth = MockFirebaseAuth();
    fakeFirestore = FakeFirebaseFirestore();
    mockStorage = MockFirebaseStorage();
    mockImagePicker = MockImagePicker();
    mockUser = MockUser();

    when(() => mockUser.uid).thenReturn('test_user_id');
    when(() => mockUser.email).thenReturn('test@example.com');
  });

  group('UserProfileBloc', () {
    test('initial state is ProfileInitial', () {
      final bloc = UserProfileBloc(
        auth: mockAuth,
        firestore: fakeFirestore,
        storage: mockStorage,
        imagePicker: mockImagePicker,
      );
      expect(bloc.state, const ProfileInitial());
      bloc.close();
    });

    blocTest<UserProfileBloc, UserProfileState>(
      'emits [ProfileLoading, ProfileError] when user is not logged in on load',
      setUp: () {
        when(() => mockAuth.currentUser).thenReturn(null);
      },
      build: () => UserProfileBloc(
        auth: mockAuth,
        firestore: fakeFirestore,
        storage: mockStorage,
        imagePicker: mockImagePicker,
      ),
      act: (bloc) => bloc.add(const LoadProfileStarted()),
      expect: () => [
        const ProfileLoading(),
        const ProfileError(
          'User not logged in',
          previousState: ProfileInitial(),
        ),
      ],
    );

    blocTest<UserProfileBloc, UserProfileState>(
      'emits [ProfileLoading, ProfileLoaded] with default data if doc does not exist',
      setUp: () {
        when(() => mockAuth.currentUser).thenReturn(mockUser);
      },
      build: () => UserProfileBloc(
        auth: mockAuth,
        firestore: fakeFirestore,
        storage: mockStorage,
        imagePicker: mockImagePicker,
      ),
      act: (bloc) => bloc.add(const LoadProfileStarted()),
      expect: () => [
        const ProfileLoading(),
        isA<ProfileLoaded>().having(
          (s) => s.profile.email,
          'email',
          'test@example.com',
        ),
      ],
    );

    blocTest<UserProfileBloc, UserProfileState>(
      'emits [ProfileLoading, ProfileLoaded] with data if doc exists',
      setUp: () async {
        when(() => mockAuth.currentUser).thenReturn(mockUser);
        await fakeFirestore.collection('users').doc('test_user_id').set({
          'name': 'John Doe',
          'email': 'john@example.com',
          'phone': '1234567890',
          'address': '123 Street',
          'imageUrl': 'http://image.com/img.jpg',
        });
      },
      build: () => UserProfileBloc(
        auth: mockAuth,
        firestore: fakeFirestore,
        storage: mockStorage,
        imagePicker: mockImagePicker,
      ),
      act: (bloc) => bloc.add(const LoadProfileStarted()),
      expect: () => [
        const ProfileLoading(),
        isA<ProfileLoaded>()
            .having((s) => s.profile.name, 'name', 'John Doe')
            .having(
              (s) => s.profile.imageUrl,
              'imageUrl',
              'http://image.com/img.jpg',
            ),
      ],
    );

    blocTest<UserProfileBloc, UserProfileState>(
      'saves profile data successfully',
      setUp: () {
        when(() => mockAuth.currentUser).thenReturn(mockUser);
      },
      build: () => UserProfileBloc(
        auth: mockAuth,
        firestore: fakeFirestore,
        storage: mockStorage,
        imagePicker: mockImagePicker,
      ),
      seed: () => const ProfileLoaded(
        profile: UserProfile(name: '', email: '', phone: '', address: ''),
      ),
      act: (bloc) => bloc.add(
        const ProfileSaved(
          UserProfile(
            name: 'New Name',
            email: 'new@example.com',
            phone: '',
            address: '',
          ),
        ),
      ),
      expect: () => [
        isA<ProfileLoaded>().having((s) => s.isSaving, 'isSaving', true),
        isA<ProfileSuccessAction>(),
        isA<ProfileLoaded>()
            .having((s) => s.isSaving, 'isSaving', false)
            .having((s) => s.profile.name, 'name', 'New Name'),
      ],
      verify: (_) async {
        final doc = await fakeFirestore
            .collection('users')
            .doc('test_user_id')
            .get();
        expect(doc.data()!['name'], 'New Name');
      },
    );
  });
}
