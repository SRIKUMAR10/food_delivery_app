import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mocktail/mocktail.dart';
import 'package:food_delivery_app/API Service/RazorpayApiService.dart';
import 'package:food_delivery_app/Buyer Bloc Architecture/WalletScreen/WalletScreen_UI.dart';
import 'package:food_delivery_app/Buyer Bloc Architecture/WalletScreen/WalletScreen_Bloc.dart';

// Create a Fake Firebase Auth user for the Database
class MockUser extends Mock implements User {}

class MockFirebaseAuth extends Mock implements FirebaseAuth {}

// A simple mock for Razorpay service
class MockRazorpayApiService extends Mock implements RazorpayApiService {
  @override
  void initialize({Function? onSuccess, Function? onFailure}) {}

  @override
  void dispose() {}
}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('WalletScreen Integration & Performance Test', () {
    late FakeFirebaseFirestore fakeFirestore;
    late MockFirebaseAuth mockAuth;
    late MockUser mockUser;
    late WalletDatabase walletDatabase;

    setUp(() {
      fakeFirestore = FakeFirebaseFirestore();
      mockUser = MockUser();
      mockAuth = MockFirebaseAuth();

      when(() => mockUser.uid).thenReturn('test_uid');
      when(() => mockUser.email).thenReturn('test@test.com');
      when(() => mockAuth.currentUser).thenReturn(mockUser);

      // Setup initial data for user
      fakeFirestore.collection('users').doc('test_uid').set({'wallet': 1000.0});
      fakeFirestore
          .collection('users')
          .doc('test_uid')
          .collection('transactions')
          .add({
            'amount': 500.0,
            'currency': 'INR',
            'status': 'success',
            'paymentId': 'pay_123',
            'createdAt': DateTime.now(), // FakeCloudFirestore supports Datetime
          });

      walletDatabase = WalletDatabase(firestore: fakeFirestore, auth: mockAuth);
    });

    Widget createTestApp() {
      return MaterialApp(
        home: RepositoryProvider<RazorpayApiService>(
          create: (_) => MockRazorpayApiService(),
          child: BlocProvider<WalletBloc>(
            create: (_) => WalletBloc(walletDatabase),
            child: const Scaffold(body: WalletView()),
          ),
        ),
      );
    }

    testWidgets('Full Wallet Flow Test', (WidgetTester tester) async {
      await tester.pumpWidget(createTestApp());
      // Wait for stream builder to settle
      await tester.pumpAndSettle(const Duration(seconds: 1));

      // 1. Verify Balance is visible and displays correct amount (1000)
      expect(find.text('₹1000.00'), findsOneWidget);

      // 2. Verify recent transaction is loaded (500)
      expect(find.text('+₹500.00'), findsOneWidget);

      // 3. Test Add Money functionality
      await tester.tap(find.text('Add Money'));
      await tester.pumpAndSettle();

      // Ensure bottom sheet opens
      expect(find.text('Enter Amount'), findsOneWidget);

      // Enter value
      await tester.enterText(find.byType(TextField), '200');
      await tester.pumpAndSettle();

      // Proceed
      await tester.tap(find.text('Proceed'));
      await tester.pumpAndSettle();

      // Confirm Payment Dialog
      expect(find.text('Confirm Payment'), findsOneWidget);
      await tester.tap(find.text('Pay ₹200'));
      await tester.pumpAndSettle();

      // Check for Processing/Loading State
      // Since it immediately calls startPayment (which is mocked to do nothing), it will be in processing state
      final bloc = BlocProvider.of<WalletBloc>(
        tester.element(find.byType(WalletView)),
      );
      expect(bloc.state.isLoading, true);
    });

    testWidgets('Performance Tracking: Smooth scrolling through transactions', (
      WidgetTester tester,
    ) async {
      // Add 20 transactions
      for (int i = 0; i < 20; i++) {
        await fakeFirestore
            .collection('users')
            .doc('test_uid')
            .collection('transactions')
            .add({
              'amount': 100.0 + i,
              'currency': 'INR',
              'status': 'success',
              'paymentId': 'pay_$i',
              'createdAt': DateTime.now(),
            });
      }

      await tester.pumpWidget(createTestApp());
      await tester.pumpAndSettle(const Duration(seconds: 1));

      final listFinder = find.byType(Scrollable).last;

      await IntegrationTestWidgetsFlutterBinding.instance.watchPerformance(() async {
        await tester.fling(listFinder, const Offset(0, -300), 1000);
        await tester.pumpAndSettle();
      }, reportKey: 'scrolling_performance_report');
    });
  });
}
