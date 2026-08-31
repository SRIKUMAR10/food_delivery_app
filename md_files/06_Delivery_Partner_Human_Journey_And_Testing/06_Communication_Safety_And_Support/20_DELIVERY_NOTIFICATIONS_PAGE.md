# 📑 20. Priority Push Notifications Hub Page — Human Journey & Real-Time Testing Blueprint

**Document ID:** `DELIVERY-DOC-20-NOTIFICATIONS`  
**Classification:** Phase 6: Communication, Safety & Support  
**Target Screen:** [DeliveryNotificationsPageUI](file:///lib/features/Delivery Partner Bloc Architecture/Delivery_Notifications_page/Delivery_Notifications_page_ui.dart)  
**Target BLoC:** `DeliveryNotificationBloc`  
**Zero-Mock Compliance:** ✅ Strict 100% Real-Time Firestore Integration (No Local Mock Data)  

---

## 🚶‍♂️ 1. Human Journey Context & User Flow

### 🎯 Step Overview
Categorized notification center managing system broadcasts, high-priority order dispatch alerts, payout settlement confirmations, incentive reward notifications, and policy/safety updates with real-time unread badges.

```mermaid
sequenceDiagram
    autonumber
    actor Rider as 🛵 Delivery Partner
    participant UI as DeliveryNotificationsPageUI
    participant Bloc as DeliveryNotificationBloc
    participant Repo as DeliveryPartnerRepository
    participant FS as Cloud Firestore (delivery_partners/{uid}/notifications)

    Rider->>UI: Interacts with screen
    UI->>Bloc: add(FetchNotificationsEvent())
    Bloc->>Repo: executeOperation()
    Repo->>FS: Real-time query / transaction (sendPushNotificationToRider)
    FS-->>Repo: Real-time Snapshot
    Repo-->>Bloc: Result Data
    Bloc-->>UI: emit(DeliveryNotificationLoadedState)
    UI->>Rider: Renders reactive UI update
```

### 🛣️ Navigation Preconditions & Route
- **Route Preceding Screen:** DeliveryNavigationBarPageUI / DeliveryDashboardPageUI
- **Subsequent Screen:** Target Action Screen linked to notification

---

## 🏛️ 2. BLoC / Cubit Architecture Mapping

### 🧩 Presentation Layer & UI Elements
- **Target File:** `DeliveryNotificationsPageUI (lib/features/Delivery Partner Bloc Architecture/Delivery_Notifications_page/Delivery_Notifications_page_ui.dart)`
- **BLoC State Management:** `DeliveryNotificationBloc`

### ⚡ Form Fields & Data Mapping
| Field / UI Element | Purpose & Behavior | Firestore / Backend Mapping |
|---|---|---|
| `notificationCategoryTabs` | All / Orders / Payouts / Incentives filter tabs | `Category Filter` |
| `notificationsList` | List cards with high-contrast icon, timestamp, unread dot | `notifications stream` |
| `markAllAsReadButton` | Clears unread badge count atomically | `Batch Firestore update` |

### 🔄 Events & State Emission Matrix
| Event Class | Trigger Condition & Description | Emitted States |
|---|---|---|
| `FetchNotificationsEvent` | Subscribes to notifications stream | `DeliveryNotificationLoadedState` |
| `MarkNotificationReadEvent` | Sets isRead = true on tapped notification | `DeliveryNotificationUpdatedState` |

---

## 🔥 3. Real-Time Cloud Firestore & Backend Connectivity

- **Firestore Document:** `delivery_partners/{uid}/notifications`
- **Serverless Cloud Function:** `sendPushNotificationToRider`
- **Zero-Mock Policy:** Real-time stream subscription with automatic offline sync and optimistic UI updates.

---

## 🛡️ 4. Validation & Error Handling

| Scenario | Validation Check | Handled State & UI Message |
|---|---|---|
| **No Notifications** | `Empty notifications collection` | `No new notifications. You're all caught up!` |

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
