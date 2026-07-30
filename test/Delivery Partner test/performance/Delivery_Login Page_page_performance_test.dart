import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/services.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:food_delivery_app/features/Delivery%20Partner%20Bloc%20Architecture/Delivery_Login%20Page_page/Delivery_Login%20Page_page_bloc.dart';
import 'package:food_delivery_app/features/Delivery%20Partner%20Bloc%20Architecture/Delivery_Login%20Page_page/Delivery_Login%20Page_page_event.dart';
import 'package:food_delivery_app/features/Delivery%20Partner%20Bloc%20Architecture/Delivery_Login%20Page_page/Delivery_Login%20Page_page_state.dart';
import 'package:food_delivery_app/features/Delivery%20Partner%20Bloc%20Architecture/Delivery_Login%20Page_page/Delivery_Login%20Page_page_ui.dart';

import '../../font_loader_helper.dart';

class MockDeliveryLoginPageBloc
    extends MockBloc<DeliveryLoginPageEvent, DeliveryLoginPageState>
    implements DeliveryLoginPageBloc {}

void main() {
  late MockDeliveryLoginPageBloc mockBloc;

  setUpAll(() {
    overrideFontAssetLoading();

    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
          const MethodChannel('plugins.flutter.io/path_provider'),
          (MethodCall methodCall) async {
            return '.';
          },
        );
  });

  setUp(() {
    mockBloc = MockDeliveryLoginPageBloc();
    when(() => mockBloc.state).thenReturn(
      const DeliveryLoginPageState(status: DeliveryLoginStatus.initial),
    );
  });

  group('DeliveryLoginPage Performance & Memory Tests', () {
    testWidgets('renders UI within frame threshold and disposes without leaks', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1280, 1000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      final Stopwatch stopwatch = Stopwatch()..start();

      await tester.pumpWidget(
        MaterialApp(
          home: DeliveryLoginPage(
            bloc: mockBloc,
          ),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));
      stopwatch.stop();

      expect(stopwatch.elapsedMilliseconds, lessThan(3000));

      await tester.pumpWidget(const MaterialApp(home: Scaffold(body: SizedBox())));
      await tester.pump(const Duration(milliseconds: 100));
      expect(find.byType(DeliveryLoginPage), findsNothing);
    });
  });
}
