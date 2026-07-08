import 'package:equatable/equatable.dart';

class RiderModel extends Equatable {
  final String id;
  final String name;
  final double rating;
  final String distance;
  final String imageUrl;

  const RiderModel({
    required this.id,
    required this.name,
    required this.rating,
    required this.distance,
    required this.imageUrl,
  });

  @override
  List<Object?> get props => [id, name, rating, distance, imageUrl];
}

abstract class AssignDeliveryState extends Equatable {
  const AssignDeliveryState();
  
  @override
  List<Object?> get props => [];
}

class AssignDeliveryInitial extends AssignDeliveryState {}

class AssignDeliveryLoading extends AssignDeliveryState {}

class AssignDeliveryLoaded extends AssignDeliveryState {
  final List<RiderModel> riders;
  final String? selectedRiderId;
  final String deliveryInstructions;
  final bool isSubmitting;

  const AssignDeliveryLoaded({
    required this.riders,
    this.selectedRiderId,
    this.deliveryInstructions = '',
    this.isSubmitting = false,
  });

  AssignDeliveryLoaded copyWith({
    List<RiderModel>? riders,
    String? selectedRiderId,
    String? deliveryInstructions,
    bool? isSubmitting,
  }) {
    return AssignDeliveryLoaded(
      riders: riders ?? this.riders,
      selectedRiderId: selectedRiderId ?? this.selectedRiderId,
      deliveryInstructions: deliveryInstructions ?? this.deliveryInstructions,
      isSubmitting: isSubmitting ?? this.isSubmitting,
    );
  }

  @override
  List<Object?> get props => [riders, selectedRiderId, deliveryInstructions, isSubmitting];
}

class AssignDeliveryError extends AssignDeliveryState {
  final String message;

  const AssignDeliveryError({required this.message});

  @override
  List<Object?> get props => [message];
}

class AssignDeliverySuccess extends AssignDeliveryState {}
