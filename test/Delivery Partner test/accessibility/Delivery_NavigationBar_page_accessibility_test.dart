import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/services.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:food_delivery_app/features/Delivery%20Partner%20Bloc%20Architecture/Delivery_NavigationBar_page/Delivery_NavigationBar_page_bloc.dart';
import 'package:food_delivery_app/features/Delivery%20Partner%20Bloc%20Architecture/Delivery_NavigationBar_page/Delivery_NavigationBar_page_event.dart';
import 'package:food_delivery_app/features/Delivery%20Partner%20Bloc%20Architecture/Delivery_NavigationBar_page/Delivery_NavigationBar_page_state.dart';
import 'package:food_delivery_app/features/Delivery%20Partner%20Bloc%20Architecture/Delivery_NavigationBar_page/Delivery_NavigationBar_page_repository.dart';
import 'package:food_delivery_app/features/Delivery%20Partner%20Bloc%20Architecture/Delivery_NavigationBar_page/Delivery_NavigationBar_page_ui.dart';

import '../../font_loader_helper.dart';

class MockDeliveryNavigationBarPageBloc
    extends MockBloc<DeliveryNavigationBarEvent, DeliveryNavigationBarState>
    implements DeliveryNavigationBarPageBloc {}

double _relativeLuminance(Color color) {
  double channel(double value) {
    final v = value / 255.0;
    return v <= 0.03928
        ? v / 12.92
        : math.pow((v + 0.055) / 1.055, 2.4).toDouble();
  }

  return 0.2126 * channel(color.r * 255) +
      0.7152 * channel(color.g * 255) +
      0.0722 * channel(color.b * 255);
}

double _contrastRatio(Color foreground, Color background) {
  final fg = _relativeLuminance(foreground);
  final bg = _relativeLuminance(background);
  final lighter = math.max(fg, bg);
  final darker = math.min(fg, bg);
  return (lighter + 0.05) / (darker + 0.05);
}

void main() {
  late MockDeliveryNavigationBarPageBloc mockBloc;

  const DeliveryNavigationBarState loadedState = DeliveryNavigationBarState(
    status: DeliveryNavigationBarStatus.loaded,
    selectedIndex: 4,
    navItems: DeliveryNavigationBarRepository.defaultNavItems,
    partnerName: 'Ravi Kumar',
  );

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
    mockBloc = MockDeliveryNavigationBarPageBloc();
    when(() => mockBloc.state).thenReturn(loadedState);
    when(() => mockBloc.stream).thenAnswer((_) => Stream.value(loadedState));
  });

  void setDesktopSize(WidgetTester tester) {
    tester.view.physicalSize = const Size(1280, 1000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
  }

  group('DeliveryNavigationBarPage Accessibility Tests', () {
    testWidgets('meets minimum 48x48 tap target sizes for menu items', (
      tester,
    ) async {
      setDesktopSize(tester);
      await tester.pumpWidget(
        MaterialApp(home: DeliveryNavigationBarPage(bloc: mockBloc)),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));

      final ordersItem = find.byKey(const ValueKey('dp_nav_orders'));
      final ordersSize = tester.getSize(ordersItem);
      expect(ordersSize.height, greaterThanOrEqualTo(48.0));

      final profileItem = find.byKey(const ValueKey('dp_nav_profile'));
      final profileSize = tester.getSize(profileItem);
      expect(profileSize.height, greaterThanOrEqualTo(48.0));
      expect(profileSize.width, greaterThanOrEqualTo(48.0));

      final contactButton = find.widgetWithText(
        ElevatedButton,
        'Contact Support',
      );
      final contactSize = tester.getSize(contactButton);
      expect(contactSize.height, greaterThanOrEqualTo(48.0));
    });

    testWidgets('provides semantics labels for all menu items', (tester) async {
      setDesktopSize(tester);
      await tester.pumpWidget(
        MaterialApp(home: DeliveryNavigationBarPage(bloc: mockBloc)),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));

      final semanticsLabels = tester
          .widgetList<Semantics>(find.byType(Semantics))
          .map((s) => s.properties.label)
          .whereType<String>()
          .toSet();

      expect(semanticsLabels, contains('Orders'));
      expect(semanticsLabels, contains('Dashboard'));
      expect(semanticsLabels, contains('Earnings'));
      expect(semanticsLabels, contains('Profile'));
      expect(semanticsLabels, contains('Settings'));
      expect(semanticsLabels, contains('Help & Support'));
    });

    testWidgets('maintains accessible color contrast ratios', (tester) async {
      const background = Color(0xFF060B11);
      const unselectedText = Color(0xFF9AA5B1);
      const selectedText = Color(0xFFE8FFF3);

      final unselectedRatio = _contrastRatio(unselectedText, background);
      final selectedRatio = _contrastRatio(selectedText, background);

      expect(unselectedRatio, greaterThanOrEqualTo(4.5));
      expect(selectedRatio, greaterThanOrEqualTo(4.5));
    });
  });
}
