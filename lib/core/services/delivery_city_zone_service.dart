import 'dart:math' as math;
import 'package:equatable/equatable.dart';

/// Operating hub / sub-zone details within a city.
class DeliveryZoneHubInfo extends Equatable {
  final String hubId;
  final String hubName;
  final String city;
  final String hubCode;
  final String description;
  final double latitude;
  final double longitude;
  final double coverageRadiusKm;
  final String surgeStatus; // 'High Demand', 'Normal', 'Popular Hub', '24/7 Active'
  final List<String> supportedShifts;

  const DeliveryZoneHubInfo({
    required this.hubId,
    required this.hubName,
    required this.city,
    required this.hubCode,
    required this.description,
    required this.latitude,
    required this.longitude,
    this.coverageRadiusKm = 6.0,
    this.surgeStatus = 'Normal',
    this.supportedShifts = const ['Morning', 'Evening', 'Night', 'Flexible'],
  });

  @override
  List<Object?> get props => [
        hubId,
        hubName,
        city,
        hubCode,
        description,
        latitude,
        longitude,
        coverageRadiusKm,
        surgeStatus,
        supportedShifts,
      ];

  Map<String, dynamic> toJson() => {
        'hubId': hubId,
        'hubName': hubName,
        'city': city,
        'hubCode': hubCode,
        'description': description,
        'latitude': latitude,
        'longitude': longitude,
        'coverageRadiusKm': coverageRadiusKm,
        'surgeStatus': surgeStatus,
        'supportedShifts': supportedShifts,
      };

