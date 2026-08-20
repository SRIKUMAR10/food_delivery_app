import 'dart:async';
import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

/// Service responsible for generating and caching high-resolution custom
/// BitmapDescriptor markers for Google Maps (two-wheelers, four-wheelers, store, customer).
class MapMarkerService {
  MapMarkerService._();
  static final MapMarkerService instance = MapMarkerService._();

  final Map<String, BitmapDescriptor> _markerCache = {};

  /// Vehicle category helper
  static bool isTwoWheeler(String? vehicleType) {
    if (vehicleType == null || vehicleType.isEmpty) return true;
    final vt = vehicleType.toLowerCase().trim();
    return vt.contains('bike') ||
        vt.contains('scooter') ||
        vt.contains('two') ||
        vt.contains('motor') ||
        vt == '2w' ||
        vt == '2_wheeler';
  }

  /// Vehicle category helper for 4-wheelers
  static bool isFourWheeler(String? vehicleType) {
    if (vehicleType == null || vehicleType.isEmpty) return false;
    final vt = vehicleType.toLowerCase().trim();
    return vt.contains('car') ||
        vt.contains('auto') ||
        vt.contains('van') ||
        vt.contains('four') ||
        vt == '4w' ||
        vt == '4_wheeler' ||
        vt.contains('truck');
  }

  /// Retrieves or creates an animated vehicle marker for Google Maps
  Future<BitmapDescriptor> getVehicleMarker({
    String? vehicleType,
    double heading = 0.0,
    Color primaryColor = const Color(0xFFE52121),
    double size = 110.0,
  }) async {
    final bool twoWheeler = isTwoWheeler(vehicleType);
    // Quantize heading to 5-degree increments to maximize cache hits
    final int roundedHeading = ((heading % 360) / 5).round() * 5;
    final String cacheKey =
        'vehicle_${twoWheeler ? "2w" : "4w"}_${primaryColor.toARGB32()}_${size.toInt()}_$roundedHeading';

    if (_markerCache.containsKey(cacheKey)) {
      return _markerCache[cacheKey]!;
    }

    final Uint8List bytes = await _generateVehicleMarkerBytes(
      isTwoWheeler: twoWheeler,
      heading: roundedHeading.toDouble(),
      primaryColor: primaryColor,
      size: size,
    );

    final BitmapDescriptor descriptor = BitmapDescriptor.bytes(
      bytes,
      imagePixelRatio: 2.0,
    );
    _markerCache[cacheKey] = descriptor;
    return descriptor;
  }

  /// Retrieves or creates a custom Restaurant/Store pin marker
  Future<BitmapDescriptor> getStoreMarker({
    Color color = const Color(0xFFE52121),
    double size = 96.0,
  }) async {
    final String cacheKey = 'store_${color.toARGB32()}_${size.toInt()}';
    if (_markerCache.containsKey(cacheKey)) {
      return _markerCache[cacheKey]!;
    }

    final Uint8List bytes = await _generatePinMarkerBytes(
      icon: Icons.storefront_rounded,
      badgeColor: color,
      label: 'Store',
      size: size,
    );

    final BitmapDescriptor descriptor = BitmapDescriptor.bytes(
      bytes,
      imagePixelRatio: 2.0,
    );
    _markerCache[cacheKey] = descriptor;
    return descriptor;
  }

  /// Retrieves or creates a custom Customer/Dropoff pin marker
  Future<BitmapDescriptor> getCustomerMarker({
    Color color = const Color(0xFF10B981),
    double size = 96.0,
  }) async {
    final String cacheKey = 'customer_${color.toARGB32()}_${size.toInt()}';
    if (_markerCache.containsKey(cacheKey)) {
      return _markerCache[cacheKey]!;
    }

    final Uint8List bytes = await _generatePinMarkerBytes(
      icon: Icons.home_rounded,
      badgeColor: color,
      label: 'Drop',
      size: size,
    );

    final BitmapDescriptor descriptor = BitmapDescriptor.bytes(
      bytes,
      imagePixelRatio: 2.0,
    );
    _markerCache[cacheKey] = descriptor;
    return descriptor;
  }

  /// Clears in-memory marker cache
  void clearCache() {
    _markerCache.clear();
  }

  // ───────────────────────────────────────────────────────────────────────────
  // Custom Canvas Rendering Engines
  // ───────────────────────────────────────────────────────────────────────────

