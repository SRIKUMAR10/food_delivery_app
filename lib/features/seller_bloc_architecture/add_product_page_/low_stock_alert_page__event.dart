import 'package:equatable/equatable.dart';

abstract class LowStockAlertEvent extends Equatable {
  const LowStockAlertEvent();

  @override
  List<Object> get props => [];
}

class LoadLowStockData extends LowStockAlertEvent {}

class RefreshLowStockData extends LowStockAlertEvent {}
