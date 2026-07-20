import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('debug test', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: const Text('Status: initial'),
        ),
      ),
    );
    await tester.pump();
    expect(find.text('Status: initial'), findsOneWidget);
  });
}
