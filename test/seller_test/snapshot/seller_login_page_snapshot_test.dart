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

Widget buildSnapshotWidget(
  SellerLoginPageBloc bloc,
  SellerLoginPageState seed,
) {
  return MaterialApp(
    debugShowCheckedModeBanner: false,
    home: BlocProvider<SellerLoginPageBloc>.value(
      value: bloc,
      child: Builder(
        builder: (context) {
          bloc.emit(seed);
          return Scaffold(
            appBar: AppBar(
              title: Text('Step: ${seed.step.name}'),
              backgroundColor: const Color(0xFF2E7D32),
              foregroundColor: Colors.white,
            ),
            body: BlocBuilder<SellerLoginPageBloc, SellerLoginPageState>(
              builder: (ctx, state) => _SnapshotBody(state: state),
            ),
          );
        },
      ),
    ),
  );
}

class _SnapshotBody extends StatelessWidget {
  final SellerLoginPageState state;
  const _SnapshotBody({required this.state});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _infoRow('Step', state.step.name),
          _infoRow('Status', state.status.name),
          _infoRow(
            'Email',
            state.emailOrPhone.isEmpty ? '(empty)' : state.emailOrPhone,
          ),
          _infoRow('Password obscured', state.isPasswordObscured.toString()),
          _infoRow('OTP complete', state.isOtpComplete.toString()),
          _infoRow('Countdown', state.otpCountdown.toString()),
          _infoRow('Phone login', state.isPhoneLogin.toString()),
          if (state.errorMessage != null)
            _infoRow('Error', state.errorMessage!, isError: true),
        ],
      ),
    );
  }

  Widget _infoRow(String label, String value, {bool isError = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Text(
            '$label: ',
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 13,
                color: isError ? Colors.red : Colors.black87,
              ),
            ),
          ),
        ],
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
  // Group 1 – Snapshot: Initial State
  // ──────────────────────────────────────────────────────────────────────────
  group('Snapshot – Initial State', () {
    testWidgets('snapshot_initial_state matches widget tree', (tester) async {
      await tester.pumpWidget(
        buildSnapshotWidget(bloc, const SellerLoginPageState()),
      );
      await tester.pumpAndSettle();

      expect(find.text('Step: loginForm'), findsOneWidget);
      expect(find.text('Status: initial'), findsOneWidget);
      expect(find.text('Email: (empty)'), findsOneWidget);
    });
  });

  // ──────────────────────────────────────────────────────────────────────────
  // Group 2 – Snapshot: Loading State
  // ──────────────────────────────────────────────────────────────────────────
  group('Snapshot – Loading State', () {
    testWidgets('snapshot_loading_state matches widget tree', (tester) async {
      await tester.pumpWidget(
        buildSnapshotWidget(
          bloc,
          const SellerLoginPageState(
            status: SellerLoginStatus.loading,
            emailOrPhone: 'test@test.com',
          ),
        ),
      );
      await tester.pump();

      expect(find.text('Status: loading'), findsOneWidget);
      expect(find.text('Email: test@test.com'), findsOneWidget);
    });
  });

  // ──────────────────────────────────────────────────────────────────────────
  // Group 3 – Snapshot: OTP Verification State
  // ──────────────────────────────────────────────────────────────────────────
  group('Snapshot – OTP Verification', () {
    testWidgets('snapshot_otp_state shows countdown', (tester) async {
      await tester.pumpWidget(
        buildSnapshotWidget(
          bloc,
          SellerLoginPageState(
            step: SellerLoginStep.otpVerification,
            status: SellerLoginStatus.otpSent,
            emailOrPhone: '+919876543210',
            otpDigits: const ['1', '2', '3', '4', '5', '6'],
            otpCountdown: 20,
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Step: otpVerification'), findsOneWidget);
      expect(find.text('OTP complete: true'), findsOneWidget);
      expect(find.text('Countdown: 20'), findsOneWidget);
    });
  });

  // ──────────────────────────────────────────────────────────────────────────
  // Group 4 – Snapshot: Error State
  // ──────────────────────────────────────────────────────────────────────────
  group('Snapshot – Error State', () {
    testWidgets('snapshot_error_state shows error message', (tester) async {
      await tester.pumpWidget(
        buildSnapshotWidget(
          bloc,
          const SellerLoginPageState(
            status: SellerLoginStatus.failure,
            errorMessage: 'தவறான Password. மீண்டும் முயற்சிக்கவும்.',
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Status: failure'), findsOneWidget);
      expect(
        find.text('Error: தவறான Password. மீண்டும் முயற்சிக்கவும்.'),
        findsOneWidget,
      );
    });
  });

  // ──────────────────────────────────────────────────────────────────────────
  // Group 5 – Snapshot: Forgot Password State
  // ──────────────────────────────────────────────────────────────────────────
  group('Snapshot – Forgot Password State', () {
    testWidgets('snapshot_forgot_password_state', (tester) async {
      await tester.pumpWidget(
        buildSnapshotWidget(
          bloc,
          const SellerLoginPageState(
            step: SellerLoginStep.forgotPassword,
            forgotPasswordEmail: 'reset@seller.com',
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Step: forgotPassword'), findsOneWidget);
    });
  });

  // ──────────────────────────────────────────────────────────────────────────
  // Group 6 – Snapshot: Reset Success State
  // ──────────────────────────────────────────────────────────────────────────
  group('Snapshot – Reset Success State', () {
    testWidgets('snapshot_reset_success_state', (tester) async {
      await tester.pumpWidget(
        buildSnapshotWidget(
          bloc,
          const SellerLoginPageState(
            step: SellerLoginStep.resetSuccess,
            status: SellerLoginStatus.passwordResetSuccess,
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Step: resetSuccess'), findsOneWidget);
      expect(find.text('Status: passwordResetSuccess'), findsOneWidget);
    });
  });

  // ──────────────────────────────────────────────────────────────────────────
  // Group 7 – State Changes Reflect in Snapshot
  // ──────────────────────────────────────────────────────────────────────────
  group('Snapshot – Dynamic State Changes', () {
    testWidgets('widget tree updates when bloc emits new state', (
      tester,
    ) async {
      await tester.pumpWidget(
        buildSnapshotWidget(bloc, const SellerLoginPageState()),
      );
      await tester.pump();

      expect(find.text('Status: initial'), findsOneWidget);

      // Trigger field change
      bloc.add(const SellerLoginFieldChanged('dynamic@test.com'));
      await tester.pump();

      expect(find.text('Email: dynamic@test.com'), findsOneWidget);
    });

    testWidgets('OTP complete status updates in snapshot', (tester) async {
      await tester.pumpWidget(
        buildSnapshotWidget(
          bloc,
          SellerLoginPageState(
            step: SellerLoginStep.otpVerification,
            otpDigits: const ['1', '2', '3', '4', '5', ''],
          ),
        ),
      );
      await tester.pump();
      expect(find.text('OTP complete: false'), findsOneWidget);

      bloc.add(const SellerLoginOtpDigitChanged(index: 5, digit: '6'));
      await tester.pump();
      expect(find.text('OTP complete: true'), findsOneWidget);
    });
  });
}
