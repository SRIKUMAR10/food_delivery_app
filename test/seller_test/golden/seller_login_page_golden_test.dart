// ignore_for_file: lines_longer_than_80_chars

import 'package:flutter/material.dart';
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

// ─────────────────────────────────────────────────────────────────────────────
// Golden tests validate pixel-perfect rendering of each screen state.
// Run with: flutter test --update-goldens (to regenerate baselines)
// ─────────────────────────────────────────────────────────────────────────────
Widget buildGoldenWidget(SellerLoginPageBloc bloc, SellerLoginPageState seed) {
  return MaterialApp(
    debugShowCheckedModeBanner: false,
    routes: {
      '/sellerDashboard': (_) => const Scaffold(body: Text('Dashboard')),
      '/sellerSignUp': (_) => const Scaffold(body: Text('Sign Up')),
    },
    home: BlocProvider<SellerLoginPageBloc>.value(
      value: bloc,
      child: Builder(
        builder: (context) {
          bloc.emit(seed);
          return Scaffold(
            body: BlocBuilder<SellerLoginPageBloc, SellerLoginPageState>(
              builder: (ctx, state) => _GoldenShell(state: state),
            ),
          );
        },
      ),
    ),
  );
}

/// Renders a minimal but representative UI shell for golden comparison.
class _GoldenShell extends StatelessWidget {
  final SellerLoginPageState state;
  const _GoldenShell({required this.state});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Step indicator
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFFE8F5E9),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                'Step: ${state.step.name}',
                style: const TextStyle(
                  color: Color(0xFF2E7D32),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Status indicator
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: state.status == SellerLoginStatus.failure
                    ? const Color(0xFFFFEBEE)
                    : state.status == SellerLoginStatus.success
                    ? const Color(0xFFE8F5E9)
                    : const Color(0xFFF5F5F5),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                'Status: ${state.status.name}',
                style: const TextStyle(fontSize: 13),
              ),
            ),
            const SizedBox(height: 16),

            // Email field
            TextField(
              controller: TextEditingController(text: state.emailOrPhone),
              decoration: InputDecoration(
                hintText: 'Email / Phone',
                prefixIcon: const Icon(Icons.email_outlined),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Password field
            TextField(
              controller: TextEditingController(text: state.password),
              obscureText: state.isPasswordObscured,
              decoration: InputDecoration(
                hintText: 'Password',
                prefixIcon: const Icon(Icons.lock_outline),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                suffixIcon: const Icon(Icons.visibility_off_outlined),
              ),
            ),
            const SizedBox(height: 20),

            // Primary button
            ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2E7D32),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                minimumSize: const Size(double.infinity, 52),
              ),
              child: const Text(
                'Login',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
            ),

            // Error text
            if (state.errorMessage != null) ...[
              const SizedBox(height: 12),
              Text(
                state.errorMessage!,
                style: const TextStyle(color: Color(0xFFD32F2F), fontSize: 13),
                textAlign: TextAlign.center,
              ),
            ],
          ],
        ),
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

  tearDown(() => bloc.close());

  // ──────────────────────────────────────────────────────────────────────────
  // Golden Tests – one per primary screen state
  // ──────────────────────────────────────────────────────────────────────────
  testWidgets('golden_01_login_form_initial', (tester) async {
    await tester.pumpWidget(
      buildGoldenWidget(bloc, const SellerLoginPageState()),
    );
    await tester.pumpAndSettle();
    await expectLater(
      find.byType(MaterialApp),
      matchesGoldenFile('goldens/seller_login/01_login_form_initial.png'),
    );
  });

  testWidgets('golden_02_login_form_loading', (tester) async {
    await tester.pumpWidget(
      buildGoldenWidget(
        bloc,
        const SellerLoginPageState(status: SellerLoginStatus.loading),
      ),
    );
    await tester.pump();
    await expectLater(
      find.byType(MaterialApp),
      matchesGoldenFile('goldens/seller_login/02_login_form_loading.png'),
    );
  });

  testWidgets('golden_03_login_form_filled', (tester) async {
    await tester.pumpWidget(
      buildGoldenWidget(
        bloc,
        const SellerLoginPageState(
          emailOrPhone: 'seller@restaurant.com',
          password: 'SecurePass1!',
          isPasswordObscured: false,
        ),
      ),
    );
    await tester.pumpAndSettle();
    await expectLater(
      find.byType(MaterialApp),
      matchesGoldenFile('goldens/seller_login/03_login_form_filled.png'),
    );
  });

  testWidgets('golden_04_login_failure', (tester) async {
    await tester.pumpWidget(
      buildGoldenWidget(
        bloc,
        const SellerLoginPageState(
          status: SellerLoginStatus.failure,
          errorMessage: 'தவறான password. மீண்டும் முயற்சிக்கவும்.',
          emailOrPhone: 'seller@restaurant.com',
          password: 'wrong',
        ),
      ),
    );
    await tester.pumpAndSettle();
    await expectLater(
      find.byType(MaterialApp),
      matchesGoldenFile('goldens/seller_login/04_login_failure.png'),
    );
  });

  testWidgets('golden_05_otp_verification', (tester) async {
    await tester.pumpWidget(
      buildGoldenWidget(
        bloc,
        SellerLoginPageState(
          step: SellerLoginStep.otpVerification,
          status: SellerLoginStatus.otpSent,
          emailOrPhone: '+919876543210',
          otpDigits: const ['1', '2', '3', '', '', ''],
          otpCountdown: 20,
        ),
      ),
    );
    await tester.pumpAndSettle();
    await expectLater(
      find.byType(MaterialApp),
      matchesGoldenFile('goldens/seller_login/05_otp_verification.png'),
    );
  });

  testWidgets('golden_06_login_success', (tester) async {
    await tester.pumpWidget(
      buildGoldenWidget(
        bloc,
        const SellerLoginPageState(
          step: SellerLoginStep.loginSuccess,
          status: SellerLoginStatus.success,
        ),
      ),
    );
    await tester.pumpAndSettle();
    await expectLater(
      find.byType(MaterialApp),
      matchesGoldenFile('goldens/seller_login/06_login_success.png'),
    );
  });

  testWidgets('golden_07_forgot_password', (tester) async {
    await tester.pumpWidget(
      buildGoldenWidget(
        bloc,
        const SellerLoginPageState(
          step: SellerLoginStep.forgotPassword,
          forgotPasswordEmail: 'reset@seller.com',
        ),
      ),
    );
    await tester.pumpAndSettle();
    await expectLater(
      find.byType(MaterialApp),
      matchesGoldenFile('goldens/seller_login/07_forgot_password.png'),
    );
  });

  testWidgets('golden_08_reset_password', (tester) async {
    await tester.pumpWidget(
      buildGoldenWidget(
        bloc,
        const SellerLoginPageState(
          step: SellerLoginStep.resetPassword,
          newPassword: 'NewSecure1!',
          confirmPassword: 'NewSecure1!',
        ),
      ),
    );
    await tester.pumpAndSettle();
    await expectLater(
      find.byType(MaterialApp),
      matchesGoldenFile('goldens/seller_login/08_reset_password.png'),
    );
  });

  testWidgets('golden_09_reset_success', (tester) async {
    await tester.pumpWidget(
      buildGoldenWidget(
        bloc,
        const SellerLoginPageState(
          step: SellerLoginStep.resetSuccess,
          status: SellerLoginStatus.passwordResetSuccess,
        ),
      ),
    );
    await tester.pumpAndSettle();
    await expectLater(
      find.byType(MaterialApp),
      matchesGoldenFile('goldens/seller_login/09_reset_success.png'),
    );
  });
}
