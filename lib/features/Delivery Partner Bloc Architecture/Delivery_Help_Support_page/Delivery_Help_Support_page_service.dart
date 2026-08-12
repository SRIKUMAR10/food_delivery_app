import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

abstract class DeliveryHelpSupportPageServiceBase {
  Stream<List<Map<String, dynamic>>> watchSupportTickets();
  Future<Map<String, dynamic>> createSupportTicket(
    Map<String, dynamic> ticket,
  );
  Future<Map<String, dynamic>> submitFeedback(int rating, String comment);
  Future<List<Map<String, dynamic>>> fetchFAQs();
}

class DeliveryHelpSupportPageService
    implements DeliveryHelpSupportPageServiceBase {
  static const String hotlineNumber = '18001234567';

  static const List<Map<String, String>> _defaultFAQs = [
    {
      'id': 'faq_earnings_1',
      'category': 'Earnings',
      'question': 'When will my earnings be credited to my wallet?',
      'answer':
          'Delivery earnings are credited to your wallet within 24 hours of '
          'completing an order. Weekend payouts may reflect on the next '
          'business day. You can track pending amounts in the Wallet section.',
    },
    {
      'id': 'faq_earnings_2',
      'category': 'Earnings',
      'question': 'How is my delivery fare calculated?',
      'answer':
          'Your fare is based on base fare plus distance, surge, and peak '
          'hour bonuses. Tips are credited separately and shown in your '
          'earnings breakdown.',
    },
    {
      'id': 'faq_route_1',
      'category': 'Route / GPS',
      'question': 'The in-app GPS shows the wrong location. What should I do?',
      'answer':
          'Ensure location services are enabled with high accuracy, then '
          'restart the app. If the issue persists, raise a Route/GPS support '
          'ticket with your delivery address details.',
    },
    {
      'id': 'faq_route_2',
      'category': 'Route / GPS',
      'question': 'Can I change the suggested delivery route?',
      'answer':
          'Yes. Tap "Alternate Routes" on the navigation screen to pick a '
          'different path. Avoid very long detours as delivery time is '
          'tracked.',
    },
    {
      'id': 'faq_app_1',
      'category': 'App Technical',
      'question': 'The app keeps crashing during an active delivery. What now?',
      'answer':
          'Restart the app and resume the active order from the dashboard. '
          'Your active order is saved automatically. If crashes repeat, '
          'submit an App Technical ticket with your device model and app '
          'version.',
    },
    {
      'id': 'faq_app_2',
      'category': 'App Technical',
      'question': 'How do I update the delivery partner app?',
      'answer':
          'Check the Play Store / App Store for the latest version. You will '
          'be notified in-app when a mandatory update is available.',
    },
    {
      'id': 'faq_customer_1',
      'category': 'Customer Issue',
      'question': 'The customer is not reachable at the drop-off location.',
      'answer':
          'Try calling twice with a 5-minute gap. If unreachable, start the '
          'waiting timer, then raise a Customer Issue ticket and follow the '
          'return-to-restaurant flow shown in the app.',
    },
    {
      'id': 'faq_customer_2',
      'category': 'Customer Issue',
      'question': 'What if a customer reports a wrong or missing item?',
      'answer':
          'Note the restaurant order id and respond to the dispute from your '
          'Notifications. Our team reviews the audit trail and updates your '
          'ticket within 48 hours.',
    },
  ];

  final FirebaseFirestore? _firestore;
  final FirebaseAuth? _auth;

  DeliveryHelpSupportPageService({
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
  })  : _firestore = firestore,
        _auth = auth;

  FirebaseFirestore get _db => _firestore ?? FirebaseFirestore.instance;

  FirebaseAuth get _authInstance => _auth ?? FirebaseAuth.instance;

  @override
  Stream<List<Map<String, dynamic>>> watchSupportTickets() {
    String? uid;
    try {
      uid = _authInstance.currentUser?.uid;
    } catch (_) {
      return Stream.value(const []);
    }
    if (uid == null) {
      return Stream.value(const []);
    }
    try {
      return _db
          .collection('delivery_partners')
          .doc(uid)
          .collection('support_tickets')
          .orderBy('createdAt', descending: true)
          .limit(50)
          .snapshots()
          .map(
            (snapshot) => snapshot.docs
                .map(_mapTicketDoc)
                .toList(),
          );
    } catch (_) {
      return Stream.value(const []);
    }
  }

  @override
  Future<Map<String, dynamic>> createSupportTicket(
    Map<String, dynamic> ticket,
  ) async {
    try {
      String? uid;
      try {
        uid = _authInstance.currentUser?.uid;
      } catch (_) {
        return {
          'success': false,
          'error': 'Authentication required to create a support ticket.',
        };
      }
      if (uid == null) {
        return {
          'success': false,
          'error': 'Authentication required to create a support ticket.',
        };
      }
      final docRef = await _db
          .collection('delivery_partners')
          .doc(uid)
          .collection('support_tickets')
          .add({
        ...ticket,
        'status': 'open',
        'createdAt': FieldValue.serverTimestamp(),
        'lastResponseAt': FieldValue.serverTimestamp(),
        'lastResponse': '',
      });
      return {'success': true, 'id': docRef.id};
    } catch (e) {
      return {'success': false, 'error': e.toString()};
    }
  }

  @override
  Future<Map<String, dynamic>> submitFeedback(int rating, String comment) async {
    try {
      String? uid;
      try {
        uid = _authInstance.currentUser?.uid;
      } catch (_) {
        return {
          'success': false,
          'error': 'Authentication required to submit feedback.',
        };
      }
      if (uid == null) {
        return {
          'success': false,
          'error': 'Authentication required to submit feedback.',
        };
      }
      await _db
          .collection('delivery_partners')
          .doc(uid)
          .collection('feedback')
          .add({
        'rating': rating,
        'comment': comment,
        'createdAt': FieldValue.serverTimestamp(),
      });
      return {'success': true};
    } catch (e) {
      return {'success': false, 'error': e.toString()};
    }
  }

  @override
  Future<List<Map<String, dynamic>>> fetchFAQs() async {
    try {
      final snapshot = await _db.collection('help_faqs').limit(50).get();
      if (snapshot.docs.isNotEmpty) {
        return snapshot.docs.map((doc) {
          final data = doc.data();
          return {
            'id': doc.id,
            'category': data['category'] ?? 'General',
            'question': data['question'] ?? '',
            'answer': data['answer'] ?? '',
          };
        }).toList();
      }
    } catch (_) {
      // Fall back to the bundled structured FAQ catalog.
    }
    return _defaultFAQs;
  }

  Map<String, dynamic> _mapTicketDoc(
    QueryDocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data();
    return {
      'id': doc.id,
      'subject': data['subject'] ?? '',
      'category': data['category'] ?? 'Other',
      'priority': data['priority'] ?? 'medium',
      'description': data['description'] ?? '',
      'orderId': data['orderId'] ?? '',
      'status': data['status'] ?? 'open',
      'createdAt': (data['createdAt'] as Timestamp?)
          ?.toDate()
          .toIso8601String() ?? '',
      'lastResponseAt': (data['lastResponseAt'] as Timestamp?)
          ?.toDate()
          .toIso8601String() ?? '',
      'lastResponse': data['lastResponse'] ?? '',
    };
  }
}
