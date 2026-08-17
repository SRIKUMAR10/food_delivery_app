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

class SubmitProductEvent extends AddProductPageEvent {
  final String name;
  final String sku;
  final double price; // GST-inclusive
  final double basePrice;
  final double gstPercentage;
  final double? discountPrice;
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
    required this.price,
    required this.basePrice,
    required this.gstPercentage,
    this.discountPrice,
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
    price,
    basePrice,
    gstPercentage,
    discountPrice,
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

class ResetFormEvent extends AddProductPageEvent {}

class FetchGstPercentageEvent extends AddProductPageEvent {}
