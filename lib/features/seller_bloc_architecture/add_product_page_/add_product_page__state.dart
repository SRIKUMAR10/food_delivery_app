import 'package:equatable/equatable.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/models/product_model.dart';

enum AddProductStatus { initial, loading, success, error }

class AddProductPageState extends Equatable {
  final AddProductStatus status;
  final List<XFile> images;
  final String? category;
  final String? subcategory;
  final String sku;
  final bool isActive;
  final String? errorMessage;
  final int currentStep;
  final DateTime? lastSavedAt;
  final String? foodType;
  final String? spicyLevel;
  final bool hasUnlimitedStock;
  final bool isFeatured;
  final bool isBestSeller;
  final Product? initialProduct;
  final List<String> existingImages;
  final List<ProductVariant> variants;
  final List<ProductCustomizationGroup> customizationGroups;
  final double gstPercentage;

  const AddProductPageState({
    this.status = AddProductStatus.initial,
    this.images = const [],
    this.category,
    this.subcategory,
    this.sku = '',
    this.isActive = true,
    this.errorMessage,
    this.currentStep = 0,
    this.lastSavedAt,
    this.foodType,
    this.spicyLevel,
    this.hasUnlimitedStock = false,
    this.isFeatured = false,
    this.isBestSeller = false,
    this.initialProduct,
    this.existingImages = const [],
    this.variants = const [],
    this.customizationGroups = const [],
    this.gstPercentage = 0.0,
  });

  AddProductPageState copyWith({
    AddProductStatus? status,
    List<XFile>? images,
    String? category,
    String? subcategory,
    String? sku,
    bool? isActive,
    String? errorMessage,
    int? currentStep,
    DateTime? lastSavedAt,
    String? foodType,
    String? spicyLevel,
    bool? hasUnlimitedStock,
    bool? isFeatured,
    bool? isBestSeller,
    Product? initialProduct,
    List<String>? existingImages,
    List<ProductVariant>? variants,
    List<ProductCustomizationGroup>? customizationGroups,
    double? gstPercentage,
  }) {
    return AddProductPageState(
      status: status ?? this.status,
      images: images ?? this.images,
      category: category ?? this.category,
      subcategory: subcategory ?? this.subcategory,
      sku: sku ?? this.sku,
      isActive: isActive ?? this.isActive,
      errorMessage: errorMessage ?? this.errorMessage,
      currentStep: currentStep ?? this.currentStep,
      lastSavedAt: lastSavedAt ?? this.lastSavedAt,
      foodType: foodType ?? this.foodType,
      spicyLevel: spicyLevel ?? this.spicyLevel,
      hasUnlimitedStock: hasUnlimitedStock ?? this.hasUnlimitedStock,
      isFeatured: isFeatured ?? this.isFeatured,
      isBestSeller: isBestSeller ?? this.isBestSeller,
      initialProduct: initialProduct ?? this.initialProduct,
      existingImages: existingImages ?? this.existingImages,
      variants: variants ?? this.variants,
      customizationGroups: customizationGroups ?? this.customizationGroups,
      gstPercentage: gstPercentage ?? this.gstPercentage,
    );
  }

  @override
  List<Object?> get props => [
    status,
    images,
    category,
    subcategory,
    sku,
    isActive,
    errorMessage,
    currentStep,
    lastSavedAt,
    foodType,
    spicyLevel,
    hasUnlimitedStock,
    isFeatured,
    isBestSeller,
    initialProduct,
    existingImages,
    variants,
    customizationGroups,
    gstPercentage,
  ];
}
