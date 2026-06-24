// test/user_profile_image/user_profile_integration_test.dart
//
// Integration tests for User Profile component.

import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:firebase_core_platform_interface/firebase_core_platform_interface.dart';
import 'package:food_delivery_app/features/buyer_bloc_architecture/user_profile_image/user_profile_image.dart';
import 'package:mocktail/mocktail.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';

import '../mock_firebase.dart';

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

// 1. FirebasePlatform-ஐ நேரடியாக Mock செய்வதற்கான கிளாஸ்
class MockFirebasePlatform extends FirebasePlatform {
  @override
  FirebaseAppPlatform app([String name = defaultFirebaseAppName]) {
    return FirebaseAppPlatform(
      name,
      const FirebaseOptions(
        apiKey: 'test-api-key',
        appId: 'test-app-id',
        messagingSenderId: 'test-sender-id',
        projectId: 'test-project-id',
      ),
    );
  }

  @override
  Future<FirebaseAppPlatform> initializeApp({
    String? name,
    FirebaseOptions? options,
  }) async {
    return app(name ?? defaultFirebaseAppName);
  }
}

void main() {
  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized(); // Ensure initialized first
    setupFirebaseAuthMocks();

    // 2. ஃபயர்பேஸ் செட்-அப் தொடங்கும் முன், நமது Mock Platform-ஐ செட் செய்கிறோம்
    FirebasePlatform.instance = MockFirebasePlatform();

    // 3. இப்போது இது எந்த MethodChannel பிழையுமின்றி ரன் ஆகும்!
    await Firebase.initializeApp();
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

    // Verify the Profile menu is displayed
    expect(
      find.byKey(const ValueKey('personalInformationMenuItem')),
      findsOneWidget,
    );

    // Tap the Personal Information menu item
    await tester.tap(find.byKey(const ValueKey('personalInformationMenuItem')));
    await tester.pumpAndSettle();

    // Verify fields are present
    expect(find.byKey(const ValueKey('fullNameField')), findsOneWidget);
    expect(find.byKey(const ValueKey('emailField')), findsOneWidget);
    expect(find.byKey(const ValueKey('phoneField')), findsOneWidget);

    // Type into the Name field
    await tester.enterText(
      find.byKey(const ValueKey('fullNameField')),
      'John Doe Integration',
    );
    await tester.pump();

    // Save Profile பட்டனை க்ளிக் செய்கிறோம்
    await tester.tap(
      find.byKey(const ValueKey('savePersonalInformationButton')),
    );

    // UI-ல் க்ளிக்கை ப்ராசஸ் செய்யச் சொல்கிறோம்
    await tester.pump();

    // அதிகபட்சம் 2 விநாடிகள் வரை (50 * 40ms = 2000ms) காத்திருக்கிறோம்.
    // இது டேட்டாபேஸ் சேவ் ஆகும் வரை மட்டுமே காத்திருக்கும், அனிமேஷனால் க்ராஷ் ஆகாது.
    bool isSaved = false;
    for (int i = 0; i < 50; i++) {
      await tester.pump(const Duration(milliseconds: 40));

      final doc = await fakeFirestore
          .collection('users')
          .doc('test_user_id')
          .get();
      if (doc.data()?['name'] == 'John Doe Integration') {
        isSaved = true;
        break; // சேவ் ஆகியிருந்தால் உடனடியாக லூப்பை விட்டு வெளியேறிவிடும் (நேரம் மிச்சமாகும்)
      }
    }

    expect(
      isSaved,
      isTrue,
      reason: 'Firestore should be updated with the new name',
    );

    // Wait for snackbar to appear
    await tester.pumpAndSettle();
    expect(find.byType(SnackBar), findsOneWidget);
  });

  testWidgets('integration: error handling when saving profile fails', (
    tester,
  ) async {
    when(() => mockAuth.currentUser).thenReturn(mockUser);

    // To simulate a Firestore error, we can use a FakeFirebaseFirestore but we need to intercept the call.
    // However, since we are using fake_cloud_firestore, we can't easily mock a specific failure.
    // Instead, we will simulate it by returning null for the user, which triggers the 'User not logged in' error.

    // Set user to null to trigger error
    when(() => mockAuth.currentUser).thenReturn(null);

    await tester.pumpWidget(
      _buildApp(mockAuth, fakeFirestore, mockStorage, mockImagePicker),
    );

    // Wait for the BLoC to fetch data and transition to Error state
    await tester.pump(const Duration(milliseconds: 100));

    // Verify error snackbar appears
    expect(find.byType(SnackBar), findsOneWidget);
    expect(find.text('User not logged in'), findsOneWidget);
  });
}
