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
          'id': 'partner_123456',
          'displayName': 'Kavitha',
          'phoneNumber': '+91 98765 43210',
          'email': 'kavitha@test.com',
          'address': '45 Anna Nagar, Chennai',
          'photoUrl': 'https://example.com/avatar.png',
          'vehicleType': 'Bike',
          'vehicleNumber': 'TN 01 AB 1234',
          'drivingLicense': 'DL-2023-001',
          'rating': 4.8,
          'totalDeliveries': 25,
          'joiningDate': '12 Jan 2024',
          'status': 'approved',
          'kycStatus': 'approved',
        });

        final profile = await repository.fetchProfile();

        expect(profile.partnerId, 'partner_123456');
        expect(profile.partnerCode, 'DP-PARTNE');
        expect(profile.fullName, 'Kavitha');
        expect(profile.phone, '+91 98765 43210');
        expect(profile.email, 'kavitha@test.com');
        expect(profile.address, '45 Anna Nagar, Chennai');
        expect(profile.vehicleType, 'Bike');
        expect(profile.vehicleNumber, 'TN 01 AB 1234');
        expect(profile.licenseNumber, 'DL-2023-001');
        expect(profile.rating, 4.8);
        expect(profile.totalDeliveries, 25);
        expect(profile.avatarPath, 'https://example.com/avatar.png');
        expect(profile.isKycApproved, isTrue);
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
        address: 'New Street, Coimbatore',
        vehicleNumber: 'TN 01 AB 1234',
      );

      await repository.saveProfile(updated);

      final restored = await repository.fetchProfile();
      expect(restored.fullName, 'Kavitha');
      expect(restored.address, 'New Street, Coimbatore');
      expect(restored.vehicleNumber, 'TN 01 AB 1234');
    });

    test('updateAddress calls service correctly', () async {
      when(() => mockService.updateProfile({'address': 'Madurai'}))
          .thenAnswer((_) async => true);
      await repository.updateAddress('Madurai');
      verify(() => mockService.updateProfile({'address': 'Madurai'})).called(1);
    });

    test('updateVehicle calls service correctly', () async {
      when(() => mockService.updateProfile({
            'vehicleType': 'Scooter',
            'vehicleNumber': 'TN 58 AA 1111',
          })).thenAnswer((_) async => true);
      await repository.updateVehicle(
        vehicleType: 'Scooter',
        vehicleNumber: 'TN 58 AA 1111',
      );
      verify(() => mockService.updateProfile({
            'vehicleType': 'Scooter',
            'vehicleNumber': 'TN 58 AA 1111',
          })).called(1);
    });

    test('changePassword calls service correctly', () async {
      when(() => mockService.changePassword(
            currentPassword: 'old',
            newPassword: 'new',
          )).thenAnswer((_) async {});
      await repository.changePassword(
        currentPassword: 'old',
        newPassword: 'new',
      );
      verify(() => mockService.changePassword(
            currentPassword: 'old',
            newPassword: 'new',
          )).called(1);
    });

    test('deactivateAccount calls service correctly', () async {
      when(() => mockService.deactivateAccount()).thenAnswer((_) async {});
      await repository.deactivateAccount();
      verify(() => mockService.deactivateAccount()).called(1);
    });

    test('logout calls service correctly', () async {
      when(() => mockService.logout()).thenAnswer((_) async {});
      await repository.logout();
      verify(() => mockService.logout()).called(1);
    });

    test('computeDeliveryProfileCompletion returns 0 for empty profile', () {
      final profile = repository.buildDefaultProfile();
      final completion = computeDeliveryProfileCompletion(
        fullName: profile.fullName,
        phone: profile.phone,
        email: profile.email,
        dob: profile.dob,
        address: profile.address,
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
