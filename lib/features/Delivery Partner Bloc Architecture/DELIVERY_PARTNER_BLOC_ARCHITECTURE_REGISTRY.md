# 🛵 Delivery Partner BLoC / Cubit Architectural Registry

This registry documents all BLoCs, Cubits, Events, States, Repositories, and Services implemented under `lib/features/Delivery Partner Bloc Architecture/` for the enterprise Food Delivery platform.

---

## 1. Architectural Overview & Design Patterns

The Delivery Partner Module adheres strictly to **Clean Architecture** with **BLoC Pattern (flutter_bloc)**:
- **Presentation Layer**: Responsive UI widgets with real-time UI/UX updates (`*_ui.dart`).
- **BLoC / Cubit Layer**: State management handling UI events, GPS streams, lifecycle state machines, and emitting immutable states (`*_bloc.dart`, `*_event.dart`, `*_state.dart`).
- **Data & Repository Layer**: Direct Firestore stream integration (`cloud_firestore`), eliminating hardcoded fallbacks and static placeholders (`delivery_partners/{uid}`).
- **Unified Barrel Export**: Available at `lib/features/Delivery Partner Bloc Architecture/delivery_partner_blocs.dart`.

---

## 2. Feature BLoC / Cubit Mapping Matrix

| # | Requested Feature BLoC | Implemented BLoC / Cubit | Directory Location | Primary Responsibilities & Real-Time Sync |
|---|---|---|---|---|
| **01** | **DeliveryAuthBloc** | `DeliveryLoginPageBloc`<br>`DeliverySignUpPageBloc`<br>`DeliveryOtpVerificationPageBloc`<br>`DeliveryForgotPasswordBloc`<br>`DeliveryOnboardingPageBloc` | `Delivery_Login Page/`<br>`Delivery_Sign_Up_page/`<br>`Delivery_OTP_Verification_page/`<br>`Delivery_Forgot_Password_page/`<br>`Delivery_onboarding_page/` | Multi-method authentication (Email, Phone OTP, Google, Apple), session management, password recovery. |
| **02** | **DeliveryVerificationBloc** | `DeliveryOnboardingVerificationBloc` | `Delivery_onboarding_verification_page/` | 8-step KYC, vehicle registration, driving license, bank payouts, GPS zones, hardware permissions & kit activation. |
| **03** | **DeliveryProfileBloc** | `DeliveryProfilePageBloc` | `Delivery_Profile_page/` | Partner profile stream, KYC document expiry tracking, vehicle info, payout settings, rating badge. |
| **04** | **DeliveryDashboardBloc** | `DeliveryDashboardPageBloc`<br>`DeliveryNavigationBarPageBloc` | `Delivery_Dashboard_page/`<br>`Delivery_NavigationBar_page/` | Real-time shift metrics: today's earnings, completed trips, acceptance rate, customer rating, bottom shell navigation. |
| **05** | **AvailabilityCubit** | `AvailabilityCubit` | `Delivery_Dashboard_page/` | Live duty status toggle (`online`, `offline`, `busy`, `auto_offline`), background location heartbeat. |
| **06** | **AvailableOrdersBloc** | `DeliveryIncomingOrderPageBloc` | `Delivery_Incoming_Order_page/` | Broadcast ride requests, 30s countdown timer, haptic & looping audio alert, atomic order acceptance lock. |
| **07** | **DeliveryOrderBloc** | `DeliveryOrdersPageBloc` | `Delivery_Orders_page/` | Active order lifecycle pipeline (`assigned` ➔ `accepted` ➔ `arrived_store` ➔ `picked_up` ➔ `in_transit` ➔ `arrived_customer` ➔ `delivered`). |
| **08** | **OrderDetailsBloc** | `DeliveryOrderDetailsPageBloc` | `Delivery_Order_Details_page/` | Order item breakdown, restaurant instructions, customer delivery notes, prep status stream. |
| **09** | **PickupBloc** | `DeliveryPickupConfirmationPageBloc` | `Delivery_Pickup Confirmation_page/` | Store geofence arrival, order item checklist verification, merchant pickup OTP/QR confirmation. |
| **10** | **DeliveryTrackingBloc** | `DeliveryDeliveryCompletedPageBloc` | `Delivery_Delivery Completed_page/` | Doorstep delivery proof, customer OTP verification, COD payment collection, completion telemetry. |
| **11** | **LiveLocationBloc** | `LiveLocationBloc` | `Delivery_Navigation Screen_page/` | High-frequency GPS telemetry, background geofencing, heading calculation, Firestore rider location stream. |
| **12** | **NavigationBloc** | `DeliveryNavigationScreenPageBloc` | `Delivery_Navigation Screen_page/` | Turn-by-turn routing HUD, external map switcher (Google Maps/Apple Maps/Waze), emergency quick actions. |
| **13** | **EarningsBloc** | `DeliveryEarningsDashboardPageBloc` | `Delivery_Earnings Dashboard_page/` | Daily/weekly/monthly revenue breakdown, trip fares, tips, surge multiplier, performance bonuses. |
| **14** | **WalletBloc** | `DeliveryWalletPageBloc` | `Delivery_Wallet_page/` | Real-time wallet balance, cash-in-hand safety limit, UPI deposit gateway, instant bank payout transfers. |
| **15** | **IncentiveBloc** | `DeliveryIncentivesDashboardPageBloc` | `Delivery_Incentives Dashboard_page/` | Milestone target challenges, peak-hour streaks, weekly leaderboard, tier badges. |
| **16** | **RatingBloc** | `DeliveryRatingBloc` | `Delivery_Dashboard_page/` | Star rating distribution, customer compliments (Speed, Politeness, Packaging), performance feedback. |
| **17** | **DeliveryHistoryBloc** | `DeliveryOrderHistoryPageBloc` | `Delivery_Order History_page/` | Archived trips log, date-range filters, route playback summaries, trip earnings breakdown. |
| **18** | **ChatBloc** | `DeliveryChatPageBloc` | `Delivery_Chat_page/` | Multi-party real-time chat (Buyer, Merchant, Rider Support) with image and quick canned responses. |
| **19** | **NotificationBloc** | `DeliveryNotificationBloc` | `Delivery_Notifications_page/` | FCM push notification center, priority dispatch alerts, incentive announcements, penalty alerts. |
| **20** | **SupportBloc** | `DeliveryHelpSupportPageBloc` | `Delivery_Help_Support_page/` | Instant SOS emergency dispatch, safety dispute tickets, live support desk, help center FAQs. |
| **21** | **SettingsBloc** | `DeliverySettingsPageBloc` | `Delivery_Settings_page/` | Navigation app preference, voice guidance toggles, audio alert volume, localization (EN / TA), dark mode. |

