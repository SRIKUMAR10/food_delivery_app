// ignore_for_file: lines_longer_than_80_chars

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:food_delivery_app/features/seller_bloc_architecture/seller_login_page/seller_login_page_bloc.dart';
import 'package:food_delivery_app/features/seller_bloc_architecture/seller_login_page/seller_login_page_event.dart';
import 'package:food_delivery_app/features/seller_bloc_architecture/seller_login_page/seller_login_page_state.dart';
import 'package:food_delivery_app/repositories/seller_repository.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Mocks
// ─────────────────────────────────────────────────────────────────────────────
class MockSellerRepository extends Mock implements SellerRepository {}

class MockUserCredential extends Mock implements UserCredential {}

// Helper: builds the widget under test wrapped in MaterialApp + BlocProvider
Widget buildTestWidget(
  SellerLoginPageBloc bloc, {
  Map<String, WidgetBuilder>? extraRoutes,
}) {
  return MaterialApp(
    routes: {
      '/sellerDashboard': (_) => const Scaffold(body: Text('Dashboard')),
      '/sellerSignUp': (_) => const Scaffold(body: Text('Sign Up')),
      ...?extraRoutes,
    },
    home: BlocProvider<SellerLoginPageBloc>.value(
      value: bloc,
      child: const _SellerLoginTestShell(),
    ),
  );
}

/// Thin shell that mirrors what SellerLoginPageUI renders (without creating a
/// new BLoC) so we can inject a mock BLoC.
class _SellerLoginTestShell extends StatelessWidget {
  const _SellerLoginTestShell();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocBuilder<SellerLoginPageBloc, SellerLoginPageState>(
        builder: (context, state) {
          // Only renders the login form for widget tests
          return Column(
            children: [
              TextField(
                key: const Key('emailField'),
                onChanged: (v) => context.read<SellerLoginPageBloc>().add(
                  SellerLoginFieldChanged(v),
                ),
                decoration: const InputDecoration(hintText: 'Email / Phone'),
              ),
              TextField(
                key: const Key('passwordField'),
                obscureText: state.isPasswordObscured,
                onChanged: (v) => context.read<SellerLoginPageBloc>().add(
                  SellerLoginPasswordChanged(v),
                ),
                decoration: const InputDecoration(hintText: 'Password'),
              ),
              if (state.status == SellerLoginStatus.loading)
                const CircularProgressIndicator(key: Key('loadingIndicator')),
              ElevatedButton(
                key: const Key('loginButton'),
                onPressed: () => context.read<SellerLoginPageBloc>().add(
                  const SellerLoginSubmitted(),
                ),
                child: const Text('Login'),
              ),
              TextButton(
                key: const Key('forgotPasswordButton'),
                onPressed: () => context.read<SellerLoginPageBloc>().add(
                  const SellerLoginForgotPasswordNavigated(),
                ),
                child: const Text('Forgot Password?'),
              ),
              if (state.errorMessage != null)
                Text(state.errorMessage!, key: const Key('errorText')),
              if (state.step == SellerLoginStep.forgotPassword)
                const Text(
                  'Forgot Password Screen',
                  key: Key('forgotPasswordScreen'),
                ),
              if (state.step == SellerLoginStep.loginSuccess)
                const Text('Login Successful', key: Key('loginSuccessScreen')),
            ],
          );
        },
      ),
    );
  }
}

