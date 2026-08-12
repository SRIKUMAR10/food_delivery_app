import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:food_delivery_app/features/Delivery%20Partner%20Bloc%20Architecture/Delivery_Profile_page/Delivery_Profile_page_repository.dart';
import 'package:food_delivery_app/features/Delivery%20Partner%20Bloc%20Architecture/Delivery_Profile_page/Delivery_Profile_page_service.dart';
import 'package:food_delivery_app/features/Delivery%20Partner%20Bloc%20Architecture/Delivery_Profile_page/Delivery_Profile_page_state.dart';

class MockDeliveryProfileService extends Mock
    implements DeliveryProfileServiceBase {}

void main() {
  late DeliveryProfileRepository repository;
  late MockDeliveryProfileService mockService;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    mockService = MockDeliveryProfileService();
    repository = DeliveryProfileRepository(
      prefs: prefs,
      service: mockService,
    );
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
      'fetchProfile returns an empty default profile when service has no data',
      () async {
        when(
          () => mockService.fetchProfileData(),
        ).thenAnswer((_) async => <String, dynamic>{});

        final profile = await repository.fetchProfile();

        expect(profile.fullName, '');
        expect(profile.phone, '');
        expect(profile.completionPercentage, 0);
        expect(profile.documents, hasLength(4));
        expect(profile.documents.where((d) => d.isUploaded), isEmpty);
        expect(profile.verificationStatuses['phone'], isFalse);
        expect(profile.status, DeliveryProfileStatus.loaded);
      },
    );

    test(
      'fetchProfile maps real-time service data into the profile',
      () async {
        when(
          () => mockService.fetchProfileData(),
        ).thenAnswer((_) async => {
          'displayName': 'Kavitha',
          'phoneNumber': '+91 98765 43210',
          'email': 'kavitha@test.com',
          'photoUrl': 'https://example.com/avatar.png',
          'vehicleType': 'Bike',
          'vehicleNumber': 'TN 01 AB 1234',
          'drivingLicense': 'DL-2023-001',
        });

        final profile = await repository.fetchProfile();

        expect(profile.fullName, 'Kavitha');
        expect(profile.phone, '+91 98765 43210');
        expect(profile.email, 'kavitha@test.com');
        expect(profile.vehicleType, 'Bike');
        expect(profile.vehicleNumber, 'TN 01 AB 1234');
        expect(profile.licenseNumber, 'DL-2023-001');
        expect(profile.avatarPath, 'https://example.com/avatar.png');
      },
    );

    test('saveProfile persists edits that fetchProfile restores', () async {
      when(
        () => mockService.fetchProfileData(),
      ).thenAnswer((_) async => <String, dynamic>{});
      when(
        () => mockService.updateProfile(any()),
      ).thenAnswer((_) async => true);

      final updated = (await repository.fetchProfile()).copyWith(
        fullName: 'Kavitha',
        vehicleNumber: 'TN 01 AB 1234',
      );

      await repository.saveProfile(updated);

      final restored = await repository.fetchProfile();
      expect(restored.fullName, 'Kavitha');
      expect(restored.vehicleNumber, 'TN 01 AB 1234');
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

    test('buildDefaultChecklist does not mark unverified documents', () {
      final profile = repository.buildDefaultProfile();
      final checklist = DeliveryProfileRepository.buildDefaultChecklist(
        profile: profile,
      );

      final byId = {for (final item in checklist) item.id: item};
      expect(byId['drivingLicense']!.isComplete, isFalse);
      expect(byId['insurance']!.isComplete, isFalse);
      expect(byId['documentVerification']!.isComplete, isFalse);
    });

    test('computeDeliveryProfileCompletion returns 0 for empty profile', () {
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
      expect(completion, 0);
    });
  });
}
