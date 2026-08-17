import 'package:cloud_firestore/cloud_firestore.dart';

class DeliveryFeeSettings {
  final double baseFee;
  final double perKmFee;
  final double freeDeliveryThreshold;
  final double surgeMultiplier;

  const DeliveryFeeSettings({
    this.baseFee = 20.0,
    this.perKmFee = 5.0,
    this.freeDeliveryThreshold = 500.0,
    this.surgeMultiplier = 1.0,
  });

  factory DeliveryFeeSettings.fromMap(Map<String, dynamic>? map) {
    if (map == null) return const DeliveryFeeSettings();
    return DeliveryFeeSettings(
      baseFee: (map['baseFee'] as num?)?.toDouble() ?? 20.0,
      perKmFee: (map['perKmFee'] as num?)?.toDouble() ?? 5.0,
      freeDeliveryThreshold:
          (map['freeDeliveryThreshold'] as num?)?.toDouble() ?? 500.0,
      surgeMultiplier: (map['surgeMultiplier'] as num?)?.toDouble() ?? 1.0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'baseFee': baseFee,
      'perKmFee': perKmFee,
      'freeDeliveryThreshold': freeDeliveryThreshold,
      'surgeMultiplier': surgeMultiplier,
    };
  }

  DeliveryFeeSettings copyWith({
    double? baseFee,
    double? perKmFee,
    double? freeDeliveryThreshold,
    double? surgeMultiplier,
  }) {
    return DeliveryFeeSettings(
      baseFee: baseFee ?? this.baseFee,
      perKmFee: perKmFee ?? this.perKmFee,
      freeDeliveryThreshold:
          freeDeliveryThreshold ?? this.freeDeliveryThreshold,
      surgeMultiplier: surgeMultiplier ?? this.surgeMultiplier,
    );
  }
}

class SellerModel {
  final String id;
  final String name;
  final String? ownerName;
  final String email;
  final String role;
  final String? phoneNumber;
  final String? shopName;
  final String? restaurantDescription;
  final String? businessDetails;
  final String authProvider;
  final bool isVerified;
  final String? verificationStatus;
  final DateTime createdAt;
  final String? profileImageUrl;
  final String? coverImageUrl;
  final String? address;
  final double? latitude;
  final double? longitude;
  final String? googleMapsUrl;
  final List<String> cuisines;
  final double? deliveryRadius;
  final DeliveryFeeSettings deliveryFeeSettings;
  final int? estimatedPrepTimeMinutes;
  final Map<String, dynamic>? businessHours;
  final String? openingHours;
  final String? closingTime;
  final List<String> weeklyHoliday;
  final bool isOpen;
  final bool isAcceptingOrders;
  final bool isActive;
  final String? deliveryTime;
  final String? deliveryArea;
  final String? gstNumber;
  final String? fssaiNumber;
  final String? panNumber;
  final bool isOnline;
  final double gstPercentage;
  final double minimumOrderValue;
  final double packagingCharges;
  final String? bankAccountNumber;
  final String? bankName;
  final String? ifscCode;
  final String? accountHolderName;
  final String? bankBranch;
  final bool notificationsEnabled;
  final String? taxConfiguration;

  SellerModel({
    required this.id,
    required this.name,
    this.ownerName,
    required this.email,
    this.role = 'seller',
    this.phoneNumber,
    this.shopName,
    this.restaurantDescription,
    this.businessDetails,
    this.authProvider = 'password',
    this.isVerified = false,
    this.verificationStatus,
    required this.createdAt,
    this.profileImageUrl,
    this.coverImageUrl,
    this.address,
    this.latitude,
    this.longitude,
    this.googleMapsUrl,
    this.cuisines = const [],
    this.deliveryRadius,
    this.deliveryFeeSettings = const DeliveryFeeSettings(),
    this.estimatedPrepTimeMinutes,
    this.businessHours,
    this.openingHours,
    this.closingTime,
    this.weeklyHoliday = const [],
    this.isOpen = true,
    this.isAcceptingOrders = true,
    this.isActive = true,
    this.deliveryTime,
    this.deliveryArea,
    this.gstNumber,
    this.fssaiNumber,
    this.panNumber,
    this.isOnline = false,
    this.gstPercentage = 18.0,
    this.minimumOrderValue = 150.0,
    this.packagingCharges = 25.0,
    this.bankAccountNumber,
    this.bankName,
    this.ifscCode,
    this.accountHolderName,
    this.bankBranch,
    this.notificationsEnabled = true,
    this.taxConfiguration,
  });

