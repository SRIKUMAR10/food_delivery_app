# 📑 13. Turn-By-Turn GPS Navigation HUD Page — Human Journey & Real-Time Testing Blueprint

**Document ID:** `DELIVERY-DOC-13-GPS-NAV`  
**Classification:** Phase 4: Turn-By-Turn Navigation & Customer Delivery  
**Target Screen:** [DeliveryNavigationScreenPageUI](file:///lib/features/Delivery Partner Bloc Architecture/Delivery_Navigation Screen_page/Delivery_Navigation Screen_page_ui.dart)  
**Target BLoC:** `DeliveryNavigationScreenPageBloc / LiveLocationBloc`  
**Zero-Mock Compliance:** ✅ Strict 100% Real-Time Firestore Integration (No Local Mock Data)  

---

## 🚶‍♂️ 1. Human Journey Context & User Flow

### 🎯 Step Overview
Real-time turn-by-turn map navigation screen featuring Google Maps polyline routing, live 60 FPS rider GPS marker telemetry, speed and ETA HUD, audio voice navigation, external map launcher (Google Maps/Apple Maps/Waze), and one-tap emergency call/chat.

```mermaid
sequenceDiagram
    autonumber
    actor Rider as 🛵 Delivery Partner
    participant UI as DeliveryNavigationScreenPageUI
    participant Bloc as DeliveryNavigationScreenPageBloc
    participant Repo as DeliveryPartnerRepository
    participant FS as Cloud Firestore (orders/{orderId} + delivery_partners/{uid}/location)

    Rider->>UI: Interacts with screen
    UI->>Bloc: add(StartNavigationStreamEvent())
    Bloc->>Repo: executeOperation()
    Repo->>FS: Real-time query / transaction (streamRiderGpsCoordinates)
    FS-->>Repo: Real-time Snapshot
    Repo-->>Bloc: Result Data
    Bloc-->>UI: emit(NavigationActiveState)
    UI->>Rider: Renders reactive UI update
```

### 🛣️ Navigation Preconditions & Route
- **Route Preceding Screen:** DeliveryPickupConfirmationPageUI
- **Subsequent Screen:** DeliveryDeliveryCompletedPageUI

---

## 🏛️ 2. BLoC / Cubit Architecture Mapping

### 🧩 Presentation Layer & UI Elements
- **Target File:** `DeliveryNavigationScreenPageUI (lib/features/Delivery Partner Bloc Architecture/Delivery_Navigation Screen_page/Delivery_Navigation Screen_page_ui.dart)`
- **BLoC State Management:** `DeliveryNavigationScreenPageBloc / LiveLocationBloc`

### ⚡ Form Fields & Data Mapping
| Field / UI Element | Purpose & Behavior | Firestore / Backend Mapping |
|---|---|---|
| `googleMapView` | 60 FPS map rendering with live route polyline | `GoogleMap widget` |
| `turnByTurnBanner` | Next turn direction and remaining distance | `RoutePolylineService` |
| `etaCard` | Estimated arrival time and remaining kilometers | `GoogleDistanceMatrixService` |
| `externalMapButton` | Launches Google Maps / Waze natively | `url_launcher` |
| `customerActionButtons` | Call Customer, In-app Chat, SOS Alert | `Direct Action Triggers` |

### 🔄 Events & State Emission Matrix
| Event Class | Trigger Condition & Description | Emitted States |
|---|---|---|
| `StartNavigationStreamEvent` | Initializes high-accuracy GPS stream | `NavigationActiveState` |
| `UpdateRiderGpsEvent` | Pushes new latitude, longitude, heading to Firestore | `LiveLocationUpdatedState` |

---

## 🔥 3. Real-Time Cloud Firestore & Backend Connectivity

- **Firestore Document:** `orders/{orderId} + delivery_partners/{uid}/location`
- **Serverless Cloud Function:** `streamRiderGpsCoordinates`
- **Zero-Mock Policy:** Real-time stream subscription with automatic offline sync and optimistic UI updates.

---

## 🛡️ 4. Validation & Error Handling

| Scenario | Validation Check | Handled State & UI Message |
|---|---|---|
| **GPS Lost Signal** | `No GPS updates received for 10 seconds` | `Searching for GPS signal... Reconnecting satellite lock` |
| **Rider Deviated from Route** | `Distance from polyline > 100m` | `Route recalculating...` |

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
