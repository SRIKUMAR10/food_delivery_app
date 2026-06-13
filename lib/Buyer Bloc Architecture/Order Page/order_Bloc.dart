import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'order_Event.dart';
import 'order_State.dart';
import 'order_models.dart';

class OrderBloc extends Bloc<OrderEvent, OrderState> {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  OrderBloc({FirebaseFirestore? firestore, FirebaseAuth? auth}) 
      : _firestore = firestore ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance,
        super(OrderInitial()) {
    on<LoadOrdersRequested>(_onLoadOrdersRequested);
  }

  Future<void> _onLoadOrdersRequested(
    LoadOrdersRequested event,
    Emitter<OrderState> emit,
  ) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) {
      emit(const OrderLoaded([]));
      return;
    }

    emit(OrderLoading());

    await emit.forEach<QuerySnapshot>(
      _firestore
          .collection('users')
          .doc(uid)
          .collection('orders')
          .orderBy('date', descending: true)
          .snapshots(),
      onData: (snapshot) {
        final orders = snapshot.docs
            .map((doc) => OrderModel.fromFirestore(doc))
            .toList();
        return OrderLoaded(orders);
      },
      onError: (error, stackTrace) => OrderError(error.toString()),
    );
  }
}
