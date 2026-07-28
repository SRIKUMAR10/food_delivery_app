import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'PaymentMethods_Event.dart';
import 'PaymentMethods_State.dart';

class PaymentMethodsRepository {
  FirebaseFirestore get _firestore => FirebaseFirestore.instance;
  FirebaseAuth get _auth => FirebaseAuth.instance;

  String? get _uid => _auth.currentUser?.uid;

  Stream<List<PaymentMethodModel>> streamPaymentMethods() {
    final uid = _uid;
    if (uid == null) return Stream.value([]);
    return _firestore
        .collection('users')
        .doc(uid)
        .collection('payment_methods')
        .orderBy('createdAt', descending: false)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return PaymentMethodModel.fromMap(doc.id, doc.data());
      }).toList();
    });
  }

  Future<void> addPaymentMethod({
    required String type,
    required String maskedNumber,
    required String lastFourDigits,
    String? expiryDate,
    String? cardholderName,
    String? upiId,
    String? billingAddress,
    required bool isDefault,
  }) async {
    final uid = _uid;
    if (uid == null) throw Exception('User not authenticated');

    final batch = _firestore.batch();
    final methodsRef = _firestore
        .collection('users')
        .doc(uid)
        .collection('payment_methods');

    if (isDefault) {
      final existingSnapshot = await methodsRef.where('isDefault', isEqualTo: true).get();
      for (final doc in existingSnapshot.docs) {
        batch.update(doc.reference, {'isDefault': false});
      }
    }

    final newDocRef = methodsRef.doc();
    batch.set(newDocRef, {
      'type': type,
      'maskedNumber': maskedNumber,
      'lastFourDigits': lastFourDigits,
      if (expiryDate != null) 'expiryDate': expiryDate,
      if (cardholderName != null) 'cardholderName': cardholderName,
      if (upiId != null) 'upiId': upiId,
      if (billingAddress != null) 'billingAddress': billingAddress,
      'isDefault': isDefault,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });

    await batch.commit();
  }

  Future<void> updatePaymentMethod({
    required String methodId,
    String? expiryDate,
    String? cardholderName,
    String? billingAddress,
    bool? isDefault,
  }) async {
    final uid = _uid;
    if (uid == null) throw Exception('User not authenticated');

    final batch = _firestore.batch();
    final methodRef = _firestore
        .collection('users')
        .doc(uid)
        .collection('payment_methods')
        .doc(methodId);

    if (isDefault == true) {
      final existingSnapshot = await _firestore
          .collection('users')
          .doc(uid)
          .collection('payment_methods')
          .where('isDefault', isEqualTo: true)
          .get();
      for (final doc in existingSnapshot.docs) {
        if (doc.id != methodId) {
          batch.update(doc.reference, {'isDefault': false});
        }
      }
    }

    final updateData = <String, dynamic>{
      'updatedAt': FieldValue.serverTimestamp(),
    };
    if (expiryDate != null) updateData['expiryDate'] = expiryDate;
    if (cardholderName != null) updateData['cardholderName'] = cardholderName;
    if (billingAddress != null) updateData['billingAddress'] = billingAddress;
    if (isDefault != null) updateData['isDefault'] = isDefault;

    batch.update(methodRef, updateData);
    await batch.commit();
  }

  Future<void> deletePaymentMethod(String methodId) async {
    final uid = _uid;
    if (uid == null) throw Exception('User not authenticated');

    await _firestore
        .collection('users')
        .doc(uid)
        .collection('payment_methods')
        .doc(methodId)
        .delete();
  }

  Future<void> setDefault(String methodId) async {
    final uid = _uid;
    if (uid == null) throw Exception('User not authenticated');

    final batch = _firestore.batch();
    final methodsRef = _firestore
        .collection('users')
        .doc(uid)
        .collection('payment_methods');

    final existingSnapshot = await methodsRef.where('isDefault', isEqualTo: true).get();
    for (final doc in existingSnapshot.docs) {
      if (doc.id != methodId) {
        batch.update(doc.reference, {'isDefault': false});
      }
    }

    batch.update(methodsRef.doc(methodId), {'isDefault': true});
    await batch.commit();
  }
}

