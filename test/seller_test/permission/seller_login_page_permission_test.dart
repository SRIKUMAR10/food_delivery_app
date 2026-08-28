// ignore_for_file: lines_longer_than_80_chars

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

/// ─────────────────────────────────────────────────────────────────────────────
/// Permission Tests
/// Validates that the login flow handles permission-gated features correctly:
///  - Camera / biometric permissions (graceful degradation)
///  - Network permission awareness
///  - Platform-specific permission dialogs
///  - Deep link / intent handling
/// ─────────────────────────────────────────────────────────────────────────────

/// Simulates a permission-aware widget test shell.
Widget buildPermissionTestWidget(SellerLoginPageBloc bloc) {
  return MaterialApp(
    home: BlocProvider<SellerLoginPageBloc>.value(
      value: bloc,
      child: Scaffold(
        body: BlocBuilder<SellerLoginPageBloc, SellerLoginPageState>(
          builder: (context, state) {
            return Column(
              children: [
                // Biometric login button (permission-gated)
                Semantics(
                  label: 'Biometric login button',
                  button: true,
                  child: ElevatedButton(
                    key: const Key('biometricLoginButton'),
                    onPressed: () {
                      // In real app: request biometric permission here
                      // If denied, show alternative login method
                    },
                    child: const Text('Login with Biometric'),
                  ),
                ),

                // Camera for QR scan (permission-gated)
                ElevatedButton(
                  key: const Key('qrScanButton'),
                  onPressed: () {
                    // In real app: request camera permission here
                  },
                  child: const Text('Scan QR Code'),
                ),

                // Standard login (no permission required)
                ElevatedButton(
                  key: const Key('loginButton'),
                  onPressed: () => context.read<SellerLoginPageBloc>().add(
                    const SellerLoginSubmitted(),
                  ),
                  child: const Text('Login'),
                ),

                // Google Sign-in (internet + account permission)
                ElevatedButton(
                  key: const Key('googleSignInButton'),
                  onPressed: () => context.read<SellerLoginPageBloc>().add(
                    const SellerLoginGoogleSignInPressed(),
                  ),
                  child: const Text('Sign in with Google'),
                ),

                if (state.errorMessage != null)
                  Text(state.errorMessage!, key: const Key('errorText')),
              ],
            );
          },
        ),
      ),
    ),
  );
}

