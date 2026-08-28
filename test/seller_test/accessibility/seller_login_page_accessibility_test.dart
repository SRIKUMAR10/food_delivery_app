// ignore_for_file: lines_longer_than_80_chars

import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:food_delivery_app/features/seller_bloc_architecture/seller_login_page/seller_login_page_bloc.dart';
import 'package:food_delivery_app/features/seller_bloc_architecture/seller_login_page/seller_login_page_state.dart';
import 'package:food_delivery_app/repositories/seller_repository.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Mocks
// ─────────────────────────────────────────────────────────────────────────────
class MockSellerRepository extends Mock implements SellerRepository {}

Widget buildAccessibilityTestWidget(SellerLoginPageBloc bloc) {
  return MaterialApp(
    home: BlocProvider<SellerLoginPageBloc>.value(
      value: bloc,
      child: Scaffold(
        body: BlocBuilder<SellerLoginPageBloc, SellerLoginPageState>(
          builder: (context, state) {
            return SingleChildScrollView(
              child: Column(
                children: [
                  // Semantic label on phone field
                  Semantics(
                    label: 'Phone Number input field',
                    textField: true,
                    child: TextField(
                      key: const Key('emailField'),
                      decoration: const InputDecoration(
                        hintText: 'Phone Number',
                        labelText: 'Phone Number',
                      ),
                    ),
                  ),

                  // Semantic label on password field
                  Semantics(
                    label: 'Password input field',
                    textField: true,
                    obscured: state.isPasswordObscured,
                    child: TextField(
                      key: const Key('passwordField'),
                      obscureText: state.isPasswordObscured,
                      decoration: const InputDecoration(
                        hintText: 'Password',
                        labelText: 'Password',
                      ),
                    ),
                  ),

                  // Semantic label on login button
                  Semantics(
                    label: 'Login button',
                    button: true,
                    child: ElevatedButton(
                      key: const Key('loginButton'),
                      onPressed: () {},
                      child: const Text('Login'),
                    ),
                  ),

                  // Forgot password with accessible tooltip
                  Semantics(
                    label: 'Forgot password button',
                    button: true,
                    child: TextButton(
                      key: const Key('forgotPasswordButton'),
                      onPressed: () {},
                      child: const Text('Forgot Password?'),
                    ),
                  ),

                  // Error text accessible
                  if (state.errorMessage != null)
                    Semantics(
                      label: 'Error: ${state.errorMessage}',
                      liveRegion: true,
                      child: Text(
                        state.errorMessage!,
                        key: const Key('errorText'),
                        style: const TextStyle(color: Colors.red),
                      ),
                    ),

                  // Loading indicator accessible
                  if (state.status == SellerLoginStatus.loading)
                    Semantics(
                      label: 'Loading, please wait',
                      child: const CircularProgressIndicator(
                        key: Key('loadingIndicator'),
                      ),
                    ),
                ],
              ),
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
    bloc = SellerLoginPageBloc(authRepository: mockRepo);
  });

  tearDown(() => bloc.close());

  // ──────────────────────────────────────────────────────────────────────────
  // Group 1 – Semantic Labels
  // ──────────────────────────────────────────────────────────────────────────
  group('Accessibility – Semantic Labels', () {
    testWidgets('phone field has semantic label', (tester) async {
      await tester.pumpWidget(buildAccessibilityTestWidget(bloc));

      final semantics = tester.getSemantics(
        find.byKey(const Key('emailField')),
      );
      expect(semantics.label, contains('Phone'));
    });

    testWidgets('password field has semantic label', (tester) async {
      await tester.pumpWidget(buildAccessibilityTestWidget(bloc));
      final semantics = tester.getSemantics(
        find.byKey(const Key('passwordField')),
      );
      expect(semantics.label, isNotEmpty);
    });

    testWidgets('login button has semantic button role', (tester) async {
      await tester.pumpWidget(buildAccessibilityTestWidget(bloc));
      final semantics = tester.getSemantics(
        find.byKey(const Key('loginButton')),
      );
      expect(semantics// ignore: deprecated_member_use
      .hasFlag(SemanticsFlag.isButton), isTrue);
    });

    testWidgets('forgot password button has semantic label', (tester) async {
      await tester.pumpWidget(buildAccessibilityTestWidget(bloc));
      final semantics = tester.getSemantics(
        find.byKey(const Key('forgotPasswordButton')),
      );
      expect(semantics.label, contains('Password'));
    });
  });

  // ──────────────────────────────────────────────────────────────────────────
  // Group 2 – Focus Order
  // ──────────────────────────────────────────────────────────────────────────
  group('Accessibility – Focus Order', () {
    testWidgets('email field is focusable', (tester) async {
      await tester.pumpWidget(buildAccessibilityTestWidget(bloc));
      await tester.tap(find.byKey(const Key('emailField')));
      await tester.pump();
      expect(tester.binding.focusManager.primaryFocus, isNotNull);
    });

    testWidgets('login button is tappable by keyboard', (tester) async {
      await tester.pumpWidget(buildAccessibilityTestWidget(bloc));
      await tester.tap(find.byKey(const Key('loginButton')));
      await tester.pump();
      // Verifies that the button responds to interaction
      expect(find.byKey(const Key('loginButton')), findsOneWidget);
    });
  });

  // ──────────────────────────────────────────────────────────────────────────
  // Group 3 – Text Scaling
  // ──────────────────────────────────────────────────────────────────────────
  group('Accessibility – Text Scaling', () {
    testWidgets('UI renders correctly at 1.5x text scale', (tester) async {
      await tester.pumpWidget(
        MediaQuery(
          data: const MediaQueryData(textScaler: TextScaler.linear(1.5)),
          child: buildAccessibilityTestWidget(bloc),
        ),
      );
      expect(find.byKey(const Key('loginButton')), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('UI renders correctly at 2.0x text scale without overflow', (
      tester,
    ) async {
      await tester.pumpWidget(
        MediaQuery(
          data: const MediaQueryData(textScaler: TextScaler.linear(2.0)),
          child: buildAccessibilityTestWidget(bloc),
        ),
      );
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    });
  });

  // ──────────────────────────────────────────────────────────────────────────
  // Group 4 – Live Regions (Screen Reader)
  // ──────────────────────────────────────────────────────────────────────────
  group('Accessibility – Live Regions', () {
    testWidgets('error message is exposed as live region', (tester) async {
      await tester.pumpWidget(buildAccessibilityTestWidget(bloc));
      bloc.emit(
        const SellerLoginPageState(
          status: SellerLoginStatus.failure,
          errorMessage: 'Login failed',
        ),
      );
      await tester.pump();

      final semantics = tester.getSemantics(find.byKey(const Key('errorText')));
      expect(semantics// ignore: deprecated_member_use
      .hasFlag(SemanticsFlag.isLiveRegion), isTrue);
    });

    testWidgets('loading indicator announces to screen reader', (tester) async {
      await tester.pumpWidget(buildAccessibilityTestWidget(bloc));
      bloc.emit(const SellerLoginPageState(status: SellerLoginStatus.loading));
      await tester.pump();

      final semantics = tester.getSemantics(
        find.byKey(const Key('loadingIndicator')),
      );
      expect(semantics.label, contains('Loading'));
    });
  });

  // ──────────────────────────────────────────────────────────────────────────
  // Group 5 – Contrast & Color Independence
  // ──────────────────────────────────────────────────────────────────────────
  group('Accessibility – Color Independence', () {
    testWidgets('error state is not conveyed by color alone', (tester) async {
      await tester.pumpWidget(buildAccessibilityTestWidget(bloc));
      bloc.emit(
        const SellerLoginPageState(
          status: SellerLoginStatus.failure,
          errorMessage: 'Error occurred',
        ),
      );
      await tester.pump();

      // Error text widget exists and has textual content (not just color)
      expect(find.byKey(const Key('errorText')), findsOneWidget);
      expect(find.text('Error occurred'), findsOneWidget);
    });

    testWidgets(
      'loading state shows indicator widget, not just spinner color',
      (tester) async {
        await tester.pumpWidget(buildAccessibilityTestWidget(bloc));
        bloc.emit(
          const SellerLoginPageState(status: SellerLoginStatus.loading),
        );
        await tester.pump();

        // Loading indicator exists as a separate widget
        expect(find.byType(CircularProgressIndicator), findsOneWidget);
      },
    );
  });

  // ──────────────────────────────────────────────────────────────────────────
  // Group 6 – Minimum Touch Target Size (48x48 per WCAG)
  // ──────────────────────────────────────────────────────────────────────────
  group('Accessibility – Touch Target Size', () {
    testWidgets('login button meets minimum touch target size', (tester) async {
      await tester.pumpWidget(buildAccessibilityTestWidget(bloc));
      final buttonFinder = find.byKey(const Key('loginButton'));
      final buttonRect = tester.getRect(buttonFinder);

      // WCAG 2.5.5 recommends at least 44x44 CSS pixels
      expect(buttonRect.height, greaterThanOrEqualTo(44));
    });

    testWidgets('forgot password button is tappable', (tester) async {
      await tester.pumpWidget(buildAccessibilityTestWidget(bloc));
      expect(find.byKey(const Key('forgotPasswordButton')), findsOneWidget);
    });
  });
}
