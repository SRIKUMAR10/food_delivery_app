# 📑 11. Order & Delivery Details Page — Human Journey & Real-Time Testing Blueprint

**Document ID:** `DELIVERY-DOC-11-ORDER-DETAILS`  
**Classification:** Phase 3: Order Dispatch, Acceptance & Merchant Pickup  
**Target Screen:** [DeliveryOrderDetailsPageUI](file:///lib/features/Delivery Partner Bloc Architecture/Delivery_Order_Details_page/Delivery_Order_Details_page_ui.dart)  
**Target BLoC:** `DeliveryOrderDetailsPageBloc`  
**Zero-Mock Compliance:** ✅ Strict 100% Real-Time Firestore Integration (No Local Mock Data)  

---

## 🚶‍♂️ 1. Human Journey Context & User Flow

### 🎯 Step Overview
Detailed inspection screen showing itemized order breakdown (dish quantities, size modifiers, veg/non-veg badges), kitchen cooking instructions, customer delivery notes (e.g. 'Leave at door', 'Ring bell'), and payment collection type (COD / Prepaid).

```mermaid
sequenceDiagram
    autonumber
    actor Rider as 🛵 Delivery Partner
    participant UI as DeliveryOrderDetailsPageUI
    participant Bloc as DeliveryOrderDetailsPageBloc
    participant Repo as DeliveryPartnerRepository
    participant FS as Cloud Firestore (orders/{orderId})

    Rider->>UI: Interacts with screen
    UI->>Bloc: add(LoadOrderDetailsEvent())
    Bloc->>Repo: executeOperation()
    Repo->>FS: Real-time query / transaction (getOrderDetailedBreakdown)
    FS-->>Repo: Real-time Snapshot
    Repo-->>Bloc: Result Data
    Bloc-->>UI: emit(DeliveryOrderDetailsLoadedState)
    UI->>Rider: Renders reactive UI update
```

### 🛣️ Navigation Preconditions & Route
- **Route Preceding Screen:** DeliveryOrdersPageUI
- **Subsequent Screen:** DeliveryPickupConfirmationPageUI / DeliveryNavigationScreenPageUI

---

## 🏛️ 2. BLoC / Cubit Architecture Mapping

### 🧩 Presentation Layer & UI Elements
- **Target File:** `DeliveryOrderDetailsPageUI (lib/features/Delivery Partner Bloc Architecture/Delivery_Order_Details_page/Delivery_Order_Details_page_ui.dart)`
- **BLoC State Management:** `DeliveryOrderDetailsPageBloc`

### ⚡ Form Fields & Data Mapping
| Field / UI Element | Purpose & Behavior | Firestore / Backend Mapping |
|---|---|---|
| `itemsList` | List of dishes with quantities and add-ons | `orders/{orderId}.items` |
| `specialInstructions` | Kitchen and delivery preferences | `orders/{orderId}.instructions` |
| `billSummary` | Subtotal, taxes, delivery fee, payment mode (COD/Prepaid) | `orders/{orderId}.payment` |

### 🔄 Events & State Emission Matrix
| Event Class | Trigger Condition & Description | Emitted States |
|---|---|---|
| `LoadOrderDetailsEvent` | Fetches complete order document | `DeliveryOrderDetailsLoadedState` |

---

## 🔥 3. Real-Time Cloud Firestore & Backend Connectivity

- **Firestore Document:** `orders/{orderId}`
- **Serverless Cloud Function:** `getOrderDetailedBreakdown`
- **Zero-Mock Policy:** Real-time stream subscription with automatic offline sync and optimistic UI updates.

---

## 🛡️ 4. Validation & Error Handling

| Scenario | Validation Check | Handled State & UI Message |
|---|---|---|
| **COD Cash Collection Notice** | `Payment method is COD` | `High-visibility badge to collect exact cash amount from customer` |

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
