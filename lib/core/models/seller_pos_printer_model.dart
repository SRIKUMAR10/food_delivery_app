import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

class PosPrinterSettingsModel extends Equatable {
  final bool isAutoPrintEnabled;
  final String printerType; // 'bluetooth', 'wifi_network', 'usb'
  final String printerPaperSize; // '58mm', '80mm'
  final String? printerMacAddress;
  final String? printerIpAddress;
  final int printKotCopies;
  final bool printCustomerReceipt;
  final String? headerCustomNote;
  final bool fssaiLicenseOnBill;
  final bool gstNumberOnBill;
  final DateTime? updatedAt;

  const PosPrinterSettingsModel({
    this.isAutoPrintEnabled = true,
    this.printerType = 'bluetooth',
    this.printerPaperSize = '80mm',
    this.printerMacAddress,
    this.printerIpAddress,
    this.printKotCopies = 2,
    this.printCustomerReceipt = true,
    this.headerCustomNote,
    this.fssaiLicenseOnBill = true,
    this.gstNumberOnBill = true,
    this.updatedAt,
  });

  factory PosPrinterSettingsModel.fromMap(Map<String, dynamic>? data) {
    if (data == null) return const PosPrinterSettingsModel();

    DateTime? parsedUpdatedAt;
    final rawDate = data['updatedAt'];
    if (rawDate is Timestamp) {
      parsedUpdatedAt = rawDate.toDate();
    } else if (rawDate is String) {
      parsedUpdatedAt = DateTime.tryParse(rawDate);
    }

    return PosPrinterSettingsModel(
      isAutoPrintEnabled: data['isAutoPrintEnabled'] as bool? ?? true,
      printerType: data['printerType'] as String? ?? 'bluetooth',
      printerPaperSize: data['printerPaperSize'] as String? ?? '80mm',
      printerMacAddress: data['printerMacAddress'] as String?,
      printerIpAddress: data['printerIpAddress'] as String?,
      printKotCopies: (data['printKotCopies'] as num?)?.toInt() ?? 2,
      printCustomerReceipt: data['printCustomerReceipt'] as bool? ?? true,
      headerCustomNote: data['headerCustomNote'] as String?,
      fssaiLicenseOnBill: data['fssaiLicenseOnBill'] as bool? ?? true,
      gstNumberOnBill: data['gstNumberOnBill'] as bool? ?? true,
      updatedAt: parsedUpdatedAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'isAutoPrintEnabled': isAutoPrintEnabled,
      'printerType': printerType,
      'printerPaperSize': printerPaperSize,
      if (printerMacAddress != null) 'printerMacAddress': printerMacAddress,
      if (printerIpAddress != null) 'printerIpAddress': printerIpAddress,
      'printKotCopies': printKotCopies,
      'printCustomerReceipt': printCustomerReceipt,
      if (headerCustomNote != null) 'headerCustomNote': headerCustomNote,
      'fssaiLicenseOnBill': fssaiLicenseOnBill,
      'gstNumberOnBill': gstNumberOnBill,
      'updatedAt': updatedAt != null
          ? Timestamp.fromDate(updatedAt!)
          : FieldValue.serverTimestamp(),
    };
  }

  PosPrinterSettingsModel copyWith({
    bool? isAutoPrintEnabled,
    String? printerType,
    String? printerPaperSize,
    String? printerMacAddress,
    String? printerIpAddress,
    int? printKotCopies,
    bool? printCustomerReceipt,
    String? headerCustomNote,
    bool? fssaiLicenseOnBill,
    bool? gstNumberOnBill,
    DateTime? updatedAt,
  }) {
    return PosPrinterSettingsModel(
      isAutoPrintEnabled: isAutoPrintEnabled ?? this.isAutoPrintEnabled,
      printerType: printerType ?? this.printerType,
      printerPaperSize: printerPaperSize ?? this.printerPaperSize,
      printerMacAddress: printerMacAddress ?? this.printerMacAddress,
      printerIpAddress: printerIpAddress ?? this.printerIpAddress,
      printKotCopies: printKotCopies ?? this.printKotCopies,
      printCustomerReceipt:
          printCustomerReceipt ?? this.printCustomerReceipt,
      headerCustomNote: headerCustomNote ?? this.headerCustomNote,
      fssaiLicenseOnBill: fssaiLicenseOnBill ?? this.fssaiLicenseOnBill,
      gstNumberOnBill: gstNumberOnBill ?? this.gstNumberOnBill,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
        isAutoPrintEnabled,
        printerType,
        printerPaperSize,
        printerMacAddress,
        printerIpAddress,
        printKotCopies,
        printCustomerReceipt,
        headerCustomNote,
        fssaiLicenseOnBill,
        gstNumberOnBill,
        updatedAt,
      ];
}
