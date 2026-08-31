# 📋 17. Orders Pipeline List & Kanban Page — Human Journey & Real-Time Testing Blueprint

**Document ID:** `SELLER-DOC-17-ORDERS-PIPELINE`  
**Classification:** Phase 5: Real-Time Kitchen Orders & Dispatch (Kitchen Execution Pipeline)  
**Target Screen:** [OrdersListPage](file:///d:/Flutter_Project/food_delivery_app/lib/features/seller_bloc_architecture/orders_list/orders_list_page_ui.dart)  
**Target BLoC:** [OrdersListBloc](file:///d:/Flutter_Project/food_delivery_app/lib/features/seller_bloc_architecture/orders_list/orders_list_page_bloc.dart)  
**Canonical Typedef Alias:** `OrderBloc`  
**Order Details Screen:** `OrderDetailsScreen` in [orders_list_page_ui.dart](file:///d:/Flutter_Project/food_delivery_app/lib/features/seller_bloc_architecture/orders_list/orders_list_page_ui.dart)  
**Service Layer:** [OrdersListService](file:///d:/Flutter_Project/food_delivery_app/lib/features/seller_bloc_architecture/orders_list/orders_list_page_service.dart)  
**Zero-Mock Compliance:** ✅ Continuous real-time Firestore stream (`orders` across full 7-stage lifecycle)  

---

## 🚶‍♂️ 1. Human Journey Context & User Flow

### 🎯 Step Overview
The **Orders Pipeline List & Kanban** is the kitchen execution core. Restaurant staff manage active food preparation across strict operational statuses: **Placed -> Confirmed -> Preparing -> Ready for Pickup -> Out for Delivery -> Delivered -> Cancelled**. Staff can inspect complete dish breakdowns, special notes, customer delivery addresses, initiate delivery rider dispatch, and handle cancellations with mandatory reason logging.

```mermaid
sequenceDiagram
    autonumber
    actor Kitchen as 👨‍🍳 Kitchen Head
    participant UI as OrdersListPage
    participant Details as OrderDetailsScreen
    participant Bloc as OrdersListBloc
    participant Service as OrdersListService
    participant FS as Cloud Firestore (orders)
    participant RiderApp as 🛵 Delivery Partner
    participant BuyerApp as 📱 Live Buyer Apps

    UI->>Bloc: add(LoadOrdersStream(sellerId))
    Bloc->>Service: streamOrders(sellerId)
    Service->>FS: collection('orders').where('sellerId', '==', uid).snapshots()
    FS-->>Service: Real-time orders stream
    Service-->>Bloc: Emits updated orders list
    Bloc-->>UI: emit(OrdersListLoaded(allOrders, filteredOrders, activeFilter: 'all'))
    Kitchen->>UI: Taps Order #ORD-4402 -> Opens Order Details Screen
    Kitchen->>Details: Finishes cooking -> Taps "Mark Food Ready for Pickup"
    Details->>Bloc: add(UpdateOrderStatusEvent('ORD-4402', OrderStatus.ready))
    Bloc->>Service: updateOrderStatus('ORD-4402', OrderStatus.ready)
    Service->>FS: doc('orders/ORD-4402').update({ status: 'ready', readyAt: SERVER_TIMESTAMP })
    FS-->>RiderApp: Push notification: "Order #ORD-4402 is ready for pickup!"
    FS-->>BuyerApp: Buyer tracking updates: "Food is ready & waiting for rider!"
    Bloc-->>UI: emit(OrdersListLoaded with updated badge tallies)
```

### 🛣️ Navigation Preconditions & Route
- **Route Name:** `/ordersPipeline`
- **Preceding Screen:** [SellerDashboardPageUI](file:///d:/Flutter_Project/food_delivery_app/lib/features/seller_bloc_architecture/seller_dashboard_page/seller_dashboard_page_ui.dart) (Orders Tab / Card Tap).
- **Subsequent Screen:** [AssignDeliveryPageUI](file:///d:/Flutter_Project/food_delivery_app/lib/features/seller_bloc_architecture/assign_delivery_page_/assign_delivery_page__ui.dart) or [OutForDeliveryPageUI](file:///d:/Flutter_Project/food_delivery_app/lib/features/seller_bloc_architecture/out_for_delivery_page_/out_for_delivery_page__ui.dart).

---

## 🏛️ 2. BLoC / Cubit Architecture Mapping

### 🧩 Presentation Layer
- **Widget:** [OrdersListPage](file:///d:/Flutter_Project/food_delivery_app/lib/features/seller_bloc_architecture/orders_list/orders_list_page_ui.dart)
- **Detail Screen:** `OrderDetailsScreen`, `_Order7StageTimeline`, `_CustomerDetailsCard`, `_DeliveryAddressCard`, `_OrderItemsCard`, `_PriceBreakdownCard`, `_PaymentStatusCard`, `_DeliveryPartnerCard`.
- **UI Design Tokens:** [SellerUiTokens](file:///d:/Flutter_Project/food_delivery_app/lib/features/seller_bloc_architecture/seller_ui_tokens.dart).

### ⚡ BLoC Event Matrix
| Event Class | Trigger Action | Payload Parameters |
|---|---|---|
| `LoadOrdersStream` | Initial page load and stream binding | `String sellerId` |
| `FilterOrders` | Merchant selects status filter tab (All, Placed, Preparing, Ready, Out, Completed) | `String status` |
| `SearchOrders` | Merchant searches by order ID or customer name | `String query` |
| `ClearMessages` | Dismisses success/error toast notifications | None |
| `UpdateOrderStatusEvent` | Transition order status to next lifecycle step | `String orderId, OrderStatus newStatus, String? reason` |
| `CancelOrderEvent` | Merchant cancels order with explicit reason | `String orderId, String reason` |
| `RejectOrderEvent` | Merchant rejects placed order | `String orderId, String reason` |

### 📊 BLoC State Matrix
- **State Base Class:** [OrdersListState](file:///d:/Flutter_Project/food_delivery_app/lib/features/seller_bloc_architecture/orders_list/orders_list_page_state.dart)
- **Sub-States:**
  - `OrdersListInitial`: Initial state.
  - `OrdersListLoading`: Emitted while connecting to orders stream.
  - `OrdersListLoaded`: Contains `List<OrderModel> allOrders`, `List<OrderModel> filteredOrders`, `String activeFilter`, `String searchQuery`, `Set<String> updatingOrderIds`, `String? errorMessage`, `String? successMessage`. Helper `getCount(status)` computes realtime tab badge counts.
  - `OrdersListError`: Contains error details.

---

## 🔥 3. Real-Time Cloud Firestore Integration

### 📦 Database Documents & Rules
- **Target Collection:** `orders`
- **Security Rules:**
  ```javascript
  match /orders/{orderId} {
    allow read: if request.auth != null && (resource.data.sellerId == request.auth.uid || resource.data.customerId == request.auth.uid);
    allow update: if request.auth != null && resource.data.sellerId == request.auth.uid;
  }
  ```
- **Order Model Lifecycle:** Real-time updates push automatically to Firestore, triggering Cloud Functions for FCM alerts and delivery rider notifications.

---

## 🛡️ 4. Validation, Error Handling & Edge Cases

| Scenario | Validation Check | Handled State & UI Message |
|---|---|---|
| **Cancellation Without Reason** | `reason.trim().isEmpty` | Form blocks cancellation: "Please provide a cancellation reason." |
| **Illegal Status Transition** | Transitioning backwards (e.g. Delivered -> Preparing) | State machine check prevents invalid status regression |
| **Concurrent Rider Assignment** | Order status changed by rider simultaneously | Firestore snapshot syncs and updates UI immediately |

---

## 🧪 5. 14 Mandatory QA Test Categories Suite

```
┌──────────────────────────────────────────────────────────────────────────────────────────────────┐
│                               14-CATEGORY QA VERIFICATION MATRIX                                 │
├────┬────────────────────────┬─────────────────────────┬──────────────────────────────────────────┤
│ #  │ Test Category          │ Status                  │ Test Target & Verification Focus         │
├────┼────────────────────────┼─────────────────────────┼──────────────────────────────────────────┤
│ 01 │ Unit Tests             │ ✅ Verified             │ OrderModel & 7-stage state machine tests │
│ 02 │ Widget Tests           │ ✅ Verified             │ Orders list, filter chips & timeline UI  │
│ 03 │ BLoC Tests             │ ✅ Verified             │ Status transition & search stream tests  │
│ 04 │ Integration Tests      │ ✅ Verified             │ Placed -> Prep -> Ready -> Dispatch flow │
│ 05 │ Golden Tests           │ ✅ Configured           │ Orders pipeline card & details snapshot  │
│ 06 │ Performance Tests      │ ✅ Verified (<16ms)     │ 60 FPS order list scroll performance     │
│ 07 │ Accessibility Tests    │ ✅ Verified             │ Status chips & order action touch targets│
│ 08 │ Security Tests         │ ✅ Verified             │ Merchant-isolated order query scoping    │
│ 09 │ Localization Tests     │ ✅ Verified             │ Status tags translated in Tamil & English│
│ 10 │ Snapshot Tests         │ ✅ Verified             │ Orders list widget tree integrity        │
│ 11 │ Dependency Tests       │ ✅ Verified             │ Mock order service stream emitter        │
│ 12 │ State Restoration      │ ✅ Verified             │ Selected order filter preserved on resume│
│ 13 │ Error Handling Tests   │ ✅ Verified             │ Mutation failure rollback & alert toast  │
│ 14 │ Permission Tests       │ ✅ Verified             │ Standard UI shell permissions            │
└────┴────────────────────────┴─────────────────────────┴──────────────────────────────────────────┘
```

---

## 📁 6. Direct Source & Test Hyperlinks Table

| Resource Type | File Name | Absolute Path Link |
|---|---|---|
| **Presentation UI** | `orders_list_page_ui.dart` | [orders_list_page_ui.dart](file:///d:/Flutter_Project/food_delivery_app/lib/features/seller_bloc_architecture/orders_list/orders_list_page_ui.dart) |
| **BLoC Logic** | `orders_list_page_bloc.dart` | [orders_list_page_bloc.dart](file:///d:/Flutter_Project/food_delivery_app/lib/features/seller_bloc_architecture/orders_list/orders_list_page_bloc.dart) |
| **Events Definition** | `orders_list_page_event.dart` | [orders_list_page_event.dart](file:///d:/Flutter_Project/food_delivery_app/lib/features/seller_bloc_architecture/orders_list/orders_list_page_event.dart) |
| **States Definition** | `orders_list_page_state.dart` | [orders_list_page_state.dart](file:///d:/Flutter_Project/food_delivery_app/lib/features/seller_bloc_architecture/orders_list/orders_list_page_state.dart) |
| **Service Layer** | `orders_list_page_service.dart` | [orders_list_page_service.dart](file:///d:/Flutter_Project/food_delivery_app/lib/features/seller_bloc_architecture/orders_list/orders_list_page_service.dart) |
| **Unit / BLoC Tests** | `orders_list_page_bloc_test.dart` | [orders_list_page_bloc_test.dart](file:///d:/Flutter_Project/food_delivery_app/test/seller_test/unit/orders_list_page_bloc_test.dart) |
| **Widget Tests** | `orders_list_page_ui_test.dart` | [orders_list_page_ui_test.dart](file:///d:/Flutter_Project/food_delivery_app/test/seller_test/widget/orders_list_page_ui_test.dart) |
| **Integration Flow** | `orders_list_page_flow_test.dart` | [orders_list_page_flow_test.dart](file:///d:/Flutter_Project/food_delivery_app/test/seller_test/integration/orders_list_page_flow_test.dart) |
| **Golden Tests** | `orders_list_page_golden_test.dart` | [orders_list_page_golden_test.dart](file:///d:/Flutter_Project/food_delivery_app/test/seller_test/golden/orders_list_page_golden_test.dart) |
| **Accessibility Tests** | `orders_list_page_accessibility_test.dart` | [orders_list_page_accessibility_test.dart](file:///d:/Flutter_Project/food_delivery_app/test/seller_test/accessibility/orders_list_page_accessibility_test.dart) |
| **Performance Tests** | `orders_list_page_performance_test.dart` | [orders_list_page_performance_test.dart](file:///d:/Flutter_Project/food_delivery_app/test/seller_test/performance/orders_list_page_performance_test.dart) |
| **Security Tests** | `orders_list_page_security_test.dart` | [orders_list_page_security_test.dart](file:///d:/Flutter_Project/food_delivery_app/test/seller_test/security/orders_list_page_security_test.dart) |
| **Localization Tests** | `orders_list_page_localization_test.dart` | [orders_list_page_localization_test.dart](file:///d:/Flutter_Project/food_delivery_app/test/seller_test/localization/orders_list_page_localization_test.dart) |
| **State Restoration** | `orders_list_page_state_restoration_test.dart` | [orders_list_page_state_restoration_test.dart](file:///d:/Flutter_Project/food_delivery_app/test/seller_test/state_restoration/orders_list_page_state_restoration_test.dart) |
| **Error Handling** | `orders_list_page_error_handling_test.dart` | [orders_list_page_error_handling_test.dart](file:///d:/Flutter_Project/food_delivery_app/test/seller_test/error_handling/orders_list_page_error_handling_test.dart) |
| **Permission Tests** | `orders_list_page_permission_test.dart` | [orders_list_page_permission_test.dart](file:///d:/Flutter_Project/food_delivery_app/test/seller_test/permission/orders_list_page_permission_test.dart) |
