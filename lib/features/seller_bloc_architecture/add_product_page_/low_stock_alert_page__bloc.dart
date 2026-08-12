import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'low_stock_alert_page__event.dart';
import 'low_stock_alert_page__state.dart';

class LowStockAlertBloc extends Bloc<LowStockAlertEvent, LowStockAlertState> {
  final FirebaseFirestore? _firestoreParam;
  final FirebaseAuth? _authParam;

  FirebaseFirestore get _firestore => _firestoreParam ?? FirebaseFirestore.instance;
  FirebaseAuth get _auth => _authParam ?? FirebaseAuth.instance;

  LowStockAlertBloc({FirebaseFirestore? firestore, FirebaseAuth? auth})
      : _firestoreParam = firestore,
        _authParam = auth,
        super(LowStockAlertInitial()) {
    on<LoadLowStockData>(_onLoadLowStockData);
    on<RefreshLowStockData>(_onRefreshLowStockData);
  }

  Future<void> _onLoadLowStockData(
    LoadLowStockData event,
    Emitter<LowStockAlertState> emit,
  ) async {
    emit(LowStockAlertLoading());
    try {
      String? sellerId;
      try {
        sellerId = _auth.currentUser?.uid;
      } catch (_) {
        sellerId = null;
      }

      if (sellerId == null) {
        emit(const LowStockAlertLoaded(items: [], totalLowStockCount: 0));
        return;
      }

      final snapshot = await _firestore
          .collection('products')
          .where('sellerId', isEqualTo: sellerId)
          .get();

      final lowStockItems = <LowStockItem>[];

      for (var doc in snapshot.docs) {
        final data = doc.data();
        final quantity = (data['quantity'] as num?)?.toDouble() ?? 0.0;
        final lowStockThreshold = (data['lowStockThreshold'] as num?)?.toDouble() ?? 5.0;

        if (quantity <= lowStockThreshold) {
          lowStockItems.add(LowStockItem(
            id: doc.id,
            name: data['name'] as String? ?? 'Item',
            quantity: quantity,
            unit: data['unit'] as String? ?? 'pcs',
            iconPath: data['imageUrl'] as String? ?? 'default_icon',
            colorHex: quantity == 0 ? 0xFFEF4444 : 0xFFF59E0B,
          ));
        }
      }

      emit(LowStockAlertLoaded(items: lowStockItems, totalLowStockCount: lowStockItems.length));
    } catch (e) {
      if (e.toString().contains('no-app')) {
        emit(const LowStockAlertLoaded(items: [], totalLowStockCount: 0));
      } else {
        emit(LowStockAlertError(message: 'Failed to load low stock items. Please try again.'));
      }
    }
  }

  Future<void> _onRefreshLowStockData(
    RefreshLowStockData event,
    Emitter<LowStockAlertState> emit,
  ) async {
    // Just reload the data to simulate refresh
    add(LoadLowStockData());
  }
}
