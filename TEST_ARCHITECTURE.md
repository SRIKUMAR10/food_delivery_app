# 🏛️ Enterprise 3-Role Test Architecture Blueprint

## Food Delivery App – Test Architecture & Directory Specification

This document defines the official, Senior-Developer-level **3-Role Test Architecture** implemented across the entire Flutter Food Delivery application. It serves as the single source of truth for all testing suites, categorizations, mock configurations, fixtures, and cross-role end-to-end user journeys.

---

## 📂 Complete Architecture Directory Tree

```text
test/
│
├── buyer_test/                  (13 Test Categories + Domain Tests)
│   ├── unit/                    (Bloc, models, services, business logic)
│   ├── widget/                  (UI components, views, interactions)
│   ├── integration/             (Buyer feature-level integration flows)
│   ├── golden/                  (Pixel-perfect UI screenshots & render stability)
│   ├── performance/             (Frame rate benchmarks, latency, memory profiling)
│   ├── accessibility/           (Semantics, contrast, screen reader compatibility)
│   ├── security/                (Input sanitization, authentication barrier)
│   ├── localization/            (i18n, translations, multi-language support)
│   ├── snapshot/                (Render tree snapshots & widget state trees)
│   ├── dependency/              (DI injection, service locator resolution)
│   ├── state_restoration/       (Process death restoration, state persistence)
│   ├── error_handling/          (Exception handling, stream error recovery)
│   └── permission/              (Location, camera, storage permissions)
│
├── seller_test/                 (13 Test Categories + Domain Tests)
│   ├── unit/                    (Seller Bloc, catalog management, inventory)
│   ├── widget/                  (Store management, order acceptance UI)
│   ├── integration/             (Seller operational workflows)
│   ├── golden/                  (Seller dashboard & analytics goldens)
│   ├── performance/             (High-volume order list rendering speed)
│   ├── accessibility/           (Touch targets, high-contrast readability)
│   ├── security/                (Store isolation, financial data protection)
│   ├── localization/            (Multilingual store and order status labels)
│   ├── snapshot/                (Store view widget snapshots)
│   ├── dependency/              (Seller services & repository bindings)
│   ├── state_restoration/       (Draft product persistence, form restore)
│   ├── error_handling/          (Payout failures, network error handling)
│   └── permission/              (Camera, receipt printing, storage permissions)
│
├── delivery_partner_test/       (13 Test Categories + Domain Tests)
│   ├── unit/                    (Route optimization, order assignment, status)
│   ├── widget/                  (Delivery radar, pickup confirmation, map UI)
│   ├── integration/             (Delivery partner dispatch & completion flow)
│   ├── golden/                  (Active delivery HUD & map controls goldens)
│   ├── performance/             (GPS stream update & battery efficiency)
│   ├── accessibility/           (Voice navigation compatibility, large buttons)
│   ├── security/                (Location spoofing prevention, auth barriers)
│   ├── localization/            (Turn-by-turn and delivery prompt localizations)
│   ├── snapshot/                (Active order bottom-sheet snapshots)
│   ├── dependency/              (Location provider & geocoding services)
│   ├── state_restoration/       (Trip recovery after app restart / kill)
│   ├── error_handling/          (GPS loss recovery, offline queue sync)
│   └── permission/              (Background GPS, foreground location permissions)
│
├── e2e/                         (End-to-End Complete User Journeys)
│   ├── authentication/          (Tri-party login, registration, role redirection)
│   ├── buyer_order_flow/        (Browse -> Cart -> Checkout -> Place Order)
│   ├── seller_order_processing/ (Receive -> Accept -> Prepare -> Dispatch)
│   ├── delivery_assignment/     (Broadcast -> Accept -> Live Track -> Handover)
│   ├── payment_flow/            (Payment intent, authorization, settlement)
│   ├── cancellation_flow/       (Pre-dispatch cancel, notification sync)
│   ├── refund_flow/             (Automated refund triggers, wallet credit)
│   └── complete_food_delivery_flow/ (Full Lifecycle: Buyer Placed to Delivered)
│
├── core_test/                   (App Core Infrastructure Tests)
│   ├── unit/                    (Core utilities, string helpers, date formatters)
│   ├── security/                (Encryption, token storage, App Check barriers)
│   ├── error_handling/          (Global error boundaries, crash reporting)
│   └── dependency/              (Global Service Locator & Dependency Graph)
│
├── firebase_test/               (Firebase & Backend Integration Tests)
│   ├── auth/                    (FirebaseAuth state streams, token refresh)
│   ├── firestore/               (Firestore collections, real-time listeners)
│   ├── storage/                 (Cloud Storage upload, download, metadata)
│   ├── cloud_functions/         (Callable functions, backend triggers)
│   ├── security_rules/          (Firestore & Storage rule validation)
│   └── realtime/                (Real-time database and live event streams)
│
├── shared_test/                 (Shared UI, Models & Cross-Cutting Services)
│   ├── widgets/                 (Custom buttons, textfields, snackbars, modals)
│   ├── services/                (Notification service, network connectivity)
│   ├── repositories/            (Base repository patterns, caching layer)
│   ├── models/                  (Shared DTOs, JSON serialization, copyWith)
│   ├── utilities/               (Math, currency formatters, geohash tools)
│   └── validators/              (Email, phone, password, address validators)
│
├── fixtures/                    (JSON / Object Fixture Seeds)
│   ├── buyer/                   (Sample buyer profiles & preferences)
│   ├── seller/                  (Sample restaurant profiles & menus)
│   ├── delivery_partner/        (Sample driver profiles & vehicle data)
│   ├── products/                (Food items, categories, add-on fixtures)
│   ├── orders/                  (Standard order payloads & state transitions)
│   ├── payments/                (Payment intent fixtures, receipts)
│   └── users/                   (Multi-role mock user documents)
│
├── mocks/                       (Centralized Mock Objects & Stubs)
│   ├── firebase/                (Mock FirebaseAuth, MockFirestore, MockStorage)
│   ├── repositories/            (MockOrderRepository, MockProductRepository)
│   ├── services/                (MockPaymentService, MockLocationService)
│   ├── api/                     (MockHttpClient, MockCloudFunctions)
│   └── external_dependencies/   (MockGeolocator, MockConnectivity)
│
├── test_data/                   (Realistic Sample Datasets)
│   ├── users/                   (Sample user seeds)
│   ├── products/                (Sample dishes, prices, categories)
│   ├── restaurants/             (Sample restaurant chains & operating hours)
│   ├── orders/                  (Sample historical & active orders)
│   ├── payments/                (Sample transaction records)
│   ├── coupons/                 (Sample discount codes & validation rules)
│   └── delivery/                (Sample GPS coordinates & delivery zones)
│
├── helpers/                     (Test Automation Helpers & Harnesses)
│   ├── test_helpers/            (PumpWidget wrappers, tester extensions)
│   ├── widget_helpers/          (Font loader, screen size setters)
│   ├── firebase_helpers/        (In-memory Firestore emulator harnesses)
│   ├── bloc_helpers/            (Bloc test wrappers, mock event emitters)
│   └── assertion_helpers/       (Custom matchers, semantic assertion helpers)
│
└── test_config/                 (Environment & Suite Setup)
    ├── test_constants/          (Timeout durations, mock UIDs, test endpoints)
    ├── test_environment/        (Environment toggles: unit, mock, live)
    ├── test_routes/             (Named route constants for navigation tests)
    └── test_setup/              (Global Flutter test binding initialization)

integration_test/
├── buyer/                       (Buyer end-to-end device integration tests)
├── seller/                      (Seller portal device integration tests)
├── delivery_partner/            (Delivery driver device integration tests)
└── cross_role/                  (Tri-Party Real-Time Integration Tests)
    ├── buyer_to_seller/         (Order placement -> Seller notification)
    ├── seller_to_delivery/      (Food prepared -> Delivery partner pickup)
    ├── buyer_to_delivery/       (Live map tracking -> Delivery OTP confirmation)
    └── complete_order_flow/     (Tri-party synchronized full lifecycle)
```

