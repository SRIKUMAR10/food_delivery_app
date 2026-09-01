import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:food_delivery_app/features/Delivery%20Partner%20Bloc%20Architecture/delivery_image_picker_helper.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('DeliveryImagePickerHelper & DeliveryFastImage Tests', () {
    testWidgets('DeliveryFastImage renders placeholder when no image given',
        (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: DeliveryFastImage(
              imageUrl: null,
              imageBytes: null,
            ),
          ),
        ),
      );

      expect(find.byType(DeliveryFastImage), findsOneWidget);
      expect(find.byIcon(Icons.image_outlined), findsOneWidget);
    });

    testWidgets('DeliveryFastImage renders custom error widget when provided',
        (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: DeliveryFastImage(
              imageUrl: null,
              imageBytes: null,
              placeholder: Text('Custom Placeholder'),
            ),
          ),
        ),
      );

      expect(find.text('Custom Placeholder'), findsOneWidget);
    });

    testWidgets('DeliveryFastImage renders memory image when byte data is provided',
        (tester) async {
      final sampleBytes = Uint8List.fromList(List.filled(100, 0));

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DeliveryFastImage(
              imageBytes: sampleBytes,
              width: 100,
              height: 100,
            ),
          ),
        ),
      );

      expect(find.byType(DeliveryFastImage), findsOneWidget);
      expect(find.byType(Image), findsOneWidget);
    });

    testWidgets('DeliveryFastImage renders circle when isCircle is true',
        (tester) async {
      final sampleBytes = Uint8List.fromList(List.filled(50, 0));

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DeliveryFastImage(
              imageBytes: sampleBytes,
              width: 90,
              height: 90,
              isCircle: true,
            ),
          ),
        ),
      );

      expect(find.byType(ClipOval), findsOneWidget);
    });

    testWidgets(
        'DeliveryFastImage handles double.infinity width and height without throwing Unsupported operation: Infinity',
        (tester) async {
      final sampleBytes = Uint8List.fromList(List.filled(100, 0));

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 300,
              height: 200,
              child: DeliveryFastImage(
                imageBytes: sampleBytes,
                width: double.infinity,
                height: double.infinity,
                fit: BoxFit.cover,
                borderRadius: 16,
              ),
            ),
          ),
        ),
      );

      expect(find.byType(DeliveryFastImage), findsOneWidget);
      expect(find.byType(ClipRRect), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('DeliveryFastImage dynamically updates when new image bytes are supplied',
        (tester) async {
      final initialBytes = Uint8List.fromList(List.filled(60, 1));
      final updatedBytes = Uint8List.fromList(List.filled(80, 2));

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StatefulBuilder(
              builder: (context, setState) {
                return Column(
                  children: [
                    DeliveryFastImage(
                      imageBytes: initialBytes,
                      width: 120,
                      height: 120,
                    ),
                    ElevatedButton(
                      onPressed: () {},
                      child: const Text('Update Photo'),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      );

      expect(find.byType(Image), findsOneWidget);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Column(
              children: [
                DeliveryFastImage(
                  imageBytes: updatedBytes,
                  width: 120,
                  height: 120,
                ),
                ElevatedButton(
                  onPressed: () {},
                  child: const Text('Update Photo'),
                ),
              ],
            ),
          ),
        ),
      );

      expect(find.byType(Image), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });
}
