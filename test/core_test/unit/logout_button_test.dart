import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:food_delivery_app/core/widgets/logout_button.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('LogoutButton', () {
    testWidgets('renders label and icon and fires onPressed', (tester) async {
      var tapped = false;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: LogoutButton(
              label: 'Sign Out',
              onPressed: () => tapped = true,
            ),
          ),
        ),
      );

      expect(find.text('Sign Out'), findsOneWidget);
      expect(find.byIcon(Icons.logout), findsOneWidget);

      await tester.tap(find.text('Sign Out'));
      expect(tapped, isTrue);
    });
  });

  group('showLogoutConfirmDialog', () {
    testWidgets('confirm triggers onConfirm and returns true', (tester) async {
      var confirmed = false;
      var onConfirmCalled = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => Center(
                child: ElevatedButton(
                  onPressed: () async {
                    confirmed = await showLogoutConfirmDialog(
                      context,
                      title: 'Leave?',
                      message: 'Really leave?',
                      confirmLabel: 'Yes',
                      onConfirm: () async => onConfirmCalled = true,
                    );
                  },
                  child: const Text('open'),
                ),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();

      expect(find.text('Leave?'), findsOneWidget);
      expect(find.text('Really leave?'), findsOneWidget);

      await tester.tap(find.text('Yes'));
      await tester.pumpAndSettle();

      expect(confirmed, isTrue);
      expect(onConfirmCalled, isTrue);
      expect(find.text('Leave?'), findsNothing);
    });

    testWidgets('cancel does not trigger onConfirm and returns false',
        (tester) async {
      var confirmed = true;
      var onConfirmCalled = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => Center(
                child: ElevatedButton(
                  onPressed: () async {
                    confirmed = await showLogoutConfirmDialog(
                      context,
                      onConfirm: () async => onConfirmCalled = true,
                    );
                  },
                  child: const Text('open'),
                ),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();

      expect(find.text('Logout'), findsWidgets);

      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();

      expect(confirmed, isFalse);
      expect(onConfirmCalled, isFalse);
    });

    testWidgets('applies theme colors and button keys', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => Center(
                child: ElevatedButton(
                  onPressed: () {
                    showLogoutConfirmDialog(
                      context,
                      title: 'Log Out',
                      confirmLabel: 'Confirm',
                      confirmColor: Colors.amber,
                      confirmForegroundColor: Colors.black,
                      confirmButtonKey: 'custom_confirm_btn',
                      cancelButtonKey: 'custom_cancel_btn',
                      onConfirm: () async {},
                    );
                  },
                  child: const Text('open'),
                ),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('custom_confirm_btn')), findsOneWidget);
      expect(find.byKey(const Key('custom_cancel_btn')), findsOneWidget);

      final confirmButton = tester.widget<ElevatedButton>(
        find.byKey(const Key('custom_confirm_btn')),
      );
      final style = confirmButton.style;
      expect(style?.backgroundColor?.resolve({}), Colors.amber);
      expect(style?.foregroundColor?.resolve({}), Colors.black);
    });
  });
}