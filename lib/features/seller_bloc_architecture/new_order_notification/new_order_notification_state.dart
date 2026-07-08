import 'package:equatable/equatable.dart';

abstract class NewOrderNotificationState extends Equatable {
  const NewOrderNotificationState();
  
  @override
  List<Object?> get props => [];
}

class NewOrderNotificationInitial extends NewOrderNotificationState {}

class NewOrderNotificationLoading extends NewOrderNotificationState {}

class NewOrderNotificationLoaded extends NewOrderNotificationState {
  final Map<String, dynamic> orderDetails;
  
  const NewOrderNotificationLoaded(this.orderDetails);
  
  @override
  List<Object?> get props => [orderDetails];
}

class OrderAcceptedState extends NewOrderNotificationState {}

class OrderRejectedState extends NewOrderNotificationState {}

class NewOrderNotificationError extends NewOrderNotificationState {
  final String message;
  
  const NewOrderNotificationError(this.message);
  
  @override
  List<Object?> get props => [message];
}
