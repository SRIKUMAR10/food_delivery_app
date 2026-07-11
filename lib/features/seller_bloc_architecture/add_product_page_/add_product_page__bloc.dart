import 'package:flutter_bloc/flutter_bloc.dart';
import 'add_product_page__event.dart';
import 'add_product_page__state.dart';

class AddProductPageBloc extends Bloc<AddProductPageEvent, AddProductPageState> {
  AddProductPageBloc() : super(const AddProductPageState()) {
    on<AddImageEvent>(_onAddImage);
    on<RemoveImageEvent>(_onRemoveImage);
    on<CategoryChangedEvent>(_onCategoryChanged);
    on<FoodTypeChangedEvent>(_onFoodTypeChanged);
    on<SpicyLevelChangedEvent>(_onSpicyLevelChanged);
    on<StatusChangedEvent>(_onStatusChanged);
    on<SubmitProductEvent>(_onSubmitProduct);
    on<StepChangedEvent>(_onStepChanged);
    on<FieldChangedEvent>(_onFieldChanged);
  }

  void _onAddImage(AddImageEvent event, Emitter<AddProductPageState> emit) {
    if (state.images.length < 5) {
      final updatedImages = List<String>.from(state.images)..add(event.imagePath);
      emit(state.copyWith(images: updatedImages));
    }
  }

  void _onRemoveImage(RemoveImageEvent event, Emitter<AddProductPageState> emit) {
    if (event.index >= 0 && event.index < state.images.length) {
      final updatedImages = List<String>.from(state.images)..removeAt(event.index);
      emit(state.copyWith(images: updatedImages));
    }
  }

  void _onCategoryChanged(CategoryChangedEvent event, Emitter<AddProductPageState> emit) {
    emit(state.copyWith(category: event.category));
  }

  void _onFoodTypeChanged(FoodTypeChangedEvent event, Emitter<AddProductPageState> emit) {
    emit(state.copyWith(foodType: event.foodType));
  }

  void _onSpicyLevelChanged(SpicyLevelChangedEvent event, Emitter<AddProductPageState> emit) {
    emit(state.copyWith(spicyLevel: event.spicyLevel));
  }

  void _onStatusChanged(StatusChangedEvent event, Emitter<AddProductPageState> emit) {
    emit(state.copyWith(isActive: event.isActive));
  }

  Future<void> _onSubmitProduct(SubmitProductEvent event, Emitter<AddProductPageState> emit) async {
    emit(state.copyWith(status: AddProductStatus.loading));
    
    try {
      // Simulate API call for adding product
      await Future.delayed(const Duration(seconds: 2));
      
      // Basic validation
      if (event.name.isEmpty || event.price <= 0 || state.category == null || state.images.isEmpty) {
         emit(state.copyWith(
           status: AddProductStatus.error, 
           errorMessage: 'Please fill all required fields and upload at least 1 image.'
         ));
         return;
      }

      emit(state.copyWith(status: AddProductStatus.success));
    } catch (e) {
      emit(state.copyWith(status: AddProductStatus.error, errorMessage: e.toString()));
    }
  }

  void _onStepChanged(StepChangedEvent event, Emitter<AddProductPageState> emit) {
    if (event.stepIndex >= 0 && event.stepIndex < 4) {
      emit(state.copyWith(currentStep: event.stepIndex));
    }
  }

  void _onFieldChanged(FieldChangedEvent event, Emitter<AddProductPageState> emit) {
    switch (event.fieldName) {
      case 'name':
        emit(state.copyWith(name: event.value as String));
        break;
      case 'price':
        emit(state.copyWith(price: event.value as double));
        break;
      case 'originalPrice':
        emit(state.copyWith(originalPrice: event.value as double));
        break;
      case 'discountPercent':
        emit(state.copyWith(discountPercent: event.value as double));
        break;
      case 'description':
        emit(state.copyWith(description: event.value as String));
        break;
      case 'availableStock':
        emit(state.copyWith(availableStock: event.value as int));
        break;
      case 'minimumAlert':
        emit(state.copyWith(minimumAlert: event.value as int));
        break;
      case 'isFeatured':
        emit(state.copyWith(isFeatured: event.value as bool));
        break;
      case 'isBestSeller':
        emit(state.copyWith(isBestSeller: event.value as bool));
        break;
      case 'hasUnlimitedStock':
        emit(state.copyWith(hasUnlimitedStock: event.value as bool));
        break;
    }
    // Simulate auto-save timestamp update
    emit(state.copyWith(lastSavedAt: DateTime.now()));
  }
}
