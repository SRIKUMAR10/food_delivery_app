import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:food_delivery_app/features/seller_bloc_architecture/seller_setting_page/seller_setting_page__bloc.dart';
import 'package:food_delivery_app/features/seller_bloc_architecture/seller_setting_page/seller_setting_page__event.dart';
import 'package:food_delivery_app/features/seller_bloc_architecture/seller_setting_page/seller_setting_page__state.dart';
import 'package:food_delivery_app/features/seller_bloc_architecture/seller_setting_page/seller_setting_page__ui.dart';

class MockSellerSettingBloc extends MockBloc<SellerSettingEvent, SellerSettingState> implements SellerSettingBloc {}

void main() {
  setUpAll(() {
    registerFallbackValue(const SellerSettingState());
  });

  group('SellerSettingPage UI', () {
    late MockSellerSettingBloc mockBloc;

    setUp(() {
      mockBloc = MockSellerSettingBloc();
    });

    testWidgets('renders loading state correctly', (WidgetTester tester) async {
      when(() => mockBloc.state).thenReturn(const SellerSettingState(isLoading: true));

      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider<SellerSettingBloc>.value(
            value: mockBloc,
            child: const SellerSettingPage(),
          ),
        ),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('renders settings list correctly', (WidgetTester tester) async {
      when(() => mockBloc.state).thenReturn(const SellerSettingState());

      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider<SellerSettingBloc>.value(
            value: mockBloc,
            child: const SellerSettingPage(),
          ),
        ),
      );

      expect(find.text('Settings'), findsWidgets);
      expect(find.text('Push Notifications'), findsOneWidget);
      expect(find.text('New Order Sound'), findsOneWidget);
      expect(find.text('Promo & Offers'), findsOneWidget);
      expect(find.text('Low Stock Alerts'), findsOneWidget);
      expect(find.text('Order Updates'), findsOneWidget);
      
      expect(find.text('App Theme'), findsOneWidget);
      expect(find.text('Language'), findsOneWidget);
    });
  });
}
