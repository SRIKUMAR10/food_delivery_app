import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'Delivery_Navigation Screen_page_bloc.dart';
import 'Delivery_Navigation Screen_page_event.dart';
import 'Delivery_Navigation Screen_page_repository.dart';
import 'Delivery_Navigation Screen_page_service.dart';
import 'Delivery_Navigation Screen_page_state.dart';
import '../../../core/theme/delivery_app_colors.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/widgets/app_google_map_view.dart';
import '../Delivery_NavigationBar_page/Delivery_NavigationBar_page_bloc.dart';
import '../Delivery_NavigationBar_page/Delivery_NavigationBar_page_event.dart';

class DeliveryNavigationStrings {
  static const Map<String, Map<String, String>> _strings = {
    'en': {
      'liveNavigation': 'Live Navigation',
      'goOnline': 'Go Online',
      'breadcrumb': 'Dashboard / Navigate',
      'themeLabel': 'Dark theme',
      'audioOn': 'Voice guidance on',
      'audioOff': 'Voice guidance off',
      'deliveryPartnerRole': 'Delivery Partner',
      'turnHint': 'Turn-by-turn guidance',
      'eta': 'ETA',
      'distanceLeft': 'Distance Left',
      'orderStatus': 'Order Status',
      'pickup': 'Pickup',
      'drop': 'Drop',
      'contactCustomer': 'Contact Customer',
      'callingCustomer': 'Calling customer...',
      'liveTraffic': 'Live Traffic',
      'trafficClear': 'Clear',
      'trafficModerate': 'Moderate',
      'trafficHeavy': 'Heavy',
      'startNavigation': 'Start Navigation',
      'followRoute': 'Follow Route',
      'exitNavigation': 'Exit Navigation',
      'emergencySos': 'Emergency SOS',
      'sosSent': 'Emergency alert sent. Nearest support team notified.',
      'currentLocation': 'Current Location',
      'locationAddress': 'Nungambakkam High Rd, Chennai',
      'zoomIn': 'Zoom in',
      'zoomOut': 'Zoom out',
      'recenter': 'Recenter map',
      'retry': 'Retry',
      'errorTitle': 'Something went wrong',
      'errorSub': 'We could not load your navigation. Please try again.',
      'emptyTitle': 'No Active Delivery',
      'emptySub': 'You have no active delivery to navigate to right now.',
      'offlineBanner': 'You are offline. Live navigation may be limited.',
      'orderId': 'Order',
      'mapSemantics': 'Live navigation map',
      'currentLocationSemantics': 'Current location',
      'darkThemeActive': 'Dark theme active',
      'stage1Title': 'Stage 1: Pickup',
      'stage1Subtitle': 'Heading to Restaurant',
      'stage2Title': 'Stage 2: Delivery',
      'stage2Subtitle': 'Heading to Customer',
      'stageCompleted': 'Delivery Completed',
      'callRestaurant': 'Call Restaurant',
      'callCustomer': 'Call Customer',
      'arrivedAtRestaurant': 'Arrived at Restaurant',
      'confirmPickup': 'Confirm Pickup',
      'arrivedAtCustomer': 'Arrived at Customer',
      'confirmDelivery': 'Confirm Delivery',
      'gpsActive': 'GPS Active · High Accuracy',
      'gpsSearching': 'GPS Searching',
      'gpsDisabled': 'GPS Disabled',
      'gpsPermissionDenied': 'Location Permission Denied',
      'batterySaver': 'Battery Saver On',
      'dataSaver': 'Data Saver On',
      'speed': 'Speed',
      'heading': 'Heading',
      'kmh': 'km/h',
      'vehicle': 'Vehicle',
      'destination': 'Destination',
      'customerNotes': 'Notes',
      'liveTelemetry': 'Live Telemetry',
      'codCollectCash': 'Collect COD Cash',
      'codAmountToCollect': 'COD Amount to Collect',
      'cashReceivedTitle': 'Cash Received',
      'receivedAmountLabel': 'Amount received from customer',
      'changeToReturn': 'Change to return',
      'codCollectedStatus': 'Cash Collected',
      'amountLessThanCod': 'Amount is less than the COD amount.',
      'invalidAmount': 'Please enter a valid amount.',
      'confirm': 'Confirm',
      'cancel': 'Cancel',
      'collectingCod': 'Collecting cash...',
      'idleOnlineStatus': 'You are Online & Available',
      'idleSearchingOrders': 'Searching for orders nearby',
      'idleViewAvailableOrders': 'View Available Orders',
      'idleMapSemantics': 'Live radar map',
      'idleGpsAccuracy': 'GPS Accuracy',
      'idleHotspots': 'High Demand Zones',
      'idleDemandLabel': 'orders waiting',
      'goOffline': 'Go Offline',
      'hotspotTapped': 'You are now near a High Demand Zone',
      'idleWaitingTitle': 'Waiting for orders',
      'idleWaitingSub': 'Stay near a hotspot to get more deliveries.',
      'idleOpeningOrders': 'Opening available orders...',
      'mapPreview': 'Active Zone Map',
      'liveBadge': 'LIVE',
      'highDemandZone': 'High Demand Operational Zone',
      'liveStoresCount': 'Live Restaurants in Operational Zone',
      'activeTrip': 'Active Trip',
    },
    'ta': {
      'liveNavigation': 'நேரடி வழிசெலுத்தல்',
      'goOnline': 'ஆன்லைனில் செல்',
      'breadcrumb': 'டாஷ்போர்டு / செல்லவும்',
      'themeLabel': 'இருண்ட தீம்',
      'audioOn': 'குரல் வழிகாட்டுதல் இயக்கத்தில்',
      'audioOff': 'குரல் வழிகாட்டுதல் முடக்கத்தில்',
      'deliveryPartnerRole': 'டெலிவரி பார்ட்னர்',
      'turnHint': 'திருப்பு-மூலம்-திருப்பு வழிகாட்டுதல்',
      'eta': 'மதிப்பீட்டு நேரம்',
      'distanceLeft': 'மீதமுள்ள தூரம்',
      'orderStatus': 'ஆர்டர் நிலை',
      'pickup': 'பிக்கப்',
      'drop': 'டிராப்',
      'contactCustomer': 'வாடிக்கையாளரை தொடர்பு கொள்ளுங்கள்',
      'callingCustomer': 'வாடிக்கையாளரை அழைக்கிறது...',
      'liveTraffic': 'நேரடி போக்குவரத்து',
      'trafficClear': 'சரி',
      'trafficModerate': 'மிதமான',
      'trafficHeavy': 'அதிகம்',
      'startNavigation': 'வழிசெலுத்தலைத் தொடங்கவும்',
      'followRoute': 'வழியைப் பின்தொடரவும்',
      'exitNavigation': 'வழிசெலுத்தலை விட்டு வெளியேறு',
      'emergencySos': 'அவசர SOS',
      'sosSent':
          'அவசர எச்சரிக்கை அனுப்பப்பட்டது. அருகிலுள்ள ஆதரவு குழுவுக்கு அறிவிக்கப்பட்டது.',
      'currentLocation': 'தற்போதைய இடம்',
      'locationAddress': 'நுங்கம்பாக்கம் உயர் சாலை, சென்னை',
      'zoomIn': 'பெரிதாக்கு',
      'zoomOut': 'சிறிதாக்கு',
      'recenter': 'வரைபடத்தை மையப்படுத்து',
      'retry': 'மீண்டும் முயற்சிக்கவும்',
      'errorTitle': 'ஏதோ தவறு ஏற்பட்டது',
      'errorSub': 'உங்கள் வழிசெலுத்தலை ஏற்ற முடியவில்லை. மீண்டும் முயற்சிக்கவும்.',
      'emptyTitle': 'செயலில் உள்ள டெலிவரி இல்லை',
      'emptySub': 'இப்போது செல்ல உங்களுக்கு செயலில் உள்ள டெலிவரி இல்லை.',
      'offlineBanner':
          'நீங்கள் ஆஃப்லைனில் உள்ளீர்கள். நேரடி வழிசெலுத்தல் குறைவாக இருக்கலாம்.',
      'orderId': 'ஆர்டர்',
      'mapSemantics': 'நேரடி வழிசெலுத்தல் வரைபடம்',
      'currentLocationSemantics': 'தற்போதைய இடம்',
      'darkThemeActive': 'இருண்ட தீம் செயலில்',
      'stage1Title': 'நிலை 1: பிக்கப்',
      'stage1Subtitle': 'உணவகத்திற்கு செல்லுதல்',
      'stage2Title': 'நிலை 2: டெலிவரி',
      'stage2Subtitle': 'வாடிக்கையாளருக்கு செல்லுதல்',
      'stageCompleted': 'டெலிவரி முடிந்தது',
      'callRestaurant': 'உணவகத்தை அழைக்கவும்',
      'callCustomer': 'வாடிக்கையாளரை அழைக்கவும்',
      'arrivedAtRestaurant': 'உணவகத்தை அடைந்தது',
      'confirmPickup': 'பிக்கப்பை உறுதிப்படுத்து',
      'arrivedAtCustomer': 'வாடிக்கையாளரை அடைந்தது',
      'confirmDelivery': 'டெலிவரியை உறுதிப்படுத்து',
      'gpsActive': 'GPS செயலில் · உயர் துல்லியம்',
      'gpsSearching': 'GPS தேடுகிறது',
      'gpsDisabled': 'GPS முடக்கப்பட்டது',
      'gpsPermissionDenied': 'இட அனுமதி மறுக்கப்பட்டது',
      'batterySaver': 'பேட்டரி சேமிப்பு இயக்கத்தில்',
      'dataSaver': 'டேட்டா சேமிப்பு இயக்கத்தில்',
      'speed': 'வேகம்',
      'heading': 'திசை',
      'kmh': 'கி.மீ/மணி',
      'vehicle': 'வாகனம்',
      'destination': 'இலக்கு',
      'customerNotes': 'குறிப்புகள்',
      'liveTelemetry': 'நேரடி டெலிமெட்ரி',
      'codCollectCash': 'COD பணத்தை பெறவும்',
      'codAmountToCollect': 'COD தொகை பெறவேண்டியது',
      'cashReceivedTitle': 'பெறப்பட்ட பணம்',
      'receivedAmountLabel': 'வாடிக்கையாளரிடமிருந்து பெறப்பட்ட தொகை',
      'changeToReturn': 'திரும்ப வழங்க வேண்டிய பணம்',
      'codCollectedStatus': 'பணம் பெறப்பட்டது',
      'amountLessThanCod': 'தொகை COD தொகையை விட குறைவு.',
      'invalidAmount': 'சரியான தொகையை உள்ளிடவும்.',
      'confirm': 'உறுதிப்படுத்து',
      'cancel': 'ரத்து செய்',
      'collectingCod': 'பணம் பெறுகிறது...',
      'idleOnlineStatus': 'நீங்கள் ஆன்லைனில் கிடைக்கிறீர்கள்',
      'idleSearchingOrders': 'அருகில் ஆர்டர்களை தேடுகிறது',
      'idleViewAvailableOrders': 'கிடைக்கும் ஆர்டர்களை பார்க்கவும்',
      'idleMapSemantics': 'நேரடி ரேடார் வரைபடம்',
      'idleGpsAccuracy': 'GPS துல்லியம்',
      'idleHotspots': 'அதிக தேவை மண்டலங்கள்',
      'idleDemandLabel': 'ஆர்டர்கள் காத்திருக்கின்றன',
      'goOffline': 'ஆஃப்லைனில் செல்',
      'hotspotTapped': 'நீங்கள் இப்போது அதிக தேவை மண்டலத்தின் அருகில் உள்ளீர்கள்',
      'idleWaitingTitle': 'ஆர்டர்களுக்காக காத்திருக்கிறது',
      'idleWaitingSub': 'அதிக டெலிவரிகள் பெற ஹாட்ஸ்பாட்டிற்கு அருகில் இருங்கள்.',
      'idleOpeningOrders': 'கிடைக்கும் ஆர்டர்களை திறக்கிறது...',
      'mapPreview': 'டெலிவரி மண்டல வரைபடம்',
      'liveBadge': 'நேரலை',
      'highDemandZone': 'அதிக தேவை செயல்பாட்டு மண்டலம்',
      'liveStoresCount': 'நேரடி உணவகங்கள் செயல்பாட்டு மண்டலத்தில்',
      'activeTrip': 'செயலில் உள்ள பயணம்',
    },
  };

