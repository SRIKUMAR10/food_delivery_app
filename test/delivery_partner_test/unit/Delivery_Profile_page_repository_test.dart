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
      when(() => mockService.updateProfile(any()))
          .thenAnswer((_) async => true);
      await repository.updateAddress('Madurai');
      verify(() => mockService.updateProfile(any())).called(1);
    });

    test('updateAddress persists GPS coordinates and googleMapsUrl', () async {
      when(() => mockService.updateProfile({
            'address': '22 Velachery Main Road, Chennai',
            'latitude': 12.9815,
            'longitude': 80.2180,
            'googleMapsUrl': 'https://www.google.com/maps?q=12.981500,80.218000',
          })).thenAnswer((_) async => true);
      await repository.updateAddress(
        '22 Velachery Main Road, Chennai',
        latitude: 12.9815,
        longitude: 80.2180,
        googleMapsUrl: 'https://www.google.com/maps?q=12.981500,80.218000',
      );
      verify(() => mockService.updateProfile({
            'address': '22 Velachery Main Road, Chennai',
            'latitude': 12.9815,
            'longitude': 80.2180,
            'googleMapsUrl': 'https://www.google.com/maps?q=12.981500,80.218000',
          })).called(1);
    });

    test('saveProfile persists GPS coordinates that fetchProfile restores', () async {
      when(
        () => mockService.fetchProfileData(),
      ).thenAnswer((_) async => <String, dynamic>{});
      when(
        () => mockService.updateProfile(any()),
      ).thenAnswer((_) async => true);

      final updated = (await repository.fetchProfile()).copyWith(
        fullName: 'Kavitha',
        address: 'New Street, Coimbatore',
        latitude: 11.0168,
        longitude: 76.9558,
        googleMapsUrl: 'https://www.google.com/maps?q=11.016800,76.955800',
      );

      await repository.saveProfile(updated);

      final restored = await repository.fetchProfile();
      expect(restored.address, 'New Street, Coimbatore');
      expect(restored.latitude, 11.0168);
      expect(restored.longitude, 76.9558);
      expect(
        restored.googleMapsUrl,
        'https://www.google.com/maps?q=11.016800,76.955800',
      );
    });

    test('fetchProfile maps real-time GPS coordinates from service data', () async {
      when(
        () => mockService.fetchProfileData(),
      ).thenAnswer((_) async => {
        'id': 'partner_123456',
        'displayName': 'Kavitha',
        'phoneNumber': '+91 98765 43210',
        'email': 'kavitha@test.com',
        'address': '45 Anna Nagar, Chennai',
        'latitude': 13.0850,
        'longitude': 80.2100,
        'googleMapsUrl': 'https://www.google.com/maps?q=13.085000,80.210000',
      });

      final profile = await repository.fetchProfile();

      expect(profile.latitude, 13.0850);
      expect(profile.longitude, 80.2100);
      expect(
        profile.googleMapsUrl,
        'https://www.google.com/maps?q=13.085000,80.210000',
      );
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

    test('maps all 8-step KYC uploaded document URLs correctly', () async {
      when(() => mockService.fetchProfileData()).thenAnswer((_) async => {
            'id': 'partner_kyc_8',
            'displayName': 'Rider Karthik',
            'phoneNumber': '9876543210',
            'email': 'karthik@example.com',
            'address': 'Anna Nagar, Madurai',
            'photoUrl': 'https://storage.googleapis.com/avatar.jpg',
            'vehicleType': 'Motorcycle',
            'vehicleNumber': 'TN 59 AB 1234',
            'dlFrontUrl': 'https://storage.googleapis.com/dl_front.jpg',
            'rcBookUrl': 'https://storage.googleapis.com/rc_book.jpg',
            'aadhaarFrontUrl': 'https://storage.googleapis.com/aadhaar_front.jpg',
            'panCardUrl': 'https://storage.googleapis.com/pan_card.jpg',
            'status': 'approved',
            'kycStatus': 'approved',
          });

      final profile = await repository.fetchProfile();

      expect(profile.fullName, 'Rider Karthik');
      expect(profile.avatarPath, 'https://storage.googleapis.com/avatar.jpg');
      expect(profile.vehicleType, 'Motorcycle');
      expect(profile.vehicleNumber, 'TN 59 AB 1234');
      expect(profile.isKycApproved, isTrue);

      final dlDoc = profile.documents.firstWhere((d) => d.id == 'drivingLicense');
      expect(dlDoc.isVerified, isTrue);
      expect(dlDoc.documentUrl, 'https://storage.googleapis.com/dl_front.jpg');

      final rcDoc = profile.documents.firstWhere((d) => d.id == 'vehicleRc');
      expect(rcDoc.isVerified, isTrue);
      expect(rcDoc.documentUrl, 'https://storage.googleapis.com/rc_book.jpg');

      final insDoc = profile.documents.firstWhere((d) => d.id == 'insurance');
      expect(insDoc.isVerified, isTrue);
      expect(insDoc.documentUrl, 'https://storage.googleapis.com/aadhaar_front.jpg');

      final panDoc = profile.documents.firstWhere((d) => d.id == 'panCard');
      expect(panDoc.isVerified, isTrue);
      expect(panDoc.documentUrl, 'https://storage.googleapis.com/pan_card.jpg');
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

    test('fetchProfile maps licenseValidTill from multiple candidate aliases', () async {
      when(() => mockService.fetchProfileData()).thenAnswer((_) async => {
        'id': 'partner_dl_1',
        'displayName': 'Rider Test',
        'dlExpiryDate': '25/12/2032',
      });

      final profile = await repository.fetchProfile();
      expect(profile.licenseValidTill, '25/12/2032');

      when(() => mockService.fetchProfileData()).thenAnswer((_) async => {
        'id': 'partner_dl_2',
        'displayName': 'Rider Test 2',
        'drivingLicenseExpiry': '15/08/2035',
      });

      final profile2 = await repository.fetchProfile();
      expect(profile2.licenseValidTill, '15/08/2035');
    });

    test('saveProfile persists licenseValidTill to service update map and prefs', () async {
      Map<String, dynamic>? capturedPayload;
      when(() => mockService.updateProfile(any())).thenAnswer((inv) async {
        capturedPayload = inv.positionalArguments[0] as Map<String, dynamic>;
        return true;
      });

      final testProfile = repository.buildDefaultProfile().copyWith(
        fullName: 'Arun Kumar',
        vehicleType: 'Scooter',
        vehicleNumber: 'TN-36-8888',
        licenseNumber: 'TN43Z20210000478',
        licenseValidTill: '31/12/2030',
      );

      await repository.saveProfile(testProfile);

      expect(capturedPayload, isNotNull);
      expect(capturedPayload!['licenseValidTill'], '31/12/2030');
      expect(capturedPayload!['dlExpiryDate'], '31/12/2030');
      expect(capturedPayload!['drivingLicense'], 'TN43Z20210000478');

      when(() => mockService.fetchProfileData()).thenAnswer((_) async => <String, dynamic>{});
      final restored = await repository.fetchProfile();
      expect(restored.licenseValidTill, '31/12/2030');
      expect(restored.licenseNumber, 'TN43Z20210000478');
    });

    test('updateVehicle includes licenseValidTill and licenseNumber when supplied', () async {
      Map<String, dynamic>? capturedVehiclePayload;
      when(() => mockService.updateProfile(any())).thenAnswer((inv) async {
        capturedVehiclePayload = inv.positionalArguments[0] as Map<String, dynamic>;
        return true;
      });

      await repository.updateVehicle(
        vehicleType: 'Electric Bike',
        vehicleNumber: 'TN-38-9999',
        licenseNumber: 'TN3820220001111',
        licenseValidTill: '10/10/2032',
      );

      expect(capturedVehiclePayload, isNotNull);
      expect(capturedVehiclePayload!['vehicleType'], 'Electric Bike');
      expect(capturedVehiclePayload!['vehicleNumber'], 'TN-38-9999');
      expect(capturedVehiclePayload!['drivingLicense'], 'TN3820220001111');
      expect(capturedVehiclePayload!['licenseValidTill'], '10/10/2032');
    });
  });
}
