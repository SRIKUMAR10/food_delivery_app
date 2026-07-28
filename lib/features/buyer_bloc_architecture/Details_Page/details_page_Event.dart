import 'package:equatable/equatable.dart';

abstract class DetailsEvent extends Equatable {
  const DetailsEvent();

  @override
  List<Object> get props => [];
}

class DetailsQuantityIncreased extends DetailsEvent {}

class DetailsQuantityDecreased extends DetailsEvent {}

class LoadDetailsRating extends DetailsEvent {
  final String foodId;

  const LoadDetailsRating({required this.foodId});

  @override
  List<Object> get props => [foodId];
}