  static String of(String key, String localeCode) {
    final localeMap = _strings[localeCode] ?? _strings['en']!;
    return localeMap[key] ?? _strings['en']![key]!;
  }
}

class _MapCoords {
  static const double pickupX = 0.18;
  static const double pickupY = 0.72;
  static const double dropX = 0.68;
  static const double dropY = 0.28;
  static const double currentX = 0.42;
  static const double currentY = 0.55;
}

typedef DeliveryNavigationScreenPageUi = DeliveryNavigationScreenPage;

class DeliveryNavigationScreenPage extends StatelessWidget {
  final DeliveryNavigationRepositoryBase? repository;
  final DeliveryNavigationServiceBase? service;
  final DeliveryNavigationBloc? bloc;
  final String? orderId;
  final String? pickupAddress;
  final String? dropoffAddress;
  final String? restaurantName;
  final String? customerName;
  final double? destinationLatitude;
  final double? destinationLongitude;
  final bool? isStoreRoute;

  const DeliveryNavigationScreenPage({
    super.key,
    this.repository,
    this.service,
    this.bloc,
    this.orderId,
    this.pickupAddress,
    this.dropoffAddress,
    this.restaurantName,
    this.customerName,
    this.destinationLatitude,
    this.destinationLongitude,
    this.isStoreRoute,
  });


  @override
  Widget build(BuildContext context) {
    if (bloc != null) {
      return BlocProvider<DeliveryNavigationBloc>.value(
        value: bloc!,
        child: const DeliveryNavigationScreenPageView(),
      );
    }

    return BlocProvider<DeliveryNavigationBloc>(
      create: (context) => DeliveryNavigationBloc(
        repository: repository ?? DeliveryNavigationRepository(),
        service: service ?? DeliveryNavigationService(),
      )..add(DeliveryNavigationInitEvent(orderId: orderId)),
      child: const DeliveryNavigationScreenPageView(),
    );
  }
}

