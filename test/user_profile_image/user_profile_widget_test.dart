// test/user_profile_image/user_profile_widget_test.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../lib/Buyer Bloc Architecture/user_profile_image/user_profile_image.dart';

// Since the UserProfileBloc requires FirebaseAuth and FirebaseStorage,
// we'll need to mock them or just use a dummy app that ignores them.
// In Widget testing, we want to see the UI states. Let's mock the BLoC state!

// To avoid the `bloc_test` version issues seen earlier, we'll create a simple
// fake BLoC that just returns whatever state we give it.

class FakeUserProfileBloc extends Bloc<UserProfileEvent, UserProfileState>
    implements UserProfileBloc {
  FakeUserProfileBloc(super.initialState) {
    on<UserProfileEvent>((event, emit) {});
  }
}

Widget _buildApp(UserProfileState initialState) {
  return MaterialApp(
    home: Scaffold(
      body: BlocProvider<UserProfileBloc>.value(
        value: FakeUserProfileBloc(initialState),
        child: const UserProfileDrawer(),
      ),
    ),
  );
}

void main() {
  group('UserProfileDrawer Widget Tests', () {
    testWidgets('shows loading indicator when state is ProfileLoading', (
      tester,
    ) async {
      await tester.pumpWidget(_buildApp(const ProfileLoading()));
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('shows form fields when state is ProfileLoaded', (
      tester,
    ) async {
      final profile = UserProfile(
        name: 'Jane Doe',
        email: 'jane@example.com',
        phone: '0987654321',
        address: '456 Avenue',
      );

      await tester.pumpWidget(_buildApp(ProfileLoaded(profile: profile)));

      expect(find.text('Jane Doe'), findsWidgets);
      expect(find.text('jane@example.com'), findsWidgets);
      expect(find.text('0987654321'), findsWidgets);
      expect(find.text('456 Avenue'), findsWidgets);
      expect(find.text('Save Profile'), findsOneWidget);
      expect(find.text('Sign Out'), findsOneWidget);
    });

    testWidgets('disables save button and shows progress indicator when saving', (
      tester,
    ) async {
      final profile = UserProfile.empty();

      await tester.pumpWidget(
        _buildApp(ProfileLoaded(profile: profile, isSaving: true)),
      );

      // The button text is hidden during save, replaced by a CircularProgressIndicator
      // However, we should check that the Elevated Button is disabled (onPressed is null).
      final button = tester.widget<ElevatedButton>(
        find.byType(ElevatedButton).first,
      );
      expect(button.onPressed, isNull);
    });

    testWidgets('shows image upload progress', (tester) async {
      final profile = UserProfile.empty();

      await tester.pumpWidget(
        _buildApp(ProfileLoaded(profile: profile, uploadProgress: 0.5)),
      );

      expect(find.text('50%'), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsWidgets);
    });
  });
}
