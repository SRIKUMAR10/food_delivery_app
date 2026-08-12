import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// Enum representing the stages of the Active Delivery State Machine.
enum ActiveDeliveryStage {
  idle,
  incomingOrder,
  acceptedOrder,
  pickupConfirmation,
  navigatingToCustomer,
  deliveryCompleted,
}

/// Data snapshot representing the current synchronized state of the Delivery Partner session.
class DeliverySessionState {
  final bool isOnline;
  final double walletBalance;
  final double pendingWithdrawal;
  final double totalEarningsToday;
  final int completedOrdersCount;
  final ActiveDeliveryStage deliveryStage;
  final String? activeOrderId;
  final String? storeName;
  final String? storeAddress;
  final String? customerName;
  final String? customerAddress;
  final double? orderAmount;

  const DeliverySessionState({
    this.isOnline = true,
    this.walletBalance = 0.0,
    this.pendingWithdrawal = 0.0,
    this.totalEarningsToday = 0.0,
    this.completedOrdersCount = 0,
    this.deliveryStage = ActiveDeliveryStage.idle,
    this.activeOrderId,
    this.storeName,
    this.storeAddress,
    this.customerName,
    this.customerAddress,
    this.orderAmount,
  });

  DeliverySessionState copyWith({
    bool? isOnline,
    double? walletBalance,
    double? pendingWithdrawal,
    double? totalEarningsToday,
    int? completedOrdersCount,
    ActiveDeliveryStage? deliveryStage,
    String? activeOrderId,
    String? storeName,
    String? storeAddress,
    String? customerName,
    String? customerAddress,
    double? orderAmount,
    bool clearActiveOrder = false,
  }) {
    return DeliverySessionState(
      isOnline: isOnline ?? this.isOnline,
      walletBalance: walletBalance ?? this.walletBalance,
      pendingWithdrawal: pendingWithdrawal ?? this.pendingWithdrawal,
      totalEarningsToday: totalEarningsToday ?? this.totalEarningsToday,
      completedOrdersCount: completedOrdersCount ?? this.completedOrdersCount,
      deliveryStage: deliveryStage ?? this.deliveryStage,
      activeOrderId: clearActiveOrder ? null : (activeOrderId ?? this.activeOrderId),
      storeName: clearActiveOrder ? null : (storeName ?? this.storeName),
      storeAddress: clearActiveOrder ? null : (storeAddress ?? this.storeAddress),
      customerName: clearActiveOrder ? null : (customerName ?? this.customerName),
      customerAddress: clearActiveOrder ? null : (customerAddress ?? this.customerAddress),
      orderAmount: clearActiveOrder ? null : (orderAmount ?? this.orderAmount),
    );
  }
}

/// Centralized local broadcast stream repository for Cross-BLoC state synchronization.
/// Syncs online status and earnings to Firestore `delivery_partners/{uid}` for persistence.
class DeliveryActiveOrderSessionRepository {
  final FirebaseFirestore? _firestore;
  final FirebaseAuth? _auth;
  DeliverySessionState _currentState = const DeliverySessionState();
  final StreamController<DeliverySessionState> _sessionController =
      StreamController<DeliverySessionState>.broadcast();

  DeliveryActiveOrderSessionRepository({
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
  })  : _firestore = firestore,
        _auth = auth;

  DeliverySessionState get currentState => _currentState;

  /// Stream emitting real-time session state changes to all subscribed BLoCs.
  Stream<DeliverySessionState> get sessionStream => _sessionController.stream;

  void dispose() {
    _sessionController.close();
  }

  void _emitState(DeliverySessionState newState) {
    _currentState = newState;
    if (!_sessionController.isClosed) {
      _sessionController.add(_currentState);
    }
  }

