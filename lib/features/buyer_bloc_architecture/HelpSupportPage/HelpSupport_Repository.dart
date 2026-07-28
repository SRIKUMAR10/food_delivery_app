import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class HelpSupportRepository {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  HelpSupportRepository({
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance;

  String? get _uid => _auth.currentUser?.uid;

  Future<void> submitSupportTicket({
    required String type,
    required String subject,
    required String message,
    String? orderId,
  }) async {
    final uid = _uid;
    if (uid == null) throw Exception('Please sign in to submit a ticket.');

    await _firestore.collection('users').doc(uid).collection('support_tickets').add({
      'type': type,
      'subject': subject,
      'message': message,
      if (orderId != null) 'orderId': orderId,
      'status': 'open',
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> submitFeedback({
    required int rating,
    required String comments,
  }) async {
    final uid = _uid;
    if (uid == null) throw Exception('Please sign in to submit feedback.');

    await _firestore.collection('users').doc(uid).collection('feedback').add({
      'rating': rating,
      'comments': comments,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }
}
