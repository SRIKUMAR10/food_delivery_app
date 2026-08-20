import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:food_delivery_app/core/services/i_auth_service.dart';
import 'package:food_delivery_app/core/repositories/i_user_profile_repository.dart';
import 'package:food_delivery_app/features/buyer_bloc_architecture/user_profile_image/user_profile_image_Bloc.dart';
import 'package:food_delivery_app/features/buyer_bloc_architecture/user_profile_image/user_profile_models.dart';
import 'package:food_delivery_app/features/buyer_bloc_architecture/user_profile_image/pages/address_management_page.dart';
import 'package:food_delivery_app/features/buyer_bloc_architecture/user_profile_image/pages/google_address_search_dialog.dart';

class MockAuthService extends Mock implements IAuthService {}
class MockUserProfileRepository extends Mock implements IUserProfileRepository {}

void main() {
  setUpAll(() {
    registerFallbackValue(UserProfile.empty());
  });

  group('AddressManagementPage & Google Address Search Widget Tests', () {
    late MockAuthService mockAuthService;
    late MockUserProfileRepository mockProfileRepository;
    late UserProfileBloc profileBloc;

    const testProfile = UserProfile(
      name: 'Test Buyer',
      email: 'buyer@example.com',
      phone: '+919876543210',
      address: '123 Main Street, Chennai',
      homeAddress: '123 Main Street, Chennai',
      workAddress: '456 IT Expressway, OMR, Chennai',
      otherAddress: '',
      selectedAddressType: 'Home',
    );

    setUp(() {
      mockAuthService = MockAuthService();
      mockProfileRepository = MockUserProfileRepository();

      when(() => mockAuthService.currentUserId).thenReturn('user_123');
      when(() => mockAuthService.currentUserDisplayName).thenReturn('Test Buyer');
      when(() => mockAuthService.currentUserEmail).thenReturn('buyer@example.com');
      when(() => mockAuthService.currentUserPhotoUrl).thenReturn(null);

      when(() => mockProfileRepository.watchProfile('user_123'))
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
          child: const AddressManagementPage(),
        ),
      );
    }

    testWidgets('Renders all address options and Save button', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(800, 1400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.runAsync(() async {
        profileBloc.add(const LoadProfileStarted());
        await profileBloc.stream.firstWhere((s) => s is ProfileLoaded);
      });

      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      expect(find.text('My Addresses'), findsAtLeastNWidgets(1));
      expect(find.text('Home'), findsOneWidget);
      expect(find.text('Work'), findsOneWidget);
      expect(find.text('Other'), findsOneWidget);
      expect(find.text('123 Main Street, Chennai'), findsOneWidget);
      expect(find.text('456 IT Expressway, OMR, Chennai'), findsOneWidget);
      expect(find.byKey(const ValueKey('saveAddressChangesButton')), findsOneWidget);
    });

    testWidgets('Tapping address card selects that address type', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(800, 1400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.runAsync(() async {
        profileBloc.add(const LoadProfileStarted());
        await profileBloc.stream.firstWhere((s) => s is ProfileLoaded);
      });

      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Tap on Work address card
      await tester.tap(find.byKey(const ValueKey('addressTile_Work')));
      await tester.pumpAndSettle();

      final Radio<String> workRadio = tester.widget(
        find.byKey(const ValueKey('addressRadio_Work')),
      );
      expect(workRadio.groupValue, 'Work');
    });

    testWidgets('Tapping edit icon opens GoogleAddressSearchDialog', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(800, 1400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.runAsync(() async {
        profileBloc.add(const LoadProfileStarted());
        await profileBloc.stream.firstWhere((s) => s is ProfileLoaded);
      });

      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Tap edit button for Home address
      await tester.tap(find.byKey(const ValueKey('editAddressButton_Home')));
      await tester.pumpAndSettle();

      expect(find.byType(GoogleAddressSearchDialog), findsOneWidget);
      expect(find.text('Set Home Address'), findsOneWidget);
      expect(find.byKey(const ValueKey('addressSearchInputField')), findsOneWidget);
      expect(find.byKey(const ValueKey('useCurrentLocationButton')), findsOneWidget);
      expect(find.byKey(const ValueKey('confirmAddressSelectionButton')), findsOneWidget);
    });

    testWidgets('Selecting popular location chip and saving updates address', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(800, 1400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.runAsync(() async {
        profileBloc.add(const LoadProfileStarted());
        await profileBloc.stream.firstWhere((s) => s is ProfileLoaded);
      });

      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Open Google Address search dialog for 'Other' (which starts empty)
      await tester.tap(find.byKey(const ValueKey('editAddressButton_Other')));
      await tester.pumpAndSettle();

      // Pick first popular location chip (Anna Nagar)
      expect(find.byKey(const ValueKey('popularLocationItem_0')), findsOneWidget);
      await tester.tap(find.byKey(const ValueKey('popularLocationItem_0')));
      await tester.pumpAndSettle();

      // Verify selected Google location card appears
      expect(find.text('Selected Google Location'), findsOneWidget);

      // Add door / flat number
      await tester.enterText(find.byKey(const ValueKey('doorFlatInputField')), 'Flat 101, Lotus Apts');
      await tester.pumpAndSettle();

      // Confirm & Save this address in dialog
      await tester.tap(find.byKey(const ValueKey('confirmAddressSelectionButton')));
      await tester.pumpAndSettle();

      // Dialog is closed and updated address is reflected in the page
      expect(find.byType(GoogleAddressSearchDialog), findsNothing);
      expect(find.textContaining('Flat 101, Lotus Apts'), findsOneWidget);
      expect(find.textContaining('Anna Nagar'), findsOneWidget);

      // Save changes to BLoC
      await tester.tap(find.byKey(const ValueKey('saveAddressChangesButton')));
      await tester.pumpAndSettle();

      verify(() => mockProfileRepository.saveProfile('user_123', any())).called(1);
    });
  });
}
