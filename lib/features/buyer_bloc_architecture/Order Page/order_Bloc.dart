import 'package:flutter_bloc/flutter_bloc.dart';
import 'order_Event.dart';
import 'order_State.dart';
import '../../../core/repositories/i_order_repository.dart';
import '../../../core/services/i_auth_service.dart';
import '../../../core/repositories/i_cart_repository.dart';
import '../../../core/models/order_status.dart';
import '../../../core/utils/app_exception_formatter.dart';
import '../../../repositories/firebase_cart_repository.dart';
import 'order_mapper.dart';

class OrderBloc extends Bloc<OrderEvent, OrderState> {
  final IOrderRepository _repository;
  final IAuthService _authService;
  final ICartRepository? _cartRepository;

  OrderBloc({
    required IOrderRepository repository,
    required IAuthService authService,
    ICartRepository? cartRepository,
  })  : _repository = repository,
        _authService = authService,
        _cartRepository = cartRepository,
        super(OrderInitial()) {
    on<LoadOrdersRequested>(_onLoadOrdersRequested);
    on<ReorderRequested>(_onReorderRequested);
    on<CancelOrderRequested>(_onCancelOrderRequested);
    on<ClearOrderMessage>(_onClearOrderMessage);
  }


  Future<void> _onLoadOrdersRequested(
    LoadOrdersRequested event,
    Emitter<OrderState> emit,
  ) async {
    final buyerId = _authService.currentUserId;
    if (buyerId == null) {
      emit(const OrderError('User not authenticated'));
      return;
    }

    emit(OrderLoading());
    await _authService.ensureTokenReady();

    await emit.forEach<List<dynamic>>(
      _repository.getBuyerOrdersStream(buyerId),
      onData: (orders) {
        final viewModels = orders.map((order) => OrderMapper.toViewModel(order)).toList();
        return OrderLoaded(viewModels);
      },
      onError: (error, stackTrace) =>
          OrderError(AppExceptionFormatter.toUserFriendlyMessage(error)),
    );
  }

  Future<void> _onReorderRequested(
    ReorderRequested event,
    Emitter<OrderState> emit,
  ) async {
    final buyerId = _authService.currentUserId;
    if (buyerId == null) {
      emit(const OrderError('Please login to reorder.'));
      return;
    }

    final currentState = state;
    if (currentState is OrderLoaded) {
      emit(currentState.copyWith(isActionLoading: true));
    }

    try {
      final cartRepo = _cartRepository ?? FirebaseCartRepository();
      for (final item in event.order.items) {
        await cartRepo.addItem(buyerId, item);
      }

      if (state is OrderLoaded) {
        final loaded = state as OrderLoaded;
        emit(loaded.copyWith(
          isActionLoading: false,
          actionSuccessMessage: 'Items from Order #${event.order.shortId} added to cart!',
        ));
      } else {
        emit(ReorderSuccess(
          items: event.order.items,
          message: 'Items from Order #${event.order.shortId} added to cart!',
        ));
      }
    } catch (e) {
      if (state is OrderLoaded) {
        final loaded = state as OrderLoaded;
        emit(loaded.copyWith(
          isActionLoading: false,
          actionErrorMessage: 'Failed to reorder items: $e',
        ));
      } else {
        emit(OrderError('Failed to reorder items: $e'));
      }
    }
  }

  Future<void> _onCancelOrderRequested(
    CancelOrderRequested event,
    Emitter<OrderState> emit,
  ) async {
    final currentState = state;
    if (currentState is OrderLoaded) {
      emit(currentState.copyWith(isActionLoading: true));
    }

    try {
      await _repository.updateOrderStatus(event.orderId, OrderStatus.cancelled);
      if (state is OrderLoaded) {
        final loaded = state as OrderLoaded;
        emit(loaded.copyWith(
          isActionLoading: false,
          actionSuccessMessage: 'Order cancelled successfully',
        ));
      }
    } catch (e) {
      if (state is OrderLoaded) {
        final loaded = state as OrderLoaded;
        emit(loaded.copyWith(
          isActionLoading: false,
          actionErrorMessage: 'Failed to cancel order: $e',
        ));
      }
    }
  }

  void _onClearOrderMessage(
    ClearOrderMessage event,
    Emitter<OrderState> emit,
  ) {
    if (state is OrderLoaded) {
      final loaded = state as OrderLoaded;
      emit(loaded.copyWith(clearActionMessage: true));
    }
  }
}

