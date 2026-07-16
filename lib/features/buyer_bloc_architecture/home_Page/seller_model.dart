import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

class Seller extends Equatable {
  final String id;
  final String shopName;
  final String sellerName;
  final String fullAddress;
  final String city;
  final String state;
  final String pincode;
  final String contactNumber;
  final String profileImageUrl;
  final String name;
  final String businessDetails;
  final String phoneNumber;
  final String openingHours;
  final String deliveryTime;
  final String deliveryArea;
  final String gstNumber;
  final String fssaiNumber;
  final String panNumber;
  final bool isOnline;
  final double gstPercentage;
  final double minimumOrderValue;
  final double packagingCharges;
  final String bankAccountNumber;
  final String bankName;

  const Seller({
    required this.id,
    this.shopName = '',
    this.sellerName = '',
    this.fullAddress = '',
    this.city = '',
    this.state = '',
    this.pincode = '',
    this.contactNumber = '',
    this.profileImageUrl = '',
    this.name = '',
    this.businessDetails = '',
    this.phoneNumber = '',
    this.openingHours = '',
    this.deliveryTime = '',
    this.deliveryArea = '',
    this.gstNumber = '',
    this.fssaiNumber = '',
    this.panNumber = '',
    this.isOnline = false,
    this.gstPercentage = 0.0,
    this.minimumOrderValue = 0.0,
    this.packagingCharges = 0.0,
    this.bankAccountNumber = '',
    this.bankName = '',
  });

  @override
  List<Object?> get props => [
    id, shopName, sellerName, fullAddress, city, state, pincode, contactNumber, profileImageUrl,
    name, businessDetails, phoneNumber, openingHours, deliveryTime, deliveryArea, gstNumber, fssaiNumber,
    panNumber, isOnline, gstPercentage, minimumOrderValue, packagingCharges, bankAccountNumber, bankName,
  ];

  factory Seller.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>? ?? {};

    return Seller(
      id: doc.id,
      shopName: data['shopName'] as String? ?? '',
      sellerName: data['sellerName'] as String? ?? '',
      fullAddress: data['address'] as String? ?? '',
      city: data['city'] as String? ?? '',
      state: data['state'] as String? ?? '',
      pincode: data['pincode'] as String? ?? '',
      contactNumber: data['contactNumber'] as String? ?? '',
      profileImageUrl: data['profileImageUrl'] as String? ?? '',
      name: data['name'] as String? ?? '',
      businessDetails: data['businessDetails'] as String? ?? '',
      phoneNumber: data['phoneNumber'] as String? ?? data['contactNumber'] as String? ?? '',
      openingHours: data['openingHours'] as String? ?? '',
      deliveryTime: data['deliveryTime'] as String? ?? '',
      deliveryArea: data['deliveryArea'] as String? ?? '',
      gstNumber: data['gstNumber'] as String? ?? '',
      fssaiNumber: data['fssaiNumber'] as String? ?? '',
      panNumber: data['panNumber'] as String? ?? '',
      isOnline: data['isOnline'] as bool? ?? false,
      gstPercentage: (data['gstPercentage'] as num?)?.toDouble() ?? 0.0,
      minimumOrderValue: (data['minimumOrderValue'] as num?)?.toDouble() ?? 0.0,
      packagingCharges: (data['packagingCharges'] as num?)?.toDouble() ?? 0.0,
      bankAccountNumber: data['bankAccountNumber'] as String? ?? '',
      bankName: data['bankName'] as String? ?? '',
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'shopName': shopName,
      'sellerName': sellerName,
      'address': fullAddress,
      'city': city,
      'state': state,
      'pincode': pincode,
      'contactNumber': contactNumber,
      'profileImageUrl': profileImageUrl,
      'name': name,
      'businessDetails': businessDetails,
      'phoneNumber': phoneNumber,
      'openingHours': openingHours,
      'deliveryTime': deliveryTime,
      'deliveryArea': deliveryArea,
      'gstNumber': gstNumber,
      'fssaiNumber': fssaiNumber,
      'panNumber': panNumber,
      'isOnline': isOnline,
      'gstPercentage': gstPercentage,
      'minimumOrderValue': minimumOrderValue,
      'packagingCharges': packagingCharges,
      'bankAccountNumber': bankAccountNumber,
      'bankName': bankName,
    };
  }

  static const empty = Seller(id: '');
}
