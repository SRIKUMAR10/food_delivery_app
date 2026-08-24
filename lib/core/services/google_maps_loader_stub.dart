bool isGoogleMapsJsReady() => true;
Future<bool> ensureGoogleMapsJsLoaded() async => true;
void markGoogleMapsAuthFailed() {}
void registerGoogleMapsAuthFailureListener(void Function() callback) {}
Future<Map<String, dynamic>?> fetchWebGoogleDirectionsRoute(
  double originLat,
  double originLng,
  double destLat,
  double destLng,
) async => null;