  Future<void> _syncOnlineStatusToFirestore(bool isOnline) async {
    try {
      final uid = _auth?.currentUser?.uid;
      if (uid != null && _firestore != null) {
        await _firestore.collection('delivery_partners').doc(uid).set({
          'isOnline': isOnline,
          'updatedAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
      }
    } catch (_) {}
  }

  Future<void> _syncEarningsToFirestore(double earnings) async {
    try {
      final uid = _auth?.currentUser?.uid;
      if (uid != null && _firestore != null) {
        final docRef = _firestore.collection('delivery_partners').doc(uid);
        await _firestore.runTransaction((transaction) async {
          final snap = await transaction.get(docRef);
          if (!snap.exists) return;
          final currentEarnings = (snap.data()?['totalEarnings'] as num?)?.toDouble() ?? 0.0;
          final currentDeliveries = (snap.data()?['totalDeliveries'] as num?)?.toInt() ?? 0;
          transaction.update(docRef, {
            'totalEarnings': currentEarnings + earnings,
            'totalDeliveries': currentDeliveries + 1,
            'updatedAt': FieldValue.serverTimestamp(),
          });
        });
      }
    } catch (_) {}
  }

  /// Toggle Online/Offline status across all BLoCs.
  void toggleOnlineStatus() {
    final newState = _currentState.copyWith(isOnline: !_currentState.isOnline);
    _emitState(newState);
    _syncOnlineStatusToFirestore(newState.isOnline);
  }

  void setOnlineStatus(bool isOnline) {
    _emitState(_currentState.copyWith(isOnline: isOnline));
    _syncOnlineStatusToFirestore(isOnline);
  }

  /// Process withdrawal and update wallet balance synchronously across Wallet and Earnings BLoCs.
  void processWithdrawal(double amount) {
    if (amount > 0 && amount <= _currentState.walletBalance) {
      final newBalance = _currentState.walletBalance - amount;
      final newPending = _currentState.pendingWithdrawal + amount;
      _emitState(_currentState.copyWith(
        walletBalance: newBalance,
        pendingWithdrawal: newPending,
      ));
    }
  }

  /// Trigger an incoming order event.
  void triggerIncomingOrder({
    required String orderId,
    String? storeName,
    String? storeAddress,
    String? customerName,
    String? customerAddress,
    double? orderAmount,
  }) {
    _emitState(_currentState.copyWith(
      deliveryStage: ActiveDeliveryStage.incomingOrder,
      activeOrderId: orderId,
      storeName: storeName,
      storeAddress: storeAddress,
      customerName: customerName,
      customerAddress: customerAddress,
      orderAmount: orderAmount,
    ));
  }

  /// Accept incoming order and transition to store pickup stage.
  void acceptOrder() {
    _emitState(_currentState.copyWith(
      deliveryStage: ActiveDeliveryStage.acceptedOrder,
    ));
  }

  /// Decline incoming order and revert to idle state.
  void declineOrder() {
    _emitState(_currentState.copyWith(
      deliveryStage: ActiveDeliveryStage.idle,
      clearActiveOrder: true,
    ));
  }

  /// Confirm store pickup and transition to navigation to customer stage.
  void confirmPickup() {
    _emitState(_currentState.copyWith(
      deliveryStage: ActiveDeliveryStage.navigatingToCustomer,
    ));
  }

  /// Complete delivery and update earnings and completed orders count synchronously.
  void completeDelivery({double? deliveryFee}) {
    final earningsAdded = deliveryFee ?? 0.0;
    _emitState(_currentState.copyWith(
      deliveryStage: ActiveDeliveryStage.deliveryCompleted,
      walletBalance: _currentState.walletBalance + earningsAdded,
      totalEarningsToday: _currentState.totalEarningsToday + earningsAdded,
      completedOrdersCount: _currentState.completedOrdersCount + 1,
    ));
    _syncEarningsToFirestore(earningsAdded);
  }

  /// Reset active order state machine back to idle.
  void resetOrder() {
    _emitState(_currentState.copyWith(
      deliveryStage: ActiveDeliveryStage.idle,
      clearActiveOrder: true,
    ));
  }
}
