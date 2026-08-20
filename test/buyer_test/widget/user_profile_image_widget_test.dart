import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:food_delivery_app/core/services/i_auth_service.dart';
import 'package:food_delivery_app/core/repositories/i_user_profile_repository.dart';
import 'package:food_delivery_app/features/buyer_bloc_architecture/user_profile_image/user_profile_image_Bloc.dart';
import 'package:food_delivery_app/features/buyer_bloc_architecture/user_profile_image/user_profile_models.dart';
import 'package:food_delivery_app/features/buyer_bloc_architecture/user_profile_image/pages/personal_information_page.dart';

class MockAuthService extends Mock implements IAuthService {}
class MockUserProfileRepository extends Mock implements IUserProfileRepository {}

void main() {
  setUpAll(() {
    registerFallbackValue(UserProfile.empty());
  });

  group('PersonalInformationPage Widget Tests', () {
    late MockAuthService mockAuthService;
    late MockUserProfileRepository mockProfileRepository;
    late UserProfileBloc profileBloc;

    const testProfile = UserProfile(
      name: 'Anu',
      email: 'Anu@gmail.com',
      phone: '9876543210',
      address: 'Bhavani, Erode, Tamil Nadu, 638300, India',
      homeAddress: 'Bhavani, Erode, Tamil Nadu, 638300, India',
      workAddress: '',
      otherAddress: '',
      selectedAddressType: 'Home',
    );

    setUp(() {
      mockAuthService = MockAuthService();
      mockProfileRepository = MockUserProfileRepository();

      when(() => mockAuthService.currentUserId).thenReturn('JQxQueOUOLcwwg56XpC9UbtOfs73');
      when(() => mockAuthService.currentUserDisplayName).thenReturn('Anu');
      when(() => mockAuthService.currentUserEmail).thenReturn('Anu@gmail.com');
      when(() => mockAuthService.currentUserPhotoUrl).thenReturn(null);

      when(() => mockProfileRepository.watchProfile('JQxQueOUOLcwwg56XpC9UbtOfs73'))
          .thenAnswer((_) => Stream.value(testProfile));
      when(() => mockProfileRepository.saveProfile(any(), any()))
          .thenAnswer((_) async {});

      profileBloc = UserProfileBloc(
        authService: mockAuthService,
        profileRepository: mockProfileRepository,
      );
    });

    tearDown(() {
      profileBloc.close();
    });

    Widget createTestWidget() {
      return MaterialApp(
        home: BlocProvider<UserProfileBloc>.value(
          value: profileBloc,
          child: const PersonalInformationPage(),
        ),
      );
    }

    testWidgets('Renders all personal information fields and populates from stream immediately', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(800, 1400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.runAsync(() async {
        profileBloc.add(const LoadProfileStarted());
        await profileBloc.stream.firstWhere((s) => s is ProfileLoaded);
      });

      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      expect(find.text('Personal Information'), findsWidgets);
      expect(find.byKey(const ValueKey('uidField')), findsOneWidget);
      expect(find.byKey(const ValueKey('fullNameField')), findsOneWidget);
      expect(find.byKey(const ValueKey('emailField')), findsOneWidget);
      expect(find.byKey(const ValueKey('phoneField')), findsOneWidget);
      expect(find.byKey(const ValueKey('savePersonalInformationButton')), findsOneWidget);

      final uidField = tester.widget<TextFormField>(find.byKey(const ValueKey('uidField')));
      expect(uidField.controller?.text, 'JQxQueOUOLcwwg56XpC9UbtOfs73');

      final nameField = tester.widget<TextFormField>(find.byKey(const ValueKey('fullNameField')));
      expect(nameField.controller?.text, 'Anu');

      final emailField = tester.widget<TextFormField>(find.byKey(const ValueKey('emailField')));
      expect(emailField.controller?.text, 'Anu@gmail.com');

      final phoneField = tester.widget<TextFormField>(find.byKey(const ValueKey('phoneField')));
      expect(phoneField.controller?.text, '9876543210');
    });

    testWidgets('Allows editing name and saving profile', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(800, 1400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.runAsync(() async {
        profileBloc.add(const LoadProfileStarted());
        await profileBloc.stream.firstWhere((s) => s is ProfileLoaded);
      });

      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      final nameFinder = find.byKey(const ValueKey('fullNameField'));
      await tester.enterText(nameFinder, 'Anu Developer');
      await tester.pumpAndSettle();

      final saveButton = find.byKey(const ValueKey('savePersonalInformationButton'));
      await tester.ensureVisible(saveButton);
      await tester.tap(saveButton);
      await tester.pumpAndSettle();

      verify(() => mockProfileRepository.saveProfile(
        'JQxQueOUOLcwwg56XpC9UbtOfs73',
        any(that: isA<UserProfile>().having((p) => p.name, 'name', 'Anu Developer')),
      )).called(1);
    });
  });
}
