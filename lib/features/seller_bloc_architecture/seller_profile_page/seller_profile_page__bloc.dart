import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:food_delivery_app/core/models/seller_model.dart';
import 'package:food_delivery_app/core/repositories/i_seller_profile_repository.dart';
import 'package:food_delivery_app/core/services/i_auth_service.dart';
import 'seller_profile_page__event.dart';
import 'seller_profile_page__state.dart';

class SellerProfilePageBloc
    extends Bloc<SellerProfilePageEvent, SellerProfilePageState> {
  final IAuthService authService;
  final ISellerProfileRepository profileRepository;
  StreamSubscription<Map<String, dynamic>>? _profileSubscription;

  SellerProfilePageBloc({
    required this.authService,
    required this.profileRepository,
  }) : super(ProfileInitial()) {
    on<LoadProfile>(_onLoadProfile);
    on<WatchProfileStarted>(_onWatchProfileStarted);
    on<ProfileUpdatedFromStream>(_onProfileUpdatedFromStream);
    on<LogoutRequested>(_onLogoutRequested);
    on<NotificationSettingsChanged>(_onNotificationSettingsChanged);
    on<SubmitVerificationForm>(_onSubmitVerificationForm);
    on<UpdateProfileImage>(_onUpdateProfileImage);
    on<UpdateCoverImage>(_onUpdateCoverImage);
    on<UpdateRestaurantIdentity>(_onUpdateRestaurantIdentity);
    on<UpdateLocationDetails>(_onUpdateLocationDetails);
    on<UpdateLogisticsSettings>(_onUpdateLogisticsSettings);
    on<UpdateCuisines>(_onUpdateCuisines);
    on<UpdateBusinessHoursSchedule>(_onUpdateBusinessHoursSchedule);
    on<ToggleAcceptingOrders>(_onToggleAcceptingOrders);
    on<ToggleStoreOpenStatus>(_onToggleStoreOpenStatus);
  }

  Future<void> _onLoadProfile(
    LoadProfile event,
    Emitter<SellerProfilePageState> emit,
  ) async {
    add(WatchProfileStarted());
  }

  Future<void> _onWatchProfileStarted(
    WatchProfileStarted event,
    Emitter<SellerProfilePageState> emit,
  ) async {
    if (state is! ProfileLoaded) {
      emit(ProfileLoading());
    }

    await _profileSubscription?.cancel();
    final String uid = authService.currentUserId ?? '';

    if (uid.isEmpty) {
      emit(const ProfileError('User not authenticated'));
      return;
    }

    try {
      // First load directly
      final directResult = await profileRepository.loadProfile(uid);
      final initialSeller = directResult['seller'] is SellerModel
          ? directResult['seller'] as SellerModel
          : ((directResult.isNotEmpty && (directResult['storeName'] != null || directResult['shopName'] != null || directResult['name'] != null))
              ? SellerModel.fromMap(directResult, id: uid)
              : null);
      if (initialSeller != null) {
        emit(_mapSellerToLoadedState(initialSeller));
      }

      // Then subscribe to live Firestore stream
      _profileSubscription = profileRepository.watchProfile(uid).listen(
        (data) {
          final seller = data['seller'] is SellerModel
              ? data['seller'] as SellerModel
              : ((data.isNotEmpty && (data['storeName'] != null || data['shopName'] != null || data['name'] != null))
                  ? SellerModel.fromMap(data, id: uid)
                  : null);
          add(ProfileUpdatedFromStream(seller));
        },
        onError: (error) {
          debugPrint('SellerProfilePageBloc Stream Error: $error');
        },
      );
    } catch (e) {
      emit(ProfileError(e.toString()));
    }
  }

  void _onProfileUpdatedFromStream(
    ProfileUpdatedFromStream event,
    Emitter<SellerProfilePageState> emit,
  ) {
    if (event.seller != null) {
      final currentLoaded = state is ProfileLoaded ? state as ProfileLoaded : null;
      final newState = _mapSellerToLoadedState(event.seller!);
      
      // Preserve local upload states if upload in progress
      if (currentLoaded != null && (currentLoaded.isImageUploading || currentLoaded.isCoverUploading)) {
        emit(newState.copyWith(
          isImageUploading: currentLoaded.isImageUploading,
          localImageBytes: currentLoaded.localImageBytes,
          isCoverUploading: currentLoaded.isCoverUploading,
          localCoverBytes: currentLoaded.localCoverBytes,
        ));
      } else {
        emit(newState);
      }
    } else {
      emit(
        ProfileLoaded(
          storeName: '',
          email: '',
          phone: '',
          profileImageUrl: '',
          coverImageUrl: '',
          notificationsEnabled: true,
          role: 'seller',
          createdAt: DateTime.now(),
          isVerified: false,
          verificationStatus: 'pending',
          address: '',
          restaurantDescription: '',
          cuisines: const [],
          isOpen: true,
          isAcceptingOrders: true,
          isActive: true,
        ),
      );
    }
  }

  ProfileLoaded _mapSellerToLoadedState(SellerModel s) {
    return ProfileLoaded(
      storeName: s.shopName ?? s.name,
      ownerName: s.ownerName ?? s.name,
      email: s.email,
      phone: s.phoneNumber ?? '',
      profileImageUrl: s.profileImageUrl ?? '',
      coverImageUrl: s.coverImageUrl ?? '',
      notificationsEnabled: s.notificationsEnabled,
      role: s.role.isNotEmpty ? s.role : 'seller',
      createdAt: s.createdAt,
      isVerified: s.isVerified,
      verificationStatus: s.verificationStatus ?? (s.isVerified ? 'verified' : 'pending'),
      address: s.address ?? s.businessDetails ?? '',
      restaurantDescription: s.restaurantDescription ?? s.businessDetails ?? '',
      latitude: s.latitude,
      longitude: s.longitude,
      googleMapsUrl: s.googleMapsUrl,
      cuisines: s.cuisines,
      minimumOrderValue: s.minimumOrderValue,
      deliveryRadius: s.deliveryRadius ?? 10.0,
      deliveryFeeSettings: s.deliveryFeeSettings,
      estimatedPrepTimeMinutes: s.estimatedPrepTimeMinutes ?? 25,
      openingHours: s.openingHours,
      closingTime: s.closingTime,
      weeklyHoliday: s.weeklyHoliday,
      isOpen: s.isOpen,
      isAcceptingOrders: s.isAcceptingOrders,
      isActive: s.isActive,
      gstNumber: s.gstNumber,
      fssaiLicense: s.fssaiNumber,
      panNumber: s.panNumber,
      bankAccountNumber: s.bankAccountNumber,
      bankName: s.bankName,
      ifscCode: s.ifscCode,
      accountHolderName: s.accountHolderName,
      bankBranch: s.bankBranch,
      taxConfiguration: s.taxConfiguration,
      deliveryTime: s.deliveryTime,
      deliveryArea: s.deliveryArea,
      businessDetails: s.businessDetails,
    );
  }

  Future<void> _onLogoutRequested(
    LogoutRequested event,
    Emitter<SellerProfilePageState> emit,
  ) async {
    await _profileSubscription?.cancel();
    emit(ProfileInitial());
  }

  Future<void> _onNotificationSettingsChanged(
    NotificationSettingsChanged event,
    Emitter<SellerProfilePageState> emit,
  ) async {
    if (state is ProfileLoaded) {
      final currentState = state as ProfileLoaded;
      emit(currentState.copyWith(notificationsEnabled: event.isEnabled));
      final String uid = authService.currentUserId ?? '';
      if (uid.isNotEmpty) {
        try {
          await profileRepository.updateProfile(uid, {
            'notificationsEnabled': event.isEnabled,
          });
        } catch (e) {
          debugPrint('Error updating notification setting: $e');
        }
      }
    }
  }

  Future<void> _onUpdateRestaurantIdentity(
    UpdateRestaurantIdentity event,
    Emitter<SellerProfilePageState> emit,
  ) async {
    if (state is ProfileLoaded) {
      final currentState = state as ProfileLoaded;
      emit(currentState.copyWith(
        storeName: event.storeName,
        ownerName: event.ownerName,
        restaurantDescription: event.description,
        email: event.email,
        phone: event.phone,
      ));

      final String uid = authService.currentUserId ?? '';
      if (uid.isNotEmpty) {
        try {
          await profileRepository.updateProfile(uid, {
            'shopName': event.storeName,
            'name': event.ownerName,
            'ownerName': event.ownerName,
            'restaurantDescription': event.description,
            'description': event.description,
            'businessDetails': event.description,
            'email': event.email,
            'phoneNumber': event.phone,
          });
        } catch (e) {
          debugPrint('Error updating restaurant identity: $e');
        }
      }
    }
  }

  Future<void> _onUpdateLocationDetails(
    UpdateLocationDetails event,
    Emitter<SellerProfilePageState> emit,
  ) async {
    if (state is ProfileLoaded) {
      final currentState = state as ProfileLoaded;
      emit(currentState.copyWith(
        address: event.address,
        latitude: event.latitude,
        longitude: event.longitude,
        googleMapsUrl: event.googleMapsUrl,
      ));

      final String uid = authService.currentUserId ?? '';
      if (uid.isNotEmpty) {
        try {
          await profileRepository.updateProfile(uid, {
            'address': event.address,
            'latitude': event.latitude,
            'longitude': event.longitude,
            'googleMapsUrl': event.googleMapsUrl,
          });
        } catch (e) {
          debugPrint('Error updating location details: $e');
        }
      }
    }
  }

  Future<void> _onUpdateLogisticsSettings(
    UpdateLogisticsSettings event,
    Emitter<SellerProfilePageState> emit,
  ) async {
    if (state is ProfileLoaded) {
      final currentState = state as ProfileLoaded;
      emit(currentState.copyWith(
        minimumOrderValue: event.minimumOrderValue,
        deliveryRadius: event.deliveryRadius,
        deliveryFeeSettings: event.deliveryFeeSettings,
        estimatedPrepTimeMinutes: event.estimatedPrepTimeMinutes,
      ));

      final String uid = authService.currentUserId ?? '';
      if (uid.isNotEmpty) {
        try {
          await profileRepository.updateProfile(uid, {
            'minimumOrderValue': event.minimumOrderValue,
            'deliveryRadius': event.deliveryRadius,
            'deliveryFeeSettings': event.deliveryFeeSettings.toMap(),
            'estimatedPrepTimeMinutes': event.estimatedPrepTimeMinutes,
            'prepTimeMinutes': event.estimatedPrepTimeMinutes,
          });
        } catch (e) {
          debugPrint('Error updating logistics settings: $e');
        }
      }
    }
  }

  Future<void> _onUpdateCuisines(
    UpdateCuisines event,
    Emitter<SellerProfilePageState> emit,
  ) async {
    if (state is ProfileLoaded) {
      final currentState = state as ProfileLoaded;
      emit(currentState.copyWith(cuisines: event.cuisines));

      final String uid = authService.currentUserId ?? '';
      if (uid.isNotEmpty) {
        try {
          await profileRepository.updateProfile(uid, {
            'cuisines': event.cuisines,
          });
        } catch (e) {
          debugPrint('Error updating cuisines: $e');
        }
      }
    }
  }

  Future<void> _onUpdateBusinessHoursSchedule(
    UpdateBusinessHoursSchedule event,
    Emitter<SellerProfilePageState> emit,
  ) async {
    if (state is ProfileLoaded) {
      final currentState = state as ProfileLoaded;
      emit(currentState.copyWith(
        openingHours: event.openingHours,
        closingTime: event.closingTime,
        weeklyHoliday: event.weeklyHoliday,
      ));

      final String uid = authService.currentUserId ?? '';
      if (uid.isNotEmpty) {
        try {
          await profileRepository.updateProfile(uid, {
            'openingHours': event.openingHours,
            'closingTime': event.closingTime,
            'weeklyHoliday': event.weeklyHoliday,
          });
        } catch (e) {
          debugPrint('Error updating business hours schedule: $e');
        }
      }
    }
  }

  Future<void> _onToggleAcceptingOrders(
    ToggleAcceptingOrders event,
    Emitter<SellerProfilePageState> emit,
  ) async {
    if (state is ProfileLoaded) {
      final currentState = state as ProfileLoaded;
      emit(currentState.copyWith(isAcceptingOrders: event.isAcceptingOrders));

      final String uid = authService.currentUserId ?? '';
      if (uid.isNotEmpty) {
        try {
          await profileRepository.updateOperationalStatus(
            uid,
            isAcceptingOrders: event.isAcceptingOrders,
          );
        } catch (e) {
          debugPrint('Error toggling accepting orders: $e');
        }
      }
    }
  }

  Future<void> _onToggleStoreOpenStatus(
    ToggleStoreOpenStatus event,
    Emitter<SellerProfilePageState> emit,
  ) async {
    if (state is ProfileLoaded) {
      final currentState = state as ProfileLoaded;
      emit(currentState.copyWith(isOpen: event.isOpen));

      final String uid = authService.currentUserId ?? '';
      if (uid.isNotEmpty) {
        try {
          await profileRepository.updateOperationalStatus(
            uid,
            isOpen: event.isOpen,
          );
        } catch (e) {
          debugPrint('Error toggling store open status: $e');
        }
      }
    }
  }

  Future<void> _onSubmitVerificationForm(
    SubmitVerificationForm event,
    Emitter<SellerProfilePageState> emit,
  ) async {
    if (state is ProfileLoaded) {
      final currentState = state as ProfileLoaded;
      emit(currentState.copyWith(
        storeName: event.storeName,
        email: event.email,
        phone: event.phone,
        address: event.address,
        gstNumber: event.gstNumber,
        fssaiLicense: event.fssaiLicense,
        bankAccountNumber: event.bankAccountNumber,
        ifscCode: event.ifscCode,
        taxConfiguration: event.taxConfiguration,
      ));

      final String uid = authService.currentUserId ?? '';
      if (uid.isNotEmpty) {
        try {
          await profileRepository.updateProfile(uid, {
            'shopName': event.storeName,
            'email': event.email,
            'phoneNumber': event.phone,
            'businessDetails': event.address,
            'address': event.address,
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
    }
  }

  Future<void> _onUpdateProfileImage(
    UpdateProfileImage event,
    Emitter<SellerProfilePageState> emit,
  ) async {
    if (state is ProfileLoaded) {
      final currentState = state as ProfileLoaded;

      emit(currentState.copyWith(
        isImageUploading: true,
        localImageBytes: event.imageBytes,
      ));

      try {
        final String uid = authService.currentUserId ?? '';
        if (uid.isEmpty) {
          emit(currentState.copyWith(isImageUploading: false, localImageBytes: null));
          return;
        }

        final downloadUrl = await profileRepository.uploadProfileImage(
          sellerId: uid,
          fileName: event.fileName,
          imageBytes: event.imageBytes,
        );

        await profileRepository.updateProfile(uid, {
          'profileImageUrl': downloadUrl,
        });

        emit(currentState.copyWith(
          profileImageUrl: downloadUrl,
          isImageUploading: false,
          localImageBytes: null,
        ));
      } catch (e) {
        emit(currentState.copyWith(
          isImageUploading: false,
          localImageBytes: null,
        ));
        debugPrint('Error uploading profile image: $e');
      }
    }
  }

  Future<void> _onUpdateCoverImage(
    UpdateCoverImage event,
    Emitter<SellerProfilePageState> emit,
  ) async {
    if (state is ProfileLoaded) {
      final currentState = state as ProfileLoaded;

      emit(currentState.copyWith(
        isCoverUploading: true,
        localCoverBytes: event.imageBytes,
      ));

      try {
        final String uid = authService.currentUserId ?? '';
        if (uid.isEmpty) {
          emit(currentState.copyWith(isCoverUploading: false, localCoverBytes: null));
          return;
        }

        final downloadUrl = await profileRepository.uploadCoverImage(
          sellerId: uid,
          fileName: event.fileName,
          imageBytes: event.imageBytes,
        );

        await profileRepository.updateProfile(uid, {
          'coverImageUrl': downloadUrl,
        });

        emit(currentState.copyWith(
          coverImageUrl: downloadUrl,
          isCoverUploading: false,
          localCoverBytes: null,
        ));
      } catch (e) {
        emit(currentState.copyWith(
          isCoverUploading: false,
          localCoverBytes: null,
        ));
        debugPrint('Error uploading cover image: $e');
      }
    }
  }

  @override
  Future<void> close() {
    _profileSubscription?.cancel();
    return super.close();
  }
}

