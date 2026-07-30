import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/repositories/i_app_settings_repository.dart';
import '../features/buyer_bloc_architecture/user_profile_image/AppSettings_State.dart';

class FirebaseAppSettingsRepository implements IAppSettingsRepository {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  FirebaseAppSettingsRepository({
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance;

  @override
  Future<AppSettingsState> loadSettings(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    final cachedTheme = prefs.getString('app_settings_theme');
    final cachedLanguage = prefs.getString('app_settings_language');

    try {
      final docRef = _firestore
          .collection('users')
          .doc(userId)
          .collection('settings')
          .doc('app');
      final snapshot = await docRef.get();

      if (snapshot.exists) {
        final data = snapshot.data()!;

        final theme = _resolveTheme(data['theme'] as String?, cachedTheme);
        final language =
            _resolveLanguage(data['language'] as String?, cachedLanguage);

        await _cacheToPrefs(theme, language);

        return AppSettingsState(
          pushNotifications: data['pushNotifications'] as bool? ?? true,
          orderNotifications: data['orderNotifications'] as bool? ?? true,
          offerNotifications: data['offerNotifications'] as bool? ?? false,
          chatNotifications: data['chatNotifications'] as bool? ?? true,
          notificationSound: data['notificationSound'] as bool? ?? true,
          vibration: data['vibration'] as bool? ?? true,
          theme: theme,
          language: language,
          isInitialized: true,
        );
      }

      return AppSettingsState(
        theme: cachedTheme ?? 'system',
        language: cachedLanguage ?? 'en',
        isInitialized: true,
      );
    } catch (e) {
      if (cachedTheme != null || cachedLanguage != null) {
        return AppSettingsState(
          theme: cachedTheme ?? 'system',
          language: cachedLanguage ?? 'en',
          isInitialized: true,
        );
      }
      rethrow;
    }
  }

  @override
  Future<void> saveSettings(AppSettingsState state) async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return;

    await _cacheToPrefs(state.theme, state.language);

    await _firestore
        .collection('users')
        .doc(userId)
        .collection('settings')
        .doc('app')
        .set({
      'pushNotifications': state.pushNotifications,
      'orderNotifications': state.orderNotifications,
      'offerNotifications': state.offerNotifications,
      'chatNotifications': state.chatNotifications,
      'notificationSound': state.notificationSound,
      'vibration': state.vibration,
      'theme': state.theme,
      'language': state.language,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  String _resolveTheme(String? firestoreValue, String? cachedValue) {
    if (firestoreValue != null && ['light', 'dark', 'system'].contains(firestoreValue)) {
      return firestoreValue;
    }
    if (cachedValue != null && ['light', 'dark', 'system'].contains(cachedValue)) {
      return cachedValue;
    }
    return 'system';
  }

  String _resolveLanguage(String? firestoreValue, String? cachedValue) {
    if (firestoreValue != null && firestoreValue.isNotEmpty) {
      return firestoreValue;
    }
    return cachedValue ?? 'en';
  }

  @override
  Future<void> deleteUserData(String userId) async {
    await _firestore.collection('users').doc(userId).delete();
  }

  Future<void> _cacheToPrefs(String theme, String language) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('app_settings_theme', theme);
    await prefs.setString('app_settings_language', language);
  }
}
