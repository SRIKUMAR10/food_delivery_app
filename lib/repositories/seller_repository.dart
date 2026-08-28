import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_auth_platform_interface/firebase_auth_platform_interface.dart';
import 'package:food_delivery_app/features/buyer_bloc_architecture/home_Page/seller_model.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:food_delivery_app/app_data_collection/seller_collections/seller_collection.dart';
import 'package:food_delivery_app/core/services/firebase_auth_config.dart';
import 'dart:async';
import 'dart:io';

class SellerRepository {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;
  final SellerCollection _sellerCollection;

  SellerRepository({
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
    SellerCollection? sellerCollection,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance,
        _sellerCollection = sellerCollection ?? SellerCollection();

  Future<bool> checkNetworkConnectivity() async {
    if (kIsWeb) {
      return true;
    }
    try {
      final result = await InternetAddress.lookup('google.com')
          .timeout(const Duration(seconds: 5));
      return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } on SocketException catch (_) {
      return false;
    } on TimeoutException catch (_) {
      return false;
    } catch (_) {
      return false;
    }
  }

  User? get currentUser => _auth.currentUser;

  Stream<Seller> getSellerById(String sellerId) {
    return _firestore
        .collection('sellers')
        .doc(sellerId)
        .snapshots()
        .map((snapshot) => Seller.fromFirestore(snapshot));
  }

  Future<Seller> fetchSeller(String sellerId) async {
    final doc = await _firestore.collection('sellers').doc(sellerId).get();
    if (doc.exists) {
      return Seller.fromFirestore(doc);
    }
    throw Exception('Seller not found');
  }

  Future<void> updateSeller(Seller seller) async {
    await _firestore.collection('sellers').doc(seller.id).set(seller.toFirestore(), SetOptions(merge: true));
  }

  Future<void> updateSellerData(String sellerId, Map<String, dynamic> data) async {
    await _firestore.collection('sellers').doc(sellerId).update(data);
  }

  /// Checks whether the seller with [sellerId] has completed or submitted KYC
  Future<bool> checkKycCompleted(String sellerId) async {
    try {
      final doc = await _firestore.collection('sellers').doc(sellerId).get();
      if (!doc.exists) {
        return false;
      }
      final data = doc.data();
      if (data == null) {
        return false;
      }
      final kycStatus = data['kycStatus']?.toString().toLowerCase();
      final verificationStatus = data['verificationStatus']?.toString().toLowerCase();
      final isVerified = data['isVerified'] == true || data['isApproved'] == true;

      if (isVerified ||
          kycStatus == 'approved' ||
          kycStatus == 'verified' ||
          kycStatus == 'in_review' ||
          kycStatus == 'under_review' ||
          kycStatus == 'submitted' ||
          verificationStatus == 'approved' ||
          verificationStatus == 'verified' ||
          verificationStatus == 'in_review') {
        return true;
      }

      // Check subcollection kyc_documents/details
      try {
        final kycSubDoc = await _firestore
            .collection('sellers')
            .doc(sellerId)
            .collection('kyc_documents')
            .doc('details')
            .get();
        if (kycSubDoc.exists && kycSubDoc.data() != null) {
          final subData = kycSubDoc.data()!;
          final subStatus = subData['status']?.toString().toLowerCase() ??
              subData['kycStatus']?.toString().toLowerCase();
          if (subStatus == 'approved' ||
              subStatus == 'verified' ||
              subStatus == 'in_review' ||
              subStatus == 'under_review' ||
              subStatus == 'submitted') {
            return true;
          }
          final hasSubLegal = (subData['fssaiNumber'] != null && subData['fssaiNumber'].toString().trim().isNotEmpty) ||
              (subData['gstNumber'] != null && subData['gstNumber'].toString().trim().isNotEmpty) ||
              (subData['panNumber'] != null && subData['panNumber'].toString().trim().isNotEmpty);
          if (hasSubLegal && subStatus != 'pending') {
            return true;
          }
        }
      } catch (_) {}

      // If key legal and banking information are recorded on root document
      final hasFssai = data['fssaiNumber'] != null && data['fssaiNumber'].toString().trim().isNotEmpty;
      final hasGst = data['gstNumber'] != null && data['gstNumber'].toString().trim().isNotEmpty;
      final hasPan = data['panNumber'] != null && data['panNumber'].toString().trim().isNotEmpty;
      final hasBank = data['bankAccountNumber'] != null && data['bankAccountNumber'].toString().trim().isNotEmpty;

      if (hasFssai && hasBank && (hasGst || hasPan)) {
        return true;
      }

      return false;
    } catch (e) {
      debugPrint('Error checking KYC status in SellerRepository: $e');
      return false;
    }
  }

  Future<UserCredential> signInWithPhoneAndPassword(String phoneNumber, String password) async {
    final cleanPhone = phoneNumber.replaceAll(RegExp(r'\s+'), '').replaceAll('-', '');
    final formattedPhone = cleanPhone.startsWith('+') ? cleanPhone : '+91$cleanPhone';
    final trimmedPassword = password.trim();

    try {
      final callable = FirebaseFunctions.instance.httpsCallable('customLogin');
      final response = await callable.call({
        'phoneNumber': formattedPhone,
        'password': trimmedPassword,
        'role': 'seller',
        'targetRole': 'seller',
      });

      final data = Map<String, dynamic>.from(response.data as Map);
      final customToken = data['customToken'] as String;

      return await _auth.signInWithCustomToken(customToken);
    } on FirebaseFunctionsException catch (e) {
      if (e.code == 'deadline-exceeded' ||
          e.code == 'not-found' ||
          e.code == 'unauthenticated' ||
          e.code == 'invalid-argument' ||
          e.code == 'internal') {
        throw Exception('Please check the mobile number and password');
      }
      final msg = e.message ?? '';
      if (msg.contains('deadline-exceeded') ||
          msg.contains('not-found') ||
          msg.contains('unauthenticated') ||
          msg.contains('Password') ||
          msg.contains('registered') ||
          msg.contains('INTERNAL') ||
          msg.contains('internal')) {
        throw Exception('Please check the mobile number and password');
      }
      throw Exception(msg.isNotEmpty && msg != 'INTERNAL' ? msg : 'Please check the mobile number and password');
    } catch (e) {
      throw Exception('Please check the mobile number and password');
    }
  }

  Future<UserCredential> signIn(String emailOrPhone, String password) async {
    final trimmed = emailOrPhone.trim();
    final trimmedPassword = password.trim();
    final isPhone = !trimmed.contains('@') && RegExp(r'^\+?[0-9\s\-]+$').hasMatch(trimmed);
    if (isPhone) {
      return await signInWithPhoneAndPassword(trimmed, trimmedPassword);
    }

    // Email branch: Use customLogin Cloud Function first, then fallback to Firebase Auth
    try {
      final callable = FirebaseFunctions.instance.httpsCallable('customLogin');
      final response = await callable.call({
        'email': trimmed,
        'phoneNumber': trimmed,
        'password': trimmedPassword,
        'role': 'seller',
        'targetRole': 'seller',
      });

      final data = Map<String, dynamic>.from(response.data as Map);
      final customToken = data['customToken'] as String;

      return await _auth.signInWithCustomToken(customToken);
    } on FirebaseFunctionsException catch (e) {
      if (e.code == 'deadline-exceeded' ||
          e.code == 'not-found' ||
          e.code == 'unauthenticated' ||
          e.code == 'invalid-argument' ||
          e.code == 'internal') {
        throw Exception('Please check the mobile number and password');
      }
      final msg = e.message ?? '';
      if (msg.contains('deadline-exceeded') ||
          msg.contains('not-found') ||
          msg.contains('unauthenticated') ||
          msg.contains('Password') ||
          msg.contains('registered') ||
          msg.contains('INTERNAL') ||
          msg.contains('internal')) {
        throw Exception('Please check the mobile number and password');
      }
      throw Exception(msg.isNotEmpty && msg != 'INTERNAL' ? msg : 'Please check the mobile number and password');
    } catch (e) {
      try {
        return await _auth.signInWithEmailAndPassword(email: trimmed, password: trimmedPassword);
      } catch (authErr) {
        throw Exception('Please check the mobile number and password');
      }
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }

  Future<void> sendPasswordResetEmail(String email, {ActionCodeSettings? actionCodeSettings}) async {
    final settings = actionCodeSettings ?? FirebaseAuthConfig.defaultActionCodeSettings;
    await _auth.sendPasswordResetEmail(
      email: email,
      actionCodeSettings: settings,
    );
  }

  Future<void> sendSignInLinkToEmail(String email, {ActionCodeSettings? actionCodeSettings}) async {
    final settings = actionCodeSettings ?? FirebaseAuthConfig.defaultActionCodeSettings;
    await _auth.sendSignInLinkToEmail(
      email: email,
      actionCodeSettings: settings,
    );
  }

  bool isSignInWithEmailLink(String emailLink) {
    return _auth.isSignInWithEmailLink(emailLink);
  }

  Future<UserCredential> signInWithEmailLink({
    required String email,
    required String emailLink,
  }) async {
    return await _auth.signInWithEmailLink(
      email: email,
      emailLink: emailLink,
    );
  }

  Future<UserCredential> signInWithGoogle() async {
    try {
      UserCredential credential;
      if (kIsWeb) {
        final authProvider = GoogleAuthProvider();
        authProvider.addScope('email');
        authProvider.addScope('profile');
        credential = await _auth.signInWithPopup(authProvider);
      } else {
        final GoogleSignIn googleSignIn = GoogleSignIn(
          scopes: ['email', 'profile'],
        );
        final GoogleSignInAccount? googleUser = await googleSignIn.signIn();
        
        if (googleUser == null) {
          throw Exception('Google Sign-In was cancelled.');
        }
        
        final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
        final AuthCredential authCredential = GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        );
        
        credential = await _auth.signInWithCredential(authCredential);
      }

      if (credential.user != null) {
        await syncSellerProfile(
          uid: credential.user!.uid,
          name: credential.user!.displayName ?? '',
          email: credential.user!.email ?? '',
          imageUrl: credential.user!.photoURL,
          phone: credential.user!.phoneNumber ?? '',
        );
      }

      return credential;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'popup-closed-by-user' ||
          e.code == 'user-cancelled' ||
          e.code == 'cancelled') {
        throw Exception('Google Sign-In was cancelled.');
      }
      if (e.code == 'popup-blocked-by-browser') {
        throw Exception(
            'Popup blocked by browser. Please allow popups and try again.');
      }
      throw Exception('Google Sign-In failed: ${e.message ?? e.code}');
    } catch (e) {
      final str = e.toString();
      if (str.contains('popup-closed-by-user') ||
          str.contains('user-cancelled') ||
          str.contains('aborted by user') ||
          str.contains('Google Sign-In was cancelled')) {
        throw Exception('Google Sign-In was cancelled.');
      }
      throw Exception('Google Sign-In failed: $e');
    }
  }

  Future<UserCredential> signInWithApple() async {
    try {
      UserCredential credential;
      final appleProvider = OAuthProvider('apple.com');
      appleProvider.addScope('email');
      appleProvider.addScope('name');

      if (kIsWeb) {
        credential = await _auth.signInWithPopup(appleProvider);
      } else {
        credential = await _auth.signInWithProvider(appleProvider);
      }

      if (credential.user != null) {
        await syncSellerProfile(
          uid: credential.user!.uid,
          name: credential.user!.displayName ?? '',
          email: credential.user!.email ?? '',
          imageUrl: credential.user!.photoURL,
          phone: credential.user!.phoneNumber ?? '',
        );
      }
      return credential;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'popup-closed-by-user' ||
          e.code == 'user-cancelled' ||
          e.code == 'cancelled') {
        throw Exception('Apple Sign-In was cancelled.');
      }
      throw Exception('Apple Sign-In failed: ${e.message ?? e.code}');
    } catch (e) {
      final str = e.toString();
      if (str.contains('popup-closed-by-user') ||
          str.contains('user-cancelled') ||
          str.contains('aborted by user') ||
          str.contains('Apple Sign-In was cancelled')) {
        throw Exception('Apple Sign-In was cancelled.');
      }
      throw Exception('Apple Sign-In failed: $e');
    }
  }