---

## 3. Directory & File Inventory (23 Modules)

1. `Delivery_onboarding_page/`: `DeliveryOnboardingPageBloc`, `DeliveryOnboardingPageEvent`, `DeliveryOnboardingPageState`, `DeliveryOnboardingPageUI`, `DeliveryOnboardingPageRepository`, `DeliveryOnboardingPageService`
2. `Delivery_Login Page/`: `DeliveryLoginPageBloc`, `DeliveryLoginPageEvent`, `DeliveryLoginPageState`, `DeliveryLoginPageUI`, `DeliveryLoginPageRepository`, `DeliveryLoginPageService`, `DeliveryAuthBloc`
3. `Delivery_Sign_Up_page/`: `DeliverySignUpPageBloc`, `DeliverySignUpPageEvent`, `DeliverySignUpPageState`, `DeliverySignUpPageUI`, `DeliverySignUpPageRepository`, `DeliverySignUpPageService`
4. `Delivery_OTP_Verification_page/`: `DeliveryOTPVerificationPageBloc`, `DeliveryOTPVerificationPageEvent`, `DeliveryOTPVerificationPageState`, `DeliveryOTPVerificationPageUI`, `DeliveryOTPVerificationPageRepository`, `DeliveryOTPVerificationPageService`
5. `Delivery_Forgot_Password_page/`: `DeliveryForgotPasswordPageBloc`, `DeliveryForgotPasswordPageEvent`, `DeliveryForgotPasswordPageState`, `DeliveryForgotPasswordPageUI`, `DeliveryForgotPasswordPageRepository`, `DeliveryForgotPasswordPageService`
6. `Delivery_onboarding_verification_page/`: `DeliveryOnboardingVerificationBloc`, `DeliveryOnboardingVerificationEvent`, `DeliveryOnboardingVerificationState`, `DeliveryOnboardingVerificationUI`, `DeliveryDocumentsPage`, `DeliveryOnboardingVerificationRepository`
7. `Delivery_NavigationBar_page/`: `DeliveryNavigationBarPageBloc`, `DeliveryNavigationBarPageEvent`, `DeliveryNavigationBarPageState`, `DeliveryNavigationBarPageUI`, `DeliveryNavigationBarPageRepository`, `DeliveryNavigationBarPageService`
8. `Delivery_Dashboard_page/`: `DeliveryDashboardPageBloc`, `DeliveryDashboardPageEvent`, `DeliveryDashboardPageState`, `DeliveryDashboardPageUI`, `DeliveryDashboardPageRepository`, `DeliveryDashboardPageService`, `AvailabilityCubit`, `DeliveryRatingBloc`
9. `Delivery_Incoming_Order_page/`: `DeliveryIncomingOrderPageBloc`, `DeliveryIncomingOrderPageEvent`, `DeliveryIncomingOrderPageState`, `DeliveryIncomingOrderPageUI`, `DeliveryIncomingOrderPageRepository`, `DeliveryIncomingOrderPageService`
10. `Delivery_Orders_page/`: `DeliveryOrdersPageBloc`, `DeliveryOrdersPageEvent`, `DeliveryOrdersPageState`, `DeliveryOrdersPageUI`, `DeliveryOrdersPageRepository`, `DeliveryOrdersPageService`
11. `Delivery_Order_Details_page/`: `DeliveryOrderDetailsPageBloc`, `DeliveryOrderDetailsPageEvent`, `DeliveryOrderDetailsPageState`, `DeliveryOrderDetailsPageUI`, `DeliveryOrderDetailsPageRepository`, `DeliveryOrderDetailsPageService`
12. `Delivery_Pickup Confirmation_page/`: `DeliveryPickupConfirmationPageBloc`, `DeliveryPickupConfirmationPageEvent`, `DeliveryPickupConfirmationPageState`, `DeliveryPickupConfirmationPageUI`, `DeliveryPickupConfirmationPageRepository`, `DeliveryPickupConfirmationPageService`
13. `Delivery_Navigation Screen_page/`: `DeliveryNavigationScreenPageBloc`, `DeliveryNavigationScreenPageEvent`, `DeliveryNavigationScreenPageState`, `DeliveryNavigationScreenPageUI`, `DeliveryNavigationScreenPageRepository`, `DeliveryNavigationScreenPageService`, `LiveLocationBloc`
14. `Delivery_Delivery Completed_page/`: `DeliveryDeliveryCompletedPageBloc`, `DeliveryDeliveryCompletedPageEvent`, `DeliveryDeliveryCompletedPageState`, `DeliveryDeliveryCompletedPageUI`, `DeliveryDeliveryCompletedPageRepository`, `DeliveryDeliveryCompletedPageService`
15. `Delivery_Earnings Dashboard_page/`: `DeliveryEarningsDashboardPageBloc`, `DeliveryEarningsDashboardPageEvent`, `DeliveryEarningsDashboardPageState`, `DeliveryEarningsDashboardPageUI`, `DeliveryEarningsDashboardPageRepository`, `DeliveryEarningsDashboardPageService`
16. `Delivery_Wallet_page/`: `DeliveryWalletPageBloc`, `DeliveryWalletPageEvent`, `DeliveryWalletPageState`, `DeliveryWalletPageUI`, `DeliveryBankDetailsPage`, `DeliveryWalletPageRepository`, `DeliveryWalletPageService`
17. `Delivery_Incentives Dashboard_page/`: `DeliveryIncentivesDashboardPageBloc`, `DeliveryIncentivesDashboardPageEvent`, `DeliveryIncentivesDashboardPageState`, `DeliveryIncentivesDashboardPageUI`, `DeliveryIncentivesDashboardPageRepository`, `DeliveryIncentivesDashboardPageService`
18. `Delivery_Order History_page/`: `DeliveryOrderHistoryPageBloc`, `DeliveryOrderHistoryPageEvent`, `DeliveryOrderHistoryPageState`, `DeliveryOrderHistoryPageUI`, `DeliveryOrderHistoryPageRepository`, `DeliveryOrderHistoryPageService`
19. `Delivery_Chat_page/`: `DeliveryChatPageBloc`, `DeliveryChatPageEvent`, `DeliveryChatPageState`, `DeliveryChatPageUI`, `DeliveryChatPageRepository`, `DeliveryChatPageService`
20. `Delivery_Notifications_page/`: `DeliveryNotificationBloc`, `DeliveryNotificationEvent`, `DeliveryNotificationState`, `DeliveryNotificationsPageUI`, `DeliveryNotificationRepository`, `DeliveryNotificationService`
21. `Delivery_Help_Support_page/`: `DeliveryHelpSupportPageBloc`, `DeliveryHelpSupportPageEvent`, `DeliveryHelpSupportPageState`, `DeliveryHelpSupportPageUI`, `DeliveryHelpSupportPageRepository`, `DeliveryHelpSupportPageService`
22. `Delivery_Profile_page/`: `DeliveryProfilePageBloc`, `DeliveryProfilePageEvent`, `DeliveryProfilePageState`, `DeliveryProfilePageUI`, `DeliveryProfilePageRepository`, `DeliveryProfilePageService`, `DeliveryGoogleAddressSearchDialog`
23. `Delivery_Settings_page/`: `DeliverySettingsPageBloc`, `DeliverySettingsPageEvent`, `DeliverySettingsPageState`, `DeliverySettingsPageUI`, `DeliverySettingsPageRepository`, `DeliverySettingsPageService`

---

## 4. Usage Example

To access any Delivery Partner BLoC, Cubit, or typed alias:

```dart
import 'package:food_delivery_app/features/Delivery%20Partner%20Bloc%20Architecture/delivery_partner_blocs.dart';

// Accessing Dashboard BLoC
BlocProvider<DeliveryDashboardBloc>(
  create: (context) => DeliveryDashboardBloc()..add(const FetchDashboardDataEvent()),
  child: const DeliveryDashboardPageUI(),
);

// Accessing Onboarding Verification BLoC
BlocProvider<DeliveryOnboardingVerificationBloc>(
  create: (context) => DeliveryOnboardingVerificationBloc()..add(const DeliveryVerificationAutoFetchRequested()),
  child: const DeliveryOnboardingVerificationPage(),
);
```
