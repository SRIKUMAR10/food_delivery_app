import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:food_delivery_app/features/seller_bloc_architecture/menu_category_management_page_/menu_category_management_page_repository.dart';
import 'package:food_delivery_app/features/seller_bloc_architecture/menu_category_management_page_/menu_category_management_page_service.dart';

class MockMenuCategoryManagementService extends Mock implements MenuCategoryManagementService {}

void main() {
  group('MenuCategoryManagementRepository', () {
    late MenuCategoryManagementRepository repository;
    late MockMenuCategoryManagementService mockService;

    setUp(() {
      mockService = MockMenuCategoryManagementService();
      repository = MenuCategoryManagementRepository(service: mockService);
    });

    test('getMenuCategories calls service', () async {
      when(() => mockService.fetchAllGlobalCategories(any())).thenAnswer((_) async => []);
      await repository.getMenuCategories('seller1');
      verify(() => mockService.fetchAllGlobalCategories('seller1')).called(1);
    });
  });
}
