# 📑 09. Incoming Order Alert & Acceptance Page — Human Journey & Real-Time Testing Blueprint

**Document ID:** `DELIVERY-DOC-09-INCOMING-ORDER`  
**Classification:** Phase 3: Order Dispatch, Acceptance & Merchant Pickup  
**Target Screen:** [DeliveryIncomingOrderPageUI](file:///lib/features/Delivery Partner Bloc Architecture/Delivery_Incoming_Order_page/Delivery_Incoming_Order_page_ui.dart)  
**Target BLoC:** `DeliveryIncomingOrderPageBloc`  
**Zero-Mock Compliance:** ✅ Strict 100% Real-Time Firestore Integration (No Local Mock Data)  

---

## 🚶‍♂️ 1. Human Journey Context & User Flow

### 🎯 Step Overview
Full-screen high-priority trip request broadcast screen featuring 30-second countdown timer, animated circular progress, audible looping ringtone, estimated trip payout, pickup distance, and customer destination preview.

```mermaid
sequenceDiagram
    autonumber
    actor Rider as 🛵 Delivery Partner
    participant UI as DeliveryIncomingOrderPageUI
    participant Bloc as DeliveryIncomingOrderPageBloc
    participant Repo as DeliveryPartnerRepository
    participant FS as Cloud Firestore (delivery_broadcasts/{broadcastId} + orders/{orderId})

    Rider->>UI: Interacts with screen
    UI->>Bloc: add(AcceptOrderEvent())
    Bloc->>Repo: executeOperation()
    Repo->>FS: Real-time query / transaction (claimDeliveryOrderAtomicLock)
    FS-->>Repo: Real-time Snapshot
    Repo-->>Bloc: Result Data
    Bloc-->>UI: emit(DeliveryIncomingOrderAcceptedState)
    UI->>Rider: Renders reactive UI update
```

### 🛣️ Navigation Preconditions & Route
- **Route Preceding Screen:** DeliveryDashboardPageUI (Background trip broadcast trigger)
- **Subsequent Screen:** DeliveryOrdersPageUI / DeliveryOrderDetailsPageUI (on Accept) or Dashboard (on Decline/Timeout)

---

## 🏛️ 2. BLoC / Cubit Architecture Mapping

### 🧩 Presentation Layer & UI Elements
- **Target File:** `DeliveryIncomingOrderPageUI (lib/features/Delivery Partner Bloc Architecture/Delivery_Incoming_Order_page/Delivery_Incoming_Order_page_ui.dart)`
- **BLoC State Management:** `DeliveryIncomingOrderPageBloc`

### ⚡ Form Fields & Data Mapping
| Field / UI Element | Purpose & Behavior | Firestore / Backend Mapping |
|---|---|---|
| `countdownTimer` | 30-second ticking progress arc | `Local countdown timer` |
| `estimatedFare` | Total guaranteed earning for this delivery | `orders/{orderId}.deliveryPartnerFare` |
| `restaurantNameAddress` | Pickup restaurant name, distance & preparation status | `orders/{orderId}.restaurantDetails` |
| `customerDropoffArea` | Customer neighborhood & delivery distance | `orders/{orderId}.deliveryAddress` |
| `acceptSlideButton` | Swipe / Tap to accept delivery contract | `Atomic Cloud Function Lock` |

### 🔄 Events & State Emission Matrix
| Event Class | Trigger Condition & Description | Emitted States |
|---|---|---|
| `AcceptOrderEvent` | Rider claims trip within 30s window | `DeliveryIncomingOrderAcceptedState` |
| `DeclineOrderEvent` | Rider declines order with reason selection | `DeliveryIncomingOrderDeclinedState` |
| `OrderTimeoutEvent` | 30s countdown expires without action | `DeliveryIncomingOrderTimeoutState` |

---

## 🔥 3. Real-Time Cloud Firestore & Backend Connectivity

- **Firestore Document:** `delivery_broadcasts/{broadcastId} + orders/{orderId}`
- **Serverless Cloud Function:** `claimDeliveryOrderAtomicLock`
- **Zero-Mock Policy:** Real-time stream subscription with automatic offline sync and optimistic UI updates.

---

## 🛡️ 4. Validation & Error Handling

| Scenario | Validation Check | Handled State & UI Message |
|---|---|---|
| **Order Already Claimed** | `Concurrent rider claimed order first` | `Order was assigned to another nearby partner` |
| **Timeout Expiry** | `Zero seconds remaining` | `Trip request timed out. Returning to radar queue` |

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
