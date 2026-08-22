import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:food_delivery_app/core/widgets/filter_chips_bar.dart';

void main() {
  testWidgets('FilterChipsBar renders all items and handles selection', (WidgetTester tester) async {
    String selectedValue = 'all';

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 300,
            child: StatefulBuilder(
              builder: (context, setState) {
                return FilterChipsBar(
                  items: const [
                    FilterChipItem(label: 'All', value: 'all'),
                    FilterChipItem(label: 'Customers', value: 'customers'),
                    FilterChipItem(label: 'Delivery Partners', value: 'deliveryPartners'),
                    FilterChipItem(label: 'Active Orders', value: 'orders'),
                  ],
                  selected: selectedValue,
                  onSelected: (value) {
                    setState(() {
                      selectedValue = value;
                    });
                  },
                );
              },
            ),
          ),
        ),
      ),
    );

    expect(find.text('All'), findsOneWidget);
    expect(find.text('Customers'), findsOneWidget);

    // Tap on Customers chip
    await tester.tap(find.text('Customers'));
    await tester.pumpAndSettle();

    expect(selectedValue, equals('customers'));
  });

  testWidgets('FilterChipsBar supports horizontal mouse dragging', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 200,
            child: FilterChipsBar(
              items: const [
                FilterChipItem(label: 'All', value: 'all'),
                FilterChipItem(label: 'Customers', value: 'customers'),
                FilterChipItem(label: 'Delivery Partners', value: 'deliveryPartners'),
                FilterChipItem(label: 'Active Orders', value: 'orders'),
              ],
              selected: 'all',
              onSelected: (_) {},
            ),
          ),
        ),
      ),
    );

    final scrollFinder = find.byType(SingleChildScrollView);
    expect(scrollFinder, findsOneWidget);

    // Drag horizontally to scroll right
    await tester.drag(scrollFinder, const Offset(-150, 0));
    await tester.pumpAndSettle();

    expect(find.text('Active Orders'), findsOneWidget);
  });
}
