import 'package:flutter_test/flutter_test.dart';

import 'package:food_delivery_app/features/Delivery%20Partner%20Bloc%20Architecture/Delivery_Pickup%20Confirmation_page/Delivery_Pickup%20Confirmation_page_repository.dart';
import 'package:food_delivery_app/features/Delivery%20Partner%20Bloc%20Architecture/Delivery_Pickup%20Confirmation_page/Delivery_Pickup%20Confirmation_page_service.dart';
import 'package:food_delivery_app/features/Delivery%20Partner%20Bloc%20Architecture/Delivery_Pickup%20Confirmation_page/Delivery_Pickup%20Confirmation_page_state.dart';

class _FakePickupService implements DeliveryPickupConfirmationServiceBase {
  @override
  Future<Map<String, dynamic>> fetchPickupConfirmationData(
    String orderId,
  ) async {
    return {
      'orderId': orderId,
      'pickupLocationName': 'Green Mart',
      'pickupAddress': '24, Anna Salai, Chennai - 600002',
      'pickupContactName': 'Priya Sharma',
      'pickupContactPhone': '+919876543210',
      'pickupInstructions': 'Show the order code at the counter.',
      'customerName': 'Mike Johnson',
      'customerAddress': '12, Beach Road, Chennai - 600001',
      'customerPhone': '+919876543211',
      'pickupTime': '12:05 PM',
      'paymentType': 'Cash on Delivery',
      'orderAmount': 486.50,
      'walletBalance': 2450.00,
    };
  }

  @override
  Stream<Map<String, dynamic>> watchPickupConfirmationData(String orderId) =>
      const Stream<Map<String, dynamic>>.empty();

  @override
  Future<Map<String, dynamic>> startDeliveryData(String orderId) async => {};

  @override
  Future<bool> arrivedAtStore(String orderId) async => true;

  @override
  String formatCurrency(double amount) => '₹${amount.toStringAsFixed(2)}';

  @override
  bool isValidPhoneNumber(String phoneNumber) => phoneNumber.length >= 10;

  @override
  String buildWhatsAppLink(String phoneNumber) => 'https://wa.me/$phoneNumber';

  @override
  Map<String, String> getEnvironmentVariables() => const {};

  @override
  Future<bool> requestPhonePermission() async => true;

  @override
  Future<bool> requestLocationPermission() async => true;
}

void main() {
  const sampleModel = PickupConfirmationModel(
    orderId: '#ORD12345',
    pickupLocationName: 'Green Mart',
    pickupAddress: '24, Anna Salai, Chennai - 600002',
    pickupContactName: 'Priya Sharma',
    pickupContactPhone: '+919876543210',
    pickupInstructions: 'Show the order code at the counter.',
    customerName: 'Mike Johnson',
    customerAddress: '12, Beach Road, Chennai - 600001',
    customerPhone: '+919876543211',
    pickupTime: '12:05 PM',
    paymentType: 'Cash on Delivery',
    orderAmount: 486.50,
    walletBalance: 2450.00,
  );

  group('DeliveryPickupConfirmationPage Snapshot Tests', () {
    test('initial snapshot has default status and empty model', () {
      const state = DeliveryPickupConfirmationPageState();

      expect(state.status, PickupConfirmationStatus.initial);
      expect(state.model, isNull);
      expect(state.errorMessage, isNull);
      expect(state.localeCode, 'en');
    });

    test('copyWith produces an updated snapshot without mutating original', () {
      const initial = DeliveryPickupConfirmationPageState();
      final updated = initial.copyWith(
        status: PickupConfirmationStatus.success,
        model: sampleModel,
        errorMessage: 'boom',
      );

      expect(updated.status, PickupConfirmationStatus.success);
      expect(updated.model, sampleModel);
      expect(updated.errorMessage, 'boom');
      expect(initial.status, PickupConfirmationStatus.initial);
      expect(initial.model, isNull);
      expect(updated == initial, isFalse);
    });

    test('clearError resets the error message while keeping other fields', () {
      const errored = DeliveryPickupConfirmationPageState(
        status: PickupConfirmationStatus.error,
        errorMessage: 'boom',
      );
      final cleared = errored.copyWith(clearError: true);

      expect(cleared.errorMessage, isNull);
      expect(cleared.status, PickupConfirmationStatus.error);
    });

    test('loading, success, started and error snapshots differ by status', () {
      const loading = DeliveryPickupConfirmationPageState(
        status: PickupConfirmationStatus.loading,
      );
      const success = DeliveryPickupConfirmationPageState(
        status: PickupConfirmationStatus.success,
      );
      const started = DeliveryPickupConfirmationPageState(
        status: PickupConfirmationStatus.deliveryStarted,
      );
      const error = DeliveryPickupConfirmationPageState(
        status: PickupConfirmationStatus.error,
        errorMessage: 'boom',
      );

      expect(loading == success, isFalse);
      expect(success == started, isFalse);
      expect(started == error, isFalse);
    });

    test('model copyWith updates only the requested fields', () {
      final updated = sampleModel.copyWith(
        customerPhone: '+911234567890',
        orderAmount: 620.00,
      );

      expect(updated.customerPhone, '+911234567890');
      expect(updated.orderAmount, 620.00);
      expect(updated.orderId, '#ORD12345');
      expect(updated.customerName, 'Mike Johnson');
      expect(updated == sampleModel, isFalse);
    });

    test('model equality is driven by all props', () {
      expect(sampleModel, sampleModel.copyWith());
      expect(
        sampleModel,
        const PickupConfirmationModel(
          orderId: '#ORD12345',
          pickupLocationName: 'Green Mart',
          pickupAddress: '24, Anna Salai, Chennai - 600002',
          pickupContactName: 'Priya Sharma',
          pickupContactPhone: '+919876543210',
          pickupInstructions: 'Show the order code at the counter.',
          customerName: 'Mike Johnson',
          customerAddress: '12, Beach Road, Chennai - 600001',
          customerPhone: '+919876543211',
          pickupTime: '12:05 PM',
          paymentType: 'Cash on Delivery',
          orderAmount: 486.50,
          walletBalance: 2450.00,
        ),
      );
    });

    test('repository loaded snapshot matches default payload', () async {
      final model = await DeliveryPickupConfirmationRepository(
        service: _FakePickupService(),
      ).fetchPickupConfirmationDetails('#ORD12345');

      expect(model.orderId, '#ORD12345');
      expect(model.pickupLocationName, 'Green Mart');
      expect(model.customerName, 'Mike Johnson');
      expect(model.pickupTime, '12:05 PM');
      expect(model.orderAmount, 486.50);
      expect(model.walletBalance, 2450.00);
    });
  });
}