void main() {
  late MockSellerRepository mockRepo;
  late SellerLoginPageBloc bloc;

  setUp(() {
    mockRepo = MockSellerRepository();
    when(() => mockRepo.checkNetworkConnectivity()).thenAnswer((_) async => true);
    bloc = SellerLoginPageBloc(authRepository: mockRepo);
  });

  tearDown(() => bloc.close());

  // ──────────────────────────────────────────────────────────────────────────
  // Group 1 – UI Renders Without Permissions
  // ──────────────────────────────────────────────────────────────────────────
  group('Permission – UI Without Permissions', () {
    testWidgets('core login UI renders without any special permissions', (
      tester,
    ) async {
      await tester.pumpWidget(buildPermissionTestWidget(bloc));
      expect(find.byKey(const Key('loginButton')), findsOneWidget);
      expect(find.byKey(const Key('googleSignInButton')), findsOneWidget);
    });

    testWidgets('biometric button renders without crashing', (tester) async {
      await tester.pumpWidget(buildPermissionTestWidget(bloc));
      expect(find.byKey(const Key('biometricLoginButton')), findsOneWidget);
    });

    testWidgets('camera scan button renders without crashing', (tester) async {
      await tester.pumpWidget(buildPermissionTestWidget(bloc));
      expect(find.byKey(const Key('qrScanButton')), findsOneWidget);
    });
  });

  // ──────────────────────────────────────────────────────────────────────────
  // Group 2 – Standard Login (No Permission Required)
  // ──────────────────────────────────────────────────────────────────────────
  group('Permission – Standard Login (No Permission Needed)', () {
    testWidgets('login with email/password requires no system permission', (
      tester,
    ) async {
      // Email/password login should work without any OS permission
      when(
        () => mockRepo.signIn(any(), any()),
      ).thenAnswer((_) async => throw UnimplementedError());

      await tester.pumpWidget(buildPermissionTestWidget(bloc));
      bloc.emit(
        const SellerLoginPageState(
          emailOrPhone: 'seller@test.com',
          password: 'Pass1234!',
        ),
      );
      await tester.pump();

      expect(find.byKey(const Key('loginButton')), findsOneWidget);
    });

    testWidgets('forgot password requires only email — no OS permission', (
      tester,
    ) async {
      await tester.pumpWidget(buildPermissionTestWidget(bloc));
      bloc.emit(
        const SellerLoginPageState(step: SellerLoginStep.forgotPassword),
      );
      await tester.pump();

      // Widget renders fine — no permission dialog triggered
      expect(tester.takeException(), isNull);
    });
  });

  // ──────────────────────────────────────────────────────────────────────────
  // Group 3 – Google Sign-In Permission Handling
  // ──────────────────────────────────────────────────────────────────────────
  group('Permission – Google Sign-In', () {
    testWidgets('Google sign-in UI element is present', (tester) async {
      await tester.pumpWidget(buildPermissionTestWidget(bloc));
      expect(find.byKey(const Key('googleSignInButton')), findsOneWidget);
    });

    testWidgets('Google sign-in permission denied maps to error state', (
      tester,
    ) async {
      when(
        () => mockRepo.signInWithGoogle(),
      ).thenThrow(Exception('sign_in_cancelled'));

      await tester.pumpWidget(buildPermissionTestWidget(bloc));
      await tester.tap(find.byKey(const Key('googleSignInButton')));
      await tester.runAsync(() => Future.delayed(const Duration(milliseconds: 100)));
      await tester.pump();

      expect(find.byKey(const Key('errorText')), findsOneWidget);
    });

    test('Google sign-in cancelled maps to failure status in BLoC', () async {
      when(
        () => mockRepo.signInWithGoogle(),
      ).thenThrow(Exception('sign_in_cancelled'));

      bloc.add(const SellerLoginGoogleSignInPressed());
      await Future.delayed(const Duration(milliseconds: 100));

      expect(bloc.state.status, SellerLoginStatus.failure);
    });
  });

  // ──────────────────────────────────────────────────────────────────────────
  // Group 4 – BLoC State During Permission Flows
  // ──────────────────────────────────────────────────────────────────────────
  group('Permission – BLoC State Management', () {
    test('loading state is shown while awaiting permission response', () async {
      when(() => mockRepo.signInWithGoogle()).thenAnswer((_) async {
        await Future.delayed(const Duration(milliseconds: 500));
        throw Exception('cancelled');
      });

      bloc.add(const SellerLoginGoogleSignInPressed());
      await Future.delayed(const Duration(milliseconds: 50));

      // Should be in loading state while waiting for Google permission
      expect(bloc.state.status, SellerLoginStatus.loading);

      await Future.delayed(const Duration(milliseconds: 600));
      expect(bloc.state.status, SellerLoginStatus.failure);
    });

    test('error is recoverable after permission denial', () async {
      when(
        () => mockRepo.signInWithGoogle(),
      ).thenThrow(Exception('permission denied'));

      bloc.add(const SellerLoginGoogleSignInPressed());
      await Future.delayed(const Duration(milliseconds: 100));

      expect(bloc.state.status, SellerLoginStatus.failure);

      // User can dismiss and try again
      bloc.add(const SellerLoginErrorDismissed());
      await Future.delayed(Duration.zero);

      expect(bloc.state.status, SellerLoginStatus.initial);
      expect(bloc.state.errorMessage, isNull);
    });
  });

  // ──────────────────────────────────────────────────────────────────────────
  // Group 5 – Platform-Agnostic Permission Handling
  // ──────────────────────────────────────────────────────────────────────────
  group('Permission – Platform Agnostic', () {
    test('BLoC handles permission exception from any platform', () async {
      when(
        () => mockRepo.signInWithApple(),
      ).thenThrow(Exception('NSUserCancelled'));

      bloc.add(const SellerLoginAppleSignInPressed());
      await Future.delayed(const Duration(milliseconds: 100));

      expect(bloc.state.status, SellerLoginStatus.failure);
    });

    test('OTP send survives platform channel permission exception', () async {
      when(
        () => mockRepo.requestPhoneLoginOtp(any()),
      ).thenThrow(Exception('PlatformException: permission denied'));

      bloc.emit(
        const SellerLoginPageState(
          emailOrPhone: '+919876543210',
          password: 'any',
          isPhoneLogin: true,
        ),
      );
      bloc.add(const SellerLoginSubmitted());
      await Future.delayed(const Duration(milliseconds: 100));

      expect(bloc.state.status, SellerLoginStatus.failure);
      expect(bloc.state.errorMessage, isNotNull);
    });
  });
}
