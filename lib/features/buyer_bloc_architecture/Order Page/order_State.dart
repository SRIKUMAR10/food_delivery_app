import 'package:equatable/equatable.dart';
import 'order_view_model.dart';
import '../Cart Page/cart_models.dart';

abstract class OrderState extends Equatable {
  const OrderState();

  @override
  List<Object?> get props => [];
}

class OrderInitial extends OrderState {}

class OrderLoading extends OrderState {}

class OrderLoaded extends OrderState {
  final List<OrderViewModel> orders;
  final String? actionSuccessMessage;
  final String? actionErrorMessage;
  final bool isActionLoading;

  const OrderLoaded(
    this.orders, {
    this.actionSuccessMessage,
    this.actionErrorMessage,
    this.isActionLoading = false,
  });

  OrderLoaded copyWith({
    List<OrderViewModel>? orders,
    String? actionSuccessMessage,
    String? actionErrorMessage,
    bool? isActionLoading,
    bool clearActionMessage = false,
  }) {
    return OrderLoaded(
      orders ?? this.orders,
      actionSuccessMessage:
          clearActionMessage ? null : (actionSuccessMessage ?? this.actionSuccessMessage),
      actionErrorMessage:
          clearActionMessage ? null : (actionErrorMessage ?? this.actionErrorMessage),
      isActionLoading: isActionLoading ?? this.isActionLoading,
    );
  }

  @override
  List<Object?> get props => [
        orders,
        actionSuccessMessage,
        actionErrorMessage,
        isActionLoading,
      ];
}

class ReorderSuccess extends OrderState {
  final List<CartItem> items;
  final String message;

  const ReorderSuccess({
    required this.items,
    this.message = 'Items added to cart successfully!',
  });

  @override
  List<Object?> get props => [items, message];
}

class OrderError extends OrderState {
  final String message;

  const OrderError(this.message);

  @override
  List<Object?> get props => [message];
}

