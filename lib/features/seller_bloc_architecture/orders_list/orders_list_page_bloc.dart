import 'dart:async';
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/models/order_model.dart';
import '../../../../core/models/order_status.dart';
import '../../../../core/services/audio_notification_service.dart';
import 'orders_list_page_event.dart';
import 'orders_list_page_state.dart';
import '../../../../core/repositories/i_order_repository.dart';
import '../../../../core/repositories/i_chat_repository.dart';

import '../../../../core/services/backfill_orders_service.dart';

class OrdersListBloc extends Bloc<OrdersListEvent, OrdersListState> {
  final IOrderRepository repository;
  final IChatRepository chatRepository;
  final AudioNotificationService _audioService = AudioNotificationService();
  
  List<OrderModel> _allOrders = [];
  String _activeFilter = 'All';
  String _searchQuery = '';
  int _previousNewOrderCount = 0;
  bool _isInitialStreamLoad = true;
  StreamSubscription? _settingsSubscription;

  double _soundVolume = 0.8;
  String _ringtoneName = 'Bell Chime';
  bool _soundEnabled = true;
  bool _soundLoop = false;

  OrdersListBloc({required this.repository, required this.chatRepository}) : super(OrdersListInitial()) {
    on<LoadOrdersStream>(_onLoadOrdersStream);
    on<FilterOrders>(_onFilterOrders);
    on<SearchOrders>(_onSearchOrders);
    on<ClearMessages>(_onClearMessages);
    on<UpdateOrderStatusEvent>(_onUpdateOrderStatus);
    on<CancelOrderEvent>(_onCancelOrder);
    on<RejectOrderEvent>(_onRejectOrder);
  }

  Future<void> _onLoadOrdersStream(LoadOrdersStream event, Emitter<OrdersListState> emit) async {
    emit(OrdersListLoading());
    _isInitialStreamLoad = true;
    _previousNewOrderCount = 0;
    if (event.sellerId.isEmpty) {
      _allOrders = [];
      emit(_createFilteredState());
      return;
    }
    unawaited(BackfillOrdersService().runBackfillMigration(event.sellerId));

    // Subscribe to seller audio notification settings
    await _settingsSubscription?.cancel();
    if (!kIsWeb && Platform.environment.containsKey('FLUTTER_TEST')) {
      // Test environment guard to avoid uninitialized Firestore platform channels
    } else if (event.sellerId.isNotEmpty) {
      try {
        _settingsSubscription = FirebaseFirestore.instance
            .collection('seller_notification_settings')
            .doc(event.sellerId)
            .snapshots()
            .listen((snap) {
          if (snap.exists) {
            final data = snap.data() ?? {};
            _soundVolume = (data['soundVolume'] as num?)?.toDouble() ?? 0.8;
            _ringtoneName = data['orderAlertRingtone'] as String? ?? 'Bell Chime';
            _soundEnabled = data['newOrderSound'] as bool? ?? true;
            _soundLoop = data['soundLoopUntilAccepted'] as bool? ?? false;
            AudioNotificationService.setGlobalAudioConfig(
              volume: _soundVolume,
              ringtone: _ringtoneName,
            );
          }
        });
      } catch (_) {}
    }

    await emit.forEach<List<OrderModel>>(
      repository.getSellerOrdersStream(event.sellerId),
      onData: (orders) {
        _allOrders = orders;
        
        // Check for new orders to play sound; skip sound trigger on initial stream load
        int currentNewOrderCount = _allOrders.where((o) => o.status == OrderStatus.newOrder).length;
        if (_isInitialStreamLoad) {
          _isInitialStreamLoad = false;
          _previousNewOrderCount = currentNewOrderCount;
        } else {
          if (currentNewOrderCount > _previousNewOrderCount) {
            if (_soundEnabled) {
              _audioService.playNewOrderSound(
                ringtoneName: _ringtoneName,
                volume: _soundVolume,
                loop: _soundLoop,
              );
            }
          } else if (currentNewOrderCount == 0) {
            _audioService.stop();
          }
          _previousNewOrderCount = currentNewOrderCount;
        }

        return _createFilteredState();
      },
      onError: (error, stackTrace) => OrdersListError('Failed to load orders: $error'),
    );
  }

  void _onFilterOrders(FilterOrders event, Emitter<OrdersListState> emit) {
    if (state is OrdersListLoaded) {
      final loaded = state as OrdersListLoaded;
      if (_allOrders.isEmpty && loaded.allOrders.isNotEmpty) {
        _allOrders = List.from(loaded.allOrders);
      }
      _activeFilter = event.status;
      emit(_createFilteredState());
    }
  }

  void _onSearchOrders(SearchOrders event, Emitter<OrdersListState> emit) {
    if (state is OrdersListLoaded) {
      final loaded = state as OrdersListLoaded;
      if (_allOrders.isEmpty && loaded.allOrders.isNotEmpty) {
        _allOrders = List.from(loaded.allOrders);
      }
      _searchQuery = event.query;
      emit(_createFilteredState(
        updatingOrderIds: (state as OrdersListLoaded).updatingOrderIds,
      ));
    }
  }

  void _onClearMessages(ClearMessages event, Emitter<OrdersListState> emit) {
    if (state is OrdersListLoaded) {
      emit((state as OrdersListLoaded).copyWith(clearMessages: true));
    }
  }

