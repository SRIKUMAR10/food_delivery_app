import 'package:food_delivery_app/core/models/product_model.dart';
import 'package:food_delivery_app/features/buyer_bloc_architecture/home_Page/home_page_models.dart';

class FoodItemMapper {
  /// Converts the Core Domain [Product] into the Buyer UI [FoodItem] ViewModel.
  static FoodItem toViewModel(Product product) {
    return FoodItem(
      id: product.id,
      name: product.name,
      price: product.price,
      discountPrice: product.discountPrice,
      description: product.description,
      category: product.category,
      // Map the primary image safely
      image: product.primaryImage,
      imageUrls: product.imageUrls,
      sellerId: product.sellerId,
      foodType: product.foodType,
      isBestSeller: product.isBestSeller,
      rating: product.rating,
      reviewCount: product.reviewCount,
      spicyLevel: product.spicyLevel,
      // Convert domain integer metrics to UI presentation strings
      prepTime: product.prepTime > 0 ? '${product.prepTime} mins' : '',
      portionSize: product.portionSize,
      calories: product.calories > 0 ? '${product.calories} kcal' : '',
      addons: product.addons,
      ingredients: product.ingredients,
      // Map visibility based on the business logic hierarchy
      isActive: product.isActive && !product.isArchived,
      status: product.status.name,
    );
  }
}
