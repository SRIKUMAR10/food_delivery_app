import 'dart:typed_data';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../../app_data_collection/seller_collections/seller_collection.dart';
import 'seller_profile_page__event.dart';
import 'seller_profile_page__state.dart';

class SellerProfilePageBloc
    extends Bloc<SellerProfilePageEvent, SellerProfilePageState> {
  SellerProfilePageBloc() : super(ProfileInitial()) {
    on<LoadProfile>(_onLoadProfile);
    on<LogoutRequested>(_onLogoutRequested);
    on<NotificationSettingsChanged>(_onNotificationSettingsChanged);
    on<SubmitVerificationForm>(_onSubmitVerificationForm);
    on<UpdateProfileImage>(_onUpdateProfileImage);
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
        address: '123 Main Street',
        gstNumber: '22AAAAA0000A1Z5',
        fssaiLicense: '10012011000000',
        bankAccountNumber: '000000000000',
        ifscCode: 'SBIN0000000',
        taxConfiguration: '5%',
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
        address: currentState.address,
        gstNumber: currentState.gstNumber,
        fssaiLicense: currentState.fssaiLicense,
        bankAccountNumber: currentState.bankAccountNumber,
        ifscCode: currentState.ifscCode,
        taxConfiguration: currentState.taxConfiguration,
      ));
    }
  }

  Future<void> _onSubmitVerificationForm(
    SubmitVerificationForm event,
    Emitter<SellerProfilePageState> emit,
  ) async {
    if (state is ProfileLoaded) {
      final currentState = state as ProfileLoaded;
      emit(ProfileLoaded(
        storeName: event.storeName,
        email: event.email,
        phone: event.phone,
        profileImageUrl: currentState.profileImageUrl,
        notificationsEnabled: currentState.notificationsEnabled,
        address: event.address,
        gstNumber: event.gstNumber,
        fssaiLicense: event.fssaiLicense,
        bankAccountNumber: event.bankAccountNumber,
        ifscCode: event.ifscCode,
        taxConfiguration: event.taxConfiguration,
      ));
    }
  }

  Future<void> _onUpdateProfileImage(
    UpdateProfileImage event,
    Emitter<SellerProfilePageState> emit,
  ) async {
    if (state is ProfileLoaded) {
      final currentState = state as ProfileLoaded;
      try {
        final String uid = FirebaseAuth.instance.currentUser?.uid ?? 'unknown_user';
        final String fileName = 'profile_images/$uid/${event.fileName}';
        
        final Reference storageRef = FirebaseStorage.instance.ref().child(fileName);
        final UploadTask uploadTask = storageRef.putData(event.imageBytes);
        final TaskSnapshot snapshot = await uploadTask;
        
        final String downloadUrl = await snapshot.ref.getDownloadURL();
        
        // Update Firestore
        if (uid != 'unknown_user') {
          await SellerCollection().updateSeller(uid, {
            'profileImageUrl': downloadUrl,
          });
        }
        
        emit(ProfileLoaded(
          storeName: currentState.storeName,
          email: currentState.email,
          phone: currentState.phone,
          profileImageUrl: downloadUrl,
          notificationsEnabled: currentState.notificationsEnabled,
          address: currentState.address,
          gstNumber: currentState.gstNumber,
          fssaiLicense: currentState.fssaiLicense,
          bankAccountNumber: currentState.bankAccountNumber,
          ifscCode: currentState.ifscCode,
          taxConfiguration: currentState.taxConfiguration,
        ));
      } catch (e) {
        // You could emit an error state here, but for now we'll just ignore or log it
        print('Error uploading image: $e');
      }
    }
  }
}
