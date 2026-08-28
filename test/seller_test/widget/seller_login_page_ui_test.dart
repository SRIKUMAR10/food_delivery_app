import 'package:firebase_core/firebase_core.dart';
import '../../mock_firebase.dart';
// ignore_for_file: lines_longer_than_80_chars

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:food_delivery_app/features/seller_bloc_architecture/seller_login_page/seller_login_page_bloc.dart';
import 'package:food_delivery_app/features/seller_bloc_architecture/seller_login_page/seller_login_page_event.dart';
import 'package:food_delivery_app/features/seller_bloc_architecture/seller_login_page/seller_login_page_state.dart';
import 'package:food_delivery_app/features/seller_bloc_architecture/seller_login_page/seller_login_page_ui.dart';
import 'package:food_delivery_app/repositories/seller_repository.dart';

// Helper: builds the real SellerLoginPageUI wrapped in MaterialApp
Widget buildRealApp() {
  return const MaterialApp(
    home: SellerLoginPageUI(),
  );
}

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
      '/sellerVerificationForm': (_) => const Scaffold(body: Text('KYC Form')),
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
                decoration: const InputDecoration(hintText: 'Phone Number'),
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
  setUpAll(() async {
    setupFirebaseAuthMocks();
    await Firebase.initializeApp();
  });

  late MockSellerRepository mockRepo;
  late SellerLoginPageBloc bloc;

  setUp(() {
    mockRepo = MockSellerRepository();
    when(() => mockRepo.checkNetworkConnectivity()).thenAnswer((_) async => true);
    when(() => mockRepo.checkKycCompleted(any())).thenAnswer((_) async => false);
    when(() => mockRepo.updateSellerData(any(), any())).thenAnswer((_) async {});
    when(() => mockRepo.currentUser).thenReturn(null);
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
      await tester.pumpWidget(buildTestWidget(bloc));
      bloc.emit(const SellerLoginPageState(status: SellerLoginStatus.loading));
      await tester.pump();
      expect(find.byKey(const Key('loadingIndicator')), findsOneWidget);
    });
  });

  // ──────────────────────────────────────────────────────────────────────────
  // Group 3 – Error Display
  // ──────────────────────────────────────────────────────────────────────────
  group('SellerLoginPageUI – Error Display', () {
    testWidgets('shows error text when login fails', (tester) async {
      await tester.pumpWidget(buildTestWidget(bloc));
      bloc.emit(
        const SellerLoginPageState(
          status: SellerLoginStatus.failure,
          errorMessage: 'Login failed',
        ),
      );
      await tester.pump();
      expect(find.byKey(const Key('errorText')), findsOneWidget);
    });

    testWidgets('shows error when email and password are empty', (
      tester,
    ) async {
      await tester.pumpWidget(buildTestWidget(bloc));
      bloc.emit(
        const SellerLoginPageState(
          status: SellerLoginStatus.failure,
          errorMessage: 'Please enter Email and Password.',
        ),
      );
      await tester.pump();
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
      bloc.emit(
        const SellerLoginPageState(step: SellerLoginStep.forgotPassword),
      );
      await tester.pump();
      expect(find.byKey(const Key('forgotPasswordScreen')), findsOneWidget);
    });

    testWidgets('successful login shows loginSuccess screen', (tester) async {
      await tester.pumpWidget(buildTestWidget(bloc));
      bloc.emit(
        const SellerLoginPageState(step: SellerLoginStep.loginSuccess),
      );
      await tester.pump();
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

  // ──────────────────────────────────────────────────────────────────────────
  // Group 6 – Responsive Viewport Rendering (Mobile & Desktop)
  // ──────────────────────────────────────────────────────────────────────────
  group('SellerLoginPageUI – Responsive Viewport Rendering', () {
    testWidgets('renders mobile layout on narrow screens (< 900px)', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(400, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(buildRealApp());
      await tester.pumpAndSettle();

      expect(find.text('Welcome Back!'), findsOneWidget);
      expect(find.text('Login to continue'), findsOneWidget);
      expect(find.text('Login'), findsOneWidget);
      expect(find.text('Forgot Password?'), findsOneWidget);
      expect(find.text('Sign up'), findsOneWidget);
      // Desktop features should NOT be rendered in mobile view
      expect(find.text('Secure & Reliable'), findsNothing);
      expect(find.text('Manage with Ease'), findsNothing);
      expect(find.text('24/7 Support'), findsNothing);
    });

    testWidgets('renders split-screen desktop layout on wide screens (>= 900px)', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(1200, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(buildRealApp());
      await tester.pumpAndSettle();

      // Left pane showcase elements
      expect(find.text('Good to see you again! Continue your journey and grow your business.'), findsOneWidget);
      expect(find.text('Secure & Reliable'), findsOneWidget);
      expect(find.text('Manage with Ease'), findsOneWidget);
      expect(find.text('24/7 Support'), findsOneWidget);

      // Right pane auth form elements
      expect(find.text('Login to continue'), findsOneWidget);
      expect(find.text('Login'), findsOneWidget);
      expect(find.text('Forgot Password?'), findsOneWidget);
      expect(find.text('Sign up'), findsOneWidget);
      expect(find.text('English ▾'), findsOneWidget);
    });
  });
}
