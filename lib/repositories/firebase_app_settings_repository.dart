import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
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
    final docRef = _firestore
        .collection('buyer_user')
        .doc(userId)
        .collection('settings')
        .doc('app');
    final snapshot = await docRef.get();

    if (snapshot.exists) {
      return _fromSnapshot(snapshot);
    }

    return const AppSettingsState(isInitialized: true);
  }

  @override
  Stream<AppSettingsState> watchSettings(String userId) {
    final docRef = _firestore
        .collection('buyer_user')
        .doc(userId)
        .collection('settings')
        .doc('app');

    return docRef.snapshots().map((snapshot) {
      if (snapshot.exists) {
        return _fromSnapshot(snapshot);
      }
      return const AppSettingsState(isInitialized: true);
    });
  }

  AppSettingsState _fromSnapshot(DocumentSnapshot<Map<String, dynamic>> snapshot) {
    final data = snapshot.data()!;
    return AppSettingsState(
      pushNotifications: data['pushNotifications'] as bool? ?? true,
      orderNotifications: data['orderNotifications'] as bool? ?? true,
      offerNotifications: data['offerNotifications'] as bool? ?? false,
      chatNotifications: data['chatNotifications'] as bool? ?? true,
      notificationSound: data['notificationSound'] as bool? ?? true,
      vibration: data['vibration'] as bool? ?? true,
      theme: _resolveTheme(data['theme'] as String?, null),
      language: _resolveLanguage(data['language'] as String?, null),
      isInitialized: true,
    );
  }

  @override
  Future<void> saveSettings(AppSettingsState state) async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return;

    await _firestore
        .collection('buyer_user')
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
    await _firestore.collection('buyer_user').doc(userId).delete();
  }
}
