import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:food_delivery_app/features/buyer_bloc_architecture/FoodGoLoginScreen/FoodGoLoginScreen_UI.dart';
import 'package:food_delivery_app/repositories/user_repository.dart';
import 'package:mocktail/mocktail.dart';

import 'package:firebase_auth/firebase_auth.dart';

class MockUserRepository extends Mock implements UserRepository {}

class MockUserCredential extends Mock implements UserCredential {}

void main() {
  late MockUserRepository mockUserRepository;

  setUp(() {
    mockUserRepository = MockUserRepository();
  });

  Widget createWidgetUnderTest() {
    return RepositoryProvider<UserRepository>.value(
      value: mockUserRepository,
      child: const MaterialApp(home: FoodGoLoginScreenUI()),
    );
  }

  group('FoodGoLoginScreenUI Widget Tests', () {
    testWidgets('renders mobile layout and required form fields', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(400, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(createWidgetUnderTest());

      expect(find.text('LogIn'), findsWidgets);
      expect(find.text('Email'), findsOneWidget);
      expect(find.text('Password'), findsOneWidget);
      expect(find.text('Forgot Password?'), findsOneWidget);
      expect(find.text('Log In'), findsOneWidget); // Button
      expect(find.text('SignUp'), findsOneWidget);
    });

    testWidgets('renders web layout and required form fields', (tester) async {
      tester.view.physicalSize = const Size(1200, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(createWidgetUnderTest());

      expect(find.text('LogIn'), findsWidgets);
      expect(find.text('Email'), findsOneWidget);
      expect(find.text('Password'), findsOneWidget);
    });

    testWidgets('shows loading indicator when login is submitted', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(400, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      // Delay to simulate network request
      when(() => mockUserRepository.signIn(any(), any())).thenAnswer((_) async {
        await Future.delayed(const Duration(seconds: 1));
        throw Exception('mock failure to prevent navigation');
      });

      await tester.pumpWidget(createWidgetUnderTest());

      // Enter valid text
      await tester.enterText(
        find.byType(TextFormField).first,
        'test@example.com',
      );
      await tester.enterText(find.byType(TextFormField).last, 'password123');
      await tester.pump();

      // Tap Login
      await tester.ensureVisible(find.text('Log In'));
      await tester.tap(find.text('Log In'));
      await tester.pump(); // Starts loading

      // Verify loading indicator
      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      await tester.pumpAndSettle(); // Finish loading
    });
  });
}
