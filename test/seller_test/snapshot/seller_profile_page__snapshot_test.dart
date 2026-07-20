import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mocktail/mocktail.dart';
import 'package:food_delivery_app/features/seller_bloc_architecture/seller_profile_page/seller_profile_page__ui.dart';
import 'package:food_delivery_app/features/seller_bloc_architecture/seller_profile_page/seller_profile_page__bloc.dart';
import 'package:food_delivery_app/features/seller_bloc_architecture/seller_profile_page/seller_profile_page__state.dart';

class MockSellerProfilePageBloc extends Mock implements SellerProfilePageBloc {}

final _validPng = base64Decode(
  'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mNkYPj/HwADBwIAMCbHYQAAAABJRU5ErkJggg==',
);

void main() {
  late MockSellerProfilePageBloc mockBloc;

  setUp(() {
    mockBloc = MockSellerProfilePageBloc();
    when(() => mockBloc.stream).thenAnswer((_) => const Stream.empty());
    when(() => mockBloc.close()).thenAnswer((_) async {});
    when(() => mockBloc.state).thenReturn(ProfileLoaded(
      storeName: 'Test Store',
      email: 'test@store.com',
      phone: '+91 9876543210',
      profileImageUrl: 'https://example.com/img.jpg',
      notificationsEnabled: true,
      role: 'seller',
      createdAt: DateTime(2024, 1, 1),
      isVerified: true,
      localImageBytes: _validPng,
    ));
  });

  testWidgets('SellerProfilePageUI snapshot test', (WidgetTester tester) async {
    await tester.binding.setSurfaceSize(const Size(1200, 2000));

    await tester.pumpWidget(
      MaterialApp(
        home: BlocProvider<SellerProfilePageBloc>.value(
          value: mockBloc,
          child: const ProfileContent(),
        ),
      ),
    );
    await tester.pumpAndSettle(const Duration(seconds: 2));

    expect(find.byIcon(Icons.account_balance_wallet_outlined), findsOneWidget);
    expect(find.byIcon(Icons.account_balance_outlined), findsOneWidget);
    expect(find.byIcon(Icons.lock_outline), findsOneWidget);
    expect(find.byIcon(Icons.notifications_none_outlined), findsOneWidget);
    expect(find.byIcon(Icons.logout), findsOneWidget);
  });
}
