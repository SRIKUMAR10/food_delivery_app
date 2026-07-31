import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:food_delivery_app/features/Delivery%20Partner%20Bloc%20Architecture/Delivery_Wallet_page/Delivery_Wallet_page_ui.dart';

double contrastRatio(Color foreground, Color background) {
  double channel(double value) {
    final v = value / 255;
    return v <= 0.03928
        ? v / 12.92
        : math.pow((v + 0.055) / 1.055, 2.4).toDouble();
  }

  final fg =
      0.2126 * channel(foreground.r * 255) +
      0.7152 * channel(foreground.g * 255) +
      0.0722 * channel(foreground.b * 255);
  final bg =
      0.2126 * channel(background.r * 255) +
      0.7152 * channel(background.g * 255) +
      0.0722 * channel(background.b * 255);
  return (math.max(fg, bg) + 0.05) / (math.min(fg, bg) + 0.05);
}

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  Future<void> load(WidgetTester tester) async {
    tester.view.physicalSize = const Size(1280, 1000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    await tester.pumpWidget(
      MaterialApp(home: const Scaffold(body: DeliveryWalletPage())),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
  }

  group('DeliveryWalletPage Accessibility Tests', () {
    testWidgets('withdraw has a usable tap target', (tester) async {
      await load(tester);
      final size = tester.getSize(
        find.byKey(const Key('dp_wallet_withdraw_button')),
      );
      expect(size.width, greaterThanOrEqualTo(48));
      expect(size.height, greaterThanOrEqualTo(40));
    });

    testWidgets('interactive controls expose button semantics', (tester) async {
      await load(tester);
      final semantics = tester
          .widgetList<Semantics>(find.byType(Semantics))
          .where((widget) => widget.properties.button == true)
          .toList();
      expect(semantics, isNotEmpty);
    });

    testWidgets('selected filters expose selected semantics', (tester) async {
      await load(tester);
      final selected = tester
          .widgetList<Semantics>(find.byType(Semantics))
          .where((widget) => widget.properties.selected == true)
          .toList();
      expect(selected, isNotEmpty);
    });

    test('dark dashboard colors meet minimum contrast', () {
      const background = Color(0xFF0F1E26);
      expect(
        contrastRatio(Colors.white, background),
        greaterThanOrEqualTo(4.5),
      );
      expect(
        contrastRatio(const Color(0xFF00E676), background),
        greaterThanOrEqualTo(3),
      );
    });
  });
}
