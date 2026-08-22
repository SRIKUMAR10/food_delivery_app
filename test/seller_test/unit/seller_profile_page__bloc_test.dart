import 'dart:async';
import 'dart:typed_data';
import 'package:flutter_test/flutter_test.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:food_delivery_app/core/models/seller_model.dart';
import 'package:food_delivery_app/core/repositories/i_seller_profile_repository.dart';
import 'package:food_delivery_app/core/services/i_auth_service.dart';
import 'package:food_delivery_app/features/seller_bloc_architecture/seller_profile_page/seller_profile_page__bloc.dart';
import 'package:food_delivery_app/features/seller_bloc_architecture/seller_profile_page/seller_profile_page__event.dart';
import 'package:food_delivery_app/features/seller_bloc_architecture/seller_profile_page/seller_profile_page__state.dart';

class MockAuthService extends Mock implements IAuthService {}
class MockProfileRepository extends Mock implements ISellerProfileRepository {}

void main() {
  group('SellerProfilePageBloc - Comprehensive Unit Tests', () {
    late SellerProfilePageBloc bloc;
    late MockAuthService mockAuthService;
    late MockProfileRepository mockProfileRepository;
    late StreamController<Map<String, dynamic>> profileStreamController;

    setUp(() {
      mockAuthService = MockAuthService();
      mockProfileRepository = MockProfileRepository();
      profileStreamController = StreamController<Map<String, dynamic>>.broadcast();

      when(() => mockAuthService.currentUserId).thenReturn('seller_123');
      when(() => mockProfileRepository.watchProfile('seller_123'))
          .thenAnswer((_) => profileStreamController.stream);

      bloc = SellerProfilePageBloc(
        authService: mockAuthService,
        profileRepository: mockProfileRepository,
      );
    });

    tearDown(() {
      profileStreamController.close();
      bloc.close();
    });

    test('initial state is ProfileInitial', () {
      expect(bloc.state, isA<ProfileInitial>());
    });

    blocTest<SellerProfilePageBloc, SellerProfilePageState>(
      'emits [ProfileLoading, ProfileLoaded] when LoadProfile loads initial seller',
      build: () {
        when(() => mockProfileRepository.loadProfile('seller_123'))
            .thenAnswer((_) async => {
                  'seller': SellerModel(
                    id: 'seller_123',
                    name: 'Spice Garden',
                    shopName: 'Spice Garden',
                    email: 'spice@garden.com',
                    phoneNumber: '9876543210',
                    isAcceptingOrders: true,
                    isOpen: true,
                    deliveryRadius: 12.5,
                    cuisines: const ['Biryani', 'South Indian'],
                    estimatedPrepTimeMinutes: 30,
                    createdAt: DateTime(2025, 1, 1),
                  ),
                });
        return bloc;
      },
      act: (bloc) => bloc.add(LoadProfile()),
      expect: () => [
        isA<ProfileLoading>(),
        isA<ProfileLoaded>().having((s) => s.storeName, 'storeName', 'Spice Garden')
            .having((s) => s.isAcceptingOrders, 'isAcceptingOrders', true)
            .having((s) => s.deliveryRadius, 'deliveryRadius', 12.5)
            .having((s) => s.cuisines, 'cuisines', ['Biryani', 'South Indian']),
      ],
    );

    blocTest<SellerProfilePageBloc, SellerProfilePageState>(
      'ToggleAcceptingOrders optimistically updates state and calls repository',
      build: () {
        when(() => mockProfileRepository.updateOperationalStatus(
              'seller_123',
              isAcceptingOrders: false,
            )).thenAnswer((_) async {});
        return bloc;
      },
      seed: () => ProfileLoaded(
        storeName: 'Test Kitchen',
        email: 'test@kitchen.com',
        phone: '1234567890',
        profileImageUrl: '',
        notificationsEnabled: true,
        role: 'seller',
        createdAt: DateTime(2025, 1, 1),
        isVerified: true,
        isAcceptingOrders: true,
      ),
      act: (bloc) => bloc.add(const ToggleAcceptingOrders(false)),
      expect: () => [
        isA<ProfileLoaded>().having((s) => s.isAcceptingOrders, 'isAcceptingOrders', false),
      ],
      verify: (_) {
        verify(() => mockProfileRepository.updateOperationalStatus(
              'seller_123',
              isAcceptingOrders: false,
            )).called(1);
      },
    );

    blocTest<SellerProfilePageBloc, SellerProfilePageState>(
      'ToggleStoreOpenStatus optimistically updates state and calls repository',
      build: () {
        when(() => mockProfileRepository.updateOperationalStatus(
              'seller_123',
              isOpen: false,
            )).thenAnswer((_) async {});
        return bloc;
      },
      seed: () => ProfileLoaded(
        storeName: 'Test Kitchen',
        email: 'test@kitchen.com',
        phone: '1234567890',
        profileImageUrl: '',
        notificationsEnabled: true,
        role: 'seller',
        createdAt: DateTime(2025, 1, 1),
        isVerified: true,
        isOpen: true,
      ),
      act: (bloc) => bloc.add(const ToggleStoreOpenStatus(false)),
      expect: () => [
        isA<ProfileLoaded>().having((s) => s.isOpen, 'isOpen', false),
      ],
      verify: (_) {
        verify(() => mockProfileRepository.updateOperationalStatus(
              'seller_123',
              isOpen: false,
            )).called(1);
      },
    );

    blocTest<SellerProfilePageBloc, SellerProfilePageState>(
      'UpdateLogisticsSettings updates state and calls updateProfile',
      build: () {
        when(() => mockProfileRepository.updateProfile(
              'seller_123',
              any(),
            )).thenAnswer((_) async {});
        return bloc;
      },
      seed: () => ProfileLoaded(
        storeName: 'Test Kitchen',
        email: 'test@kitchen.com',
        phone: '1234567890',
        profileImageUrl: '',
        notificationsEnabled: true,
        role: 'seller',
        createdAt: DateTime(2025, 1, 1),
        isVerified: true,
      ),
      act: (bloc) => bloc.add(UpdateLogisticsSettings(
        minimumOrderValue: 200.0,
        deliveryRadius: 15.0,
        deliveryFeeSettings: const DeliveryFeeSettings(baseFee: 30, perKmFee: 6, freeDeliveryThreshold: 600),
        estimatedPrepTimeMinutes: 35,
      )),
      expect: () => [
        isA<ProfileLoaded>()
            .having((s) => s.minimumOrderValue, 'minimumOrderValue', 200.0)
            .having((s) => s.deliveryRadius, 'deliveryRadius', 15.0)
            .having((s) => s.estimatedPrepTimeMinutes, 'estimatedPrepTimeMinutes', 35),
      ],
      verify: (_) {
        verify(() => mockProfileRepository.updateProfile('seller_123', {
              'minimumOrderValue': 200.0,
              'deliveryRadius': 15.0,
              'deliveryFeeSettings': {
                'baseFee': 30.0,
                'perKmFee': 6.0,
                'freeDeliveryThreshold': 600.0,
                'surgeMultiplier': 1.0,
              },
              'estimatedPrepTimeMinutes': 35,
              'prepTimeMinutes': 35,
            })).called(1);
      },
    );

    blocTest<SellerProfilePageBloc, SellerProfilePageState>(
      'UpdateLocationDetails persists GPS coordinates to Firestore and state',
      build: () {
        when(() => mockProfileRepository.updateProfile(
              'seller_123',
              any(),
            )).thenAnswer((_) async {});
        return bloc;
      },
      seed: () => ProfileLoaded(
        storeName: 'Test Kitchen',
        email: 'test@kitchen.com',
        phone: '1234567890',
        profileImageUrl: '',
        notificationsEnabled: true,
        role: 'seller',
        createdAt: DateTime(2025, 1, 1),
        isVerified: true,
      ),
      act: (bloc) => bloc.add(const UpdateLocationDetails(
        address: '123 Food Street, T. Nagar, Chennai',
        latitude: 13.0418,
        longitude: 80.2341,
        googleMapsUrl: 'https://www.google.com/maps?q=13.041800,80.234100',
      )),
      expect: () => [
        isA<ProfileLoaded>()
            .having((s) => s.address, 'address', '123 Food Street, T. Nagar, Chennai')
            .having((s) => s.latitude, 'latitude', 13.0418)
            .having((s) => s.longitude, 'longitude', 80.2341)
            .having((s) => s.googleMapsUrl, 'googleMapsUrl', 'https://www.google.com/maps?q=13.041800,80.234100'),
      ],
      verify: (_) {
        verify(() => mockProfileRepository.updateProfile('seller_123', {
              'address': '123 Food Street, T. Nagar, Chennai',
              'latitude': 13.0418,
              'longitude': 80.2341,
              'googleMapsUrl': 'https://www.google.com/maps?q=13.041800,80.234100',
            })).called(1);
      },
    );

    blocTest<SellerProfilePageBloc, SellerProfilePageState>(
      'SubmitVerificationForm persists address with GPS coordinates to Firestore',
      build: () {
        when(() => mockProfileRepository.updateProfile(
              'seller_123',
              any(),
            )).thenAnswer((_) async {});
        return bloc;
      },
      seed: () => ProfileLoaded(
        storeName: 'Test Kitchen',
        email: 'test@kitchen.com',
        phone: '1234567890',
        profileImageUrl: '',
        notificationsEnabled: true,
        role: 'seller',
        createdAt: DateTime(2025, 1, 1),
        isVerified: true,
      ),
      act: (bloc) => bloc.add(const SubmitVerificationForm(
        storeName: 'Spice Garden',
        address: '45 Anna Nagar, Chennai',
        email: 'spice@garden.com',
        phone: '9876543210',
        gstNumber: '33ABCDE1234F1Z5',
        taxConfiguration: '18%',
        fssaiLicense: '12345678901234',
        bankAccountNumber: '123456789012',
        ifscCode: 'HDFC0001234',
        latitude: 13.0850,
        longitude: 80.2100,
        googleMapsUrl: 'https://www.google.com/maps?q=13.085000,80.210000',
      )),
      expect: () => [
        isA<ProfileLoaded>()
            .having((s) => s.storeName, 'storeName', 'Spice Garden')
            .having((s) => s.address, 'address', '45 Anna Nagar, Chennai')
            .having((s) => s.latitude, 'latitude', 13.0850)
            .having((s) => s.longitude, 'longitude', 80.2100)
            .having((s) => s.gstNumber, 'gstNumber', '33ABCDE1234F1Z5'),
      ],
      verify: (_) {
        verify(() => mockProfileRepository.updateProfile('seller_123', {
              'shopName': 'Spice Garden',
              'email': 'spice@garden.com',
              'phoneNumber': '9876543210',
              'businessDetails': '45 Anna Nagar, Chennai',
              'address': '45 Anna Nagar, Chennai',
              'gstNumber': '33ABCDE1234F1Z5',
              'fssaiNumber': '12345678901234',
              'bankAccountNumber': '123456789012',
              'ifscCode': 'HDFC0001234',
              'taxConfiguration': '18%',
              'latitude': 13.0850,
              'longitude': 80.2100,
              'googleMapsUrl': 'https://www.google.com/maps?q=13.085000,80.210000',
            })).called(1);
      },
    );

    blocTest<SellerProfilePageBloc, SellerProfilePageState>(
      'UpdateCuisines updates state and calls updateProfile',
      build: () {
        when(() => mockProfileRepository.updateProfile(
              'seller_123',
              {'cuisines': ['Biryani', 'Desserts']},
            )).thenAnswer((_) async {});
        return bloc;
      },
      seed: () => ProfileLoaded(
        storeName: 'Test Kitchen',
        email: 'test@kitchen.com',
        phone: '1234567890',
        profileImageUrl: '',
        notificationsEnabled: true,
        role: 'seller',
        createdAt: DateTime(2025, 1, 1),
        isVerified: true,
      ),
      act: (bloc) => bloc.add(const UpdateCuisines(['Biryani', 'Desserts'])),
      expect: () => [
        isA<ProfileLoaded>().having((s) => s.cuisines, 'cuisines', ['Biryani', 'Desserts']),
      ],
    );

    blocTest<SellerProfilePageBloc, SellerProfilePageState>(
      'UpdateCoverImage shows upload progress and updates coverImageUrl',
      build: () {
        when(() => mockProfileRepository.uploadCoverImage(
              sellerId: 'seller_123',
              imageBytes: any(named: 'imageBytes'),
              fileName: 'cover.jpg',
            )).thenAnswer((_) async => 'https://storage.googleapis.com/cover.jpg');
        when(() => mockProfileRepository.updateProfile('seller_123', any()))
            .thenAnswer((_) async {});
        return bloc;
      },
      seed: () => ProfileLoaded(
        storeName: 'Test Kitchen',
        email: 'test@kitchen.com',
        phone: '1234567890',
        profileImageUrl: '',
        notificationsEnabled: true,
        role: 'seller',
        createdAt: DateTime(2025, 1, 1),
        isVerified: true,
      ),
      act: (bloc) => bloc.add(UpdateCoverImage(Uint8List.fromList([1, 2, 3]), 'cover.jpg')),
      expect: () => [
        isA<ProfileLoaded>().having((s) => s.isCoverUploading, 'isCoverUploading', true),
        isA<ProfileLoaded>()
            .having((s) => s.isCoverUploading, 'isCoverUploading', false)
            .having((s) => s.coverImageUrl, 'coverImageUrl', 'https://storage.googleapis.com/cover.jpg'),
      ],
    );

    blocTest<SellerProfilePageBloc, SellerProfilePageState>(
      'LogoutRequested resets state to ProfileInitial and cancels stream subscription',
      build: () => bloc,
      act: (bloc) => bloc.add(LogoutRequested()),
      expect: () => [
        isA<ProfileInitial>(),
      ],
    );
  });
}
