import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:food_delivery_app/features/buyer_bloc_architecture/ForgotPasswordPage/ForgotPasswordPage_UI.dart';
import 'package:food_delivery_app/repositories/user_repository.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mocktail/mocktail.dart';

class MockUserRepository extends Mock implements UserRepository {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late MockUserRepository mockUserRepository;

  setUp(() {
    mockUserRepository = MockUserRepository();
  });

  Widget createWidgetUnderTest() {
    return RepositoryProvider<UserRepository>.value(
      value: mockUserRepository,
      child: const MaterialApp(home: ForgotPasswordScreenUI()),
    );
  }

  group('ForgotPasswordScreen Integration Tests', () {
    testWidgets('successful reset password flow', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      final emailField = find.byType(TextFormField).first;
      final submitButton = find.text('Submit');

      await tester.enterText(emailField, 'test@example.com');
      await tester.pumpAndSettle();

      await tester.ensureVisible(submitButton);
      await tester.tap(submitButton);

      // Pump frames until the mocked 2 second delay finishes and the navigation occurs
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // Upon success, it navigates to FoodGoLoginScreenUI, removing this screen
      expect(find.byType(ForgotPasswordScreenUI), findsNothing);
    });
  });
}
