import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'HelpSupport_State.dart';

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

    await _firestore.collection('buyer_user').doc(uid).collection('support_tickets').add({
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

    await _firestore.collection('buyer_user').doc(uid).collection('feedback').add({
      'rating': rating,
      'comments': comments,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> watchSupportTickets() {
    final uid = _uid;
    if (uid == null) return const Stream.empty();
    return _firestore
        .collection('buyer_user')
        .doc(uid)
        .collection('support_tickets')
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  static const List<FaqItem> defaultFaqs = [
    FaqItem(
      question: 'How do I place an order?',
      answer: 'Browse restaurants and menu items, add your favorite food to the cart, select your delivery address, and proceed to checkout.',
    ),
    FaqItem(
      question: 'How can I track my order?',
      answer: 'You can track your order in real-time under the Orders tab by tapping on the active order to view delivery status and rider location.',
    ),
    FaqItem(
      question: 'How do I cancel my order?',
      answer: 'You can cancel an order before the restaurant starts preparing it from the order details page.',
    ),
    FaqItem(
      question: 'What payment methods are accepted?',
      answer: 'We accept Credit/Debit Cards, UPI, Net Banking, FoodGo Wallet, and Cash on Delivery.',
    ),
    FaqItem(
      question: 'How do refunds work?',
      answer: 'Refunds for cancelled orders are credited back to your original payment method or FoodGo wallet within 2-4 business days.',
    ),
    FaqItem(
      question: 'How can I contact customer support?',
      answer: 'You can reach us directly via Email (support@foodgo.app) or call our helpline from the Contact Us option.',
    ),
  ];

  Stream<List<FaqItem>> watchFaqs() async* {
    yield defaultFaqs;
    try {
      await for (final snapshot in _firestore.collection('faqs').snapshots()) {
        final items = snapshot.docs
            .map((doc) => FaqItem.fromFirestore(doc.data()))
            .where((faq) => faq.question.isNotEmpty)
            .toList();
        yield items.isNotEmpty ? items : defaultFaqs;
      }
    } catch (_) {
      yield defaultFaqs;
    }
  }
}
