import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'add_product_page__event.dart';
import 'add_product_page__state.dart';
import '../../../../core/repositories/i_product_repository.dart';
import '../../../../core/repositories/i_seller_repository.dart';
import '../../../../core/models/product_model.dart';
import '../../../../core/services/i_auth_service.dart';

class AddProductPageBloc
    extends Bloc<AddProductPageEvent, AddProductPageState> {
  final IProductRepository repository;
  final IAuthService authService;
  final ISellerRepository sellerRepository;

  AddProductPageBloc({
    required this.repository,
    required this.authService,
    required this.sellerRepository,
  }) : super(const AddProductPageState()) {
    on<LoadProductEvent>(_onLoadProduct);
    on<AddImageEvent>(_onAddImage);
    on<RemoveImageEvent>(_onRemoveImage);
    on<RemoveExistingImageEvent>(_onRemoveExistingImage);
    on<CategoryChangedEvent>(_onCategoryChanged);
    on<SubcategoryChangedEvent>(_onSubcategoryChanged);
    on<SkuChangedEvent>(_onSkuChanged);
    on<HsnCodeChangedEvent>(_onHsnCodeChanged);
    on<GstRateChangedEvent>(_onGstRateChanged);
    on<TaxTypeChangedEvent>(_onTaxTypeChanged);
    on<VariantsUpdatedEvent>(_onVariantsUpdated);
    on<CustomizationGroupsUpdatedEvent>(_onCustomizationGroupsUpdated);
    on<StatusChangedEvent>(_onStatusChanged);
    on<FoodTypeChangedEvent>(_onFoodTypeChanged);
    on<SpicyLevelChangedEvent>(_onSpicyLevelChanged);
    on<FieldChangedEvent>(_onFieldChanged);
    on<ToggleProductTypeEvent>(_onToggleProductType);
    on<SingleInventoryChangedEvent>(_onSingleInventoryChanged);
    on<SubmitProductEvent>(_onSubmitProduct);
    on<ResetFormEvent>(_onResetForm);
    on<FetchGstPercentageEvent>(_onFetchGstPercentage);
  }

  void _onHsnCodeChanged(
    HsnCodeChangedEvent event,
    Emitter<AddProductPageState> emit,
  ) {
    emit(state.copyWith(hsnCode: event.hsnCode));
  }

  void _onGstRateChanged(
    GstRateChangedEvent event,
    Emitter<AddProductPageState> emit,
  ) {
    emit(state.copyWith(gstPercentage: event.gstPercentage));
  }

  void _onTaxTypeChanged(
    TaxTypeChangedEvent event,
    Emitter<AddProductPageState> emit,
  ) {
    emit(state.copyWith(taxType: event.taxType));
  }

  void _onToggleProductType(
    ToggleProductTypeEvent event,
    Emitter<AddProductPageState> emit,
  ) {
    emit(state.copyWith(hasVariants: event.hasVariants));
  }

  void _onSingleInventoryChanged(
    SingleInventoryChangedEvent event,
    Emitter<AddProductPageState> emit,
  ) {
    emit(state.copyWith(
      singleBasePrice: event.basePrice ?? state.singleBasePrice,
      singleDiscountPercentage:
          event.discountPercentage ?? state.singleDiscountPercentage,
      gstPercentage: event.gstPercentage ?? state.gstPercentage,
      taxType: event.taxType ?? state.taxType,
      singleStock: event.stock ?? state.singleStock,
      hasUnlimitedStock: event.hasUnlimitedStock ?? state.hasUnlimitedStock,
      minimumAlert: event.minimumAlert ?? state.minimumAlert,
    ));
  }

  Future<void> _onFetchGstPercentage(
    FetchGstPercentageEvent event,
    Emitter<AddProductPageState> emit,
  ) async {
    final userId = authService.currentUserId;
    if (userId != null) {
      try {
        final gst = await sellerRepository.getGstPercentage(userId);
        emit(state.copyWith(gstPercentage: gst > 0 ? gst : 5.0));
      } catch (_) {}
    }
  }

  void _onResetForm(ResetFormEvent event, Emitter<AddProductPageState> emit) {
    emit(const AddProductPageState());
  }

  void _onLoadProduct(
    LoadProductEvent event,
    Emitter<AddProductPageState> emit,
  ) async {
    emit(state.copyWith(status: AddProductStatus.loading));
    try {
      final product = await repository.getProduct(
        event.productId,
        authService.currentUserId ?? '',
      );
      if (product != null) {
        final hasVar = product.hasVariants || product.variants.isNotEmpty;
        emit(
          state.copyWith(
            status: AddProductStatus.initial,
            initialProduct: product,
            category: product.category,
            subcategory: product.subcategory,
            sku: product.sku,
            hsnCode: product.hsnCode.isNotEmpty ? product.hsnCode : '996331',
            taxType: product.taxType.isNotEmpty ? product.taxType : 'intraState',
            isActive: product.isActive,
            foodType: product.foodType,
            spicyLevel: product.spicyLevel,
            hasUnlimitedStock: product.hasUnlimitedStock,
            isFeatured: product.isFeatured,
            isBestSeller: product.isBestSeller,
            existingImages: product.imageUrls,
            variants: product.variants,
            customizationGroups: product.customizationGroups,
            gstPercentage: product.gstPercentage > 0 ? product.gstPercentage : 5.0,
            hasVariants: hasVar,
            singleBasePrice:
                product.basePrice > 0 ? product.basePrice : product.price,
            singleDiscountPercentage: product.discountPercentage.toDouble(),
            singleStock: product.availableStock,
            minimumAlert: product.minimumAlert,
          ),
        );
      } else {
        emit(
          state.copyWith(
            status: AddProductStatus.error,
            errorMessage: 'Product not found',
          ),
        );
      }
    } catch (e) {

      emit(
        state.copyWith(
          status: AddProductStatus.error,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  void _onAddImage(AddImageEvent event, Emitter<AddProductPageState> emit) {
    if (state.images.length < 5) {
      final updatedImages = List<XFile>.from(state.images)..add(event.image);
      emit(state.copyWith(images: updatedImages));
    }
  }

  void _onRemoveImage(
    RemoveImageEvent event,
    Emitter<AddProductPageState> emit,
  ) {
    if (event.index >= 0 && event.index < state.images.length) {
      final updatedImages = List<XFile>.from(state.images)
        ..removeAt(event.index);
      emit(state.copyWith(images: updatedImages));
    }
  }

  void _onRemoveExistingImage(
    RemoveExistingImageEvent event,
    Emitter<AddProductPageState> emit,
  ) {
    if (event.index >= 0 && event.index < state.existingImages.length) {
      final updatedImages = List<String>.from(state.existingImages)
        ..removeAt(event.index);
      emit(state.copyWith(existingImages: updatedImages));
    }
  }

  void _onCategoryChanged(
    CategoryChangedEvent event,
    Emitter<AddProductPageState> emit,
  ) {
    emit(state.copyWith(category: event.category));
  }

  void _onSubcategoryChanged(
    SubcategoryChangedEvent event,
    Emitter<AddProductPageState> emit,
  ) {
    emit(state.copyWith(subcategory: event.subcategory));
  }

  void _onSkuChanged(
    SkuChangedEvent event,
    Emitter<AddProductPageState> emit,
  ) {
    emit(state.copyWith(sku: event.sku));
  }

  void _onVariantsUpdated(
    VariantsUpdatedEvent event,
    Emitter<AddProductPageState> emit,
  ) {
    emit(state.copyWith(variants: event.variants));
  }

  void _onCustomizationGroupsUpdated(
    CustomizationGroupsUpdatedEvent event,
    Emitter<AddProductPageState> emit,
  ) {
    emit(state.copyWith(customizationGroups: event.customizationGroups));
  }

  void _onStatusChanged(
    StatusChangedEvent event,
    Emitter<AddProductPageState> emit,
  ) {
    emit(state.copyWith(isActive: event.isActive));
  }

  void _onFoodTypeChanged(
    FoodTypeChangedEvent event,
    Emitter<AddProductPageState> emit,
  ) {
    emit(state.copyWith(foodType: event.foodType));
  }

  void _onSpicyLevelChanged(
    SpicyLevelChangedEvent event,
    Emitter<AddProductPageState> emit,
  ) {
    emit(state.copyWith(spicyLevel: event.spicyLevel));
  }

  void _onFieldChanged(
    FieldChangedEvent event,
    Emitter<AddProductPageState> emit,
  ) {
    switch (event.field) {
      case 'hasUnlimitedStock':
        emit(state.copyWith(hasUnlimitedStock: event.value as bool));
        break;
      case 'isFeatured':
        emit(state.copyWith(isFeatured: event.value as bool));
        break;
      case 'isBestSeller':
        emit(state.copyWith(isBestSeller: event.value as bool));
        break;
    }
  }

  Future<void> _onSubmitProduct(
    SubmitProductEvent event,
    Emitter<AddProductPageState> emit,
  ) async {
    emit(state.copyWith(status: AddProductStatus.loading));

    try {
      final bool effectiveHasVariants = state.hasVariants;
      final List<ProductVariant> effectiveVariants = effectiveHasVariants
          ? (event.variants ?? state.variants)
          : const <ProductVariant>[];

      // Robust multi-mode validation
      if (event.name.trim().isEmpty ||
          state.category == null ||
          state.category!.trim().isEmpty ||
          (state.images.isEmpty && state.existingImages.isEmpty)) {
        emit(
          state.copyWith(
            status: AddProductStatus.error,
            errorMessage:
                'Please fill all required fields and upload at least 1 image.',
          ),
        );
        return;
      }

      if (effectiveHasVariants) {
        if (effectiveVariants.isEmpty) {
          emit(
            state.copyWith(
              status: AddProductStatus.error,
              errorMessage: 'Please add at least one size variant before publishing.',
            ),
          );
          return;
        }
        final hasInvalidVariant = effectiveVariants.any((v) => v.name.trim().isEmpty || v.basePrice <= 0);
        if (hasInvalidVariant) {
          emit(
            state.copyWith(
              status: AddProductStatus.error,
              errorMessage: 'All size variants must have a name and base price greater than ₹0.',
            ),
          );
          return;
        }
      } else {
        if (event.basePrice <= 0 && event.price <= 0) {
          emit(
            state.copyWith(
              status: AddProductStatus.error,
              errorMessage: 'Please enter a valid base price greater than ₹0.',
            ),
          );
          return;
        }
      }

      final initial = state.initialProduct;
      
      // Auto generate SKU if empty
      String effectiveSku = event.sku.isNotEmpty ? event.sku : state.sku;
      if (effectiveSku.isEmpty) {
        final catCode = (state.category ?? 'PRD')
            .toUpperCase()
            .replaceAll(RegExp(r'[^A-Z]'), '');
        final shortCat = catCode.length >= 3 ? catCode.substring(0, 3) : catCode.padRight(3, 'X');
        effectiveSku = 'SKU-$shortCat-${DateTime.now().millisecondsSinceEpoch.toString().substring(8)}';
      }

      List<String> effectiveAddons = event.addons?.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList() ?? initial?.addons ?? [];
      final effectiveGroups = event.customizationGroups ?? state.customizationGroups;
      if (effectiveAddons.isEmpty && effectiveGroups.isNotEmpty) {
        final List<String> extracted = [];
        for (final group in effectiveGroups) {
          for (final opt in group.options) {
            if (opt.name.isNotEmpty) {
              if (opt.price > 0) {
                final pStr = opt.price.truncateToDouble() == opt.price
                    ? opt.price.toInt().toString()
                    : opt.price.toStringAsFixed(2);
                extracted.add('${opt.name} (+₹$pStr)');
              } else {
                extracted.add(opt.name);
              }
            }
          }
        }
        effectiveAddons = extracted;
      }

      double effectiveBasePrice = event.basePrice;
      double effectivePrice = event.price;
      double effectiveDiscountPrice = event.discountPrice ?? 0.0;
      double effectiveDiscountPercentage = event.discountPercentage ?? state.singleDiscountPercentage;
      int effectiveStock = event.availableStock ?? state.singleStock;

      if (effectiveHasVariants && effectiveVariants.isNotEmpty) {
        effectiveBasePrice = effectiveVariants.map((v) => v.basePrice).reduce((a, b) => a < b ? a : b);
        effectivePrice = effectiveVariants.map((v) => v.finalPrice).reduce((a, b) => a < b ? a : b);
        effectiveDiscountPrice = effectiveVariants.map((v) => v.effectivePrice).reduce((a, b) => a < b ? a : b);
        effectiveDiscountPercentage = effectiveVariants.map((v) => v.discountPercentage).reduce((a, b) => a < b ? a : b);
        effectiveStock = effectiveVariants.fold<int>(0, (sum, v) => sum + (v.trackInventory ? v.stock : 999));
      }

      final productToSave = Product(
        id: initial?.id ?? '',
        name: event.name.trim(),
        sku: effectiveSku,
        price: effectivePrice,
        basePrice: effectiveBasePrice,
        gstPercentage: event.gstPercentage,
        discountPrice: effectiveDiscountPrice,
        discountPercentage: effectiveDiscountPercentage,
        description: event.description,
        prepTime: int.tryParse(event.prepTime ?? '') ?? initial?.prepTime ?? 0,
        calories: int.tryParse(event.calories ?? '') ?? initial?.calories ?? 0,
        portionSize: event.portionSize ?? '',
        addons: effectiveAddons,
        ingredients: event.ingredients?.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList() ?? initial?.ingredients ?? [],
        variants: effectiveVariants,
        hasVariants: effectiveHasVariants,
        customizationGroups: effectiveGroups,
        category: state.category ?? '',
        subcategory: event.subcategory ?? state.subcategory ?? '',
        foodType: state.foodType ?? '',
        spicyLevel: state.spicyLevel ?? '',
        isActive: state.isActive,
        isFeatured: state.isFeatured,
        isBestSeller: state.isBestSeller,
        hasUnlimitedStock: effectiveHasVariants ? effectiveVariants.every((v) => !v.trackInventory) : state.hasUnlimitedStock,
        status: initial?.status ?? (effectiveStock <= 0 && !state.hasUnlimitedStock ? ProductStatus.outOfStock : ProductStatus.inStock),
        rating: initial?.rating ?? 0.0,
        reviewCount: initial?.reviewCount ?? 0,
        salesCount: initial?.salesCount ?? 0,
        availableStock: effectiveStock,
        createdAt: initial?.createdAt ?? DateTime.now(),
        updatedAt: DateTime.now(),
        minimumAlert: event.minimumAlert ?? initial?.minimumAlert ?? 10,
        sellerId: initial?.sellerId ?? '',
        isArchived: initial?.isArchived ?? false,
        hsnCode: event.hsnCode.isNotEmpty ? event.hsnCode : state.hsnCode,
        taxType: event.taxType.isNotEmpty ? event.taxType : state.taxType,
      );



      final effectiveSellerId = (authService.currentUserId != null && authService.currentUserId!.isNotEmpty)
          ? authService.currentUserId!
          : (initial?.sellerId != null && initial!.sellerId.isNotEmpty ? initial.sellerId : '');

      if (effectiveSellerId.isEmpty) {
        emit(
          state.copyWith(
            status: AddProductStatus.error,
            errorMessage: 'User not authenticated. Please log in.',
          ),
        );
        return;
      }

      if (initial != null) {
        await repository.updateProduct(productToSave, state.images, effectiveSellerId, existingImages: state.existingImages);
      } else {
        await repository.addProduct(productToSave, state.images, effectiveSellerId);
      }

      emit(state.copyWith(status: AddProductStatus.success));
    } catch (e) {
      emit(
        state.copyWith(
          status: AddProductStatus.error,
          errorMessage: e.toString(),
        ),
      );
    }
  }
}
