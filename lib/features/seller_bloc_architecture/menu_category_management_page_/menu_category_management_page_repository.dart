import 'menu_category_management_page_model.dart';
import 'menu_category_management_page_service.dart';

class MenuCategoryManagementRepository {
  final MenuCategoryManagementService service;

  MenuCategoryManagementRepository({required this.service});

  Future<List<MenuCategoryModel>> getMenuCategories(String sellerId) {
    return service.fetchAllGlobalCategories(sellerId);
  }

  Future<void> savePreferences(String sellerId, List<MenuCategoryModel> categories) {
    return service.saveSellerCategoryPreferences(sellerId, categories);
  }
}
