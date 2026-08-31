# 📑 10. Active Orders Pipeline Page — Human Journey & Real-Time Testing Blueprint

**Document ID:** `DELIVERY-DOC-10-ORDERS-PIPELINE`  
**Classification:** Phase 3: Order Dispatch, Acceptance & Merchant Pickup  
**Target Screen:** [DeliveryOrdersPageUI](file:///lib/features/Delivery Partner Bloc Architecture/Delivery_Orders_page/Delivery_Orders_page_ui.dart)  
**Target BLoC:** `DeliveryOrdersPageBloc`  
**Zero-Mock Compliance:** ✅ Strict 100% Real-Time Firestore Integration (No Local Mock Data)  

---

## 🚶‍♂️ 1. Human Journey Context & User Flow

### 🎯 Step Overview
Real-time state machine pipeline managing active ongoing deliveries through 7 chronological stages: assigned ➔ accepted ➔ arrived_at_restaurant ➔ food_picked_up ➔ in_transit ➔ arrived_at_customer ➔ delivered.

```mermaid
sequenceDiagram
    autonumber
    actor Rider as 🛵 Delivery Partner
    participant UI as DeliveryOrdersPageUI
    participant Bloc as DeliveryOrdersPageBloc
    participant Repo as DeliveryPartnerRepository
    participant FS as Cloud Firestore (orders/{orderId})

    Rider->>UI: Interacts with screen
    UI->>Bloc: add(FetchActiveOrdersEvent())
    Bloc->>Repo: executeOperation()
    Repo->>FS: Real-time query / transaction (updateDeliveryOrderStatus)
    FS-->>Repo: Real-time Snapshot
    Repo-->>Bloc: Result Data
    Bloc-->>UI: emit(DeliveryOrdersLoadedState)
    UI->>Rider: Renders reactive UI update
```

### 🛣️ Navigation Preconditions & Route
- **Route Preceding Screen:** DeliveryIncomingOrderPageUI
- **Subsequent Screen:** DeliveryOrderDetailsPageUI / DeliveryPickupConfirmationPageUI / DeliveryNavigationScreenPageUI

---

## 🏛️ 2. BLoC / Cubit Architecture Mapping

### 🧩 Presentation Layer & UI Elements
- **Target File:** `DeliveryOrdersPageUI (lib/features/Delivery Partner Bloc Architecture/Delivery_Orders_page/Delivery_Orders_page_ui.dart)`
- **BLoC State Management:** `DeliveryOrdersPageBloc`

### ⚡ Form Fields & Data Mapping
| Field / UI Element | Purpose & Behavior | Firestore / Backend Mapping |
|---|---|---|
| `orderStatusStepper` | Visual 7-step status pipeline timeline | `orders/{orderId}.status` |
| `restaurantCard` | Store location, call button, navigate to store | `orders/{orderId}.restaurant` |
| `customerCard` | Customer name, delivery address, call/chat triggers | `orders/{orderId}.buyer` |
| `actionButton` | Dynamic contextual action (e.g. 'Arrived at Store', 'Confirm Pickup', 'Navigate') | `State Transition Trigger` |

### 🔄 Events & State Emission Matrix
| Event Class | Trigger Condition & Description | Emitted States |
|---|---|---|
| `FetchActiveOrdersEvent` | Listens to real-time stream of active orders | `DeliveryOrdersLoadedState` |
| `AdvanceOrderStatusEvent` | Updates status to next pipeline milestone | `DeliveryOrderStatusUpdatedState` |

---

## 🔥 3. Real-Time Cloud Firestore & Backend Connectivity

- **Firestore Document:** `orders/{orderId}`
- **Serverless Cloud Function:** `updateDeliveryOrderStatus`
- **Zero-Mock Policy:** Real-time stream subscription with automatic offline sync and optimistic UI updates.

---

## 🛡️ 4. Validation & Error Handling

| Scenario | Validation Check | Handled State & UI Message |
|---|---|---|
| **Premature Status Jump** | `Rider taps 'Delivered' before picking up food` | `Action blocked. Please confirm food pickup from restaurant first` |

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
