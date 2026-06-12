import 'package:flutter/material.dart';

class CartItem {
  final String id;
  final String name;
  final double price;
  final String? image;
  int quantity;
  bool isSelected;

  CartItem({
    required this.id,
    required this.name,
    required this.price,
    this.image,
    this.quantity = 1,
    this.isSelected = true,
  });
}

class CartController extends ChangeNotifier {
  // Singleton pattern
  CartController._internal();
  static final CartController instance = CartController._internal();

  final List<CartItem> _items = [];

  List<CartItem> get items => _items;

  void addItem(CartItem newItem) {
    // Check if item already exists
    int index = _items.indexWhere((item) => item.id == newItem.id);
    
    if (index != -1) {
      _items[index].quantity += newItem.quantity;
    } else {
      _items.add(newItem);
    }
    notifyListeners();
  }

  void removeItem(String id) {
    _items.removeWhere((item) => item.id == id);
    notifyListeners();
  }

  void updateQuantity(String id, int delta) {
    int index = _items.indexWhere((item) => item.id == id);
    if (index != -1) {
      _items[index].quantity += delta;
      if (_items[index].quantity <= 0) {
        _items.removeAt(index);
      }
      notifyListeners();
    }
  }

  void toggleSelection(String id) {
    int index = _items.indexWhere((item) => item.id == id);
    if (index != -1) {
      _items[index].isSelected = !_items[index].isSelected;
      notifyListeners();
    }
  }

  double get totalAmount {
    return _items.where((item) => item.isSelected).fold(0.0, (sum, item) => sum + (item.price * item.quantity));
  }
}
