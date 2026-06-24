import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:food_delivery_app/features/buyer_bloc_architecture/FoodGoLoginScreen/FoodGoLoginScreen_UI.dart';
import 'package:food_delivery_app/repositories/user_repository.dart';
import 'package:mocktail/mocktail.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class MockUserRepository extends Mock implements UserRepository {}

void main() {
  setUpAll(() {
    TestWidgetsFlutterBinding.ensureInitialized();
  });

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

  group('FoodGoLoginScreen Integration Tests', () {
    testWidgets('failed login shows snackbar with error message', (
      tester,
    ) async {
      when(
        () => mockUserRepository.signIn('fail@example.com', 'wrongpass'),
      ).thenThrow(Exception('Invalid credentials'));

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      final emailField = find.byType(TextFormField).first;
      final passwordField = find.byType(TextFormField).last;
      final loginButton = find.text('Log In');

      await tester.enterText(emailField, 'fail@example.com');
      await tester.enterText(passwordField, 'wrongpass');
      await tester.pumpAndSettle();

      await tester.ensureVisible(loginButton);
      await tester.tap(loginButton);
      await tester.pumpAndSettle();

      expect(find.byType(SnackBar), findsOneWidget);
      expect(find.text('Exception: Invalid credentials'), findsOneWidget);
    });
  });
}
