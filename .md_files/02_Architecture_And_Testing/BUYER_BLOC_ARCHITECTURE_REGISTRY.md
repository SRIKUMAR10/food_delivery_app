# 🛒 Buyer BLoC / Cubit Architectural Registry

This registry documents all 20+ BLoCs, Cubits, Events, States, Repositories, and Services implemented under `lib/features/buyer_bloc_architecture/` for the enterprise Multi-Platform Food Delivery application.

---

## 1. Architectural Overview & Design Patterns

The Buyer Module adheres strictly to **Clean Architecture** with **BLoC Pattern (flutter_bloc)**:
- **Presentation Layer**: Responsive UI widgets with real-time UI/UX updates (`*_ui.dart`, `*_UI.dart`, `*_page.dart`).
- **BLoC / Cubit Layer**: State management handling UI events, stream transformations, and emitting immutable states (`*_bloc.dart`, `*_Bloc.dart`, `*_event.dart`, `*_state.dart`).
- **Data & Repository Layer**: Direct Firestore stream integration (`cloud_firestore`, `firebase_storage`, `cloud_functions`), strictly eliminating hardcoded fallbacks and static placeholders.
- **8-Step KYC & Profile Setup Wizard**: Built under `buyer_onboarding_verification_page/` for end-to-end customer onboarding, geolocation pinning, dietary preferences, wallet activation, and permissions.

---

## 2. Feature BLoC / Cubit Mapping Matrix

| Requested Feature BLoC | Implemented BLoC / Cubit | Directory Location | Primary Scope & Responsibilities |
|---|---|---|---|
| **BuyerAuthBloc** | `OnboardingPageBloc`<br>`BuyerLoginPageBloc`<br>`BuyerSignUpBloc`<br>`BuyerOtpBloc`<br>`BuyerForgotPasswordBloc` | `onboarding_page/`<br>`buyer_login_page/`<br>`buyer_sign_up_page/`<br>`buyer_otp_verification_page/`<br>`buyer_forgot_password_page/` | Splash onboarding, multi-method auth (Email, Phone/OTP, Google, Apple), phone credential verification, password recovery. |
| **BuyerVerificationWizardBloc** | `BuyerOnboardingVerificationBloc` | `buyer_onboarding_verification_page/` | 8-Step progressive customer KYC, address geolocation, dietary habits, food allergies, payment preferences, wallet bonus. |
| **HomeDiscoveryBloc** | `HomePageBloc` | `home_Page/` | Real-time active food catalogue, category filters, restaurant availability stream, dish search. |
| **DishDetailsBloc** | `DetailsPageBloc` | `Details_Page/` | Food item customization, size variants, add-on toppings, dynamic pricing, cart addition. |
| **FavoritesBloc** | `FavoritesBloc` | `Favorites_Page/` | Real-time bookmarked dishes & favorite restaurants stream (`buyer_user/{uid}/favorites`). |
| **CartBloc** | `CartPageBloc` | `Cart Page/` | Real-time shopping cart item modifiers, GST calculation, delivery fee, promo coupon application. |
| **PaymentGatewayBloc** | `PaymentMethodsBloc` | `PaymentMethodsPage/` | UPI, Saved Cards, Net Banking, COD selection, Cloud Function payment validation. |
| **BuyerWalletBloc** | `WalletScreenBloc` | `WalletScreen/` | Live wallet balance stream, instant top-up, cashback rewards ledger, ledger transactions. |
| **OrderLifecycleBloc** | `OrderBloc` | `Order Page/` | Active order pipeline (Placed ➔ Preparing ➔ Ready ➔ Out for Delivery ➔ Delivered) & history. |
| **LiveTrackingBloc** | `TrackOrderBloc` | `Track_Order_page/` | Real-time rider GPS stream, 60 FPS marker interpolation, Google Maps polyline routing, dynamic ETA. |
| **RatingsFeedbackBloc** | `RatingPageBloc` | `Rating_page/` | Multi-criteria star ratings (Food & Delivery), compliment tags, photo uploads, reviews feed. |
| **BuyerChatBloc** | `BuyerChatBloc` | `Chat_Page/` | Real-time chat with rider/restaurant/support, voice notes, camera captures, PDF invoice generator. |
| **VoiceVideoCallBloc** | `VideoCallBloc` | `Chat_Page/` | WebRTC / Agora live calling interface with delivery partner and platform customer support. |
| **NotificationsBloc** | `BuyerNotificationBloc` | `Notifications_page/` | FCM push notification center, categorized inbox, unread counts, mark-as-read stream. |
| **CustomerSupportBloc** | `HelpSupportBloc` | `HelpSupportPage/` | Dispute reporting, ticket submission to Firestore `support_tickets`, FAQ search accordion. |
| **UserProfileBloc** | `UserProfileImageBloc` | `user_profile_image/` | User avatar upload, personal info updates, address management, Google Places search. |
| **AppSettingsBloc** | `AppSettingsBloc` | `user_profile_image/` | Multi-language localization (EN / TA), dark/light theme toggle, push notification settings. |

