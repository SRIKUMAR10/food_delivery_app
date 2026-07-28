# Enterprise Architecture Review & Implementation Plan: Buyer App Settings Page

You are a senior Flutter architect. DO NOT generate any code until explicitly instructed.

## Phase 1: Architecture Audit Only

### Project Context
- Path: `D:\Flutter_Project\food_delivery_app`
- Buyer BLoC convention: `PageName_Bloc.dart`, `PageName_Event.dart`, `PageName_State.dart`, `PageName_UI.dart`
- Seller BLoC convention: `page_name__bloc.dart`, `page_name__event.dart`, `page_name__state.dart`, `page_name__ui.dart`
- Repository pattern: abstract interfaces in `core/repositories/`, implementations in `repositories/`
- DI: `RepositoryProvider` + `BlocProvider` in `main.dart`
- Packages: `flutter_bloc: ^9.1.1`, `equatable: ^2.0.8`, `firebase_auth`, `cloud_firestore`, `shared_preferences`, `get_it`

### Existing Files to Analyze

**Buyer App Settings (placeholder):**
`lib/features/buyer_bloc_architecture/user_profile_image/pages/app_settings_page.dart`
— Currently just `Text('App Settings Page (Placeholder)')`. No BLoC, no functionality.

**Seller Settings (fully implemented — reference only, do NOT copy blindly):**
`lib/features/seller_bloc_architecture/seller_setting_page/`
— Files: `seller_setting_page__bloc.dart`, `seller_setting_page__event.dart`, `seller_setting_page__state.dart`, `seller_setting_page__ui.dart`
— Settings: Push Notifications, New Order Sound, Promo & Offers, Low Stock Alerts, Order Updates, App Theme, Language
— Persists to Firestore `seller_notification_settings`
— Uses `SellerSettingRepository` + `SellerSettingRepositoryImpl`

**Buyer profile sub-pages (review for UI patterns):**
`lib/features/buyer_bloc_architecture/user_profile_image/pages/`
— personal_information_page.dart, payment_methods_page.dart, notification_settings_page.dart, help_support_page.dart, address_management_page.dart

**Other buyer pages to study for convention consistency:**
— `Favorites_Page/`, `Cart Page/`, `Order Page/`, `WalletScreen/`, `Chat_Page/`

---

## Important Constraints

Before writing any code:

1. Perform a complete architecture audit first.
2. Reuse existing Buyer architecture wherever possible.
3. Do NOT duplicate existing functionality.
4. Do NOT modify folder structure unless absolutely necessary.
5. Do NOT introduce new dependencies unless required.
6. Follow the existing Buyer BLoC naming convention exactly.
7. Keep Clean Architecture intact.
8. Keep Repository pattern intact.
9. Keep Dependency Injection intact.
10. Produce an implementation plan FIRST.
11. Wait until the plan is approved before generating code.

---

## Architecture Audit Report Required

Produce a comprehensive report covering:

### 1. Existing Components Inventory
- Existing repositories (list all in `core/repositories/` and `repositories/`)
- Existing services (`core/services/`, `api_service/`)
- Existing models (`core/models/`, feature-specific models)
- Existing shared widgets (`core/widgets/`, `widgets/`)
- Existing utilities and helpers

### 2. Existing Features Analysis
- Notification feature (FCM, notification_service, audio_notification_service)
- Authentication feature (auth_service, login/signup pages)
- Theme handling (check seller theme implementation, MaterialApp setup in main.dart)
- Localization (check if any l10n/intl setup exists)
- Cache management
- Firestore usage patterns
- SharedPreferences usage

### 3. Reusable Components
List every existing component that can be reused instead of creating new ones.

### 4. Missing Components
List only the components that truly need to be created.

### 5. Risks
Identify all possible architecture conflicts, naming convention violations, DI issues.

### 6. Recommendations
Provide the best implementation strategy while keeping the architecture consistent.

---

## Settings Matrix

Create this table with all rows filled:

| Setting | Exists Already | Reuse From | New | Storage | Priority |
|---|---|---|---|---|---|
| Theme (Light/Dark/System) | | | | | |
| Language | | | | | |
| Push Notifications | | | | | |
| Order Notifications | | | | | |
| Offer Notifications | | | | | |
| Chat Notifications | | | | | |
| Sound | | | | | |
| Vibration | | | | | |
| Location Permission | | | | | |
| Default Address | | | | | |
| Default Payment Method | | | | | |
| Biometric Login | | | | | |
| Privacy Policy | | | | | |
| Terms & Conditions | | | | | |
| App Version | | | | | |
| About | | | | | |
| Clear Cache | | | | | |
| Delete Account | | | | | |
| Logout | | | | | |

---

## UI Requirements

Design a premium settings page inspired by:
- Google Play, Swiggy, Zomato, Amazon, Uber Eats

Requirements:
- Material 3 design language
- Responsive layout: Desktop, Tablet, Mobile
- Glassmorphism where appropriate
- Smooth staggered animations
- Sectioned settings with headers
- Search settings functionality
- Icon-based setting tiles
- Adaptive layout
- Accessibility support (sufficient contrast, large touch targets)
- High contrast mode support
- Dark/Light theme switching seamless

---

## Data & Storage Design

### Firestore Schema
Propose the exact collection name, document ID strategy, and field structure for buyer settings.

### SharedPreferences Schema
Propose key-value pairs for any local-only settings.

---

## BLoC Architecture Design

### Repository Design
- Interface name, methods, return types
- Implementation class, Firestore/local integration
- Error handling strategy

### Event Design
- All events with full class signatures extending Equatable
- Props for each event

### State Design
- Complete state class with all fields, defaults, copyWith, Equatable props
- Loading, error, success states

### BLoC Flow
- Event → handler → repository call → state emission
- Error handling per event
- Debouncing / throttling if needed

---

## Navigation & DI Integration

### Navigation Flow
- How user reaches App Settings from profile page
- Route configuration in main.dart or CurvedNavigationBarView

### Dependency Injection
- How to provide AppSettingsBloc and AppSettingsRepository
- Where in main.dart's MultiRepositoryProvider / MultiBlocProvider tree
- Any lazy initialization needed

---

## Final Output Order

Your report MUST follow this structure:

1. Architecture Audit
2. Existing Components Inventory
3. Reusable Components
4. Missing Components
5. Settings Matrix (complete table)
6. Data Flow Diagram (text-based)
7. Firestore Schema
8. SharedPreferences Schema
9. Repository Design
10. Event Design
11. State Design
12. BLoC Flow (per event)
13. UI Structure (widget tree description)
14. Navigation Flow
15. Dependency Injection Wiring
16. Implementation Roadmap (phased)
17. Risks & Mitigations
18. Final Recommendations

Do NOT generate any Dart code until the implementation plan is approved.

Once approved, produce:
- `AppSettings_Bloc.dart`
- `AppSettings_Event.dart`
- `AppSettings_State.dart`
- `AppSettings_Repository.dart` (interface)
- `AppSettings_RepositoryImpl.dart`
- `app_settings_page.dart` (full UI)
- Update to `main.dart` (DI wiring)