  factory DeliveryZoneHubInfo.fromJson(Map<String, dynamic> json) {
    return DeliveryZoneHubInfo(
      hubId: json['hubId']?.toString() ?? '',
      hubName: json['hubName']?.toString() ?? '',
      city: json['city']?.toString() ?? '',
      hubCode: json['hubCode']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      latitude: (json['latitude'] as num?)?.toDouble() ?? 0.0,
      longitude: (json['longitude'] as num?)?.toDouble() ?? 0.0,
      coverageRadiusKm: (json['coverageRadiusKm'] as num?)?.toDouble() ?? 6.0,
      surgeStatus: json['surgeStatus']?.toString() ?? 'Normal',
      supportedShifts: (json['supportedShifts'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const ['Morning', 'Evening', 'Night', 'Flexible'],
    );
  }
}

/// Operational delivery city metadata and its associated zones.
class DeliveryCityInfo extends Equatable {
  final String cityName;
  final String state;
  final String tier; // 'Tier 1 Metro', 'Tier 2 City'
  final double latitude;
  final double longitude;
  final bool isPopular;
  final List<DeliveryZoneHubInfo> hubs;

  const DeliveryCityInfo({
    required this.cityName,
    required this.state,
    this.tier = 'Tier 1 Metro',
    required this.latitude,
    required this.longitude,
    this.isPopular = false,
    required this.hubs,
  });

  @override
  List<Object?> get props => [cityName, state, tier, latitude, longitude, isPopular, hubs];
}

/// Combined result when a rider selects a City and Operating Zone Hub.
class DeliveryCityZoneSelection extends Equatable {
  final String city;
  final String operatingZone;
  final String? hubCode;
  final String? hubDescription;
  final double? latitude;
  final double? longitude;

  const DeliveryCityZoneSelection({
    required this.city,
    required this.operatingZone,
    this.hubCode,
    this.hubDescription,
    this.latitude,
    this.longitude,
  });

  @override
  List<Object?> get props => [
        city,
        operatingZone,
        hubCode,
        hubDescription,
        latitude,
        longitude,
      ];
}

/// Comprehensive service managing delivery operational cities, hubs, and geospatial zone matching.
class DeliveryCityZoneService {
  DeliveryCityZoneService._();
  static final DeliveryCityZoneService instance = DeliveryCityZoneService._();

  static final List<DeliveryCityInfo> _citiesCatalog = [
    // 1. Chennai
    const DeliveryCityInfo(
      cityName: 'Chennai',
      state: 'Tamil Nadu',
      tier: 'Tier 1 Metro',
      latitude: 13.0827,
      longitude: 80.2707,
      isPopular: true,
      hubs: [
        DeliveryZoneHubInfo(
          hubId: 'chn_central',
          hubName: 'Central Zone',
          city: 'Chennai',
          hubCode: 'CHN-CTR-01',
          description: 'Egmore, Triplicane, Royapettah & Central Station Area',
          latitude: 13.0827,
          longitude: 80.2707,
          surgeStatus: '🔥 High Surge Zone',
        ),
        DeliveryZoneHubInfo(
          hubId: 'chn_annanagar',
          hubName: 'Anna Nagar Zone',
          city: 'Chennai',
          hubCode: 'CHN-ANN-02',
          description: 'Anna Nagar East/West, Shenoy Nagar, Kilpauk & Aminjikarai',
          latitude: 13.0850,
          longitude: 80.2101,
          surgeStatus: '🌟 Popular Hub',
        ),
        DeliveryZoneHubInfo(
          hubId: 'chn_tnagar',
          hubName: 'T. Nagar & Mylapore Hub',
          city: 'Chennai',
          hubCode: 'CHN-TNG-03',
          description: 'T. Nagar, Mylapore, Alwarpet, Nungambakkam & Pondy Bazaar',
          latitude: 13.0418,
          longitude: 80.2341,
          surgeStatus: '🔥 High Surge Zone',
        ),
        DeliveryZoneHubInfo(
          hubId: 'chn_adyar',
          hubName: 'Adyar & Besant Nagar Hub',
          city: 'Chennai',
          hubCode: 'CHN-ADY-04',
          description: 'Adyar, Besant Nagar, Thiruvanmiyur, Kotturpuram & ECR Start',
          latitude: 13.0012,
          longitude: 80.2565,
          surgeStatus: '⚡ Fast Payout Hub',
        ),
        DeliveryZoneHubInfo(
          hubId: 'chn_velachery',
          hubName: 'Velachery & Guindy Hub',
          city: 'Chennai',
          hubCode: 'CHN-VEL-05',
          description: 'Velachery, Guindy, Saidapet, Little Mount & Madipakkam',
          latitude: 12.9815,
          longitude: 80.2180,
          surgeStatus: '🌟 Popular Hub',
        ),
        DeliveryZoneHubInfo(
          hubId: 'chn_omr',
          hubName: 'OMR IT Corridor Hub',
          city: 'Chennai',
          hubCode: 'CHN-OMR-06',
          description: 'Perungudi, Thoraipakkam, Sholinganallur, Karapakkam & Navalur',
          latitude: 12.9165,
          longitude: 80.2285,
          surgeStatus: '🔥 High Surge Zone',
        ),
        DeliveryZoneHubInfo(
          hubId: 'chn_tambaram',
          hubName: 'Tambaram & Chromepet Hub',
          city: 'Chennai',
          hubCode: 'CHN-TBM-07',
          description: 'Tambaram, Chromepet, Pallavaram, Sanatorium & GST Road',
          latitude: 12.9249,
          longitude: 80.1000,
          surgeStatus: '⚡ Fast Payout Hub',
        ),
        DeliveryZoneHubInfo(
          hubId: 'chn_porur',
          hubName: 'Porur & Vadapalani Hub',
          city: 'Chennai',
          hubCode: 'CHN-POR-08',
          description: 'Porur, Vadapalani, Virugambakkam, Valasaravakkam & Ramapuram',
          latitude: 13.0382,
          longitude: 80.1565,
          surgeStatus: '🌟 Popular Hub',
        ),
        DeliveryZoneHubInfo(
          hubId: 'chn_north',
          hubName: 'North Chennai Hub',
          city: 'Chennai',
          hubCode: 'CHN-NRT-09',
          description: 'George Town, Royapuram, Perambur, Washermanpet & Tondiarpet',
          latitude: 13.1147,
          longitude: 80.2872,
          surgeStatus: 'Normal',
        ),
        DeliveryZoneHubInfo(
          hubId: 'chn_ambattur',
          hubName: 'Ambattur & Avadi Hub',
          city: 'Chennai',
          hubCode: 'CHN-AMB-10',
          description: 'Ambattur Estate, Mogappair, Avadi, Padi & Korattur',
          latitude: 13.1143,
          longitude: 80.1548,
          surgeStatus: 'Normal',
        ),
      ],
    ),

    // 2. Bengaluru / Bangalore
    const DeliveryCityInfo(
      cityName: 'Bengaluru',
      state: 'Karnataka',
      tier: 'Tier 1 Metro',
      latitude: 12.9716,
      longitude: 77.5946,
      isPopular: true,
      hubs: [
        DeliveryZoneHubInfo(
          hubId: 'blr_koramangala',
          hubName: 'Koramangala & HSR Hub',
          city: 'Bengaluru',
          hubCode: 'BLR-KRM-01',
          description: 'Koramangala Blocks 1-8, HSR Layout Sectors 1-7, BTM Layout',
          latitude: 12.9352,
          longitude: 77.6245,
          surgeStatus: '🔥 High Surge Zone',
        ),
        DeliveryZoneHubInfo(
          hubId: 'blr_indiranagar',
          hubName: 'Indiranagar & Domlur Hub',
          city: 'Bengaluru',
          hubCode: 'BLR-IND-02',
          description: '100ft Road, 12th Main, Domlur, HAL 2nd Stage & Old Airport Rd',
          latitude: 12.9784,
          longitude: 77.6408,
          surgeStatus: '🔥 High Surge Zone',
        ),
        DeliveryZoneHubInfo(
          hubId: 'blr_whitefield',
          hubName: 'Whitefield IT Hub',
          city: 'Bengaluru',
          hubCode: 'BLR-WTF-03',
          description: 'ITPL, Brookefield, Kundalahalli, Hope Farm & Kadugodi',
          latitude: 12.9698,
          longitude: 77.7500,
          surgeStatus: '⚡ Fast Payout Hub',
        ),
        DeliveryZoneHubInfo(
          hubId: 'blr_ecity',
          hubName: 'Electronic City Hub',
          city: 'Bengaluru',
          hubCode: 'BLR-ECT-04',
          description: 'Electronic City Phase 1 & 2, Bommasandra, Neeladri Road',
          latitude: 12.8452,
          longitude: 77.6602,
          surgeStatus: '⚡ Fast Payout Hub',
        ),
        DeliveryZoneHubInfo(
          hubId: 'blr_jayanagar',
          hubName: 'Jayanagar & JP Nagar Hub',
          city: 'Bengaluru',
          hubCode: 'BLR-JAY-05',
          description: 'Jayanagar 4th/9th Block, JP Nagar 1st-7th Phase, Banashankari',
          latitude: 12.9308,
          longitude: 77.5838,
          surgeStatus: '🌟 Popular Hub',
        ),
        DeliveryZoneHubInfo(
          hubId: 'blr_central',
          hubName: 'Central Bengaluru Hub',
          city: 'Bengaluru',
          hubCode: 'BLR-CTR-06',
          description: 'MG Road, Brigade Road, Shivajinagar, Richmond Town, Shanthi Nagar',
          latitude: 12.9716,
          longitude: 77.5946,
          surgeStatus: '🔥 High Surge Zone',
        ),
        DeliveryZoneHubInfo(
          hubId: 'blr_marathahalli',
          hubName: 'Marathahalli & Bellandur Hub',
          city: 'Bengaluru',
          hubCode: 'BLR-MRT-07',
          description: 'Outer Ring Road, Bellandur, Sarjapur Road, Kadubeesanahalli',
          latitude: 12.9591,
          longitude: 77.6974,
          surgeStatus: '🔥 High Surge Zone',
        ),
        DeliveryZoneHubInfo(
          hubId: 'blr_north',
          hubName: 'Hebbal & Manyata Tech Hub',
          city: 'Bengaluru',
          hubCode: 'BLR-HBL-08',
          description: 'Hebbal, Manyata Embassy Business Park, Nagavara, Sahakar Nagar',
          latitude: 13.0358,
          longitude: 77.5970,
          surgeStatus: '🌟 Popular Hub',
        ),
      ],
    ),

    // 3. Coimbatore
    const DeliveryCityInfo(
      cityName: 'Coimbatore',
      state: 'Tamil Nadu',
      tier: 'Tier 2 City',
      latitude: 11.0168,
      longitude: 76.9558,
      isPopular: true,
      hubs: [
        DeliveryZoneHubInfo(
          hubId: 'cbe_rspuram',
          hubName: 'RS Puram & Town Hall Hub',
          city: 'Coimbatore',
          hubCode: 'CBE-RSP-01',
          description: 'RS Puram, DB Road, TV Swamy Road, Town Hall & Gandhipark',
          latitude: 11.0088,
          longitude: 76.9500,
          surgeStatus: '🔥 High Surge Zone',
        ),
        DeliveryZoneHubInfo(
          hubId: 'cbe_gandhipuram',
          hubName: 'Gandhipuram & Cross Cut Hub',
          city: 'Coimbatore',
          hubCode: 'CBE-GND-02',
          description: 'Gandhipuram, Cross Cut Road, Ram Nagar, 100 Feet Road',
          latitude: 11.0183,
          longitude: 76.9644,
          surgeStatus: '🌟 Popular Hub',
        ),
        DeliveryZoneHubInfo(
          hubId: 'cbe_peelamedu',
          hubName: 'Peelamedu & Hopes Hub',
          city: 'Coimbatore',
          hubCode: 'CBE-PLM-03',
          description: 'Peelamedu, Hopes College, Avinashi Road, TIDEL Park & Airport',
          latitude: 11.0253,
          longitude: 77.0142,
          surgeStatus: '🔥 High Surge Zone',
        ),
        DeliveryZoneHubInfo(
          hubId: 'cbe_saravanampatti',
          hubName: 'Saravanampatti IT Hub',
          city: 'Coimbatore',
          hubCode: 'CBE-SRV-04',
          description: 'Saravanampatti, CHIL SEZ, Keeranatham & KGISL Tech Park',
          latitude: 11.0805,
          longitude: 76.9942,
          surgeStatus: '⚡ Fast Payout Hub',
        ),
        DeliveryZoneHubInfo(
          hubId: 'cbe_singanallur',
          hubName: 'Singanallur & Trichy Rd Hub',
          city: 'Coimbatore',
          hubCode: 'CBE-SNG-05',
          description: 'Singanallur, Ramanathapuram, Trichy Road, Ondipudur',
          latitude: 10.9992,
          longitude: 77.0250,
          surgeStatus: 'Normal',
        ),
        DeliveryZoneHubInfo(
          hubId: 'cbe_saibaba',
          hubName: 'Saibaba Colony Hub',
          city: 'Coimbatore',
          hubCode: 'CBE-SBC-06',
          description: 'Saibaba Colony, Thadagam Road, Koundampalayam, NSR Road',
          latitude: 11.0289,
          longitude: 76.9405,
          surgeStatus: '🌟 Popular Hub',
        ),
      ],
    ),

    // 4. Hyderabad
    const DeliveryCityInfo(
      cityName: 'Hyderabad',
      state: 'Telangana',
      tier: 'Tier 1 Metro',
      latitude: 17.3850,
      longitude: 78.4867,
      isPopular: true,
      hubs: [
        DeliveryZoneHubInfo(
          hubId: 'hyd_hitec',
          hubName: 'Hitec City & Madhapur Hub',
          city: 'Hyderabad',
          hubCode: 'HYD-HTC-01',
          description: 'Hitec City, Madhapur, Mindspace, Kondapur & Inorbit Mall',
          latitude: 17.4474,
          longitude: 78.3762,
          surgeStatus: '🔥 High Surge Zone',
        ),
        DeliveryZoneHubInfo(
          hubId: 'hyd_gachibowli',
          hubName: 'Gachibowli & Financial Hub',
          city: 'Hyderabad',
          hubCode: 'HYD-GCB-02',
          description: 'Gachibowli, Financial District, Nanakramguda, Waverock',
          latitude: 17.4401,
          longitude: 78.3489,
          surgeStatus: '🔥 High Surge Zone',
        ),
        DeliveryZoneHubInfo(
          hubId: 'hyd_banjara',
          hubName: 'Banjara Hills & Jubilee Hub',
          city: 'Hyderabad',
          hubCode: 'HYD-BNJ-03',
          description: 'Banjara Hills Rd 1-12, Jubilee Hills Rd 36/45, Somajiguda',
          latitude: 17.4156,
          longitude: 78.4350,
          surgeStatus: '🌟 Popular Hub',
        ),
        DeliveryZoneHubInfo(
          hubId: 'hyd_kukatpally',
          hubName: 'Kukatpally & KPHB Hub',
          city: 'Hyderabad',
          hubCode: 'HYD-KUK-04',
          description: 'KPHB Colony Phase 1-9, Forum Mall, Nizampet & JNTU',
          latitude: 17.4933,
          longitude: 78.3914,
          surgeStatus: '⚡ Fast Payout Hub',
        ),
        DeliveryZoneHubInfo(
          hubId: 'hyd_secunderabad',
          hubName: 'Secunderabad & Begumpet Hub',
          city: 'Hyderabad',
          hubCode: 'HYD-SEC-05',
          description: 'Secunderabad Station, Begumpet, Paradise, Sindhi Colony, Marredpally',
          latitude: 17.4399,
          longitude: 78.4983,
          surgeStatus: 'Normal',
        ),
      ],
    ),

    // 5. Mumbai
    const DeliveryCityInfo(
      cityName: 'Mumbai',
      state: 'Maharashtra',
      tier: 'Tier 1 Metro',
      latitude: 19.0760,
      longitude: 72.8777,
      isPopular: true,
      hubs: [
        DeliveryZoneHubInfo(
          hubId: 'mum_andheri',
          hubName: 'Andheri & Juhu Hub',
          city: 'Mumbai',
          hubCode: 'MUM-AND-01',
          description: 'Andheri West (Lokhandwala, Oshiwara), Andheri East (MIDC, SEEPZ), Juhu',
          latitude: 19.1197,
          longitude: 72.8464,
          surgeStatus: '🔥 High Surge Zone',
        ),
        DeliveryZoneHubInfo(
          hubId: 'mum_bandra',
          hubName: 'Bandra & BKC Hub',
          city: 'Mumbai',
          hubCode: 'MUM-BND-02',
          description: 'Bandra West (Linking Rd, Hill Rd, Pali Hill), BKC Commercial Hub',
          latitude: 19.0596,
          longitude: 72.8295,
          surgeStatus: '🔥 High Surge Zone',
        ),
        DeliveryZoneHubInfo(
          hubId: 'mum_south',
          hubName: 'South Mumbai Hub',
          city: 'Mumbai',
          hubCode: 'MUM-SOU-03',
          description: 'Lower Parel, Worli, Nariman Point, Colaba, Fort, Marine Drive',
          latitude: 18.9220,
          longitude: 72.8347,
          surgeStatus: '🌟 Popular Hub',
        ),
        DeliveryZoneHubInfo(
          hubId: 'mum_powai',
          hubName: 'Powai & Kanjurmarg Hub',
          city: 'Mumbai',
          hubCode: 'MUM-POW-04',
          description: 'Hiranandani Gardens, Chandivali, Saki Naka, Kanjurmarg West',
          latitude: 19.1176,
          longitude: 72.9060,
          surgeStatus: '⚡ Fast Payout Hub',
        ),
        DeliveryZoneHubInfo(
          hubId: 'mum_thane',
          hubName: 'Thane & Mulund Hub',
          city: 'Mumbai',
          hubCode: 'MUM-THN-05',
          description: 'Thane West (Viviana Mall, Ghodbunder Rd), Mulund West',
          latitude: 19.2183,
          longitude: 72.9781,
          surgeStatus: '🌟 Popular Hub',
        ),
        DeliveryZoneHubInfo(
          hubId: 'mum_navimumbai',
          hubName: 'Navi Mumbai / Vashi Hub',
          city: 'Mumbai',
          hubCode: 'MUM-NAV-06',
          description: 'Vashi, Nerul, Belapur, Seawoods Grand Central, Kharghar',
          latitude: 19.0771,
          longitude: 72.9986,
          surgeStatus: 'Normal',
        ),
      ],
    ),

    // 6. Delhi NCR
    const DeliveryCityInfo(
      cityName: 'Delhi NCR',
      state: 'Delhi / NCR',
      tier: 'Tier 1 Metro',
      latitude: 28.6139,
      longitude: 77.2090,
      isPopular: true,
      hubs: [
        DeliveryZoneHubInfo(
          hubId: 'del_central',
          hubName: 'Connaught Place & Central Hub',
          city: 'Delhi NCR',
          hubCode: 'DEL-CTR-01',
          description: 'Connaught Place, Barakhamba, Bengali Market, Karol Bagh',
          latitude: 28.6315,
          longitude: 77.2167,
          surgeStatus: '🔥 High Surge Zone',
        ),
        DeliveryZoneHubInfo(
          hubId: 'del_south',
          hubName: 'South Delhi & Hauz Khas Hub',
          city: 'Delhi NCR',
          hubCode: 'DEL-STH-02',
          description: 'Hauz Khas, Greater Kailash 1&2, Saket, Lajpat Nagar, Defence Colony',
          latitude: 28.5494,
          longitude: 77.2001,
          surgeStatus: '🔥 High Surge Zone',
        ),
        DeliveryZoneHubInfo(
          hubId: 'del_gurgaon',
          hubName: 'Gurgaon Cyber Hub & Golf Course',
          city: 'Delhi NCR',
          hubCode: 'DEL-GGN-03',
          description: 'Cyber City, DLF Phase 1-5, Sector 29, Golf Course Extension',
          latitude: 28.4595,
          longitude: 77.0266,
          surgeStatus: '🔥 High Surge Zone',
        ),
        DeliveryZoneHubInfo(
          hubId: 'del_noida',
          hubName: 'Noida Sector 18 & 62 Hub',
          city: 'Delhi NCR',
          hubCode: 'DEL-NOD-04',
          description: 'Sector 18 (Atta Market), Sector 62 (IT Hub), Sector 137 Expressway',
          latitude: 28.5708,
          longitude: 77.3271,
          surgeStatus: '⚡ Fast Payout Hub',
        ),
        DeliveryZoneHubInfo(
          hubId: 'del_dwarka',
          hubName: 'Dwarka & Airport Hub',
          city: 'Delhi NCR',
          hubCode: 'DEL-DWK-05',
          description: 'Dwarka Sector 6, 10, 12, 21, Aerocity, Mahipalpur',
          latitude: 28.5921,
          longitude: 77.0460,
          surgeStatus: 'Normal',
        ),
      ],
    ),

    // 7. Madurai
    const DeliveryCityInfo(
      cityName: 'Madurai',
      state: 'Tamil Nadu',
      tier: 'Tier 2 City',
      latitude: 9.9252,
      longitude: 78.1198,
      isPopular: true,
      hubs: [
        DeliveryZoneHubInfo(
          hubId: 'mdu_annanagar',
          hubName: 'Anna Nagar & KK Nagar Hub',
          city: 'Madurai',
          hubCode: 'MDU-ANN-01',
          description: 'Anna Nagar, KK Nagar, Mattuthavani Bus Stand, Mellur Rd',
          latitude: 9.9238,
          longitude: 78.1450,
          surgeStatus: '🔥 High Surge Zone',
        ),
        DeliveryZoneHubInfo(
          hubId: 'mdu_town',
          hubName: 'Meenakshi Amman / Town Hub',
          city: 'Madurai',
          hubCode: 'MDU-TWN-02',
          description: 'Town Hall, Simmakkal, South Masi Street, Periyar Bus Stand',
          latitude: 9.9195,
          longitude: 78.1193,
          surgeStatus: '🌟 Popular Hub',
        ),
        DeliveryZoneHubInfo(
          hubId: 'mdu_tallakulam',
          hubName: 'Tallakulam & Goripalayam Hub',
          city: 'Madurai',
          hubCode: 'MDU-TLK-03',
          description: 'Tallakulam, Goripalayam, Sellur, Alagar Kovil Road',
          latitude: 9.9360,
          longitude: 78.1320,
          surgeStatus: 'Normal',
        ),
        DeliveryZoneHubInfo(
          hubId: 'mdu_thirunagar',
          hubName: 'Thirunagar & Pasumalai Hub',
          city: 'Madurai',
          hubCode: 'MDU-TRN-04',
          description: 'Thirunagar, Pasumalai, Thiruparankundram, GST Road',
          latitude: 9.8780,
          longitude: 78.0770,
          surgeStatus: 'Normal',
        ),
      ],
    ),

    // 8. Tiruchirappalli (Trichy)
    const DeliveryCityInfo(
      cityName: 'Tiruchirappalli',
      state: 'Tamil Nadu',
      tier: 'Tier 2 City',
      latitude: 10.7905,
      longitude: 78.7047,
      isPopular: false,
      hubs: [
        DeliveryZoneHubInfo(
          hubId: 'try_thillai',
          hubName: 'Thillai Nagar & Cantonment Hub',
          city: 'Tiruchirappalli',
          hubCode: 'TRY-THL-01',
          description: 'Thillai Nagar East/West, Cantonment, Central Bus Stand, Shastri Road',
          latitude: 10.8250,
          longitude: 78.6850,
          surgeStatus: '🔥 High Surge Zone',
        ),
        DeliveryZoneHubInfo(
          hubId: 'try_srirangam',
          hubName: 'Srirangam & Chathiram Hub',
          city: 'Tiruchirappalli',
          hubCode: 'TRY-SRI-02',
          description: 'Srirangam Temple, Chathiram Bus Stand, Rockfort, Main Guard Gate',
          latitude: 10.8620,
          longitude: 78.6940,
          surgeStatus: '🌟 Popular Hub',
        ),
        DeliveryZoneHubInfo(
          hubId: 'try_kknagar',
          hubName: 'KK Nagar & Airport Hub',
          city: 'Tiruchirappalli',
          hubCode: 'TRY-KKN-03',
          description: 'KK Nagar, Sundar Nagar, Trichy Airport, Gundur',
          latitude: 10.7680,
          longitude: 78.7180,
          surgeStatus: 'Normal',
        ),
      ],
    ),

    // 9. Salem
    const DeliveryCityInfo(
      cityName: 'Salem',
      state: 'Tamil Nadu',
      tier: 'Tier 2 City',
      latitude: 11.6643,
      longitude: 78.1460,
      isPopular: false,
      hubs: [
        DeliveryZoneHubInfo(
          hubId: 'slm_fairlands',
          hubName: 'Fairlands & 5 Roads Hub',
          city: 'Salem',
          hubCode: 'SLM-FLN-01',
          description: 'Fairlands, New Bus Stand, 5 Roads, Brindavan Road, Meyyanur',
          latitude: 11.6750,
          longitude: 78.1380,
          surgeStatus: '🔥 High Surge Zone',
        ),
        DeliveryZoneHubInfo(
          hubId: 'slm_junction',
          hubName: 'Salem Junction & Suramangalam Hub',
          city: 'Salem',
          hubCode: 'SLM-JNC-02',
          description: 'Suramangalam, Salem Railway Junction, Leigh Bazaar',
          latitude: 11.6650,
          longitude: 78.1180,
          surgeStatus: '🌟 Popular Hub',
        ),
        DeliveryZoneHubInfo(
          hubId: 'slm_hasthampatti',
          hubName: 'Hasthampatti & Yercaud Road Hub',
          city: 'Salem',
          hubCode: 'SLM-HST-03',
          description: 'Hasthampatti, Gorimedu, Kumarasamipatti, Yercaud Foothills',
          latitude: 11.6880,
          longitude: 78.1650,
          surgeStatus: 'Normal',
        ),
      ],
    ),

    // 10. Pune
    const DeliveryCityInfo(
      cityName: 'Pune',
      state: 'Maharashtra',
      tier: 'Tier 1 Metro',
      latitude: 18.5204,
      longitude: 73.8567,
      isPopular: true,
      hubs: [
        DeliveryZoneHubInfo(
          hubId: 'pune_kp',
          hubName: 'Koregaon Park & Viman Nagar Hub',
          city: 'Pune',
          hubCode: 'PUN-KRG-01',
          description: 'Koregaon Park, Kalyani Nagar, Viman Nagar, Phoenix Market City',
          latitude: 18.5362,
          longitude: 73.8940,
          surgeStatus: '🔥 High Surge Zone',
        ),
        DeliveryZoneHubInfo(
          hubId: 'pune_hinjawadi',
          hubName: 'Hinjawadi IT Hub',
          city: 'Pune',
          hubCode: 'PUN-HIN-02',
          description: 'Hinjawadi Phase 1, 2, 3, Wakad, Baner, Balewadi High Street',
          latitude: 18.5913,
          longitude: 73.7389,
          surgeStatus: '🔥 High Surge Zone',
        ),
        DeliveryZoneHubInfo(
          hubId: 'pune_kothrud',
          hubName: 'Kothrud & Deccan Hub',
          city: 'Pune',
          hubCode: 'PUN-KOT-03',
          description: 'Kothrud, Karve Nagar, FC Road, JM Road, Deccan Gymkhana',
          latitude: 18.5074,
          longitude: 73.8077,
          surgeStatus: '🌟 Popular Hub',
        ),
      ],
    ),

    // 11. Kochi / Cochin
    const DeliveryCityInfo(
      cityName: 'Kochi',
      state: 'Kerala',
      tier: 'Tier 2 City',
      latitude: 9.9312,
      longitude: 76.2673,
      isPopular: true,
      hubs: [
        DeliveryZoneHubInfo(
          hubId: 'cok_mgroad',
          hubName: 'MG Road & Marine Drive Hub',
          city: 'Kochi',
          hubCode: 'COK-MGR-01',
          description: 'MG Road, Marine Drive, High Court, Panampilly Nagar, Ravipuram',
          latitude: 9.9674,
          longitude: 76.2800,
          surgeStatus: '🔥 High Surge Zone',
        ),
        DeliveryZoneHubInfo(
          hubId: 'cok_kakkanad',
          hubName: 'Kakkanad & InfoPark Hub',
          city: 'Kochi',
          hubCode: 'COK-KND-02',
          description: 'InfoPark Phase 1&2, SmartCity, Kakkanad Civil Station, Seaport-Airport Rd',
          latitude: 10.0159,
          longitude: 76.3419,
          surgeStatus: '🔥 High Surge Zone',
        ),
        DeliveryZoneHubInfo(
          hubId: 'cok_edappally',
          hubName: 'Edappally & Lulu Mall Hub',
          city: 'Kochi',
          hubCode: 'COK-EDP-03',
          description: 'Edappally Toll, Lulu International Mall, Palarivattom, Kalamassery',
          latitude: 10.0261,
          longitude: 76.3125,
          surgeStatus: '🌟 Popular Hub',
        ),
      ],
    ),

    // 12. Kolkata
    const DeliveryCityInfo(
      cityName: 'Kolkata',
      state: 'West Bengal',
      tier: 'Tier 1 Metro',
      latitude: 22.5726,
      longitude: 88.3639,
      isPopular: false,
      hubs: [
        DeliveryZoneHubInfo(
          hubId: 'ccu_saltlake',
          hubName: 'Salt Lake & Sector V IT Hub',
          city: 'Kolkata',
          hubCode: 'CCU-SLK-01',
          description: 'Sector V Tech Hub, Salt Lake City Blocks, New Town Action Area 1',
          latitude: 22.5786,
          longitude: 88.4312,
          surgeStatus: '🔥 High Surge Zone',
        ),
        DeliveryZoneHubInfo(
          hubId: 'ccu_parkstreet',
          hubName: 'Park Street & Central Hub',
          city: 'Kolkata',
          hubCode: 'CCU-PKS-02',
          description: 'Park Street, Camac Street, Esplanade, Dharmatala, Elgin Road',
          latitude: 22.5513,
          longitude: 88.3524,
          surgeStatus: '🌟 Popular Hub',
        ),
        DeliveryZoneHubInfo(
          hubId: 'ccu_south',
          hubName: 'South Kolkata Hub',
          city: 'Kolkata',
          hubCode: 'CCU-STH-03',
          description: 'Ballygunge, Gariahat, Jadavpur, Tollygunge, Dhakuria',
          latitude: 22.5186,
          longitude: 88.3643,
          surgeStatus: 'Normal',
        ),
      ],
    ),
  ];

  /// Returns all operational delivery cities.
  List<DeliveryCityInfo> getAllCities() {
    return List.unmodifiable(_citiesCatalog);
  }

  /// Returns popular metropolitan and high-demand cities.
  List<DeliveryCityInfo> getPopularCities() {
    return _citiesCatalog.where((c) => c.isPopular).toList();
  }

  /// Returns city names list for quick dropdowns.
  List<String> getCityNames() {
    return _citiesCatalog.map((c) => c.cityName).toList();
  }

  /// Finds a city object by its name (case-insensitive).
  DeliveryCityInfo? findCityByName(String cityName) {
    final query = cityName.trim().toLowerCase();
    if (query.isEmpty) return null;
    try {
      return _citiesCatalog.firstWhere(
        (c) =>
            c.cityName.toLowerCase() == query ||
            (query == 'bangalore' && c.cityName.toLowerCase() == 'bengaluru') ||
            (query == 'madras' && c.cityName.toLowerCase() == 'chennai'),
      );
    } catch (_) {
      return null;
    }
  }

  /// Returns the list of available operating zone/hub names for a given city.
  /// If the city is custom or unlisted, returns systematic regional fallback zones.
  List<String> getZoneNamesForCity(String cityName) {
    final city = findCityByName(cityName);
    if (city != null) {
      return city.hubs.map((h) => h.hubName).toList();
    }

    // Systematic dynamic fallback for custom cities
    final cleanCity = cityName.trim().isEmpty ? 'City' : cityName.trim();
    return [
      'Central Zone',
      'North $cleanCity Hub',
      'South $cleanCity Hub',
      'East $cleanCity Hub',
      'West $cleanCity Hub',
      'Express Delivery Hub',
    ];
  }

  /// Returns full hub objects for a given city.
  List<DeliveryZoneHubInfo> getHubsForCity(String cityName) {
    final city = findCityByName(cityName);
    if (city != null) {
      return city.hubs;
    }

    final cleanCity = cityName.trim().isEmpty ? 'City' : cityName.trim();
    return [
      DeliveryZoneHubInfo(
        hubId: 'custom_central',
        hubName: 'Central Zone',
        city: cleanCity,
        hubCode: '${cleanCity.toUpperCase().replaceAll(' ', '').padRight(3).substring(0, 3)}-CTR-01',
        description: 'Main City Centre & Commercial Hub',
        latitude: 13.0827,
        longitude: 80.2707,
        surgeStatus: '🔥 High Surge Zone',
      ),
      DeliveryZoneHubInfo(
        hubId: 'custom_north',
        hubName: 'North $cleanCity Hub',
        city: cleanCity,
        hubCode: '${cleanCity.toUpperCase().replaceAll(' ', '').padRight(3).substring(0, 3)}-NRT-02',
        description: 'North Zone & Residential Express Hub',
        latitude: 13.1100,
        longitude: 80.2500,
        surgeStatus: '🌟 Popular Hub',
      ),
      DeliveryZoneHubInfo(
        hubId: 'custom_south',
        hubName: 'South $cleanCity Hub',
        city: cleanCity,
        hubCode: '${cleanCity.toUpperCase().replaceAll(' ', '').padRight(3).substring(0, 3)}-STH-03',
        description: 'South Zone & Commercial Corridor',
        latitude: 13.0000,
        longitude: 80.2200,
        surgeStatus: '⚡ Fast Payout Hub',
      ),
    ];
  }

  /// Searches cities and zones matching a keyword query.
  List<DeliveryCityInfo> searchCities(String query) {
    final q = query.trim().toLowerCase();
    if (q.isEmpty) return getAllCities();

    return _citiesCatalog.where((c) {
      final nameMatches = c.cityName.toLowerCase().contains(q);
      final stateMatches = c.state.toLowerCase().contains(q);
      final hubMatches = c.hubs.any((h) =>
          h.hubName.toLowerCase().contains(q) ||
          h.description.toLowerCase().contains(q) ||
          h.hubCode.toLowerCase().contains(q));
      return nameMatches || stateMatches || hubMatches;
    }).toList();
  }

  /// Calculates geodesic distance between two points in km (Haversine formula).
  double calculateDistanceKm(
    double lat1,
    double lon1,
    double lat2,
    double lon2,
  ) {
    const p = 0.017453292519943295; // Math.PI / 180
    final a = 0.5 -
        math.cos((lat2 - lat1) * p) / 2 +
        math.cos(lat1 * p) *
            math.cos(lat2 * p) *
            (1 - math.cos((lon2 - lon1) * p)) /
            2;
    return 12742 * math.asin(math.sqrt(a)); // 2 * R * asin...
  }

  /// Finds the closest operational city given GPS coordinates.
  DeliveryCityInfo findNearestCity(double latitude, double longitude) {
    DeliveryCityInfo nearest = _citiesCatalog.first;
    double minDistance = double.infinity;

    for (final city in _citiesCatalog) {
      final d = calculateDistanceKm(latitude, longitude, city.latitude, city.longitude);
      if (d < minDistance) {
        minDistance = d;
        nearest = city;
      }
    }
    return nearest;
  }

  /// Finds the closest hub in a city given GPS coordinates.
  DeliveryZoneHubInfo findNearestHub(String cityName, double latitude, double longitude) {
    final hubs = getHubsForCity(cityName);
    if (hubs.isEmpty) {
      return const DeliveryZoneHubInfo(
        hubId: 'default',
        hubName: 'Central Zone',
        city: 'Chennai',
        hubCode: 'CHN-CTR-01',
        description: 'Central Operating Hub',
        latitude: 13.0827,
        longitude: 80.2707,
      );
    }

    DeliveryZoneHubInfo nearest = hubs.first;
    double minDistance = double.infinity;

    for (final hub in hubs) {
      final d = calculateDistanceKm(latitude, longitude, hub.latitude, hub.longitude);
      if (d < minDistance) {
        minDistance = d;
        nearest = hub;
      }
    }
    return nearest;
  }
}
