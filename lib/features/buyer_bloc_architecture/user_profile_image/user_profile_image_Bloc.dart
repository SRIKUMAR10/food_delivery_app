import 'dart:async';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image/image.dart' as img;
import 'package:food_delivery_app/core/services/i_auth_service.dart';
import 'package:food_delivery_app/core/repositories/i_user_profile_repository.dart';
import 'package:food_delivery_app/core/utils/app_exception_formatter.dart';
import 'user_profile_models.dart';

part 'user_profile_image_Event.dart';
part 'user_profile_image_State.dart';

class UserProfileBloc extends Bloc<UserProfileEvent, UserProfileState> {
  final IAuthService authService;
  final IUserProfileRepository profileRepository;
  final ImagePicker _imagePicker;

  StreamSubscription<UserProfile?>? _profileSubscription;

  UserProfileBloc({
    required this.authService,
    required this.profileRepository,
    ImagePicker? imagePicker,
  }) : _imagePicker = imagePicker ?? ImagePicker(),
       super(const ProfileInitial()) {
    on<LoadProfileStarted>(_onLoadProfileStarted);
    on<_ProfileUpdatedInternal>(_onProfileUpdatedInternal);
    on<ProfileImagePicked>(_onProfileImagePicked);
    on<ProfileImageUploadProgress>(_onProfileImageUploadProgress);
    on<ProfileSaved>(_onProfileSaved);
    on<SignOutRequested>(_onSignOutRequested);
  }

  @override
  Future<void> close() {
    _profileSubscription?.cancel();
    return super.close();
  }

  Future<void> _onLoadProfileStarted(
    LoadProfileStarted event,
    Emitter<UserProfileState> emit,
  ) async {
    emit(const ProfileLoading());

    try {
      final uid = authService.currentUserId;
      if (uid == null || uid.isEmpty) {
        emit(
          const ProfileError(
            'User not logged in',
            previousState: ProfileInitial(),
          ),
        );
        return;
      }

      await _profileSubscription?.cancel();
      _profileSubscription = profileRepository.watchProfile(uid).listen(
        (profile) {
          if (profile != null) {
            final updatedProfile = profile.copyWith(
              name: profile.name.isEmpty ? (authService.currentUserDisplayName ?? '') : profile.name,
              email: profile.email.isEmpty ? (authService.currentUserEmail ?? '') : profile.email,
              imageUrl: profile.imageUrl ?? authService.currentUserPhotoUrl,
            );
            add(_ProfileUpdatedInternal(updatedProfile));
          } else {
            final fallbackProfile = UserProfile.empty().copyWith(
              name: authService.currentUserDisplayName ?? '',
              email: authService.currentUserEmail ?? '',
              imageUrl: authService.currentUserPhotoUrl,
            );
            add(_ProfileUpdatedInternal(fallbackProfile));
          }
        },
        onError: (e) {
          debugPrint('Error in real-time profile stream: $e');
        },
      );
    } catch (e) {
      emit(
        ProfileError(
          'Failed to load profile: $e',
          previousState: const ProfileInitial(),
        ),
      );
    }
  }

  void _onProfileUpdatedInternal(
    _ProfileUpdatedInternal event,
    Emitter<UserProfileState> emit,
  ) {
    if (state is ProfileLoaded) {
      final current = state as ProfileLoaded;
      emit(current.copyWith(profile: event.profile));
    } else {
      emit(ProfileLoaded(profile: event.profile));
    }
  }

  Future<void> _onProfileSaved(
    ProfileSaved event,
    Emitter<UserProfileState> emit,
  ) async {
    if (state is! ProfileLoaded) return;
    final currentState = state as ProfileLoaded;

    emit(currentState.copyWith(isSaving: true));

    try {
      final uid = authService.currentUserId;
      if (uid == null || uid.isEmpty) {
        emit(
          ProfileError('User not logged in', previousState: currentState),
        );
        emit(currentState.copyWith(isSaving: false));
        return;
      }

      await profileRepository.saveProfile(uid, event.profile);

      emit(currentState.copyWith(
        profile: event.profile,
        isSaving: false,
        successMessage: 'Profile saved successfully!',
      ));
    } catch (e) {
      emit(currentState.copyWith(
        isSaving: false,
        errorMessage: 'Error saving profile: $e',
      ));
    }
  }

  void _onProfileImageUploadProgress(
    ProfileImageUploadProgress event,
    Emitter<UserProfileState> emit,
  ) {
    if (state is ProfileLoaded) {
      emit((state as ProfileLoaded).copyWith(uploadProgress: event.progress));
    }
  }

  Future<void> _onProfileImagePicked(
    ProfileImagePicked event,
    Emitter<UserProfileState> emit,
  ) async {
    if (state is! ProfileLoaded) return;
    final currentState = state as ProfileLoaded;

    try {
      final uid = authService.currentUserId;
      if (uid == null || uid.isEmpty) {
        emit(
          ProfileError(
            'Please login first.',
            previousState: currentState,
          ),
        );
        return;
      }

      final XFile? picked = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 100,
      );
      if (picked == null) return;

      emit(currentState.copyWith(uploadProgress: 0.01));

      final Uint8List originalBytes = await picked.readAsBytes();

      Uint8List bytesToUpload = originalBytes;
      String contentType = 'image/jpeg';

      try {
        img.Image? decoded = img.decodeImage(originalBytes);
        if (decoded != null) {
          if (decoded.width > 800 || decoded.height > 800) {
            decoded = decoded.width >= decoded.height
                ? img.copyResize(decoded, width: 800)
                : img.copyResize(decoded, height: 800);
          }
          bytesToUpload = Uint8List.fromList(
            img.encodeJpg(decoded, quality: 75),
          );
        }
      } catch (decodeErr) {
        debugPrint('Image decode/compress warning, using original bytes: $decodeErr');
      }

      if (picked.name.toLowerCase().endsWith('.png')) {
        contentType = 'image/png';
      } else if (picked.name.toLowerCase().endsWith('.webp')) {
        contentType = 'image/webp';
      }

      final downloadUrl = await profileRepository.uploadProfileImage(
        userId: uid,
        fileName: picked.name,
        imageBytes: bytesToUpload,
        contentType: contentType,
      );

      await profileRepository.updateProfileImageUrl(uid, downloadUrl);

      final updatedProfile = currentState.profile.copyWith(
        imageUrl: downloadUrl,
      );
      emit(currentState.copyWith(
        profile: updatedProfile,
        uploadProgress: 0.0,
        successMessage: 'Profile photo updated!',
      ));
    } catch (e) {
      debugPrint('Upload error: $e');
      final String message = e.toString().contains('unauthorized')
          ? 'Storage Permission Error: User is not authorized to upload to Firebase Storage.'
          : AppExceptionFormatter.toUserFriendlyMessage(e);
      emit(currentState.copyWith(
        uploadProgress: 0.0,
        errorMessage: message,
      ));
    }
  }

  Future<void> _onSignOutRequested(
    SignOutRequested event,
    Emitter<UserProfileState> emit,
  ) async {
    try {
      await authService.signOut();
      emit(const SignOutSuccess());
    } catch (e) {
      emit(ProfileError('Failed to sign out: $e', previousState: state));
    }
  }
}
