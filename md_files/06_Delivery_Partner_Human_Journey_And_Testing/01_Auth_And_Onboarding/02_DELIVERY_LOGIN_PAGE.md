# 📑 02. Delivery Partner Login Page — Human Journey & Real-Time Testing Blueprint

**Document ID:** `DELIVERY-DOC-02-LOGIN`  
**Classification:** Phase 1: Authentication, Onboarding & 8-Step Verification  
**Target Screen:** [DeliveryLoginPageUI](file:///lib/features/Delivery Partner Bloc Architecture/Delivery_Login Page/Delivery_Login Page_ui.dart)  
**Target BLoC:** `DeliveryLoginPageBloc / DeliveryAuthBloc`  
**Zero-Mock Compliance:** ✅ Strict 100% Real-Time Firestore Integration (No Local Mock Data)  

---

## 🚶‍♂️ 1. Human Journey Context & User Flow

### 🎯 Step Overview
Enables existing delivery riders to authenticate using Email/Password, Phone OTP, Google Auth, or Apple Sign-In with instant session token verification and KYC verification status checking.

```mermaid
sequenceDiagram
    autonumber
    actor Rider as 🛵 Delivery Partner
    participant UI as DeliveryLoginPageUI
    participant Bloc as DeliveryLoginPageBloc
    participant Repo as DeliveryPartnerRepository
    participant FS as Cloud Firestore (delivery_partners/{uid})

    Rider->>UI: Interacts with screen
    UI->>Bloc: add(LoginWithEmailAndPasswordEvent())
    Bloc->>Repo: executeOperation()
    Repo->>FS: Real-time query / transaction (onDeliveryPartnerLoginAuth)
    FS-->>Repo: Real-time Snapshot
    Repo-->>Bloc: Result Data
    Bloc-->>UI: emit(DeliveryLoginLoadingState)
    UI->>Rider: Renders reactive UI update
```

### 🛣️ Navigation Preconditions & Route
- **Route Preceding Screen:** DeliveryOnboardingPageUI / Splash
- **Subsequent Screen:** DeliveryOnboardingVerificationPage (if KYC incomplete) or DeliveryNavigationBarPageUI (if active)

---

## 🏛️ 2. BLoC / Cubit Architecture Mapping

### 🧩 Presentation Layer & UI Elements
- **Target File:** `DeliveryLoginPageUI (lib/features/Delivery Partner Bloc Architecture/Delivery_Login Page/Delivery_Login Page_ui.dart)`
- **BLoC State Management:** `DeliveryLoginPageBloc / DeliveryAuthBloc`

### ⚡ Form Fields & Data Mapping
| Field / UI Element | Purpose & Behavior | Firestore / Backend Mapping |
|---|---|---|
| `emailOrPhone` | User Email address or 10-digit mobile number | `delivery_partners/{uid}.email / phone` |
| `password` | Encrypted password for email credential authentication | `Firebase Auth credential` |
| `rememberMe` | Persist secure auth token locally | `FlutterSecureStorage` |

### 🔄 Events & State Emission Matrix
| Event Class | Trigger Condition & Description | Emitted States |
|---|---|---|
| `LoginWithEmailAndPasswordEvent` | Email & Password login trigger | `DeliveryLoginLoadingState, DeliveryLoginSuccessState, DeliveryLoginFailureState` |
| `LoginWithPhoneOtpRequestedEvent` | Triggers phone number OTP verification | `DeliveryLoginOtpSentState` |
| `SocialLoginTriggeredEvent` | Google/Apple OAuth auth trigger | `DeliveryLoginSuccessState` |

---

## 🔥 3. Real-Time Cloud Firestore & Backend Connectivity

- **Firestore Document:** `delivery_partners/{uid}`
- **Serverless Cloud Function:** `onDeliveryPartnerLoginAuth`
- **Zero-Mock Policy:** Real-time stream subscription with automatic offline sync and optimistic UI updates.

---

## 🛡️ 4. Validation & Error Handling

| Scenario | Validation Check | Handled State & UI Message |
|---|---|---|
| **Invalid Email/Phone** | `RegExp checks for standard email format or 10-digit mobile` | `Please enter a valid email address or 10-digit mobile number` |
| **Incorrect Password** | `Firebase Auth error code `wrong-password`` | `Incorrect password. Please verify or reset your password` |
| **Unverified KYC State** | `kycStatus == 'pending' | 'under_review'` | `Redirects partner directly to 8-step verification wizard` |

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
