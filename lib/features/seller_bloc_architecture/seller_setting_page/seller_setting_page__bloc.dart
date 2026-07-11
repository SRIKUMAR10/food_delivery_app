import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'seller_setting_page__event.dart';
import 'seller_setting_page__state.dart';

// Since we need to test a repository, we define a simple interface here.
// In a real app, this might interface with shared_preferences or an API.
abstract class SellerSettingRepository {
  Future<SellerSettingState> loadSettings();
  Future<void> saveSettings(SellerSettingState state);
}

class SellerSettingBloc extends Bloc<SellerSettingEvent, SellerSettingState> {
  final SellerSettingRepository repository;

  SellerSettingBloc({required this.repository}) : super(const SellerSettingState()) {
    on<LoadSellerSettings>(_onLoadSettings);
    on<UpdatePushNotifications>(_onUpdatePushNotifications);
    on<UpdateNewOrderSound>(_onUpdateNewOrderSound);
    on<UpdatePromoAndOffers>(_onUpdatePromoAndOffers);
    on<UpdateLowStockAlerts>(_onUpdateLowStockAlerts);
    on<UpdateOrderUpdates>(_onUpdateOrderUpdates);
    on<UpdateAppTheme>(_onUpdateAppTheme);
    on<UpdateLanguage>(_onUpdateLanguage);
  }

  Future<void> _onLoadSettings(LoadSellerSettings event, Emitter<SellerSettingState> emit) async {
    emit(state.copyWith(isLoading: true, error: null));
    try {
      final settings = await repository.loadSettings();
      emit(settings.copyWith(isLoading: false));
    } catch (e) {
      emit(state.copyWith(isLoading: false, error: e.toString()));
    }
  }

  Future<void> _onUpdatePushNotifications(UpdatePushNotifications event, Emitter<SellerSettingState> emit) async {
    final newState = state.copyWith(pushNotifications: event.enabled);
    emit(newState);
    await repository.saveSettings(newState);
  }

  Future<void> _onUpdateNewOrderSound(UpdateNewOrderSound event, Emitter<SellerSettingState> emit) async {
    final newState = state.copyWith(newOrderSound: event.enabled);
    emit(newState);
    await repository.saveSettings(newState);
  }

  Future<void> _onUpdatePromoAndOffers(UpdatePromoAndOffers event, Emitter<SellerSettingState> emit) async {
    final newState = state.copyWith(promoAndOffers: event.enabled);
    emit(newState);
    await repository.saveSettings(newState);
  }

  Future<void> _onUpdateLowStockAlerts(UpdateLowStockAlerts event, Emitter<SellerSettingState> emit) async {
    final newState = state.copyWith(lowStockAlerts: event.enabled);
    emit(newState);
    await repository.saveSettings(newState);
  }

  Future<void> _onUpdateOrderUpdates(UpdateOrderUpdates event, Emitter<SellerSettingState> emit) async {
    final newState = state.copyWith(orderUpdates: event.enabled);
    emit(newState);
    await repository.saveSettings(newState);
  }

  Future<void> _onUpdateAppTheme(UpdateAppTheme event, Emitter<SellerSettingState> emit) async {
    final newState = state.copyWith(appTheme: event.theme);
    emit(newState);
    await repository.saveSettings(newState);
  }

  Future<void> _onUpdateLanguage(UpdateLanguage event, Emitter<SellerSettingState> emit) async {
    final newState = state.copyWith(language: event.language);
    emit(newState);
    await repository.saveSettings(newState);
  }
}

class SellerSettingRepositoryImpl implements SellerSettingRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  Future<SellerSettingState> loadSettings() async {
    final sellerId = _auth.currentUser?.uid;
    if (sellerId == null) {
      return const SellerSettingState();
    }

    final docRef = _firestore.collection('seller_notification_settings').doc(sellerId);
    final snapshot = await docRef.get();

    if (snapshot.exists) {
      final data = snapshot.data()!;
      return SellerSettingState(
        pushNotifications: data['pushNotifications'] ?? true,
        newOrderSound: data['newOrderSound'] ?? true,
        promoAndOffers: data['promoAndOffers'] ?? false,
        lowStockAlerts: data['lowStockAlerts'] ?? true,
        orderUpdates: data['orderUpdates'] ?? true,
        appTheme: data['appTheme'] ?? 'Light',
        language: data['language'] ?? 'English',
      );
    }

    return const SellerSettingState();
  }

  @override
  Future<void> saveSettings(SellerSettingState state) async {
    final sellerId = _auth.currentUser?.uid;
    if (sellerId != null) {
      final docRef = _firestore.collection('seller_notification_settings').doc(sellerId);
      await docRef.set({
        'pushNotifications': state.pushNotifications,
        'newOrderSound': state.newOrderSound,
        'promoAndOffers': state.promoAndOffers,
        'lowStockAlerts': state.lowStockAlerts,
        'orderUpdates': state.orderUpdates,
        'appTheme': state.appTheme,
        'language': state.language,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    }
  }
}
