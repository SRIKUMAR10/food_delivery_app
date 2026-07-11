import 'package:equatable/equatable.dart';

enum AddProductStatus { initial, loading, success, error }

class AddProductPageState extends Equatable {
  final AddProductStatus status;
  final int currentStep;
  final List<String> images;
  final String? category;
  final String? foodType;
  final String? spicyLevel;
  
  // Toggles
  final bool isActive;
  final bool isFeatured;
  final bool isBestSeller;
  final bool hasUnlimitedStock;

  // Real-time fields for live preview and auto-save
  final String name;
  final double price;
  final double originalPrice;
  final double discountPercent;
  final String description;
  final int availableStock;
  final int minimumAlert;
  
  final DateTime? lastSavedAt;
  final String? errorMessage;

  const AddProductPageState({
    this.status = AddProductStatus.initial,
    this.currentStep = 0,
    this.images = const [],
    this.category,
    this.foodType,
    this.spicyLevel,
    this.isActive = true,
    this.isFeatured = false,
    this.isBestSeller = false,
    this.hasUnlimitedStock = false,
    this.name = '',
    this.price = 0.0,
    this.originalPrice = 0.0,
    this.discountPercent = 0.0,
    this.description = '',
    this.availableStock = 0,
    this.minimumAlert = 10,
    this.lastSavedAt,
    this.errorMessage,
  });

  AddProductPageState copyWith({
    AddProductStatus? status,
    int? currentStep,
    List<String>? images,
    String? category,
    String? foodType,
    String? spicyLevel,
    bool? isActive,
    bool? isFeatured,
    bool? isBestSeller,
    bool? hasUnlimitedStock,
    String? name,
    double? price,
    double? originalPrice,
    double? discountPercent,
    String? description,
    int? availableStock,
    int? minimumAlert,
    DateTime? lastSavedAt,
    String? errorMessage,
  }) {
    return AddProductPageState(
      status: status ?? this.status,
      currentStep: currentStep ?? this.currentStep,
      images: images ?? this.images,
      category: category ?? this.category,
      foodType: foodType ?? this.foodType,
      spicyLevel: spicyLevel ?? this.spicyLevel,
      isActive: isActive ?? this.isActive,
      isFeatured: isFeatured ?? this.isFeatured,
      isBestSeller: isBestSeller ?? this.isBestSeller,
      hasUnlimitedStock: hasUnlimitedStock ?? this.hasUnlimitedStock,
      name: name ?? this.name,
      price: price ?? this.price,
      originalPrice: originalPrice ?? this.originalPrice,
      discountPercent: discountPercent ?? this.discountPercent,
      description: description ?? this.description,
      availableStock: availableStock ?? this.availableStock,
      minimumAlert: minimumAlert ?? this.minimumAlert,
      lastSavedAt: lastSavedAt ?? this.lastSavedAt,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [
        status, currentStep, images, category, foodType, spicyLevel,
        isActive, isFeatured, isBestSeller, hasUnlimitedStock,
        name, price, originalPrice, discountPercent, description,
        availableStock, minimumAlert, lastSavedAt, errorMessage,
      ];
}
