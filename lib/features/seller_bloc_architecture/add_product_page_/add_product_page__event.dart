import 'package:equatable/equatable.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/models/product_model.dart';

abstract class AddProductPageEvent extends Equatable {
  const AddProductPageEvent();

  @override
  List<Object?> get props => [];
}

class LoadProductEvent extends AddProductPageEvent {
  final String productId;
  const LoadProductEvent(this.productId);

  @override
  List<Object?> get props => [productId];
}

class AddImageEvent extends AddProductPageEvent {
  final XFile image;
  const AddImageEvent(this.image);

  @override
  List<Object?> get props => [image];
}

class RemoveImageEvent extends AddProductPageEvent {
  final int index;
  const RemoveImageEvent(this.index);

  @override
  List<Object?> get props => [index];
}

class RemoveExistingImageEvent extends AddProductPageEvent {
  final int index;
  const RemoveExistingImageEvent(this.index);

  @override
  List<Object?> get props => [index];
}

class CategoryChangedEvent extends AddProductPageEvent {
  final String category;
  const CategoryChangedEvent(this.category);

  @override
  List<Object?> get props => [category];
}

class SubcategoryChangedEvent extends AddProductPageEvent {
  final String subcategory;
  const SubcategoryChangedEvent(this.subcategory);

  @override
  List<Object?> get props => [subcategory];
}

class SkuChangedEvent extends AddProductPageEvent {
  final String sku;
  const SkuChangedEvent(this.sku);

  @override
  List<Object?> get props => [sku];
}

class VariantsUpdatedEvent extends AddProductPageEvent {
  final List<ProductVariant> variants;
  const VariantsUpdatedEvent(this.variants);

  @override
  List<Object?> get props => [variants];
}

class CustomizationGroupsUpdatedEvent extends AddProductPageEvent {
  final List<ProductCustomizationGroup> customizationGroups;
  const CustomizationGroupsUpdatedEvent(this.customizationGroups);

  @override
  List<Object?> get props => [customizationGroups];
}

class StatusChangedEvent extends AddProductPageEvent {
  final bool isActive;
  const StatusChangedEvent(this.isActive);

  @override
  List<Object?> get props => [isActive];
}

class FoodTypeChangedEvent extends AddProductPageEvent {
  final String foodType;
  const FoodTypeChangedEvent(this.foodType);

  @override
  List<Object?> get props => [foodType];
}

class SpicyLevelChangedEvent extends AddProductPageEvent {
  final String spicyLevel;
  const SpicyLevelChangedEvent(this.spicyLevel);

  @override
  List<Object?> get props => [spicyLevel];
}

class FieldChangedEvent extends AddProductPageEvent {
  final String field;
  final dynamic value;
  const FieldChangedEvent(this.field, this.value);

  @override
  List<Object?> get props => [field, value];
}

class HsnCodeChangedEvent extends AddProductPageEvent {
  final String hsnCode;
  const HsnCodeChangedEvent(this.hsnCode);

  @override
  List<Object?> get props => [hsnCode];
}

class GstRateChangedEvent extends AddProductPageEvent {
  final double gstPercentage;
  const GstRateChangedEvent(this.gstPercentage);

  @override
  List<Object?> get props => [gstPercentage];
}

class TaxTypeChangedEvent extends AddProductPageEvent {
  final String taxType;
  const TaxTypeChangedEvent(this.taxType);

  @override
  List<Object?> get props => [taxType];
}

class SubmitProductEvent extends AddProductPageEvent {
  final String name;
  final String sku;
  final String hsnCode;
  final String taxType;
  final double price; // GST-inclusive
  final double basePrice;
  final double gstPercentage;
  final double? discountPrice;
  final double? discountPercentage;
  final String description;
  final String? prepTime;
  final String? portionSize;
  final String? addons;
  final String? ingredients;
  final String? calories;
  final int? availableStock;
  final int? minimumAlert;
  final String? subcategory;
  final List<ProductVariant>? variants;
  final List<ProductCustomizationGroup>? customizationGroups;

  const SubmitProductEvent({
    required this.name,
    this.sku = '',
    this.hsnCode = '996331',
    this.taxType = 'intraState',
    required this.price,
    required this.basePrice,
    required this.gstPercentage,
    this.discountPrice,
    this.discountPercentage,
    required this.description,
    this.prepTime,
    this.portionSize,
    this.addons,
    this.ingredients,
    this.calories,
    this.availableStock,
    this.minimumAlert,
    this.subcategory,
    this.variants,
    this.customizationGroups,
  });

  @override
  List<Object?> get props => [
    name,
    sku,
    hsnCode,
    taxType,
    price,
    basePrice,
    gstPercentage,
    discountPrice,
    discountPercentage,
    description,
    prepTime,
    portionSize,
    addons,
    ingredients,
    calories,
    availableStock,
    minimumAlert,
    subcategory,
    variants,
    customizationGroups,
  ];
}

class ToggleProductTypeEvent extends AddProductPageEvent {
  final bool hasVariants;
  const ToggleProductTypeEvent(this.hasVariants);

  @override
  List<Object?> get props => [hasVariants];
}

class SingleInventoryChangedEvent extends AddProductPageEvent {
  final double? basePrice;
  final double? discountPercentage;
  final double? gstPercentage;
  final String? taxType;
  final int? stock;
  final bool? hasUnlimitedStock;
  final int? minimumAlert;

  const SingleInventoryChangedEvent({
    this.basePrice,
    this.discountPercentage,
    this.gstPercentage,
    this.taxType,
    this.stock,
    this.hasUnlimitedStock,
    this.minimumAlert,
  });

  @override
  List<Object?> get props => [
    basePrice,
    discountPercentage,
    gstPercentage,
    taxType,
    stock,
    hasUnlimitedStock,
    minimumAlert,
  ];
}

class ResetFormEvent extends AddProductPageEvent {}

class FetchGstPercentageEvent extends AddProductPageEvent {}

