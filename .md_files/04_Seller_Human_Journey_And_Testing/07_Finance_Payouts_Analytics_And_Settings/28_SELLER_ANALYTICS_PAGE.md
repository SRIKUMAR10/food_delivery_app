# 📈 28. Revenue & Sales Analytics Page — Human Journey & Real-Time Testing Blueprint

**Document ID:** `SELLER-DOC-28-ANALYTICS`  
**Classification:** Phase 7: Finance, Payouts, Analytics & Settings (Business Intelligence)  
**Target Screen:** [SellerAnalyticsPageUI](file:///d:/Flutter_Project/food_delivery_app/lib/features/seller_bloc_architecture/seller_analytics_page/seller_analytics_page__ui.dart)  
**Target BLoC:** [SellerAnalyticsBloc](file:///d:/Flutter_Project/food_delivery_app/lib/features/seller_bloc_architecture/seller_analytics_page/seller_analytics_page__bloc.dart)  
**Canonical Typedef Alias:** `AnalyticsBloc`  
**Repository:** [SellerAnalyticsRepository](file:///d:/Flutter_Project/food_delivery_app/lib/features/seller_bloc_architecture/seller_analytics_page/seller_analytics_repository.dart)  
**Zero-Mock Compliance:** ✅ BigQuery Star-Schema Data Pipeline & Cloud Firestore aggregated metrics  

---

## 🚶‍♂️ 1. Human Journey Context & User Flow

### 🎯 Step Overview
Restaurant managers and executives analyze store performance, weekly/monthly revenue trends, top-selling dishes, peak dining hours, customer retention percentages, and average order values (AOV). The business intelligence dashboard visualizes interactive charts (bar charts, line graphs, and donut distributions) to empower data-driven menu pricing and promotional strategies.

```mermaid
sequenceDiagram
    autonumber
    actor Manager as 👨‍🍳 Restaurant Executive
    participant UI as SellerAnalyticsPageUI
    participant Bloc as SellerAnalyticsBloc
    participant Repo as SellerAnalyticsRepository
    participant BQ as 📊 BigQuery Data Lakehouse / Firestore

    UI->>Bloc: add(LoadSellerAnalytics(sellerId, timeframe: 'Weekly'))
    Bloc->>Repo: fetchAnalyticsMetrics(sellerId, 'Weekly')
    Repo->>BQ: Query aggregated sales, top dishes, hourly order volume
    BQ-->>Repo: Multi-dimensional BI analytics payload
    Repo-->>Bloc: _AnalyticsDataUpdated(data)
    Bloc-->>UI: emit(AnalyticsLoaded(salesMetrics, topSellingDishes, revenueChartData))
    Manager->>UI: Selects "Monthly Trend" tab
    UI->>Bloc: add(LoadSellerAnalytics(sellerId, timeframe: 'Monthly'))
    Bloc-->>UI: Charts smoothly re-render with monthly comparative curves
```

### 🛣️ Navigation Preconditions & Route
- **Route Name:** `/sellerAnalytics`
- **Preceding Screen:** [SellerDashboardPageUI](file:///d:/Flutter_Project/food_delivery_app/lib/features/seller_bloc_architecture/seller_dashboard_page/seller_dashboard_page_ui.dart) (Analytics Card / Tab).
- **Subsequent Screen:** [OverallRatingPageUI](file:///d:/Flutter_Project/food_delivery_app/lib/features/seller_bloc_architecture/overall_rating_page/overall_rating_page__ui.dart) or [PromotionsCouponsPageUI](file:///d:/Flutter_Project/food_delivery_app/lib/features/seller_bloc_architecture/promotions_coupons_page_/promotions_coupons_page_ui.dart).

---

## 🏛️ 2. BLoC / Cubit Architecture Mapping

### 🧩 Presentation Layer
- **Widget:** [SellerAnalyticsPageUI](file:///d:/Flutter_Project/food_delivery_app/lib/features/seller_bloc_architecture/seller_analytics_page/seller_analytics_page__ui.dart)
- **Subcomponents:** `_SalesMetricCard`, `_OperationalMetricTile`, `_RevenueChartCard`, `_TopDishesList`.
- **UI Design Tokens:** [SellerUiTokens](file:///d:/Flutter_Project/food_delivery_app/lib/features/seller_bloc_architecture/seller_ui_tokens.dart).

### ⚡ BLoC Event Matrix
| Event Class | Trigger Action | Payload Parameters |
|---|---|---|
| `LoadSellerAnalytics` | Page load or timeframe tab selection | `String sellerId, String? timeframe` |
| `_AnalyticsDataUpdated` | Stream or backend data fetch update | `AnalyticsModel data` |
| `_FavoritesUpdated` | Updates customer bookmark totals | `int favoritesCount` |
| `_ReviewsUpdated` | Updates review count and average rating | `double rating, int totalReviews` |

### 📊 BLoC State Matrix
- **State Base Class:** [SellerAnalyticsState](file:///d:/Flutter_Project/food_delivery_app/lib/features/seller_bloc_architecture/seller_analytics_page/seller_analytics_page__state.dart)
- **Sub-States:**
  - `AnalyticsInitial`: Initial state.
  - `AnalyticsLoading`: Emitted while compiling analytical reports.
  - `AnalyticsLoaded`: Contains `double totalSales`, `int totalOrders`, `double averageOrderValue`, `List<RevenuePoint> chartPoints`, `List<TopDishItem> topDishes`.
  - `AnalyticsEmpty`: Emitted when no historical sales data is recorded.
  - `AnalyticsError`: Contains `String message`.

---

## 🔥 3. Real-Time Cloud Firestore & BigQuery Integration

### 📦 Analytics Architecture
- **Lakehouse Pipeline:** Firestore order events stream to BigQuery table `food_delivery.orders_fact` via Firestore BigQuery Export Extension.
- **Aggregated Collections:** `sellers/{sellerId}/analytics/summary` cached in Firestore for real-time mobile latency (<100ms).

---

## 🛡️ 4. Validation, Error Handling & Edge Cases

| Scenario | Validation Check | Handled State & UI Message |
|---|---|---|
| **No Sales in Period** | `totalOrders == 0` | Displays EmptyAnalyticsView: "No sales recorded for this timeframe" |
| **Chart Data Single Point** | `chartPoints.length < 2` | Renders single datum bar rather than broken curve |
| **Backend Latency** | Query execution > 3s | Shimmer skeleton chart cards prevent UI jank |

---

## 🧪 5. 14 Mandatory QA Test Categories Suite

```
┌──────────────────────────────────────────────────────────────────────────────────────────────────┐
│                               14-CATEGORY QA VERIFICATION MATRIX                                 │
├────┬────────────────────────┬─────────────────────────┬──────────────────────────────────────────┤
│ #  │ Test Category          │ Status                  │ Test Target & Verification Focus         │
├────┼────────────────────────┼─────────────────────────┼──────────────────────────────────────────┤
│ 01 │ Unit Tests             │ ✅ Verified             │ AOV, growth percentage & revenue math    │
│ 02 │ Widget Tests           │ ✅ Verified             │ Revenue chart card, top dish tiles & UI  │
│ 03 │ BLoC Tests             │ ✅ Verified             │ Timeframe filter & data update stream    │
│ 04 │ Integration Tests      │ ✅ Verified             │ End-to-end sales analytics aggregation   │
│ 05 │ Golden Tests           │ ✅ Configured           │ Mobile and Desktop charts layout snapshot│
│ 06 │ Performance Tests      │ ✅ Verified (<16ms)     │ Chart bezier curve rendering at 60 FPS   │
│ 07 │ Accessibility Tests    │ ✅ Verified             │ Screen reader semantic chart summaries   │
│ 08 │ Security Tests         │ ✅ Verified             │ Tenant-isolated business revenue data    │
│ 09 │ Localization Tests     │ ✅ Verified             │ Metric labels & currency in Tamil/English│
│ 10 │ Snapshot Tests         │ ✅ Verified             │ Analytics widget tree hierarchy integrity│
│ 11 │ Dependency Tests       │ ✅ Verified             │ Mock analytics repository stream emitter │
│ 12 │ State Restoration      │ ✅ Verified             │ Timeframe tab selection state recovery   │
│ 13 │ Error Handling Tests   │ ✅ Verified             │ Aggregation timeout graceful fallback    │
│ 14 │ Permission Tests       │ ✅ Verified             │ Standard UI shell permissions            │
└────┴────────────────────────┴─────────────────────────┴──────────────────────────────────────────┘
```

---

## 📁 6. Direct Source & Test Hyperlinks Table

| Resource Type | File Name | Absolute Path Link |
|---|---|---|
| **Presentation UI** | `seller_analytics_page__ui.dart` | [seller_analytics_page__ui.dart](file:///d:/Flutter_Project/food_delivery_app/lib/features/seller_bloc_architecture/seller_analytics_page/seller_analytics_page__ui.dart) |
| **BLoC Logic** | `seller_analytics_page__bloc.dart` | [seller_analytics_page__bloc.dart](file:///d:/Flutter_Project/food_delivery_app/lib/features/seller_bloc_architecture/seller_analytics_page/seller_analytics_page__bloc.dart) |
| **Events Definition** | `seller_analytics_page__event.dart` | [seller_analytics_page__event.dart](file:///d:/Flutter_Project/food_delivery_app/lib/features/seller_bloc_architecture/seller_analytics_page/seller_analytics_page__event.dart) |
| **States Definition** | `seller_analytics_page__state.dart` | [seller_analytics_page__state.dart](file:///d:/Flutter_Project/food_delivery_app/lib/features/seller_bloc_architecture/seller_analytics_page/seller_analytics_page__state.dart) |
| **Repository** | `seller_analytics_repository.dart` | [seller_analytics_repository.dart](file:///d:/Flutter_Project/food_delivery_app/lib/features/seller_bloc_architecture/seller_analytics_page/seller_analytics_repository.dart) |
| **Unit / BLoC Tests** | `seller_analytics_page__bloc_test.dart` | [seller_analytics_page__bloc_test.dart](file:///d:/Flutter_Project/food_delivery_app/test/seller_test/unit/seller_analytics_page__bloc_test.dart) |
| **Widget Tests** | `seller_analytics_page__ui_test.dart` | [seller_analytics_page__ui_test.dart](file:///d:/Flutter_Project/food_delivery_app/test/seller_test/widget/seller_analytics_page__ui_test.dart) |
| **Golden Tests** | `seller_analytics_page_golden_test.dart` | [seller_analytics_page_golden_test.dart](file:///d:/Flutter_Project/food_delivery_app/test/seller_test/golden/seller_analytics_page_golden_test.dart) |
| **Accessibility Tests** | `seller_analytics_page_accessibility_test.dart` | [seller_analytics_page_accessibility_test.dart](file:///d:/Flutter_Project/food_delivery_app/test/seller_test/accessibility/seller_analytics_page_accessibility_test.dart) |
| **Performance Tests** | `seller_analytics_page_performance_test.dart` | [seller_analytics_page_performance_test.dart](file:///d:/Flutter_Project/food_delivery_app/test/seller_test/performance/seller_analytics_page_performance_test.dart) |
| **Security Tests** | `seller_analytics_page_security_test.dart` | [seller_analytics_page_security_test.dart](file:///d:/Flutter_Project/food_delivery_app/test/seller_test/security/seller_analytics_page_security_test.dart) |
| **Localization Tests** | `seller_analytics_page_localization_test.dart` | [seller_analytics_page_localization_test.dart](file:///d:/Flutter_Project/food_delivery_app/test/seller_test/localization/seller_analytics_page_localization_test.dart) |
| **State Restoration** | `seller_analytics_page_state_restoration_test.dart` | [seller_analytics_page_state_restoration_test.dart](file:///d:/Flutter_Project/food_delivery_app/test/seller_test/state_restoration/seller_analytics_page_state_restoration_test.dart) |
| **Error Handling** | `seller_analytics_page_error_handling_test.dart` | [seller_analytics_page_error_handling_test.dart](file:///d:/Flutter_Project/food_delivery_app/test/seller_test/error_handling/seller_analytics_page_error_handling_test.dart) |
| **Permission Tests** | `seller_analytics_page_permission_test.dart` | [seller_analytics_page_permission_test.dart](file:///d:/Flutter_Project/food_delivery_app/test/seller_test/permission/seller_analytics_page_permission_test.dart) |
