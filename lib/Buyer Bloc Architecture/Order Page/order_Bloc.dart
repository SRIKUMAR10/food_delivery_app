import 'package:flutter_bloc/flutter_bloc.dart';
import 'order_Event.dart';
import 'order_State.dart';

class OrderBloc extends Bloc<OrderEvent, OrderState> {
  OrderBloc() : super(OrderInitial()) {
    on<LoadOrdersRequested>(_onLoadOrdersRequested);
  }

  Future<void> _onLoadOrdersRequested(
    LoadOrdersRequested event,
    Emitter<OrderState> emit,
  ) async {
    emit(OrderLoading());
    
    // Simulate a brief network delay
    await Future.delayed(const Duration(milliseconds: 600));

    // Mock data for the orders list
    final List<Map<String, dynamic>> mockOrders = [
      {
        'id': 'ORD-92842',
        'name': 'Double Cheese Burger',
        'status': 'Delivered',
        'price': 15.50,
        'date': '22 Oct 2023',
        'image':
            'https://images.unsplash.com/photo-1568901346375-23c9450c58cd?q=80&w=400&auto=format&fit=crop',
      },
      {
        'id': 'ORD-92711',
        'name': 'Margherita Pizza',
        'status': 'Pending',
        'price': 12.00,
        'date': '24 Oct 2023',
        'image':
            'https://images.unsplash.com/photo-1604382354936-07c5d9983bd3?q=80&w=400&auto=format&fit=crop',
      },
      {
        'id': 'ORD-92650',
        'name': 'Crispy Chicken Wings',
        'status': 'Delivered',
        'price': 10.25,
        'date': '20 Oct 2023',
        'image':
            'https://images.unsplash.com/photo-1567620832903-9fc6debc209f?q=80&w=400&auto=format&fit=crop',
      },
    ];

    emit(OrderLoaded(mockOrders));
  }
}
