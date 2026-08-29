import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:food_delivery_app/core/widgets/primary_button.dart';
import 'package:food_delivery_app/features/seller_bloc_architecture/seller_auth_shared/seller_auth_shared_widgets.dart';

void main() {
  group('SellerResponsiveContainer', () {
    testWidgets('constrains max width to 480 when screen wider than 600', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(800, 600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SellerResponsiveContainer(child: SizedBox(width: 600)),
          ),
        ),
      );

      final constrained = tester.widget<ConstrainedBox>(
        find.descendant(
          of: find.byType(SellerResponsiveContainer),
          matching: find.byType(ConstrainedBox),
        ),
      );
      expect(constrained.constraints.maxWidth, 480.0);
    });

    testWidgets('uses unbounded width on narrow screens', (tester) async {
      tester.view.physicalSize = const Size(400, 600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SellerResponsiveContainer(child: SizedBox(width: 400)),
          ),
        ),
      );

      final constrained = tester.widget<ConstrainedBox>(
        find.descendant(
          of: find.byType(SellerResponsiveContainer),
          matching: find.byType(ConstrainedBox),
        ),
      );
      expect(constrained.constraints.maxWidth, double.infinity);
    });
  });

  group('SellerPrimaryButton', () {
    testWidgets('delegates to core PrimaryButton with auth styling', (
      tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SellerPrimaryButton(label: 'Continue', isLoading: false),
          ),
        ),
      );

      final coreButton = tester.widget<PrimaryButton>(
        find.byType(PrimaryButton),
      );
      expect(coreButton.text, 'Continue');
      expect(coreButton.isLoading, false);
      expect(coreButton.height, 52);
      expect(coreButton.borderRadius, 12);
      expect(coreButton.backgroundColor, const Color(0xFFE52929));
    });

    testWidgets('invokes onPressed when tapped', (tester) async {
      var pressed = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SellerPrimaryButton(
              label: 'Verify',
              isLoading: false,
              onPressed: () => pressed = true,
            ),
          ),
        ),
      );

      await tester.tap(find.text('Verify'));
      expect(pressed, isTrue);
    });
  });

  group('SellerBackButton', () {
    testWidgets('invokes onTap when tapped', (tester) async {
      var tapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SellerBackButton(onTap: () => tapped = true),
          ),
        ),
      );

      await tester.tap(find.byType(SellerBackButton));
      expect(tapped, isTrue);
    });
  });

  group('SellerScreenIllustration', () {
    testWidgets('renders child inside hero container', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SellerScreenIllustration(
              heroTag: 'test_hero',
              child: Icon(Icons.person_rounded),
            ),
          ),
        ),
      );

      expect(find.byType(Hero), findsOneWidget);
      expect(find.byIcon(Icons.person_rounded), findsOneWidget);
      final hero = tester.widget<Hero>(find.byType(Hero));
      expect(hero.tag, 'test_hero');
    });
  });

  group('SellerOtpBoxRow', () {
    testWidgets('renders 6 digit boxes and forwards digit changes', (
      tester,
    ) async {
      final controllers = List.generate(6, (_) => TextEditingController());
      final focusNodes = List.generate(6, (_) => FocusNode());
      addTearDown(() {
        for (final c in controllers) {
          c.dispose();
        }
        for (final f in focusNodes) {
          f.dispose();
        }
      });

      final changedDigits = <int, String>{};

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SellerOtpBoxRow(
              controllers: controllers,
              focusNodes: focusNodes,
              onDigitChanged: (index, digit) => changedDigits[index] = digit,
            ),
          ),
        ),
      );

      expect(find.byType(TextField), findsNWidgets(6));

      await tester.enterText(find.byType(TextField).first, '4');
      expect(changedDigits[0], '4');
    });

    testWidgets('moves focus to next box after entering a digit', (
      tester,
    ) async {
      final controllers = List.generate(6, (_) => TextEditingController());
      final focusNodes = List.generate(6, (_) => FocusNode());
      addTearDown(() {
        for (final c in controllers) {
          c.dispose();
        }
        for (final f in focusNodes) {
          f.dispose();
        }
      });

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SellerOtpBoxRow(
              controllers: controllers,
              focusNodes: focusNodes,
              onDigitChanged: (index, digit) {},
            ),
          ),
        ),
      );

      await tester.enterText(find.byType(TextField).first, '9');
      await tester.pump();
      expect(focusNodes[1].hasFocus, isTrue);
    });
  });

  group('SellerOtpVerificationScreen', () {
    Widget buildScreen({
      String title = 'Email Verification',
      String subtitleValue = 'seller@example.com',
      String verifyLabel = 'Verify',
      Key? verifyButtonKey,
      bool isLoading = false,
      int countdown = 0,
      bool resendAvailable = true,
      bool alwaysShowCountdownSlot = true,
      String? otpError,
      bool showStepFooter = false,
      String stepFooterText = '',
      VoidCallback? onBack,
      VoidCallback? onResend,
      VoidCallback? onVerify,
    }) {
      return MaterialApp(
        home: Scaffold(
          body: SellerOtpVerificationScreen(
            title: title,
            subtitleValue: subtitleValue,
            verifyLabel: verifyLabel,
            verifyButtonKey: verifyButtonKey,
            isLoading: isLoading,
            countdown: countdown,
            resendAvailable: resendAvailable,
            alwaysShowCountdownSlot: alwaysShowCountdownSlot,
            otpError: otpError,
            showStepFooter: showStepFooter,
            stepFooterText: stepFooterText,
            onBack: onBack ?? () {},
            onDigitChanged: (index, digit) {},
            onResend: onResend ?? () {},
            onVerify: onVerify ?? () {},
          ),
        ),
      );
    }

    testWidgets('renders title, subtitle and verify button', (tester) async {
      await tester.pumpWidget(
        buildScreen(
          title: 'OTP Verification',
          subtitleValue: '+919876543210',
          verifyLabel: 'Verify OTP',
          verifyButtonKey: const Key('verifyOtpButton'),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('OTP Verification'), findsOneWidget);
      expect(find.textContaining('+919876543210'), findsOneWidget);
      expect(find.text('Verify OTP'), findsOneWidget);
      expect(find.byKey(const Key('verifyOtpButton')), findsOneWidget);
      expect(find.byType(TextField), findsNWidgets(6));
    });

    testWidgets('shows countdown when resend is not available', (
      tester,
    ) async {
      await tester.pumpWidget(
        buildScreen(countdown: 45, resendAvailable: false),
      );
      await tester.pumpAndSettle();

      expect(find.text('Resend OTP in 00:45'), findsOneWidget);
      expect(find.text('Resend OTP'), findsNothing);
    });

    testWidgets('shows resend button when resend is available', (tester) async {
      await tester.pumpWidget(buildScreen(resendAvailable: true));
      await tester.pumpAndSettle();

      expect(find.text('Resend OTP'), findsOneWidget);
    });

    testWidgets('renders countdown via inline slot variant (sign-up flow)', (
      tester,
    ) async {
      await tester.pumpWidget(
        buildScreen(
          alwaysShowCountdownSlot: false,
          countdown: 30,
          resendAvailable: false,
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Resend OTP in 00:30'), findsOneWidget);
      expect(find.text('Resend OTP'), findsNothing);
    });

    testWidgets('shows OTP error text when provided', (tester) async {
      await tester.pumpWidget(buildScreen(otpError: 'Invalid OTP'));
      await tester.pumpAndSettle();

      expect(find.text('Invalid OTP'), findsOneWidget);
    });

    testWidgets('shows step footer when enabled', (tester) async {
      await tester.pumpWidget(
        buildScreen(showStepFooter: true, stepFooterText: '4. Email OTP Verification'),
      );
      await tester.pumpAndSettle();

      expect(find.text('4. Email OTP Verification'), findsOneWidget);
    });

    testWidgets('fires back, resend and verify callbacks', (tester) async {
      var backFired = false;
      var resendFired = false;
      var verifyFired = false;

      await tester.pumpWidget(
        buildScreen(
          onBack: () => backFired = true,
          onResend: () => resendFired = true,
          onVerify: () => verifyFired = true,
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byType(SellerBackButton));
      await tester.tap(find.text('Resend OTP'));
      await tester.tap(find.text('Verify'));

      expect(backFired, isTrue);
      expect(resendFired, isTrue);
      expect(verifyFired, isTrue);
    });
  });
}