import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'add_product_page__event.dart';
import 'add_product_page__state.dart';
import '../../../../core/repositories/i_product_repository.dart';
import '../../../../core/models/product_model.dart';
import '../../../../core/services/i_auth_service.dart';

class AddProductPageBloc
    extends Bloc<AddProductPageEvent, AddProductPageState> {
  final IProductRepository repository;
  final IAuthService authService;

  AddProductPageBloc({required this.repository, required this.authService}) : super(const AddProductPageState()) {
    on<LoadProductEvent>(_onLoadProduct);
    on<AddImageEvent>(_onAddImage);
    on<RemoveImageEvent>(_onRemoveImage);
    on<RemoveExistingImageEvent>(_onRemoveExistingImage);
    on<CategoryChangedEvent>(_onCategoryChanged);
    on<StatusChangedEvent>(_onStatusChanged);
    on<FoodTypeChangedEvent>(_onFoodTypeChanged);
    on<SpicyLevelChangedEvent>(_onSpicyLevelChanged);
    on<FieldChangedEvent>(_onFieldChanged);
    on<SubmitProductEvent>(_onSubmitProduct);
  }

  void _onLoadProduct(LoadProductEvent event, Emitter<AddProductPageState> emit) async {
    emit(state.copyWith(status: AddProductStatus.loading));
    try {
      final product = await repository.getProduct(event.productId, authService.currentUserId ?? '');
      if (product != null) {
        emit(state.copyWith(
          status: AddProductStatus.initial,
          initialProduct: product,
          category: product.category,
          isActive: product.isActive,
          foodType: product.foodType,
          spicyLevel: product.spicyLevel,
          hasUnlimitedStock: product.hasUnlimitedStock,
          isFeatured: product.isFeatured,
          isBestSeller: product.isBestSeller,
          existingImages: product.imageUrls,
        ));
      } else {
        emit(state.copyWith(status: AddProductStatus.error, errorMessage: 'Product not found'));
      }
    } catch (e) {
      emit(state.copyWith(status: AddProductStatus.error, errorMessage: e.toString()));
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
      // Basic validation
      if (event.name.isEmpty ||
          event.price <= 0 ||
          state.category == null ||
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

      final initial = state.initialProduct;
      final productToSave = Product(
        id: initial?.id ?? '',
        name: event.name,
        price: event.price,
        discountPrice: event.discountPrice ?? 0.0,
        description: event.description,
        prepTime: int.tryParse(event.prepTime ?? '') ?? initial?.prepTime ?? 0,
        calories: int.tryParse(event.calories ?? '') ?? initial?.calories ?? 0,
        portionSize: event.portionSize ?? '',
        addons: event.addons?.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList() ?? [],
        category: state.category ?? '',
        foodType: state.foodType ?? '',
        spicyLevel: state.spicyLevel ?? '',
        isActive: state.isActive,
        isFeatured: state.isFeatured,
        isBestSeller: state.isBestSeller,
        hasUnlimitedStock: state.hasUnlimitedStock,
        status: initial?.status ?? ProductStatus.inStock,
        rating: initial?.rating ?? 0.0,
        reviewCount: initial?.reviewCount ?? 0,
        salesCount: initial?.salesCount ?? 0,
        availableStock: event.availableStock ?? initial?.availableStock ?? 0,
        createdAt: initial?.createdAt ?? DateTime.now(),
        updatedAt: DateTime.now(),
        minimumAlert: event.minimumAlert ?? initial?.minimumAlert ?? 10,
        sellerId: initial?.sellerId ?? '',
        isArchived: initial?.isArchived ?? false,
      );

      if (initial != null) {
        await repository.updateProduct(productToSave, state.images, authService.currentUserId ?? '', existingImages: state.existingImages);
      } else {
        await repository.addProduct(productToSave, state.images, authService.currentUserId ?? '');
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
