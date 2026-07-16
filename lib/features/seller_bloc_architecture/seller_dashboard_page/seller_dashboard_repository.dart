import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:rxdart/rxdart.dart';
import 'seller_dashboard_page_state.dart';

abstract class SellerDashboardRepository {
  Stream<DashboardData> getDashboardDataStream();
  Future<DashboardData> getDashboardData();
}

class FirebaseSellerDashboardRepository implements SellerDashboardRepository {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  FirebaseSellerDashboardRepository({
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance;

  @override
  Stream<DashboardData> getDashboardDataStream() {
    final sellerId = _auth.currentUser?.uid;
    if (sellerId == null) {
      return Stream.value(const DashboardData(
        revenueToday: 0.0,
        revenueChangePercentage: 0.0,
        pendingOrdersCount: 0,
        todaysOrdersCount: 0,
        lowStockCount: 0,
        activeProductsCount: 0,
        todaysOrders: [],
        storeName: 'Picarhub',
      ));
    }

    final now = DateTime.now();
    // Timezone safe today boundary
    final todayStart = DateTime(now.year, now.month, now.day);
    final tomorrowStart = todayStart.add(const Duration(days: 1));

    Stream<QuerySnapshot> ordersStream = _firestore
        .collection('orders')
        .where('sellerId', isEqualTo: sellerId)
        .snapshots();

    Stream<QuerySnapshot> productsStream = _firestore
        .collection('products')
        .where('sellerId', isEqualTo: sellerId)
        .snapshots();

    Stream<DocumentSnapshot> sellerStream = _firestore
        .collection('sellers')
        .doc(sellerId)
        .snapshots();

    return Rx.combineLatest3(
      ordersStream,
      productsStream,
      sellerStream,
      (QuerySnapshot ordersSnapshot, QuerySnapshot productsSnapshot, DocumentSnapshot sellerSnapshot) {
        String storeName = 'Picarhub';
        if (sellerSnapshot.exists) {
          final sellerData = sellerSnapshot.data() as Map<String, dynamic>?;
          if (sellerData != null) {
            storeName = sellerData['shopName'] ?? (sellerData['name']?.toString().isNotEmpty == true ? sellerData['name'] : 'Picarhub Restaurant');
          }
        }

        int todaysOrdersCount = 0;
        int pendingOrdersCount = 0;
        double revenueToday = 0.0;
        List<DashboardOrder> todaysOrders = [];

        for (var doc in ordersSnapshot.docs) {
          final data = doc.data() as Map<String, dynamic>;
          
          final status = data['status'] ?? 'New';
          
          DateTime? createdAt;
          if (data['timestamp'] is Timestamp) {
            createdAt = (data['timestamp'] as Timestamp).toDate();
          }

          bool isToday = false;
          if (createdAt != null) {
            isToday = (createdAt.isAfter(todayStart) || createdAt.isAtSameMomentAs(todayStart)) &&
                createdAt.isBefore(tomorrowStart);
          }

          if (isToday) {
            todaysOrdersCount++;
            
            if (status == 'Delivered' || status == 'Completed') {
              revenueToday += (data['amount'] ?? 0.0).toDouble();
            }

            String timeAgo = 'Just now';
            if (createdAt != null) {
              final diff = now.difference(createdAt);
              if (diff.inMinutes < 60) {
                timeAgo = '${diff.inMinutes} min ago';
              } else if (diff.inHours < 24) {
                timeAgo = '${diff.inHours} hrs ago';
              } else {
                timeAgo = '${diff.inDays} days ago';
              }
            }

            todaysOrders.add(DashboardOrder(
              id: doc.id,
              customerName: data['customerName'] ?? 'Unknown',
              status: status,
              price: (data['amount'] ?? 0.0).toDouble(),
              timeAgo: timeAgo,
            ));
          }

          if (status == 'New' || status == 'Accepted' || status == 'Preparing') {
            pendingOrdersCount++;
          }
        }

        // Sort by newest first
        todaysOrders.sort((a, b) {
          // A bit hacky since we only have timeAgo string in the model.
          // For a real app, timestamp should be added to DashboardOrder, but here we can rely on doc order or timeAgo.
          // Since it's a stream, we can sort by document creation or maintain a timestamp.
          // Let's add timestamp to DashboardOrder or sort before mapping.
          // We will sort before mapping.
          return 0; // Handled below by sorting docs first.
        });

        // Let's re-do the list generation with proper sorting.
        final todayDocs = ordersSnapshot.docs.where((doc) {
           final data = doc.data() as Map<String, dynamic>;
           DateTime? createdAt;
           if (data['timestamp'] is Timestamp) {
              createdAt = (data['timestamp'] as Timestamp).toDate();
           }
           if (createdAt == null) return false;
           return (createdAt.isAfter(todayStart) || createdAt.isAtSameMomentAs(todayStart)) &&
                  createdAt.isBefore(tomorrowStart);
        }).toList();

        todayDocs.sort((a, b) {
           final aTime = ((a.data() as Map<String, dynamic>)['timestamp'] as Timestamp?)?.toDate() ?? DateTime.fromMillisecondsSinceEpoch(0);
           final bTime = ((b.data() as Map<String, dynamic>)['timestamp'] as Timestamp?)?.toDate() ?? DateTime.fromMillisecondsSinceEpoch(0);
           return bTime.compareTo(aTime); // Descending
        });

        todaysOrders = todayDocs.map((doc) {
           final data = doc.data() as Map<String, dynamic>;
           final status = data['status'] ?? 'New';
           final createdAt = (data['timestamp'] as Timestamp).toDate();
           
           String timeAgo = 'Just now';
           final diff = DateTime.now().difference(createdAt);
           if (diff.inMinutes < 60) {
             timeAgo = '${diff.inMinutes} min ago';
           } else if (diff.inHours < 24) {
             timeAgo = '${diff.inHours} hrs ago';
           } else {
             timeAgo = '${diff.inDays} days ago';
           }

           return DashboardOrder(
             id: doc.id.length > 5 ? '#${doc.id.substring(0, 5)}' : '#${doc.id}',
             customerName: data['customerName'] ?? 'Unknown',
             status: status,
             price: (data['amount'] ?? 0.0).toDouble(),
             timeAgo: timeAgo,
           );
        }).toList();

        // Calculate Products Metrics
        int lowStockCount = 0;
        int activeProductsCount = 0;

        for (var doc in productsSnapshot.docs) {
          final data = doc.data() as Map<String, dynamic>;
          final isActive = data['isActive'] ?? true;
          final availableStock = data['availableStock'] ?? 0;
          final minimumAlert = data['minimumAlert'] ?? 10;
          final hasUnlimitedStock = data['hasUnlimitedStock'] ?? false;

          if (isActive) {
            activeProductsCount++;
          }

          if (!hasUnlimitedStock && availableStock <= minimumAlert) {
            lowStockCount++;
          }
        }

        return DashboardData(
          revenueToday: revenueToday,
          revenueChangePercentage: 0.0, // Keeping 0 for now as it requires historical data
          pendingOrdersCount: pendingOrdersCount,
          todaysOrdersCount: todaysOrdersCount,
          lowStockCount: lowStockCount,
          activeProductsCount: activeProductsCount,
          todaysOrders: todaysOrders,
          storeName: storeName,
        );
      },
    );
  }

  @override
  Future<DashboardData> getDashboardData() async {
    return await getDashboardDataStream().first;
  }
}

class MockSellerDashboardRepository implements SellerDashboardRepository {
  @override
  Stream<DashboardData> getDashboardDataStream() async* {
    await Future.delayed(const Duration(milliseconds: 800));
    yield _getMockData();
  }

  @override
  Future<DashboardData> getDashboardData() async {
    await Future.delayed(const Duration(milliseconds: 800));
    return _getMockData();
  }

  DashboardData _getMockData() {
    return const DashboardData(
      revenueToday: 45600.0,
      revenueChangePercentage: 12.5,
      pendingOrdersCount: 26,
      todaysOrdersCount: 128,
      lowStockCount: 8,
      activeProductsCount: 145,
      todaysOrders: [
        DashboardOrder(
          id: '#11024',
          customerName: 'John Doe',
          status: 'New',
          price: 660.0,
          timeAgo: '10 min ago',
        ),
        DashboardOrder(
          id: '#11023',
          customerName: 'Jane Smith',
          status: 'Preparing',
          price: 450.0,
          timeAgo: '30 min ago',
        ),
      ],
      storeName: 'Picarhub',
    );
  }
}