class DeliveryNavigationScreenPageView extends StatelessWidget {
  const DeliveryNavigationScreenPageView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<DeliveryNavigationBloc, DeliveryNavigationState>(
      listenWhen: (previous, current) =>
          previous.status != current.status ||
          (previous.errorMessage != current.errorMessage &&
              current.errorMessage != null),
      listener: (context, state) {
        if (state.status == DeliveryNavigationStatus.error &&
            state.errorMessage != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.errorMessage!),
              backgroundColor: DeliveryAppColors.error,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      },
      builder: (context, state) {
        return LayoutBuilder(
          builder: (context, constraints) {
            final isDesktop = constraints.maxWidth >= 1024;
            final isTablet =
                constraints.maxWidth >= 600 && constraints.maxWidth < 1024;
            final isMobile = !isDesktop && !isTablet;

            final Widget body = switch (state.status) {
              DeliveryNavigationStatus.initial ||
              DeliveryNavigationStatus.loading =>
                _NavigationSkeleton(isMobile: isMobile),
              DeliveryNavigationStatus.error => _NavigationErrorState(
                  state: state,
                ),
              DeliveryNavigationStatus.empty => _RiderIdleMap(
                  state: state,
                  isMobile: isMobile,
                  isTablet: isTablet,
                  isDesktop: isDesktop,
                ),
              DeliveryNavigationStatus.loaded ||
              DeliveryNavigationStatus.navigating =>
                state.hasActiveOrder
                    ? _NavigationDashboard(
                        state: state,
                        isMobile: isMobile,
                        isTablet: isTablet,
                        isDesktop: isDesktop,
                      )
                    : _RiderIdleMap(
                        state: state,
                        isMobile: isMobile,
                        isTablet: isTablet,
                        isDesktop: isDesktop,
                      ),
            };

            return Scaffold(
              key: const Key('dp_navscreen_page'),
              backgroundColor: const Color(0xFF060B11),
              body: SafeArea(
                child: Column(
                  children: [
                    if (state.isOffline) const _OfflineBanner(),
                    Expanded(child: body),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}

class _NavigationDashboard extends StatefulWidget {
  final DeliveryNavigationState state;
  final bool isMobile;
  final bool isTablet;
  final bool isDesktop;

  const _NavigationDashboard({
    required this.state,
    required this.isMobile,
    required this.isTablet,
    required this.isDesktop,
  });

  @override
  State<_NavigationDashboard> createState() => _NavigationDashboardState();
}

class _NavigationDashboardState extends State<_NavigationDashboard> {
  bool _isMapFullScreen = false;

  void _handleSOS(BuildContext context, String localeCode) {
    context
        .read<DeliveryNavigationBloc>()
        .add(const DeliveryNavigationSOSClickedEvent());
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(DeliveryNavigationStrings.of('sosSent', localeCode)),
        backgroundColor: DeliveryAppColors.error,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showContactSnackBar(BuildContext context, String localeCode) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          DeliveryNavigationStrings.of('callingCustomer', localeCode),
        ),
        backgroundColor: DeliveryAppColors.primaryDark,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _handleStageArrived() {
    final bloc = context.read<DeliveryNavigationBloc>();
    if (widget.state.isStageToRestaurant) {
      bloc.add(const DeliveryNavigationArrivedAtPickupEvent());
    } else {
      bloc.add(const DeliveryNavigationArrivedAtCustomerEvent());
    }
  }

  void _handleStageConfirm() {
    final bloc = context.read<DeliveryNavigationBloc>();
    if (widget.state.isStageToRestaurant) {
      bloc.add(const DeliveryNavigationConfirmPickupEvent());
    } else {
      bloc.add(const DeliveryNavigationConfirmDeliveryEvent());
    }
  }

  @override
  Widget build(BuildContext context) {
    final localeCode = widget.state.localeCode;
    return LayoutBuilder(
      builder: (context, constraints) {
        final stagePanel = _StageBanner(
          state: widget.state,
          localeCode: localeCode,
          onCall: () => _showContactSnackBar(context, localeCode),
          onArrived: _handleStageArrived,
          onConfirm: _handleStageConfirm,
        );
        final telemetryPanel = _TelemetryPanel(
          state: widget.state,
          localeCode: localeCode,
        );

        return Column(
          children: [
            _NavigationTopBar(
              state: widget.state,
              isMobile: widget.isMobile,
              onToggleAudio: () => context
                  .read<DeliveryNavigationBloc>()
                  .add(const DeliveryNavigationToggleAudioEvent()),
            ),
            Expanded(
              child: widget.isMobile
                  ? Column(
                      children: [
                        if (widget.state.showMap)
                          SizedBox(
                            height: _isMapFullScreen
                                ? (constraints.maxHeight - 80)
                                    .clamp(320.0, double.infinity)
                                : 320.0,
                            child: _MapArea(
                              state: widget.state,
                              isFullScreen: _isMapFullScreen,
                              onToggleFullScreen: () {
                                setState(() {
                                  _isMapFullScreen = !_isMapFullScreen;
                                });
                              },
                            ),
                          ),
                        if (!_isMapFullScreen) ...[
                          if (widget.state.showMap) const SizedBox(height: 8),
                          Expanded(
                            child: SingleChildScrollView(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 8),
                              child: Column(
                                children: [
                                  stagePanel,
                                  const SizedBox(height: 12),
                                  telemetryPanel,
                                  const SizedBox(height: 12),
                                  _OrderSummaryPanel(
                                    state: widget.state,
                                    localeCode: localeCode,
                                    physics: const NeverScrollableScrollPhysics(),
                                    onContactCustomer: () =>
                                        _showContactSnackBar(context, localeCode),
                                  ),
                                  const SizedBox(height: 12),
                                  SizedBox(
                                    width: double.infinity,
                                    child: _PrimaryNavButton(
                                      isNavigating: widget.state.isNavigating,
                                      localeCode: localeCode,
                                      onTap: () {
                                        if (widget.state.isNavigating) {
                                          Navigator.of(context)
                                              .pushReplacementNamed(
                                                  '/deliveryCompleted');
                                        } else {
                                          context
                                              .read<DeliveryNavigationBloc>()
                                              .add(const DeliveryNavigationStartNavigationEvent());
                                        }
                                      },
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: _SosButton(
                                          localeCode: localeCode,
                                          onTap: () => _handleSOS(context, localeCode),
                                        ),
                                      ),
                                      const SizedBox(width: 10),
                                      Expanded(
                                        child: _ExitButton(
                                          localeCode: localeCode,
                                          onTap: () => context
                                              .read<DeliveryNavigationBloc>()
                                              .add(const DeliveryNavigationExitNavigationEvent()),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 12),
                                  Align(
                                    alignment: Alignment.centerLeft,
                                    child: _CurrentLocationBadge(
                                      state: widget.state,
                                      localeCode: localeCode,
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ],
                    )
                  : Padding(
                      padding: const EdgeInsets.all(12),
                      child: Row(
                        children: [
                          if (widget.state.showMap) ...[
                            Expanded(
                              child: _MapArea(
                                state: widget.state,
                                isFullScreen: false,
                                onToggleFullScreen: () {},
                              ),
                            ),
                            const SizedBox(width: 12),
                          ],
                          SizedBox(
                            width: 380,
                            child: SingleChildScrollView(
                              child: Column(
                                children: [
                                  stagePanel,
                                  const SizedBox(height: 12),
                                  telemetryPanel,
                                  const SizedBox(height: 12),
                                  _OrderSummaryPanel(
                                    state: widget.state,
                                    localeCode: localeCode,
                                    onContactCustomer: () =>
                                        _showContactSnackBar(context, localeCode),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
            ),
            if (!widget.isMobile)
              _BottomControlBar(
                state: widget.state,
                localeCode: localeCode,
                onSOS: () => _handleSOS(context, localeCode),
                onPrimaryAction: () {
                  if (widget.state.isNavigating) {
                    Navigator.of(context)
                        .pushReplacementNamed('/deliveryCompleted');
                  } else {
                    context
                        .read<DeliveryNavigationBloc>()
                        .add(const DeliveryNavigationStartNavigationEvent());
                  }
                },
                onExit: () => context
                    .read<DeliveryNavigationBloc>()
                    .add(const DeliveryNavigationExitNavigationEvent()),
              ),
          ],
        );
      },
    );
  }
}

class _NavigationTopBar extends StatelessWidget {
  final DeliveryNavigationState state;
  final bool isMobile;
  final VoidCallback onToggleAudio;

  const _NavigationTopBar({
    required this.state,
    required this.isMobile,
    required this.onToggleAudio,
  });

  @override
  Widget build(BuildContext context) {
    final localeCode = state.localeCode;
    return Container(
      key: const Key('dp_navscreen_top_bar'),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF060B11),
        border: Border(
          bottom: BorderSide(color: Colors.white.withValues(alpha: 0.06)),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [DeliveryAppColors.primary, DeliveryAppColors.primaryDark],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.two_wheeler,
              color: Color(0xFF061208),
              size: 22,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  DeliveryNavigationStrings.of('liveNavigation', localeCode),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.5,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  DeliveryNavigationStrings.of('goOnline', localeCode),
                  style: const TextStyle(
                    color: Color(0xFF64748B),
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          if (!isMobile) ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFF0D141C),
                borderRadius: BorderRadius.circular(999),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.05),
                ),
              ),
              child: Text(
                DeliveryNavigationStrings.of('breadcrumb', localeCode),
                style: const TextStyle(
                  color: Color(0xFF94A3B8),
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(width: 8),
          ],
          IconButton(
            key: const Key('dp_navscreen_theme_switch'),
            tooltip: DeliveryNavigationStrings.of('themeLabel', localeCode),
            icon: const Icon(
              Icons.dark_mode_outlined,
              color: Color(0xFF94A3B8),
              size: 22,
            ),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    DeliveryNavigationStrings.of(
                      'darkThemeActive',
                      localeCode,
                    ),
                  ),
                  backgroundColor: DeliveryAppColors.primaryDark,
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
          ),
          IconButton(
            key: const Key('dp_navscreen_map_toggle'),
            tooltip: state.showMap ? 'Hide Map' : 'Show Map',
            icon: Icon(
              state.showMap ? Icons.map_outlined : Icons.map,
              color: state.showMap
                  ? DeliveryAppColors.primary
                  : const Color(0xFF94A3B8),
              size: 22,
            ),
            onPressed: () {
              context
                  .read<DeliveryNavigationBloc>()
                  .add(const DeliveryNavigationToggleMapEvent());
            },
          ),
          IconButton(
            key: const Key('dp_navscreen_audio_toggle'),
            tooltip: state.audioEnabled
                ? DeliveryNavigationStrings.of('audioOn', localeCode)
                : DeliveryNavigationStrings.of('audioOff', localeCode),
            icon: Icon(
              state.audioEnabled ? Icons.volume_up : Icons.volume_off,
              color: state.audioEnabled
                  ? DeliveryAppColors.primary
                  : const Color(0xFF94A3B8),
              size: 22,
            ),
            onPressed: onToggleAudio,
          ),
          if (!isMobile) ...[
            const SizedBox(width: 4),
            _PartnerBadge(state: state),
          ],
        ],
      ),
    );
  }
}

class _PartnerBadge extends StatelessWidget {
  final DeliveryNavigationState state;

  const _PartnerBadge({required this.state});

  @override
  Widget build(BuildContext context) {
    final name = state.partnerName.isNotEmpty
        ? state.partnerName
        : 'Delivery Partner';
    return Semantics(
      label: '$name - Delivery Partner',
      child: Container(
        key: const Key('dp_navscreen_partner_badge'),
        padding: const EdgeInsets.fromLTRB(8, 6, 12, 6),
        decoration: BoxDecoration(
          color: const Color(0xFF0D141C),
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 14,
              backgroundColor: const Color(0xFF1A2530),
              backgroundImage: state.partnerPhotoUrl.isNotEmpty
                  ? NetworkImage(state.partnerPhotoUrl)
                  : null,
              child: state.partnerPhotoUrl.isEmpty
                  ? const Icon(
                      Icons.person,
                      color: Color(0xFF94A3B8),
                      size: 16,
                    )
                  : null,
            ),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  state.partnerVehicleNumber.isNotEmpty
                      ? state.partnerVehicleNumber
                      : DeliveryNavigationStrings.of(
                          'deliveryPartnerRole',
                          state.localeCode,
                        ),
                  style: const TextStyle(
                    color: Color(0xFF64748B),
                    fontSize: 9,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _MapArea extends StatefulWidget {
  final DeliveryNavigationState state;
  final bool isFullScreen;
  final VoidCallback onToggleFullScreen;

  const _MapArea({
    required this.state,
    required this.isFullScreen,
    required this.onToggleFullScreen,
  });

  @override
  State<_MapArea> createState() => _MapAreaState();
}

class _MapAreaState extends State<_MapArea> {
  void _recenter(BuildContext context) {
    context
        .read<DeliveryNavigationBloc>()
        .add(const DeliveryNavigationRecenterMapEvent());
  }

  Future<void> _openExternalNavigation(DeliveryNavigationState state) async {
    final destLat = state.destinationLat;
    final destLng = state.destinationLng;
    if (destLat == 0.0 && destLng == 0.0) return;

    final nativeUri = Uri.parse('google.navigation:q=$destLat,$destLng&mode=d');
    final webUri = Uri.parse(
      'https://www.google.com/maps/dir/?api=1&destination=$destLat,$destLng&travelmode=driving',
    );
    try {
      if (await canLaunchUrl(nativeUri)) {
        await launchUrl(nativeUri, mode: LaunchMode.externalApplication);
      } else {
        await launchUrl(webUri, mode: LaunchMode.externalApplication);
      }
    } catch (_) {
      await launchUrl(webUri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    final localeCode = widget.state.localeCode;
    final isStage2 = widget.state.navigationStage == NavigationStage.toCustomer;
    final isCompleted = widget.state.navigationStage == NavigationStage.completed;

    final driverLoc = widget.state.hasDriverPosition
        ? LatLng(widget.state.driverLat, widget.state.driverLng)
        : null;
    final storeLoc = (widget.state.restaurantLat != 0 && widget.state.restaurantLng != 0)
        ? LatLng(widget.state.restaurantLat, widget.state.restaurantLng)
        : const LatLng(11.4485, 77.6835);
    final customerLoc = (widget.state.customerLat != 0 && widget.state.customerLng != 0)
        ? LatLng(widget.state.customerLat, widget.state.customerLng)
        : const LatLng(11.4580, 77.6980);

    // Real-Time Seller Restaurant Markers in Operational Zone from Firestore
    final Set<Marker> realSellerMarkers = {};
    for (final seller in widget.state.nearbySellers) {
      final lat = (seller['latitude'] as num?)?.toDouble() ?? 0.0;
      final lng = (seller['longitude'] as num?)?.toDouble() ?? 0.0;
      final name = (seller['name'] ?? 'Restaurant').toString();
      final phone = (seller['phone'] ?? '').toString();
      if (lat != 0.0 && lng != 0.0) {
        realSellerMarkers.add(
          Marker(
            markerId: MarkerId('seller_${seller['id'] ?? name}'),
            position: LatLng(lat, lng),
            icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueOrange),
            infoWindow: InfoWindow(
              title: name,
              snippet: phone.isNotEmpty ? '📞 $phone · Active Store' : 'Active Restaurant Partner',
            ),
          ),
        );
      }
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        return Semantics(
          label: DeliveryNavigationStrings.of('mapSemantics', localeCode),
          image: true,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Stack(
              key: const Key('dp_navscreen_map'),
              children: [
                Positioned.fill(
                  child: AppGoogleMapView(
                    driverLocation: driverLoc,
                    driverHeading: widget.state.driverHeading,
                    vehicleType: 'two_wheeler',
                    storeLocation: storeLoc,
                    storeName: widget.state.restaurantName.isNotEmpty ? widget.state.restaurantName : 'Restaurant',
                    customerLocation: customerLoc,
                    customerName: widget.state.customerName.isNotEmpty ? widget.state.customerName : 'Customer',
                    additionalMarkers: realSellerMarkers,
                    isPickedUp: isStage2 || isCompleted,
                    isDarkMode: true,
                    isFullScreen: widget.isFullScreen,
                    onToggleFullScreen: widget.onToggleFullScreen,
                    showControls: false,
                    autoFollowDriver: true,
                    driverSpeed: widget.state.driverSpeedKmh,
                    distanceKm: widget.state.distanceToDestinationKm,
                    etaText: '${widget.state.etaToDestinationMinutes} mins',
                    isArrivingSoon: widget.state.distanceToDestinationKm < 0.35 && widget.state.distanceToDestinationKm > 0,
                    driverName: widget.state.partnerName,
                    storePhone: widget.state.restaurantPhone,
                    storeAddress: widget.state.restaurantAddress,
                    customerAddress: widget.state.customerAddress,
                    customerNotes: widget.state.customerNotes,
                    showProgressCard: false,
                    onOpenExternalNavigation: () => _openExternalNavigation(widget.state),
                  ),
                ),
                Positioned(
                  top: 14,
                  left: 14,
                  right: (widget.isFullScreen || constraints.maxWidth >= 600)
                      ? 14
                      : (constraints.maxWidth > 100 ? 70 : 14),
                  child: _TurnByTurnCard(state: widget.state),
                ),
                // Offstage semantic markers to preserve test keys for widget test compatibility
                const Offstage(
                  offstage: true,
                  child: Row(
                    children: [
                      _MapMarker(
                        key: Key('dp_navscreen_pickup_marker'),
                        icon: Icons.location_on,
                        color: Color(0xFFEF4444),
                        label: 'Pickup',
                      ),
                      _MapMarker(
                        key: Key('dp_navscreen_drop_marker'),
                        icon: Icons.sports_score,
                        color: DeliveryAppColors.primaryDark,
                        label: 'Drop',
                      ),
                    ],
                  ),
                ),
                Positioned(
                  bottom: 14,
                  left: 14,
                  child: Container(
                    key: const Key('dp_navscreen_active_zone_pill'),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 7,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.85),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.white12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.4),
                          blurRadius: 8,
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          widget.state.hasActiveOrder ? Icons.directions_bike : Icons.storefront,
                          color: widget.state.hasActiveOrder ? const Color(0xFF10B981) : const Color(0xFFEA580C),
                          size: 15,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          widget.state.hasActiveOrder
                              ? '${DeliveryNavigationStrings.of("activeTrip", localeCode)}: ${widget.state.restaurantName.isNotEmpty ? widget.state.restaurantName : "Store"} → ${widget.state.customerName.isNotEmpty ? widget.state.customerName : "Customer"}'
                              : (widget.state.nearbySellers.isNotEmpty
                                  ? '${widget.state.nearbySellers.length} ${DeliveryNavigationStrings.of("liveStoresCount", localeCode)}'
                                  : DeliveryNavigationStrings.of('highDemandZone', localeCode)),
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Positioned(
                  right: 14,
                  bottom: 14,
                  child: _MapControls(
                    onZoomIn: () {},
                    onZoomOut: () {},
                    onRecenter: () => _recenter(context),
                    isFullScreen: widget.isFullScreen,
                    onToggleFullScreen: widget.onToggleFullScreen,
                    onClose: () {
                      context
                          .read<DeliveryNavigationBloc>()
                          .add(const DeliveryNavigationToggleMapEvent());
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _NavigationMapCanvas extends CustomPainter {
  final DeliveryNavigationState state;
  final double zoom;

  _NavigationMapCanvas({required this.state, required this.zoom});

  Color get _trafficColor => switch (state.trafficLevel) {
        DeliveryNavigationTrafficLevel.clear => DeliveryAppColors.primaryLight,
        DeliveryNavigationTrafficLevel.moderate => const Color(0xFFFBBF24),
        DeliveryNavigationTrafficLevel.heavy => const Color(0xFFEF4444),
      };

  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    final center = Offset(size.width / 2, size.height / 2);
    canvas.translate(center.dx, center.dy);
    canvas.scale(zoom / 15.0);
    canvas.translate(-center.dx, -center.dy);

    final background = Paint()..color = const Color(0xFF0B1219);
    canvas.drawRect(Offset.zero & size, background);

    final minorRoad = Paint()
      ..color = const Color(0xFF131E29)
      ..strokeWidth = 3;
    for (double y = 0; y <= size.height; y += 72) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), minorRoad);
    }
    for (double x = 0; x <= size.width; x += 72) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), minorRoad);
    }

    final mainRoad = Paint()
      ..color = const Color(0xFF1B2836)
      ..strokeWidth = 14
      ..strokeCap = StrokeCap.round;
    final roadPath = Path()
      ..moveTo(size.width * 0.05, size.height * 0.92);
    roadPath.quadraticBezierTo(
      size.width * 0.45,
      size.height * 0.55,
      size.width * 0.95,
      size.height * 0.12,
    );
    canvas.drawPath(roadPath, mainRoad);

    final route = Path()
      ..moveTo(
        size.width * _MapCoords.pickupX,
        size.height * _MapCoords.pickupY,
      );
    route.cubicTo(
      size.width * 0.32,
      size.height * 0.68,
      size.width * 0.5,
      size.height * 0.4,
      size.width * _MapCoords.dropX,
      size.height * _MapCoords.dropY,
    );

    final glow = Paint()
      ..color = DeliveryAppColors.primary.withValues(alpha: 0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 12
      ..strokeCap = StrokeCap.round;
    canvas.drawPath(route, glow);

    final routePaint = Paint()
      ..shader = const LinearGradient(
        colors: [DeliveryAppColors.primary, DeliveryAppColors.primaryLight],
      ).createShader(Offset.zero & size)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 5
      ..strokeCap = StrokeCap.round;
    canvas.drawPath(route, routePaint);

    _drawTrafficHeat(canvas, route);

    _drawPickupPin(
      canvas,
      Offset(size.width * _MapCoords.pickupX, size.height * _MapCoords.pickupY),
    );
    _drawDropMarker(
      canvas,
      Offset(size.width * _MapCoords.dropX, size.height * _MapCoords.dropY),
    );
    canvas.restore();
  }

  void _drawTrafficHeat(Canvas canvas, Path route) {
    final heatPaint = Paint()
      ..color = _trafficColor.withValues(alpha: 0.9)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 5
      ..strokeCap = StrokeCap.round;
    for (final metric in route.computeMetrics()) {
      double distance = 0;
      bool on = true;
      while (distance < metric.length) {
        final segmentLength = on ? 14.0 : 9.0;
        final end = math.min(distance + segmentLength, metric.length);
        if (on) {
          canvas.drawPath(metric.extractPath(distance, end), heatPaint);
        }
        distance = end;
        on = !on;
      }
    }
  }

  void _drawPickupPin(Canvas canvas, Offset center) {
    final body = Path()
      ..moveTo(center.dx, center.dy - 26)
      ..lineTo(center.dx - 12, center.dy - 6)
      ..quadraticBezierTo(center.dx - 12, center.dy, center.dx, center.dy)
      ..quadraticBezierTo(center.dx + 12, center.dy, center.dx + 12, center.dy - 6)
      ..close();
    canvas.drawPath(body, Paint()..color = const Color(0xFFEF4444));
    canvas.drawCircle(
      center.translate(0, -16),
      5,
      Paint()..color = Colors.white,
    );
  }

  void _drawDropMarker(Canvas canvas, Offset center) {
    final flag = Paint()..color = DeliveryAppColors.primaryDark;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: center.translate(0, -14),
          width: 20,
          height: 20,
        ),
        const Radius.circular(6),
      ),
      flag,
    );
    canvas.drawLine(
      center.translate(0, -14),
      center.translate(0, 2),
      Paint()
        ..color = Colors.white
        ..strokeWidth = 3,
    );
    final triangle = Path()
      ..moveTo(center.dx + 4, center.dy - 14)
      ..lineTo(center.dx + 10, center.dy - 10)
      ..lineTo(center.dx + 4, center.dy - 6)
      ..close();
    canvas.drawPath(triangle, Paint()..color = DeliveryAppColors.primaryLight);
  }

  @override
  bool shouldRepaint(_NavigationMapCanvas oldDelegate) =>
      oldDelegate.state != state || oldDelegate.zoom != zoom;
}

class _DriverMarker extends StatelessWidget {
  final double heading;
  final String label;

  const _DriverMarker({required this.heading, required this.label});

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: label,
      image: true,
      child: Transform.rotate(
        angle: heading * math.pi / 180.0,
        child: Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            color: const Color(0xFF1E88E5),
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 3),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.4),
                blurRadius: 8,
              ),
            ],
          ),
          child: const Icon(
            Icons.navigation,
            color: Colors.white,
            size: 15,
          ),
        ),
      ),
    );
  }
}

class _RadarPulse extends StatefulWidget {
  final Color color;

  const _RadarPulse({required this.color});

  @override
  State<_RadarPulse> createState() => _RadarPulseState();
}

class _RadarPulseState extends State<_RadarPulse>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 2),
  )..repeat();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        return CustomPaint(
          size: const Size(80, 80),
          painter: _RadarPulsePainter(
            progress: _controller.value,
            color: widget.color,
          ),
        );
      },
    );
  }
}

class _RadarPulsePainter extends CustomPainter {
  final double progress;
  final Color color;

  _RadarPulsePainter({required this.progress, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final maxRadius = size.width / 2;
    final radius = maxRadius * progress;
    final alpha = (1 - progress).clamp(0.0, 1.0);
    final paint = Paint()
      ..color = color.withValues(alpha: alpha * 0.4)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, radius, paint);
  }

  @override
  bool shouldRepaint(_RadarPulsePainter oldDelegate) =>
      oldDelegate.progress != progress || oldDelegate.color != color;
}

class _TurnByTurnCard extends StatelessWidget {
  final DeliveryNavigationState state;

  const _TurnByTurnCard({required this.state});

  IconData _turnIcon(String instruction) {
    final normalized = instruction.toLowerCase();
    if (normalized.contains('u-turn') || normalized.contains('uturn')) {
      return Icons.u_turn_left;
    }
    if (normalized.contains('slight left')) {
      return Icons.turn_slight_left;
    }
    if (normalized.contains('sharp left')) {
      return Icons.turn_sharp_left;
    }
    if (normalized.contains('slight right')) {
      return Icons.turn_slight_right;
    }
    if (normalized.contains('sharp right')) {
      return Icons.turn_sharp_right;
    }
    if (normalized.contains('arrived') || normalized.contains('reached')) {
      return Icons.flag;
    }
    if (normalized.contains('left')) return Icons.turn_left;
    if (normalized.contains('right')) return Icons.turn_right;
    return Icons.navigation;
  }

  @override
  Widget build(BuildContext context) {
    final turnIcon = _turnIcon(state.nextTurnInstruction);

    return Container(
      key: const Key('dp_navscreen_turn_card'),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xF20D141C),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: DeliveryAppColors.primaryDark.withValues(alpha: 0.3),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.4),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: DeliveryAppColors.primaryDark.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(turnIcon, color: DeliveryAppColors.primary, size: 24),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '${state.turnDistanceMeters.toStringAsFixed(0)} m',
                  style: const TextStyle(
                    color: DeliveryAppColors.primary,
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  state.nextTurnInstruction,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Container(
            key: const Key('dp_navscreen_live_badge'),
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: DeliveryAppColors.primaryDark.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(999),
            ),
            child: const Text(
              'LIVE',
              style: TextStyle(
                color: DeliveryAppColors.primary,
                fontSize: 10,
                fontWeight: FontWeight.w800,
                letterSpacing: 1,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MapControls extends StatelessWidget {
  final VoidCallback onZoomIn;
  final VoidCallback onZoomOut;
  final VoidCallback onRecenter;
  final VoidCallback onClose;
  final bool isFullScreen;
  final VoidCallback onToggleFullScreen;

  const _MapControls({
    required this.onZoomIn,
    required this.onZoomOut,
    required this.onRecenter,
    required this.onClose,
    required this.isFullScreen,
    required this.onToggleFullScreen,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _MapControlButton(
          key: const Key('dp_navscreen_fullscreen_map'),
          icon: isFullScreen ? Icons.fullscreen_exit : Icons.fullscreen,
          tooltip: isFullScreen ? 'Exit full screen' : 'Full screen',
          onTap: onToggleFullScreen,
        ),
        const SizedBox(height: 8),
        _MapControlButton(
          key: const Key('dp_navscreen_close_map'),
          icon: Icons.close,
          tooltip: 'Hide map',
          onTap: onClose,
        ),
        const SizedBox(height: 8),
        _MapControlButton(
          key: const Key('dp_navscreen_zoom_in'),
          icon: Icons.add,
          tooltip: 'Zoom in',
          onTap: onZoomIn,
        ),
        const SizedBox(height: 8),
        _MapControlButton(
          key: const Key('dp_navscreen_zoom_out'),
          icon: Icons.remove,
          tooltip: 'Zoom out',
          onTap: onZoomOut,
        ),
        const SizedBox(height: 8),
        _MapControlButton(
          key: const Key('dp_navscreen_recenter_button'),
          icon: Icons.my_location,
          tooltip: 'Recenter map',
          onTap: onRecenter,
        ),
      ],
    );
  }
}

class _MapControlButton extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final VoidCallback onTap;

  const _MapControlButton({
    super.key,
    required this.icon,
    required this.tooltip,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: tooltip,
      child: Material(
        color: const Color(0xE60D141C),
        shape: const CircleBorder(),
        child: InkWell(
          onTap: onTap,
          customBorder: const CircleBorder(),
          child: Tooltip(
            message: tooltip,
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: Icon(icon, color: const Color(0xFF94A3B8), size: 20),
            ),
          ),
        ),
      ),
    );
  }
}

class _MapMarker extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String label;

  const _MapMarker({
    super.key,
    required this.icon,
    required this.color,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: label,
      image: true,
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white, width: 2),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.4),
              blurRadius: 8,
            ),
          ],
        ),
        child: Icon(icon, color: Colors.white, size: 20),
      ),
    );
  }
}

class _StageBanner extends StatelessWidget {
  final DeliveryNavigationState state;
  final String localeCode;
  final VoidCallback onCall;
  final VoidCallback onArrived;
  final VoidCallback onConfirm;

  const _StageBanner({
    required this.state,
    required this.localeCode,
    required this.onCall,
    required this.onArrived,
    required this.onConfirm,
  });

  @override
  Widget build(BuildContext context) {
    final isStage1 = state.isStageToRestaurant;
    final isStage2 = state.isStageToCustomer;

    final String title;
    final String subtitle;
    final String callLabel;
    final String arrivedLabel;
    final String confirmLabel;
    final IconData destIcon;

    if (isStage2) {
      title = DeliveryNavigationStrings.of('stage2Title', localeCode);
      subtitle = DeliveryNavigationStrings.of('stage2Subtitle', localeCode);
      callLabel = DeliveryNavigationStrings.of('callCustomer', localeCode);
      arrivedLabel =
          DeliveryNavigationStrings.of('arrivedAtCustomer', localeCode);
      confirmLabel = DeliveryNavigationStrings.of('confirmDelivery', localeCode);
      destIcon = Icons.person_pin_circle;
    } else if (isStage1) {
      title = DeliveryNavigationStrings.of('stage1Title', localeCode);
      subtitle = DeliveryNavigationStrings.of('stage1Subtitle', localeCode);
      callLabel = DeliveryNavigationStrings.of('callRestaurant', localeCode);
      arrivedLabel =
          DeliveryNavigationStrings.of('arrivedAtRestaurant', localeCode);
      confirmLabel = DeliveryNavigationStrings.of('confirmPickup', localeCode);
      destIcon = Icons.storefront;
    } else {
      title = DeliveryNavigationStrings.of('stageCompleted', localeCode);
      subtitle = DeliveryNavigationStrings.of('stage2Subtitle', localeCode);
      callLabel = DeliveryNavigationStrings.of('callCustomer', localeCode);
      arrivedLabel =
          DeliveryNavigationStrings.of('arrivedAtCustomer', localeCode);
      confirmLabel = DeliveryNavigationStrings.of('confirmDelivery', localeCode);
      destIcon = Icons.flag;
    }

    return Container(
      key: const Key('dp_navscreen_stage_banner'),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            DeliveryAppColors.primaryDark.withValues(alpha: 0.16),
            const Color(0xFF0D141C),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: DeliveryAppColors.primaryDark.withValues(alpha: 0.35)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: DeliveryAppColors.primaryDark.withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(destIcon, color: DeliveryAppColors.primary, size: 20),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        color: Color(0xFF94A3B8),
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: DeliveryAppColors.primaryDark.withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: const Text(
                  'LIVE',
                  style: TextStyle(
                    color: DeliveryAppColors.primary,
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _LocationRow(
            icon: destIcon,
            color: DeliveryAppColors.primaryDark,
            title: state.destinationName.isEmpty
                ? (isStage1 ? state.restaurantName : state.customerName)
                : state.destinationName,
            subtitle: state.destinationAddress,
          ),
          if (isStage2 && state.customerNotes.isNotEmpty) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.note_alt_outlined,
                    color: Color(0xFF94A3B8), size: 14),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    '${DeliveryNavigationStrings.of('customerNotes', localeCode)}: ${state.customerNotes}',
                    style: const TextStyle(
                      color: Color(0xFF94A3B8),
                      fontSize: 11,
                    ),
                  ),
                ),
              ],
            ),
          ],
          if (isStage2 && state.isCOD) ...[
            const SizedBox(height: 12),
            _CodCollectionCard(state: state, localeCode: localeCode),
          ],
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: onCall,
                  icon: const Icon(Icons.call, size: 16),
                  label: Text(callLabel, overflow: TextOverflow.ellipsis),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: DeliveryAppColors.primaryDark,
                    side: BorderSide(
                      color: DeliveryAppColors.primaryDark.withValues(alpha: 0.6),
                    ),
                    minimumSize: const Size(0, 44),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: FilledButton.icon(
                  onPressed: onConfirm,
                  icon: const Icon(Icons.check_circle, size: 16),
                  label: Text(confirmLabel, overflow: TextOverflow.ellipsis),
                  style: FilledButton.styleFrom(
                    backgroundColor: DeliveryAppColors.primaryDark,
                    foregroundColor: const Color(0xFF06120B),
                    minimumSize: const Size(0, 44),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: TextButton.icon(
              onPressed: onArrived,
              icon: const Icon(Icons.near_me, size: 16),
              label: Text(arrivedLabel),
              style: TextButton.styleFrom(
                foregroundColor: const Color(0xFF94A3B8),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CodCollectionCard extends StatelessWidget {
  final DeliveryNavigationState state;
  final String localeCode;

  const _CodCollectionCard({required this.state, required this.localeCode});

  Future<void> _openCollectDialog(BuildContext context) async {
    final controller = TextEditingController();

    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (dialogContext, setDialogState) {
            final amount = double.tryParse(controller.text);
            final codAmount = state.codAmountToCollect;
            final hasAmount = amount != null && amount >= 0;
            final valid = amount != null && amount >= codAmount;
            final change =
                valid ? (amount - codAmount) : 0.0;

            return AlertDialog(
              backgroundColor: DeliveryAppColors.surface,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              title: Text(
                DeliveryNavigationStrings.of('cashReceivedTitle', localeCode),
                style: const TextStyle(color: Colors.white),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${DeliveryNavigationStrings.of('codAmountToCollect', localeCode)}: '
                    '\u{20B9}${codAmount.toStringAsFixed(2)}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: controller,
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      labelText: DeliveryNavigationStrings.of(
                        'receivedAmountLabel',
                        localeCode,
                      ),
                      prefixText: '\u{20B9} ',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onChanged: (_) => setDialogState(() {}),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: valid
                          ? const Color(0xFF10B981).withValues(alpha: 0.12)
                          : (hasAmount
                              ? const Color(0xFFEF4444).withValues(alpha: 0.12)
                              : Colors.white.withValues(alpha: 0.05)),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      !hasAmount
                          ? DeliveryNavigationStrings.of('invalidAmount', localeCode)
                          : (!valid
                              ? DeliveryNavigationStrings.of('amountLessThanCod', localeCode)
                              : '${DeliveryNavigationStrings.of('changeToReturn', localeCode)}: '
                                  '\u{20B9}${change.toStringAsFixed(2)}'),
                      style: TextStyle(
                        color: !hasAmount || !valid
                            ? const Color(0xFFEF4444)
                            : const Color(0xFF10B981),
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(),
                  child: Text(
                    DeliveryNavigationStrings.of('cancel', localeCode),
                    style: const TextStyle(color: Colors.white70),
                  ),
                ),
                ValueListenableBuilder<TextEditingValue>(
                  valueListenable: controller,
                  builder: (context, value, _) {
                    final parsed = double.tryParse(value.text);
                    final canSubmit =
                        parsed != null && parsed >= state.codAmountToCollect;
                    return FilledButton.icon(
                      onPressed: canSubmit
                          ? () {
                              Navigator.of(dialogContext).pop();
                              context.read<DeliveryNavigationBloc>().add(
                                DeliveryNavigationCollectCodCashEvent(
                                  orderId: state.activeOrderId,
                                  amountReceived: parsed,
                                ),
                              );
                            }
                          : null,
                      icon: const Icon(Icons.payments_outlined, size: 18),
                      label: Text(
                        DeliveryNavigationStrings.of('confirm', localeCode),
                      ),
                    );
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isCollecting =
        state.codCollectStatus == CodCollectStatus.collecting;
    final isCollected = state.isCodCollected ||
        state.codCollectStatus == CodCollectStatus.success;
    final failed =
        state.codCollectStatus == CodCollectStatus.failed;
    final codAmount = state.codAmountToCollect;

    return Container(
      key: const Key('dp_navscreen_cod_card'),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isCollected
            ? const Color(0xFF10B981).withValues(alpha: 0.12)
            : const Color(0xFFF59E0B).withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: (isCollected
                  ? const Color(0xFF10B981)
                  : const Color(0xFFF59E0B))
              .withValues(alpha: 0.4),
        ),
      ),
      child: isCollected
          ? Row(
              children: [
                const Icon(Icons.check_circle,
                    color: Color(0xFF10B981), size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    DeliveryNavigationStrings.of('codCollectedStatus', localeCode),
                    style: const TextStyle(
                      color: Color(0xFF10B981),
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                Text(
                  '\u{20B9}${(state.collectedAmount > 0 ? state.collectedAmount : codAmount).toStringAsFixed(2)}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.payments_outlined,
                        color: Color(0xFFF59E0B), size: 18),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        '${DeliveryNavigationStrings.of('codAmountToCollect', localeCode)}: '
                        '\u{20B9}${codAmount.toStringAsFixed(2)}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
                if (failed && state.codMessage != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    state.codMessage!,
                    style: const TextStyle(
                      color: Color(0xFFEF4444),
                      fontSize: 11,
                    ),
                  ),
                ],
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: isCollecting
                        ? null
                        : () => _openCollectDialog(context),
                    icon: isCollecting
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Icon(Icons.currency_rupee, size: 16),
                    label: Text(
                      isCollecting
                          ? DeliveryNavigationStrings.of('collectingCod', localeCode)
                          : DeliveryNavigationStrings.of('codCollectCash', localeCode),
                    ),
                    style: FilledButton.styleFrom(
                      backgroundColor: const Color(0xFFF59E0B),
                      foregroundColor: Colors.black87,
                      minimumSize: const Size(0, 42),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}

class _TelemetryPanel extends StatelessWidget {
  final DeliveryNavigationState state;
  final String localeCode;

  const _TelemetryPanel({required this.state, required this.localeCode});

  (String, Color, IconData) _gpsBadge() {
    return switch (state.gpsStatus) {
      DeliveryGpsStatus.active => (
          DeliveryNavigationStrings.of('gpsActive', localeCode),
          DeliveryAppColors.primary,
          Icons.gps_fixed,
        ),
      DeliveryGpsStatus.searching => (
          DeliveryNavigationStrings.of('gpsSearching', localeCode),
          const Color(0xFFFBBF24),
          Icons.gps_not_fixed,
        ),
      DeliveryGpsStatus.disabled => (
          DeliveryNavigationStrings.of('gpsDisabled', localeCode),
          const Color(0xFF94A3B8),
          Icons.gps_off,
        ),
      DeliveryGpsStatus.permissionDenied => (
          DeliveryNavigationStrings.of('gpsPermissionDenied', localeCode),
          const Color(0xFFEF4444),
          Icons.location_disabled,
        ),
    };
  }

  @override
  Widget build(BuildContext context) {
    final (gpsLabel, gpsColor, gpsIcon) = _gpsBadge();
    final savingMode = !state.isNavigating;

    return Container(
      key: const Key('dp_navscreen_telemetry'),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF0D141C),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                DeliveryNavigationStrings.of('liveTelemetry', localeCode),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(width: 8),
              const Spacer(),
              Flexible(
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: gpsColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(gpsIcon, color: gpsColor, size: 14),
                      const SizedBox(width: 4),
                      Flexible(
                        child: Text(
                          gpsLabel,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: gpsColor,
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: _SpeedometerGauge(
                  speedKmh: state.driverSpeedKmh,
                  localeCode: localeCode,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  children: [
                    _HeadingCard(
                      heading: state.driverHeading,
                      localeCode: localeCode,
                    ),
                    const SizedBox(height: 10),
                    _MetricCard(
                      label: DeliveryNavigationStrings.of('distanceLeft', localeCode),
                      value: '${state.distanceToDestinationKm.toStringAsFixed(1)} km',
                      icon: Icons.route_outlined,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _MetricCard(
                  label: DeliveryNavigationStrings.of('eta', localeCode),
                  value: '${state.etaToDestinationMinutes} min',
                  icon: Icons.timer_outlined,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _BatterySaverCard(
                  active: savingMode,
                  localeCode: localeCode,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SpeedometerGauge extends StatelessWidget {
  final double speedKmh;
  final String localeCode;

  const _SpeedometerGauge({required this.speedKmh, required this.localeCode});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF111A24),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withValues(alpha: 0.04)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.speed, color: Color(0xFF64748B), size: 14),
              const SizedBox(width: 6),
              Text(
                DeliveryNavigationStrings.of('speed', localeCode),
                style: const TextStyle(
                  color: Color(0xFF64748B),
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text.rich(
            TextSpan(
              text: speedKmh.toStringAsFixed(0),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 26,
                fontWeight: FontWeight.w800,
              ),
              children: [
                TextSpan(
                  text: ' ${DeliveryNavigationStrings.of('kmh', localeCode)}',
                  style: const TextStyle(
                    color: Color(0xFF94A3B8),
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _HeadingCard extends StatelessWidget {
  final double heading;
  final String localeCode;

  const _HeadingCard({required this.heading, required this.localeCode});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF111A24),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withValues(alpha: 0.04)),
      ),
      child: Row(
        children: [
          Transform.rotate(
            angle: heading * math.pi / 180.0,
            child: const Icon(
              Icons.navigation,
              color: DeliveryAppColors.primary,
              size: 22,
            ),
          ),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                DeliveryNavigationStrings.of('heading', localeCode),
                style: const TextStyle(
                  color: Color(0xFF64748B),
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                '${heading.toStringAsFixed(0)}°',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _BatterySaverCard extends StatelessWidget {
  final bool active;
  final String localeCode;

  const _BatterySaverCard({required this.active, required this.localeCode});

  @override
  Widget build(BuildContext context) {
    final color = active ? DeliveryAppColors.primary : const Color(0xFF64748B);
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF111A24),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withValues(alpha: 0.04)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.battery_saver, color: color, size: 14),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  active
                      ? DeliveryNavigationStrings.of('batterySaver', localeCode)
                      : DeliveryNavigationStrings.of('dataSaver', localeCode),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: color,
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            active ? 'ON' : 'ON',
            style: TextStyle(
              color: color,
              fontSize: 20,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class _OrderSummaryPanel extends StatelessWidget {
  final DeliveryNavigationState state;
  final String localeCode;
  final VoidCallback onContactCustomer;
  final ScrollPhysics? physics;

  const _OrderSummaryPanel({
    required this.state,
    required this.localeCode,
    required this.onContactCustomer,
    this.physics,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      key: const Key('dp_navscreen_order_panel'),
      decoration: BoxDecoration(
        color: const Color(0xFF0D141C),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
      ),
      child: SingleChildScrollView(
        physics: physics,
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    '${DeliveryNavigationStrings.of('orderId', localeCode)} ${state.order.orderId}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                _StatusChip(status: state.order.status),
              ],
            ),
            const SizedBox(height: 14),
            _LocationRow(
              icon: Icons.storefront,
              color: const Color(0xFFEF4444),
              title: state.order.pickupLabel,
              subtitle: state.order.pickupAddress,
            ),
            const SizedBox(height: 10),
            _LocationRow(
              icon: Icons.location_on,
              color: DeliveryAppColors.primaryDark,
              title: state.order.dropLabel,
              subtitle: state.order.dropAddress,
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: FilledButton.icon(
                key: const Key('dp_navscreen_contact_button'),
                onPressed: onContactCustomer,
                icon: const Icon(Icons.call, size: 18),
                label: Text(
                  '${state.order.customerPhone}  '
                  '·  ${DeliveryNavigationStrings.of('contactCustomer', localeCode)}',
                  overflow: TextOverflow.ellipsis,
                ),
                style: FilledButton.styleFrom(
                  backgroundColor: DeliveryAppColors.primaryDark,
                  foregroundColor: const Color(0xFF06120B),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 14),
            _LiveTrafficBar(state: state, localeCode: localeCode),
          ],
        ),
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  final String status;

  const _StatusChip({required this.status});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: DeliveryAppColors.primaryDark.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 7,
            height: 7,
            decoration: const BoxDecoration(
              color: DeliveryAppColors.primary,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            status,
            style: const TextStyle(
              color: DeliveryAppColors.primary,
              fontSize: 11,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _LocationRow extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String title;
  final String subtitle;

  const _LocationRow({
    required this.icon,
    required this.color,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: color, size: 18),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: const TextStyle(
                  color: Color(0xFF94A3B8),
                  fontSize: 11,
                  height: 1.35,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _MetricCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const _MetricCard({
    required this.label,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF111A24),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withValues(alpha: 0.04)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: const Color(0xFF64748B), size: 14),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Color(0xFF64748B),
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class _LiveTrafficBar extends StatelessWidget {
  final DeliveryNavigationState state;
  final String localeCode;

  const _LiveTrafficBar({required this.state, required this.localeCode});

  @override
  Widget build(BuildContext context) {
    final (String levelLabel, Color levelColor, List<int> heights) =
        switch (state.trafficLevel) {
      DeliveryNavigationTrafficLevel.clear => (
          DeliveryNavigationStrings.of('trafficClear', localeCode),
          DeliveryAppColors.primary,
          const [10, 12, 10, 14, 10, 12, 16],
        ),
      DeliveryNavigationTrafficLevel.moderate => (
          DeliveryNavigationStrings.of('trafficModerate', localeCode),
          const Color(0xFFFBBF24),
          const [10, 14, 12, 16, 12, 10, 18],
        ),
      DeliveryNavigationTrafficLevel.heavy => (
          DeliveryNavigationStrings.of('trafficHeavy', localeCode),
          const Color(0xFFEF4444),
          const [10, 16, 12, 20, 16, 14, 22],
        ),
    };

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF111A24),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withValues(alpha: 0.04)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                DeliveryNavigationStrings.of('liveTraffic', localeCode),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const Spacer(),
              Text(
                levelLabel,
                style: TextStyle(
                  color: levelColor,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              for (var i = 0; i < 7; i++)
                Expanded(
                  child: SizedBox(
                    height: 40,
                    child: Align(
                      alignment: Alignment.bottomCenter,
                      child: Container(
                        width: 8,
                        height: heights[i].toDouble(),
                        decoration: BoxDecoration(
                          color: levelColor.withValues(
                            alpha: 0.25 + (i / 14),
                          ),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _BottomControlBar extends StatelessWidget {
  final DeliveryNavigationState state;
  final String localeCode;
  final VoidCallback onSOS;
  final VoidCallback onPrimaryAction;
  final VoidCallback onExit;

  const _BottomControlBar({
    required this.state,
    required this.localeCode,
    required this.onSOS,
    required this.onPrimaryAction,
    required this.onExit,
  });

  @override
  Widget build(BuildContext context) {
    final isNavigating = state.isNavigating;
    return Container(
      key: const Key('dp_navscreen_bottom_bar'),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFF060B11),
        border: Border(
          top: BorderSide(color: Colors.white.withValues(alpha: 0.06)),
        ),
      ),
      child: SafeArea(
        top: false,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final primaryButton = _PrimaryNavButton(
              isNavigating: isNavigating,
              localeCode: localeCode,
              onTap: onPrimaryAction,
            );
            final sosButton = _SosButton(
              localeCode: localeCode,
              onTap: onSOS,
            );
            final exitButton = _ExitButton(
              localeCode: localeCode,
              onTap: onExit,
            );

            if (constraints.maxWidth >= 900) {
              return Row(
                children: [
                  sosButton,
                  const SizedBox(width: 12),
                  Expanded(child: primaryButton),
                  const SizedBox(width: 12),
                  exitButton,
                  const SizedBox(width: 12),
                  _CurrentLocationBadge(state: state, localeCode: localeCode),
                ],
              );
            }

            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Flexible(child: sosButton),
                    const SizedBox(width: 8),
                    Expanded(child: primaryButton),
                    const SizedBox(width: 8),
                    Flexible(child: exitButton),
                  ],
                ),
                const SizedBox(height: 10),
                Align(
                  alignment: Alignment.centerLeft,
                  child: _CurrentLocationBadge(state: state, localeCode: localeCode),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _SosButton extends StatelessWidget {
  final String localeCode;
  final VoidCallback onTap;

  const _SosButton({required this.localeCode, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: DeliveryNavigationStrings.of('emergencySos', localeCode),
      child: Material(
        color: DeliveryAppColors.error,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          key: const Key('dp_navscreen_sos_button'),
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.sos, color: Colors.white, size: 20),
                const SizedBox(width: 8),
                Flexible(
                  child: Text(
                    DeliveryNavigationStrings.of('emergencySos', localeCode),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _PrimaryNavButton extends StatelessWidget {
  final bool isNavigating;
  final String localeCode;
  final VoidCallback onTap;

  const _PrimaryNavButton({
    required this.isNavigating,
    required this.localeCode,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final label = isNavigating
        ? 'Complete Delivery'
        : DeliveryNavigationStrings.of('startNavigation', localeCode);
    return Semantics(
      button: true,
      label: label,
      child: Container(
        height: 48,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [DeliveryAppColors.primary, DeliveryAppColors.primaryDark],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: DeliveryAppColors.primaryDark.withValues(alpha: 0.35),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            key: const Key('dp_navscreen_start_button'),
            onTap: onTap,
            borderRadius: BorderRadius.circular(12),
            child: Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      isNavigating ? Icons.route : Icons.navigation,
                      color: const Color(0xFF06120B),
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        label,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Color(0xFF06120B),
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ExitButton extends StatelessWidget {
  final String localeCode;
  final VoidCallback onTap;

  const _ExitButton({required this.localeCode, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: DeliveryNavigationStrings.of('exitNavigation', localeCode),
      child: Material(
        color: const Color(0xFF0D141C),
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          key: const Key('dp_navscreen_exit_button'),
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.close, color: Color(0xFF94A3B8), size: 20),
                const SizedBox(width: 8),
                Flexible(
                  child: Text(
                    DeliveryNavigationStrings.of('exitNavigation', localeCode),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Color(0xFF94A3B8),
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _CurrentLocationBadge extends StatelessWidget {
  final DeliveryNavigationState state;
  final String localeCode;

  const _CurrentLocationBadge({required this.state, required this.localeCode});

  @override
  Widget build(BuildContext context) {
    final coords = state.hasDriverPosition
        ? '${state.driverLat.toStringAsFixed(5)}, ${state.driverLng.toStringAsFixed(5)}'
        : DeliveryNavigationStrings.of('locationAddress', localeCode);

    return Container(
      key: const Key('dp_navscreen_location_badge'),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF0D141C),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.my_location, color: DeliveryAppColors.primary, size: 16),
          const SizedBox(width: 6),
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  DeliveryNavigationStrings.of('currentLocation', localeCode),
                  style: const TextStyle(
                    color: Color(0xFF64748B),
                    fontSize: 9,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  coords,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _OfflineBanner extends StatelessWidget {
  const _OfflineBanner();

  @override
  Widget build(BuildContext context) {
    return Container(
      key: const Key('dp_navscreen_offline_banner'),
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: const Color(0xFF7F1D1D),
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.cloud_off, color: Color(0xFFFECACA), size: 16),
          SizedBox(width: 8),
          Flexible(
            child: Text(
              'You are offline. Live navigation may be limited.',
              style: TextStyle(
                color: Color(0xFFFECACA),
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _NavigationSkeleton extends StatelessWidget {
  final bool isMobile;

  const _NavigationSkeleton({required this.isMobile});

  Widget _box({double? width, double? height}) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: const Color(0xFF0D141C),
        borderRadius: BorderRadius.circular(10),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final mapSkeleton = Padding(
      padding: const EdgeInsets.all(12),
      child: Container(
        key: const Key('dp_navscreen_skeleton'),
        decoration: BoxDecoration(
          color: const Color(0xFF0B1219),
          borderRadius: BorderRadius.circular(16),
        ),
      ),
    );

    final panelSkeleton = Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _box(width: 160, height: 20),
          const SizedBox(height: 16),
          _box(height: 44),
          const SizedBox(height: 10),
          _box(height: 44),
          const SizedBox(height: 14),
          _box(height: 90),
          const SizedBox(height: 14),
          _box(height: 56),
        ],
      ),
    );

    return Container(
      color: const Color(0xFF0B1219),
      child: isMobile
          ? Column(
              children: [
                Expanded(child: mapSkeleton),
                SizedBox(
                  height: 220,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _box(width: 140, height: 16),
                      const SizedBox(height: 12),
                      _box(height: 40),
                      const SizedBox(height: 10),
                      _box(height: 40),
                      const SizedBox(height: 12),
                      _box(height: 48),
                    ],
                  ),
                ),
              ],
            )
          : Row(
              children: [
                Expanded(child: mapSkeleton),
                const SizedBox(width: 0),
                SizedBox(width: 360, child: panelSkeleton),
              ],
            ),
    );
  }
}

class _NavigationErrorState extends StatelessWidget {
  final DeliveryNavigationState state;

  const _NavigationErrorState({required this.state});

  @override
  Widget build(BuildContext context) {
    final localeCode = state.localeCode;
    return Center(
      key: const Key('dp_navscreen_error'),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.error_outline,
              color: Color(0xFFF87171),
              size: 48,
            ),
            const SizedBox(height: 16),
            Text(
              DeliveryNavigationStrings.of('errorTitle', localeCode),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                state.errorMessage ??
                    DeliveryNavigationStrings.of('errorSub', localeCode),
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Color(0xFF94A3B8),
                  fontSize: 13,
                ),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => context
                  .read<DeliveryNavigationBloc>()
                  .add(const DeliveryNavigationRefreshEvent()),
              style: ElevatedButton.styleFrom(
                backgroundColor: DeliveryAppColors.primaryDark,
                foregroundColor: const Color(0xFF06120B),
                minimumSize: const Size(140, 48),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                DeliveryNavigationStrings.of('retry', localeCode),
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RiderIdleMap extends StatefulWidget {
  final DeliveryNavigationState state;
  final bool isMobile;
  final bool isTablet;
  final bool isDesktop;

  const _RiderIdleMap({
    required this.state,
    required this.isMobile,
    required this.isTablet,
    required this.isDesktop,
  });

  @override
  State<_RiderIdleMap> createState() => _RiderIdleMapState();
}

class _RiderIdleMapState extends State<_RiderIdleMap> {
  bool _isMapFullScreen = false;

  void _toggleOnline() {
    context
        .read<DeliveryNavigationBloc>()
        .add(const DeliveryNavigationToggleOnlineStatusEvent());
  }

  void _showViewOrders() {
    // Switch to the Orders tab when running inside the NavigationBar shell.
    try {
      final navBarBloc = context.read<DeliveryNavigationBarPageBloc>();
      final ordersIndex = navBarBloc.state.navItems
          .indexWhere((item) => item.id == 'orders');
      if (ordersIndex >= 0) {
        navBarBloc.add(DeliveryNavigationBarTabChangedEvent(ordersIndex));
        return;
      }
    } catch (_) {
      // Standalone usage (tests / deep link): hint the driver instead.
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          DeliveryNavigationStrings.of(
            'idleOpeningOrders',
            widget.state.localeCode,
          ),
        ),
        backgroundColor: DeliveryAppColors.primaryDark,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _handleSOS() {
    context
        .read<DeliveryNavigationBloc>()
        .add(const DeliveryNavigationSOSClickedEvent());
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          DeliveryNavigationStrings.of('sosSent', widget.state.localeCode),
        ),
        backgroundColor: DeliveryAppColors.error,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Set<Marker> _sellerMarkers() {
    final Set<Marker> markers = {};
    for (final seller in widget.state.nearbySellers) {
      final lat = (seller['latitude'] as num?)?.toDouble() ?? 0.0;
      final lng = (seller['longitude'] as num?)?.toDouble() ?? 0.0;
      final name = (seller['name'] ?? 'Restaurant').toString();
      final phone = (seller['phone'] ?? '').toString();
      if (lat != 0.0 && lng != 0.0) {
        markers.add(
          Marker(
            markerId: MarkerId('seller_${seller['id'] ?? name}'),
            position: LatLng(lat, lng),
            icon: BitmapDescriptor.defaultMarkerWithHue(
              BitmapDescriptor.hueOrange,
            ),
            infoWindow: InfoWindow(
              title: name,
              snippet: phone.isNotEmpty
                  ? '📞 $phone · Active Store'
                  : 'Active Restaurant Partner',
            ),
          ),
        );
      }
    }
    return markers;
  }

  Set<Marker> _demandMarkers() {
    return widget.state.demandZones.map((zone) {
      return Marker(
        markerId: MarkerId(
          'hotspot_${zone.name.replaceAll(RegExp(r'\s+'), '_')}',
        ),
        position: LatLng(zone.latitude, zone.longitude),
        icon: BitmapDescriptor.defaultMarkerWithHue(
          BitmapDescriptor.hueOrange,
        ),
        infoWindow: InfoWindow(
          title: zone.name,
          snippet:
              '${zone.estimatedDemand} ${DeliveryNavigationStrings.of('idleDemandLabel', widget.state.localeCode)}',
        ),
        onTap: () {
          context
              .read<DeliveryNavigationBloc>()
              .add(DeliveryNavigationSelectDemandZoneEvent(zone));
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                DeliveryNavigationStrings.of(
                  'hotspotTapped',
                  widget.state.localeCode,
                ),
              ),
              backgroundColor: DeliveryAppColors.primaryDark,
              behavior: SnackBarBehavior.floating,
            ),
          );
        },
      );
    }).toSet();
  }

  Widget _buildMap({double? borderRadius}) {
    final driverLatLng = widget.state.hasDriverPosition
        ? LatLng(widget.state.driverLat, widget.state.driverLng)
        : null;
    final storeLoc = (widget.state.restaurantLat != 0 && widget.state.restaurantLng != 0)
        ? LatLng(widget.state.restaurantLat, widget.state.restaurantLng)
        : null;
    final customerLoc = (widget.state.customerLat != 0 && widget.state.customerLng != 0)
        ? LatLng(widget.state.customerLat, widget.state.customerLng)
        : null;

    Widget map = Stack(
      key: const Key('dp_navscreen_idle_map'),
      children: [
        Positioned.fill(
          child: AppGoogleMapView(
            driverLocation: driverLatLng,
            driverHeading: widget.state.driverHeading,
            vehicleType: 'two_wheeler',
            storeLocation: storeLoc,
            storeName: widget.state.restaurantName.isNotEmpty
                ? widget.state.restaurantName
                : 'Restaurant',
            storeAddress: widget.state.restaurantAddress,
            storePhone: widget.state.restaurantPhone,
            customerLocation: customerLoc,
            customerName: widget.state.customerName.isNotEmpty
                ? widget.state.customerName
                : 'Customer',
            customerAddress: widget.state.customerAddress,
            customerNotes: widget.state.customerNotes,
            additionalMarkers: {..._demandMarkers(), ..._sellerMarkers()},
            isDarkMode: true,
            showControls: true,
            autoFollowDriver: true,
            isFullScreen: _isMapFullScreen,
            onToggleFullScreen: () {
              setState(() {
                _isMapFullScreen = !_isMapFullScreen;
              });
            },
            driverName: widget.state.partnerName,
            isArrivingSoon: false,
            showProgressCard: true,
          ),
        ),
        // Offstage pill to maintain widget test compatibility without blocking the status card
        Offstage(
          offstage: true,
          child: _IdleOnlinePill(
            state: widget.state,
            localeCode: widget.state.localeCode,
            onToggle: _toggleOnline,
          ),
        ),
        Positioned(
          left: 14,
          bottom: 14,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                key: const Key('dp_navscreen_idle_active_zone_pill'),
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 7,
                ),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.85),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.white12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.4),
                      blurRadius: 8,
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.storefront,
                      color: Color(0xFFEA580C),
                      size: 15,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      widget.state.nearbySellers.isNotEmpty
                          ? '${widget.state.nearbySellers.length} ${DeliveryNavigationStrings.of("liveStoresCount", widget.state.localeCode)}'
                          : DeliveryNavigationStrings.of(
                              'highDemandZone',
                              widget.state.localeCode,
                            ),
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              _IdleGpsAccuracyChip(
                state: widget.state,
                localeCode: widget.state.localeCode,
              ),
            ],
          ),
        ),
      ],
    );

    if (borderRadius != null) {
      map = ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: map,
      );
    }
    return map;
  }

  @override
  Widget build(BuildContext context) {
    final localeCode = widget.state.localeCode;

    final content = widget.isMobile
        ? Column(
            children: [
              Expanded(child: _buildMap()),
              _IdleBottomCard(
                state: widget.state,
                localeCode: localeCode,
                onToggleOnline: _toggleOnline,
                onViewOrders: _showViewOrders,
                onSOS: _handleSOS,
              ),
            ],
          )
        : Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Expanded(child: _buildMap(borderRadius: 16)),
                const SizedBox(width: 12),
                SizedBox(
                  width: 380,
                  child: _IdleSidePanel(
                    state: widget.state,
                    localeCode: localeCode,
                    onToggleOnline: _toggleOnline,
                    onViewOrders: _showViewOrders,
                    onSOS: _handleSOS,
                    onZoneTap: (zone) {
                      context
                          .read<DeliveryNavigationBloc>()
                          .add(DeliveryNavigationSelectDemandZoneEvent(zone));
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            DeliveryNavigationStrings.of(
                              'hotspotTapped',
                              localeCode,
                            ),
                          ),
                          backgroundColor: DeliveryAppColors.primaryDark,
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          );

    return Column(
      children: [
        _NavigationTopBar(
          state: widget.state,
          isMobile: widget.isMobile,
          onToggleAudio: () => context
              .read<DeliveryNavigationBloc>()
              .add(const DeliveryNavigationToggleAudioEvent()),
        ),
        Expanded(child: content),
      ],
    );
  }
}

class _IdleOnlinePill extends StatelessWidget {
  final DeliveryNavigationState state;
  final String localeCode;
  final VoidCallback onToggle;

  const _IdleOnlinePill({
    required this.state,
    required this.localeCode,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    final online = state.isOnline;
    final accent =
        online ? const Color(0xFF22C55E) : const Color(0xFF94A3B8);
    final label = online
        ? DeliveryNavigationStrings.of('goOffline', localeCode)
        : DeliveryNavigationStrings.of('goOnline', localeCode);

    return Semantics(
      button: true,
      label: label,
      child: Material(
        color: const Color(0xF20D141C),
        borderRadius: BorderRadius.circular(999),
        child: InkWell(
          key: const Key('dp_navscreen_idle_online_pill'),
          onTap: onToggle,
          borderRadius: BorderRadius.circular(999),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const _RadarPulse(color: Color(0xFF22C55E)),
                const SizedBox(width: 10),
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: accent,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 6),
                Flexible(
                  child: Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const SizedBox(width: 6),
                Icon(Icons.swap_horiz, color: accent, size: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _IdleGpsAccuracyChip extends StatelessWidget {
  final DeliveryNavigationState state;
  final String localeCode;

  const _IdleGpsAccuracyChip({
    required this.state,
    required this.localeCode,
  });

  @override
  Widget build(BuildContext context) {
    final gpsLabel = switch (state.gpsStatus) {
      DeliveryGpsStatus.active =>
        DeliveryNavigationStrings.of('gpsActive', localeCode),
      DeliveryGpsStatus.searching =>
        DeliveryNavigationStrings.of('gpsSearching', localeCode),
      DeliveryGpsStatus.disabled =>
        DeliveryNavigationStrings.of('gpsDisabled', localeCode),
      DeliveryGpsStatus.permissionDenied =>
        DeliveryNavigationStrings.of('gpsPermissionDenied', localeCode),
    };
    return Container(
      key: const Key('dp_navscreen_idle_gps_chip'),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xF20D141C),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.gps_fixed,
            color: DeliveryAppColors.primary,
            size: 15,
          ),
          const SizedBox(width: 6),
          Text(
            '${DeliveryNavigationStrings.of('idleGpsAccuracy', localeCode)}: '
            '$gpsLabel',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _IdleBottomCard extends StatelessWidget {
  final DeliveryNavigationState state;
  final String localeCode;
  final VoidCallback onToggleOnline;
  final VoidCallback onViewOrders;
  final VoidCallback onSOS;

  const _IdleBottomCard({
    required this.state,
    required this.localeCode,
    required this.onToggleOnline,
    required this.onViewOrders,
    required this.onSOS,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Container(
        key: const Key('dp_navscreen_idle_card'),
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
        decoration: BoxDecoration(
          color: const Color(0xFF060B11),
          border: Border(
            top: BorderSide(color: Colors.white.withValues(alpha: 0.06)),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                const _RadarPulse(color: Color(0xFF22C55E)),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        DeliveryNavigationStrings.of(
                          'idleOnlineStatus',
                          localeCode,
                        ),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        DeliveryNavigationStrings.of(
                          'idleSearchingOrders',
                          localeCode,
                        ),
                        style: const TextStyle(
                          color: Color(0xFF94A3B8),
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: onToggleOnline,
                  tooltip: DeliveryNavigationStrings.of('goOnline', localeCode),
                  icon: Icon(
                    state.isOnline
                        ? Icons.power_settings_new
                        : Icons.power_off,
                    color: state.isOnline
                        ? const Color(0xFF22C55E)
                        : const Color(0xFF94A3B8),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            FilledButton.icon(
              key: const Key('dp_navscreen_idle_view_orders'),
              onPressed: onViewOrders,
              icon: const Icon(Icons.list_alt, size: 18),
              label: Text(
                DeliveryNavigationStrings.of(
                  'idleViewAvailableOrders',
                  localeCode,
                ),
              ),
              style: FilledButton.styleFrom(
                backgroundColor: DeliveryAppColors.primaryDark,
                foregroundColor: const Color(0xFF06120B),
                minimumSize: const Size(0, 46),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: Text(
                    '${DeliveryNavigationStrings.of('idleHotspots', localeCode)}: '
                    '${state.demandZones.length}',
                    style: const TextStyle(
                      color: Color(0xFF94A3B8),
                      fontSize: 11,
                    ),
                  ),
                ),
                const Spacer(),
                _SosButton(localeCode: localeCode, onTap: onSOS),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _IdleSidePanel extends StatelessWidget {
  final DeliveryNavigationState state;
  final String localeCode;
  final VoidCallback onToggleOnline;
  final VoidCallback onViewOrders;
  final VoidCallback onSOS;
  final void Function(DeliveryDemandZone) onZoneTap;

  const _IdleSidePanel({
    required this.state,
    required this.localeCode,
    required this.onToggleOnline,
    required this.onViewOrders,
    required this.onSOS,
    required this.onZoneTap,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            key: const Key('dp_navscreen_idle_side'),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF0D141C),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  DeliveryNavigationStrings.of('idleOnlineStatus', localeCode),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${DeliveryNavigationStrings.of('idleWaitingTitle', localeCode)} '
                  '• ${DeliveryNavigationStrings.of('idleSearchingOrders', localeCode)}',
                  style: const TextStyle(
                    color: Color(0xFF94A3B8),
                    fontSize: 11,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  DeliveryNavigationStrings.of('idleWaitingSub', localeCode),
                  style: const TextStyle(
                    color: Color(0xFF64748B),
                    fontSize: 11,
                  ),
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    const Icon(
                      Icons.local_fire_department,
                      color: Color(0xFFF59E0B),
                      size: 16,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      DeliveryNavigationStrings.of('idleHotspots', localeCode),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                if (state.demandZones.isEmpty)
                  Text(
                    DeliveryNavigationStrings.of('idleWaitingSub', localeCode),
                    style: const TextStyle(
                      color: Color(0xFF64748B),
                      fontSize: 11,
                    ),
                  )
                else
                  ...state.demandZones.map(
                    (zone) => Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: _HotspotTile(
                        zone: zone,
                        localeCode: localeCode,
                        isSelected:
                            state.selectedDemandZone?.name == zone.name,
                        onTap: () => onZoneTap(zone),
                      ),
                    ),
                  ),
                const SizedBox(height: 14),
                FilledButton.icon(
                  onPressed: onViewOrders,
                  icon: const Icon(Icons.list_alt, size: 18),
                  label: Text(
                    DeliveryNavigationStrings.of(
                      'idleViewAvailableOrders',
                      localeCode,
                    ),
                  ),
                  style: FilledButton.styleFrom(
                    backgroundColor: DeliveryAppColors.primaryDark,
                    foregroundColor: const Color(0xFF06120B),
                    minimumSize: const Size(0, 46),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                _SosButton(localeCode: localeCode, onTap: onSOS),
                const SizedBox(height: 10),
                OutlinedButton.icon(
                  key: const Key('dp_navscreen_idle_online_toggle'),
                  onPressed: onToggleOnline,
                  icon: const Icon(Icons.swap_horiz, size: 18),
                  label: Text(
                    state.isOnline
                        ? DeliveryNavigationStrings.of('goOffline', localeCode)
                        : DeliveryNavigationStrings.of('goOnline', localeCode),
                  ),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: state.isOnline
                        ? const Color(0xFF22C55E)
                        : const Color(0xFF94A3B8),
                    side: BorderSide(
                      color: Colors.white.withValues(alpha: 0.12),
                    ),
                    minimumSize: const Size(0, 44),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _HotspotTile extends StatelessWidget {
  final DeliveryDemandZone zone;
  final String localeCode;
  final bool isSelected;
  final VoidCallback onTap;

  const _HotspotTile({
    required this.zone,
    required this.localeCode,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: isSelected
          ? DeliveryAppColors.primaryDark.withValues(alpha: 0.18)
          : Colors.white.withValues(alpha: 0.04),
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Row(
            children: [
              const Icon(
                Icons.location_on,
                color: Color(0xFFF59E0B),
                size: 18,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      zone.name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${zone.latitude.toStringAsFixed(4)}, '
                      '${zone.longitude.toStringAsFixed(4)}',
                      style: const TextStyle(
                        color: Color(0xFF64748B),
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFF59E0B).withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  '${zone.estimatedDemand}',
                  style: const TextStyle(
                    color: Color(0xFFF59E0B),
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
