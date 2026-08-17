import 'dart:async';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/repositories/delivery_active_order_session_repository.dart';
import '../../../repositories/delivery_partner_repository.dart';

/// State representing delivery partner availability and duty status.
class AvailabilityState extends Equatable {
  final bool isOnline;
  final bool isAvailable;
  final bool isBusy;
  final String partnerStatus;
  final String? currentOrderId;
  final int autoOfflineMinutes;
  final bool isLoading;
  final String? errorMessage;
  final DateTime? lastActiveAt;

  const AvailabilityState({
    this.isOnline = true,
    this.isAvailable = true,
    this.isBusy = false,
    this.partnerStatus = 'online',
    this.currentOrderId,
    this.autoOfflineMinutes = 15,
    this.isLoading = false,
    this.errorMessage,
    this.lastActiveAt,
  });

  AvailabilityState copyWith({
    bool? isOnline,
    bool? isAvailable,
    bool? isBusy,
    String? partnerStatus,
    String? currentOrderId,
    int? autoOfflineMinutes,
    bool? isLoading,
    String? errorMessage,
    DateTime? lastActiveAt,
    bool clearOrderId = false,
  }) {
    return AvailabilityState(
      isOnline: isOnline ?? this.isOnline,
      isAvailable: isAvailable ?? this.isAvailable,
      isBusy: isBusy ?? this.isBusy,
      partnerStatus: partnerStatus ?? this.partnerStatus,
      currentOrderId: clearOrderId ? null : (currentOrderId ?? this.currentOrderId),
      autoOfflineMinutes: autoOfflineMinutes ?? this.autoOfflineMinutes,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      lastActiveAt: lastActiveAt ?? this.lastActiveAt,
    );
  }

  @override
  List<Object?> get props => [
        isOnline,
        isAvailable,
        isBusy,
        partnerStatus,
        currentOrderId,
        autoOfflineMinutes,
        isLoading,
        errorMessage,
        lastActiveAt,
      ];
}

/// Cubit managing real-time duty status, online/offline toggle, busy states, and auto-offline.
class AvailabilityCubit extends Cubit<AvailabilityState> {
  final DeliveryPartnerRepository _repository;
  final DeliveryActiveOrderSessionRepository? _sessionRepo;
  StreamSubscription? _partnerSub;
  StreamSubscription<DeliverySessionState>? _sessionSub;
  Timer? _autoOfflineTimer;

  AvailabilityCubit({
    DeliveryPartnerRepository? repository,
    DeliveryActiveOrderSessionRepository? sessionRepo,
  })  : _repository = repository ?? DeliveryPartnerRepository(),
        _sessionRepo = sessionRepo,
        super(const AvailabilityState()) {
    _initListeners();
  }

  void _initListeners() {
    final user = _repository.currentUser;
    if (user != null) {
      _partnerSub = _repository.watchDeliveryPartner(user.uid).listen((partner) {
        if (partner != null && !isClosed) {
          emit(state.copyWith(
            isOnline: partner.isOnline,
            isAvailable: partner.isAvailable,
            isBusy: partner.isBusy,
            partnerStatus: partner.isOnline ? (partner.isBusy ? 'busy' : 'online') : 'offline',
            lastActiveAt: partner.lastActiveAt,
          ));
        }
      });
    }

    _sessionSub = _sessionRepo?.sessionStream.listen((session) {
      if (!isClosed) {
        emit(state.copyWith(
          isOnline: session.isOnline,
          isBusy: session.activeOrderId != null,
          currentOrderId: session.activeOrderId,
        ));
      }
    });
  }

  Future<void> toggleOnline() async {
    if (state.isOnline) {
      await goOffline();
    } else {
      await goOnline();
    }
  }

  Future<void> goOnline() async {
    final uid = _repository.currentUser?.uid;
    emit(state.copyWith(isLoading: true, errorMessage: null));
    try {
      if (uid != null && uid.isNotEmpty) {
        await _repository.goOnline(uid);
      }
      _sessionRepo?.setOnlineStatus(true);
      emit(state.copyWith(
        isOnline: true,
        isAvailable: true,
        isBusy: false,
        partnerStatus: 'online',
        isLoading: false,
        lastActiveAt: DateTime.now(),
      ));
      _resetAutoOfflineTimer();
    } catch (e) {
      emit(state.copyWith(
        isLoading: false,
        errorMessage: 'Failed to go online: ${e.toString()}',
      ));
    }
  }

  Future<void> goOffline() async {
    final uid = _repository.currentUser?.uid;
    emit(state.copyWith(isLoading: true, errorMessage: null));
    try {
      if (uid != null && uid.isNotEmpty) {
        await _repository.goOffline(uid);
      }
      _sessionRepo?.setOnlineStatus(false);
      _autoOfflineTimer?.cancel();
      emit(state.copyWith(
        isOnline: false,
        isAvailable: false,
        isBusy: false,
        partnerStatus: 'offline',
        isLoading: false,
        lastActiveAt: DateTime.now(),
      ));
    } catch (e) {
      emit(state.copyWith(
        isLoading: false,
        errorMessage: 'Failed to go offline: ${e.toString()}',
      ));
    }
  }

  Future<void> setBusy({String? orderId}) async {
    final uid = _repository.currentUser?.uid;
    try {
      if (uid != null && uid.isNotEmpty) {
        await _repository.setBusyStatus(uid, isBusy: true, currentOrderId: orderId);
      }
      emit(state.copyWith(
        isBusy: true,
        isAvailable: false,
        partnerStatus: 'busy',
        currentOrderId: orderId,
      ));
    } catch (e) {
      emit(state.copyWith(errorMessage: e.toString()));
    }
  }

  Future<void> setAvailable() async {
    final uid = _repository.currentUser?.uid;
    try {
      if (uid != null && uid.isNotEmpty) {
        await _repository.setAvailableStatus(uid, isAvailable: true);
      }
      emit(state.copyWith(
        isBusy: false,
        isAvailable: true,
        partnerStatus: 'online',
        clearOrderId: true,
      ));
      _resetAutoOfflineTimer();
    } catch (e) {
      emit(state.copyWith(errorMessage: e.toString()));
    }
  }

  Future<void> setBreak() async {
    final uid = _repository.currentUser?.uid;
    try {
      if (uid != null && uid.isNotEmpty) {
        await _repository.updatePartnerStatus(uid, isOnline: false, isAvailable: false);
      }
      emit(state.copyWith(
        isAvailable: false,
        partnerStatus: 'break',
      ));
    } catch (e) {
      emit(state.copyWith(errorMessage: e.toString()));
    }
  }

  void updateAutoOfflineMinutes(int minutes) {
    emit(state.copyWith(autoOfflineMinutes: minutes));
    _resetAutoOfflineTimer();
  }

  void _resetAutoOfflineTimer() {
    _autoOfflineTimer?.cancel();
    if (state.isOnline && state.autoOfflineMinutes > 0) {
      _autoOfflineTimer = Timer(Duration(minutes: state.autoOfflineMinutes), () {
        if (state.isOnline && !state.isBusy) {
          goOffline();
        }
      });
    }
  }

  @override
  Future<void> close() {
    _partnerSub?.cancel();
    _sessionSub?.cancel();
    _autoOfflineTimer?.cancel();
    return super.close();
  }
}
