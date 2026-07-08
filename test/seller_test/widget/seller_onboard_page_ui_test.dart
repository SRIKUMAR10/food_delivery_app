import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:network_image_mock/network_image_mock.dart';
import 'package:food_delivery_app/features/seller_bloc_architecture/seller_onboard_page/seller_onboard_page_ui.dart';
import 'package:food_delivery_app/features/seller_bloc_architecture/seller_onboard_page/seller_onboard_page_bloc.dart';
import 'package:food_delivery_app/features/seller_bloc_architecture/seller_onboard_page/seller_onboard_page_state.dart';
import 'package:food_delivery_app/features/seller_bloc_architecture/seller_onboard_page/seller_onboard_page_event.dart';

class MockSellerOnboardPageBloc
    extends MockBloc<SellerOnboardPageEvent, SellerOnboardPageState>
    implements SellerOnboardPageBloc {}

void main() {
  late MockSellerOnboardPageBloc mockBloc;

  setUp(() {
    mockBloc = MockSellerOnboardPageBloc();
  });

  Widget createWidgetUnderTest() {
    return MaterialApp(
      home: BlocProvider<SellerOnboardPageBloc>.value(
        value: mockBloc,
        child: const SellerOnboardView(),
      ),
    );
  }

  group('SellerOnboardPageUI Widget Tests', () {
    testWidgets('renders initial UI correctly', (WidgetTester tester) async {
      when(() => mockBloc.state).thenReturn(SellerOnboardInitial());

      await mockNetworkImagesFor(
        () => tester.pumpWidget(createWidgetUnderTest()),
      );

      // Let animations settle
      await tester.pumpAndSettle();

      expect(find.text('Seller App'), findsOneWidget);
      expect(
        find.text('Manage your restaurant\nbusiness with ease'),
        findsOneWidget,
      );
      expect(find.text('Get Started'), findsOneWidget);
    });

    testWidgets('shows CircularProgressIndicator when state is loading', (
      WidgetTester tester,
    ) async {
      when(() => mockBloc.state).thenReturn(SellerOnboardLoading());

      await mockNetworkImagesFor(
        () => tester.pumpWidget(createWidgetUnderTest()),
      );
      await tester.pump();

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('shows error SnackBar when state is error', (
      WidgetTester tester,
    ) async {
      when(
        () => mockBloc.state,
      ).thenReturn(const SellerOnboardError('Network Failed'));
      whenListen(
        mockBloc,
        Stream.fromIterable([const SellerOnboardError('Network Failed')]),
      );

      await mockNetworkImagesFor(
        () => tester.pumpWidget(createWidgetUnderTest()),
      );
      await tester.pump();

      expect(find.text('Network Failed'), findsOneWidget);
    });
  });
}