---

## 🏷️ The 13 Enterprise Test Categories Per Role

Every primary user role (`Buyer`, `Seller`, `Delivery Partner`) maintains the following 13 test categories:

| Category | Target / Purpose |
|---|---|
| **1. Unit Tests** | Business logic, BLoC state transitions, models, repositories, and data formatting. |
| **2. Widget Tests** | UI rendering, user tap/scroll interactions, state changes in isolated widget trees. |
| **3. Integration Tests** | Multi-screen user flows, real navigation, repository-to-UI data pipeline. |
| **4. Golden Tests** | Visual regression testing against canonical baseline screenshots across light/dark themes. |
| **5. Performance Tests** | Frame rate metrics (60/120 FPS), jank detection, list scrolling, memory leaks. |
| **6. Accessibility Tests** | Minimum tap target size (48x48 dp), text contrast ratios, semantics nodes, screen readers. |
| **7. Security Tests** | Role-based authorization barriers, unauthorized state prevention, input sanitization. |
| **8. Localization Tests** | Multi-language translation integrity, RTL/LTR layout verification, currency formatting. |
| **9. Snapshot Tests** | Widget tree structure stability, semantic tree validation. |
| **10. Dependency Tests** | Dependency injection verification, singleton vs factory lifecycle, fallback bindings. |
| **11. State Restoration Tests** | App backgrounding, low-memory process termination, state preservation & restoration. |
| **12. Error Handling Tests** | Network failure recovery, timeout handling, stream interruption, user error banners. |
| **13. Permission Tests** | Permission request dialogs, granted/denied/permanently-denied branching logic. |

---

## 🚀 Running Test Suites

### Run Buyer Test Suite
```bash
flutter test test/buyer_test
```

### Run Seller Test Suite
```bash
flutter test test/seller_test
```

### Run Delivery Partner Test Suite
```bash
flutter test test/delivery_partner_test
```

### Run Foundation & Infrastructure Tests
```bash
flutter test test/core_test
flutter test test/firebase_test
flutter test test/shared_test
```

### Run End-to-End Flow Tests
```bash
flutter test test/e2e
```

### Run Device Integration Tests
```bash
flutter test integration_test/buyer
flutter test integration_test/seller
flutter test integration_test/delivery_partner
flutter test integration_test/cross_role
```

---

## 🔒 Best Practices & Rules

1. **Role Isolation:** Never place buyer-specific tests in `seller_test` or `delivery_partner_test`.
2. **Re-Usable Mocks:** All mocks must reside under `test/mocks/` to avoid mock duplication.
3. **Realistic Fixtures:** Store mock JSON objects and data payloads under `test/fixtures/` and `test/test_data/`.
4. **Centralized Helpers:** Always use helper wrappers from `test/helpers/` for pumpWidget, font loading, and accessibility assertions.
5. **No Static Placeholders:** Integration and E2E tests must validate live Firestore stream subscriptions or accurate mock emissions.