  factory SellerModel.fromFirestore(DocumentSnapshot snapshot) {
    final data = snapshot.data() as Map<String, dynamic>?;
    return SellerModel.fromMap(data ?? {}, id: snapshot.id);
  }

  factory SellerModel.fromMap(Map<String, dynamic> data, {String id = ''}) {
    List<String> parsedCuisines = [];
    if (data['cuisines'] is List) {
      parsedCuisines = (data['cuisines'] as List)
          .map((e) => e.toString().trim())
          .where((e) => e.isNotEmpty)
          .toList();
    } else if (data['cuisines'] is String && (data['cuisines'] as String).isNotEmpty) {
      parsedCuisines = (data['cuisines'] as String)
          .split(',')
          .map((e) => e.trim())
          .where((e) => e.isNotEmpty)
          .toList();
    }

    List<String> parsedWeeklyHolidays = [];
    if (data['weeklyHoliday'] is List) {
      parsedWeeklyHolidays = (data['weeklyHoliday'] as List)
          .map((e) => e.toString().trim())
          .where((e) => e.isNotEmpty)
          .toList();
    } else if (data['weeklyHoliday'] is String &&
        (data['weeklyHoliday'] as String).isNotEmpty) {
      parsedWeeklyHolidays = (data['weeklyHoliday'] as String)
          .split(',')
          .map((e) => e.trim())
          .where((e) => e.isNotEmpty)
          .toList();
    }

    double? parsedLat;
    double? parsedLng;
    final loc = data['location'] ?? data['geoPoint'] ?? data['coordinates'];
    if (loc is GeoPoint) {
      parsedLat = loc.latitude;
      parsedLng = loc.longitude;
    } else {
      if (data['latitude'] != null) {
        parsedLat = (data['latitude'] as num?)?.toDouble() ??
            double.tryParse(data['latitude'].toString());
      }
      if (data['longitude'] != null) {
        parsedLng = (data['longitude'] as num?)?.toDouble() ??
            double.tryParse(data['longitude'].toString());
      }
    }

    DateTime createdAt;
    if (data['createdAt'] is Timestamp) {
      createdAt = (data['createdAt'] as Timestamp).toDate();
    } else if (data['createdAt'] is String) {
      createdAt = DateTime.tryParse(data['createdAt'] as String) ?? DateTime.now();
    } else {
      createdAt = DateTime.now();
    }

    return SellerModel(
      id: id.isNotEmpty ? id : (data['id'] as String? ?? ''),
      name: data['name'] as String? ?? '',
      ownerName: data['ownerName'] as String? ?? data['name'] as String?,
      email: data['email'] as String? ?? '',
      role: data['role'] as String? ?? 'seller',
      phoneNumber: data['phoneNumber'] as String? ?? data['contactNumber'] as String?,
      shopName: data['shopName'] as String? ?? data['restaurantName'] as String?,
      restaurantDescription: data['restaurantDescription'] as String? ??
          data['description'] as String? ??
          data['businessDetails'] as String?,
      businessDetails: data['businessDetails'] as String?,
      authProvider: data['authProvider'] as String? ?? 'password',
      isVerified: data['isVerified'] as bool? ?? false,
      verificationStatus: data['verificationStatus'] as String? ??
          (data['isVerified'] == true ? 'verified' : 'pending'),
      createdAt: createdAt,
      profileImageUrl: data['profileImageUrl'] as String? ?? data['logoUrl'] as String?,
      coverImageUrl: data['coverImageUrl'] as String?,
      address: data['address'] as String? ?? data['fullAddress'] as String? ?? data['businessDetails'] as String?,
      latitude: parsedLat,
      longitude: parsedLng,
      googleMapsUrl: data['googleMapsUrl'] as String?,
      cuisines: parsedCuisines,
      deliveryRadius: (data['deliveryRadius'] as num?)?.toDouble(),
      deliveryFeeSettings: data['deliveryFeeSettings'] is Map<String, dynamic>
          ? DeliveryFeeSettings.fromMap(data['deliveryFeeSettings'] as Map<String, dynamic>)
          : const DeliveryFeeSettings(),
      estimatedPrepTimeMinutes: (data['estimatedPrepTimeMinutes'] as num?)?.toInt() ??
          (data['prepTimeMinutes'] as num?)?.toInt(),
      businessHours: data['businessHours'] as Map<String, dynamic>?,
      openingHours: data['openingHours'] as String? ?? data['openingTime'] as String?,
      closingTime: data['closingTime'] as String?,
      weeklyHoliday: parsedWeeklyHolidays,
      isOpen: data['isOpen'] as bool? ?? true,
      isAcceptingOrders: data['isAcceptingOrders'] as bool? ?? true,
      isActive: data['isActive'] as bool? ?? true,
      deliveryTime: data['deliveryTime'] as String?,
      deliveryArea: data['deliveryArea'] as String?,
      gstNumber: data['gstNumber'] as String?,
      fssaiNumber: data['fssaiNumber'] as String?,
      panNumber: data['panNumber'] as String?,
      isOnline: data['isOnline'] as bool? ?? false,
      gstPercentage: (data['gstPercentage'] as num?)?.toDouble() ?? 18.0,
      minimumOrderValue: (data['minimumOrderValue'] as num?)?.toDouble() ??
          (data['minimumOrderAmount'] as num?)?.toDouble() ??
          150.0,
      packagingCharges: (data['packagingCharges'] as num?)?.toDouble() ?? 25.0,
      bankAccountNumber: data['bankAccountNumber'] as String?,
      bankName: data['bankName'] as String?,
      ifscCode: data['ifscCode'] as String?,
      accountHolderName: data['accountHolderName'] as String?,
      bankBranch: data['bankBranch'] as String?,
      notificationsEnabled: data['notificationsEnabled'] as bool? ?? true,
      taxConfiguration: data['taxConfiguration'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'ownerName': ownerName ?? name,
      'email': email,
      'role': role,
      'phoneNumber': phoneNumber,
      'shopName': shopName,
      'restaurantDescription': restaurantDescription,
      'businessDetails': businessDetails ?? restaurantDescription,
      'authProvider': authProvider,
      'isVerified': isVerified,
      'verificationStatus': verificationStatus ?? (isVerified ? 'verified' : 'pending'),
      'createdAt': Timestamp.fromDate(createdAt),
      'profileImageUrl': profileImageUrl,
      'coverImageUrl': coverImageUrl,
      'address': address,
      'latitude': latitude,
      'longitude': longitude,
      'googleMapsUrl': googleMapsUrl,
      'cuisines': cuisines,
      'deliveryRadius': deliveryRadius,
      'deliveryFeeSettings': deliveryFeeSettings.toMap(),
      'estimatedPrepTimeMinutes': estimatedPrepTimeMinutes,
      'businessHours': businessHours,
      'openingHours': openingHours,
      'closingTime': closingTime,
      'weeklyHoliday': weeklyHoliday,
      'isOpen': isOpen,
      'isAcceptingOrders': isAcceptingOrders,
      'isActive': isActive,
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
      'ifscCode': ifscCode,
      'accountHolderName': accountHolderName,
      'bankBranch': bankBranch,
      'notificationsEnabled': notificationsEnabled,
      'taxConfiguration': taxConfiguration,
    };
  }

  SellerModel copyWith({
    String? id,
    String? name,
    String? ownerName,
    String? email,
    String? role,
    String? phoneNumber,
    String? shopName,
    String? restaurantDescription,
    String? businessDetails,
    String? authProvider,
    bool? isVerified,
    String? verificationStatus,
    DateTime? createdAt,
    String? profileImageUrl,
    String? coverImageUrl,
    String? address,
    double? latitude,
    double? longitude,
    String? googleMapsUrl,
    List<String>? cuisines,
    double? deliveryRadius,
    DeliveryFeeSettings? deliveryFeeSettings,
    int? estimatedPrepTimeMinutes,
    Map<String, dynamic>? businessHours,
    String? openingHours,
    String? closingTime,
    List<String>? weeklyHoliday,
    bool? isOpen,
    bool? isAcceptingOrders,
    bool? isActive,
    String? deliveryTime,
    String? deliveryArea,
    String? gstNumber,
    String? fssaiNumber,
    String? panNumber,
    bool? isOnline,
    double? gstPercentage,
    double? minimumOrderValue,
    double? packagingCharges,
    String? bankAccountNumber,
    String? bankName,
    String? ifscCode,
    String? accountHolderName,
    String? bankBranch,
    bool? notificationsEnabled,
    String? taxConfiguration,
  }) {
    return SellerModel(
      id: id ?? this.id,
      name: name ?? this.name,
      ownerName: ownerName ?? this.ownerName,
      email: email ?? this.email,
      role: role ?? this.role,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      shopName: shopName ?? this.shopName,
      restaurantDescription:
          restaurantDescription ?? this.restaurantDescription,
      businessDetails: businessDetails ?? this.businessDetails,
      authProvider: authProvider ?? this.authProvider,
      isVerified: isVerified ?? this.isVerified,
      verificationStatus: verificationStatus ?? this.verificationStatus,
      createdAt: createdAt ?? this.createdAt,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      coverImageUrl: coverImageUrl ?? this.coverImageUrl,
      address: address ?? this.address,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      googleMapsUrl: googleMapsUrl ?? this.googleMapsUrl,
      cuisines: cuisines ?? this.cuisines,
      deliveryRadius: deliveryRadius ?? this.deliveryRadius,
      deliveryFeeSettings: deliveryFeeSettings ?? this.deliveryFeeSettings,
      estimatedPrepTimeMinutes:
          estimatedPrepTimeMinutes ?? this.estimatedPrepTimeMinutes,
      businessHours: businessHours ?? this.businessHours,
      openingHours: openingHours ?? this.openingHours,
      closingTime: closingTime ?? this.closingTime,
      weeklyHoliday: weeklyHoliday ?? this.weeklyHoliday,
      isOpen: isOpen ?? this.isOpen,
      isAcceptingOrders: isAcceptingOrders ?? this.isAcceptingOrders,
      isActive: isActive ?? this.isActive,
      deliveryTime: deliveryTime ?? this.deliveryTime,
      deliveryArea: deliveryArea ?? this.deliveryArea,
      gstNumber: gstNumber ?? this.gstNumber,
      fssaiNumber: fssaiNumber ?? this.fssaiNumber,
      panNumber: panNumber ?? this.panNumber,
      isOnline: isOnline ?? this.isOnline,
      gstPercentage: gstPercentage ?? this.gstPercentage,
      minimumOrderValue: minimumOrderValue ?? this.minimumOrderValue,
      packagingCharges: packagingCharges ?? this.packagingCharges,
      bankAccountNumber: bankAccountNumber ?? this.bankAccountNumber,
      bankName: bankName ?? this.bankName,
      ifscCode: ifscCode ?? this.ifscCode,
      accountHolderName: accountHolderName ?? this.accountHolderName,
      bankBranch: bankBranch ?? this.bankBranch,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      taxConfiguration: taxConfiguration ?? this.taxConfiguration,
    );
  }
}
