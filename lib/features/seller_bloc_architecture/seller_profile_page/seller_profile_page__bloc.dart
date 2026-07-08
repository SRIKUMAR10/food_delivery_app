import 'package:flutter_bloc/flutter_bloc.dart';
import 'seller_profile_page__event.dart';
import 'seller_profile_page__state.dart';

class SellerProfilePageBloc
    extends Bloc<SellerProfilePageEvent, SellerProfilePageState> {
  SellerProfilePageBloc() : super(ProfileInitial()) {
    on<LoadProfile>(_onLoadProfile);
    on<LogoutRequested>(_onLogoutRequested);
    on<NotificationSettingsChanged>(_onNotificationSettingsChanged);
  }

  Future<void> _onLoadProfile(
    LoadProfile event,
    Emitter<SellerProfilePageState> emit,
  ) async {
    emit(ProfileLoading());
    try {
      // Simulate network request
      await Future.delayed(const Duration(seconds: 1));
      
      // Load data (Ideally from a repository)
      emit(const ProfileLoaded(
        storeName: 'Picarhub Restaurant',
        email: 'seller@picarhub.com',
        phone: '+91 98765 43210',
        profileImageUrl: 'https://via.placeholder.com/150',
        notificationsEnabled: true,
      ));
    } catch (e) {
      emit(ProfileError(e.toString()));
    }
  }

  Future<void> _onLogoutRequested(
    LogoutRequested event,
    Emitter<SellerProfilePageState> emit,
  ) async {
    // Handle logout logic
    emit(ProfileInitial());
  }

  Future<void> _onNotificationSettingsChanged(
    NotificationSettingsChanged event,
    Emitter<SellerProfilePageState> emit,
  ) async {
    if (state is ProfileLoaded) {
      final currentState = state as ProfileLoaded;
      emit(ProfileLoaded(
        storeName: currentState.storeName,
        email: currentState.email,
        phone: currentState.phone,
        profileImageUrl: currentState.profileImageUrl,
        notificationsEnabled: event.isEnabled,
      ));
    }
  }
}
