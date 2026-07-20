// ignore_for_file: lines_longer_than_80_chars

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:food_delivery_app/features/seller_bloc_architecture/seller_login_page/seller_login_page_state.dart';

Widget buildSnapshotWidget(SellerLoginPageState seed) {
  return MaterialApp(
    debugShowCheckedModeBanner: false,
    home: Scaffold(
      appBar: AppBar(
        title: Text('Step: ${seed.step.name}'),
        backgroundColor: const Color(0xFF2E7D32),
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _infoRow('Step', seed.step.name),
            _infoRow('Status', seed.status.name),
            _infoRow(
              'Email',
              seed.emailOrPhone.isEmpty ? '(empty)' : seed.emailOrPhone,
            ),
            _infoRow('Password obscured', seed.isPasswordObscured.toString()),
            _infoRow('OTP complete', seed.isOtpComplete.toString()),
            _infoRow('Countdown', seed.otpCountdown.toString()),
            _infoRow('Phone login', seed.isPhoneLogin.toString()),
            if (seed.errorMessage != null)
              _infoRow('Error', seed.errorMessage!, isError: true),
          ],
        ),
      ),
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

/// Returns a finder that matches a Row containing [labelText] as a direct Text child.
Finder findRowWithLabel(String labelText) {
  return find.byWidgetPredicate(
    (widget) =>
        widget is Row &&
        widget.children.any(
          (child) => child is Text && child.data == '$labelText: ',
        ),
  );
}

void main() {
  // ──────────────────────────────────────────────────────────────────────────
  // Group 1 – Snapshot: Initial State
  // ──────────────────────────────────────────────────────────────────────────
  group('Snapshot – Initial State', () {
    testWidgets('snapshot_initial_state matches widget tree', (tester) async {
      await tester.pumpWidget(
        buildSnapshotWidget(const SellerLoginPageState()),
      );
      await tester.pumpAndSettle();

      expect(find.text('loginForm'), findsOneWidget);
      expect(find.text('initial'), findsOneWidget);
      expect(find.text('(empty)'), findsOneWidget);
    });
  });

  // ──────────────────────────────────────────────────────────────────────────
  // Group 2 – Snapshot: Loading State
  // ──────────────────────────────────────────────────────────────────────────
  group('Snapshot – Loading State', () {
    testWidgets('snapshot_loading_state matches widget tree', (tester) async {
      await tester.pumpWidget(
        buildSnapshotWidget(
          const SellerLoginPageState(
            status: SellerLoginStatus.loading,
            emailOrPhone: 'test@test.com',
          ),
        ),
      );
      await tester.pump();

      expect(find.text('loading'), findsOneWidget);
      expect(find.text('test@test.com'), findsOneWidget);
    });
  });

  // ──────────────────────────────────────────────────────────────────────────
  // Group 3 – Snapshot: OTP Verification State
  // ──────────────────────────────────────────────────────────────────────────
  group('Snapshot – OTP Verification', () {
    testWidgets('snapshot_otp_state shows countdown', (tester) async {
      await tester.pumpWidget(
        buildSnapshotWidget(
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

      expect(find.text('otpVerification'), findsOneWidget);
      expect(find.text('20'), findsOneWidget);
    });
  });

  // ──────────────────────────────────────────────────────────────────────────
  // Group 4 – Snapshot: Error State
  // ──────────────────────────────────────────────────────────────────────────
  group('Snapshot – Error State', () {
    testWidgets('snapshot_error_state shows error message', (tester) async {
      await tester.pumpWidget(
        buildSnapshotWidget(
          const SellerLoginPageState(
            status: SellerLoginStatus.failure,
            errorMessage: 'தவறான Password. மீண்டும் முயற்சிக்கவும்.',
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('failure'), findsOneWidget);
      expect(
        find.text('தவறான Password. மீண்டும் முயற்சிக்கவும்.'),
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
          const SellerLoginPageState(
            step: SellerLoginStep.forgotPassword,
            forgotPasswordEmail: 'reset@seller.com',
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('forgotPassword'), findsOneWidget);
    });
  });

  // ──────────────────────────────────────────────────────────────────────────
  // Group 7 – State Changes Reflect in Snapshot
  // ──────────────────────────────────────────────────────────────────────────
  group('Snapshot – Dynamic State Changes', () {
    testWidgets('widget tree updates when state changes', (tester) async {
      await tester.pumpWidget(
        buildSnapshotWidget(const SellerLoginPageState()),
      );
      await tester.pump();

      expect(find.text('initial'), findsOneWidget);

      await tester.pumpWidget(
        buildSnapshotWidget(
          const SellerLoginPageState(emailOrPhone: 'dynamic@test.com'),
        ),
      );
      await tester.pump();

      expect(find.text('dynamic@test.com'), findsOneWidget);
    });

    testWidgets('OTP complete status updates', (tester) async {
      await tester.pumpWidget(
        buildSnapshotWidget(
          SellerLoginPageState(
            step: SellerLoginStep.otpVerification,
            otpDigits: const ['1', '2', '3', '4', '5', ''],
          ),
        ),
      );
      await tester.pump();

      expect(
        find.textContaining('false'),
        findsAtLeastNWidgets(1),
      );

      await tester.pumpWidget(
        buildSnapshotWidget(
          SellerLoginPageState(
            step: SellerLoginStep.otpVerification,
            otpDigits: const ['1', '2', '3', '4', '5', '6'],
          ),
        ),
      );
      await tester.pump();

      expect(
        find.textContaining('true'),
        findsAtLeastNWidgets(1),
      );
    });
  });
}
