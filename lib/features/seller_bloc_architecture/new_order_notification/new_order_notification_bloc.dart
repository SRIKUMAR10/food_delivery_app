// Real-Time BLoC Stream Binding Standardized
import 'dart:async';
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/models/order_model.dart';
import 'new_order_notification_event.dart';
import 'new_order_notification_state.dart';
import 'new_order_notification_repository.dart';

import '../../../../core/services/audio_notification_service.dart';

class NewOrderNotificationBloc extends Bloc<NewOrderNotificationEvent, NewOrderNotificationState> {
  final NewOrderNotificationRepository repository;
  final AudioNotificationService? audioService;

  StreamSubscription<List<OrderModel>>? _ordersSubscription;
  StreamSubscription? _settingsSubscription;
  final List<OrderModel> _pendingOrders = [];
  OrderModel? _currentOrder;

  String _ringtoneName = 'Bell Chime';
  double _soundVolume = 0.8;
  bool _soundEnabled = true;
  bool _soundLoop = true;

  NewOrderNotificationBloc({
    required this.repository,
    this.audioService,
  }) : super(NewOrderNotificationInitial()) {
    on<StartListening>(_onStartListening);
    on<AcceptOrderEvent>(_onAcceptOrder);
    on<RejectOrderEvent>(_onRejectOrder);
    on<DismissCurrentOrder>(_onDismissCurrentOrder);
    on<OrdersUpdated>(_onOrdersUpdated);
    on<NewOrderNotificationErrorEvent>(_onErrorEvent);
    on<ConfigureNewOrderAudio>(_onConfigureAudio);
  }

  void _onConfigureAudio(ConfigureNewOrderAudio event, Emitter<NewOrderNotificationState> emit) {
    _ringtoneName = event.ringtoneName;
    _soundVolume = event.volume;
    _soundEnabled = event.soundEnabled;
    _soundLoop = event.soundLoop;
    AudioNotificationService.setGlobalAudioConfig(
      volume: _soundVolume,
      ringtone: _ringtoneName,
    );
  }

  void _onStartListening(StartListening event, Emitter<NewOrderNotificationState> emit) {
    emit(NewOrderNotificationLoading());
    _ordersSubscription?.cancel();
    _settingsSubscription?.cancel();

    if (!kIsWeb && Platform.environment.containsKey('FLUTTER_TEST')) {
      // Skip live Firestore channel subscription in unit test mode
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
            _soundLoop = data['soundLoopUntilAccepted'] as bool? ?? true;
            AudioNotificationService.setGlobalAudioConfig(
              volume: _soundVolume,
              ringtone: _ringtoneName,
            );
          }
        });
      } catch (_) {}
    }

    _ordersSubscription = repository.streamNewOrders(event.sellerId).listen(
      (orders) {
        add(OrdersUpdated(orders));
      },
      onError: (error) {
        add(NewOrderNotificationErrorEvent(error.toString()));
      },
    );
  }

  void _onErrorEvent(NewOrderNotificationErrorEvent event, Emitter<NewOrderNotificationState> emit) {
    emit(NewOrderNotificationError(event.message));
  }

  void _onOrdersUpdated(OrdersUpdated event, Emitter<NewOrderNotificationState> emit) {
    final orders = event.orders;
    if (orders.isEmpty) {
      _pendingOrders.clear();
      _currentOrder = null;
      audioService?.stop();
      emit(NoNewOrders());
      return;
    }

    for (var order in orders) {
      if (_currentOrder != null && _currentOrder!.id == order.id) continue;
      if (_pendingOrders.any((o) => o.id == order.id)) continue;
      _pendingOrders.add(order);
    }

    if (_currentOrder == null) {
      _showNextOrder(emit);
    }
  }

  void _showNextOrder(Emitter<NewOrderNotificationState> emit) {
    if (_pendingOrders.isEmpty) {
      _currentOrder = null;
      audioService?.stop();
      emit(NoNewOrders());
      return;
    }

    _currentOrder = _pendingOrders.removeAt(0);
    if (_soundEnabled) {
      audioService?.playNewOrderSound(
        ringtoneName: _ringtoneName,
        volume: _soundVolume,
        loop: _soundLoop,
      );
    }
    emit(NewOrderLoaded(order: _currentOrder!, pendingCount: _pendingOrders.length + 1));
  }

  Future<void> _onAcceptOrder(AcceptOrderEvent event, Emitter<NewOrderNotificationState> emit) async {
    try {
      audioService?.stop();
      await repository.acceptOrder(event.orderId);
      _currentOrder = null;
      emit(OrderAcceptedState(event.orderId));
      _showNextOrder(emit);
    } catch (e) {
      emit(NewOrderNotificationError(e.toString()));
    }
  }

  Future<void> _onRejectOrder(RejectOrderEvent event, Emitter<NewOrderNotificationState> emit) async {
    try {
      audioService?.stop();
      await repository.rejectOrder(event.orderId);
      _currentOrder = null;
      emit(OrderRejectedState(event.orderId));
      _showNextOrder(emit);
    } catch (e) {
      emit(NewOrderNotificationError(e.toString()));
    }
  }

  void _onDismissCurrentOrder(DismissCurrentOrder event, Emitter<NewOrderNotificationState> emit) {
    audioService?.stop();
    _currentOrder = null;
    _showNextOrder(emit);
  }

  @override
  Future<void> close() {
    audioService?.stop();
    _ordersSubscription?.cancel();
    _settingsSubscription?.cancel();
    return super.close();
  }
}
