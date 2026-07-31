import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:food_delivery_app/features/Delivery%20Partner%20Bloc%20Architecture/Delivery_Profile_page/Delivery_Profile_page_state.dart';
import 'package:food_delivery_app/features/Delivery%20Partner%20Bloc%20Architecture/Delivery_Profile_page/Delivery_Profile_page_repository.dart';

void main() {
  group('DeliveryProfilePage Snapshot Tests', () {
    test('initial snapshot has default profile with 75% completion', () {
      const state = DeliveryProfileState();

      expect(state.status, DeliveryProfileStatus.initial);
      expect(state.fullName, 'Ravi Kumar');
      expect(state.completionPercentage, 75);
      expect(
        state.verificationStatuses,
        DeliveryProfileRepository.defaultVerificationStatuses,
      );
      expect(state.avatarPath, isNull);
      expect(state.documents, isEmpty);
    });

    test('copyWith produces an updated snapshot without mutating original', () {
      const initial = DeliveryProfileState();
      final updated = initial.copyWith(
        vehicleNumber: 'TN 01 AB 1234',
        completionPercentage: 83,
      );

      expect(updated.vehicleNumber, 'TN 01 AB 1234');
      expect(updated.completionPercentage, 83);
      expect(initial.vehicleNumber, '');
      expect(initial.completionPercentage, 75);
      expect(updated == initial, isFalse);
    });

    test('loading, loaded and error snapshots differ only by status', () {
      const loaded = DeliveryProfileState(status: DeliveryProfileStatus.loaded);
      const loading = DeliveryProfileState(
        status: DeliveryProfileStatus.loading,
      );
      const error = DeliveryProfileState(
        status: DeliveryProfileStatus.error,
        errorMessage: 'boom',
      );

      expect(loaded == loading, isFalse);
      expect(loaded == error, isFalse);
      expect(loaded.completionPercentage, error.completionPercentage);
    });

    test('document status snapshot transitions correctly', () {
      const document = DeliveryProfileDocument(
        id: 'insurance',
        label: 'Insurance',
        icon: Icons.verified_user_outlined,
      );

      final uploading = document.copyWith(
        status: DeliveryProfileDocumentStatus.uploading,
        progress: 0.5,
      );
      final uploaded = document.copyWith(
        status: DeliveryProfileDocumentStatus.uploaded,
        progress: 1.0,
      );

      expect(uploading.isUploading, isTrue);
      expect(uploading.isUploaded, isFalse);
      expect(uploaded.isUploaded, isTrue);
      expect(uploaded.progress, 1.0);
      expect(document.status, DeliveryProfileDocumentStatus.notUploaded);
    });

    test('completion snapshot rises when documents are uploaded', () {
      final base = DeliveryProfileRepository().buildDefaultProfile();

      final allUploaded = base.copyWith(
        documents: [
          for (final d in base.documents)
            d.copyWith(status: DeliveryProfileDocumentStatus.uploaded),
        ],
      );

      final before = computeDeliveryProfileCompletion(
        fullName: base.fullName,
        phone: base.phone,
        email: base.email,
        dob: base.dob,
        vehicleType: base.vehicleType,
        vehicleNumber: base.vehicleNumber,
        licenseNumber: base.licenseNumber,
        licenseValidTill: base.licenseValidTill,
        documents: base.documents,
      );
      final after = computeDeliveryProfileCompletion(
        fullName: allUploaded.fullName,
        phone: allUploaded.phone,
        email: allUploaded.email,
        dob: allUploaded.dob,
        vehicleType: allUploaded.vehicleType,
        vehicleNumber: allUploaded.vehicleNumber,
        licenseNumber: allUploaded.licenseNumber,
        licenseValidTill: allUploaded.licenseValidTill,
        documents: allUploaded.documents,
      );

      expect(before, 75);
      expect(after, greaterThan(before));
      expect(after, 83);
    });
  });
}
