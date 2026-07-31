import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'Delivery_Navigation Screen_page_bloc.dart';
import 'Delivery_Navigation Screen_page_event.dart';
import 'Delivery_Navigation Screen_page_repository.dart';
import 'Delivery_Navigation Screen_page_service.dart';
import 'Delivery_Navigation Screen_page_state.dart';

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
      'errorSub':
          'We could not load your navigation. Please try again.',
      'emptyTitle': 'No Active Delivery',
      'emptySub':
          'You have no active delivery to navigate to right now.',
      'offlineBanner':
          'You are offline. Live navigation may be limited.',
      'orderId': 'Order',
      'mapSemantics': 'Live navigation map',
      'currentLocationSemantics': 'Current location',
      'darkThemeActive': 'Dark theme active',
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

class DeliveryNavigationScreenPage extends StatelessWidget {
  final DeliveryNavigationRepositoryBase? repository;
  final DeliveryNavigationServiceBase? service;
  final DeliveryNavigationBloc? bloc;

  const DeliveryNavigationScreenPage({
    super.key,
    this.repository,
    this.service,
    this.bloc,
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
      )..add(const DeliveryNavigationInitEvent()),
      child: const DeliveryNavigationScreenPageView(),
    );
  }
}

class DeliveryNavigationScreenPageView extends StatelessWidget {
  const DeliveryNavigationScreenPageView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<DeliveryNavigationBloc, DeliveryNavigationState>(
      listener: (context, state) {
        if (state.status == DeliveryNavigationStatus.error &&
            state.errorMessage != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.errorMessage!),
              backgroundColor: const Color(0xFFB3261E),
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
              DeliveryNavigationStatus.empty => _NavigationEmptyState(
                  state: state,
                ),
              DeliveryNavigationStatus.loaded ||
              DeliveryNavigationStatus.navigating =>
                _NavigationDashboard(
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

class _NavigationDashboard extends StatelessWidget {
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

  void _handleSOS(BuildContext context, String localeCode) {
    context
        .read<DeliveryNavigationBloc>()
        .add(const DeliveryNavigationSOSClickedEvent());
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(DeliveryNavigationStrings.of('sosSent', localeCode)),
        backgroundColor: const Color(0xFFB3261E),
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
        backgroundColor: const Color(0xFF00C853),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final localeCode = state.localeCode;
    return Column(
      children: [
        _NavigationTopBar(
          state: state,
          isMobile: isMobile,
          onToggleAudio: () => context
              .read<DeliveryNavigationBloc>()
              .add(const DeliveryNavigationToggleAudioEvent()),
        ),
        Expanded(
          child: isMobile
              ? Column(
                  children: [
                    Visibility(
                      visible: state.showMap,
                      child: SizedBox(
                        height: 320,
                        child: _MapArea(state: state),
                      ),
                    ),
                    if (state.showMap) const SizedBox(height: 8),
                    Expanded(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        child: Column(
                          children: [
                            _OrderSummaryPanel(
                              state: state,
                              localeCode: localeCode,
                              physics: const NeverScrollableScrollPhysics(),
                              onContactCustomer: () =>
                                  _showContactSnackBar(context, localeCode),
                            ),
                            const SizedBox(height: 12),
                            SizedBox(
                              width: double.infinity,
                              child: _PrimaryNavButton(
                                isNavigating: state.isNavigating,
                                localeCode: localeCode,
                                onTap: () => context
                                    .read<DeliveryNavigationBloc>()
                                    .add(const DeliveryNavigationStartNavigationEvent()),
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
                              child: _CurrentLocationBadge(localeCode: localeCode),
                            ),
                            const SizedBox(height: 12),
                          ],
                        ),
                      ),
                    ),
                  ],
                )
              : Padding(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    children: [
                      if (state.showMap) ...[
                        Expanded(child: _MapArea(state: state)),
                        const SizedBox(width: 12),
                      ],
                      state.showMap
                          ? SizedBox(
                              width: 360,
                              child: _OrderSummaryPanel(
                                state: state,
                                localeCode: localeCode,
                                onContactCustomer: () =>
                                    _showContactSnackBar(context, localeCode),
                              ),
                            )
                          : Expanded(
                              child: _OrderSummaryPanel(
                                state: state,
                                localeCode: localeCode,
                                onContactCustomer: () =>
                                    _showContactSnackBar(context, localeCode),
                              ),
                            ),
                    ],
                  ),
                ),
        ),
        if (!isMobile)
          _BottomControlBar(
            state: state,
            localeCode: localeCode,
            onSOS: () => _handleSOS(context, localeCode),
            onPrimaryAction: () => context
                .read<DeliveryNavigationBloc>()
                .add(const DeliveryNavigationStartNavigationEvent()),
            onExit: () => context
                .read<DeliveryNavigationBloc>()
                .add(const DeliveryNavigationExitNavigationEvent()),
          ),
      ],
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
                colors: [Color(0xFF00E676), Color(0xFF00C853)],
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
                  backgroundColor: const Color(0xFF00C853),
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
                  ? const Color(0xFF00E676)
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
                  ? const Color(0xFF00E676)
                  : const Color(0xFF94A3B8),
              size: 22,
            ),
            onPressed: onToggleAudio,
          ),
          if (!isMobile) ...[
            const SizedBox(width: 4),
            const _PartnerBadge(),
          ],
        ],
      ),
    );
  }
}