  /// Centralized sync helper to ensure:
  /// STEP 1: Firebase Authentication Layer (Links EmailAuthProvider if missing)
  /// STEP 2: Cloud Functions Layer (Role & custom claims verification)
  /// STEP 3: Firestore Database Layer (sellers/{uid} root document + subcollections)
  Future<void> syncSellerProfile({
    required String uid,
    String? name,
    String? email,
    String? phone,
    String? imageUrl,
    String? password,
  }) async {
    final currentUser = _auth.currentUser;

    // STEP 1: Firebase Authentication - Link EmailAuthProvider if missing
    if (currentUser != null && email != null && email.trim().contains('@')) {
      final trimmedEmail = email.trim();
      final hasPasswordProvider = currentUser.providerData.any(
        (info) => info.providerId == 'password',
      );

      if (!hasPasswordProvider) {
        final authPassword = (password != null && password.isNotEmpty)
            ? password
            : 'SellerPass123!';
        try {
          final emailCred = EmailAuthProvider.credential(
            email: trimmedEmail,
            password: authPassword,
          );
          await currentUser.linkWithCredential(emailCred);
          debugPrint('Step 1 Success: Linked EmailAuthProvider for Seller $trimmedEmail');
        } on FirebaseAuthException catch (e) {
          debugPrint('Step 1 Link Note ($trimmedEmail): ${e.code} - ${e.message}');
          if (e.code == 'provider-already-linked' ||
              e.code == 'email-already-in-use' ||
              e.code == 'credential-already-in-use') {
            try {
              await currentUser.updatePassword(authPassword);
            } catch (_) {}
          }
        } catch (e) {
          debugPrint('Step 1 Auth sync note: $e');
        }
      }
    }

    // STEP 2: Cloud Functions Role / Custom Claims Synchronization
    try {
      final callable = FirebaseFunctions.instance.httpsCallable('customLogin');
      await callable.call({
        'uid': uid,
        'email': email ?? '',
        'role': 'seller',
        'targetRole': 'seller',
      }).timeout(const Duration(seconds: 4));
    } catch (e) {
      debugPrint('Step 2 Cloud Functions role sync note: $e');
    }

    // STEP 3: Firestore Database - Store in sellers/{uid} collection
    final cleanName = (name != null && name.trim().isNotEmpty) ? name.trim() : '';
    final defaultProfile = <String, dynamic>{
      'id': uid,
      'uid': uid,
      'name': cleanName,
      'sellerName': cleanName,
      'shopName': cleanName,
      'email': email ?? '',
      'contactNumber': phone ?? '',
      'phoneNumber': phone ?? '',
      'imageUrl': imageUrl ?? '',
      'profileImage': imageUrl ?? '',
      'role': 'seller',
      'isOnline': true,
      'isApproved': false,
      'status': 'active',
      'rating': 0.0,
      'ratingCount': 0,
      'totalOrders': 0,
      'wallet': 0.0,
      'walletBalance': 0.0,
      'fcmToken': '',
      'isVerified': false,
      'verificationStatus': 'pending',
      'kycStatus': 'pending',
      'address': '',
      'businessDetails': '',
      'fullAddress': '',
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    };

    try {
      final callable = FirebaseFunctions.instance.httpsCallable('createSellerProfile');
      final result = await callable.call({
        'uid': uid,
        'email': email ?? '',
        'name': cleanName,
        'phone': phone ?? '',
        'imageUrl': imageUrl ?? '',
      }).timeout(const Duration(seconds: 4));
      if (result.data is Map) {
        final resMap = Map<String, dynamic>.from(result.data as Map);
        if (resMap['status'] == 'success') {
          return;
        }
      }

      final doc = await _firestore.collection('sellers').doc(uid).get();
      if (!doc.exists) {
        await _sellerCollection.createSellerWithSubCollections(uid, defaultProfile);
      } else {
        final Map<String, dynamic> updates = {
          'isOnline': true,
          'updatedAt': FieldValue.serverTimestamp(),
        };
        if (cleanName.isNotEmpty) {
          updates['sellerName'] = cleanName;
          updates['name'] = cleanName;
          final existingData = doc.data();
          final currentShop = existingData?['shopName']?.toString() ?? '';
          if (currentShop.isEmpty || currentShop.endsWith("'s Kitchen")) {
            updates['shopName'] = cleanName;
          }
        }
        if (email != null && email.trim().isNotEmpty) {
          updates['email'] = email.trim();
        }
        if (phone != null && phone.trim().isNotEmpty) {
          updates['contactNumber'] = phone.trim();
          updates['phoneNumber'] = phone.trim();
        }
        if (imageUrl != null && imageUrl.trim().isNotEmpty) {
          updates['imageUrl'] = imageUrl.trim();
          updates['profileImage'] = imageUrl.trim();
        }
        updates['uid'] = uid;
        updates['id'] = uid;
        updates['role'] = 'seller';

        await _firestore.collection('sellers').doc(uid).set(updates, SetOptions(merge: true));
      }
    } catch (e) {
      debugPrint('Error syncing seller profile to Firestore sellers: $e');
      try {
        await _sellerCollection.createSellerWithSubCollections(uid, defaultProfile);
      } catch (retryErr) {
        throw Exception('Failed to write seller profile to Firestore sellers: $retryErr');
      }
    }
  }

