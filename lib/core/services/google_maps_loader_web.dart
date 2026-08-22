import 'dart:async';
import 'dart:html' as html;
import 'dart:js' as js;
import 'package:flutter_dotenv/flutter_dotenv.dart';

bool _gmAuthFailed = false;

bool isGoogleMapsJsReady() {
  try {
    if (_gmAuthFailed) return false;
    if (js.context.hasProperty('_gmAuthFailed') && js.context['_gmAuthFailed'] == true) {
      return false;
    }
    if (js.context.hasProperty('google')) {
      final dynamic google = js.context['google'];
      if (google != null) {
        final dynamic maps = google['maps'];
        if (maps != null && maps['MapTypeId'] != null) {
          return true;
        }
      }
    }
  } catch (_) {}
  return false;
}

void markGoogleMapsAuthFailed() {
  _gmAuthFailed = true;
}

void registerGoogleMapsAuthFailureListener(void Function() callback) {
  try {
    if (_gmAuthFailed || (js.context.hasProperty('_gmAuthFailed') && js.context['_gmAuthFailed'] == true)) {
      _gmAuthFailed = true;
      callback();
    }
    html.window.addEventListener('gm-auth-failed', (_) {
      _gmAuthFailed = true;
      callback();
    });
  } catch (_) {}
}

Future<bool> ensureGoogleMapsJsLoaded() async {
  if (isGoogleMapsJsReady()) return true;

  try {
    final existing = html.document.querySelector('script[src*="maps.googleapis.com"]');
    if (existing == null) {
      final apiKey = dotenv.env['GOOGLE_MAPS_API_KEY'] ??
          dotenv.env['API_KEY'] ??
          'AIzaSyBwTsgY7b5lSrYZVR7KX76Fkq4ijzZkBrA';
      final script = html.ScriptElement()
        ..src = 'https://maps.googleapis.com/maps/api/js?key=$apiKey&libraries=places,geometry&v=weekly'
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