class _PartnerBadge extends StatelessWidget {
  const _PartnerBadge();

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Dinesh Kumar - Delivery Partner',
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
            const CircleAvatar(
              radius: 14,
              backgroundColor: Color(0xFF1A2530),
              child: Icon(
                Icons.person,
                color: Color(0xFF94A3B8),
                size: 16,
              ),
            ),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Dinesh Kumar',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  DeliveryNavigationStrings.of(
                    'deliveryPartnerRole',
                    'en',
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

  const _MapArea({required this.state});

  @override
  State<_MapArea> createState() => _MapAreaState();
}

class _MapAreaState extends State<_MapArea> {
  double _zoom = 15.0;

  void _zoomIn() {
    setState(() => _zoom = (_zoom + 1).clamp(11.0, 19.0));
  }

  void _zoomOut() {
    setState(() => _zoom = (_zoom - 1).clamp(11.0, 19.0));
  }

  void _recenter(BuildContext context) {
    setState(() => _zoom = 15.0);
    context
        .read<DeliveryNavigationBloc>()
        .add(const DeliveryNavigationRecenterMapEvent());
  }

  @override
  Widget build(BuildContext context) {
    final localeCode = widget.state.localeCode;
    return LayoutBuilder(
      builder: (context, constraints) {
        final w = constraints.maxWidth;
        final h = constraints.maxHeight;
        return Semantics(
          label: DeliveryNavigationStrings.of('mapSemantics', localeCode),
          image: true,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Stack(
              key: const Key('dp_navscreen_map'),
              children: [
                Positioned.fill(
                  child: CustomPaint(
                    painter: _NavigationMapCanvas(state: widget.state),
                  ),
                ),
                Positioned(
                  top: 14,
                  left: 14,
                  right: 14,
                  child: _TurnByTurnCard(state: widget.state),
                ),
                Positioned(
                  left: w * _MapCoords.pickupX - 18,
                  top: h * _MapCoords.pickupY - 18,
                  child: const _MapMarker(
                    key: Key('dp_navscreen_pickup_marker'),
                    icon: Icons.location_on,
                    color: Color(0xFFEF4444),
                    label: 'Pickup',
                  ),
                ),
                Positioned(
                  left: w * _MapCoords.dropX - 18,
                  top: h * _MapCoords.dropY - 18,
                  child: const _MapMarker(
                    key: Key('dp_navscreen_drop_marker'),
                    icon: Icons.sports_score,
                    color: Color(0xFF00C853),
                    label: 'Drop',
                  ),
                ),
                Positioned(
                  left: w * _MapCoords.currentX - 12,
                  top: h * _MapCoords.currentY - 12,
                  child: _CurrentLocationMarker(
                    label: DeliveryNavigationStrings.of(
                      'currentLocationSemantics',
                      localeCode,
                    ),
                  ),
                ),
                Positioned(
                  right: 14,
                  bottom: 14,
                  child: _MapControls(
                    onZoomIn: _zoomIn,
                    onZoomOut: _zoomOut,
                    onRecenter: () => _recenter(context),
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

  _NavigationMapCanvas({required this.state});

  @override
  void paint(Canvas canvas, Size size) {
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
      ..color = const Color(0xFF00E676).withValues(alpha: 0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 12
      ..strokeCap = StrokeCap.round;
    canvas.drawPath(route, glow);

    final routePaint = Paint()
      ..shader = const LinearGradient(
        colors: [Color(0xFF00E676), Color(0xFF69F0AE)],
      ).createShader(Offset.zero & size)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 5
      ..strokeCap = StrokeCap.round;
    canvas.drawPath(route, routePaint);

    _drawPickupPin(
      canvas,
      Offset(size.width * _MapCoords.pickupX, size.height * _MapCoords.pickupY),
    );
    _drawDropMarker(
      canvas,
      Offset(size.width * _MapCoords.dropX, size.height * _MapCoords.dropY),
    );
    _drawCurrentLocation(
      canvas,
      Offset(
        size.width * _MapCoords.currentX,
        size.height * _MapCoords.currentY,
      ),
    );
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
    final flag = Paint()..color = const Color(0xFF00C853);
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
    canvas.drawPath(triangle, Paint()..color = const Color(0xFF69F0AE));
  }

  void _drawCurrentLocation(Canvas canvas, Offset center) {
    canvas.drawCircle(
      center,
      18,
      Paint()..color = const Color(0xFF2196F3).withValues(alpha: 0.25),
    );
    canvas.drawCircle(center, 12, Paint()..color = Colors.white);
    canvas.drawCircle(center, 8, Paint()..color = const Color(0xFF1E88E5));
  }

  @override
  bool shouldRepaint(_NavigationMapCanvas oldDelegate) =>
      oldDelegate.state != state;
}

class _TurnByTurnCard extends StatelessWidget {
  final DeliveryNavigationState state;

  const _TurnByTurnCard({required this.state});

  @override
  Widget build(BuildContext context) {
    final instruction = state.nextTurnInstruction.toLowerCase();
    final IconData turnIcon = instruction.contains('left')
        ? Icons.turn_left
        : instruction.contains('right')
            ? Icons.turn_right
            : Icons.navigation;

    return Container(
      key: const Key('dp_navscreen_turn_card'),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xF20D141C),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFF00C853).withValues(alpha: 0.3),
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
              color: const Color(0xFF00C853).withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(turnIcon, color: const Color(0xFF00E676), size: 24),
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
                    color: Color(0xFF00E676),
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
              color: const Color(0xFF00C853).withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(999),
            ),
            child: const Text(
              'LIVE',
              style: TextStyle(
                color: Color(0xFF00E676),
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

  const _MapControls({
    required this.onZoomIn,
    required this.onZoomOut,
    required this.onRecenter,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
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

class _CurrentLocationMarker extends StatelessWidget {
  final String label;

  const _CurrentLocationMarker({required this.label});

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: label,
      image: true,
      child: Container(
        width: 24,
        height: 24,
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
              color: const Color(0xFF00C853),
              title: state.order.dropLabel,
              subtitle: state.order.dropAddress,
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _MetricCard(
                    label: DeliveryNavigationStrings.of('eta', localeCode),
                    value: '${state.etaMinutes} min',
                    icon: Icons.timer_outlined,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _MetricCard(
                    label: DeliveryNavigationStrings.of(
                      'distanceLeft',
                      localeCode,
                    ),
                    value: '${state.distanceKm.toStringAsFixed(1)} km',
                    icon: Icons.route_outlined,
                  ),
                ),
              ],
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
                  backgroundColor: const Color(0xFF00C853),
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
        color: const Color(0xFF00C853).withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 7,
            height: 7,
            decoration: const BoxDecoration(
              color: Color(0xFF00E676),
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            status,
            style: const TextStyle(
              color: Color(0xFF00E676),
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
        const Color(0xFF00E676),
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
                  _CurrentLocationBadge(localeCode: localeCode),
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
                  child: _CurrentLocationBadge(localeCode: localeCode),
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
        color: const Color(0xFFB3261E),
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
        ? DeliveryNavigationStrings.of('followRoute', localeCode)
        : DeliveryNavigationStrings.of('startNavigation', localeCode);
    return Semantics(
      button: true,
      label: label,
      child: Container(
        height: 48,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF00E676), Color(0xFF00C853)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF00C853).withValues(alpha: 0.35),
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
  final String localeCode;

  const _CurrentLocationBadge({required this.localeCode});

  @override
  Widget build(BuildContext context) {
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
          const Icon(Icons.my_location, color: Color(0xFF00E676), size: 16),
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
                const Text(
                  'Nungambakkam High Rd, Chennai',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
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
                backgroundColor: const Color(0xFF00C853),
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

class _NavigationEmptyState extends StatelessWidget {
  final DeliveryNavigationState state;

  const _NavigationEmptyState({required this.state});

  @override
  Widget build(BuildContext context) {
    final localeCode = state.localeCode;
    return Center(
      key: const Key('dp_navscreen_empty'),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: const Color(0xFF0D141C),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.inbox_outlined,
                color: Color(0xFF64748B),
                size: 34,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              DeliveryNavigationStrings.of('emptyTitle', localeCode),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              DeliveryNavigationStrings.of('emptySub', localeCode),
              textAlign: TextAlign.center,
              style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 13),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => context
                  .read<DeliveryNavigationBloc>()
                  .add(const DeliveryNavigationRefreshEvent()),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF00C853),
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
