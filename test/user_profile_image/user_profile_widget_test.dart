import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:food_delivery_app/features/buyer_bloc_architecture/user_profile_image/pages/address_management_page.dart';
import 'package:food_delivery_app/features/buyer_bloc_architecture/user_profile_image/pages/personal_information_page.dart';
import 'package:food_delivery_app/features/buyer_bloc_architecture/user_profile_image/user_profile_image.dart';
import 'package:mocktail/mocktail.dart';

class MockUserProfileBloc extends MockBloc<UserProfileEvent, UserProfileState>
    implements UserProfileBloc {}

Widget _buildApp(UserProfileBloc bloc) {
  return MaterialApp(
    home: BlocProvider<UserProfileBloc>.value(
      value: bloc,
      child: const UserProfileDrawer(),
    ),
  );
}

void main() {
  setUpAll(() {
    TestWidgetsFlutterBinding.ensureInitialized();
  });

  group('UserProfileDrawer Widget Tests', () {
    late MockUserProfileBloc mockBloc;

    setUp(() {
      mockBloc = MockUserProfileBloc();
    });

    testWidgets('shows loading indicator for upload progress', (tester) async {
      final profile = const UserProfile(
        name: 'John Doe',
        email: 'john@example.com',
        phone: '1234567890',
        address: '123 Main St',
      );

      when(
        () => mockBloc.state,
      ).thenReturn(ProfileLoaded(profile: profile, uploadProgress: 0.5));
      await tester.pumpWidget(_buildApp(mockBloc));

      // CircularProgressIndicator should be visible for progress > 0
      expect(find.byType(CircularProgressIndicator), findsWidgets);
    });

    testWidgets('verifies all menu items are visible', (tester) async {
      final profile = const UserProfile(
        name: 'John Doe',
        email: 'john@example.com',
        phone: '1234567890',
        address: '123 Main St',
      );

      when(() => mockBloc.state).thenReturn(ProfileLoaded(profile: profile));
      await tester.pumpWidget(_buildApp(mockBloc));

      // Scrollable view might require scrolling to find some items, but they are Text widgets
      // We'll use drag to ensure everything is visible
      expect(find.text('Personal Information'), findsOneWidget);
      expect(find.text('Addresses'), findsOneWidget);
      expect(find.text('My Orders'), findsOneWidget);
      expect(find.text('Notifications'), findsOneWidget);
      expect(find.text('View Transactions'), findsOneWidget);

      await tester.drag(
        find.byType(SingleChildScrollView),
        const Offset(0, -500),
      );
      await tester.pumpAndSettle();

      expect(find.text('Settings'), findsOneWidget);
      expect(find.text('Help & Support'), findsOneWidget);
      expect(find.text('Log Out'), findsOneWidget);
    });

    testWidgets('verifies navigation to Personal Information page', (
      tester,
    ) async {
      final profile = const UserProfile(
        name: 'John Doe',
        email: 'john@example.com',
        phone: '1234567890',
        address: '123 Main St',
      );

      when(() => mockBloc.state).thenReturn(ProfileLoaded(profile: profile));
      await tester.pumpWidget(_buildApp(mockBloc));

      await tester.tap(find.text('Personal Information'));
      await tester.pumpAndSettle();

      expect(find.byType(PersonalInformationPage), findsOneWidget);
    });

    testWidgets('verifies navigation to Address Management page', (
      tester,
    ) async {
      final profile = const UserProfile(
        name: 'John Doe',
        email: 'john@example.com',
        phone: '1234567890',
        address: '123 Main St',
      );

      when(() => mockBloc.state).thenReturn(ProfileLoaded(profile: profile));
      await tester.pumpWidget(_buildApp(mockBloc));

      await tester.tap(find.text('Addresses'));
      await tester.pumpAndSettle();

      expect(find.byType(AddressManagementPage), findsOneWidget);
    });

    testWidgets(
      'shows logout dialog and dispatches SignOutRequested on confirm',
      (tester) async {
        final profile = const UserProfile(
          name: 'John Doe',
          email: 'john@example.com',
          phone: '1234567890',
          address: '123 Main St',
        );

        when(() => mockBloc.state).thenReturn(ProfileLoaded(profile: profile));
        await tester.pumpWidget(_buildApp(mockBloc));

        // Scroll down to Logout button
        await tester.drag(
          find.byType(SingleChildScrollView),
          const Offset(0, -1000),
        );
        await tester.pumpAndSettle();

        // Tap Logout
        await tester.tap(find.text('Log Out'));
        await tester.pumpAndSettle();

        // Verify Dialog appears
        expect(find.text('Are you sure you want to log out?'), findsOneWidget);

        // Tap Confirm
        await tester.tap(find.text('Logout').last);
        await tester.pumpAndSettle();

        verify(() => mockBloc.add(const SignOutRequested())).called(1);
      },
    );
  });
}
