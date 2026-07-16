import 'package:firebase_core/firebase_core.dart';
import '../../mock_firebase.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mocktail/mocktail.dart';
import 'package:food_delivery_app/features/seller_bloc_architecture/seller_dashboard_page/seller_dashboard_page_ui.dart';
import 'package:food_delivery_app/features/seller_bloc_architecture/seller_dashboard_page/seller_dashboard_page_bloc.dart';
import 'package:food_delivery_app/features/seller_bloc_architecture/seller_dashboard_page/seller_dashboard_page_state.dart';
import 'package:food_delivery_app/features/seller_bloc_architecture/seller_dashboard_page/seller_dashboard_repository.dart';

class MockSellerDashboardPageBloc extends Mock
    implements SellerDashboardPageBloc {}

class MockSellerDashboardRepository extends Mock
    implements SellerDashboardRepository {}

void main() {
  setUpAll(() async {
    setupFirebaseAuthMocks();
    await Firebase.initializeApp();
  });

  group('SellerDashboardPageUI Widget Tests', () {
    late MockSellerDashboardPageBloc mockBloc;

    setUp(() {
      mockBloc = MockSellerDashboardPageBloc();
      // Ensure the mock returns a stream, even an empty one
      when(() => mockBloc.stream).thenAnswer((_) => const Stream.empty());
    });

    Widget createWidgetUnderTest() {
      return MaterialApp(
        home: RepositoryProvider<SellerDashboardRepository>(
          create: (_) => MockSellerDashboardRepository(),
          child: BlocProvider<SellerDashboardPageBloc>.value(
            value: mockBloc,
            child: const SellerDashboardPageUI(),
          ),
        ),
      );
    }

    testWidgets('displays Skeleton Loader when state is Initial', (
      WidgetTester tester,
    ) async {
      when(() => mockBloc.state).thenReturn(SellerDashboardInitial());

      await tester.pumpWidget(createWidgetUnderTest());

      // The UI uses a Scaffold but does not use BottomNavigationBar directly
      // It has SellerAppBarPageUI and CustomScrollView
      expect(find.byType(Scaffold), findsOneWidget);
      expect(find.byType(SingleChildScrollView), findsWidgets);
    });
  });
}