  Future<Uint8List> _generateVehicleMarkerBytes({
    required bool isTwoWheeler,
    required double heading,
    required Color primaryColor,
    required double size,
  }) async {
    final ui.PictureRecorder recorder = ui.PictureRecorder();
    final Canvas canvas = Canvas(recorder);
    final double radius = size / 2;
    final Offset center = Offset(radius, radius);

    // 1. Soft Outer Pulse Glow
    final Paint glowPaint = Paint()
      ..color = primaryColor.withValues(alpha: 0.22)
      ..maskFilter = const ui.MaskFilter.blur(ui.BlurStyle.normal, 8);
    canvas.drawCircle(center, radius - 6, glowPaint);

    // 2. Translucent Pulse Ring
    final Paint pulseRingPaint = Paint()
      ..color = primaryColor.withValues(alpha: 0.35)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0;
    canvas.drawCircle(center, radius - 8, pulseRingPaint);

    // 3. Crisp White Background Disk
    final Paint diskPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    final Paint diskBorderPaint = Paint()
      ..color = primaryColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4.0;

    canvas.drawCircle(center, radius - 16, diskPaint);
    canvas.drawCircle(center, radius - 16, diskBorderPaint);

    // 4. Directional Heading Indicator (Pointer Arrow)
    final double rad = (heading - 90) * (math.pi / 180.0);
    final Offset pointerTip = Offset(
      center.dx + (radius - 8) * math.cos(rad),
      center.dy + (radius - 8) * math.sin(rad),
    );
    final Offset pointerBaseLeft = Offset(
      center.dx + (radius - 18) * math.cos(rad - 0.35),
      center.dy + (radius - 18) * math.sin(rad - 0.35),
    );
    final Offset pointerBaseRight = Offset(
      center.dx + (radius - 18) * math.cos(rad + 0.35),
      center.dy + (radius - 18) * math.sin(rad + 0.35),
    );

    final Path pointerPath = Path()
      ..moveTo(pointerTip.dx, pointerTip.dy)
      ..lineTo(pointerBaseLeft.dx, pointerBaseLeft.dy)
      ..lineTo(center.dx + (radius - 20) * math.cos(rad), center.dy + (radius - 20) * math.sin(rad))
      ..lineTo(pointerBaseRight.dx, pointerBaseRight.dy)
      ..close();

    final Paint pointerPaint = Paint()
      ..color = primaryColor
      ..style = PaintingStyle.fill;
    canvas.drawPath(pointerPath, pointerPaint);

    // 5. Draw Vehicle Icon (Bike vs Car)
    final TextPainter textPainter = TextPainter(
      textDirection: TextDirection.ltr,
    );

    final IconData vehicleIcon = isTwoWheeler
        ? Icons.two_wheeler_rounded
        : Icons.directions_car_filled_rounded;

    textPainter.text = TextSpan(
      text: String.fromCharCode(vehicleIcon.codePoint),
      style: TextStyle(
        fontSize: size * 0.36,
        fontFamily: vehicleIcon.fontFamily,
        package: vehicleIcon.fontPackage,
        color: primaryColor,
        fontWeight: FontWeight.w900,
      ),
    );
    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset(
        center.dx - (textPainter.width / 2),
        center.dy - (textPainter.height / 2),
      ),
    );

    // 6. Finalize Bitmap
    final ui.Picture picture = recorder.endRecording();
    final ui.Image image = await picture.toImage(size.toInt(), size.toInt());
    final ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    return byteData!.buffer.asUint8List();
  }

  Future<Uint8List> _generatePinMarkerBytes({
    required IconData icon,
    required Color badgeColor,
    required String label,
    required double size,
  }) async {
    final ui.PictureRecorder recorder = ui.PictureRecorder();
    final Canvas canvas = Canvas(recorder);
    final double width = size;
    final double height = size * 1.25;

    // Pin shape path
    final Path pinPath = Path();
    final double radius = width * 0.40;
    final Offset circleCenter = Offset(width / 2, radius + 4);

    pinPath.addArc(
      Rect.fromCircle(center: circleCenter, radius: radius),
      math.pi * 0.75,
      math.pi * 1.5,
    );
    pinPath.lineTo(width / 2, height - 6);
    pinPath.close();

    // Pin Shadow
    final Paint shadowPaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.25)
      ..maskFilter = const ui.MaskFilter.blur(ui.BlurStyle.normal, 5);
    canvas.drawOval(
      Rect.fromCenter(center: Offset(width / 2, height - 4), width: width * 0.45, height: 8),
      shadowPaint,
    );

    // Pin Body Fill
    final Paint pinPaint = Paint()
      ..color = badgeColor
      ..style = PaintingStyle.fill;
    canvas.drawPath(pinPath, pinPaint);

    // Pin Body Border
    final Paint pinBorderPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0;
    canvas.drawPath(pinPath, pinBorderPaint);

    // Inner White Disk
    final Paint innerDisk = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    canvas.drawCircle(circleCenter, radius * 0.65, innerDisk);

    // Icon Inside Pin
    final TextPainter textPainter = TextPainter(
      textDirection: TextDirection.ltr,
    );
    textPainter.text = TextSpan(
      text: String.fromCharCode(icon.codePoint),
      style: TextStyle(
        fontSize: radius * 0.85,
        fontFamily: icon.fontFamily,
        package: icon.fontPackage,
        color: badgeColor,
        fontWeight: FontWeight.bold,
      ),
    );
    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset(
        circleCenter.dx - (textPainter.width / 2),
        circleCenter.dy - (textPainter.height / 2),
      ),
    );

    final ui.Picture picture = recorder.endRecording();
    final ui.Image image = await picture.toImage(width.toInt(), height.toInt());
    final ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    return byteData!.buffer.asUint8List();
  }
}
