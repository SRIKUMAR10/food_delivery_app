import 'package:flutter_test/flutter_test.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:food_delivery_app/core/models/seller_pos_printer_model.dart';
import 'package:food_delivery_app/core/models/seller_delivery_surge_model.dart';
import 'package:food_delivery_app/core/models/seller_staff_model.dart';
import 'package:food_delivery_app/core/models/seller_ledger_model.dart';
import 'package:food_delivery_app/core/models/seller_performance_model.dart';

void main() {
  group('Seller Backend Data Models Unit Tests', () {
    test('PosPrinterSettingsModel fromMap, toMap and copyWith work correctly', () {
      final now = DateTime(2026, 8, 30, 10, 0);
      final model = PosPrinterSettingsModel(
        isAutoPrintEnabled: true,
        printerType: 'bluetooth',
        printerPaperSize: '80mm',
        printerMacAddress: '00:11:22:33:44:55',
        printerIpAddress: '192.168.1.100',
        printKotCopies: 3,
        printCustomerReceipt: true,
        headerCustomNote: 'Welcome to Special Fast Food',
        fssaiLicenseOnBill: true,
        gstNumberOnBill: true,
        updatedAt: now,
      );

      final map = model.toMap();
      expect(map['isAutoPrintEnabled'], true);
      expect(map['printerType'], 'bluetooth');
      expect(map['printerPaperSize'], '80mm');
      expect(map['printerMacAddress'], '00:11:22:33:44:55');
      expect(map['printKotCopies'], 3);
      expect(map['headerCustomNote'], 'Welcome to Special Fast Food');

      final fromMapModel = PosPrinterSettingsModel.fromMap(map);
      expect(fromMapModel.isAutoPrintEnabled, true);
      expect(fromMapModel.printerType, 'bluetooth');
      expect(fromMapModel.printKotCopies, 3);

      final updated = model.copyWith(printKotCopies: 1, isAutoPrintEnabled: false);
      expect(updated.printKotCopies, 1);
      expect(updated.isAutoPrintEnabled, false);
      expect(updated.printerPaperSize, '80mm');
    });

    test('DeliverySurgeSettingsModel fromMap, toMap and copyWith work correctly', () {
      final now = DateTime(2026, 8, 30, 12, 0);
      final disableTime = DateTime(2026, 8, 30, 15, 0);
      final model = DeliverySurgeSettingsModel(
        isSurgeActive: true,
        surgeReason: 'heavy_rain',
        surgeDeliveryMultiplier: 1.5,
        extraPrepTimeMinutes: 10,
        autoDisableAt: disableTime,
        updatedAt: now,
      );

      final map = model.toMap();
      expect(map['isSurgeActive'], true);
      expect(map['surgeReason'], 'heavy_rain');
      expect(map['surgeDeliveryMultiplier'], 1.5);
      expect(map['extraPrepTimeMinutes'], 10);

      final fromMapModel = DeliverySurgeSettingsModel.fromMap(map);
      expect(fromMapModel.isSurgeActive, true);
      expect(fromMapModel.surgeReason, 'heavy_rain');
      expect(fromMapModel.surgeDeliveryMultiplier, 1.5);
      expect(fromMapModel.extraPrepTimeMinutes, 10);

      final updated = model.copyWith(isSurgeActive: false, surgeDeliveryMultiplier: 1.0);
      expect(updated.isSurgeActive, false);
      expect(updated.surgeDeliveryMultiplier, 1.0);
    });

    test('SellerStaffModel and StaffPermissions fromMap, toMap and copyWith work correctly', () {
      final now = DateTime(2026, 8, 30, 9, 0);
      const permissions = StaffPermissions(
        canAcceptRejectOrders: true,
        canMarkOrderReady: true,
        canEditMenuStock: false,
        canViewFinancials: false,
        canRequestPayout: false,
        canModifySettings: false,
      );

      final staff = SellerStaffModel(
        staffId: 'STF_101',
        name: 'John Master Chef',
        phoneNumber: '+919876543210',
        role: 'kitchen_staff',
        permissions: permissions,
        isActive: true,
        createdAt: now,
        updatedAt: now,
      );

      final map = staff.toMap();
      expect(map['staffId'], 'STF_101');
      expect(map['name'], 'John Master Chef');
      expect(map['role'], 'kitchen_staff');
      expect((map['permissions'] as Map)['canMarkOrderReady'], true);
      expect((map['permissions'] as Map)['canEditMenuStock'], false);

      final fromMapStaff = SellerStaffModel.fromMap(map, id: 'STF_101');
      expect(fromMapStaff.staffId, 'STF_101');
      expect(fromMapStaff.name, 'John Master Chef');
      expect(fromMapStaff.permissions.canAcceptRejectOrders, true);
      expect(fromMapStaff.permissions.canEditMenuStock, false);

      final updatedStaff = staff.copyWith(role: 'manager', permissions: const StaffPermissions(canViewFinancials: true));
      expect(updatedStaff.role, 'manager');
      expect(updatedStaff.permissions.canViewFinancials, true);
    });

    test('SellerLedgerTransactionModel fromMap, toMap and copyWith work correctly', () {
      final now = DateTime(2026, 8, 30, 14, 0);
      final tx = SellerLedgerTransactionModel(
        transactionId: 'TXN_9988',
        orderId: 'ORD_5544',
        type: 'order_credit',
        grossAmount: 500.0,
        platformCommission: 50.0,
        gstOnCommission: 9.0,
        tdsAmount: 5.0,
        deliveryFeeShare: 30.0,
        netCreditedAmount: 466.0,
        balanceAfter: 15466.0,
        status: 'settled',
        description: 'Order earnings credit after commission and TDS',
        createdAt: now,
      );

      final map = tx.toMap();
      expect(map['transactionId'], 'TXN_9988');
      expect(map['orderId'], 'ORD_5544');
      expect(map['type'], 'order_credit');
      expect(map['grossAmount'], 500.0);
      expect(map['netCreditedAmount'], 466.0);
      expect(map['balanceAfter'], 15466.0);

      final fromMapTx = SellerLedgerTransactionModel.fromMap(map, id: 'TXN_9988');
      expect(fromMapTx.transactionId, 'TXN_9988');
      expect(fromMapTx.netCreditedAmount, 466.0);
      expect(fromMapTx.status, 'settled');

      final updatedTx = tx.copyWith(status: 'reversed');
      expect(updatedTx.status, 'reversed');
    });

    test('SellerPerformanceSummaryModel fromMap, toMap and copyWith work correctly', () {
      final now = DateTime(2026, 8, 30, 18, 0);
      final summary = SellerPerformanceSummaryModel(
        todayRevenue: 12500.0,
        todayOrdersCount: 35,
        todayCompletedCount: 33,
        todayCancelledCount: 2,
        thisWeekRevenue: 85000.0,
        thisMonthRevenue: 340000.0,
        thisYearRevenue: 1200000.0,
        averageOrderValue: 357.14,
        averagePrepTimeMinutes: 17,
        customerRetentionRate: 72.4,
        totalReviewsCount: 280,
        averageStoreRating: 4.8,
        popularHours: {'12_13': 10, '19_20': 15},
        updatedAt: now,
      );

      final map = summary.toMap();
      expect(map['todayRevenue'], 12500.0);
      expect(map['todayOrdersCount'], 35);
      expect(map['averageStoreRating'], 4.8);
      expect((map['popularHours'] as Map)['19_20'], 15);

      final fromMapSummary = SellerPerformanceSummaryModel.fromMap(map);
      expect(fromMapSummary.todayRevenue, 12500.0);
      expect(fromMapSummary.todayCompletedCount, 33);
      expect(fromMapSummary.popularHours['12_13'], 10);

      final updated = summary.copyWith(todayRevenue: 15000.0, todayOrdersCount: 40);
      expect(updated.todayRevenue, 15000.0);
      expect(updated.todayOrdersCount, 40);
    });
  });
}
