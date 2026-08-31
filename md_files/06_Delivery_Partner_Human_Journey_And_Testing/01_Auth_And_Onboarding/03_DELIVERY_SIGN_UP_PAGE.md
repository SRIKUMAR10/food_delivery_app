# 📑 03. Delivery Partner Sign Up Page — Human Journey & Real-Time Testing Blueprint

**Document ID:** `DELIVERY-DOC-03-SIGNUP`  
**Classification:** Phase 1: Authentication, Onboarding & 8-Step Verification  
**Target Screen:** [DeliverySignUpPageUI](file:///lib/features/Delivery Partner Bloc Architecture/Delivery_Sign_Up_page/Delivery_Sign_Up_page_ui.dart)  
**Target BLoC:** `DeliverySignUpPageBloc`  
**Zero-Mock Compliance:** ✅ Strict 100% Real-Time Firestore Integration (No Local Mock Data)  

---

## 🚶‍♂️ 1. Human Journey Context & User Flow

### 🎯 Step Overview
Onboards new delivery riders by provisioning their account in Firebase Authentication and initializing their initial document in Cloud Firestore under delivery_partners/{uid} with default 'pending' verification state.

```mermaid
sequenceDiagram
    autonumber
    actor Rider as 🛵 Delivery Partner
    participant UI as DeliverySignUpPageUI
    participant Bloc as DeliverySignUpPageBloc
    participant Repo as DeliveryPartnerRepository
    participant FS as Cloud Firestore (delivery_partners/{uid})

    Rider->>UI: Interacts with screen
    UI->>Bloc: add(SignUpSubmittedEvent())
    Bloc->>Repo: executeOperation()
    Repo->>FS: Real-time query / transaction (onDeliveryPartnerCreated)
    FS-->>Repo: Real-time Snapshot
    Repo-->>Bloc: Result Data
    Bloc-->>UI: emit(DeliverySignUpLoadingState)
    UI->>Rider: Renders reactive UI update
```

### 🛣️ Navigation Preconditions & Route
- **Route Preceding Screen:** DeliveryLoginPageUI / DeliveryOnboardingPageUI
- **Subsequent Screen:** DeliveryOTPVerificationPageUI ➔ DeliveryOnboardingVerificationPage

---

## 🏛️ 2. BLoC / Cubit Architecture Mapping

### 🧩 Presentation Layer & UI Elements
- **Target File:** `DeliverySignUpPageUI (lib/features/Delivery Partner Bloc Architecture/Delivery_Sign_Up_page/Delivery_Sign_Up_page_ui.dart)`
- **BLoC State Management:** `DeliverySignUpPageBloc`

### ⚡ Form Fields & Data Mapping
| Field / UI Element | Purpose & Behavior | Firestore / Backend Mapping |
|---|---|---|
| `fullName` | Official name as printed on Driving License | `delivery_partners/{uid}.name` |
| `phoneNumber` | 10-digit primary mobile contact | `delivery_partners/{uid}.phone` |
| `email` | Partner communication email address | `delivery_partners/{uid}.email` |
| `cityZone` | Target operating delivery city / zone | `delivery_partners/{uid}.zone` |
| `vehicleType` | Type of vehicle (Bike, Scooter, EV, Cycle) | `delivery_partners/{uid}.vehicleType` |

### 🔄 Events & State Emission Matrix
| Event Class | Trigger Condition & Description | Emitted States |
|---|---|---|
| `SignUpSubmittedEvent` | Triggers partner account provisioning | `DeliverySignUpLoadingState, DeliverySignUpSuccessState, DeliverySignUpFailureState` |
| `CheckPhoneUniquenessEvent` | Verifies mobile number uniqueness in Firestore | `PhoneAvailableState / PhoneDuplicateErrorState` |

---

## 🔥 3. Real-Time Cloud Firestore & Backend Connectivity

- **Firestore Document:** `delivery_partners/{uid}`
- **Serverless Cloud Function:** `onDeliveryPartnerCreated`
- **Zero-Mock Policy:** Real-time stream subscription with automatic offline sync and optimistic UI updates.

---

## 🛡️ 4. Validation & Error Handling

| Scenario | Validation Check | Handled State & UI Message |
|---|---|---|
| **Phone Already Registered** | `Firestore query on delivery_partners where phone == input` | `This mobile number is already registered. Please login instead` |
| **Weak Password** | `Length < 6 or lacking alphanumeric complexity` | `Password must be at least 6 characters with letters and numbers` |

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
