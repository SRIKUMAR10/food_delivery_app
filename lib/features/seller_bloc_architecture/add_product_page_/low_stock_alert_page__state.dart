import 'package:equatable/equatable.dart';

// Represents an item that is low in stock
class LowStockItem extends Equatable {
  final String id;
  final String name;
  final double quantity;
  final String unit;
  final String iconPath; // Path to local asset or network URL
  final int colorHex; // Base color for the icon background

  const LowStockItem({
    required this.id,
    required this.name,
    required this.quantity,
    required this.unit,
    required this.iconPath,
    required this.colorHex,
  });

  @override
  List<Object> get props => [id, name, quantity, unit, iconPath, colorHex];
}

abstract class LowStockAlertState extends Equatable {
  const LowStockAlertState();

  @override
  List<Object> get props => [];
}

class LowStockAlertInitial extends LowStockAlertState {}

class LowStockAlertLoading extends LowStockAlertState {}

class LowStockAlertLoaded extends LowStockAlertState {
  final List<LowStockItem> items;
  final int totalLowStockCount;

  const LowStockAlertLoaded({
    required this.items,
    required this.totalLowStockCount,
  });

  @override
  List<Object> get props => [items, totalLowStockCount];
}

class LowStockAlertError extends LowStockAlertState {
  final String message;

  const LowStockAlertError({required this.message});

  @override
  List<Object> get props => [message];
}
