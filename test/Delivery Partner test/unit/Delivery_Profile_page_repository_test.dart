import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:food_delivery_app/features/Delivery%20Partner%20Bloc%20Architecture/Delivery_Profile_page/Delivery_Profile_page_repository.dart';
import 'package:food_delivery_app/features/Delivery%20Partner%20Bloc%20Architecture/Delivery_Profile_page/Delivery_Profile_page_state.dart';

void main() {
  late DeliveryProfileRepository repository;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    repository = DeliveryProfileRepository(prefs: prefs);
  });

  group('DeliveryProfilePage Repository Tests', () {
    test('default documents contain the four KYC document types', () {
      expect(DeliveryProfileRepository.defaultDocuments, hasLength(4));
      final ids = DeliveryProfileRepository.defaultDocuments.map((d) => d.id);
      expect(
        ids,
        containsAll(['drivingLicense', 'vehicleRc', 'insurance', 'panCard']),
      );
    });

    test(
      'fetchProfile returns default profile with Ravi Kumar and 75%',
      () async {
        final profile = await repository.fetchProfile();

        expect(profile.fullName, 'Ravi Kumar');
        expect(profile.phone, '+91 98765 43210');
        expect(profile.completionPercentage, 75);
        expect(profile.documents, hasLength(4));
        expect(profile.documents.where((d) => d.isUploaded), hasLength(3));
        expect(profile.verificationStatuses['phone'], isTrue);
        expect(profile.status, DeliveryProfileStatus.loaded);
      },
    );

    test('saveProfile persists edits that fetchProfile restores', () async {
      final updated = (await repository.fetchProfile()).copyWith(
        fullName: 'Kavitha',
        vehicleNumber: 'TN 01 AB 1234',
      );

      await repository.saveProfile(updated);

      final restored = await repository.fetchProfile();
      expect(restored.fullName, 'Kavitha');
      expect(restored.vehicleNumber, 'TN 01 AB 1234');
      expect(restored.phone, '+91 98765 43210');
    });

    test('avatar path can be saved and retrieved', () async {
      expect(await repository.getAvatarPath(), isNull);

      await repository.saveAvatarPath('/tmp/profile.png');
      expect(await repository.getAvatarPath(), '/tmp/profile.png');

      await repository.saveAvatarPath(null);
      expect(await repository.getAvatarPath(), isNull);
    });

    test('pickProfileImage resolves to null placeholder', () async {
      expect(await repository.pickProfileImage(), isNull);
    });

    test('buildDefaultChecklist marks completed documents', () {
      final profile = repository.buildDefaultProfile();
      final checklist = DeliveryProfileRepository.buildDefaultChecklist(
        profile: profile,
      );

      final byId = {for (final item in checklist) item.id: item};
      expect(byId['drivingLicense']!.isComplete, isTrue);
      expect(byId['insurance']!.isComplete, isFalse);
      expect(byId['documentVerification']!.isComplete, isTrue);
    });

    test('computeDeliveryProfileCompletion returns 75 for default profile', () {
      final profile = repository.buildDefaultProfile();
      final completion = computeDeliveryProfileCompletion(
        fullName: profile.fullName,
        phone: profile.phone,
        email: profile.email,
        dob: profile.dob,
        vehicleType: profile.vehicleType,
        vehicleNumber: profile.vehicleNumber,
        licenseNumber: profile.licenseNumber,
        licenseValidTill: profile.licenseValidTill,
        documents: profile.documents,
      );
      expect(completion, 75);
    });
  });
}
