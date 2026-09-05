import 'package:food_delivery_app/core/models/product_model.dart';
import 'package:food_delivery_app/features/buyer_bloc_architecture/home_Page/home_page_models.dart';

class FoodItemMapper {
  /// Converts the Core Domain [Product] into the Buyer UI [FoodItem] ViewModel.
  static FoodItem toViewModel(Product product) {
    List<String> effectiveAddons = List<String>.from(product.addons);
    if (effectiveAddons.isEmpty && product.customizationGroups.isNotEmpty) {
      for (final group in product.customizationGroups) {
        for (final opt in group.options) {
          if (opt.name.isNotEmpty) {
            final double optPrice = opt.taxablePrice > 0
                ? opt.taxablePrice
                : (opt.basePrice > 0 ? opt.basePrice : opt.price);
            if (optPrice > 0) {
              final pStr = optPrice.truncateToDouble() == optPrice
                  ? optPrice.toInt().toString()
                  : optPrice.toStringAsFixed(2);
              effectiveAddons.add('${opt.name} (+₹$pStr)');
            } else {
              effectiveAddons.add(opt.name);
            }
          }
        }
      }
    }

    return FoodItem(
      id: product.id,
      name: product.name,
      price: product.price,
      basePrice: product.basePrice,
      gstPercentage: product.gstPercentage,
      discountPrice: product.discountPrice,
      discountPercentage: product.discountPercentage,
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
      addons: effectiveAddons,
      variants: product.variants,
      customizationGroups: product.customizationGroups,
      ingredients: product.ingredients,
      allergens: product.allergens,
      taxStrategy: product.taxStrategy,
      hsnCode: product.hsnCode,
      taxType: product.taxType,
      // Map visibility based on the business logic hierarchy
      isActive: product.isActive && !product.isArchived,
      status: product.status.name,
      availableStock: product.availableStock,
      hasUnlimitedStock: product.hasUnlimitedStock,
    );
  }
}
