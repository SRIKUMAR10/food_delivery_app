import 'dart:async';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image/image.dart' as img;
import 'package:food_delivery_app/core/services/i_auth_service.dart';
import 'package:food_delivery_app/core/repositories/i_user_profile_repository.dart';
import 'user_profile_models.dart';

part 'user_profile_image_Event.dart';
part 'user_profile_image_State.dart';

class UserProfileBloc extends Bloc<UserProfileEvent, UserProfileState> {
  final IAuthService authService;
  final IUserProfileRepository profileRepository;
  final ImagePicker _imagePicker;

  UserProfileBloc({
    required this.authService,
    required this.profileRepository,
    ImagePicker? imagePicker,
  }) : _imagePicker = imagePicker ?? ImagePicker(),
       super(const ProfileInitial()) {
    on<LoadProfileStarted>(_onLoadProfileStarted);
    on<ProfileImagePicked>(_onProfileImagePicked);
    on<ProfileImageUploadProgress>(_onProfileImageUploadProgress);
    on<ProfileSaved>(_onProfileSaved);
    on<SignOutRequested>(_onSignOutRequested);
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

      final profile = await profileRepository.loadProfile(uid);
      if (profile != null) {
        emit(ProfileLoaded(profile: profile));
      } else {
        emit(
          ProfileLoaded(
            profile: UserProfile.empty().copyWith(email: authService.currentUserEmail),
          ),
        );
      }
    } catch (e) {
      emit(
        ProfileError(
          'Failed to load profile: $e',
          previousState: const ProfileInitial(),
        ),
      );
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
          ? 'Storage Permission Error: User is not authorized to upload to Firebase Storage. Please check Firebase Storage Security Rules.'
          : 'Upload failed: ${e.toString().replaceAll('Exception: ', '')}';
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
