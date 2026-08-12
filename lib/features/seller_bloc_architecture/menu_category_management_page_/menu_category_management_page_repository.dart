// Real-Time Firestore Stream Provider Standardized
import 'menu_category_management_page_model.dart';
import 'menu_category_management_page_service.dart';

class MenuCategoryManagementRepository {
  final MenuCategoryManagementService service;

  MenuCategoryManagementRepository({required this.service});

  Stream<List<MenuCategoryModel>> streamMenuCategories(String sellerId) {
    return service.streamAllGlobalCategories(sellerId);
  }

  Future<List<MenuCategoryModel>> getMenuCategories(String sellerId) {
    return service.fetchAllGlobalCategories(sellerId);
  }

  Future<void> savePreferences(String sellerId, List<MenuCategoryModel> categories) {
    return service.saveSellerCategoryPreferences(sellerId, categories);
  }
}
