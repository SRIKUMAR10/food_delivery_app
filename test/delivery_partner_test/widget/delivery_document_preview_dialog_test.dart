import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:food_delivery_app/features/Delivery%20Partner%20Bloc%20Architecture/delivery_document_preview_dialog.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('DeliveryDocumentPreviewDialog Widget Tests', () {
    testWidgets('renders dialog with title and verified badge', (tester) async {
      final dummyBytes = Uint8List.fromList(List.filled(100, 0));

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () => DeliveryDocumentPreviewDialog.show(
                  context: context,
                  title: 'Driving License Front',
                  documentBytes: dummyBytes,
                  status: 'verified',
                ),
                child: const Text('Open Dialog'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Open Dialog'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.byType(DeliveryDocumentPreviewDialog), findsOneWidget);
      expect(find.text('Driving License Front'), findsOneWidget);
      expect(find.text('VERIFIED KYC DOCUMENT'), findsOneWidget);
      expect(find.byType(InteractiveViewer), findsOneWidget);
      expect(find.text('Done'), findsOneWidget);
    });

    testWidgets('renders dialog with byte image data and reupload trigger',
        (tester) async {
      bool reuploadTriggered = false;
      final dummyBytes = Uint8List.fromList(List.filled(100, 0));

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () => DeliveryDocumentPreviewDialog.show(
                  context: context,
                  title: 'PAN Card Document',
                  documentBytes: dummyBytes,
                  status: 'uploaded',
                  onReupload: () => reuploadTriggered = true,
                ),
                child: const Text('Open PAN'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Open PAN'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.text('PAN Card Document'), findsOneWidget);
      expect(find.text('OFFICIAL DOCUMENT PROOF'), findsOneWidget);
      expect(find.text('Change'), findsOneWidget);

      await tester.tap(find.text('Change'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(reuploadTriggered, isTrue);
    });

    testWidgets('dismisses dialog when Done button is pressed', (tester) async {
      final dummyBytes = Uint8List.fromList(List.filled(100, 0));

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () => DeliveryDocumentPreviewDialog.show(
                  context: context,
                  title: 'Vehicle RC Book',
                  documentBytes: dummyBytes,
                ),
                child: const Text('Open RC'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Open RC'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.byType(DeliveryDocumentPreviewDialog), findsOneWidget);

      await tester.tap(find.text('Done'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.byType(DeliveryDocumentPreviewDialog), findsNothing);
    });
  });
}
