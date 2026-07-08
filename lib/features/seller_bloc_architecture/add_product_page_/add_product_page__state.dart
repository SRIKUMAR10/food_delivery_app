import 'package:equatable/equatable.dart';

enum AddProductStatus { initial, loading, success, error }

class AddProductPageState extends Equatable {
  final AddProductStatus status;
  final List<String> images;
  final String? category;
  final bool isActive;
  final String? errorMessage;

  const AddProductPageState({
    this.status = AddProductStatus.initial,
    this.images = const [],
    this.category,
    this.isActive = true,
    this.errorMessage,
  });

  AddProductPageState copyWith({
    AddProductStatus? status,
    List<String>? images,
    String? category,
    bool? isActive,
    String? errorMessage,
  }) {
    return AddProductPageState(
      status: status ?? this.status,
      images: images ?? this.images,
      category: category ?? this.category,
      isActive: isActive ?? this.isActive,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, images, category, isActive, errorMessage];
}
