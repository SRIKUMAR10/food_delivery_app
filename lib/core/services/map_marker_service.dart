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
    String storeName = 'Restaurant',
    Color color = const Color(0xFFEA580C),
    double size = 120.0,
  }) async {
    final String shortName = storeName.length > 20 ? '${storeName.substring(0, 18)}..' : storeName;
    final String cacheKey = 'store_${color.toARGB32()}_${size.toInt()}_$shortName';
    if (_markerCache.containsKey(cacheKey)) {
      return _markerCache[cacheKey]!;
    }

    final Uint8List bytes = await _generateStoreMarkerBytes(
      storeName: shortName,
      color: color,
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
    String customerName = 'Customer',
    Color color = const Color(0xFF10B981),
    double size = 120.0,
  }) async {
    final String shortName = customerName.length > 20 ? '${customerName.substring(0, 18)}..' : customerName;
    final String cacheKey = 'customer_${color.toARGB32()}_${size.toInt()}_$shortName';
    if (_markerCache.containsKey(cacheKey)) {
      return _markerCache[cacheKey]!;
    }

    final Uint8List bytes = await _generateCustomerMarkerBytes(
      customerName: shortName,
      color: color,
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
    final double width = size;
    final double height = size * 1.2;
    final Offset center = Offset(width / 2, height / 2);

    canvas.save();
    canvas.translate(center.dx, center.dy);

    if (isTwoWheeler) {
      // 1. Dynamic 3D Volumetric Headlight Light Cone (Front Projection)
      final Path lightBeamPath = Path()
        ..moveTo(0, -18)
        ..lineTo(-26, -60)
        ..lineTo(26, -60)
        ..close();

      final Paint headlightBeamPaint = Paint()
        ..shader = ui.Gradient.linear(
          const Offset(0, -18),
          const Offset(0, -60),
          [
            const Color(0xFFFEF08A).withValues(alpha: 0.5),
            const Color(0xFF38BDF8).withValues(alpha: 0.15),
            Colors.transparent,
          ],
          [0.0, 0.5, 1.0],
        )
        ..style = PaintingStyle.fill;
      canvas.drawPath(lightBeamPath, headlightBeamPaint);

      // 2. Realistic 3D Ground Drop Shadow with Perspective Depth
      final Paint shadowPaint = Paint()
        ..color = Colors.black.withValues(alpha: 0.35)
        ..maskFilter = ui.MaskFilter.blur(ui.BlurStyle.normal, 5.0);
      canvas.drawRRect(
        RRect.fromRectAndRadius(const Rect.fromLTWH(-10, -18, 20, 44), const Radius.circular(10)),
        shadowPaint,
      );

      // 3. 3D Front & Rear Tires with Alloy Rims
      final Paint tirePaint = Paint()..color = const Color(0xFF111827);
      final Paint alloyPaint = Paint()..color = const Color(0xFF94A3B8);
      // Front Tire
      canvas.drawRRect(RRect.fromRectAndRadius(const Rect.fromLTWH(-3.5, -24, 7, 12), const Radius.circular(3.5)), tirePaint);
      canvas.drawRRect(RRect.fromRectAndRadius(const Rect.fromLTWH(-2, -22, 4, 8), const Radius.circular(2)), alloyPaint);
      // Rear Tire
      canvas.drawRRect(RRect.fromRectAndRadius(const Rect.fromLTWH(-4, 14, 8, 14), const Radius.circular(4)), tirePaint);
      canvas.drawRRect(RRect.fromRectAndRadius(const Rect.fromLTWH(-2.5, 16, 5, 10), const Radius.circular(2.5)), alloyPaint);

      // 4. 3D Metallic Chassis & Floorboard
      final Paint chassisPaint = Paint()
        ..shader = ui.Gradient.linear(
          const Offset(-9, 0),
          const Offset(9, 0),
          [
            const Color(0xFF1E293B),
            const Color(0xFF334155),
            const Color(0xFF0F172A),
          ],
          [0.0, 0.5, 1.0],
        );
      canvas.drawRRect(
        RRect.fromRectAndRadius(const Rect.fromLTWH(-8, -14, 16, 30), const Radius.circular(7)),
        chassisPaint,
      );

      // 5. Sporty Aerodynamic Front Fairing / Bodywork (3D Red Gloss)
      final Path frontFairingPath = Path()
        ..moveTo(0, -22)
        ..cubicTo(-9, -19, -10, -11, -8, -5)
        ..lineTo(8, -5)
        ..cubicTo(10, -11, 9, -19, 0, -22)
        ..close();

      final Paint fairingPaint = Paint()
        ..shader = ui.Gradient.linear(
          const Offset(-9, -22),
          const Offset(9, -5),
          [
            const Color(0xFFFF5252),
            const Color(0xFFE52121),
            const Color(0xFF991B1B),
          ],
          [0.0, 0.5, 1.0],
        );
      canvas.drawPath(frontFairingPath, fairingPaint);

      // Bevel Edge on Fairing
      canvas.drawPath(
        frontFairingPath,
        Paint()
          ..color = Colors.white.withValues(alpha: 0.4)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.0,
      );

      // 6. Dual Xenon Crystal Headlights
      final Paint headlightGlow = Paint()
        ..color = Colors.white
        ..maskFilter = ui.MaskFilter.blur(ui.BlurStyle.solid, 2.5);
      canvas.drawCircle(const Offset(-4, -18), 3.0, headlightGlow);
      canvas.drawCircle(const Offset(4, -18), 3.0, headlightGlow);
      canvas.drawCircle(const Offset(-4, -18), 1.8, Paint()..color = const Color(0xFF38BDF8));
      canvas.drawCircle(const Offset(4, -18), 1.8, Paint()..color = const Color(0xFF38BDF8));

      // 7. Handlebars & Dual Chrome Rear-view Mirrors
      final Paint handlebarPaint = Paint()
        ..color = const Color(0xFF0F172A)
        ..strokeWidth = 3.2
        ..strokeCap = StrokeCap.round;
      canvas.drawLine(const Offset(-12, -9), const Offset(12, -9), handlebarPaint);

      // Grip Ends
      canvas.drawCircle(const Offset(-12, -9), 2.2, Paint()..color = const Color(0xFFE52121));
      canvas.drawCircle(const Offset(12, -9), 2.2, Paint()..color = const Color(0xFFE52121));

      // Chrome Stalks & Mirrors with Blue Tint
      canvas.drawLine(const Offset(-7, -10), const Offset(-12, -15), Paint()..color = const Color(0xFF94A3B8)..strokeWidth = 1.6);
      canvas.drawLine(const Offset(7, -10), const Offset(12, -15), Paint()..color = const Color(0xFF94A3B8)..strokeWidth = 1.6);
      canvas.drawOval(const Rect.fromLTWH(-15, -18, 6, 4.5), Paint()..color = const Color(0xFF38BDF8));
      canvas.drawOval(const Rect.fromLTWH(9, -18, 6, 4.5), Paint()..color = const Color(0xFF38BDF8));

      // 8. 3D Delivery Rider Torso & Shoulders
      final Paint riderVestPaint = Paint()
        ..shader = ui.Gradient.linear(
          const Offset(-9, -6),
          const Offset(9, 6),
          [
            const Color(0xFFDC2626),
            const Color(0xFFB91C1C),
            const Color(0xFF7F1D1D),
          ],
          [0.0, 0.5, 1.0],
        );
      canvas.drawRRect(
        RRect.fromRectAndRadius(const Rect.fromLTWH(-8.5, -6, 17, 14), const Radius.circular(5.5)),
        riderVestPaint,
      );

      // Reflective Harness Straps on Rider's Back
      canvas.drawLine(const Offset(-5.5, -5), const Offset(-5.5, 6), Paint()..color = Colors.white.withValues(alpha: 0.85)..strokeWidth = 1.4);
      canvas.drawLine(const Offset(5.5, -5), const Offset(5.5, 6), Paint()..color = Colors.white.withValues(alpha: 0.85)..strokeWidth = 1.4);

      // 9. 3D Rider Aerodynamic Helmet with Metallic Shading & Cyan Reflective Visor
      final Paint helmetPaint = Paint()
        ..shader = ui.Gradient.radial(
          const Offset(-2, -3),
          8.0,
          [
            const Color(0xFF475569),
            const Color(0xFF1E293B),
            const Color(0xFF0F172A),
          ],
          [0.0, 0.5, 1.0],
        );
      canvas.drawCircle(const Offset(0, -1), 6.5, helmetPaint);

      // Helmet Top Gloss Highlight
      canvas.drawArc(
        const Rect.fromLTWH(-5, -6, 10, 10),
        math.pi * 1.1,
        math.pi * 0.8,
        false,
        Paint()..color = Colors.white.withValues(alpha: 0.5)..style = PaintingStyle.stroke..strokeWidth = 1.6,
      );

      // Cyan Reflective Visor
      final Path visorPath = Path()
        ..moveTo(-4.5, -5)
        ..quadraticBezierTo(0, -7.5, 4.5, -5)
        ..lineTo(4.0, -3.5)
        ..quadraticBezierTo(0, -6.0, -4.0, -3.5)
        ..close();

      final Paint visorPaint = Paint()
        ..shader = ui.Gradient.linear(
          const Offset(-4.5, -7),
          const Offset(4.5, -3.5),
          [
            const Color(0xFF0284C7),
            const Color(0xFF38BDF8),
            const Color(0xFFE0F2FE),
          ],
          [0.0, 0.5, 1.0],
        );
      canvas.drawPath(visorPath, visorPaint);

      // 10. 3D Thermal Delivery Box (Isometric Rear Perspective)
      final Paint boxBodyPaint = Paint()
        ..shader = ui.Gradient.linear(
          const Offset(-9, 8),
          const Offset(9, 22),
          [
            const Color(0xFFEF4444),
            const Color(0xFFDC2626),
            const Color(0xFF991B1B),
          ],
          [0.0, 0.5, 1.0],
        );
      canvas.drawRRect(
        RRect.fromRectAndRadius(const Rect.fromLTWH(-9, 8, 18, 14), const Radius.circular(3.5)),
        boxBodyPaint,
      );

      // Box Top Lid Bevel Highlight
      canvas.drawRRect(
        RRect.fromRectAndRadius(const Rect.fromLTWH(-8, 8.5, 16, 4.5), const Radius.circular(2)),
        Paint()..color = const Color(0xFFFCA5A5).withValues(alpha: 0.7),
      );

      // Silver Reflective Center Band
      canvas.drawRRect(
        RRect.fromRectAndRadius(const Rect.fromLTWH(-9, 14.5, 18, 3.2), const Radius.circular(0.8)),
        Paint()..color = Colors.white.withValues(alpha: 0.95),
      );
      canvas.drawCircle(const Offset(0, 16.1), 1.6, Paint()..color = const Color(0xFFE52121));

      // 11. Ruby LED Taillight Bar & Chrome Exhaust
      final Paint taillightGlow = Paint()
        ..color = const Color(0xFFFF2222)
        ..maskFilter = ui.MaskFilter.blur(ui.BlurStyle.solid, 3.0);
      canvas.drawRRect(
        RRect.fromRectAndRadius(const Rect.fromLTWH(-5, 21.5, 10, 3), const Radius.circular(1.5)),
        taillightGlow,
      );

      // Chrome Exhaust Pipe on Right Side
      canvas.drawRRect(
        RRect.fromRectAndRadius(const Rect.fromLTWH(8, 10, 3.2, 10), const Radius.circular(1.5)),
        Paint()..color = const Color(0xFF64748B),
      );
      canvas.drawCircle(const Offset(9.6, 20), 1.4, Paint()..color = const Color(0xFFCBD5E1));
    } else {
      // 3D Car
      canvas.drawRRect(
        RRect.fromRectAndRadius(const Rect.fromLTWH(-12, -22, 24, 44), const Radius.circular(7)),
        Paint()..color = const Color(0xFFFBBF24),
      );
    }

    canvas.restore();

    // Finalize Bitmap
    final ui.Picture picture = recorder.endRecording();
    final ui.Image image = await picture.toImage(width.toInt(), height.toInt());
    final ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    return byteData!.buffer.asUint8List();
  }

  Future<Uint8List> _generateStoreMarkerBytes({
    required String storeName,
    required Color color,
    required double size,
  }) async {
    final ui.PictureRecorder recorder = ui.PictureRecorder();
    final Canvas canvas = Canvas(recorder);
    final double width = size * 1.5;
    final double height = size * 1.4;

    // 1. Text Label Badge
    final TextPainter namePainter = TextPainter(
      text: TextSpan(
        text: '🏪 $storeName',
        style: const TextStyle(
          color: Colors.white,
          fontSize: 11,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.2,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();

    final badgeWidth = math.max(namePainter.width + 16, 80.0);
    const badgeHeight = 24.0;
    final badgeRRect = RRect.fromRectAndRadius(
      Rect.fromCenter(center: Offset(width / 2, 14), width: badgeWidth, height: badgeHeight),
      const Radius.circular(12),
    );

    // Badge Shadow & Surface
    canvas.drawRRect(badgeRRect, Paint()..color = Colors.black.withValues(alpha: 0.35)..maskFilter = ui.MaskFilter.blur(ui.BlurStyle.normal, 4));
    canvas.drawRRect(badgeRRect, Paint()..color = const Color(0xFF0F172A).withValues(alpha: 0.95));
    canvas.drawRRect(
      badgeRRect,
      Paint()
        ..shader = ui.Gradient.linear(
          const Offset(0, 0),
          Offset(width, 0),
          [const Color(0xFFF59E0B), const Color(0xFFEA580C)],
        )
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.4,
    );
    namePainter.paint(canvas, Offset((width - namePainter.width) / 2, 8));

    // 2. 3D Beveled Teardrop Store Pin
    final double pinCenterX = width / 2;
    final double pinCenterY = height * 0.58;
    final double pinRadius = size * 0.26;

    // Ground Aura Halo
    canvas.drawOval(
      Rect.fromCenter(center: Offset(pinCenterX, height - 6), width: size * 0.45, height: 10),
      Paint()..color = const Color(0xFFEA580C).withValues(alpha: 0.35)..maskFilter = ui.MaskFilter.blur(ui.BlurStyle.normal, 4),
    );

    final Path pinPath = Path()
      ..addArc(Rect.fromCircle(center: Offset(pinCenterX, pinCenterY), radius: pinRadius), math.pi * 0.78, math.pi * 1.44)
      ..lineTo(pinCenterX, height - 8)
      ..close();

    final Paint pinPaint = Paint()
      ..shader = ui.Gradient.linear(
        Offset(pinCenterX - pinRadius, pinCenterY - pinRadius),
        Offset(pinCenterX + pinRadius, height - 8),
        [
          const Color(0xFFFF6B00),
          const Color(0xFFEA580C),
          const Color(0xFFB91C1C),
        ],
        [0.0, 0.5, 1.0],
      );
    canvas.drawPath(pinPath, pinPaint);

    // Bevel Edge Rim
    canvas.drawPath(
      pinPath,
      Paint()
        ..color = Colors.white.withValues(alpha: 0.85)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.4,
    );

    // Inner White Pearl Center
    canvas.drawCircle(Offset(pinCenterX, pinCenterY), pinRadius * 0.68, Paint()..color = Colors.white);

    // Storefront Icon inside
    final TextPainter iconPainter = TextPainter(textDirection: TextDirection.ltr);
    iconPainter.text = TextSpan(
      text: String.fromCharCode(Icons.storefront_rounded.codePoint),
      style: TextStyle(
        fontSize: pinRadius * 0.88,
        fontFamily: Icons.storefront_rounded.fontFamily,
        package: Icons.storefront_rounded.fontPackage,
        color: const Color(0xFFEA580C),
        fontWeight: FontWeight.bold,
      ),
    );
    iconPainter.layout();
    iconPainter.paint(
      canvas,
      Offset(pinCenterX - (iconPainter.width / 2), pinCenterY - (iconPainter.height / 2)),
    );

    // 3. Gold Star Rating Chip on Top-Right of Pin
    final starCenter = Offset(pinCenterX + pinRadius * 0.75, pinCenterY - pinRadius * 0.75);
    canvas.drawCircle(starCenter, 9, Paint()..color = const Color(0xFFFEF08A));
    canvas.drawCircle(starCenter, 9, Paint()..color = const Color(0xFFF59E0B)..style = PaintingStyle.stroke..strokeWidth = 1.2);
    final TextPainter starPainter = TextPainter(
      text: const TextSpan(
        text: '★',
        style: TextStyle(color: Color(0xFFD97706), fontSize: 10, fontWeight: FontWeight.w900),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    starPainter.paint(canvas, Offset(starCenter.dx - (starPainter.width / 2), starCenter.dy - (starPainter.height / 2)));

    final ui.Picture picture = recorder.endRecording();
    final ui.Image image = await picture.toImage(width.toInt(), height.toInt());
    final ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    return byteData!.buffer.asUint8List();
  }

  Future<Uint8List> _generateCustomerMarkerBytes({
    required String customerName,
    required Color color,
    required double size,
  }) async {
    final ui.PictureRecorder recorder = ui.PictureRecorder();
    final Canvas canvas = Canvas(recorder);
    final double width = size * 1.5;
    final double height = size * 1.4;

    // 1. Text Label Badge
    final TextPainter namePainter = TextPainter(
      text: TextSpan(
        text: '📍 $customerName',
        style: const TextStyle(
          color: Colors.white,
          fontSize: 11,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.2,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();

    final badgeWidth = math.max(namePainter.width + 16, 80.0);
    const badgeHeight = 24.0;
    final badgeRRect = RRect.fromRectAndRadius(
      Rect.fromCenter(center: Offset(width / 2, 14), width: badgeWidth, height: badgeHeight),
      const Radius.circular(12),
    );

    // Badge Shadow & Surface
    canvas.drawRRect(badgeRRect, Paint()..color = Colors.black.withValues(alpha: 0.35)..maskFilter = ui.MaskFilter.blur(ui.BlurStyle.normal, 4));
    canvas.drawRRect(badgeRRect, Paint()..color = const Color(0xFF0F172A).withValues(alpha: 0.95));
    canvas.drawRRect(
      badgeRRect,
      Paint()
        ..shader = ui.Gradient.linear(
          const Offset(0, 0),
          Offset(width, 0),
          [const Color(0xFF34D399), const Color(0xFF059669)],
        )
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.4,
    );
    namePainter.paint(canvas, Offset((width - namePainter.width) / 2, 8));

    // 2. 3D Beveled Teardrop Customer Pin
    final double pinCenterX = width / 2;
    final double pinCenterY = height * 0.58;
    final double pinRadius = size * 0.26;

    // Ground Geofence Halo
    canvas.drawOval(
      Rect.fromCenter(center: Offset(pinCenterX, height - 6), width: size * 0.45, height: 10),
      Paint()..color = const Color(0xFF10B981).withValues(alpha: 0.35)..maskFilter = ui.MaskFilter.blur(ui.BlurStyle.normal, 4),
    );

    final Path pinPath = Path()
      ..addArc(Rect.fromCircle(center: Offset(pinCenterX, pinCenterY), radius: pinRadius), math.pi * 0.78, math.pi * 1.44)
      ..lineTo(pinCenterX, height - 8)
      ..close();

    final Paint pinPaint = Paint()
      ..shader = ui.Gradient.linear(
        Offset(pinCenterX - pinRadius, pinCenterY - pinRadius),
        Offset(pinCenterX + pinRadius, height - 8),
        [
          const Color(0xFF34D399),
          const Color(0xFF10B981),
          const Color(0xFF047857),
        ],
        [0.0, 0.5, 1.0],
      );
    canvas.drawPath(pinPath, pinPaint);

    // Bevel Edge Rim
    canvas.drawPath(
      pinPath,
      Paint()
        ..color = Colors.white.withValues(alpha: 0.85)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.4,
    );

    // Inner White Pearl Center
    canvas.drawCircle(Offset(pinCenterX, pinCenterY), pinRadius * 0.68, Paint()..color = Colors.white);

    // Home Icon inside
    final TextPainter iconPainter = TextPainter(textDirection: TextDirection.ltr);
    iconPainter.text = TextSpan(
      text: String.fromCharCode(Icons.home_rounded.codePoint),
      style: TextStyle(
        fontSize: pinRadius * 0.88,
        fontFamily: Icons.home_rounded.fontFamily,
        package: Icons.home_rounded.fontPackage,
        color: const Color(0xFF10B981),
        fontWeight: FontWeight.bold,
      ),
    );
    iconPainter.layout();
    iconPainter.paint(
      canvas,
      Offset(pinCenterX - (iconPainter.width / 2), pinCenterY - (iconPainter.height / 2)),
    );

    final ui.Picture picture = recorder.endRecording();
    final ui.Image image = await picture.toImage(width.toInt(), height.toInt());
    final ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    return byteData!.buffer.asUint8List();
  }
}
