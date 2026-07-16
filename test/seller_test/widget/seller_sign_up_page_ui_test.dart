import 'package:firebase_core/firebase_core.dart';
import '../../mock_firebase.dart';
// ignore_for_file: lines_longer_than_80_chars

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mocktail/mocktail.dart';
import 'package:food_delivery_app/features/seller_bloc_architecture/seller_sign_up_page/seller_sign_up_page_bloc.dart';
import 'package:food_delivery_app/features/seller_bloc_architecture/seller_sign_up_page/seller_sign_up_page_state.dart';
import 'package:food_delivery_app/features/seller_bloc_architecture/seller_sign_up_page/seller_sign_up_page_ui.dart';

class MockSellerSignUpPageBloc extends Mock implements SellerSignUpPageBloc {}

void main() {
  setUpAll(() async {
    setupFirebaseAuthMocks();
    await Firebase.initializeApp();
  });

  late MockSellerSignUpPageBloc mockBloc;

  setUp(() {
    mockBloc = MockSellerSignUpPageBloc();
    when(() => mockBloc.stream).thenAnswer((_) => const Stream.empty());
    when(() => mockBloc.state).thenReturn(const SellerSignUpPageState());
    when(() => mockBloc.close()).thenAnswer((_) async {});
  });

  Widget buildTestWidget() {
    return MaterialApp(
      home: BlocProvider<SellerSignUpPageBloc>.value(
        value: mockBloc,
        child: const SellerSignUpPageUI(),
      ),
    );
  }

  group('SellerSignUpPageUI - Widget Tests', () {
    testWidgets('renders Welcome screen by default', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      expect(find.text('Seller ஆக பதிவு செய்யுங்கள்!'), findsOneWidget);
      expect(find.byKey(const Key('getStartedButton')), findsOneWidget);
    });

    testWidgets(
      'renders Personal Details screen when state is personalDetails',
      (tester) async {
        when(() => mockBloc.state).thenReturn(
          const SellerSignUpPageState(step: SellerSignUpStep.personalDetails),
        );
        await tester.pumpWidget(buildTestWidget());
        expect(find.byKey(const Key('nameField')), findsOneWidget);
        expect(find.byKey(const Key('shopNameField')), findsOneWidget);
        expect(find.byKey(const Key('businessDetailsField')), findsOneWidget);
      },
    );

    testWidgets('renders Contact and Password screen', (tester) async {
      when(() => mockBloc.state).thenReturn(
        const SellerSignUpPageState(step: SellerSignUpStep.contactPassword),
      );
      await tester.pumpWidget(buildTestWidget());
      expect(find.byKey(const Key('phoneField')), findsOneWidget);
      expect(find.byKey(const Key('emailField')), findsOneWidget);
      expect(find.byKey(const Key('passwordField')), findsOneWidget);
    });

    testWidgets('renders OTP screen', (tester) async {
      when(() => mockBloc.state).thenReturn(
        const SellerSignUpPageState(
          step: SellerSignUpStep.otpVerification,
          phone: '+919876543210',
        ),
      );
      await tester.pumpWidget(buildTestWidget());
      expect(find.textContaining('+919876543210'), findsOneWidget);
      expect(find.byKey(const Key('verifyOtpButton')), findsOneWidget);
    });

    testWidgets('renders Success screen', (tester) async {
      when(() => mockBloc.state).thenReturn(
        const SellerSignUpPageState(
          step: SellerSignUpStep.signUpSuccess,
          name: 'John',
        ),
      );
      await tester.pumpWidget(buildTestWidget());
      expect(find.textContaining('வரவேற்கிறோம், John!'), findsOneWidget);
      expect(find.byKey(const Key('goToDashboardButton')), findsOneWidget);
    });
  });
}