  Future<void> _onUpdateOrderStatus(UpdateOrderStatusEvent event, Emitter<OrdersListState> emit) async {
    final currentState = state;
    if (currentState is! OrdersListLoaded) return;

    if (_allOrders.isEmpty && currentState.allOrders.isNotEmpty) {
      _allOrders = List.from(currentState.allOrders);
    }

    final orderIndex = _allOrders.indexWhere((o) => o.id == event.orderId);
    if (orderIndex == -1) {
      emit(currentState.copyWith(
        errorMessage: 'Order not found.',
      ));
      return;
    }

    final order = _allOrders[orderIndex];

    if (!order.canTransitionTo(event.newStatus)) {
      emit(currentState.copyWith(
        errorMessage: 'Invalid status transition from ${order.status.displayName} to ${event.newStatus.displayName}.',
      ));
      return;
    }

    final newUpdating = Set<String>.from(currentState.updatingOrderIds)..add(event.orderId);
    emit(currentState.copyWith(updatingOrderIds: newUpdating));

    try {
      await repository.updateOrderStatus(event.orderId, event.newStatus, reason: event.reason);
      
      // Auto-create chat conversation when an order is accepted or preparing
      if (event.newStatus == OrderStatus.accepted || event.newStatus == OrderStatus.preparing) {
        try {
          await chatRepository.createConversation(
            buyerId: order.customerId,
            buyerName: order.customerName,
            sellerId: order.sellerId,
            sellerName: order.sellerName ?? 'Store',
            orderId: order.id,
            initialMessage: 'Your order #${order.id} has been accepted and is being processed.',
          );
        } catch (e) {
          debugPrint('Failed to initiate chat: $e');
        }
      }

      // Add wallet transaction when order is delivered
      if (event.newStatus == OrderStatus.delivered) {
        try {
          await repository.addOrderWalletTransaction(
            customerId: order.customerId,
            orderId: order.id,
            sellerId: order.sellerId,
            amount: order.amount,
          );
        } catch (e) {
          debugPrint('Failed to create wallet transaction: $e');
        }
      }

      if (state is OrdersListLoaded) {
        final st = state as OrdersListLoaded;
        final nextUpdating = Set<String>.from(st.updatingOrderIds)..remove(event.orderId);
        emit(st.copyWith(
          updatingOrderIds: nextUpdating,
          successMessage: 'Order status updated to ${event.newStatus.displayName}.',
        ));
      }
    } catch (e) {
      if (state is OrdersListLoaded) {
        final st = state as OrdersListLoaded;
        final nextUpdating = Set<String>.from(st.updatingOrderIds)..remove(event.orderId);
        emit(st.copyWith(
          updatingOrderIds: nextUpdating,
          errorMessage: 'Failed to update order status: $e',
        ));
      }
    }
  }

  Future<void> _onCancelOrder(CancelOrderEvent event, Emitter<OrdersListState> emit) async {
    add(UpdateOrderStatusEvent(event.orderId, OrderStatus.cancelled, reason: event.reason));
  }

  Future<void> _onRejectOrder(RejectOrderEvent event, Emitter<OrdersListState> emit) async {
    add(UpdateOrderStatusEvent(event.orderId, OrderStatus.rejected, reason: event.reason));
  }

  OrdersListLoaded _createFilteredState({Set<String> updatingOrderIds = const {}}) {
    final filtered = _allOrders.where((order) {
      final cleanFilter = _activeFilter.toLowerCase().replaceAll(' ', '').replaceAll('_', '').replaceAll('-', '');
      bool matchesFilter = false;

      if (cleanFilter == 'all' || cleanFilter.isEmpty) {
        matchesFilter = true;
      } else if (cleanFilter == 'new' || cleanFilter == 'placed' || cleanFilter == 'neworder') {
        matchesFilter = order.status == OrderStatus.newOrder;
      } else if (cleanFilter == 'accepted') {
        matchesFilter = order.status == OrderStatus.accepted;
      } else if (cleanFilter == 'preparing') {
        matchesFilter = order.status == OrderStatus.preparing;
      } else if (cleanFilter == 'ready' || cleanFilter == 'readyforpickup') {
        matchesFilter = order.status == OrderStatus.ready;
      } else if (cleanFilter == 'pickedup') {
        matchesFilter = order.status == OrderStatus.pickedUp;
      } else if (cleanFilter == 'outfordelivery') {
        matchesFilter = order.status == OrderStatus.outForDelivery;
      } else if (cleanFilter == 'delivered') {
        matchesFilter = order.status == OrderStatus.delivered;
      } else if (cleanFilter == 'cancelled' || cleanFilter == 'canceled' || cleanFilter == 'rejected') {
        matchesFilter = order.status == OrderStatus.cancelled || order.status == OrderStatus.rejected;
      } else {
        matchesFilter = order.status.value.toLowerCase() == cleanFilter;
      }

      final query = _searchQuery.toLowerCase().trim();
      final matchesSearch = query.isEmpty || 
                            order.id.toLowerCase().contains(query) || 
                            order.customerName.toLowerCase().contains(query) ||
                            (order.customerPhone ?? '').toLowerCase().contains(query) ||
                            (order.deliveryAddress ?? '').toLowerCase().contains(query) ||
                            (order.items?.any((item) => item.name.toLowerCase().contains(query)) ?? false);

      return matchesFilter && matchesSearch;
    }).toList();

    return OrdersListLoaded(
      allOrders: _allOrders,
      filteredOrders: filtered,
      activeFilter: _activeFilter,
      searchQuery: _searchQuery,
      updatingOrderIds: updatingOrderIds,
    );
  }

  @override
  Future<void> close() {
    _settingsSubscription?.cancel();
    _audioService.stop();
    _audioService.dispose();
    return super.close();
  }
}
