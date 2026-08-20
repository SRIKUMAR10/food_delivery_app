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
  final String coverImageUrl;
  final String name;
  final String businessDetails;
  final String phoneNumber;
  final String openingHours;
  final String closingTime;
  final String deliveryTime;
  final String deliveryArea;
  final String gstNumber;
  final String fssaiNumber;
  final String panNumber;
  final bool isOnline;
  final bool isOpen;
  final bool isAcceptingOrders;
  final double gstPercentage;
  final double minimumOrderValue;
  final double packagingCharges;
  final double deliveryRadius;
  final String bankAccountNumber;
  final String bankName;
  final double latitude;
  final double longitude;
  final List<String> cuisines;
  final List<String> weeklyHoliday;
  final int estimatedPrepTimeMinutes;
  final double rating;
  final int reviewCount;
  final String fssaiExpiryDate;
  final bool isTaxIncludedInPrice;
  final String invoicePrefix;
  final bool autoAcceptOrders;
  final int prepBufferTimeMinutes;
  final int maxActiveOrdersLimit;
  final bool allowScheduledOrders;
  final bool allowSpecialInstructions;
  final int cancellationWindowMinutes;

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
    this.coverImageUrl = '',
    this.name = '',
    this.businessDetails = '',
    this.phoneNumber = '',
    this.openingHours = '',
    this.closingTime = '',
    this.deliveryTime = '',
    this.deliveryArea = '',
    this.gstNumber = '',
    this.fssaiNumber = '',
    this.panNumber = '',
    this.isOnline = false,
    this.isOpen = true,
    this.isAcceptingOrders = true,
    this.gstPercentage = 0.0,
    this.minimumOrderValue = 0.0,
    this.packagingCharges = 0.0,
    this.deliveryRadius = 10.0,
    this.bankAccountNumber = '',
    this.bankName = '',
    this.latitude = 0.0,
    this.longitude = 0.0,
    this.cuisines = const [],
    this.weeklyHoliday = const [],
    this.estimatedPrepTimeMinutes = 25,
    this.rating = 0.0,
    this.reviewCount = 0,
    this.fssaiExpiryDate = '',
    this.isTaxIncludedInPrice = true,
    this.invoicePrefix = 'INV-',
    this.autoAcceptOrders = false,
    this.prepBufferTimeMinutes = 15,
    this.maxActiveOrdersLimit = 20,
    this.allowScheduledOrders = true,
    this.allowSpecialInstructions = true,
    this.cancellationWindowMinutes = 2,
  });

  @override
  List<Object?> get props => [
    id, shopName, sellerName, fullAddress, city, state, pincode, contactNumber, profileImageUrl,
    coverImageUrl, name, businessDetails, phoneNumber, openingHours, closingTime, deliveryTime,
    deliveryArea, gstNumber, fssaiNumber, panNumber, isOnline, isOpen, isAcceptingOrders,
    gstPercentage, minimumOrderValue, packagingCharges, deliveryRadius, bankAccountNumber,
    bankName, latitude, longitude, cuisines, weeklyHoliday, estimatedPrepTimeMinutes,
    rating, reviewCount, fssaiExpiryDate, isTaxIncludedInPrice, invoicePrefix,
    autoAcceptOrders, prepBufferTimeMinutes, maxActiveOrdersLimit,
    allowScheduledOrders, allowSpecialInstructions, cancellationWindowMinutes,
  ];

  factory Seller.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>? ?? {};

    return Seller(
      id: doc.id,
      shopName: data['shopName'] as String? ?? data['restaurantName'] as String? ?? '',
      sellerName: data['sellerName'] as String? ?? data['ownerName'] as String? ?? data['name'] as String? ?? '',
      fullAddress: data['address'] as String? ?? data['fullAddress'] as String? ?? '',
      city: data['city'] as String? ?? '',
      state: data['state'] as String? ?? '',
      pincode: data['pincode'] as String? ?? '',
      contactNumber: data['contactNumber'] as String? ?? data['phoneNumber'] as String? ?? '',
      profileImageUrl: data['profileImageUrl'] as String? ?? data['logoUrl'] as String? ?? '',
      coverImageUrl: data['coverImageUrl'] as String? ?? '',
      name: data['name'] as String? ?? '',
      businessDetails: data['businessDetails'] as String? ?? data['restaurantDescription'] as String? ?? '',
      phoneNumber: data['phoneNumber'] as String? ?? data['contactNumber'] as String? ?? '',
      openingHours: data['openingHours'] as String? ?? data['openingTime'] as String? ?? '',
      closingTime: data['closingTime'] as String? ?? '',
      deliveryTime: data['deliveryTime'] as String? ?? '',
      deliveryArea: data['deliveryArea'] as String? ?? '',
      gstNumber: data['gstNumber'] as String? ?? '',
      fssaiNumber: data['fssaiNumber'] as String? ?? '',
      panNumber: data['panNumber'] as String? ?? '',
      isOnline: data['isOnline'] as bool? ?? false,
      isOpen: data['isOpen'] as bool? ?? true,
      isAcceptingOrders: data['isAcceptingOrders'] as bool? ?? true,
      gstPercentage: (data['gstPercentage'] as num?)?.toDouble() ?? 0.0,
      minimumOrderValue: (data['minimumOrderValue'] as num?)?.toDouble() ?? 0.0,
      packagingCharges: (data['packagingCharges'] as num?)?.toDouble() ?? 0.0,
      deliveryRadius: (data['deliveryRadius'] as num?)?.toDouble() ?? 10.0,
      bankAccountNumber: data['bankAccountNumber'] as String? ?? '',
      bankName: data['bankName'] as String? ?? '',
      latitude: _parseLatitude(data),
      longitude: _parseLongitude(data),
      cuisines: _parseCuisines(data),
      weeklyHoliday: _parseWeeklyHoliday(data),
      estimatedPrepTimeMinutes: (data['estimatedPrepTimeMinutes'] as num?)?.toInt() ??
          (data['prepTimeMinutes'] as num?)?.toInt() ?? 25,
      rating: (data['rating'] as num?)?.toDouble() ?? 0.0,
      reviewCount: (data['reviewCount'] as num?)?.toInt() ?? 0,
      fssaiExpiryDate: data['fssaiExpiryDate'] as String? ?? '',
      isTaxIncludedInPrice: data['isTaxIncludedInPrice'] as bool? ?? true,
      invoicePrefix: data['invoicePrefix'] as String? ?? 'INV-',
      autoAcceptOrders: data['autoAcceptOrders'] as bool? ?? false,
      prepBufferTimeMinutes: (data['prepBufferTimeMinutes'] as num?)?.toInt() ?? 15,
      maxActiveOrdersLimit: (data['maxActiveOrdersLimit'] as num?)?.toInt() ?? 20,
      allowScheduledOrders: data['allowScheduledOrders'] as bool? ?? true,
      allowSpecialInstructions: data['allowSpecialInstructions'] as bool? ?? true,
      cancellationWindowMinutes: (data['cancellationWindowMinutes'] as num?)?.toInt() ?? 2,
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
      'coverImageUrl': coverImageUrl,
      'name': name,
      'businessDetails': businessDetails,
      'phoneNumber': phoneNumber,
      'openingHours': openingHours,
      'closingTime': closingTime,
      'deliveryTime': deliveryTime,
      'deliveryArea': deliveryArea,
      'gstNumber': gstNumber,
      'fssaiNumber': fssaiNumber,
      'panNumber': panNumber,
      'isOnline': isOnline,
      'isOpen': isOpen,
      'isAcceptingOrders': isAcceptingOrders,
      'gstPercentage': gstPercentage,
      'minimumOrderValue': minimumOrderValue,
      'packagingCharges': packagingCharges,
      'deliveryRadius': deliveryRadius,
      'bankAccountNumber': bankAccountNumber,
      'bankName': bankName,
      'latitude': latitude,
      'longitude': longitude,
      'cuisines': cuisines,
      'weeklyHoliday': weeklyHoliday,
      'estimatedPrepTimeMinutes': estimatedPrepTimeMinutes,
      'rating': rating,
      'reviewCount': reviewCount,
      'fssaiExpiryDate': fssaiExpiryDate,
      'isTaxIncludedInPrice': isTaxIncludedInPrice,
      'invoicePrefix': invoicePrefix,
      'autoAcceptOrders': autoAcceptOrders,
      'prepBufferTimeMinutes': prepBufferTimeMinutes,
      'maxActiveOrdersLimit': maxActiveOrdersLimit,
      'allowScheduledOrders': allowScheduledOrders,
      'allowSpecialInstructions': allowSpecialInstructions,
      'cancellationWindowMinutes': cancellationWindowMinutes,
    };
  }

  static const empty = Seller(id: '');

  static double _parseLatitude(Map<String, dynamic> data) {
    final location = data['location'] ?? data['geoPoint'] ?? data['coordinates'];
    if (location is GeoPoint) return location.latitude;
    final lat = data['latitude'] ?? data['lat'];
    if (lat is num) return lat.toDouble();
    if (lat is String) return double.tryParse(lat) ?? 0.0;
    return 0.0;
  }

  static double _parseLongitude(Map<String, dynamic> data) {
    final location = data['location'] ?? data['geoPoint'] ?? data['coordinates'];
    if (location is GeoPoint) return location.longitude;
    final lng = data['longitude'] ?? data['lng'] ?? data['lon'];
    if (lng is num) return lng.toDouble();
    if (lng is String) return double.tryParse(lng) ?? 0.0;
    return 0.0;
  }

  static List<String> _parseCuisines(Map<String, dynamic> data) {
    final raw = data['cuisines'] ?? data['cuisine'];
    if (raw is List) {
      return raw.map((e) => e.toString().trim()).where((e) => e.isNotEmpty).toList();
    }
    if (raw is String && raw.isNotEmpty) {
      return raw.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
    }
    return const [];
  }

  static List<String> _parseWeeklyHoliday(Map<String, dynamic> data) {
    final raw = data['weeklyHoliday'];
    if (raw is List) {
      return raw.map((e) => e.toString().trim()).where((e) => e.isNotEmpty).toList();
    }
    if (raw is String && raw.isNotEmpty) {
      return raw.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
    }
    return const [];
  }
}