  /// Real-time stream of the seller's DocumentSnapshot from sellers collection
  Stream<DocumentSnapshot> getSellerStream(String uid) {
    return _firestore.collection('sellers').doc(uid).snapshots();
  }

  /// Real-time stream of the seller's profile data map from sellers collection
  Stream<Map<String, dynamic>?> getSellerDataStream(String uid) {
    return getSellerStream(uid).map((doc) {
      if (doc.exists && doc.data() != null) {
        return doc.data() as Map<String, dynamic>;
      }
      return null;
    });
  }

  String? _verificationId;
  ConfirmationResult? _confirmationResult;
  RecaptchaVerifier? _recaptchaVerifier;

  Future<void> requestPhoneLoginOtp(String phoneNumber) async {
    if (kIsWeb) {
      try {
        try {
          _recaptchaVerifier?.clear();
        } catch (_) {}
        _recaptchaVerifier = RecaptchaVerifier(
          auth: FirebaseAuthPlatform.instance,
          container: 'recaptcha-container',
          size: RecaptchaVerifierSize.compact,
        );
        _confirmationResult = await _auth.signInWithPhoneNumber(
          phoneNumber,
          _recaptchaVerifier!,
        ).timeout(const Duration(seconds: 30), onTimeout: () {
          try {
            _recaptchaVerifier?.clear();
          } catch (_) {}
          _recaptchaVerifier = null;
          throw Exception('OTP Request Timed Out.');
        });
      } catch (e) {
        try {
          _recaptchaVerifier?.clear();
        } catch (_) {}
        _recaptchaVerifier = null;
        throw Exception('Failed to send OTP: $e');
      }
    } else {
      Completer<void> completer = Completer<void>();
      await _auth.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        verificationCompleted: (PhoneAuthCredential credential) async {
          // Auto-resolution (Android only)
        },
        verificationFailed: (FirebaseAuthException e) {
          if (!completer.isCompleted) {
            completer.completeError(e);
          }
        },
        codeSent: (String verificationId, int? resendToken) {
          _verificationId = verificationId;
          if (!completer.isCompleted) {
            completer.complete();
          }
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          _verificationId = verificationId;
        },
      );
      return completer.future;
    }
  }

  Future<bool> verifyPhoneLoginOtp(String otpCode, String phoneNumber) async {
    try {
      if (kIsWeb) {
        if (_confirmationResult == null) return false;
        await _confirmationResult!.confirm(otpCode);
        return true;
      } else {
        if (_verificationId == null) return false;
        PhoneAuthCredential credential = PhoneAuthProvider.credential(
          verificationId: _verificationId!,
          smsCode: otpCode,
        );
        await _auth.signInWithCredential(credential);
        return true;
      }
    } catch (e) {
      return false;
    }
  }

  Future<void> initiateSignUp({
    required String name,
    required String shopName,
    required String businessDetails,
    required String phoneNumber,
    required String email,
    required String password,
    String? address,
    double? latitude,
    double? longitude,
    String? googleMapsUrl,
    String? fssaiNumber,
    String? gstNumber,
  }) async {
    final cleanPhone = phoneNumber.replaceAll(RegExp(r'\s+'), '').replaceAll('-', '');
    final digits = cleanPhone.replaceAll(RegExp(r'\D'), '');
    final variants = [cleanPhone, '+91$digits', '+91 $digits', digits];

    // Check if phone number is already registered in sellers
    try {
      final snapPhone = await _firestore
          .collection('sellers')
          .where('contactNumber', whereIn: variants)
          .limit(1)
          .get();

      if (snapPhone.docs.isNotEmpty) {
        throw Exception('This phone number is already registered. Please Login.');
      }
    } catch (e) {
      if (e.toString().contains('already registered')) rethrow;
      debugPrint('Seller pre-check phone lookup: $e');
    }

    // Check if email is already registered in sellers
    if (email.trim().isNotEmpty && email.trim().contains('@')) {
      try {
        final snapEmail = await _firestore
            .collection('sellers')
            .where('email', isEqualTo: email.trim())
            .limit(1)
            .get();

        if (snapEmail.docs.isNotEmpty) {
          throw Exception('The email address is already in use by another account.');
        }
      } catch (e) {
        if (e.toString().contains('already in use')) rethrow;
        debugPrint('Seller pre-check email lookup: $e');
      }
    }
  }

  Future<bool> confirmSignUpOtp({
    required String otpCode,
    required String phoneNumber,
    required String verificationId,
    required String name,
    required String shopName,
    required String businessDetails,
    required String email,
    required String password,
    String? address,
    double? latitude,
    double? longitude,
    String? googleMapsUrl,
    String? fssaiNumber,
    String? gstNumber,
  }) async {
    final credential = PhoneAuthProvider.credential(
      verificationId: verificationId,
      smsCode: otpCode,
    );

    try {
      final userCred = await _auth.signInWithCredential(credential);
      final uid = userCred.user?.uid ?? _auth.currentUser?.uid;
      if (uid != null) {
        final effectiveAddress = (address != null && address.trim().isNotEmpty)
            ? address.trim()
            : businessDetails;

        final sellerData = <String, dynamic>{
          'id': uid,
          'uid': uid,
          'sellerName': name.trim(),
          'name': name.trim(),
          'ownerName': name.trim(),
          'shopName': shopName.trim(),
          'restaurantName': shopName.trim(),
          'businessDetails': businessDetails.trim(),
          'description': businessDetails.trim(),
          'address': effectiveAddress,
          'fullAddress': effectiveAddress,
          'contactNumber': phoneNumber.trim(),
          'phoneNumber': phoneNumber.trim(),
          'email': email.trim(),
          'password': password.trim(),
          'hashedPassword': password.trim(),
          'role': 'seller',
          'isOnline': true,
          'isOpen': true,
          'isAcceptingOrders': true,
          'isApproved': false,
          'isVerified': false,
          'verificationStatus': 'pending',
          'kycStatus': 'pending',
          'status': 'active',
          'rating': 4.5,
          'ratingCount': 0,
          'totalOrders': 0,
          'wallet': 0.0,
          'walletBalance': 0.0,
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        };
        if (latitude != null) sellerData['latitude'] = latitude;
        if (longitude != null) sellerData['longitude'] = longitude;
        if (googleMapsUrl != null) sellerData['googleMapsUrl'] = googleMapsUrl;
        if (fssaiNumber != null && fssaiNumber.trim().isNotEmpty) {
          sellerData['fssaiNumber'] = fssaiNumber.trim();
        }
        if (gstNumber != null && gstNumber.trim().isNotEmpty) {
          sellerData['gstNumber'] = gstNumber.trim();
        }

        await _sellerCollection.createSellerWithSubCollections(uid, sellerData);
        try {
          await userCred.user?.updateDisplayName(name.trim());
        } catch (_) {}
      }
      return true;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'invalid-verification-code' ||
          e.code == 'invalid-verification-id') {
        return false;
      }
      rethrow;
    }
  }

  Future<String> sendOtp(String phoneNumber) async {
    final formattedPhone = phoneNumber
        .replaceAll(RegExp(r'\s+'), '')
        .replaceAll('-', '');
    final fullPhone =
        formattedPhone.startsWith('+') ? formattedPhone : '+91$formattedPhone';

    if (kIsWeb) {
      await requestPhoneLoginOtp(fullPhone);
      return 'web_verification_id';
    }

    final completer = Completer<String>();

    await _auth.verifyPhoneNumber(
      phoneNumber: fullPhone,
      verificationCompleted: (credential) {},
      verificationFailed: (e) {
        if (!completer.isCompleted) {
          completer.completeError(
              Exception(e.message ?? 'Phone verification failed'));
        }
      },
      codeSent: (verificationId, resendToken) {
        _verificationId = verificationId;
        if (!completer.isCompleted) {
          completer.complete(verificationId);
        }
      },
      codeAutoRetrievalTimeout: (verificationId) {
        _verificationId = verificationId;
        if (!completer.isCompleted) {
          completer.complete(verificationId);
        }
      },
    );

    return completer.future;
  }

  /// Reset password via Phone OTP verification for Seller
  Future<void> resetPasswordWithPhoneOtp({
    required String verificationId,
    required String smsCode,
    required String phoneNumber,
    required String newPassword,
  }) async {
    final cleanPhone = phoneNumber.replaceAll(RegExp(r'\s+'), '').replaceAll('-', '');
    final fullPhone = cleanPhone.startsWith('+') ? cleanPhone : '+91$cleanPhone';
    final digitsOnly = cleanPhone.replaceAll(RegExp(r'\D'), '');
    final withoutPrefix = cleanPhone.startsWith('+91')
        ? cleanPhone.substring(3)
        : (cleanPhone.startsWith('+') ? cleanPhone.substring(1) : cleanPhone);
    final phoneVariants = [cleanPhone, fullPhone, digitsOnly, withoutPrefix, '+91 $digitsOnly'];

    late UserCredential userCredential;
    if (kIsWeb && _confirmationResult != null) {
      userCredential = await _confirmationResult!.confirm(smsCode);
    } else {
      final credential = PhoneAuthProvider.credential(
        verificationId: verificationId,
        smsCode: smsCode,
      );
      userCredential = await _auth.signInWithCredential(credential);
    }

    final user = userCredential.user;
    if (user != null && newPassword.isNotEmpty) {
      try {
        await user.updatePassword(newPassword);
      } catch (e) {
        debugPrint('Direct user.updatePassword note in SellerRepository: $e');
      }

      // Query seller document by phone number variations
      String? matchedSellerDocId;
      Map<String, dynamic>? existingSellerData;
      try {
        final snap = await _firestore
            .collection('sellers')
            .where('contactNumber', whereIn: phoneVariants)
            .limit(1)
            .get();
        if (snap.docs.isNotEmpty) {
          matchedSellerDocId = snap.docs.first.id;
          existingSellerData = snap.docs.first.data();
        } else {
          final snapPhone = await _firestore
              .collection('sellers')
              .where('phoneNumber', whereIn: phoneVariants)
              .limit(1)
              .get();
          if (snapPhone.docs.isNotEmpty) {
            matchedSellerDocId = snapPhone.docs.first.id;
            existingSellerData = snapPhone.docs.first.data();
          }
        }
      } catch (e) {
        debugPrint('Error querying seller by phone in resetPasswordWithPhoneOtp: $e');
      }

      final updateData = <String, dynamic>{
        'password': newPassword,
        'hashedPassword': newPassword,
        'updatedAt': FieldValue.serverTimestamp(),
      };

      final targetSellerId = matchedSellerDocId ?? user.uid;

      try {
        await _firestore.collection('sellers').doc(targetSellerId).set(updateData, SetOptions(merge: true));
        if (user.uid != targetSellerId) {
          await _firestore.collection('sellers').doc(user.uid).set(updateData, SetOptions(merge: true));
          await _sellerCollection.mergeSellerDocuments(targetSellerId, user.uid);
        }
      } catch (e) {
        debugPrint('Error updating password in SellerRepository Firestore doc: $e');
      }

      final sellerEmail = existingSellerData?['email']?.toString() ??
          (user.email?.isNotEmpty == true ? user.email! : '$withoutPrefix@foodgoseller.app');

      final targetEmails = <String>{
        sellerEmail,
        if (user.email != null && user.email!.contains('@')) user.email!,
        if (digitsOnly.isNotEmpty) '$digitsOnly@foodgoseller.app',
      };

      for (final email in targetEmails) {
        try {
          final emailCred = EmailAuthProvider.credential(
            email: email,
            password: newPassword,
          );
          await user.linkWithCredential(emailCred);
        } on FirebaseAuthException catch (e) {
          if (e.code == 'provider-already-linked' ||
              e.code == 'email-already-in-use' ||
              e.code == 'credential-already-in-use') {
            try {
              await user.updatePassword(newPassword);
            } catch (_) {}
          }
        } catch (_) {}
      }

      await _auth.signOut();
    }
  }

  Future<bool> checkEmailVerified() async {
    await _auth.currentUser?.reload();
    return _auth.currentUser?.emailVerified ?? false;
  }
}