class PaymentMethodsBloc
    extends Bloc<PaymentMethodsEvent, PaymentMethodsState> {
  final PaymentMethodsRepository _repository;

  PaymentMethodsBloc(this._repository)
      : super(const PaymentMethodsState()) {
    on<LoadPaymentMethods>(_onLoad);
    on<AddPaymentMethod>(_onAdd);
    on<UpdatePaymentMethod>(_onUpdate);
    on<DeletePaymentMethod>(_onDelete);
    on<SetDefaultPaymentMethod>(_onSetDefault);
    on<ClearPaymentMethodsMessage>(_onClearMessage);
  }

  Future<void> _onLoad(
    LoadPaymentMethods event,
    Emitter<PaymentMethodsState> emit,
  ) async {
    emit(state.copyWith(status: PaymentMethodsStatus.loading));
    try {
      await emit.forEach<List<PaymentMethodModel>>(
        _repository.streamPaymentMethods(),
        onData: (methods) {
          return state.copyWith(
            status: PaymentMethodsStatus.loaded,
            methods: methods,
          );
        },
        onError: (e, stackTrace) {
          return state.copyWith(
            status: PaymentMethodsStatus.error,
            errorMessage: 'Failed to load payment methods: $e',
          );
        },
      );
    } catch (e) {
      emit(state.copyWith(
        status: PaymentMethodsStatus.error,
        errorMessage: 'Failed to load payment methods: $e',
      ));
    }
  }

  Future<void> _onAdd(
    AddPaymentMethod event,
    Emitter<PaymentMethodsState> emit,
  ) async {
    emit(state.copyWith(isSaving: true, clearError: true));
    try {
      final raw = event.cardNumber.replaceAll(RegExp(r'\s+'), '');
      final lastFour = raw.length >= 4 ? raw.substring(raw.length - 4) : raw;
      final masked = '**** $lastFour';

      await _repository.addPaymentMethod(
        type: event.type,
        maskedNumber: masked,
        lastFourDigits: lastFour,
        expiryDate: event.expiryDate,
        cardholderName: event.cardholderName,
        upiId: event.upiId,
        billingAddress: event.billingAddress,
        isDefault: event.isDefault,
      );
      emit(state.copyWith(isSaving: false, successMessage: 'Payment method added'));
    } catch (e) {
      emit(state.copyWith(
        isSaving: false,
        errorMessage: 'Failed to add payment method: $e',
      ));
    }
  }

  Future<void> _onUpdate(
    UpdatePaymentMethod event,
    Emitter<PaymentMethodsState> emit,
  ) async {
    emit(state.copyWith(isSaving: true, clearError: true));
    try {
      await _repository.updatePaymentMethod(
        methodId: event.methodId,
        expiryDate: event.expiryDate,
        cardholderName: event.cardholderName,
        billingAddress: event.billingAddress,
        isDefault: event.isDefault,
      );
      emit(state.copyWith(isSaving: false, successMessage: 'Payment method updated'));
    } catch (e) {
      emit(state.copyWith(
        isSaving: false,
        errorMessage: 'Failed to update payment method: $e',
      ));
    }
  }

  Future<void> _onDelete(
    DeletePaymentMethod event,
    Emitter<PaymentMethodsState> emit,
  ) async {
    emit(state.copyWith(isSaving: true, clearError: true));
    try {
      await _repository.deletePaymentMethod(event.methodId);
      emit(state.copyWith(isSaving: false, successMessage: 'Payment method removed'));
    } catch (e) {
      emit(state.copyWith(
        isSaving: false,
        errorMessage: 'Failed to delete payment method: $e',
      ));
    }
  }

  Future<void> _onSetDefault(
    SetDefaultPaymentMethod event,
    Emitter<PaymentMethodsState> emit,
  ) async {
    try {
      await _repository.setDefault(event.methodId);
    } catch (e) {
      emit(state.copyWith(errorMessage: 'Failed to set default: $e'));
    }
  }

  void _onClearMessage(
    ClearPaymentMethodsMessage event,
    Emitter<PaymentMethodsState> emit,
  ) {
    emit(state.copyWith(clearError: true, clearSuccess: true));
  }

  @override
  Future<void> close() {
    return super.close();
  }
}
