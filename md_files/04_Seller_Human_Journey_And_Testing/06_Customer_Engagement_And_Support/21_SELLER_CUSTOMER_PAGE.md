# 👥 21. Seller Customer CRM & Analytics Page — Human Journey & Real-Time Testing Blueprint

**Document ID:** `SELLER-DOC-21-CUSTOMER-CRM`  
**Classification:** Phase 6: Customer Engagement & Support (Customer Retention)  
**Target Screen:** [SellerCustomerPageUI](file:///d:/Flutter_Project/food_delivery_app/lib/features/seller_bloc_architecture/seller_customer_page/seller_customer_page__ui.dart)  
**Target BLoC:** [SellerCustomerBloc](file:///d:/Flutter_Project/food_delivery_app/lib/features/seller_bloc_architecture/seller_customer_page/seller_customer_page__bloc.dart)  
**Canonical Typedef Alias:** `CustomerBloc`  
**Data Models:** `CustomerStats`, `CustomerItem`, `CustomerSortOption` in [seller_customer_page__state.dart](file:///d:/Flutter_Project/food_delivery_app/lib/features/seller_bloc_architecture/seller_customer_page/seller_customer_page__state.dart)  
**Zero-Mock Compliance:** ✅ Live Cloud Firestore customer relationship streams & BigQuery aggregates  

---

## 🚶‍♂️ 1. Human Journey Context & User Flow

### 🎯 Step Overview
Restaurant managers inspect their customer base, loyal patron metrics, and repeat purchase trends. The CRM calculates customer lifetime value (LTV), total orders placed, average spend per order, favorite dishes, and last ordered dates. Managers can sort by top spenders or most frequent buyers and initiate direct chat engagements or personalized loyalty coupons.

```mermaid
sequenceDiagram
    autonumber
    actor Manager as 👨‍🍳 Restaurant Manager
    participant UI as SellerCustomerPageUI
    participant Bloc as SellerCustomerBloc
    participant Repo as SellerCustomerRepository
    participant FS as Cloud Firestore (sellers/{uid}/customers)

    UI->>Bloc: add(LoadCustomerData())
    Bloc->>Repo: watchCustomerStats(sellerId)
    Repo->>FS: collection('sellers/{uid}/customers').snapshots()
    FS-->>Repo: Live customer documents snapshot
    Repo-->>Bloc: CustomerDataStreamUpdated(stats, customers)
    Bloc-->>UI: emit(SellerCustomerLoaded(stats, customers, selectedSortOption))
    Manager->>UI: Types "Priya" in search bar
    UI->>Bloc: add(SearchCustomers('Priya'))
    Bloc-->>UI: emit(SellerCustomerLoaded with filtered list)
    Manager->>UI: Selects "Top Spenders" filter
    UI->>Bloc: add(SortCustomers(CustomerSortOption.highestSpent))
    Bloc-->>UI: Reorders customer cards by lifetime spend desc
    Manager->>UI: Taps on customer card
    UI->>Bloc: add(SelectCustomer(customer))
    UI->>Manager: Displays customer profile modal with order history
```

### 🛣️ Navigation Preconditions & Route
- **Route Name:** `/sellerCustomers`
- **Preceding Screen:** [SellerDashboardPageUI](file:///d:/Flutter_Project/food_delivery_app/lib/features/seller_bloc_architecture/seller_dashboard_page/seller_dashboard_page_ui.dart) (CRM quick link).
- **Subsequent Screen:** [ChatSupportPageUI](file:///d:/Flutter_Project/food_delivery_app/lib/features/seller_bloc_architecture/chat_support_page_/chat_support_page_ui.dart) or [PromotionsCouponsPageUI](file:///d:/Flutter_Project/food_delivery_app/lib/features/seller_bloc_architecture/promotions_coupons_page_/promotions_coupons_page_ui.dart).

---

## 🏛️ 2. BLoC / Cubit Architecture Mapping

### 🧩 Presentation Layer
- **Widget:** [SellerCustomerPageUI](file:///d:/Flutter_Project/food_delivery_app/lib/features/seller_bloc_architecture/seller_customer_page/seller_customer_page__ui.dart)
- **Subcomponents:** `_CustomerStatsBanner`, `_CustomerTileCard`, `_SortFilterDropdown`, `_CustomerDetailModal`.
- **UI Design Tokens:** [SellerUiTokens](file:///d:/Flutter_Project/food_delivery_app/lib/features/seller_bloc_architecture/seller_ui_tokens.dart).

### ⚡ BLoC Event Matrix
| Event Class | Trigger Action | Payload Parameters |
|---|---|---|
| `LoadCustomerData` | Initial page load and stream binding | None |
| `RefreshCustomerData` | Pull-to-refresh swipe gesture | None |
| `LoadMoreCustomers` | Pagination trigger on scroll end | None |
| `CustomerDataStreamUpdated` | Internal stream snapshot update | `CustomerStats stats, List<CustomerItem> customers` |
| `SearchCustomers` | Merchant searches by name, phone or email | `String query` |
| `SortCustomers` | Sort by most recent, highest spent, order count | `CustomerSortOption sortOption` |
| `SelectCustomer` | Merchant taps customer tile for detail drilldown | `CustomerItem? customer` |

### 📊 BLoC State Matrix
- **State Base Class:** [SellerCustomerPageState](file:///d:/Flutter_Project/food_delivery_app/lib/features/seller_bloc_architecture/seller_customer_page/seller_customer_page__state.dart)
- **Sub-States:**
  - `SellerCustomerInitial`: Initial state.
  - `SellerCustomerLoading`: Emitted while connecting to Firestore stream.
  - `SellerCustomerLoaded`: Contains `CustomerStats stats`, `List<CustomerItem> customers`, `List<CustomerItem> filteredCustomers`, `CustomerSortOption sortOption`, `String searchQuery`, `CustomerItem? selectedCustomer`.
  - `SellerCustomerError`: Contains `String message`.

---

## 🔥 3. Real-Time Cloud Firestore Integration

### 📦 Database Documents & Aggregates
- **Target Collection:** `sellers/{sellerId}/customers`
- **Customer Document Schema:**
  ```json
  {
    "id": "cust_88291",
    "name": "Priya Sundaram",
    "email": "priya@gmail.com",
    "phone": "+919840123456",
    "totalOrders": 18,
    "totalSpent": 6450.0,
    "favoriteDish": "Paneer Butter Masala",
    "lastOrderDate": "SERVER_TIMESTAMP",
    "loyaltyTier": "Gold"
  }
  ```
- **Zero-Mock Guarantee:** Customer metrics compute from real-time customer document streams and historical order receipts.

---

## 🛡️ 4. Validation, Error Handling & Edge Cases

| Scenario | Validation Check | Handled State & UI Message |
|---|---|---|
| **No Matching Search** | `filteredCustomers.isEmpty` | `No customers matching "${query}"` |
| **Phone Privacy Masking** | Customer contact display | Middle 4 digits masked (e.g. `+91 9840•••456`) |
| **Stream Disconnection** | Offline socket timeout | Retry banner with cached CRM metrics |

---

## 🧪 5. 14 Mandatory QA Test Categories Suite

```
┌──────────────────────────────────────────────────────────────────────────────────────────────────┐
│                               14-CATEGORY QA VERIFICATION MATRIX                                 │
├────┬────────────────────────┬─────────────────────────┬──────────────────────────────────────────┤
│ #  │ Test Category          │ Status                  │ Test Target & Verification Focus         │
├────┼────────────────────────┼─────────────────────────┼──────────────────────────────────────────┤
│ 01 │ Unit Tests             │ ✅ Verified             │ CustomerStats & LTV math calculation     │
│ 02 │ Widget Tests           │ ✅ Verified             │ Customer tile, search bar & sort filter  │
│ 03 │ BLoC Tests             │ ✅ Verified             │ Search query & sorting event emissions   │
│ 04 │ Integration Tests      │ ✅ Verified             │ Real-time customer profile drilldown     │
│ 05 │ Golden Tests           │ ✅ Configured           │ Customer CRM list & modal visual snapshot│
│ 06 │ Performance Tests      │ ✅ Verified (<16ms)     │ High-volume customer list 60 FPS scroll  │
│ 07 │ Accessibility Tests    │ ✅ Verified             │ Customer card accessibility actions      │
│ 08 │ Security Tests         │ ✅ Verified             │ PII masking & strict sellerId scoping    │
│ 09 │ Localization Tests     │ ✅ Verified             │ Loyalty tier & currency in Tamil/English │
│ 10 │ Snapshot Tests         │ ✅ Verified             │ CRM screen widget hierarchy stability    │
│ 11 │ Dependency Tests       │ ✅ Verified             │ Mock repository stream emitter           │
│ 12 │ State Restoration      │ ✅ Verified             │ Search query & sort option state restore │
│ 13 │ Error Handling Tests   │ ✅ Verified             │ Network error state with retry button    │
│ 14 │ Permission Tests       │ ✅ Verified             │ Standard UI shell permissions            │
└────┴────────────────────────┴─────────────────────────┴──────────────────────────────────────────┘
```

---

## 📁 6. Direct Source & Test Hyperlinks Table

| Resource Type | File Name | Absolute Path Link |
|---|---|---|
| **Presentation UI** | `seller_customer_page__ui.dart` | [seller_customer_page__ui.dart](file:///d:/Flutter_Project/food_delivery_app/lib/features/seller_bloc_architecture/seller_customer_page/seller_customer_page__ui.dart) |
| **BLoC Logic** | `seller_customer_page__bloc.dart` | [seller_customer_page__bloc.dart](file:///d:/Flutter_Project/food_delivery_app/lib/features/seller_bloc_architecture/seller_customer_page/seller_customer_page__bloc.dart) |
| **Events Definition** | `seller_customer_page__event.dart` | [seller_customer_page__event.dart](file:///d:/Flutter_Project/food_delivery_app/lib/features/seller_bloc_architecture/seller_customer_page/seller_customer_page__event.dart) |
| **States Definition** | `seller_customer_page__state.dart` | [seller_customer_page__state.dart](file:///d:/Flutter_Project/food_delivery_app/lib/features/seller_bloc_architecture/seller_customer_page/seller_customer_page__state.dart) |
| **Unit / BLoC Tests** | `seller_customer_page__bloc_test.dart` | [seller_customer_page__bloc_test.dart](file:///d:/Flutter_Project/food_delivery_app/test/seller_test/unit/seller_customer_page__bloc_test.dart) |
| **Widget Tests** | `seller_customer_page__ui_test.dart` | [seller_customer_page__ui_test.dart](file:///d:/Flutter_Project/food_delivery_app/test/seller_test/widget/seller_customer_page__ui_test.dart) |
| **Golden Tests** | `seller_customer_page_golden_test.dart` | [seller_customer_page_golden_test.dart](file:///d:/Flutter_Project/food_delivery_app/test/seller_test/golden/seller_customer_page_golden_test.dart) |
| **Accessibility Tests** | `seller_customer_page_accessibility_test.dart` | [seller_customer_page_accessibility_test.dart](file:///d:/Flutter_Project/food_delivery_app/test/seller_test/accessibility/seller_customer_page_accessibility_test.dart) |
| **Performance Tests** | `seller_customer_page_performance_test.dart` | [seller_customer_page_performance_test.dart](file:///d:/Flutter_Project/food_delivery_app/test/seller_test/performance/seller_customer_page_performance_test.dart) |
| **Security Tests** | `seller_customer_page_security_test.dart` | [seller_customer_page_security_test.dart](file:///d:/Flutter_Project/food_delivery_app/test/seller_test/security/seller_customer_page_security_test.dart) |
| **Localization Tests** | `seller_customer_page_localization_test.dart` | [seller_customer_page_localization_test.dart](file:///d:/Flutter_Project/food_delivery_app/test/seller_test/localization/seller_customer_page_localization_test.dart) |
| **State Restoration** | `seller_customer_page_state_restoration_test.dart` | [seller_customer_page_state_restoration_test.dart](file:///d:/Flutter_Project/food_delivery_app/test/seller_test/state_restoration/seller_customer_page_state_restoration_test.dart) |
| **Error Handling** | `seller_customer_page_error_handling_test.dart` | [seller_customer_page_error_handling_test.dart](file:///d:/Flutter_Project/food_delivery_app/test/seller_test/error_handling/seller_customer_page_error_handling_test.dart) |
| **Permission Tests** | `seller_customer_page_permission_test.dart` | [seller_customer_page_permission_test.dart](file:///d:/Flutter_Project/food_delivery_app/test/seller_test/permission/seller_customer_page_permission_test.dart) |
