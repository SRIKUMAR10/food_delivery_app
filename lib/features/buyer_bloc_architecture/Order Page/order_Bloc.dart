import 'package:flutter_bloc/flutter_bloc.dart';
import 'order_Event.dart';
import 'order_State.dart';
import '../../../core/repositories/i_order_repository.dart';
import '../../../core/services/i_auth_service.dart';
import 'order_mapper.dart';

class OrderBloc extends Bloc<OrderEvent, OrderState> {
  final IOrderRepository _repository;
  final IAuthService _authService;

  OrderBloc({
    required IOrderRepository repository,
    required IAuthService authService,
  })  : _repository = repository,
        _authService = authService,
        super(OrderInitial()) {
    on<LoadOrdersRequested>(_onLoadOrdersRequested);
  }

  Future<void> _onLoadOrdersRequested(
    LoadOrdersRequested event,
    Emitter<OrderState> emit,
  ) async {
    final buyerId = _authService.currentUserId;
    if (buyerId == null) {
      emit(OrderLoaded([]));
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
      onError: (error, stackTrace) => OrderError(error.toString()),
    );
  }
}
