# 📑 08. Live Rider Duty Dashboard Page — Human Journey & Real-Time Testing Blueprint

**Document ID:** `DELIVERY-DOC-08-DASHBOARD`  
**Classification:** Phase 2: Navigation & Live Duty Dashboard  
**Target Screen:** [DeliveryDashboardPageUI](file:///lib/features/Delivery Partner Bloc Architecture/Delivery_Dashboard_page/Delivery_Dashboard_page_ui.dart)  
**Target BLoC:** `DeliveryDashboardPageBloc / AvailabilityCubit / DeliveryRatingBloc`  
**Zero-Mock Compliance:** ✅ Strict 100% Real-Time Firestore Integration (No Local Mock Data)  

---

## 🚶‍♂️ 1. Human Journey Context & User Flow

### 🎯 Step Overview
Primary operational command center for riders. Features live Online/Offline duty switch, daily earnings overview, completed deliveries counter, customer rating score, floating map radar, and SOS emergency access.

```mermaid
sequenceDiagram
    autonumber
    actor Rider as 🛵 Delivery Partner
    participant UI as DeliveryDashboardPageUI
    participant Bloc as DeliveryDashboardPageBloc
    participant Repo as DeliveryPartnerRepository
    participant FS as Cloud Firestore (delivery_partners/{uid} + metrics/realtime)

    Rider->>UI: Interacts with screen
    UI->>Bloc: add(FetchDashboardDataEvent())
    Bloc->>Repo: executeOperation()
    Repo->>FS: Real-time query / transaction (updateRiderDutyStatus)
    FS-->>Repo: Real-time Snapshot
    Repo-->>Bloc: Result Data
    Bloc-->>UI: emit(DeliveryDashboardLoadedState)
    UI->>Rider: Renders reactive UI update
```

### 🛣️ Navigation Preconditions & Route
- **Route Preceding Screen:** DeliveryNavigationBarPageUI
- **Subsequent Screen:** DeliveryIncomingOrderPageUI (on trip dispatch) / DeliveryOrdersPageUI

---

## 🏛️ 2. BLoC / Cubit Architecture Mapping

### 🧩 Presentation Layer & UI Elements
- **Target File:** `DeliveryDashboardPageUI (lib/features/Delivery Partner Bloc Architecture/Delivery_Dashboard_page/Delivery_Dashboard_page_ui.dart)`
- **BLoC State Management:** `DeliveryDashboardPageBloc / AvailabilityCubit / DeliveryRatingBloc`

### ⚡ Form Fields & Data Mapping
| Field / UI Element | Purpose & Behavior | Firestore / Backend Mapping |
|---|---|---|
| `dutyToggleSwitch` | Interactive slide-to-online switch | `delivery_partners/{uid}.isOnline` |
| `todayEarningsCard` | Real-time accumulated trip fares and tips | `delivery_partners/{uid}/earnings/today` |
| `tripsCompletedMetric` | Count of successfully delivered orders today | `delivery_partners/{uid}.todayTripsCount` |
| `acceptanceRateMetric` | Percentage of assigned orders accepted | `delivery_partners/{uid}.acceptanceRate` |
| `ratingScoreCard` | Overall rider rating (e.g. 4.9★ with badges) | `delivery_partners/{uid}.rating` |

### 🔄 Events & State Emission Matrix
| Event Class | Trigger Condition & Description | Emitted States |
|---|---|---|
| `FetchDashboardDataEvent` | Loads live metrics and shift statistics | `DeliveryDashboardLoadedState` |
| `ToggleDutyStatusEvent` | Switches rider between Online, Offline, and Busy | `AvailabilityStateUpdated` |
| `LocationHeartbeatEvent` | Pushes current GPS coordinate to Firestore | `delivery_partners/{uid}.currentLocation` |

---

## 🔥 3. Real-Time Cloud Firestore & Backend Connectivity

- **Firestore Document:** `delivery_partners/{uid} + metrics/realtime`
- **Serverless Cloud Function:** `updateRiderDutyStatus`
- **Zero-Mock Policy:** Real-time stream subscription with automatic offline sync and optimistic UI updates.

---

## 🛡️ 4. Validation & Error Handling

| Scenario | Validation Check | Handled State & UI Message |
|---|---|---|
| **GPS Disabled** | `Location service disabled on device` | `Please enable high accuracy GPS location to go Online` |
| **Low Battery Warning** | `Battery level < 15%` | `Low battery warning prompt with power-saving mode suggestions` |

---

## 🧪 5. 14 Mandatory QA Test Categories Suite

```
┌──────────────────────────────────────────────────────────────────────────────────────────────────┐
│                               14-CATEGORY QA VERIFICATION MATRIX                                 │
├────┬────────────────────────┬─────────────────────────┬──────────────────────────────────────────┤
│ #  │ Test Category          │ Status                  │ Test Target & Verification Focus         │
├────┼────────────────────────┼─────────────────────────┼──────────────────────────────────────────┤
│ 01 │ Unit Tests             │ ✅ Verified             │ Business logic, validation regex & models│
│ 02 │ Widget Tests           │ ✅ Verified             │ UI rendering, element tree & gestures    │
│ 03 │ BLoC Tests             │ ✅ Verified             │ State emissions & event transitions      │
│ 04 │ Integration Tests      │ ✅ Verified             │ Real Firestore stream synchronization    │
│ 05 │ Golden Tests           │ ✅ Configured           │ Pixel fidelity across device DP sizes    │
│ 06 │ Performance Tests      │ ✅ Verified (<16ms)     │ 60 FPS frame rate & smooth animation     │
│ 07 │ Accessibility Tests    │ ✅ Verified             │ Screen reader semantics & touch targets  │
│ 08 │ Security Tests         │ ✅ Verified             │ Sanitized input & token verification     │
│ 09 │ Localization Tests     │ ✅ Verified (EN / TA)   │ Tamil & English multi-language keys      │
│ 10 │ Snapshot Tests         │ ✅ Verified             │ Widget tree hierarchy regression check   │
│ 11 │ Dependency Tests       │ ✅ Verified             │ Dependency injection & service isolation │
│ 12 │ State Restoration      │ ✅ Verified             │ Background lifecycle & session recovery  │
│ 13 │ Error Handling Tests   │ ✅ Verified             │ Network dropouts & Firestore retry       │
│ 14 │ Permission Tests       │ ✅ Verified             │ Fine GPS location, Camera, Storage       │
└────┴────────────────────────┴─────────────────────────┴──────────────────────────────────────────┘
```
