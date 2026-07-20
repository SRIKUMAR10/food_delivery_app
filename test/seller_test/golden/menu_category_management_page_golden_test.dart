import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mocktail/mocktail.dart';
import 'package:golden_toolkit/golden_toolkit.dart';
import 'package:food_delivery_app/features/seller_bloc_architecture/menu_category_management_page_/menu_category_management_page_bloc.dart';
import 'package:food_delivery_app/features/seller_bloc_architecture/menu_category_management_page_/menu_category_management_page_state.dart';
import 'package:food_delivery_app/features/seller_bloc_architecture/menu_category_management_page_/menu_category_management_page_ui.dart';

class MockMenuCategoryManagementBloc extends Mock implements MenuCategoryManagementBloc {}

void main() {
  group('MenuCategoryManagementPage Golden Tests', () {
    late MockMenuCategoryManagementBloc mockBloc;

    setUp(() async {
      mockBloc = MockMenuCategoryManagementBloc();
      when(() => mockBloc.stream).thenAnswer((_) => const Stream.empty());
      when(() => mockBloc.close()).thenAnswer((_) async {});
    });

    testGoldens('Menu Categories layout matches golden file', (tester) async {
      await loadAppFonts();

      when(() => mockBloc.state).thenReturn(MenuCategoryManagementLoaded(categories: []));

      final builder = DeviceBuilder()
        ..overrideDevicesForAllScenarios(devices: [Device.phone, Device.iphone11])
        ..addScenario(
          name: 'Menu Categories Empty State',
          widget: MaterialApp(
            debugShowCheckedModeBanner: false,
            home: BlocProvider<MenuCategoryManagementBloc>.value(
              value: mockBloc,
              child: const MenuCategoryManagementView(sellerId: 'test'),
            ),
          ),
        );

      await tester.pumpDeviceBuilder(builder);
      await screenMatchesGolden(tester, 'menu_category_management_page_golden');
    });
  });
}
