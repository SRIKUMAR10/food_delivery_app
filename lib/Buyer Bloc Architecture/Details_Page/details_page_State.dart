import 'package:equatable/equatable.dart';

class DetailsState extends Equatable {
  final int quantity;
  final bool isFavourite;

  const DetailsState({
    this.quantity = 1,
    this.isFavourite = false,
  });

  DetailsState copyWith({
    int? quantity,
    bool? isFavourite,
  }) {
    return DetailsState(
      quantity: quantity ?? this.quantity,
      isFavourite: isFavourite ?? this.isFavourite,
    );
  }

  @override
  List<Object> get props => [quantity, isFavourite];
}
