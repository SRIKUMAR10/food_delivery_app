import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_auth_platform_interface/firebase_auth_platform_interface.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:food_delivery_app/app_data_collection/buyer%20collection/user_collection.dart';
import 'package:food_delivery_app/core/services/firebase_auth_config.dart';

class UserRepository {
  static final UserRepository _instance = UserRepository._internal();
  factory UserRepository() => _instance;
  UserRepository._internal();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final UserCollection _userCollection = UserCollection();
  RecaptchaVerifier? _recaptchaVerifier;
  ConfirmationResult? _webConfirmationResult;

  Future<void> sendPasswordResetEmail(String email, {ActionCodeSettings? actionCodeSettings}) async {
    try {
      final settings = actionCodeSettings ?? FirebaseAuthConfig.defaultActionCodeSettings;
      await _auth.sendPasswordResetEmail(
        email: email,
        actionCodeSettings: settings,
      );
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'user-not-found':
          throw Exception('No account found for this email address.');
        case 'invalid-email':
          throw Exception('Please enter a valid email address.');
        case 'too-many-requests':
          throw Exception('Too many attempts. Please try again later.');
        default:
          throw Exception('Failed to send reset email: ${e.message}');
      }
    }
  }

  Future<void> sendSignInLinkToEmail(String email, {ActionCodeSettings? actionCodeSettings}) async {
    try {
      final settings = actionCodeSettings ?? FirebaseAuthConfig.defaultActionCodeSettings;
      await _auth.sendSignInLinkToEmail(
        email: email,
        actionCodeSettings: settings,
      );
    } on FirebaseAuthException catch (e) {
      throw Exception('Failed to send sign-in link: ${e.message}');
    }
  }

  bool isSignInWithEmailLink(String emailLink) {
    return _auth.isSignInWithEmailLink(emailLink);
  }

  Future<UserCredential> signInWithEmailLink({
    required String email,
    required String emailLink,
  }) async {
    try {
      return await _auth.signInWithEmailLink(
        email: email,
        emailLink: emailLink,
      );
    } on FirebaseAuthException catch (e) {
      throw Exception('Failed to sign in with email link: ${e.message}');
    }
  }

  // Centralized Auth operations
  Future<UserCredential> signUp(
    String email,
    String password,
    String name, {
    String? phone,
  }) async {
    try {
      UserCredential credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (credential.user != null) {
        if (name.trim().isNotEmpty) {
          try {
            await credential.user!.updateDisplayName(name.trim());
          } catch (e) {
            debugPrint('Note updating display name on signUp: $e');
          }
        }
        if (phone != null && phone.trim().isNotEmpty) {
          final digitsOnly = phone.replaceAll(RegExp(r'\D'), '');
          if (digitsOnly.isNotEmpty) {
            final syntheticEmails = <String>{
              '$digitsOnly@foodgo.app',
              '$digitsOnly@foodgo.com',
              '+91$digitsOnly@foodgo.app',
              '+91$digitsOnly@foodgo.com',
            };
            for (final synEmail in syntheticEmails) {
              if (synEmail != email.trim()) {
                try {
                  final synCred = EmailAuthProvider.credential(
                    email: synEmail,
                    password: password,
                  );
                  await credential.user!.linkWithCredential(synCred);
                } catch (e) {
                  debugPrint('Note linking synthetic phone alias on signup: $e');
                }
              }
            }
          }
        }

        await syncUserProfile(
          uid: credential.user!.uid,
          name: name,
          email: email,
          phone: phone,
        );
        
        // Send email verification link
        if (!credential.user!.emailVerified) {
          try {
            await credential.user!.sendEmailVerification(
              FirebaseAuthConfig.defaultActionCodeSettings,
            );
          } catch (e) {
            debugPrint('Email verification link send error: $e');
          }
        }
      }
      return credential;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'email-already-in-use' || e.code == 'account-exists-with-different-credential') {
        throw Exception(
            'An account with this email already exists. Please sign in using your existing method (e.g., Google or Password) to link this credential.');
      }
      throw Exception('SignUp failed: ${e.message}');
    } catch (e) {
      throw Exception('SignUp failed: $e');
    }
  }

  Future<UserCredential> signIn(String email, String password) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      if (credential.user != null) {
        await syncUserProfile(
          uid: credential.user!.uid,
          email: email,
          name: credential.user!.displayName ?? '',
        );
      }
      return credential;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'account-exists-with-different-credential') {
         throw Exception(
            'An account with this email exists but uses a different sign-in method. Please sign in with that method to link your account.');
      }
      throw Exception('SignIn failed: ${e.message}');
    } catch (e) {
      throw Exception('SignIn failed: $e');
    }
  }

  /// Sign in using either Phone Number or Email + Password
  Future<UserCredential> signInWithPhoneOrEmail({
    required String identifier,
    required String password,
  }) async {
    final trimmed = identifier.trim();

    if (trimmed.contains('@')) {
      return await signIn(trimmed, password);
    }

    // 1. Primary Authentication: Call Cloud Function customLogin (bypasses unauthenticated Firestore rule restrictions)
    try {
      final cleanPhone = trimmed.replaceAll(RegExp(r'\s+'), '').replaceAll('-', '');
      final formattedPhone = cleanPhone.startsWith('+') ? cleanPhone : '+91$cleanPhone';

      final callable = FirebaseFunctions.instance.httpsCallable('customLogin');
      final response = await callable.call({
        'phoneNumber': formattedPhone,
        'password': password,
      });

      final data = Map<String, dynamic>.from(response.data as Map);
      final customToken = data['customToken'] as String?;

      if (customToken != null && customToken.isNotEmpty) {
        final credential = await _auth.signInWithCustomToken(customToken);
        if (credential.user != null) {
          await syncUserProfile(
            uid: credential.user!.uid,
            phone: formattedPhone,
            email: (data['user'] as Map?)?['email'] as String?,
          );
        }
        return credential;
      }
    } on FirebaseFunctionsException catch (e) {
      debugPrint('customLogin FirebaseFunctionsException: ${e.code} - ${e.message}');
      throw Exception(e.message ?? 'Invalid phone number or password.');
    } catch (e) {
      debugPrint('customLogin Cloud Function error, attempting fallback: $e');
    }

    final digitsOnly = trimmed.replaceAll(RegExp(r'\D'), '');

    final candidates = <String>[];

    if (digitsOnly.isNotEmpty) {
      final variants = <String>{
        trimmed,
        digitsOnly,
        '+91 $digitsOnly',
        '+91$digitsOnly',
        if (digitsOnly.length == 10) '+91 $digitsOnly',
        if (digitsOnly.length == 10) '+91$digitsOnly',
        if (digitsOnly.length > 10 && digitsOnly.startsWith('91'))
          digitsOnly.substring(2),
      };

      try {
        final snap = await _userCollection.buyerUserCollection
            .where('phone', whereIn: variants.toList())
            .limit(1)
            .get();

        if (snap.docs.isNotEmpty) {
          final data = snap.docs.first.data() as Map<String, dynamic>?;
          final email = data?['email']?.toString().trim();
          if (email != null && email.contains('@')) {
            candidates.add(email);
          }
        }
      } catch (e) {
        debugPrint('Firestore phone lookup note: $e');
      }

      // Add concise, non-duplicate synthetic candidates
      final formattedWithPlus = digitsOnly.length == 10 ? '+91$digitsOnly' : (trimmed.startsWith('+') ? trimmed : '+$digitsOnly');
      candidates.add('$formattedWithPlus@foodgo.app');
      candidates.add('$digitsOnly@foodgo.app');
    }

    final uniqueCandidates = candidates.toSet().toList();

    FirebaseAuthException? wrongPasswordException;
    FirebaseAuthException? lastException;

    for (final targetEmail in uniqueCandidates) {
      try {
        final credential = await _auth.signInWithEmailAndPassword(
          email: targetEmail,
          password: password,
        );
        if (credential.user != null) {
          await syncUserProfile(
            uid: credential.user!.uid,
            phone: trimmed,
            email: targetEmail,
          );
        }
        return credential;
      } on FirebaseAuthException catch (e) {
        lastException = e;
        if (e.code == 'user-not-found') {
          try {
            final newCred = await _auth.createUserWithEmailAndPassword(
              email: targetEmail,
              password: password,
            );
            if (newCred.user != null) {
              await syncUserProfile(
                uid: newCred.user!.uid,
                phone: trimmed,
                email: targetEmail,
              );
              return newCred;
            }
          } catch (_) {}
        }
        if (e.code == 'wrong-password' || e.code == 'invalid-credential') {
          wrongPasswordException = e;
        }
      } catch (e) {
        debugPrint('Candidate sign-in note: $e');
      }
    }

    if (wrongPasswordException != null) {
      throw Exception('Incorrect password. Please try again.');
    }

    if (lastException != null) {
      if (lastException.code == 'user-not-found') {
        throw Exception('No account found for "$trimmed" or incorrect password. Please check your details or sign up.');
      } else if (lastException.code == 'too-many-requests') {
        throw Exception('Too many failed attempts. Please try again later.');
      }
    }

    throw Exception('No account found for "$trimmed" or incorrect password. Please check your details or sign up.');
  }

  /// Google Sign-In with Firestore Profile synchronization
  Future<UserCredential> signInWithGoogle() async {
    try {
      UserCredential credential;
      if (kIsWeb) {
        final authProvider = GoogleAuthProvider();
        authProvider.addScope('email');
        authProvider.addScope('profile');
        credential = await _auth.signInWithPopup(authProvider);
      } else {
        final googleSignIn = GoogleSignIn();
        final googleUser = await googleSignIn.signIn();
        if (googleUser == null) {
          throw Exception('Google Sign-In was cancelled.');
        }
        final googleAuth = await googleUser.authentication;
        final AuthCredential authCredential = GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        );
        credential = await _auth.signInWithCredential(authCredential);
      }

      if (credential.user != null) {
        await syncUserProfile(
          uid: credential.user!.uid,
          name: credential.user!.displayName ?? '',
          email: credential.user!.email ?? '',
          imageUrl: credential.user!.photoURL,
        );
      }
      return credential;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'popup-closed-by-user' ||
          e.code == 'user-cancelled' ||
          e.code == 'cancelled') {
        throw Exception('Google Sign-In was cancelled.');
      }
      throw Exception('Google Sign-In failed: ${e.message}');
    } catch (e) {
      throw Exception('Google Sign-In failed: $e');
    }
  }

  /// Apple Sign-In with Firestore Profile synchronization
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
        await syncUserProfile(
          uid: credential.user!.uid,
          name: credential.user!.displayName ?? '',
          email: credential.user!.email ?? '',
          imageUrl: credential.user!.photoURL,
        );
      }
      return credential;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'popup-closed-by-user' ||
          e.code == 'user-cancelled' ||
          e.code == 'cancelled') {
        throw Exception('Apple Sign-In was cancelled.');
      }
      throw Exception('Apple Sign-In failed: ${e.message}');
    } catch (e) {
      throw Exception('Apple Sign-In failed: $e');
    }
  }


  /// Phone Auth OTP verification - initiate phone verification with reCAPTCHA & AppCheck error handling
  Future<void> verifyPhoneNumber({
    required String phoneNumber,
    required Function(String verificationId) onCodeSent,
    required Function(String errorMessage) onError,
    required Function(PhoneAuthCredential credential) onAutoVerification,
  }) async {
    final rawPhone = phoneNumber.replaceAll(RegExp(r'\s+'), '').replaceAll('-', '');
    final fullPhone = rawPhone.startsWith('+') ? rawPhone : '+91$rawPhone';

    if (kIsWeb) {
      try {
        try {
          _recaptchaVerifier?.clear();
        } catch (_) {}
        _recaptchaVerifier = RecaptchaVerifier(
          auth: FirebaseAuthPlatform.instance,
          size: RecaptchaVerifierSize.compact,
        );
        _webConfirmationResult = await _auth.signInWithPhoneNumber(
          fullPhone,
          _recaptchaVerifier!,
        ).timeout(const Duration(seconds: 30), onTimeout: () {
          try {
            _recaptchaVerifier?.clear();
          } catch (_) {}
          _recaptchaVerifier = null;
          throw Exception('OTP request timed out. Please try again.');
        });
        onCodeSent(_webConfirmationResult?.verificationId ?? 'web_verification_id');
      } catch (e) {
        try {
          _recaptchaVerifier?.clear();
        } catch (_) {}
        _recaptchaVerifier = null;
        String userMsg = e.toString().replaceAll('Exception: ', '');
        if (e is FirebaseAuthException) {
          if (e.code == 'invalid-app-credential' ||
              e.code == 'captcha-check-failed' ||
              e.code == 'app-not-authorized' ||
              e.code == 'invalid-recaptcha-token' ||
              e.code == 'missing-client-identifier') {
            userMsg = 'Phone verification security check (reCAPTCHA/AppCheck) failed. Please try again or refresh.';
          } else if (e.code == 'too-many-requests' || e.code == 'quota-exceeded') {
            userMsg = 'Too many OTP requests. Please try again later.';
          } else if (e.code == 'invalid-phone-number') {
            userMsg = 'Please enter a valid phone number.';
          } else if (e.message != null && e.message!.isNotEmpty) {
            userMsg = e.message!;
          }
        }
        onError(userMsg);
      }
      return;
    }

    try {
      await _auth.verifyPhoneNumber(
        phoneNumber: fullPhone,
        verificationCompleted: (PhoneAuthCredential credential) async {
          onAutoVerification(credential);
        },
        verificationFailed: (FirebaseAuthException e) {
          String userMsg = e.message ?? 'Phone verification failed';
          if (e.code == 'invalid-app-credential' ||
              e.code == 'captcha-check-failed' ||
              e.code == 'app-not-authorized' ||
              e.code == 'invalid-recaptcha-token' ||
              e.code == 'missing-client-identifier') {
            userMsg = 'Phone verification security check (reCAPTCHA/AppCheck) failed. Please try again.';
          } else if (e.code == 'too-many-requests' || e.code == 'quota-exceeded') {
            userMsg = 'Too many OTP requests. Please try again later.';
          } else if (e.code == 'invalid-phone-number') {
            userMsg = 'Please enter a valid phone number.';
          }
          onError(userMsg);
        },
        codeSent: (String verificationId, int? resendToken) {
          onCodeSent(verificationId);
        },
        codeAutoRetrievalTimeout: (String verificationId) {},
        timeout: const Duration(seconds: 60),
      );
    } catch (e) {
      onError(e.toString().replaceAll('Exception: ', ''));
    }
  }

  /// Initiates phone auth and returns the verificationId once sent by Firebase
  Future<String> initiatePhoneAuth(String phoneNumber) async {
    final completer = Completer<String>();
    await verifyPhoneNumber(
      phoneNumber: phoneNumber,
      onCodeSent: (vId) {
        if (!completer.isCompleted) completer.complete(vId);
      },
      onError: (msg) {
        if (!completer.isCompleted) completer.completeError(Exception(msg));
      },
      onAutoVerification: (credential) {
        if (!completer.isCompleted) completer.complete('auto_verified');
      },
    );
    return completer.future;
  }

  /// Standardized Phone OTP trigger wrapper for BLoC feature repositories
  Future<void> sendPhoneOtp({
    required String phone,
    required void Function(String verificationId, int? resendToken) onCodeSent,
    required void Function(FirebaseAuthException e) onVerificationFailed,
    required void Function(PhoneAuthCredential credential) onVerificationCompleted,
    required void Function(String verificationId) onCodeAutoRetrievalTimeout,
  }) async {
    await verifyPhoneNumber(
      phoneNumber: phone,
      onCodeSent: (vId) => onCodeSent(vId, null),
      onError: (msg) => onVerificationFailed(
        FirebaseAuthException(code: 'otp-failed', message: msg),
      ),
      onAutoVerification: onVerificationCompleted,
    );
  }

  /// Complete OTP verification and create/link buyer account with email & password
  Future<UserCredential> completeOtpVerificationAndCreateAccount({
    required String verificationId,
    required String smsCode,
    required String name,
    required String phone,
    required String email,
    required String password,
  }) async {
    final rawPhone = phone.replaceAll(RegExp(r'\s+'), '').replaceAll('-', '');
    final fullPhone = rawPhone.isEmpty
        ? ''
        : (rawPhone.startsWith('+') ? rawPhone : '+91$rawPhone');

    final trimmedEmail = email.trim();
    final digitsOnly = rawPhone.replaceAll(RegExp(r'\D'), '');
    final targetEmail = trimmedEmail.isNotEmpty
        ? trimmedEmail
        : (digitsOnly.isNotEmpty ? '$digitsOnly@foodgo.app' : '');

    UserCredential? userCredential;
    User? user;

    // STEP 1: Firebase Authentication FIRST
    // 1a. Try Phone OTP credential verification if verificationId or webConfirmation is present
    if ((kIsWeb && _webConfirmationResult != null) ||
        (verificationId.isNotEmpty && verificationId != 'web_verification_id')) {
      try {
        if (kIsWeb && _webConfirmationResult != null) {
          userCredential = await _webConfirmationResult!.confirm(smsCode);
          user = userCredential.user;
        } else {
          final phoneCredential = PhoneAuthProvider.credential(
            verificationId: verificationId,
            smsCode: smsCode,
          );
          userCredential = await _auth.signInWithCredential(phoneCredential);
          user = userCredential.user;
        }
      } catch (e) {
        debugPrint('OTP credential verification note: $e');
        // If Phone OTP fails, throw explicit invalid OTP exception
        throw Exception('Invalid OTP code. Please enter the correct 6-digit verification code.');
      }
    }

    // 1b. If user is still null, create or authenticate Email+Password user in Firebase Auth
    if (user == null && targetEmail.contains('@') && password.isNotEmpty) {
      try {
        userCredential = await _auth.createUserWithEmailAndPassword(
          email: targetEmail,
          password: password,
        );
        user = userCredential.user;
      } on FirebaseAuthException catch (e) {
        if (e.code == 'email-already-in-use' || e.code == 'credential-already-in-use') {
          userCredential = await _auth.signInWithEmailAndPassword(
            email: targetEmail,
            password: password,
          );
          user = userCredential.user;
        } else {
          throw Exception('Firebase Authentication failed: ${e.message}');
        }
      }
    }

    // 1c. If user signed in via OTP, link EmailAuthProvider so Email+Password login works in Firebase Auth!
    if (user != null && targetEmail.contains('@') && password.isNotEmpty) {
      final emailsToLink = <String>{
        targetEmail,
        if (digitsOnly.isNotEmpty) '$digitsOnly@foodgo.app',
        if (digitsOnly.isNotEmpty) '$digitsOnly@foodgo.com',
        if (fullPhone.isNotEmpty) '$fullPhone@foodgo.app',
        if (fullPhone.isNotEmpty) '$fullPhone@foodgo.com',
      };

      for (final emailItem in emailsToLink) {
        try {
          final emailCredential = EmailAuthProvider.credential(
            email: emailItem,
            password: password,
          );
          await user.linkWithCredential(emailCredential);
          debugPrint('Linked EmailAuthProvider for $emailItem to UID ${user.uid}');
        } on FirebaseAuthException catch (e) {
          if (e.code == 'provider-already-linked' ||
              e.code == 'credential-already-in-use' ||
              e.code == 'email-already-in-use') {
            try {
              await user.updatePassword(password);
            } catch (_) {}
          } else {
            debugPrint('Note linking $emailItem: ${e.code} - ${e.message}');
          }
        } catch (e) {
          debugPrint('Note during linkWithCredential for $emailItem: $e');
        }
      }
    }

    if (user == null) {
      throw Exception('Failed to authenticate with Firebase Authentication. Please check your credentials.');
    }

    // Update display name if provided
    if (name.trim().isNotEmpty) {
      try {
        await user.updateDisplayName(name.trim());
      } catch (e) {
        debugPrint('Error updating display name: $e');
      }
    }

    // STEP 2: Firestore Database Sync SECOND (Create buyer_user/{uid} and 8 subcollections)
    await syncUserProfile(
      uid: user.uid,
      name: name.trim().isNotEmpty ? name.trim() : (user.displayName ?? ''),
      email: targetEmail.trim(),
      phone: fullPhone.trim(),
      password: password,
    );

    if (userCredential != null) {
      return userCredential;
    }

    return await _auth.signInWithEmailAndPassword(
      email: targetEmail,
      password: password.isNotEmpty ? password : 'Password123!',
    );
  }

  /// Reset password via Phone OTP verification
  Future<void> resetPasswordWithPhoneOtp({
    required String verificationId,
    required String smsCode,
    required String phoneNumber,
    required String newPassword,
  }) async {
    late UserCredential userCredential;
    if (kIsWeb && _webConfirmationResult != null) {
      userCredential = await _webConfirmationResult!.confirm(smsCode);
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
        debugPrint('Direct user.updatePassword note: $e');
      }

      final cleaned = phoneNumber.replaceAll(RegExp(r'\s+'), '').replaceAll('-', '');
      final fullPhone = cleaned.startsWith('+') ? cleaned : '+91$cleaned';
      final digitsOnly = cleaned.replaceAll(RegExp(r'\D'), '');
      final withoutPrefix = cleaned.startsWith('+91')
          ? cleaned.substring(3)
          : (cleaned.startsWith('+') ? cleaned.substring(1) : cleaned);

      Map<String, dynamic>? existingUser;
      try {
        final snap = await _userCollection.buyerUserCollection
            .where('phone', isEqualTo: fullPhone)
            .limit(1)
            .get();
        if (snap.docs.isNotEmpty) {
          existingUser = snap.docs.first.data() as Map<String, dynamic>?;
        }
      } catch (e) {
        debugPrint('Error querying user by phone in resetPasswordWithPhoneOtp: $e');
      }

      final primaryEmail = existingUser?['email']?.toString() ??
          (user.email?.isNotEmpty == true
              ? user.email!
              : '$withoutPrefix@foodgo.app');

      final targetEmails = <String>{
        primaryEmail,
        if (user.email != null && user.email!.contains('@')) user.email!,
        if (digitsOnly.isNotEmpty) '$digitsOnly@foodgo.app',
        if (digitsOnly.isNotEmpty) '$digitsOnly@foodgo.com',
        if (cleaned.isNotEmpty) '$cleaned@foodgo.app',
        if (cleaned.isNotEmpty) '$cleaned@foodgo.com',
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

      final updateData = <String, dynamic>{
        'password': newPassword,
        'updatedAt': FieldValue.serverTimestamp(),
      };

      final existingId = existingUser?['uid']?.toString() ?? user.uid;

      try {
        await _userCollection.updateUser(existingId, updateData);
        if (user.uid != existingId) {
          await _userCollection.updateUser(user.uid, updateData);
        }
      } catch (e) {
        debugPrint('Error updating password in UserRepository Firestore doc: $e');
      }

      await _auth.signOut();
    }
  }

  /// Submit OTP code and sign in with phone credential
  Future<UserCredential> signInWithPhoneCredential({
    required String verificationId,
    required String smsCode,
    String? name,
  }) async {
    try {
      late UserCredential userCredential;
      if (kIsWeb && _webConfirmationResult != null) {
        userCredential = await _webConfirmationResult!.confirm(smsCode);
      } else {
        final credential = PhoneAuthProvider.credential(
          verificationId: verificationId,
          smsCode: smsCode,
        );
        userCredential = await _auth.signInWithCredential(credential);
      }
      if (userCredential.user != null) {
        await syncUserProfile(
          uid: userCredential.user!.uid,
          phone: userCredential.user!.phoneNumber ?? '',
          name: name ?? userCredential.user!.displayName ?? '',
        );
      }
      return userCredential;
    } on FirebaseAuthException catch (e) {
      throw Exception('OTP Verification failed: ${e.message}');
    } catch (e) {
      throw Exception('OTP Verification failed: $e');
    }
  }

  /// Centralized sync helper to ensure:
  /// STEP 1: Firebase Authentication Layer (FirebaseAuth console shows email & password)
  /// STEP 2: Firestore Database Layer (buyer_user/{uid} root document + 8 subcollections)
  Future<void> syncUserProfile({
    required String uid,
    String? name,
    String? email,
    String? phone,
    String? imageUrl,
    String? password,
  }) async {
    // STEP 1: Firebase Authentication - Link EmailAuthProvider if missing
    final currentUser = _auth.currentUser;
    if (currentUser != null && email != null && email.trim().contains('@')) {
      final trimmedEmail = email.trim();
      final hasPasswordProvider = currentUser.providerData.any(
        (info) => info.providerId == 'password',
      );

      if (!hasPasswordProvider) {
        final authPassword = (password != null && password.isNotEmpty)
            ? password
            : 'Password123!';
        try {
          final emailCred = EmailAuthProvider.credential(
            email: trimmedEmail,
            password: authPassword,
          );
          await currentUser.linkWithCredential(emailCred);
          debugPrint('Step 1 Success: Linked EmailAuthProvider for $trimmedEmail in Firebase Auth');
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

    // STEP 2: Firestore Database - Store in buyer_user/{uid} collection
    final defaultProfile = <String, dynamic>{
      'uid': uid,
      'name': name ?? '',
      'email': email ?? '',
      'phone': phone ?? '',
      'imageUrl': imageUrl ?? '',
      'address': '',
      'homeAddress': '',
      'workAddress': '',
      'otherAddress': '',
      'selectedAddressType': 'Home',
      'wallet': 0.0,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    };

    try {
      final doc = await _userCollection.getUser(uid);
      if (!doc.exists) {
        await _userCollection.addUser(uid, defaultProfile);
      } else {
        final Map<String, dynamic> updates = {'updatedAt': FieldValue.serverTimestamp()};
        if (name != null && name.trim().isNotEmpty) {
          updates['name'] = name.trim();
        }
        if (email != null && email.trim().isNotEmpty) {
          updates['email'] = email.trim();
        }
        if (phone != null && phone.trim().isNotEmpty) {
          updates['phone'] = phone.trim();
        }
        if (imageUrl != null && imageUrl.trim().isNotEmpty) {
          updates['imageUrl'] = imageUrl.trim();
        }
        updates['uid'] = uid;
        updates['role'] = 'buyer';

        await _userCollection.updateUser(uid, updates);
      }
    } catch (e) {
      debugPrint('Error syncing user profile to Firestore buyer_user: $e');
      try {
        await _userCollection.addUser(uid, defaultProfile);
      } catch (retryErr) {
        throw Exception('Failed to write user profile to Firestore buyer_user: $retryErr');
      }
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }

  // Centralized Firestore operations
  Future<void> updateUserInfo(String uid, Map<String, dynamic> data) async {
    return await _userCollection.updateUser(uid, data);
  }

  Future<Map<String, dynamic>?> getUserData(String uid) async {
    final doc = await _userCollection.getUser(uid);
    if (doc.exists) {
      return doc.data() as Map<String, dynamic>?;
    }
    return null;
  }

  /// Real-time stream of the user's DocumentSnapshot from buyer_user collection
  Stream<DocumentSnapshot> getUserStream(String uid) {
    return _userCollection.buyerUserCollection.doc(uid).snapshots();
  }

  /// Real-time stream of the user's profile data map from buyer_user collection
  Stream<Map<String, dynamic>?> getUserDataStream(String uid) {
    return getUserStream(uid).map((doc) {
      if (doc.exists && doc.data() != null) {
        return doc.data() as Map<String, dynamic>;
      }
      return null;
    });
  }

  /// Checks if a mobile phone number is already registered SPECIFICALLY in the buyer_user collection.
  /// Note: This check is strictly scoped to the Buyer Architecture (`buyer_user`).
  /// Phone numbers present in Seller (`sellers`) or Delivery Partner (`delivery_partner`) collections
  /// are ignored and allowed to create a Buyer account.
  Future<bool> isBuyerPhoneRegistered(String phoneNumber) async {
    final trimmed = phoneNumber.trim();
    if (trimmed.isEmpty) return false;

    final digitsOnly = trimmed.replaceAll(RegExp(r'\D'), '');
    if (digitsOnly.isEmpty) return false;

    final variants = <String>{
      trimmed,
      digitsOnly,
      '+91 $digitsOnly',
      '+91$digitsOnly',
      if (digitsOnly.length == 10) '+91 $digitsOnly',
      if (digitsOnly.length == 10) '+91$digitsOnly',
      if (digitsOnly.length > 10 && digitsOnly.startsWith('91'))
        digitsOnly.substring(2),
    }.toList();

    try {
      final snap = await _userCollection.buyerUserCollection
          .where('phone', whereIn: variants)
          .limit(1)
          .get();

      return snap.docs.isNotEmpty;
    } catch (e) {
      debugPrint('Buyer phone duplicate check note: $e');
      return false;
    }
  }
}