---

## 3. Directory & File Inventory (20 Feature Modules)

1. `onboarding_page/`: `OnboardingPageBloc`, `OnboardingPageEvent`, `OnboardingPageState`, `OnboardingPage`, `OnboardingPageView`
2. `buyer_login_page/`: `BuyerLoginPageBloc`, `BuyerLoginPageEvent`, `BuyerLoginPageState`, `BuyerLoginPageUI`, `BuyerLoginRepository`
3. `buyer_sign_up_page/`: `BuyerSignUpBloc`, `BuyerSignUpEvent`, `BuyerSignUpState`, `BuyerSignUpPageUI`, `BuyerSignUpRepository`
4. `buyer_otp_verification_page/`: `BuyerOtpBloc`, `BuyerOtpEvent`, `BuyerOtpState`, `BuyerOtpVerificationPageUI`, `BuyerOtpRepository`
5. `buyer_forgot_password_page/`: `BuyerForgotPasswordBloc`, `BuyerForgotPasswordEvent`, `BuyerForgotPasswordState`, `BuyerForgotPasswordPageUI`, `BuyerForgotPasswordRepository`
6. `buyer_onboarding_verification_page/`: `BuyerOnboardingVerificationBloc`, `BuyerOnboardingVerificationEvent`, `BuyerOnboardingVerificationState`, `BuyerOnboardingVerificationPage`, `BuyerOnboardingVerificationRepository`
7. `CurvedNavigationBarView/`: `CurvedNavigationBarView`
8. `home_Page/`: `HomePageBloc`, `HomePageEvent`, `HomePageState`, `HomePageUI`, `FoodItemMapper`, `HomePageModels`, `SellerModel`
9. `Details_Page/`: `DetailsPageBloc`, `DetailsPageEvent`, `DetailsPageState`, `DetailsPageUI`, `DetailsRepository`
10. `Favorites_Page/`: `FavoritesBloc`, `FavoritesEvent`, `FavoritesState`, `FavoritesPageUI`, `FavoritesModels`
11. `Cart Page/`: `CartPageBloc`, `CartPageEvent`, `CartPageState`, `CartPageUI`, `CartModels`
12. `PaymentMethodsPage/`: `PaymentMethodsBloc`, `PaymentMethodsEvent`, `PaymentMethodsState`, `PaymentMethodsUI`
13. `WalletScreen/`: `WalletScreenBloc`, `WalletScreenEvent`, `WalletScreenState`, `WalletScreenUI`
14. `Order Page/`: `OrderBloc`, `OrderEvent`, `OrderState`, `OrderPageUI`, `OrderMapper`, `OrderViewModel`
15. `Track_Order_page/`: `TrackOrderBloc`, `TrackOrderEvent`, `TrackOrderState`, `TrackOrderPageUI`, `TrackOrderRepository`, `TrackOrderService`
16. `Rating_page/`: `RatingPageBloc`, `RatingPageEvent`, `RatingPageState`, `RatingPageUI`, `ReviewsListScreen`
17. `Chat_Page/`: `BuyerChatBloc`, `BuyerChatEvent`, `BuyerChatState`, `BuyerChatUI`, `VideoCallBloc`, `VideoCallEvent`, `VideoCallState`, `VoiceCallPage`, `VideoCallPage`, `CustomCameraPage`, `InvoiceGenerator`
18. `Notifications_page/`: `BuyerNotificationBloc`, `BuyerNotificationEvent`, `BuyerNotificationState`, `BuyerNotificationUI`, `BuyerNotificationService`, `BuyerNotificationStrings`
19. `HelpSupportPage/`: `HelpSupportBloc`, `HelpSupportEvent`, `HelpSupportState`, `HelpSupportUI`, `HelpSupportRepository`
20. `user_profile_image/`: `UserProfileImageBloc`, `UserProfileImageEvent`, `UserProfileImageState`, `UserProfileImageUI`, `AppSettingsBloc`, `AppSettingsEvent`, `AppSettingsState`, `AppSettingsUI`, `TransactionsPage`, `AddressManagementPage`, `PersonalInformationPage`, `GoogleAddressSearchDialog`
