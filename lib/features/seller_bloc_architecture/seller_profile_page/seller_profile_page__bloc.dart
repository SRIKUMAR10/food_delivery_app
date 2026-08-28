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
  StreamSubscription<Map<String, dynamic>>? _kycSubscription;

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
    on<LoadSellerKycDocuments>(_onLoadSellerKycDocuments);
    on<KycDocumentsStreamUpdated>(_onKycDocumentsStreamUpdated);
    on<SubmitSellerKycDocuments>(_onSubmitSellerKycDocuments);
    on<UploadKycDocumentFileEvent>(_onUploadKycDocumentFileEvent);
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
    await _kycSubscription?.cancel();
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

      _kycSubscription = profileRepository.watchKycDocuments(uid).listen(
        (kycData) {
          add(KycDocumentsStreamUpdated(kycData));
        },
        onError: (error) {
          debugPrint('SellerProfilePageBloc KYC Stream Error: $error');
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
      if (currentLoaded != null && (currentLoaded.isImageUploading || currentLoaded.isCoverUploading || currentLoaded.isKycUploading)) {
        emit(newState.copyWith(
          isImageUploading: currentLoaded.isImageUploading,
          localImageBytes: currentLoaded.localImageBytes,
          isCoverUploading: currentLoaded.isCoverUploading,
          localCoverBytes: currentLoaded.localCoverBytes,
          isKycUploading: currentLoaded.isKycUploading,
          kycStatus: currentLoaded.kycStatus.isNotEmpty ? currentLoaded.kycStatus : newState.kycStatus,
          fssaiCertificateUrl: currentLoaded.fssaiCertificateUrl ?? newState.fssaiCertificateUrl,
          gstCertificateUrl: currentLoaded.gstCertificateUrl ?? newState.gstCertificateUrl,
          panCardUrl: currentLoaded.panCardUrl ?? newState.panCardUrl,
          bankChequeUrl: currentLoaded.bankChequeUrl ?? newState.bankChequeUrl,
          shopLicenseUrl: currentLoaded.shopLicenseUrl ?? newState.shopLicenseUrl,
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
          kycStatus: 'pending',
        ),
      );
    }
  }

  ProfileLoaded _mapSellerToLoadedState(SellerModel s) {
    final storeName = (s.shopName != null && s.shopName!.isNotEmpty)
        ? s.shopName!
        : ((s.name.isNotEmpty)
            ? s.name
            : '');
    final address = (s.address != null && s.address!.isNotEmpty)
        ? s.address!
        : ((s.businessDetails != null && s.businessDetails!.isNotEmpty)
            ? s.businessDetails!
            : '');

    return ProfileLoaded(
      storeName: storeName,
      ownerName: s.ownerName ?? s.name,
      email: s.email,
      phone: (s.phoneNumber != null && s.phoneNumber!.isNotEmpty)
          ? s.phoneNumber!
          : '',
      profileImageUrl: s.profileImageUrl ?? '',
      coverImageUrl: s.coverImageUrl ?? '',
      notificationsEnabled: s.notificationsEnabled,
      role: s.role.isNotEmpty ? s.role : 'seller',
      createdAt: s.createdAt,
      isVerified: s.isVerified,
      verificationStatus: s.verificationStatus ?? (s.isVerified ? 'verified' : 'pending'),
      address: address,
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
      kycStatus: s.kycStatus,
      fssaiCertificateUrl: s.fssaiCertificateUrl,
      gstCertificateUrl: s.gstCertificateUrl,
      panCardUrl: s.panCardUrl,
      bankChequeUrl: s.bankChequeUrl,
      shopLicenseUrl: s.shopLicenseUrl,
      kycRejectionReason: s.kycRejectionReason,
    );
  }

  Future<void> _onLogoutRequested(
    LogoutRequested event,
    Emitter<SellerProfilePageState> emit,
  ) async {
    await _profileSubscription?.cancel();
    await _kycSubscription?.cancel();
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
        latitude: event.latitude,
        longitude: event.longitude,
        googleMapsUrl: event.googleMapsUrl,
      ));

      final String uid = authService.currentUserId ?? '';
      if (uid.isNotEmpty) {
        try {
          await profileRepository.updateProfile(uid, {
            'shopName': event.storeName,
            'name': event.storeName,
            'sellerName': event.storeName,
            'email': event.email,
            'phoneNumber': event.phone,
            'contactNumber': event.phone,
            'businessDetails': event.address,
            'address': event.address,
            'fullAddress': event.address,
            'gstNumber': event.gstNumber,
            'fssaiNumber': event.fssaiLicense,
            'bankAccountNumber': event.bankAccountNumber,
            'ifscCode': event.ifscCode,
            'taxConfiguration': event.taxConfiguration,
            'latitude': event.latitude,
            'longitude': event.longitude,
            'googleMapsUrl': event.googleMapsUrl,
            'kycStatus': 'in_review',
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

  Future<void> _onLoadSellerKycDocuments(
    LoadSellerKycDocuments event,
    Emitter<SellerProfilePageState> emit,
  ) async {
    final String uid = authService.currentUserId ?? '';
    if (uid.isEmpty) return;

    try {
      final kycData = await profileRepository.loadKycDocuments(uid);
      if (kycData.isNotEmpty && state is ProfileLoaded) {
        final current = state as ProfileLoaded;
        emit(current.copyWith(
          kycStatus: kycData['kycStatus'] as String? ?? current.kycStatus,
          fssaiCertificateUrl: kycData['fssaiCertificateUrl'] as String? ?? current.fssaiCertificateUrl,
          gstCertificateUrl: kycData['gstCertificateUrl'] as String? ?? current.gstCertificateUrl,
          panCardUrl: kycData['panCardUrl'] as String? ?? current.panCardUrl,
          bankChequeUrl: kycData['bankChequeUrl'] as String? ?? current.bankChequeUrl,
          shopLicenseUrl: kycData['shopLicenseUrl'] as String? ?? current.shopLicenseUrl,
          kycRejectionReason: kycData['rejectionReason'] as String? ?? current.kycRejectionReason,
        ));
      }
    } catch (e) {
      debugPrint('Error loading seller KYC documents: $e');
    }
  }

  void _onKycDocumentsStreamUpdated(
    KycDocumentsStreamUpdated event,
    Emitter<SellerProfilePageState> emit,
  ) {
    if (state is ProfileLoaded && event.kycData.isNotEmpty) {
      final current = state as ProfileLoaded;
      final kycData = event.kycData;
      emit(current.copyWith(
        kycStatus: kycData['kycStatus'] as String? ?? current.kycStatus,
        fssaiCertificateUrl: kycData['fssaiCertificateUrl'] as String? ?? current.fssaiCertificateUrl,
        gstCertificateUrl: kycData['gstCertificateUrl'] as String? ?? current.gstCertificateUrl,
        panCardUrl: kycData['panCardUrl'] as String? ?? current.panCardUrl,
        bankChequeUrl: kycData['bankChequeUrl'] as String? ?? current.bankChequeUrl,
        shopLicenseUrl: kycData['shopLicenseUrl'] as String? ?? current.shopLicenseUrl,
        kycRejectionReason: kycData['rejectionReason'] as String? ?? current.kycRejectionReason,
      ));
    }
  }

  Future<void> _onSubmitSellerKycDocuments(
    SubmitSellerKycDocuments event,
    Emitter<SellerProfilePageState> emit,
  ) async {
    if (state is ProfileLoaded) {
      final current = state as ProfileLoaded;
      emit(current.copyWith(
        kycStatus: 'in_review',
        fssaiLicense: event.fssaiNumber,
        fssaiCertificateUrl: event.fssaiCertificateUrl ?? current.fssaiCertificateUrl,
        gstNumber: event.gstNumber,
        gstCertificateUrl: event.gstCertificateUrl ?? current.gstCertificateUrl,
        panNumber: event.panNumber,
        panCardUrl: event.panCardUrl ?? current.panCardUrl,
        bankAccountNumber: event.bankAccountNumber,
        ifscCode: event.ifscCode,
        bankChequeUrl: event.bankChequeUrl ?? current.bankChequeUrl,
        shopLicenseUrl: event.shopLicenseUrl ?? current.shopLicenseUrl,
      ));

      final String uid = authService.currentUserId ?? '';
      if (uid.isNotEmpty) {
        try {
          final payload = {
            'sellerId': uid,
            'fssaiNumber': event.fssaiNumber,
            'fssaiCertificateUrl': event.fssaiCertificateUrl ?? current.fssaiCertificateUrl ?? '',
            'gstNumber': event.gstNumber,
            'gstCertificateUrl': event.gstCertificateUrl ?? current.gstCertificateUrl ?? '',
            'panNumber': event.panNumber,
            'panCardUrl': event.panCardUrl ?? current.panCardUrl ?? '',
            'bankAccountNumber': event.bankAccountNumber,
            'ifscCode': event.ifscCode,
            'bankChequeUrl': event.bankChequeUrl ?? current.bankChequeUrl ?? '',
            'shopLicenseUrl': event.shopLicenseUrl ?? current.shopLicenseUrl ?? '',
            'kycStatus': 'in_review',
            'submittedAt': DateTime.now().toIso8601String(),
          };

          await profileRepository.updateKycDocuments(uid, payload);
          await profileRepository.updateProfile(uid, {
            'fssaiNumber': event.fssaiNumber,
            'gstNumber': event.gstNumber,
            'panNumber': event.panNumber,
            'bankAccountNumber': event.bankAccountNumber,
            'ifscCode': event.ifscCode,
            'kycStatus': 'in_review',
            'verificationStatus': 'pending',
          });
        } catch (e) {
          debugPrint('Error submitting KYC documents: $e');
        }
      }
    }
  }

  Future<void> _onUploadKycDocumentFileEvent(
    UploadKycDocumentFileEvent event,
    Emitter<SellerProfilePageState> emit,
  ) async {
    if (state is ProfileLoaded) {
      final current = state as ProfileLoaded;
      emit(current.copyWith(isKycUploading: true));

      final String uid = authService.currentUserId ?? '';
      if (uid.isEmpty) {
        emit(current.copyWith(isKycUploading: false));
        return;
      }

      try {
        final downloadUrl = await profileRepository.uploadKycDocumentFile(
          sellerId: uid,
          docType: event.docType,
          fileName: event.fileName,
          fileBytes: event.fileBytes,
        );

        final Map<String, dynamic> kycUpdates = {};
        final docTypeLower = event.docType.toLowerCase();

        ProfileLoaded updatedState = current;
        if (docTypeLower.contains('fssai')) {
          kycUpdates['fssaiCertificateUrl'] = downloadUrl;
          updatedState = updatedState.copyWith(fssaiCertificateUrl: downloadUrl);
        } else if (docTypeLower.contains('gst')) {
          kycUpdates['gstCertificateUrl'] = downloadUrl;
          updatedState = updatedState.copyWith(gstCertificateUrl: downloadUrl);
        } else if (docTypeLower.contains('pan')) {
          kycUpdates['panCardUrl'] = downloadUrl;
          updatedState = updatedState.copyWith(panCardUrl: downloadUrl);
        } else if (docTypeLower.contains('cheque') || docTypeLower.contains('bank')) {
          kycUpdates['bankChequeUrl'] = downloadUrl;
          updatedState = updatedState.copyWith(bankChequeUrl: downloadUrl);
        } else if (docTypeLower.contains('shop') || docTypeLower.contains('license')) {
          kycUpdates['shopLicenseUrl'] = downloadUrl;
          updatedState = updatedState.copyWith(shopLicenseUrl: downloadUrl);
        }

        if (kycUpdates.isNotEmpty) {
          await profileRepository.updateKycDocuments(uid, kycUpdates);
        }

        emit(updatedState.copyWith(isKycUploading: false));
      } catch (e) {
        emit(current.copyWith(isKycUploading: false));
        debugPrint('Error uploading KYC document: $e');
      }
    }
  }

  @override
  Future<void> close() {
    _profileSubscription?.cancel();
    _kycSubscription?.cancel();
    return super.close();
  }
}


