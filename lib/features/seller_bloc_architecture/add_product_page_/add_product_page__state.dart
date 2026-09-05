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
  final String hsnCode;
  final String taxType;
  final bool hasVariants;
  final double singleBasePrice;
  final double singleDiscountPercentage;
  final int singleStock;
  final int minimumAlert;

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
    this.gstPercentage = 5.0,
    this.hsnCode = '996331',
    this.taxType = 'intraState',
    this.hasVariants = false,
    this.singleBasePrice = 0.0,
    this.singleDiscountPercentage = 0.0,
    this.singleStock = 0,
    this.minimumAlert = 10,
  });

  /// Effective total stock across all variants or single stock
  int get effectiveTotalStock {
    if (hasVariants && variants.isNotEmpty) {
      return variants.fold<int>(
        0,
        (sum, v) => sum + (v.trackInventory ? v.stock : 999),
      );
    }
    return hasUnlimitedStock ? 999999 : singleStock;
  }

  /// Tax Classification & Percentage Getters
  bool get isInterStateTax => taxType == 'interState';
  double get cgstPercentage => taxType == 'interState' ? 0.0 : gstPercentage / 2.0;
  double get sgstPercentage => taxType == 'interState' ? 0.0 : gstPercentage / 2.0;
  double get igstPercentage => taxType == 'interState' ? gstPercentage : 0.0;

  /// Live Single Item Calculation Getters
  double get singleDiscountAmount =>
      singleBasePrice * (singleDiscountPercentage / 100.0);

  double get singleTaxablePrice =>
      (singleBasePrice - singleDiscountAmount).clamp(0.0, double.infinity);

  double get singleCgstAmount => taxType == 'interState'
      ? 0.0
      : ((singleTaxablePrice * (cgstPercentage / 100.0)) * 100).roundToDouble() /
          100.0;

  double get singleSgstAmount => taxType == 'interState'
      ? 0.0
      : ((singleTaxablePrice * (sgstPercentage / 100.0)) * 100).roundToDouble() /
          100.0;

  double get singleIgstAmount => taxType == 'interState'
      ? ((singleTaxablePrice * (igstPercentage / 100.0)) * 100).roundToDouble() /
          100.0
      : 0.0;

  double get singleGstAmount =>
      taxType == 'interState' ? singleIgstAmount : (singleCgstAmount + singleSgstAmount);

  double get cgstAmount => singleCgstAmount;
  double get sgstAmount => singleSgstAmount;
  double get igstAmount => singleIgstAmount;
  double get gstAmount => singleGstAmount;

  double get singleFinalPrice =>
      (singleTaxablePrice + singleGstAmount).roundToDouble();

  double get singleRoundOff =>
      singleFinalPrice - (singleTaxablePrice + singleGstAmount);

  /// Live Minimum and Maximum Price for Range display
  (double min, double max, bool isRange) get computedPriceRange {
    if (hasVariants && variants.isNotEmpty) {
      final active = variants.where((v) => v.isAvailable).toList();
      final list = active.isNotEmpty ? active : variants;
      double min = double.infinity;
      double max = 0.0;
      for (final v in list) {
        final p = v.effectivePrice;
        if (p < min) min = p;
        if (p > max) max = p;
      }
      if (min == double.infinity) min = singleFinalPrice;
      if (max <= 0.0) max = singleFinalPrice;
      return (min, max, (max - min).abs() > 0.01);
    }
    return (singleFinalPrice, singleFinalPrice, false);
  }

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
    String? hsnCode,
    String? taxType,
    bool? hasVariants,
    double? singleBasePrice,
    double? singleDiscountPercentage,
    int? singleStock,
    int? minimumAlert,
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
      hsnCode: hsnCode ?? this.hsnCode,
      taxType: taxType ?? this.taxType,
      hasVariants: hasVariants ?? this.hasVariants,
      singleBasePrice: singleBasePrice ?? this.singleBasePrice,
      singleDiscountPercentage:
          singleDiscountPercentage ?? this.singleDiscountPercentage,
      singleStock: singleStock ?? this.singleStock,
      minimumAlert: minimumAlert ?? this.minimumAlert,
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
    hsnCode,
    taxType,
    hasVariants,
    singleBasePrice,
    singleDiscountPercentage,
    singleStock,
    minimumAlert,
  ];
}

