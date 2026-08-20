import 'package:flutter_test/flutter_test.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:food_delivery_app/features/buyer_bloc_architecture/home_Page/seller_model.dart';
import 'package:food_delivery_app/features/seller_bloc_architecture/seller_store_details_page/seller_store_details_page__bloc.dart';
import 'package:food_delivery_app/features/seller_bloc_architecture/seller_store_details_page/seller_store_details_page__event.dart';
import 'package:food_delivery_app/features/seller_bloc_architecture/seller_store_details_page/seller_store_details_page__state.dart';
import 'package:food_delivery_app/repositories/seller_repository.dart';

class MockSellerRepository extends Mock implements SellerRepository {}
class MockUser extends Mock implements User {}

void main() {
  late MockSellerRepository mockRepository;
  late MockUser mockUser;
  late SellerStoreDetailsBloc bloc;

  const testSeller = Seller(
    id: 'seller_123',
    shopName: 'Tasty Bites',
    name: 'Chef John',
    businessDetails: '123 Main St, Foodville',
    phoneNumber: '+919876543210',
    openingHours: '09:00 AM - 10:00 PM',
    deliveryTime: '25-35 mins',
    deliveryArea: '10 km',
    gstNumber: '29ABCDE1234F1Z5',
    fssaiNumber: '12345678901234',
    panNumber: 'ABCDE1234F',
    isOnline: true,
    isOpen: true,
    isAcceptingOrders: true,
    gstPercentage: 5.0,
    minimumOrderValue: 150.0,
    packagingCharges: 20.0,
    bankAccountNumber: '987654321098',
    bankName: 'HDFC Bank',
  );

  setUp(() {
    mockRepository = MockSellerRepository();
    mockUser = MockUser();
    when(() => mockUser.uid).thenReturn('seller_123');
    when(() => mockRepository.currentUser).thenReturn(mockUser);
    bloc = SellerStoreDetailsBloc(repository: mockRepository);
  });

  tearDown(() {
    bloc.close();
  });

  group('SellerStoreDetailsBloc', () {
    test('initial state is SellerStoreDetailsInitial', () {
      expect(bloc.state, equals(SellerStoreDetailsInitial()));
    });

    blocTest<SellerStoreDetailsBloc, SellerStoreDetailsPageState>(
      'emits [Loading, Loaded] when LoadStoreDetailsEvent is added and stream emits seller',
      build: () {
        when(() => mockRepository.fetchSeller('seller_123'))
            .thenAnswer((_) async => testSeller);
        when(() => mockRepository.getSellerById('seller_123'))
            .thenAnswer((_) => Stream.value(testSeller));
        return bloc;
      },
      act: (bloc) => bloc.add(LoadStoreDetailsEvent()),
      expect: () => [
        isA<SellerStoreDetailsLoading>(),
        isA<SellerStoreDetailsLoaded>()
            .having((s) => s.restaurantName, 'restaurantName', 'Tasty Bites')
            .having((s) => s.phone, 'phone', '+919876543210')
            .having((s) => s.isOnline, 'isOnline', true)
            .having((s) => s.gstPercentage, 'gstPercentage', 5.0)
            .having((s) => s.autoAcceptOrders, 'autoAcceptOrders', false)
            .having((s) => s.prepBufferTimeMinutes, 'prepBufferTimeMinutes', 15)
            .having((s) => s.maxActiveOrdersLimit, 'maxActiveOrdersLimit', 20)
            .having((s) => s.allowScheduledOrders, 'allowScheduledOrders', true)
            .having((s) => s.allowSpecialInstructions, 'allowSpecialInstructions', true)
            .having((s) => s.cancellationWindowMinutes, 'cancellationWindowMinutes', 2)
            .having((s) => s.isTaxIncludedInPrice, 'isTaxIncludedInPrice', true)
            .having((s) => s.invoicePrefix, 'invoicePrefix', 'INV-')
            .having((s) => s.fssaiExpiryDate, 'fssaiExpiryDate', ''),
      ],
    );

    blocTest<SellerStoreDetailsBloc, SellerStoreDetailsPageState>(
      'emits [Loading, Error] when user is not authenticated',
      build: () {
        when(() => mockRepository.currentUser).thenReturn(null);
        return bloc;
      },
      act: (bloc) => bloc.add(LoadStoreDetailsEvent()),
      expect: () => [
        isA<SellerStoreDetailsLoading>(),
        isA<SellerStoreDetailsError>()
            .having((s) => s.message, 'message', 'User not authenticated'),
      ],
    );

    blocTest<SellerStoreDetailsBloc, SellerStoreDetailsPageState>(
      'calls updateSellerData on ToggleStoreStatusEvent',
      build: () {
        when(() => mockRepository.fetchSeller('seller_123'))
            .thenAnswer((_) async => testSeller);
        when(() => mockRepository.getSellerById('seller_123'))
            .thenAnswer((_) => Stream.value(testSeller));
        when(() => mockRepository.updateSellerData('seller_123', {'isOnline': false}))
            .thenAnswer((_) async {});
        return bloc;
      },
      act: (bloc) async {
        bloc.add(LoadStoreDetailsEvent());
        await Future.delayed(const Duration(milliseconds: 10));
        bloc.add(const ToggleStoreStatusEvent(false));
      },
      verify: (_) {
        verify(() => mockRepository.updateSellerData('seller_123', {'isOnline': false})).called(1);
      },
    );

    blocTest<SellerStoreDetailsBloc, SellerStoreDetailsPageState>(
      'calls updateSellerData on UpdateFieldEvent',
      build: () {
        when(() => mockRepository.fetchSeller('seller_123'))
            .thenAnswer((_) async => testSeller);
        when(() => mockRepository.getSellerById('seller_123'))
            .thenAnswer((_) => Stream.value(testSeller));
        when(() => mockRepository.updateSellerData('seller_123', {'openingHours': '08:00 AM - 11:00 PM'}))
            .thenAnswer((_) async {});
        return bloc;
      },
      act: (bloc) async {
        bloc.add(LoadStoreDetailsEvent());
        await Future.delayed(const Duration(milliseconds: 10));
        bloc.add(const UpdateFieldEvent('openingHours', '08:00 AM - 11:00 PM'));
      },
      verify: (_) {
        verify(() => mockRepository.updateSellerData('seller_123', {'openingHours': '08:00 AM - 11:00 PM'})).called(1);
      },
    );
  });
}