void main() {
  late MockSellerRepository mockRepo;
  late SellerLoginPageBloc bloc;

  setUp(() {
    mockRepo = MockSellerRepository();
    bloc = SellerLoginPageBloc(authRepository: mockRepo);
  });

  tearDown(() {
    bloc.close();
  });

  // ──────────────────────────────────────────────────────────────────────────
  // Group 1 – Renders correctly
  // ──────────────────────────────────────────────────────────────────────────
  group('SellerLoginPageUI – Render', () {
    testWidgets('renders email and password fields', (tester) async {
      await tester.pumpWidget(buildTestWidget(bloc));
      expect(find.byKey(const Key('emailField')), findsOneWidget);
      expect(find.byKey(const Key('passwordField')), findsOneWidget);
      expect(find.byKey(const Key('loginButton')), findsOneWidget);
    });

    testWidgets('renders forgot password button', (tester) async {
      await tester.pumpWidget(buildTestWidget(bloc));
      expect(find.byKey(const Key('forgotPasswordButton')), findsOneWidget);
    });

    testWidgets('does not show loading indicator initially', (tester) async {
      await tester.pumpWidget(buildTestWidget(bloc));
      expect(find.byKey(const Key('loadingIndicator')), findsNothing);
    });
  });

  // ──────────────────────────────────────────────────────────────────────────
  // Group 2 – User Input Interactions
  // ──────────────────────────────────────────────────────────────────────────
  group('SellerLoginPageUI – User Input', () {
    testWidgets('entering email dispatches SellerLoginFieldChanged', (
      tester,
    ) async {
      await tester.pumpWidget(buildTestWidget(bloc));
      await tester.enterText(
        find.byKey(const Key('emailField')),
        'test@test.com',
      );
      await tester.pump();
      expect(bloc.state.emailOrPhone, 'test@test.com');
    });

    testWidgets('entering password dispatches SellerLoginPasswordChanged', (
      tester,
    ) async {
      await tester.pumpWidget(buildTestWidget(bloc));
      await tester.enterText(find.byKey(const Key('passwordField')), 'pass123');
      await tester.pump();
      expect(bloc.state.password, 'pass123');
    });

    testWidgets('tapping login with empty fields shows no loading indicator', (
      tester,
    ) async {
      await tester.pumpWidget(buildTestWidget(bloc));
      await tester.tap(find.byKey(const Key('loginButton')));
      await tester.pump();
      expect(find.byKey(const Key('loadingIndicator')), findsNothing);
    });

    testWidgets('tapping login with valid credentials shows loading', (
      tester,
    ) async {
      when(() => mockRepo.signIn(any(), any())).thenAnswer((_) async {
        await Future.delayed(const Duration(milliseconds: 300));
        return MockUserCredential();
      });

      await tester.pumpWidget(buildTestWidget(bloc));
      await tester.enterText(find.byKey(const Key('emailField')), 'a@b.com');
      await tester.enterText(
        find.byKey(const Key('passwordField')),
        'passw0rd',
      );
      await tester.tap(find.byKey(const Key('loginButton')));
      await tester.pump(); // loading state
      expect(find.byKey(const Key('loadingIndicator')), findsOneWidget);
      await tester.pumpAndSettle();
    });
  });

  // ──────────────────────────────────────────────────────────────────────────
  // Group 3 – Error Display
  // ──────────────────────────────────────────────────────────────────────────
  group('SellerLoginPageUI – Error Display', () {
    testWidgets('shows error text when login fails', (tester) async {
      when(
        () => mockRepo.signIn(any(), any()),
      ).thenThrow(Exception('Login failed'));

      await tester.pumpWidget(buildTestWidget(bloc));
      await tester.enterText(find.byKey(const Key('emailField')), 'a@b.com');
      await tester.enterText(find.byKey(const Key('passwordField')), 'wrong');
      await tester.tap(find.byKey(const Key('loginButton')));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('errorText')), findsOneWidget);
    });

    testWidgets('shows error when email and password are empty', (
      tester,
    ) async {
      await tester.pumpWidget(buildTestWidget(bloc));
      await tester.tap(find.byKey(const Key('loginButton')));
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('errorText')), findsOneWidget);
    });
  });

  // ──────────────────────────────────────────────────────────────────────────
  // Group 4 – Navigation
  // ──────────────────────────────────────────────────────────────────────────
  group('SellerLoginPageUI – Navigation', () {
    testWidgets('tapping Forgot Password changes step to forgotPassword', (
      tester,
    ) async {
      await tester.pumpWidget(buildTestWidget(bloc));
      await tester.tap(find.byKey(const Key('forgotPasswordButton')));
      await tester.pump();
      expect(find.byKey(const Key('forgotPasswordScreen')), findsOneWidget);
    });

    testWidgets('successful login shows loginSuccess screen', (tester) async {
      when(
        () => mockRepo.signIn(any(), any()),
      ).thenAnswer((_) async => MockUserCredential());

      await tester.pumpWidget(buildTestWidget(bloc));
      await tester.enterText(
        find.byKey(const Key('emailField')),
        'seller@test.com',
      );
      await tester.enterText(
        find.byKey(const Key('passwordField')),
        'SecurePass1!',
      );
      await tester.tap(find.byKey(const Key('loginButton')));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('loginSuccessScreen')), findsOneWidget);
    });
  });

  // ──────────────────────────────────────────────────────────────────────────
  // Group 5 – State-driven UI
  // ──────────────────────────────────────────────────────────────────────────
  group('SellerLoginPageUI – State-Driven Rendering', () {
    testWidgets('loading state shows CircularProgressIndicator', (
      tester,
    ) async {
      await tester.pumpWidget(buildTestWidget(bloc));
      bloc.emit(const SellerLoginPageState(status: SellerLoginStatus.loading));
      await tester.pump();
      expect(find.byKey(const Key('loadingIndicator')), findsOneWidget);
    });

    testWidgets('failure state with error shows errorText widget', (
      tester,
    ) async {
      await tester.pumpWidget(buildTestWidget(bloc));
      bloc.emit(
        const SellerLoginPageState(
          status: SellerLoginStatus.failure,
          errorMessage: 'Test error message',
        ),
      );
      await tester.pump();
      expect(find.byKey(const Key('errorText')), findsOneWidget);
      expect(find.text('Test error message'), findsOneWidget);
    });
  });
}
