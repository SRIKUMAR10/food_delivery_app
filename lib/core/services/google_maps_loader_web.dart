import 'dart:async';
import 'dart:convert';
import 'dart:html' as html;
import 'dart:js_interop';
import 'dart:js_interop_unsafe';
import 'package:flutter_dotenv/flutter_dotenv.dart';

bool _gmAuthFailed = false;

/// Checks if Google Maps JS SDK is fully initialized and operational on Web.
bool isGoogleMapsJsReady() {
  try {
    if (_gmAuthFailed) return false;
    if (globalContext.hasProperty('_gmAuthFailed'.toJS).toDart) {
      final authFailed = globalContext.getProperty<JSBoolean?>('_gmAuthFailed'.toJS);
      if (authFailed?.toDart == true) {
        _gmAuthFailed = true;
        return false;
      }
    }
    final errContainer = html.document.querySelector(
      '.gm-err-container, .gm-err-message, .gm-err-autocomplete, [class*="gm-err"]',
    );
    if (errContainer != null) {
      _gmAuthFailed = true;
      return false;
    }
    if (globalContext.hasProperty('google'.toJS).toDart) {
      final google = globalContext.getProperty<JSObject?>('google'.toJS);
      if (google != null && google.hasProperty('maps'.toJS).toDart) {
        final maps = google.getProperty<JSObject?>('maps'.toJS);
        if (maps != null && maps.hasProperty('MapTypeId'.toJS).toDart) {
          return true;
        }
      }
    }
  } catch (_) {}
  return false;
}

/// Explicitly mark Google Maps authentication or quota as failed.
void markGoogleMapsAuthFailed() {
  _gmAuthFailed = true;
}

/// Registers a listener for Google Maps authentication/quota failure events.
void registerGoogleMapsAuthFailureListener(void Function() callback) {
  try {
    final authFailedProp = globalContext.hasProperty('_gmAuthFailed'.toJS).toDart
        ? globalContext.getProperty<JSBoolean?>('_gmAuthFailed'.toJS)?.toDart
        : false;
    if (_gmAuthFailed || authFailedProp == true) {
      _gmAuthFailed = true;
      callback();
    }
    html.window.addEventListener('gm-auth-failed', (_) {
      _gmAuthFailed = true;
      callback();
    });
  } catch (_) {}
}

/// Ensures the Google Maps JavaScript script is loaded in the browser.
Future<bool> ensureGoogleMapsJsLoaded() async {
  if (isGoogleMapsJsReady()) return true;

  try {
    final existing = html.document.querySelector('script[src*="maps.googleapis.com"]');
    if (existing == null) {
      final apiKey = dotenv.env['GOOGLE_MAPS_API_KEY'] ??
          dotenv.env['API_KEY'] ??
          'AIzaSyCo2p5qPkTyj2zl3hxVvH1C5B-mN9vOXFs';
      final script = html.ScriptElement()
        ..src = 'https://maps.googleapis.com/maps/api/js?key=$apiKey&libraries=places,geometry,routes&v=weekly&loading=async'
        ..async = true
        ..defer = true;
      html.document.head?.append(script);
    }

    for (int i = 0; i < 40; i++) {
      await Future<void>.delayed(const Duration(milliseconds: 100));
      if (isGoogleMapsJsReady()) return true;
    }
  } catch (_) {}

  return isGoogleMapsJsReady();
}

/// Fetches real road navigation route using the Web JS DirectionsService (CORS-free).
Future<Map<String, dynamic>?> fetchWebGoogleDirectionsRoute(
  double originLat,
  double originLng,
  double destLat,
  double destLng,
) async {
  try {
    if (globalContext.hasProperty('getGoogleDirectionsRoute'.toJS).toDart) {
      final completer = Completer<String?>();
      
      final successCallback = ((JSString? jsonStr) {
        if (!completer.isCompleted) {
          completer.complete(jsonStr?.toDart);
        }
      }).toJS;

      final errorCallback = ((JSAny? err) {
        if (!completer.isCompleted) {
          completer.complete(null);
        }
      }).toJS;

      globalContext.callMethodVarArgs<JSAny?>(
        'getGoogleDirectionsRoute'.toJS,
        <JSAny?>[
          originLat.toJS,
          originLng.toJS,
          destLat.toJS,
          destLng.toJS,
          successCallback,
          errorCallback,
        ],
      );

      final rawJson = await completer.future.timeout(
        const Duration(seconds: 6),
        onTimeout: () => null,
      );
      if (rawJson != null && rawJson.isNotEmpty) {
        return json.decode(rawJson) as Map<String, dynamic>;
      }
    }
  } catch (_) {}
  return null;
}
