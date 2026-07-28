
# 🚀 Food Delivery App — BLoC Architecture Audit Report (Buyer ↔ Seller Data Flow)

**Audit Date:** July 28, 2026  
**App:** food_delivery_app (Flutter + Firebase)  
**Total Buyer Pages:** 17  
**Total Seller Pages:** 29  
**Shared Core Models:** 10  
**Shared Repository Interfaces:** 6  
**Shared Firebase Services:** 10+

---

## 📑 பொருளடக்கம் (Table of Contents)

1. [Buyer Pages (17) — Complete Architecture](#1-buyer-pages-17--complete-architecture)
2. [Seller Pages (29) — Complete Architecture](#2-seller-pages-29--complete-architecture)
3. [Buyer ↔ Seller Cross Data Flow Analysis](#3-buyer--seller-cross-data-flow-analysis)
4. [Gap Analysis — Mocked Pages Needing Firebase Connection](#4-gap-analysis--mocked-pages-needing-firebase-connection)
5. [Firebase Firestore Collections Map](#5-firebase-firestore-collections-map)
6. [Real-Time Stream Architecture Diagram](#6-real-time-stream-architecture-diagram)
7. [Recommendations & Implementation Plan](#7-recommendations--implementation-plan)

---

## 1. Buyer Pages (17) — Complete Architecture

| # | Page Name | BLoC | Repository | Backend Service | Data Flow Pattern | Real-Time? |
|---|-----------|------|-----------|----------------|-------------------|-----------|
| 1 | **Onboarding Page** | `OnboardingPageBloc` | — | `FirebaseAuthService` (authStateChanges) | Auth state stream → Navigation | ✅ Yes (auth stream) |
| 2 | **Home Page** (Product Browsing) | `HomePageBloc` | `IProductRepository` → `FirebaseProductRepository`, `CategoryRepository` | Firestore (`products`, `global_categories`) | `Stream<List<Product>>` via `.snapshots()` | ✅ Yes |
| 3 | **Details Page** (Product + Rating) | `DetailsBloc` | `DetailsRepository` | Firestore (`products`, `users/{uid}/ratings/`, `products/{id}/reviews`) | `Rx.combineLatest2` — user rating + avg rating streams | ✅ Yes |
| 4 | **Cart Page** | `CartBloc` | `ICartRepository` → `FirebaseCartRepository` | Firestore (`users/{buyerId}/cart/`), Firebase Cloud Function (`createSecureOrder`) | `Stream<List<CartItem>>` via `.snapshots()` | ✅ Yes |
| 5 | **Favorites Page** | `FavoritesBloc` | — (direct Firestore) | Firestore (`users/{uid}/favorites/`) | `QuerySnapshot` stream | ✅ Yes |
| 6 | **Order Page** | `OrderBloc` | `IOrderRepository` → `FirebaseOrderRepository` | Firestore (`orders` collection — filtered by `customerId`) | `Stream<List<OrderModel>>` via `.snapshots()` | ✅ Yes |
| 7 | **Track Order Page** | `TrackOrderBloc` | `TrackOrderRepository` | Firestore (`orders/{orderId}`, `sellers/{sellerId}`, `riders/{riderId}`) | Rider location stream + order status stream | ✅ Yes |
| 8 | **Chat Page** (Buyer) | `BuyerChatBloc` | `IChatRepository` → `FirebaseChatRepository` | Firestore (`conversations`, `messages`), Firebase Storage (media) | `Rx.combineLatest4` — conversations + messages streams | ✅ Yes |
| 9 | **Video Call Page** | `VideoCallBloc` | — | ZegoCloud SDK, PermissionService | Event-driven state machine | ❌ No (P2P) |
| 10 | **Wallet Screen** | `WalletBloc` | `WalletDatabase` (inline) | Firestore (`users/{uid}`, `users/{uid}/transactions/`), Razorpay API | `Stream<DocumentSnapshot>` + `Stream<QuerySnapshot>` | ✅ Yes |
| 11 | **Login Screen** | `FoodGoLoginBloc` | `UserRepository` | Firebase Auth (`signInWithEmailAndPassword`) | Synchronous (Future-based) | ❌ No |
| 12 | **Sign Up Page** | `SignUpBloc` | `UserRepository` | Firebase Auth + Firestore (`users/{uid}`) | Synchronous (Future-based) | ❌ No |
| 13 | **Forgot Password Page** | `ForgotPasswordBloc` | `UserRepository` | Firebase Auth (`sendPasswordResetEmail`) | Synchronous (Future-based) | ❌ No |
| 14 | **Payment Methods Page** | `PaymentMethodsBloc` | `PaymentMethodsRepository` (inline) | Firestore (`users/{uid}/payment_methods/`) | `Stream<List<PaymentMethodModel>>` via `.snapshots()` | ✅ Yes |
| 15 | **Help & Support Page** | `HelpSupportBloc` | `HelpSupportRepository` | Firestore (`users/{uid}/support_tickets/`, `users/{uid}/feedback/`) | Synchronous writes | ❌ No |
| 16 | **User Profile Page** | `UserProfileBloc` | — (direct Firebase) | Firestore (`users/{uid}`), Firebase Storage, Firebase Auth | Synchronous (Future-based) | ❌ No |
| 17 | **App Settings Page** | `AppSettingsBloc` | `IAppSettingsRepository` → `FirebaseAppSettingsRepository` | Firestore (`users/{uid}/settings/app`), SharedPreferences | Synchronous (Future-based) | ❌ No |

### Buyer Navigation Shell

| Component | Type | Notes |
|-----------|------|-------|
| **CurvedNavigationBarView** | Root shell (5 tabs) | No BLoC — uses `ValueNotifier` |
| Tab 0: Home | `HomePage` | Products browsing |
| Tab 1: Wallet | `WalletScreen` | Balance + transactions |
| Tab 2: Cart | `CartPage` | Cart items + checkout |
| Tab 3: Orders | `OrderPage` | Order history |
| Tab 4: Support/Chat | `BuyerChatUI` + `HelpSupportUI` |

---

## 2. Seller Pages (29) — Complete Architecture

| # | Page Name | BLoC | Repository | Backend Service | Data Flow Pattern | Real-Time? |
|---|-----------|------|-----------|----------------|-------------------|-----------|
| 1 | **Seller Dashboard** | `SellerDashboardPageBloc` | `SellerDashboardRepository` | Firestore (`orders`, `products`, `sellers`) | `Rx.combineLatest3` — orders + products + sellers streams | ✅ Yes |
| 2 | **Seller Login** | `SellerLoginPageBloc` | `SellerRepository` | Firebase Auth (email, phone OTP, Google, Apple) | Synchronous (Future-based) | ❌ No |
| 3 | **Seller Sign-Up** | `SellerSignUpPageBloc` | `SellerRepository` | Firebase Auth + Firestore (`sellers`) | Synchronous (Future-based) | ❌ No |
| 4 | **Seller Navigation Bar** | `SellerNavigationBarViewPageBloc` | — | — | Local state (tab index) | ❌ No |
| 5 | **Seller Onboard** | `SellerOnboardPageBloc` | — | — | Navigation flow only | ❌ No |
| 6 | **Seller Forgot Password** | `SellerForgotPasswordBloc` | `SellerRepository` | Firebase Auth | Synchronous | ❌ No |
| 7 | **Seller Analytics** | `SellerAnalyticsBloc` | `SellerAnalyticsRepository` | Firestore (`orders` — sellerId + timestamp) | Future-based `.get()` → client-side compute | ❌ No |
| 8 | **Seller Wallet** | `SellerWalletBloc` | `SellerWalletRepository` | Firestore (`sellers/{id}`, `payouts`, `payout_requests`) | Future-based (transaction for withdrawal) | ❌ No |
| 9 | **Seller Request Payout** | `SellerRequestPayoutBloc` | `SellerRequestPayoutRepository` | Firestore (`sellers`, `payout_requests`, `payouts`) | Future-based (Firestore transaction) | ❌ No |
| 10 | **Seller Payout History** | `SellerPayoutHistoryBloc` | `SellerPayoutHistoryRepository` | Firestore (`payouts` — sellerId) | Future-based (pagination) | ❌ No |
| 11 | **Seller Customers** | `SellerCustomerBloc` | `SellerCustomerRepository` | Firestore (`orders` — sellerId → dedup customers) | Future-based `.get()` | ❌ No |
| 12 | **Seller Product List** | `ProductListBloc` | `IProductRepository` → `FirebaseProductRepository` | Firestore (`products` — sellerId), Firebase Storage | **Real-time stream** `.listen()` | ✅ Yes |
| 13 | **Seller Add/Edit Product** | `AddProductPageBloc` | `IProductRepository` | Firestore (`products`), Firebase Storage | Synchronous (Future-based) | ❌ No |
| 14 | **Seller Orders List** | `OrdersListBloc` | `IOrderRepository` → `FirebaseOrderRepository` | Firestore (`orders` — sellerId), `IChatRepository` | **Real-time stream** via `emit.forEach` | ✅ Yes |
| 15 | **New Order Notification** | `NewOrderNotificationBloc` | `NewOrderNotificationRepository` | **⚠️ MOCKED** (simulated delays) | **⚠️ Mocked** — no real Firebase calls | ❌ No |
| 16 | **Out For Delivery** | `OutForDeliveryPageBloc` | — | **⚠️ MOCKED** (hardcoded rider data) | **⚠️ Mocked** — no real Firebase calls | ❌ No |
| 17 | **Assign Delivery** | `AssignDeliveryBloc` | `AssignDeliveryRepository` | Firestore (`orders` — status + riderId) — but rider list is **mocked** | Partially mocked | ❌ No |
| 18 | **Overall Rating** | `OverallRatingBloc` | `OverallRatingRepository` | Firestore (`reviews` — sellerId) via `SellerReviewService` | Future-based `.get()` | ❌ No |
| 19 | **Promotions & Coupons** | `PromotionsCouponsBloc` | `PromotionsCouponsRepository` | Firestore (`sellers/{id}/promotions`) | Future-based CRUD | ❌ No |
| 20 | **Business Hours** | `BusinessHoursBloc` | `BusinessHoursRepository` | Firestore (`sellers/{id}/settings/business_hours`) | Future-based (read/write) | ❌ No |
| 21 | **Menu Category Management** | `MenuCategoryManagementBloc` | `MenuCategoryManagementRepository` | Firestore (`global_categories`, `sellers/{id}/menu_preferences`) | Future-based (batch write) | ❌ No |
| 22 | **Chat Support** (Seller) | `ChatSupportBloc` | `IChatRepository` → `FirebaseChatRepository` | Firestore (`conversations`, `messages`) | **Real-time streams** — conversations + messages | ✅ Yes |
| 23 | **Inventory / Low Stock** | `InventoryBloc` | `IInventoryRepository` → `InventoryRepository` | Firestore (`products` — sellerId, `inventory_logs`) | **Real-time stream** `.listen()` | ✅ Yes |
| 24 | **Low Stock Alert** (separate) | `LowStockAlertBloc` | — | **⚠️ MOCKED** (hardcoded data) | **⚠️ Mocked** — no real Firebase | ❌ No |
| 25 | **Seller Settings** | `SellerSettingBloc` | `SellerSettingRepository` | Firestore (`seller_notification_settings/{id}`) | Synchronous (Future-based) | ❌ No |
| 26 | **Seller Store Details** | `SellerStoreDetailsBloc` | `SellerRepository` | Firestore (`sellers/{id}`) | Synchronous (Future-based) | ❌ No |
| 27 | **Seller Profile** | `SellerProfilePageBloc` | `SellerCollection`, `SellerRepository` | Firestore (`sellers/{id}`), Firebase Storage | Synchronous (Future-based) | ❌ No |
| 28 | **Seller Verification Form** | (Shares `SellerProfilePageBloc`) | `SellerCollection` | Firestore (`sellers/{id}`) | Synchronous (Future-based) | ❌ No |
| 29 | **Seller Payment** | `SellerPaymentPageBloc` | `SellerPaymentRepository` (inline) | Firestore (`sellers/{id}/payment/details`) | Future-based (mix of real + mock data) | ❌ No |

### Seller Navigation Tab Structure

| Tab | Page | Notes |
|-----|------|-------|
| Tab 0: Dashboard | `SellerDashboardPageUI` | Real-time KPIs |
| Tab 1: Products | `ProductListPageUI` | CRUD + inventory |
| Tab 2: Orders | `OrdersListPageUI` | Accept/Reject → Track |
| Tab 3: Wallet | `SellerWalletPageUI` | Balance + payout |
| Tab 4: Profile/More | Settings, Store, Chat, etc. | Settings drawer/menu |

---

## 3. Buyer ↔ Seller Cross Data Flow Analysis

### 🔴 CRITICAL DATA FLOWS (Already Connected via Firestore)

#### Flow 1: Orders — Buyer Order → Seller Accept/Reject → Buyer Track

```
Buyer (Cart Page)                Firestore                    Seller (Orders List)
     │                              │                              │
     │── checkout ──► Cloud Function ──► orders/{orderId}          │
     │                              │    status: "New"             │
     │                              │    customerId: buyerUid      │
     │                              │    sellerId: sellerUid       │
     │                              │                              │
     │                              │◄── real-time stream ────────┤
     │                              │   (filtered by sellerId)     │
     │                              │                              │
     │                              │              Seller accepts  │
     │                              │◄── status: "Accepted" ──────┤
     │                              │                              │
     │◄── real-time stream ────────┤                              │
     │   (filtered by customerId)   │                              │
     │                              │         Seller prepares     │
     │                              │◄── status: "Preparing" ─────┤
     │                              │                              │
     │◄── status: "Preparing" ─────┤                              │
     │                              │         Seller assigns rider│
     │                              │◄── status: "OutForDelivery" ─┤
     │                              │    assignedRiderId: riderId  │
     │                              │                              │
Buyer (Track Order Page)           │                              │
     │◄── rider location stream ───┤                              │
     │   (riders/{riderId})         │                              │
     │                              │         Rider delivers      │
     │                              │◄── status: "Delivered" ─────┤
     │◄── status: "Delivered" ─────┤                              │
```

**BLoC Chain:** `CartBloc` (checkout) → `OrderBloc` (buyer orders stream) ↔ `OrdersListBloc` (seller orders stream) → `TrackOrderBloc` (buyer tracking)

**Firestore Collections:** `orders` (shared), `riders` (for location), `sellers` (for seller info)

**Real-Time Status:** ✅ **Full real-time sync via Firestore snapshots**

---

#### Flow 2: Chat — Buyer ↔ Seller Messaging

```
Buyer (Chat Page)                 Firestore                    Seller (Chat Support)
     │                              │                              │
     │── sendMessage() ──────────► conversations/{convId}          │
     │                              │    /messages/{msgId}         │
     │                              │                              │
     │◄── real-time stream ────────┤◄── real-time stream ────────┤
     │   (getMessagesStream)        │   (getMessagesStream)        │
     │                              │                              │
     │── markConversationRead() ──► │◄── markConversationRead() ──┤
```

**BLoC Chain:** `BuyerChatBloc` ↔ `ChatSupportBloc` (both use `IChatRepository` → `FirebaseChatRepository`)

**Firestore Collections:** `conversations` (shared), `conversations/{convId}/messages` (shared)

**Real-Time Status:** ✅ **Full real-time sync via Rx.combineLatest4**

---

#### Flow 3: Products — Seller Adds/Updates → Buyer Sees Changes

```
Seller (AddProductPage)           Firestore                    Buyer (Home Page)
     │                              │                              │
     │── addProduct() ───────────► products/{productId}            │
     │   (or updateProduct())       │    sellerId: sellerUid       │
     │                              │    name, price, image...     │
     │                              │                              │
     │                              │◄── real-time stream ────────┤
     │                              │   (products collection)      │
     │                              │                              │
Seller (ProductListPage)            │                              │
     │── toggleStatus() ─────────► │                              │
     │   (isActive: true/false)     │                              │
     │                              │◄── real-time stream ────────┤
     │                              │   (filtered by category)     │
```

**BLoC Chain:** `AddProductPageBloc` / `ProductListBloc` → `HomePageBloc` (via `IProductRepository`)

**Firestore Collections:** `products` (shared, filtered by `sellerId` for seller, by `categoryId` for buyer)

**Real-Time Status:** ✅ **Full real-time sync via Firestore snapshots**

---

#### Flow 4: Ratings — Buyer Submits → Seller Sees

```
Buyer (Details Page)              Firestore                    Seller (Overall Rating)
     │                              │                              │
     │── submitRating() ─────────► products/{foodId}/reviews       │
     │                              │    /{reviewId}               │
     │                              │    userId: buyerUid          │
     │                              │    users/{uid}/ratings/      │
     │                              │                              │
     │◄── avg rating stream ───────┤                              │
     │                              │                              │
     │                              │◄── .get() reviews ──────────┤
     │                              │   (filtered by product's     │
     │                              │    sellerId or sellerId)     │
```

**BLoC Chain:** `DetailsBloc` (buyer submits) → `OverallRatingBloc` (seller views reviews)

**Firestore Collections:** `products/{foodId}/reviews` (subcollection), `users/{uid}/ratings/` (subcollection)

**Real-Time Status:** ⚠️ **Buyer side real-time ✅, Seller side is Future-based `.get()` only — needs real-time stream upgrade**

---

#### Flow 5: Cart → Order Creation (Checkout)

```
Buyer (Cart Page)
     │
     │── checkoutCart()
     │   └─► calls Firebase Cloud Function: "createSecureOrder"
     │         │
     │         ├─► Creates order doc in `orders` collection
     │         │     orderId: auto-generated
     │         │     customerId: buyerUid
     │         │     sellerId: extracted from cart items
     │         │     status: "New"
     │         │     items: [...cart items]
     │         │     totalAmount: calculated
     │         │     timestamp: now
     │         │
     │         ├─► Clears buyer's cart
     │         │     users/{buyerId}/cart/ → delete all
     │         │
     │         └─► Sends push notification to seller
     │               (via FCM — seller's token from users/{sellerId}/fcmToken)
     │
Seller (Orders List)
     │◄── real-time stream detects new order ────┘
     │   status: "New" → shows in seller's pending orders
     │
     ├─► AudioNotificationService plays "new_order.mp3"
     └─► Seller taps → navigates to NewOrderNotification UI
```

**Real-Time Status:** ✅ **Full real-time (stream + FCM push)**

---

#### Flow 6: Wallet → Order Payment Flow

```
Buyer (Wallet)                    Firestore                    Seller (Wallet / Dashboard)
     │                              │                              │
     │── Razorpay payment ──────► (external)                       │
     │   (top-up or pay)           │                              │
     │                              │                              │
Buyer (Cart → Checkout)            │                              │
     │── order placed ──────────► orders/{orderId}                │
     │   paymentMethod: "Wallet"   │    paymentStatus: "Paid"      │
     │   or "COD"                  │                              │
     │                              │◄── real-time stream ────────┤
     │                              │   order count + revenue      │
     │                              │                              │
     │                              │         Seller's wallet      │
     │                              │◄── updated on delivery ─────┤
     │                              │   sellers/{id}/walletBalance │
```

**BLoC Chain:** `WalletBloc` (buyer) + `CartBloc` (checkout) → `SellerWalletBloc` (seller balance) + `SellerDashboardPageBloc` (revenue)

**Real-Time Status:** ⚠️ **Order sync is real-time ✅. Seller wallet balance updates are Future-based ❌ — no real-time stream for balance changes**

---

### 🟡 CROSS-DATA-FLOW SUMMARY MATRIX

| Data Entity | Buyer Page(s) | Seller Page(s) | Firestore Collection | Sync Method | Real-Time? |
|------------|---------------|----------------|---------------------|-------------|-----------|
| **Orders** | `Order Page`, `Track Order` | `Orders List`, `New Order Notification`, `Dashboard` | `orders` | Firestore `.snapshots()` stream | ✅ |
| **Products** | `Home Page`, `Details Page` | `Product List`, `Add Product`, `Dashboard` | `products` | Firestore `.snapshots()` stream | ✅ |
| **Chat** | `Chat Page` | `Chat Support` | `conversations`, `messages` | Firestore `.snapshots()` stream | ✅ |
| **Ratings** | `Details Page` | `Overall Rating` | `products/{id}/reviews`, `users/{uid}/ratings` | Buyer: stream ✅ / Seller: Future-based ⚠️ | ⚠️ Partial |
| **Cart → Order** | `Cart Page` | `Orders List` | `orders` | Cloud Function + Firestore stream | ✅ |
| **Payment/Wallet** | `Wallet`, `Payment Methods` | `Wallet`, `Payout`, `Dashboard` | `sellers/{id}`, `users/{id}`, `payouts` | Future-based on seller side ❌ | ⚠️ Partial |
| **Inventory** | `Details Page` (stock qty) | `Inventory`, `Product List` | `products` (quantity field) | Real-time stream on seller ✅, buyer sees product changes ✅ | ✅ |
| **Favorites** | `Favorites Page` | — (seller sees popularity) | `users/{uid}/favorites` | Buyer stream ✅ → Seller needs analytics | ❌ No seller view |
| **Settings** | `App Settings`, `Profile` | `Settings`, `Store Details`, `Profile` | `users/{uid}`, `sellers/{id}` | Future-based (both sides) | ❌ No |

---

## 4. Gap Analysis — Mocked Pages Needing Firebase Connection

### 🔴 CRITICAL GAPS (Must Fix)

#### Gap 1: New Order Notification (Seller) — Fully Mocked

**Current State:**
- **File:** `lib/features/seller_bloc_architecture/new_order_notification/`
- `NewOrderNotificationService` has **500ms simulated delays** with hardcoded data
- No real Firebase calls for accept/reject
- No real FCM push notification integration

**What Should Happen:**
```
Seller's FCM receives push → taps notification → opens NewOrderNotificationPage
                                                            │
                    ┌───────────────────────────────────────┤
                    │                                       │
                    ▼                                       ▼
            Accept Order                               Reject Order
                    │                                       │
                    ▼                                       ▼
    orders/{orderId}.update({                 orders/{orderId}.update({
      status: "Accepted",                      status: "Rejected",
      acceptedAt: timestamp,                   rejectedAt: timestamp,
      preparationTime: X min                   rejectionReason: "..."
    })                                        })
                    │                                       │
                    ▼                                       ▼
    Auto-create conversation               Buyer receives FCM
    via IChatRepository                    "Your order was rejected"
    + Send FCM to buyer:
    "Your order is being prepared!"
```

**Firebase Implementation Plan:**
```dart
// NewOrderNotificationService — REAL IMPLEMENTATION
class NewOrderNotificationService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<OrderModel> loadOrderDetails(String orderId) async {
    final doc = await _firestore.collection('orders').doc(orderId).get();
    return OrderModel.fromFirestore(doc);
  }

  Future<void> acceptOrder(String orderId, int prepTime) async {
    await _firestore.collection('orders').doc(orderId).update({
      'status': OrderStatus.accepted.value,
      'acceptedAt': FieldValue.serverTimestamp(),
      'preparationTime': prepTime,
    });
    // Auto-create conversation
    final order = await loadOrderDetails(orderId);
    await _chatRepository.createConversation(
      buyerId: order.customerId,
      sellerId: order.sellerId,
      orderId: orderId,
    );
    // Send FCM to buyer
    await _fcmService.sendNotification(
      userId: order.customerId,
      title: 'Order Accepted',
      body: 'Your order is being prepared!',
    );
  }

  Future<void> rejectOrder(String orderId, String reason) async {
    await _firestore.collection('orders').doc(orderId).update({
      'status': OrderStatus.rejected.value,
      'rejectedAt': FieldValue.serverTimestamp(),
      'rejectionReason': reason,
    });
    // Send FCM to buyer
    final order = await loadOrderDetails(orderId);
    await _fcmService.sendNotification(
      userId: order.customerId,
      title: 'Order Rejected',
      body: reason,
    );
  }
}
```

---

#### Gap 2: Out For Delivery Page (Seller) — Fully Mocked

**Current State:**
- **File:** `lib/features/seller_bloc_architecture/out_for_delivery_page_/`
- All rider data is **hardcoded** (mock name, phone, location, OTP)
- No real-time rider location tracking from seller side
- No connection to `riders` collection

**What Should Happen:**
```
Seller (Assign Delivery)                Firestore                  
     │                                      │
     │── assignRider(orderId, riderId) ──► orders/{orderId}        
     │   status: "OutForDelivery"           │  assignedRiderId
     │                                      │  deliveryOTP
     │                                      │
Seller (Out For Delivery Page)              │
     │                                      │
     │◄── real-time rider location ────────┤
     │   riders/{riderId}/currentLocation   │
     │   (lat, lng, updatedAt)              │
     │                                      │
     │── callRider() ──► (phone dial)       │
     │── messageRider() ──► (chat)          │
```

**Firebase Implementation Plan:**
```dart
class OutForDeliveryRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<RiderModel> riderLocationStream(String riderId) {
    return _firestore
        .collection('riders')
        .doc(riderId)
        .snapshots()
        .map((doc) => RiderModel.fromFirestore(doc));
  }

  Future<DeliveryDetails> loadDeliveryDetails(String orderId) async {
    final orderDoc = await _firestore.collection('orders').doc(orderId).get();
    final order = OrderModel.fromFirestore(orderDoc);
    if (order.assignedRiderId == null) throw Exception('No rider assigned');
    
    final riderDoc = await _firestore
        .collection('riders')
        .doc(order.assignedRiderId)
        .get();
    final rider = RiderModel.fromFirestore(riderDoc);
    
    return DeliveryDetails(order: order, rider: rider);
  }
}
```

---

#### Gap 3: Assign Delivery (Seller) — Rider List is Mocked

**Current State:**
- **File:** `lib/features/seller_bloc_architecture/assign_delivery_page_/`
- Rider list is **hardcoded mock** with simulated 1-second delay
- No real query to `riders` collection
- Assignment writes to Firestore correctly (order status + riderId)

**Firebase Implementation Plan:**
```dart
// In AssignDeliveryRepository
Future<List<RiderModel>> loadAvailableRiders(String sellerId) async {
  // Query riders collection for available riders in seller's area
  final snapshot = await _firestore
      .collection('riders')
      .where('isAvailable', isEqualTo: true)
      .where('serviceAreas', arrayContains: sellerId)
      .get();
  return snapshot.docs.map((doc) => RiderModel.fromFirestore(doc)).toList();
}

Future<void> assignRider(String orderId, String riderId, String instructions) async {
  await _firestore.collection('orders').doc(orderId).update({
    'status': OrderStatus.outForDelivery.value,
    'assignedRiderId': riderId,
    'deliveryInstructions': instructions,
    'assignedAt': FieldValue.serverTimestamp(),
    'deliveryOtp': _generateDeliveryOtp(), // 4-digit OTP
  });
  // Notify rider via FCM
  await _fcmService.sendNotification(
    userId: riderId,
    title: 'New Delivery',
    body: 'You have a new delivery assignment',
  );
}
```

---

#### Gap 4: Low Stock Alert (Seller) — Fully Mocked

**Current State:**
- **File:** `lib/features/seller_bloc_architecture/add_product_page_/low_stock_alert_page__bloc.dart`
- Fully mocked with 1-second simulated delay and hardcoded list of 3 items
- Not connected to real inventory data

**Firebase Implementation Plan:**
```dart
class LowStockAlertBloc extends Bloc<LowStockAlertEvent, LowStockAlertState> {
  LowStockAlertBloc({required String sellerId}) : super(LowStockAlertInitial()) {
    on<LoadLowStockData>((event, emit) async {
      emit(LowStockAlertLoading());
      try {
        // Real-time stream from products collection
        await emit.forEach(
          _productRepository.getProductsStream(sellerId),
          onData: (products) {
            final lowStock = products
                .where((p) => p.quantity < p.lowStockThreshold)
                .toList();
            return LowStockAlertLoaded(
              items: lowStock,
              totalLowStockCount: lowStock.length,
            );
          },
          onError: (error, _) => LowStockAlertError(error.toString()),
        );
      } catch (e) {
        emit(LowStockAlertError(e.toString()));
      }
    });
  }
}
```

**Key Change:** Transform the existing `InventoryBloc`'s real-time stream to also emit low-stock alerts. Add a `lowStockThreshold` field to `Product` model (currently may not exist).

---

#### Gap 5: Overall Rating (Seller) — No Real-Time Stream

**Current State:**
- Uses Future-based `.get()` on `reviews` collection
- No real-time updates — seller must manually refresh
- Connected to `SellerReviewService` which does Firestore queries correctly

**Upgrade to Real-Time:**
```dart
// In OverallRatingRepository
Stream<OverallRatingData> getRatingStream(String sellerId) {
  return _firestore
      .collection('products')
      .where('sellerId', isEqualTo: sellerId)
      .snapshots()
      .asyncMap((snapshot) async {
    double totalRating = 0;
    int totalReviews = 0;
    List<ReviewModel> reviews = [];

    for (var productDoc in snapshot.docs) {
      final reviewsSnapshot = await productDoc.reference
          .collection('reviews')
          .orderBy('createdAt', descending: true)
          .get();
      
      for (var reviewDoc in reviewsSnapshot.docs) {
        final review = ReviewModel.fromFirestore(reviewDoc);
        reviews.add(review);
        totalRating += review.rating;
        totalReviews++;
      }
    }

    return OverallRatingData(
      overallRating: totalReviews > 0 ? totalRating / totalReviews : 0,
      totalReviews: totalReviews,
      reviews: reviews,
    );
  });
}
```

Alternatively, maintain a `reviews` collection at root level (not subcollection of products) for easier querying:
```dart
// New root-level collection: reviews
_firestore.collection('reviews')
    .where('sellerId', isEqualTo: sellerId)
    .orderBy('createdAt', descending: true)
    .snapshots()
```

---

#### Gap 6: Seller Wallet Balance — No Real-Time Stream

**Current State:**
- `SellerWalletBloc` uses Future-based `.get()` for balance
- When a new order is delivered, seller wallet updates, but seller must refresh

**Upgrade to Real-Time:**
```dart
// In SellerWalletRepository
Stream<double> getWalletBalanceStream(String sellerId) {
  return _firestore
      .collection('sellers')
      .doc(sellerId)
      .snapshots()
      .map((doc) => (doc.data()?['walletBalance'] ?? 0.0).toDouble());
}

Stream<List<PayoutModel>> getPayoutHistoryStream(String sellerId) {
  return _firestore
      .collection('payouts')
      .where('sellerId', isEqualTo: sellerId)
      .orderBy('createdAt', descending: true)
      .snapshots()
      .map((snapshot) => snapshot.docs
          .map((doc) => PayoutModel.fromFirestore(doc))
          .toList());
}
```

---

### 🟡 MEDIUM GAPS (Nice to Have)

#### Gap 7: Seller Analytics — No Real-Time

Upgrade `SellerAnalyticsBloc` to use Firestore `.snapshots()` stream instead of `.get()` for real-time dashboard updates.

#### Gap 8: Seller Customers — No Real-Time

Upgrade `SellerCustomerBloc` to listen to `orders` collection stream and recompute customer stats reactively.

#### Gap 9: Help & Support Tickets — No Cross-Role Visibility

Buyer submissions (`users/{uid}/support_tickets/`) are not visible to Seller. Should sync to a shared `support_tickets` collection visible to admin/seller dashboard.

#### Gap 10: Favorites Data — Not Visible to Seller

Buyer favorites (`users/{uid}/favorites/`) are not aggregated. Seller cannot see most-liked products. Add an aggregation pipeline:
```dart
// Cloud Function: onFavoritesWrite → increment productFavoritesCount
exports.incrementFavoritesCount = functions.firestore
    .document('users/{uid}/favorites/{productId}')
    .onWrite((change, context) => {
      const productRef = admin.firestore()
          .collection('products').doc(context.params.productId);
      if (!change.before.exists && change.after.exists) {
        return productRef.update({ favoritesCount: admin.firestore.FieldValue.increment(1) });
      }
      if (change.before.exists && !change.after.exists) {
        return productRef.update({ favoritesCount: admin.firestore.FieldValue.increment(-1) });
      }
      return null;
    });
```

---

## 5. Firebase Firestore Collections Map

```
Firestore Root
│
├── users/                          # Buyer & User data
│   └── {userId}/
│       ├── cart/                   # CartItem[]
│       ├── favorites/              # FavoriteItem[]
│       ├── ratings/                # User's ratings
│       ├── transactions/           # Wallet transactions
│       ├── payment_methods/        # Saved payment methods
│       ├── support_tickets/        # Help & support tickets
│       ├── feedback/               # User feedback
│       └── settings/
│           └── app                 # App settings
│
├── sellers/                        # Seller data
│   └── {sellerId}/
│       ├── promotions/             # Coupons & offers
│       ├── menu_preferences/       # Selected categories + order
│       ├── settings/
│       │   └── business_hours      # Operating hours
│       ├── payment/
│       │   └── details             # Bank account info
│       └── disputes/               # Disputes & refunds
│
├── products/                       # Shared by Buyer & Seller
│   └── {productId}/
│       └── reviews/                # Product reviews (subcollection)
│
├── orders/                         # Shared by Buyer & Seller ← KEY
│   └── {orderId}
│       ├── status: OrderStatus
│       ├── customerId: string
│       ├── sellerId: string
│       ├── items: OrderItem[]
│       ├── totalAmount: number
│       ├── assignedRiderId: string?
│       └── timestamp: Timestamp
│
├── conversations/                  # Shared Chat
│   └── {conversationId}/
│       ├── buyerId: string
│       ├── sellerId: string
│       ├── orderId: string?
│       ├── messages/               # Message[]
│       ├── photos/                 # PhotoMessage[]
│       ├── videos/                 # VideoMessage[]
│       └── audios/                 # AudioMessage[]
│
├── riders/                         # Delivery Riders (Seller uses)
│   └── {riderId}/
│       ├── name: string
│       ├── phone: string
│       ├── isAvailable: boolean
│       ├── currentLocation: GeoPoint
│       └── serviceAreas: string[]
│
├── payouts/                        # Seller payout history
│   └── {payoutId}
│
├── payout_requests/               # Pending payout requests
│   └── {requestId}
│
├── global_categories/             # Shared categories
│
├── inventory_logs/                # Inventory change logs
│
└── seller_notification_settings/  # Seller notification prefs
```

---

## 6. Real-Time Stream Architecture Diagram

```
                   ┌─────────────────────────────────────────────┐
                   │              FIREBASE FIRESTORE              │
                   │                                             │
                   │  ┌──────────┐  ┌──────────┐  ┌──────────┐  │
                   │  │  orders  │  │ products │  │   chat   │  │
                   │  │    📄    │  │    📄    │  │   💬     │  │
                   │  └────┬─────┘  └────┬─────┘  └────┬─────┘  │
                   │       │              │              │        │
                   └───────┼──────────────┼──────────────┼────────┘
                           │              │              │
           ┌───────────────┼──────┐       │       ┌──────┼───────────────┐
           │               │      │       │       │      │               │
           ▼               ▼      │       ▼       │      ▼               ▼
   ┌──────────────┐ ┌──────────┐ │ ┌───────────┐ │ ┌──────────┐ ┌──────────────┐
   │  Buyer App   │ │  Buyer   │ │ │  Seller   │ │ │  Seller  │ │  Seller App  │
   │  Order Page  │ │ HomePage │ │ │Dashboard  │ │ │ProductList│ │  Chat Support│
   │  (snapshots) │ │(snapshots│ │ │(combine3) │ │ │(snapshots│ │  (snapshots) │
   └──────────────┘ └──────────┘ │ └───────────┘ │ └──────────┘ └──────────────┘
                                 │               │
                                 ▼               ▼
                         ┌──────────────┐ ┌───────────────────┐
                         │  Buyer       │ │  Seller           │
                         │  Track Order │ │  Orders List      │
                         │  (snapshots) │ │  (snapshots)      │
                         └──────────────┘ └───────────────────┘
                                              │
                                              ▼
                                     ┌───────────────────┐
                                     │  Seller           │
                                     │  Inventory        │
                                     │  (snapshots)      │
                                     └───────────────────┘

Streaming Pages:    8 Buyer + 6 Seller = 14 pages with real-time Firestore streams
Future-based Pages: 9 Buyer + 23 Seller = 32 pages with synchronous calls
Mocked Pages:       0 Buyer + 4 Seller = 4 pages with no real backend
```

---

## 7. Recommendations & Implementation Plan

### Priority Matrix

| Priority | Gap | Effort | Impact | Current State |
|----------|-----|--------|--------|---------------|
| 🔴 P0 | New Order Notification | Medium | High | Fully Mocked |
| 🔴 P0 | Assign Delivery (riders) | Medium | High | Partially Mocked |
| 🔴 P0 | Out For Delivery | Medium | High | Fully Mocked |
| 🔴 P0 | Low Stock Alert | Low | Medium | Fully Mocked |
| 🟡 P1 | Overall Rating → Real-time | Low | Medium | Future-based |
| 🟡 P1 | Seller Wallet → Real-time | Low | Medium | Future-based |
| 🟡 P1 | Seller Analytics → Stream | Medium | Low | Future-based |
| 🟢 P2 | Favorites → Seller Analytics | Medium | Low | Not Visible |
| 🟢 P2 | Support Tickets → Cross-role | Low | Low | Buyer-only |
| 🟢 P2 | Seller Customers → Stream | Medium | Low | Future-based |

### Implementation Roadmap

```
Phase 1 (Week 1-2): Fix Mocked Pages
  ├── New Order Notification → Firebase real accept/reject + FCM
  ├── Assign Delivery → Real riders query from Firestore
  ├── Out For Delivery → Real rider location stream
  └── Low Stock Alert → Real-time inventory threshold check

Phase 2 (Week 3-4): Upgrade to Real-Time
  ├── Overall Rating → Switch from .get() to .snapshots()
  ├── Seller Wallet → Add snapshots() for balance/payouts
  └── Seller Analytics → Add real-time order stream

Phase 3 (Week 5-6): Cross-Role Features
  ├── Favorites aggregation for Seller
  ├── Support Tickets sharing
  └── Seller Customers real-time updates
```

### Key Architecture Patterns to Follow

```dart
// PATTERN 1: Real-time stream in BLoC (emit.forEach)
on<LoadOrdersRequested>((event, emit) async {
  emit(OrderLoading());
  await emit.forEach(
    _orderRepository.getBuyerOrdersStream(userId),
    onData: (orders) => OrderLoaded(orders: orders),
    onError: (error, _) => OrderError(message: error.toString()),
  );
});

// PATTERN 2: Real-time stream with Rx.combineLatest
Stream<DashboardData> getDashboardData(String sellerId) {
  return Rx.combineLatest3(
    _firestore.collection('orders')
        .where('sellerId', isEqualTo: sellerId).snapshots(),
    _firestore.collection('products')
        .where('sellerId', isEqualTo: sellerId).snapshots(),
    _firestore.collection('sellers').doc(sellerId).snapshots(),
    (ordersSnap, productsSnap, sellerDoc) => DashboardData(
      orders: ordersSnap.docs.map(OrderModel.fromFirestore).toList(),
      products: productsSnap.docs.map(Product.fromFirestore).toList(),
      seller: SellerModel.fromFirestore(sellerDoc),
    ),
  );
}

// PATTERN 3: Firestore Transaction (for critical writes)
Future<void> processWithdrawal(String sellerId, double amount) async {
  await _firestore.runTransaction((transaction) async {
    final sellerRef = _firestore.collection('sellers').doc(sellerId);
    final sellerDoc = await transaction.get(sellerRef);
    final balance = (sellerDoc.data()?['walletBalance'] ?? 0).toDouble();
    if (balance < amount) throw Exception('Insufficient balance');
    transaction.update(sellerRef, {'walletBalance': balance - amount});
    transaction.set(
      _firestore.collection('payout_requests').doc(),
      {'sellerId': sellerId, 'amount': amount, 'status': 'Pending'},
    );
  });
}
```

---

## 📊 Final Statistics

| Metric | Buyer | Seller | Total |
|--------|-------|--------|-------|
| **Pages** | 17 | 29 | 46 |
| **Real-Time Stream Pages** | 8 (47%) | 6 (21%) | 14 (30%) |
| **Future-Based Pages** | 9 (53%) | 19 (65%) | 28 (61%) |
| **Mocked Pages (No Backend)** | 0 (0%) | 4 (14%) | 4 (9%) |
| **BLoCs** | 14 | 22 | 36 |
| **Repositories** | 12 | 20 | 32 |
| **Shared Models** | — | — | 10 |
| **Shared Repository Interfaces** | — | — | 6 |
| **Firebase Services Used** | Auth, Firestore, Storage, Functions, FCM | Auth, Firestore, Storage, FCM | 5 services |

### ✅ Already Working in Real-Time
1. **Orders:** Buyer Order → Seller Accept/Reject → Buyer Track (full cycle)
2. **Products:** Seller Add/Update → Buyer Browse (instant sync)
3. **Chat:** Buyer ↔ Seller (bidirectional real-time)
4. **Inventory:** Seller stock changes → reflected in real-time
5. **Cart:** Real-time cart management for buyer

### ❌ Needs Immediate Fix
1. **New Order Notification (Seller)** — Replace mock with real Firebase
2. **Out For Delivery (Seller)** — Replace mock with real rider tracking
3. **Assign Delivery (Seller)** — Replace mock rider list with Firestore query
4. **Low Stock Alert (Seller)** — Connect to real inventory stream

### ⚠️ Needs Upgrade
1. **Overall Rating (Seller)** — Add real-time stream
2. **Seller Wallet** — Add real-time balance updates
3. **Seller Analytics** — Add real-time data pipeline

---

*Report generated by BLoC Architecture Audit — July 28, 2026*
