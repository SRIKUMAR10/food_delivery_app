import 'package:flutter_test/flutter_test.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:food_delivery_app/features/seller_bloc_architecture/seller_setting_page/seller_setting_page__bloc.dart';
import 'package:food_delivery_app/features/seller_bloc_architecture/seller_setting_page/seller_setting_page__event.dart';
import 'package:food_delivery_app/features/seller_bloc_architecture/seller_setting_page/seller_setting_page__state.dart';

class MockSellerSettingRepository extends Mock implements SellerSettingRepository {}

void main() {
  setUpAll(() {
    registerFallbackValue(const SellerSettingState());
  });

  group('SellerSettingBloc Comprehensive Tests', () {
    late SellerSettingBloc bloc;
    late MockSellerSettingRepository mockRepository;

    setUp(() {
      mockRepository = MockSellerSettingRepository();
      when(() => mockRepository.watchSettings()).thenAnswer((_) => const Stream.empty());
      bloc = SellerSettingBloc(repository: mockRepository);
    });

    tearDown(() {
      bloc.close();
    });

    test('initial state is correct', () {
      expect(bloc.state, const SellerSettingState());
    });

    blocTest<SellerSettingBloc, SellerSettingState>(
      'emits [isLoading: true, loaded settings] when LoadSellerSettings succeeds',
      build: () {
        when(() => mockRepository.loadSettings()).thenAnswer(
          (_) async => const SellerSettingState(restaurantName: 'Spice Palace', pushNotifications: false),
        );
        return bloc;
      },
      act: (bloc) => bloc.add(LoadSellerSettings()),
      expect: () => [
        const SellerSettingState(isLoading: true),
        const SellerSettingState(isLoading: false, restaurantName: 'Spice Palace', pushNotifications: false),
      ],
      verify: (_) {
        verify(() => mockRepository.loadSettings()).called(1);
      },
    );

    blocTest<SellerSettingBloc, SellerSettingState>(
      'emits [isLoading: true, error] when LoadSellerSettings fails',
      build: () {
        when(() => mockRepository.loadSettings()).thenThrow(Exception('Network Error'));
        return bloc;
      },
      act: (bloc) => bloc.add(LoadSellerSettings()),
      expect: () => [
        const SellerSettingState(isLoading: true),
        const SellerSettingState(isLoading: false, error: 'Exception: Network Error'),
      ],
    );

    blocTest<SellerSettingBloc, SellerSettingState>(
      'updates selected section index when SelectSettingsSection is added',
      build: () => bloc,
      act: (bloc) => bloc.add(const SelectSettingsSection(3)),
      expect: () => [
        const SellerSettingState(selectedSectionIndex: 3),
      ],
    );

    blocTest<SellerSettingBloc, SellerSettingState>(
      'emits updated live state when SettingsUpdatedFromStream is received',
      build: () => bloc,
      act: (bloc) => bloc.add(const SettingsUpdatedFromStream(
        SellerSettingState(restaurantName: 'Live Cloud Kitchen', isOpen: true),
      )),
      expect: () => [
        const SellerSettingState(restaurantName: 'Live Cloud Kitchen', isOpen: true, isLoading: false),
      ],
    );

    // 1. Restaurant Info Test
    blocTest<SellerSettingBloc, SellerSettingState>(
      'updates restaurant info and saves to repository',
      build: () {
        when(() => mockRepository.saveSettings(any())).thenAnswer((_) async {});
        return bloc;
      },
      act: (bloc) => bloc.add(const UpdateRestaurantInfo(
        restaurantName: 'New Palace',
        ownerName: 'Chef Ramsey',
        phoneNumber: '+919988776655',
        email: 'ramsey@kitchen.com',
        restaurantDescription: 'Exquisite Fine Dining',
        address: '77 Chef Avenue',
        cuisines: ['Continental', 'Italian'],
      )),
      expect: () => [
        const SellerSettingState(isSaving: true),
        const SellerSettingState(
          isSaving: false,
          restaurantName: 'New Palace',
          ownerName: 'Chef Ramsey',
          phoneNumber: '+919988776655',
          email: 'ramsey@kitchen.com',
          restaurantDescription: 'Exquisite Fine Dining',
          address: '77 Chef Avenue',
          cuisines: ['Continental', 'Italian'],
          successMessage: 'Restaurant information updated successfully.',
        ),
      ],
      verify: (_) {
        verify(() => mockRepository.saveSettings(any())).called(1);
      },
    );

    // 2. Business Hours & Emergency Closure Test
    blocTest<SellerSettingBloc, SellerSettingState>(
      'updates emergency closure status',
      build: () {
        when(() => mockRepository.saveSettings(any())).thenAnswer((_) async {});
        return bloc;
      },
      act: (bloc) => bloc.add(const ToggleEmergencyClosure(true)),
      expect: () => [
        const SellerSettingState(
          isEmergencyClosed: true,
          isOpen: false,
          successMessage: 'Store marked as temporarily closed.',
        ),
      ],
    );

    // 3. Delivery Settings Test
    blocTest<SellerSettingBloc, SellerSettingState>(
      'updates delivery settings',
      build: () {
        when(() => mockRepository.saveSettings(any())).thenAnswer((_) async {});
        return bloc;
      },
      act: (bloc) => bloc.add(const UpdateDeliverySettings(
        deliveryRadius: 15.0,
        minimumOrderValue: 200.0,
        baseDeliveryFee: 30.0,
        perKmDeliveryFee: 6.0,
        freeDeliveryThreshold: 600.0,
        estimatedPrepTimeMinutes: 25,
        deliveryTimeEstimate: '35-50 mins',
        packagingCharges: 20.0,
        allowSelfPickup: true,
        isSelfDelivery: true,
      )),
      expect: () => [
        const SellerSettingState(isSaving: true),
        const SellerSettingState(
          isSaving: false,
          deliveryRadius: 15.0,
          minimumOrderValue: 200.0,
          baseDeliveryFee: 30.0,
          perKmDeliveryFee: 6.0,
          freeDeliveryThreshold: 600.0,
          estimatedPrepTimeMinutes: 25,
          deliveryTimeEstimate: '35-50 mins',
          packagingCharges: 20.0,
          allowSelfPickup: true,
          isSelfDelivery: true,
          successMessage: 'Delivery settings updated successfully.',
        ),
      ],
    );

    // 4. Order Settings Test
    blocTest<SellerSettingBloc, SellerSettingState>(
      'updates order flow settings',
      build: () {
        when(() => mockRepository.saveSettings(any())).thenAnswer((_) async {});
        return bloc;
      },
      act: (bloc) => bloc.add(const UpdateOrderSettings(
        autoAcceptOrders: true,
        prepBufferTimeMinutes: 20,
        maxActiveOrdersLimit: 30,
        allowScheduledOrders: false,
        allowSpecialInstructions: true,
        cancellationWindowMinutes: 3,
      )),
      expect: () => [
        const SellerSettingState(isSaving: true),
        const SellerSettingState(
          isSaving: false,
          autoAcceptOrders: true,
          prepBufferTimeMinutes: 20,
          maxActiveOrdersLimit: 30,
          allowScheduledOrders: false,
          allowSpecialInstructions: true,
          cancellationWindowMinutes: 3,
          successMessage: 'Order preferences updated.',
        ),
      ],
    );

    // 5. Notification Settings Test
    blocTest<SellerSettingBloc, SellerSettingState>(
      'updates advanced notification settings',
      build: () {
        when(() => mockRepository.saveSettings(any())).thenAnswer((_) async {});
        return bloc;
      },
      act: (bloc) => bloc.add(const UpdateNotificationAdvancedSettings(
        pushNotifications: true,
        newOrderSound: true,
        soundLoopUntilAccepted: false,
        orderAlertRingtone: 'Digital Siren',
        soundVolume: 0.9,
        promoAndOffers: true,
        lowStockAlerts: true,
        orderUpdates: true,
        whatsappNotifications: true,
        smsNotifications: true,
      )),
      expect: () => [
        const SellerSettingState(isSaving: true),
        const SellerSettingState(
          isSaving: false,
          pushNotifications: true,
          newOrderSound: true,
          soundLoopUntilAccepted: false,
          orderAlertRingtone: 'Digital Siren',
          soundVolume: 0.9,
          promoAndOffers: true,
          lowStockAlerts: true,
          orderUpdates: true,
          whatsappNotifications: true,
          smsNotifications: true,
          successMessage: 'Notification preferences saved.',
        ),
      ],
    );

    // 6. Payment Settings Test
    blocTest<SellerSettingBloc, SellerSettingState>(
      'updates payment & payout settings',
      build: () {
        when(() => mockRepository.saveSettings(any())).thenAnswer((_) async {});
        return bloc;
      },
      act: (bloc) => bloc.add(const UpdatePaymentSettings(
        acceptCashOnDelivery: false,
        acceptOnlinePayments: true,
        acceptWalletPayments: true,
        payoutSchedule: 'Weekly',
        minPayoutThreshold: 1000.0,
        autoSettlementEnabled: true,
      )),
      expect: () => [
        const SellerSettingState(isSaving: true),
        const SellerSettingState(
          isSaving: false,
          acceptCashOnDelivery: false,
          acceptOnlinePayments: true,
          acceptWalletPayments: true,
          payoutSchedule: 'Weekly',
          minPayoutThreshold: 1000.0,
          autoSettlementEnabled: true,
          successMessage: 'Payment configuration saved.',
        ),
      ],
    );

    // 7. Bank UPI Settings Test
    blocTest<SellerSettingBloc, SellerSettingState>(
      'updates bank & UPI settings',
      build: () {
        when(() => mockRepository.saveSettings(any())).thenAnswer((_) async {});
        return bloc;
      },
      act: (bloc) => bloc.add(const UpdateBankUpiSettings(
        accountHolderName: 'Spice Symphony Pvt Ltd',
        bankName: 'ICICI Bank',
        bankAccountNumber: '001122334455',
        ifscCode: 'ICIC0001234',
        bankBranch: 'T Nagar',
        upiId: 'spice@icici',
        primaryPayoutMethod: 'upi',
      )),
      expect: () => [
        const SellerSettingState(isSaving: true),
        const SellerSettingState(
          isSaving: false,
          accountHolderName: 'Spice Symphony Pvt Ltd',
          bankName: 'ICICI Bank',
          bankAccountNumber: '001122334455',
          ifscCode: 'ICIC0001234',
          bankBranch: 'T Nagar',
          upiId: 'spice@icici',
          primaryPayoutMethod: 'upi',
          successMessage: 'Bank & UPI details updated successfully.',
        ),
      ],
    );

    // 8. Tax Info Test
    blocTest<SellerSettingBloc, SellerSettingState>(
      'updates tax & compliance info',
      build: () {
        when(() => mockRepository.saveSettings(any())).thenAnswer((_) async {});
        return bloc;
      },
      act: (bloc) => bloc.add(const UpdateTaxSettings(
        gstNumber: '33ABCDE1234F1Z5',
        gstPercentage: 5.0,
        isTaxIncludedInPrice: true,
        panNumber: 'ABCDE1234F',
        fssaiNumber: '12423000000000',
        fssaiExpiryDate: '2028-12-31',
        invoicePrefix: 'TAX-',
      )),
      expect: () => [
        const SellerSettingState(isSaving: true),
        const SellerSettingState(
          isSaving: false,
          gstNumber: '33ABCDE1234F1Z5',
          gstPercentage: 5.0,
          isTaxIncludedInPrice: true,
          panNumber: 'ABCDE1234F',
          fssaiNumber: '12423000000000',
          fssaiExpiryDate: '2028-12-31',
          invoicePrefix: 'TAX-',
          successMessage: 'Tax and compliance info saved.',
        ),
      ],
    );

    // 9. Change Password Test
    blocTest<SellerSettingBloc, SellerSettingState>(
      'changes password successfully',
      build: () {
        when(() => mockRepository.changePassword(any(), any(), signOutOtherDevices: any(named: 'signOutOtherDevices')))
            .thenAnswer((_) async {});
        return bloc;
      },
      act: (bloc) => bloc.add(const ChangePasswordRequested(
        currentPassword: 'OldPassword123!',
        newPassword: 'NewStrongPassword456@',
        signOutOtherDevices: true,
      )),
      expect: () => [
        const SellerSettingState(isSaving: true),
        predicate<SellerSettingState>((s) => s.isSaving == false && s.successMessage == 'Password changed successfully.'),
      ],
    );

    // 10. Deactivate Account Test
    blocTest<SellerSettingBloc, SellerSettingState>(
      'deactivates account temporarily',
      build: () {
        when(() => mockRepository.deactivateAccount(any(), any()))
            .thenAnswer((_) async {});
        return bloc;
      },
      act: (bloc) => bloc.add(const DeactivateAccountRequested(
        reason: 'Renovation work',
        durationDays: 14,
      )),
      expect: () => [
        const SellerSettingState(isSaving: true),
        const SellerSettingState(
          isSaving: false,
          isDeactivated: true,
          deactivationReason: 'Renovation work',
          isOpen: false,
          isAcceptingOrders: false,
          successMessage: 'Account temporarily deactivated for 14 days.',
        ),
      ],
    );

    // 11. Delete Account Validation Test
    blocTest<SellerSettingBloc, SellerSettingState>(
      'fails delete account when keyword is not DELETE',
      build: () => bloc,
      act: (bloc) => bloc.add(const DeleteAccountRequested(
        password: 'Pass',
        confirmationKeyword: 'NO',
      )),
      expect: () => [
        const SellerSettingState(error: 'Please type DELETE to confirm permanent account deletion.'),
      ],
    );

    // 12. Logout Test
    blocTest<SellerSettingBloc, SellerSettingState>(
      'logs out successfully',
      build: () {
        when(() => mockRepository.logout()).thenAnswer((_) async {});
        return bloc;
      },
      act: (bloc) => bloc.add(LogoutRequested()),
      expect: () => [
        const SellerSettingState(isLoading: true),
        const SellerSettingState(isLoading: false),
      ],
      verify: (_) {
        verify(() => mockRepository.logout()).called(1);
      },
    );
  });
}
