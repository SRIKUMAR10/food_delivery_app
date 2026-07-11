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
      final String uid = FirebaseAuth.instance.currentUser?.uid ?? '';
      
      if (uid.isNotEmpty) {
        final seller = await SellerCollection().getSeller(uid);
        
        if (seller != null) {
          emit(ProfileLoaded(
            storeName: seller.shopName ?? (seller.name.isNotEmpty ? seller.name : 'Picarhub Restaurant'),
            email: seller.email.isNotEmpty ? seller.email : 'seller@picarhub.com',
            phone: seller.phoneNumber ?? '+91 98765 43210',
            profileImageUrl: seller.profileImageUrl ?? 'https://via.placeholder.com/150',
            notificationsEnabled: seller.notificationsEnabled,
            address: seller.businessDetails ?? '123 Main Street',
            gstNumber: seller.gstNumber,
            fssaiLicense: seller.fssaiNumber,
            bankAccountNumber: seller.bankAccountNumber,
            ifscCode: seller.ifscCode,
            taxConfiguration: seller.taxConfiguration,
            role: seller.role.isNotEmpty ? seller.role : 'seller',
            createdAt: seller.createdAt,
            isVerified: seller.isVerified,
            bankName: seller.bankName,
            accountHolderName: seller.accountHolderName,
            bankBranch: seller.bankBranch,
            panNumber: seller.panNumber,
            openingHours: seller.openingHours,
            deliveryTime: seller.deliveryTime,
            deliveryArea: seller.deliveryArea,
            businessDetails: seller.businessDetails,
          ));
          return;
        }
      }
      
      // Fallback if no user is logged in or seller not found
      emit(ProfileLoaded(
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
        role: 'Restaurant Owner',
        createdAt: DateTime.now(),
        isVerified: true,
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
        role: currentState.role,
        createdAt: currentState.createdAt,
        isVerified: currentState.isVerified,
        bankName: currentState.bankName,
        accountHolderName: currentState.accountHolderName,
        bankBranch: currentState.bankBranch,
        panNumber: currentState.panNumber,
        openingHours: currentState.openingHours,
        deliveryTime: currentState.deliveryTime,
        deliveryArea: currentState.deliveryArea,
        businessDetails: currentState.businessDetails,
      ));
    }
  }

  Future<void> _onSubmitVerificationForm(
    SubmitVerificationForm event,
    Emitter<SellerProfilePageState> emit,
  ) async {
    if (state is ProfileLoaded) {
      final currentState = state as ProfileLoaded;
      
      final String uid = FirebaseAuth.instance.currentUser?.uid ?? '';
      if (uid.isNotEmpty) {
        try {
          await SellerCollection().updateSeller(uid, {
            'shopName': event.storeName,
            'email': event.email,
            'phoneNumber': event.phone,
            'businessDetails': event.address,
            'gstNumber': event.gstNumber,
            'fssaiNumber': event.fssaiLicense,
            'bankAccountNumber': event.bankAccountNumber,
            'ifscCode': event.ifscCode,
            'taxConfiguration': event.taxConfiguration,
          });
        } catch (e) {
          print('Error updating verification form: $e');
        }
      }

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
        role: currentState.role,
        createdAt: currentState.createdAt,
        isVerified: currentState.isVerified,
        bankName: currentState.bankName,
        accountHolderName: currentState.accountHolderName,
        bankBranch: currentState.bankBranch,
        panNumber: currentState.panNumber,
        openingHours: currentState.openingHours,
        deliveryTime: currentState.deliveryTime,
        deliveryArea: currentState.deliveryArea,
        businessDetails: currentState.businessDetails,
      ));
    }
  }

  Future<void> _onUpdateProfileImage(
    UpdateProfileImage event,
    Emitter<SellerProfilePageState> emit,
  ) async {
    if (state is ProfileLoaded) {
      final currentState = state as ProfileLoaded;
      
      // Optimistic UI update: Show the selected image immediately
      emit(ProfileLoaded(
        storeName: currentState.storeName,
        email: currentState.email,
        phone: currentState.phone,
        profileImageUrl: currentState.profileImageUrl,
        notificationsEnabled: currentState.notificationsEnabled,
        address: currentState.address,
        gstNumber: currentState.gstNumber,
        fssaiLicense: currentState.fssaiLicense,
        bankAccountNumber: currentState.bankAccountNumber,
        ifscCode: currentState.ifscCode,
        taxConfiguration: currentState.taxConfiguration,
        role: currentState.role,
        createdAt: currentState.createdAt,
        isVerified: currentState.isVerified,
        bankName: currentState.bankName,
        accountHolderName: currentState.accountHolderName,
        bankBranch: currentState.bankBranch,
        panNumber: currentState.panNumber,
        openingHours: currentState.openingHours,
        deliveryTime: currentState.deliveryTime,
        deliveryArea: currentState.deliveryArea,
        businessDetails: currentState.businessDetails,
        isImageUploading: true,
        localImageBytes: event.imageBytes,
      ));

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
          role: currentState.role,
          createdAt: currentState.createdAt,
          isVerified: currentState.isVerified,
          bankName: currentState.bankName,
          accountHolderName: currentState.accountHolderName,
          bankBranch: currentState.bankBranch,
          panNumber: currentState.panNumber,
          openingHours: currentState.openingHours,
          deliveryTime: currentState.deliveryTime,
          deliveryArea: currentState.deliveryArea,
          businessDetails: currentState.businessDetails,
          isImageUploading: false,
          localImageBytes: null, // Clear local image, rely on network url now
        ));
      } catch (e) {
        // On error, revert optimistic update
        emit(ProfileLoaded(
          storeName: currentState.storeName,
          email: currentState.email,
          phone: currentState.phone,
          profileImageUrl: currentState.profileImageUrl, // old url
          notificationsEnabled: currentState.notificationsEnabled,
          address: currentState.address,
          gstNumber: currentState.gstNumber,
          fssaiLicense: currentState.fssaiLicense,
          bankAccountNumber: currentState.bankAccountNumber,
          ifscCode: currentState.ifscCode,
          taxConfiguration: currentState.taxConfiguration,
          role: currentState.role,
          createdAt: currentState.createdAt,
          isVerified: currentState.isVerified,
          bankName: currentState.bankName,
          accountHolderName: currentState.accountHolderName,
          bankBranch: currentState.bankBranch,
          panNumber: currentState.panNumber,
          openingHours: currentState.openingHours,
          deliveryTime: currentState.deliveryTime,
          deliveryArea: currentState.deliveryArea,
          businessDetails: currentState.businessDetails,
          isImageUploading: false,
          localImageBytes: null,
        ));
        print('Error uploading image: $e');
      }
    }
  }
}
