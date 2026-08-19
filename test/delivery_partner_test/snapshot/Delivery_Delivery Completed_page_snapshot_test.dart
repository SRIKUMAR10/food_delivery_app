import 'package:flutter_test/flutter_test.dart';

import 'package:food_delivery_app/features/Delivery%20Partner%20Bloc%20Architecture/Delivery_Delivery%20Completed_page/Delivery_Delivery%20Completed_page_repository.dart';
import 'package:food_delivery_app/features/Delivery%20Partner%20Bloc%20Architecture/Delivery_Delivery%20Completed_page/Delivery_Delivery%20Completed_page_service.dart';
import 'package:food_delivery_app/features/Delivery%20Partner%20Bloc%20Architecture/Delivery_Delivery%20Completed_page/Delivery_Delivery%20Completed_page_state.dart';

class _FakeCompletedService implements DeliveryCompletedServiceBase {
  @override
  Future<Map<String, dynamic>> fetchCompletedOrderData(String orderId) async {
    return {
      'orderId': orderId,
      'walletBalance': 2450.00,
      'partnerName': 'Ravi Kumar',
      'partnerVehicleNo': 'TN 01 AB 1234',
      'customerName': 'Arun Kumar',
      'deliveryAddress': '12, Beach Road, Chennai - 600001',
      'timeTaken': '32 min',
      'distanceCovered': 5.6,
      'paymentStatus': 'Paid Successfully',
      'paymentMethod': 'UPI • Google Pay',
      'customerRating': 5.0,
      'deliveryEarnings': 120.00,
      'completedAt': 'Today, 4:15 PM',
    };
  }

  @override
  Stream<Map<String, dynamic>> watchCompletedOrderData(String orderId) =>
      const Stream<Map<String, dynamic>>.empty();

  @override
  Future<Map<String, dynamic>> completeOrderData(String orderId) async => {};

  @override
  Stream<double> chunkedMediaUpload(String orderId) =>
      const Stream<double>.empty();

  @override
  String? validateMedia(String? filePath) => null;

  @override
  Map<String, String> getEnvironmentVariables() => const {};

  @override
  Future<bool> requestMediaPermission() async => true;

  @override
  Future<bool> requestLocationPermission() async => true;

  @override
  String formatCurrency(double amount) => '₹${amount.toStringAsFixed(2)}';

  @override
  String formatDistance(double distance) =>
      '${distance.toStringAsFixed(1)} km';
}

void main() {
  const sampleModel = DeliveryCompletedModel(
    orderId: '#ORD12345',
    walletBalance: 2450.00,
    partnerName: 'Ravi Kumar',
    partnerVehicleNo: 'TN 01 AB 1234',
    customerName: 'Arun Kumar',
    deliveryAddress: '12, Beach Road, Chennai - 600001',
    timeTaken: '32 min',
    distanceCovered: 5.6,
    paymentStatus: 'Paid Successfully',
    paymentMethod: 'UPI • Google Pay',
    customerRating: 5.0,
    deliveryEarnings: 120.00,
    completedAt: 'Today, 4:15 PM',
  );

  group('DeliveryCompletedPage Snapshot Tests', () {
    test('initial snapshot has default status and empty model', () {
      const state = DeliveryCompletedPageState();

      expect(state.status, DeliveryCompletedStatus.initial);
      expect(state.model, isNull);
      expect(state.errorMessage, isNull);
      expect(state.localeCode, 'en');
      expect(state.proofUploadStatus, DeliveryProofUploadStatus.idle);
      expect(state.isCompleting, isFalse);
      expect(state.ratingSubmitted, isFalse);
    });

    test('copyWith produces an updated snapshot without mutating original', () {
      const initial = DeliveryCompletedPageState();
      final updated = initial.copyWith(
        status: DeliveryCompletedStatus.success,
        model: sampleModel,
        errorMessage: 'boom',
      );

      expect(updated.status, DeliveryCompletedStatus.success);
      expect(updated.model, sampleModel);
      expect(updated.errorMessage, 'boom');
      expect(initial.status, DeliveryCompletedStatus.initial);
      expect(initial.model, isNull);
      expect(updated == initial, isFalse);
    });

    test('clearError resets the error message while keeping other fields', () {
      const errored = DeliveryCompletedPageState(
        status: DeliveryCompletedStatus.error,
        errorMessage: 'boom',
      );
      final cleared = errored.copyWith(clearError: true);

      expect(cleared.errorMessage, isNull);
      expect(cleared.status, DeliveryCompletedStatus.error);
    });

    test(
      'loading, success, completed and error snapshots differ by status',
      () {
        const loading = DeliveryCompletedPageState(
          status: DeliveryCompletedStatus.loading,
        );
        const success = DeliveryCompletedPageState(
          status: DeliveryCompletedStatus.success,
        );
        const completed = DeliveryCompletedPageState(
          status: DeliveryCompletedStatus.completed,
        );
        const error = DeliveryCompletedPageState(
          status: DeliveryCompletedStatus.error,
          errorMessage: 'boom',
        );

        expect(loading == success, isFalse);
        expect(success == completed, isFalse);
        expect(completed == error, isFalse);
      },
    );

    test('copyWith tracks upload and rating state', () {
      const initial = DeliveryCompletedPageState();
      final uploading = initial.copyWith(
        proofUploadStatus: DeliveryProofUploadStatus.uploading,
        proofUploadProgress: 0.6,
      );
      final rated = uploading.copyWith(ratedScore: 5, ratingSubmitted: true);

      expect(uploading.isUploading, isTrue);
      expect(uploading.proofUploadProgress, 0.6);
      expect(rated.ratedScore, 5);
      expect(rated.ratingSubmitted, isTrue);
      expect(initial.isUploading, isFalse);
    });

    test('model copyWith updates only the requested fields', () {
      final updated = sampleModel.copyWith(
        customerName: 'Priya Sharma',
        deliveryEarnings: 160.00,
      );

      expect(updated.customerName, 'Priya Sharma');
      expect(updated.deliveryEarnings, 160.00);
      expect(updated.orderId, '#ORD12345');
      expect(updated.customerName, isNot(sampleModel.customerName));
      expect(updated == sampleModel, isFalse);
    });

    test('model equality is driven by all props', () {
      expect(sampleModel, sampleModel.copyWith());
      expect(
        sampleModel,
        const DeliveryCompletedModel(
          orderId: '#ORD12345',
          walletBalance: 2450.00,
          partnerName: 'Ravi Kumar',
          partnerVehicleNo: 'TN 01 AB 1234',
          customerName: 'Arun Kumar',
          deliveryAddress: '12, Beach Road, Chennai - 600001',
          timeTaken: '32 min',
          distanceCovered: 5.6,
          paymentStatus: 'Paid Successfully',
          paymentMethod: 'UPI • Google Pay',
          customerRating: 5.0,
          deliveryEarnings: 120.00,
          completedAt: 'Today, 4:15 PM',
        ),
      );
    });

    test('repository loaded snapshot matches default payload', () async {
      final model = await DeliveryCompletedRepository(
        service: _FakeCompletedService(),
      ).fetchCompletedOrderDetails('#ORD12345');

      expect(model.orderId, '#ORD12345');
      expect(model.customerName, 'Arun Kumar');
      expect(model.partnerVehicleNo, 'TN 01 AB 1234');
      expect(model.timeTaken, '32 min');
      expect(model.distanceCovered, 5.6);
      expect(model.paymentStatus, 'Paid Successfully');
      expect(model.customerRating, 5.0);
      expect(model.walletBalance, 2450.00);
    });
  });
}
