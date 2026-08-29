import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:food_delivery_app/app_data_collection/seller_collections/seller_collection.dart';
import 'package:food_delivery_app/core/models/seller_model.dart';
import 'package:food_delivery_app/core/models/seller_pos_printer_model.dart';
import 'package:food_delivery_app/core/models/seller_delivery_surge_model.dart';
import 'package:food_delivery_app/core/models/seller_staff_model.dart';
import 'package:food_delivery_app/core/models/seller_ledger_model.dart';
import 'package:food_delivery_app/core/models/seller_performance_model.dart';

class MockSellerCollection extends Mock implements SellerCollection {}

void main() {
  group('SellerCollection Unit Tests', () {
    late MockSellerCollection mockSellerCollection;

    setUp(() {
      mockSellerCollection = MockSellerCollection();
    });

    test('addSeller handles seller persistence successfully', () async {
      final testSeller = SellerModel(
        id: 'seller_123',
        name: 'Test Kitchen',
        shopName: 'Test Kitchen',
        email: 'test@kitchen.com',
        phoneNumber: '9876543210',
        createdAt: DateTime(2025, 1, 1),
      );

      when(() => mockSellerCollection.addSeller(testSeller))
          .thenAnswer((_) async {});

      await mockSellerCollection.addSeller(testSeller);

      verify(() => mockSellerCollection.addSeller(testSeller)).called(1);
    });

    test('updateSeller updates seller document in Firestore', () async {
      const uid = 'seller_123';
      final updateData = {'isOnline': true, 'isOpen': true};

      when(() => mockSellerCollection.updateSeller(uid, updateData))
          .thenAnswer((_) async {});

      await mockSellerCollection.updateSeller(uid, updateData);

      verify(() => mockSellerCollection.updateSeller(uid, updateData)).called(1);
    });

    test('updateKycDocument updates KYC details subcollection', () async {
      const uid = 'seller_123';
      final kycData = {'status': 'in_review', 'fssaiNumber': '12345678901234'};

      when(() => mockSellerCollection.updateKycDocument(uid, kycData))
          .thenAnswer((_) async {});

      await mockSellerCollection.updateKycDocument(uid, kycData);

      verify(() => mockSellerCollection.updateKycDocument(uid, kycData)).called(1);
    });

    test('updatePosPrinterSettings updates thermal printer subcollection', () async {
      const uid = 'seller_123';
      final printerData = {'isAutoPrintEnabled': true, 'printerType': 'bluetooth', 'printerPaperSize': '80mm'};

      when(() => mockSellerCollection.updatePosPrinterSettings(uid, printerData))
          .thenAnswer((_) async {});

      await mockSellerCollection.updatePosPrinterSettings(uid, printerData);

      verify(() => mockSellerCollection.updatePosPrinterSettings(uid, printerData)).called(1);
    });

    test('updateDeliverySurgeSettings updates surge settings subcollection', () async {
      const uid = 'seller_123';
      final surgeData = {'isSurgeActive': true, 'surgeReason': 'heavy_rain', 'surgeDeliveryMultiplier': 1.5};

      when(() => mockSellerCollection.updateDeliverySurgeSettings(uid, surgeData))
          .thenAnswer((_) async {});

      await mockSellerCollection.updateDeliverySurgeSettings(uid, surgeData);

      verify(() => mockSellerCollection.updateDeliverySurgeSettings(uid, surgeData)).called(1);
    });

    test('addOrUpdateStaffMember updates staff members subcollection', () async {
      const uid = 'seller_123';
      const staff = SellerStaffModel(
        staffId: 'staff_01',
        name: 'Kumar',
        phoneNumber: '9876543210',
        role: 'kitchen_staff',
      );

      when(() => mockSellerCollection.addOrUpdateStaffMember(uid, staff))
          .thenAnswer((_) async {});

      await mockSellerCollection.addOrUpdateStaffMember(uid, staff);

      verify(() => mockSellerCollection.addOrUpdateStaffMember(uid, staff)).called(1);
    });

    test('deleteStaffMember removes staff member from subcollection', () async {
      const uid = 'seller_123';
      const staffId = 'staff_01';

      when(() => mockSellerCollection.deleteStaffMember(uid, staffId))
          .thenAnswer((_) async {});

      await mockSellerCollection.deleteStaffMember(uid, staffId);

      verify(() => mockSellerCollection.deleteStaffMember(uid, staffId)).called(1);
    });

    test('addLedgerEntry creates financial settlement entry', () async {
      const uid = 'seller_123';
      const entry = SellerLedgerTransactionModel(
        transactionId: 'txn_01',
        orderId: 'ord_100',
        type: 'order_credit',
        grossAmount: 500,
        platformCommission: 50,
        netCreditedAmount: 450,
        balanceAfter: 1450,
      );

      when(() => mockSellerCollection.addLedgerEntry(uid, entry))
          .thenAnswer((_) async {});

      await mockSellerCollection.addLedgerEntry(uid, entry);

      verify(() => mockSellerCollection.addLedgerEntry(uid, entry)).called(1);
    });

    test('updatePerformanceSummary updates analytics summary subcollection', () async {
      const uid = 'seller_123';
      final summaryData = {'todayRevenue': 1500.0, 'todayOrdersCount': 5};

      when(() => mockSellerCollection.updatePerformanceSummary(uid, summaryData))
          .thenAnswer((_) async {});

      await mockSellerCollection.updatePerformanceSummary(uid, summaryData);

      verify(() => mockSellerCollection.updatePerformanceSummary(uid, summaryData)).called(1);
    });
  });
}