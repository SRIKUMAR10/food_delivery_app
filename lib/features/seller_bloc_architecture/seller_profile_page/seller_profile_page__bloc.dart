import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:food_delivery_app/core/repositories/i_seller_profile_repository.dart';
import 'package:food_delivery_app/core/services/i_auth_service.dart';
import 'seller_profile_page__event.dart';
import 'seller_profile_page__state.dart';

class SellerProfilePageBloc
    extends Bloc<SellerProfilePageEvent, SellerProfilePageState> {
  final IAuthService authService;
  final ISellerProfileRepository profileRepository;

  SellerProfilePageBloc({
    required this.authService,
    required this.profileRepository,
  }) : super(ProfileInitial()) {
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
      final String uid = authService.currentUserId ?? '';

      if (uid.isNotEmpty) {
        final result = await profileRepository.loadProfile(uid);
        final seller = result['seller'];
        if (seller != null) {
          final s = seller as dynamic;
          emit(
            ProfileLoaded(
              storeName: s.shopName ?? (s.name.isNotEmpty ? s.name : 'Picarhub Restaurant'),
              email: s.email.isNotEmpty ? s.email : 'seller@picarhub.com',
              phone: s.phoneNumber ?? '+91 98765 43210',
              profileImageUrl: s.profileImageUrl ?? 'https://via.placeholder.com/150',
              notificationsEnabled: s.notificationsEnabled,
              address: s.businessDetails ?? '123 Main Street',
              gstNumber: s.gstNumber,
              fssaiLicense: s.fssaiNumber,
              bankAccountNumber: s.bankAccountNumber,
              ifscCode: s.ifscCode,
              taxConfiguration: s.taxConfiguration,
              role: s.role.isNotEmpty ? s.role : 'seller',
              createdAt: s.createdAt,
              isVerified: s.isVerified,
              bankName: s.bankName,
              accountHolderName: s.accountHolderName,
              bankBranch: s.bankBranch,
              panNumber: s.panNumber,
              openingHours: s.openingHours,
              deliveryTime: s.deliveryTime,
              deliveryArea: s.deliveryArea,
              businessDetails: s.businessDetails,
            ),
          );
          return;
        }
      }

      emit(
        ProfileLoaded(
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
        ),
      );
    } catch (e) {
      emit(ProfileError(e.toString()));
    }
  }

  Future<void> _onLogoutRequested(
    LogoutRequested event,
    Emitter<SellerProfilePageState> emit,
  ) async {
    emit(ProfileInitial());
  }

  Future<void> _onNotificationSettingsChanged(
    NotificationSettingsChanged event,
    Emitter<SellerProfilePageState> emit,
  ) async {
    if (state is ProfileLoaded) {
      final currentState = state as ProfileLoaded;
      emit(
        ProfileLoaded(
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
        ),
      );
    }
  }

  Future<void> _onSubmitVerificationForm(
    SubmitVerificationForm event,
    Emitter<SellerProfilePageState> emit,
  ) async {
    if (state is ProfileLoaded) {
      final currentState = state as ProfileLoaded;
      final String uid = authService.currentUserId ?? '';
      if (uid.isNotEmpty) {
        try {
          await profileRepository.updateProfile(uid, {
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
          debugPrint('Error updating verification form: $e');
        }
      }

      emit(
        ProfileLoaded(
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
        ),
      );
    }
  }

  Future<void> _onUpdateProfileImage(
    UpdateProfileImage event,
    Emitter<SellerProfilePageState> emit,
  ) async {
    if (state is ProfileLoaded) {
      final currentState = state as ProfileLoaded;

      emit(
        ProfileLoaded(
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
        ),
      );

      try {
        final String uid = authService.currentUserId ?? '';
        final effectiveUid = uid.isNotEmpty ? uid : 'default_seller';

        final downloadUrl = await profileRepository.uploadProfileImage(
          sellerId: effectiveUid,
          fileName: event.fileName,
          imageBytes: event.imageBytes,
        );

        await profileRepository.updateProfile(effectiveUid, {
          'profileImageUrl': downloadUrl,
        });

        emit(
          ProfileLoaded(
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
            localImageBytes: null,
          ),
        );
      } catch (e) {
        emit(
          ProfileLoaded(
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
            isImageUploading: false,
            localImageBytes: null,
          ),
        );
        debugPrint('Error uploading image: $e');
      }
    }
  }
}
