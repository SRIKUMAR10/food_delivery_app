// test/user_profile_image/user_profile_integration_test.dart
//
// Integration tests for User Profile component.

import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';

import '../../lib/Buyer Bloc Architecture/user_profile_image/user_profile_image.dart';

class MockFirebaseAuth extends Mock implements FirebaseAuth {}

class MockUser extends Mock implements User {}

class MockFirebaseStorage extends Mock implements FirebaseStorage {}

class MockImagePicker extends Mock implements ImagePicker {}

Widget _buildApp(
  MockFirebaseAuth mockAuth,
  FakeFirebaseFirestore fakeFirestore,
  MockFirebaseStorage mockStorage,
  MockImagePicker mockImagePicker,
) {
  return MaterialApp(
    home: Scaffold(
      body: BlocProvider<UserProfileBloc>(
        create: (_) => UserProfileBloc(
          auth: mockAuth,
          firestore: fakeFirestore,
          storage: mockStorage,
          imagePicker: mockImagePicker,
        ),
        child: const UserProfileDrawer(),
      ),
    ),
  );
}

void main() {
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

  testWidgets('integration: loading, editing, and saving profile', (
    tester,
  ) async {
    when(() => mockAuth.currentUser).thenReturn(mockUser);

    // Initial empty state in Firestore
    await tester.pumpWidget(
      _buildApp(mockAuth, fakeFirestore, mockStorage, mockImagePicker),
    );

    // Wait for the BLoC to fetch data (which is empty) and transition to Loaded
    await tester.pumpAndSettle();

    // Verify fields are present (at least some are rendered on screen)
    expect(find.byType(TextFormField), findsWidgets);

    // Type into the Name field
    await tester.enterText(
      find.byType(TextFormField).first,
      'John Doe Integration',
    );
    await tester.pump();

    // Tap Save Profile button
    await tester.tap(find.text('Save Profile'));
    await tester.pump(); // Start save
    await tester.pump(
      const Duration(seconds: 1),
    ); // Wait for mock firestore to complete

    // Check that Firestore was updated
    final doc = await fakeFirestore
        .collection('users')
        .doc('test_user_id')
        .get();
    expect(doc.data()?['name'], 'John Doe Integration');
  });
}
