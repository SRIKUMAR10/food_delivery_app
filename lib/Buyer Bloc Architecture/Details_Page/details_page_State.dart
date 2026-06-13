import 'package:equatable/equatable.dart';

class DetailsState extends Equatable {
  final int quantity;

  const DetailsState({
    this.quantity = 1,
  });

  DetailsState copyWith({
    int? quantity,
  }) {
    return DetailsState(
      quantity: quantity ?? this.quantity,
    );
  }

  @override
  List<Object> get props => [quantity];
}
