// lib/user_profile_image/user_profile_image_Bloc.dart
//
// Business logic for the User Profile.
// Handles fetching data, saving data, and uploading images to Firebase Storage.

import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image/image.dart' as img;

import 'user_profile_models.dart';

part 'user_profile_image_Event.dart';
part 'user_profile_image_State.dart';

class UserProfileBloc extends Bloc<UserProfileEvent, UserProfileState> {
  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;
  final FirebaseStorage _storage;
  final ImagePicker _imagePicker;

  UserProfileBloc({
    FirebaseAuth? auth,
    FirebaseFirestore? firestore,
    FirebaseStorage? storage,
    ImagePicker? imagePicker,
  }) : _auth = auth ?? FirebaseAuth.instance,
       _firestore = firestore ?? FirebaseFirestore.instance,
       _storage = storage ?? FirebaseStorage.instance,
       _imagePicker = imagePicker ?? ImagePicker(),
       super(const ProfileInitial()) {
    on<LoadProfileStarted>(_onLoadProfileStarted);
    on<ProfileImagePicked>(_onProfileImagePicked);
    on<ProfileImageUploadProgress>(_onProfileImageUploadProgress);
    on<ProfileSaved>(_onProfileSaved);
    on<SignOutRequested>(_onSignOutRequested);
  }

  /// Fetches the user profile data from Firestore.
  Future<void> _onLoadProfileStarted(
    LoadProfileStarted event,
    Emitter<UserProfileState> emit,
  ) async {
    emit(const ProfileLoading());

    try {
      final user = _auth.currentUser;
      if (user == null) {
        emit(
          const ProfileError(
            'User not logged in',
            previousState: ProfileInitial(),
          ),
        );
        return;
      }

      final doc = await _firestore.collection('users').doc(user.uid).get();

      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>;
        final profile = UserProfile(
          name: data['name'] ?? '',
          email: data['email'] ?? user.email ?? '',
          phone: data['phone'] ?? '',
          address: data['address'] ?? '',
          homeAddress: data['homeAddress'] ?? '',
          workAddress: data['workAddress'] ?? '',
          otherAddress: data['otherAddress'] ?? '',
          selectedAddressType: data['selectedAddressType'] ?? 'Home',
          imageUrl: data['imageUrl'],
        );
        emit(ProfileLoaded(profile: profile));
      } else {
        // If document doesn't exist, start with an empty profile but use the auth email.
        emit(
          ProfileLoaded(
            profile: UserProfile.empty().copyWith(email: user.email),
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

  /// Saves the updated profile data to Firestore.
  Future<void> _onProfileSaved(
    ProfileSaved event,
    Emitter<UserProfileState> emit,
  ) async {
    if (state is! ProfileLoaded) return;
    final currentState = state as ProfileLoaded;

    emit(currentState.copyWith(isSaving: true));

    try {
      final user = _auth.currentUser;
      if (user == null) {
        emit(
          ProfileError('User not logged in', previousState: currentState),
        );
        emit(currentState.copyWith(isSaving: false));
        return;
      }

      // Update Firestore with the new user details
      await _firestore.collection('users').doc(user.uid).set({
        'name': event.profile.name.trim(),
        'email': event.profile.email.trim(),
        'phone': event.profile.phone.trim(),
        'address': event.profile.address.trim(),
        'homeAddress': event.profile.homeAddress.trim(),
        'workAddress': event.profile.workAddress.trim(),
        'otherAddress': event.profile.otherAddress.trim(),
        'selectedAddressType': event.profile.selectedAddressType,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      emit(ProfileSuccessAction('Profile saved successfully!', currentState));
      emit(currentState.copyWith(profile: event.profile, isSaving: false));
    } catch (e) {
      emit(ProfileError('Error saving profile: $e', previousState: currentState));
      emit(currentState.copyWith(isSaving: false));
    }
  }

  /// Internal handler to update the upload progress without resetting the entire state.
  void _onProfileImageUploadProgress(
    ProfileImageUploadProgress event,
    Emitter<UserProfileState> emit,
  ) {
    if (state is ProfileLoaded) {
      emit((state as ProfileLoaded).copyWith(uploadProgress: event.progress));
    }
  }

  /// Picks an image from the gallery, compresses it, and uploads it to Firebase Storage.
  Future<void> _onProfileImagePicked(
    ProfileImagePicked event,
    Emitter<UserProfileState> emit,
  ) async {
    if (state is! ProfileLoaded) return;
    final currentState = state as ProfileLoaded;

    try {
      final user = _auth.currentUser;
      if (user == null) {
        emit(
          ProfileError(
            'Please login first.',
            previousState: currentState,
          ),
        );
        return;
      }

      // 1. Pick image
      final XFile? picked = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 100, // Pick raw, compress manually
      );
      if (picked == null) return;

      emit(currentState.copyWith(uploadProgress: 0.01)); // Indicate start

      // 2. Read bytes
      final Uint8List originalBytes = await picked.readAsBytes();

      // 3. Compress using the 'image' package with fallback to originalBytes
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

      // 4. Upload to Firebase Storage
      final Reference ref = _storage.ref('user/image/${user.uid}.jpg');
      final UploadTask uploadTask = ref.putData(
        bytesToUpload,
        SettableMetadata(contentType: contentType),
      );

      // Listen to progress updates safely
      final progressSubscription = uploadTask.snapshotEvents.listen(
        (snap) {
          final total = snap.totalBytes == 0 ? 1 : snap.totalBytes;
          add(ProfileImageUploadProgress(snap.bytesTransferred / total));
        },
        onError: (err) {
          debugPrint('Upload progress stream error: $err');
        },
        cancelOnError: true,
      );

      await uploadTask;
      await progressSubscription.cancel();

      // 5. Get Download URL
      final String downloadUrl = await ref.getDownloadURL();

      // 6. Update Firestore Document
      await _firestore.collection('users').doc(user.uid).set({
        'imageUrl': downloadUrl,
      }, SetOptions(merge: true));

      // 7. Update State
      final updatedProfile = currentState.profile.copyWith(
        imageUrl: downloadUrl,
      );
      emit(ProfileSuccessAction('✅ Profile photo updated!', currentState));
      emit(currentState.copyWith(profile: updatedProfile, uploadProgress: 0.0));
    } catch (e) {
      debugPrint('Upload error: $e');
      final String message = e.toString().contains('unauthorized')
          ? '❌ Storage Permission Error: User is not authorized to upload to Firebase Storage. Please check Firebase Storage Security Rules.'
          : '❌ Upload failed: ${e.toString().replaceAll('Exception: ', '')}';
      emit(
        ProfileError(
          message,
          previousState: currentState,
        ),
      );
      emit(currentState.copyWith(uploadProgress: 0.0));
    }
  }

  /// Signs out the user from Firebase Auth.
  Future<void> _onSignOutRequested(
    SignOutRequested event,
    Emitter<UserProfileState> emit,
  ) async {
    try {
      await _auth.signOut();
      emit(const SignOutSuccess());
    } catch (e) {
      emit(ProfileError('Failed to sign out: $e', previousState: state));
    }
  }
}
