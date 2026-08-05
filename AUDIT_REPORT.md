# Delivery Partner Bloc Architecture – Full Audit Report

> **Generated:** 2026-08-03
> **App Mode:** `AppMode.delivery`
> **Routing:** `Map<String, WidgetBuilder>` (named routes)
> **Base Path:** `lib/features/Delivery Partner Bloc Architecture/`

---

## 1. Page Inventory Table

| # | Page Name | Route | Has BLoC | Has Repo | Has Service | Data Source | Status | UI Lines |
|---|-----------|-------|----------|----------|-------------|-------------|--------|----------|
| 1 | Onboarding | `/deliveryonboard` | Yes | Yes | Yes | Mock (`Future.delayed`) | Static | 937 |
| 2 | Login | `/deliverylogin` | Yes | Yes | Yes | Firebase Auth | Wired | 750 |
| 3 | Sign Up | `/deliverySignUp` | Yes | Yes | Yes | Firebase Auth | Wired | 505 |
| 4 | Forgot Password | `/deliveryForgotPassword` | Yes | No (shared) | No | Firebase Auth | Wired | 283 |
| 5 | OTP Verification | `/deliveryOtpVerification` | Yes | Yes | No | Firebase Phone Auth | Wired | 453 |
| 6 | NavigationBar | `/deliveryNavigationBar` | Yes | Yes | Yes | Mock | Static | 1608 |
| 7 | Dashboard | (tab 0) | Yes | Yes | Yes | Mock | Static | 2535 |
| 8 | Orders | (tab 1) | Yes | Yes | Yes | Mock | Static | 2485 |
| 9 | Order Details | `/deliveryOrderDetails` | Yes | No | No | Mock (in BLoC) | Static | 445 |
| 10 | Order History | (tab 6) | Yes | Yes | Yes | Mock | Static | 1985 |
| 11 | Wallet | (tab 5) | Yes | Yes | Yes | Mock | Static | 2441 |
| 12 | Earnings Dashboard | (tab 2) | Yes | Yes | Yes | Mock | Static | 1549 |
| 13 | Incentives Dashboard | (tab 3) | Yes | Yes | Yes | Mock | Static | 2236 |
| 14 | Profile | (tab 8) | Yes | Yes | Yes | Mixed | Static | 1464 |
| 15 | Settings | (tab 7) | Yes | Yes | Yes | Mixed | Static | 1113 |
| 16 | Navigation Screen | `/deliveryNavigationScreen` | Yes | Yes | Yes | Mock | Static | 2039 |
| 17 | Incoming Order | `/deliveryIncomingOrder` | **No BLoC** | No | No | Local AnimationController | Static | 295 |
| 18 | Pickup Confirmation | `/deliveryPickupConfirmation` | Yes | Yes | Yes | Mock | Static | 1735 |
| 19 | Delivery Completed | `/deliveryCompleted` | Yes | Yes | Yes | Mock | Static | 1980 |

**Summary:** 15 static placeholder pages, 4 auth-wired to Firebase. 18 of 19 pages have BLoC architecture.

---

## 2. Navigator Flow Diagram

```
App.Start
    │
    ▼
┌──────────────────────────────────────────────────────────┐
│ /deliveryonboard                                         │
│ DeliveryOnboardingPageUI (BlocProvider in route)         │
│ GetStarted → /deliverylogin (pushNamed)                  │
└─────────────────────────┬────────────────────────────────┘
                          │
          ┌───────────────┼───────────────┐
          ▼               ▼               ▼
┌───────────────┐  ┌──────────────┐  ┌───────────────────┐
│ /deliverylogin │  │/deliverySignUp│  │/deliveryForgotPwd │
│ LoginPage      │  │SignUpPage    │  │ForgotPwdPage      │
│ ─────────────  │  ─────────────  │ ────────────────    │
│ Phone/Pwd/     │  │ Name/Phone/  │  │ Phone → OTP →     │
│ Google/Apple   │  │ Email/Pwd/   │  │ Verify OTP →      │
│                │  │ Terms        │  │ New Pwd/Confirm   │
│ Success →      │  │ Submitted →  │  │ ────────────────  │
│ /deliveryNav   │  │ OTP Verify   │  │ Reset Success →   │
│ SignUp →       │  │ (pushNamed)  │  │ pop back to Login │
│ /deliverySignUp│  │ LoginBtn →   │  └───────────────────┘
│ ForgotPwd →    │  │ /deliverylogin│
│ /delForgotPwd  │  └──────┬───────┘
└───────┬───────┘         │
        │                 ▼
        │          ┌───────────────────┐
        │          │/deliveryOtpVerify │
        │          │OtpVerifyPage      │
        │          │ args: verifyId,   │
        │          │ name,phone,email, │
        │          │ password          │
        │          │ ────────────────  │
        │          │ OTP → Firebase    │
        │          │ CompleteVerify    │
        │          │ + CreateAccount   │
        │          │ Success →         │
        │          │ /deliverylogin    │
        │          └───────────────────┘
        ▼
┌──────────────────────────────────────────────────────────┐
│ /deliveryNavigationBar  (CENTRAL HUB)                    │
│ DeliveryNavigationBarPage (IndexedStack + Sidebar/BottomNav)│
│ ─────────────────────────────────────────────────────    │
│ [0] Dashboard                 ::DashboardPage            │
│ [1] Orders                    ::OrdersPage               │
│ [2] Earnings                  ::EarningsDashboardPage    │
│ [3] Incentives                ::IncentivesDashboardPage  │
│ [4] Navigate  → /deliveryNavigationScreen (push)         │
│ [5] Wallet                    ::WalletPage               │
│ [6] Order History             ::OrderHistoryPage         │
│ [7] Settings                  ::SettingsPage             │
│ [8] Profile                   ::ProfilePage              │
│ ───                                                      │
│ Logout → FirebaseAuth.signOut() → /deliveryonboard       │
└───────────────────────┬──────────────────────────────────┘
                        │
    ┌───────────────────┼───────────────────────┐
    ▼                   ▼                       ▼
┌──────────────────┐  ┌──────────────────┐  ┌──────────────────────┐
│/deliveryOrderDtl │  │/deliveryIncoming │  │/deliveryPickupConfirm│
│OrderDetails      │  │IncomingOrder     │  │PickupConfirmation    │
│ args: {orderId}  │  │(no args, no BLoC)│  │ args: {orderId}      │
│                  │  │15s countdown     │  │                      │
│ **GAP: not      │  │**GAP: no BLoC**  │  │ Accept → ConfirmPickup│
│  navigable from │  │Accept → no nav   │  │ StartDelivery →      │
│  Orders page**  │  │Decline → pop     │  │ **GAP: no nav**      │
└──────────────────┘  └────────┬─────────┘  └──────────┬───────────┘
                               │                        │
                   Accept btn ─┘                        │
                   (needs nav to Pickup)                │
                                                        ▼
                                          ┌──────────────────────┐
                                          │/deliveryNavScreen    │
                                          │DeliveryNavigation    │
                                          │ Live nav + SOS       │
                                          │ Arrived → **GAP:     │
                                          │  no nav to Complete**│
                                          └──────────┬───────────┘
                                                     │
                                                     ▼
                                          ┌──────────────────────┐
                                          │/deliveryCompleted    │
                                          │DeliveryCompleted     │
                                          │ args: {orderId}      │
                                          │ Rating + Earnings    │
                                          │ ReturnHome → pop to  │
                                          │ NavigationBar        │
                                          └──────────────────────┘


Cross-BLoC State Machine:
─────────────────────────

  DeliveryActiveOrderSessionRepository (broadcast stream)

  IDLE ──triggerIncomingOrder()──► INCOMING_ORDER
                                       │
                          ┌────────────┴────────────┐
                     acceptOrder()            declineOrder()
                          │                        │
                          ▼                        ▼
                  ACCEPTED_ORDER                  IDLE
                          │
                   confirmPickup()
                          │
                          ▼
                NAVIGATING_TO_CUSTOMER
                          │
                   completeDelivery()
                    (+earnings, +wallet, +count)
                          │
                          ▼
                DELIVERY_COMPLETED
                          │
                     resetOrder()
                          │
                          ▼
                        IDLE

  Stream consumed by: None currently. Dashboard, Wallet, Earnings,
  Pickup, Completed BLoCs need subscription added (GAP-11).
```

---

## 3. Per-Page Audit

---

### 3.1 Delivery_Onboarding (`Delivery_onboarding_page/`)

| Field | Detail |
|-------|--------|
| **BLoC** | `DeliveryOnboardingPageBloc` |
| **Status Enum** | `initial, loading, loaded, error` |
| **State Fields** | `status`, `localeCode`, `isVideoUploading`, `uploadProgress`, `selectedLanguage`, `partnerStats` (2 items), `features` (4 items), `errorMessage` |

| Event | Handler | Repo/Service Call | Emitted State |
|-------|---------|-------------------|---------------|
| `InitEvent` | `_onInit` | `_repo.getOnboardingData()` | `copyWith(status: .loaded, features, partnerStats)` |
| `LanguageChangedEvent` | `_onLanguageChanged` | — | `copyWith(localeCode, selectedLanguage)` |
| `GetStartedClickedEvent` | `_onGetStarted` | — | No change, nav handled by UI |
| `LoginClickedEvent` | `_onLoginClicked` | — | No state emit |
| `RefreshEvent` | `_onRefresh` | `_repo.getOnboardingData()` | `copyWith(status: .loaded)` |
| `SimulateVideoUploadEvent` | `_onSimulateVideoUpload` | `_service.uploadVideo()` (stream) | `copyWith(isVideoUploading, uploadProgress)` |
| `EmailSignInClickedEvent` | **Not handled** | — | **GAP-14** |

| Navigation | Trigger | Route |
|------------|---------|-------|
| "Get Started" | UI onTap | `/deliverylogin` |
| "Login" | UI onTap | `/deliverylogin` |

| Gaps |
|------|
| Navigation hardcoded in UI, not via BLoC event |
| `EmailSignInClickedEvent` defined but no `on<Event>` handler |
| Mock repository with 2-second delay |

---

### 3.2 Delivery_Login (`Delivery_Login Page/`)

| Field | Detail |
|-------|--------|
| **BLoC** | `DeliveryLoginPageBloc` |
| **Dependencies** | `repository` (required), `service` (required) |
| **Status Enum** | `initial, loading, success, error` |
| **State Fields** | `status`, `phone`, `password`, `obscurePassword`, `rememberMe`, `isPhoneValid`, `isPasswordValid`, `errorMessage`, `navigationAction`, `forgotPasswordEmail`, `forgotPasswordStatus`, `forgotPasswordMessage`, `isPhoneAutoFilled` (13 fields) |

| Event | Handler | Repo Call | State |
|-------|---------|-----------|-------|
| `InitEvent` | `_onInit` | `_repo.getSavedPhone()` (secure storage) | `copyWith(phone, isPhoneAutoFilled)` |
| `PhoneChangedEvent` | `_onPhoneChanged` | — | `copyWith(phone, isPhoneValid)` |
| `PasswordChangedEvent` | `_onPasswordChanged` | — | `copyWith(password, isPasswordValid)` |
| `TogglePasswordVisibilityEvent` | `_onTogglePassword` | — | `copyWith(obscurePassword: !)` |
| `ToggleRememberMeEvent` | `_onToggleRememberMe` | — | `copyWith(rememberMe: !)` |
| `SubmittedEvent` | `_onSubmitted` | `_repo.signInWithEmailPassword()` | loading → success / error |
| `GoogleSubmittedEvent` | `_onGoogleSubmitted` | `_repo.signInWithGoogle()` | loading → success / error |
| `AppleSubmittedEvent` | `_onAppleSubmitted` | `_repo.signInWithApple()` | loading → success / error |
| `ForgotPasswordSubmittedEvent` | `_onForgotPassword` | `_repo.sendPasswordResetEmail()` | forgotPasswordStatus: loading → success/failure |
| `NavigateToSignUpEvent` | `_onNavigateToSignUp` | — | `copyWith(navigationAction: 'signUp')` |

| UI Binding | Widget | Field |
|------------|--------|-------|
| Phone field + validation | `BlocBuilder` + `TextFormField` | `phone`, `isPhoneValid` |
| Password field + visibility | `BlocBuilder` + `TextFormField` | `password`, `obscurePassword` |
| Remember me checkbox | `BlocBuilder` + `Checkbox` | `rememberMe` |
| Loading indicator | `BlocConsumer` | `status == .loading` |
| Error dialog | `BlocListener` | `status == .error` |
| Navigation | `BlocListener` | `navigationAction` |

| Navigation | Route |
|------------|-------|
| Login success | `Navigator.pushReplacementNamed(context, '/deliveryNavigationBar')` |
| Navigate to Sign Up | `Navigator.pushNamed(context, '/deliverySignUp')` |

| Gaps |
|------|
| Duplicate route in `main.dart`: `/deliverylogin` AND `/deliveryLogin` — GAP-12 |
| `signInWithApple()` throws `UnimplementedError` — GAP-13 |
| `required` repo/service prevents testability — GAP-16 |
| `navigationAction` string-based dispatch antipattern |

---

### 3.3 Delivery_Sign_Up (`Delivery_Sign_Up_page/`)

| Field | Detail |
|-------|--------|
| **BLoC** | `DeliverySignUpPageBloc` |
| **Dependencies** | `repository` (required), `service` (required) |
| **Status Enum** | `initial, loading, otpSent, success, failure` |
| **State Fields** (16) | `status`, `name`, `phone`, `email`, `password`, `confirmPassword`, `obscurePassword`, `obscureConfirmPassword`, `termsAccepted`, `errorMessage`, `successMessage`, `isNameValid`, `isPhoneValid`, `isEmailValid`, `isPasswordValid`, `isConfirmPasswordValid`, `navigationAction`, `verificationId` |

| Event | Handler | Repo Call | State |
|-------|---------|-----------|-------|
| `InitEvent` | `_onInit` | — | `copyWith(status: .initial)` |
| `NameChanged(name)` | `_onNameChanged` | — | `copyWith(name, isNameValid)` |
| `PhoneChanged(phone)` | `_onPhoneChanged` | — | `copyWith(phone, isPhoneValid)` |
| `EmailChanged(email)` | `_onEmailChanged` | — | `copyWith(email, isEmailValid)` |
| `PasswordChanged(password)` | `_onPasswordChanged` | — | `copyWith(password, isPasswordValid)` |
| `ConfirmPasswordChanged(password)` | `_onConfirmPasswordChanged` | — | `copyWith(confirmPassword, isConfirmPasswordValid)` |
| `PasswordVisibilityToggled` | `_onTogglePassword` | — | `copyWith(obscurePassword: !)` |
| `ConfirmPasswordVisibilityToggled` | `_onToggleConfirmPassword` | — | `copyWith(obscureConfirmPassword: !)` |
| `TermsToggled` | `_onTermsToggled` | — | `copyWith(termsAccepted: !)` |
| `Submitted` | `_onSubmitted` | `_repo.sendPhoneOtp()` | `otpSent` with `verificationId` |
| `BackPressed` | `_onBackPressed` | — | `copyWith(navigationAction: 'navBack')` |
| `LoginNavigated` | `_onLoginNavigated` | — | `copyWith(navigationAction: 'navToLogin')` |

| Navigation | Route | Arguments |
|------------|-------|-----------|
| OTP Sent | `/deliveryOtpVerification` | `{verificationId, name, phone, email, password}` |
| Login link | `/deliverylogin` | — |
| Back | `pop()` | — |

| Gaps |
|------|
| Same `required` repo/service issue — GAP-16 |
| `navigationAction` string-based antipattern |

---

### 3.4 Delivery_Forgot_Password (`Delivery_Forgot_Password_page/`)

| Field | Detail |
|-------|--------|
| **BLoC** | `DeliveryForgotPasswordBloc` |
| **Dependencies** | `DeliveryPartnerRepository` (shared, not injected) |
| **Status Enum** | `initial, loading, otpSent, otpVerified, success, failure` |
| **State Fields** | `status`, `phone`, `otp`, `newPassword`, `confirmPassword`, `verificationId`, `message` |

| Event | Handler | Repo Call | State |
|-------|---------|-----------|-------|
| `PhoneChanged(phone)` | `_onPhoneChanged` | — | `copyWith(phone)` |
| `SendOtpSubmitted` | `_onSendOtpSubmitted` | `_repo.sendResetPhoneOtp(phone)` | `loading → otpSent` |
| `OtpChanged(otp)` | `_onOtpChanged` | — | `copyWith(otp)` |
| `VerifyOtpSubmitted` | `_onVerifyOtpSubmitted` | `_repo.verifyResetOtp(otp)` | `loading → otpVerified` |
| `PasswordChanged(pwd)` | `_onPasswordChanged` | — | `copyWith(newPassword)` |
| `ConfirmPasswordChanged(pwd)` | `_onConfirmPasswordChanged` | — | `copyWith(confirmPassword)` |
| `ResetPasswordSubmitted` | `_onResetPasswordSubmitted` | `_repo.resetPasswordWithOtp(...)` | `loading → success/failure` |

| Gaps |
|------|
| Phone number and password strength validation required before submission |
| BLoC creates its own `DeliveryPartnerRepository()` — not mockable |

---

### 3.5 Delivery_OTP_Verification (`Delivery_OTP_Verification_page/`)

| Field | Detail |
|-------|--------|
| **BLoC** | `DeliveryOtpVerificationBloc` |
| **Constructor Args** | `verificationId`, `name`, `phone`, `email`, `password` |
| **Timer** | `Timer.periodic(1 sec)` for 30s resend countdown |
| **Status Enum** | `initial, loading, success, failure` |
| **State Fields** (11) | `status`, `otp`, `errorMessage`, `canResend`, `resendCountdown`, `isValid` (computed), `navigationAction`, `isLoading`, ... |

| Event | Handler | Repo Call | State |
|-------|---------|-----------|-------|
| `OtpChangedEvent(otp)` | `_onOtpChanged` | — | `copyWith(otp, isValid)` |
| `VerifySubmittedEvent` | `_onVerify` | `_repo.completeOtpVerificationAndCreateAccount(...)` | `loading → success/failure` |
| `ResendRequestedEvent` | `_onResend` | `_repo.sendPhoneOtp()` | Reset timer |
| `TimerTickedEvent(duration)` | `_onTimerTick` | — | `copyWith(resendCountdown, canResend)` |

| Navigation | Route |
|------------|-------|
| Success | `Navigator.pushReplacementNamed(context, '/deliveryLogin')` |

| Gaps |
|------|
| `_repo` is `required` — BLoC creates own instance if not provided |
| After account creation user is re-directed to login instead of auto-login |
| Backspace handling in UI, not BLoC |

---

### 3.6 Delivery_NavigationBar (Central Hub, `Delivery_NavigationBar_page/`)

| Field | Detail |
|-------|--------|
| **BLoC** | `DeliveryNavigationBarPageBloc` |
| **Status Enum** | `initial, loading, loaded, error, empty, loggedOut` |
| **State Fields** | `status`, `currentTabIndex` (0-8), `navigationItems` (9 items), `isUploading`, `uploadProgress`, `isUploadBarVisible`, `errorMessage`, `selectedLocale` |

| Index | Tab Widget |
|-------|-----------|
| 0 | `DeliveryDashboardPage()` |
| 1 | `DeliveryOrdersPage()` |
| 2 | `DeliveryEarningsDashboardPage()` |
| 3 | `DeliveryIncentivesDashboardPage()` |
| 4 | **Push to `/deliveryNavigationScreen`** (not embedded) |
| 5 | `DeliveryWalletPage()` |
| 6 | `DeliveryOrderHistoryPage()` |
| 7 | `DeliverySettingsPage()` |
| 8 | `DeliveryProfilePage()` |

| Event | Handler | State |
|-------|---------|-------|
| `InitEvent` | `_onInit` | `copyWith(status: .loaded, navigationItems)` |
| `TabChangedEvent(index)` | `_onTabChanged` | `copyWith(currentTabIndex)` |
| `RefreshEvent` | `_onRefresh` | `copyWith(status: .loaded)` |
| `LogoutRequestedEvent` | `_onLogoutRequested` | `signOut → copyWith(status: .loggedOut)` |
| `LocaleChangedEvent` | `_onLocaleChanged` | `copyWith(selectedLocale)` |

| Navigation | Route |
|------------|-------|
| Logout | `Navigator.pushNamedAndRemoveUntil(context, '/deliveryonboard', (_) => false)` |

| Gaps |
|------|
| Tab 4 navigation hardcoded in UI, not via BLoC event — GAP-7 |
| Tab pages instantiated without `BlocProvider` wrapping |
| Logout uses `FirebaseAuth.instance` directly |
| No `DeliveryActiveOrderSessionRepository` injection |
| `selectedLocale` tracked but doesn't change app locale |

---

### 3.7 Delivery_Dashboard (Tab 0, `Delivery_Dashboard_page/`)

| Field | Detail |
|-------|--------|
| **BLoC** | `DeliveryDashboardPageBloc` |
| **Status Enum** | `initial, loading, loaded, error, empty` |
| **State Fields** (22) | `status`, `isOnline`, `metrics` (8 cards), `activeOrder`, `activities`, `notifications`, `earningsData`, `todaysEarnings`, `activityFilter`, `errorMessage`, ... |

| Event | Handler | Repo Call | State |
|-------|---------|-----------|-------|
| `InitEvent` | `_onInit` | `_repo.getDashboardData()` | `loaded` |
| `ToggleOnlineEvent` | `_onToggleOnline` | `_service.toggleOnlineStatus()` | `copyWith(isOnline: !)` |
| `RefreshEvent` | `_onRefresh` | `_repo.getDashboardData()` | `copyWith(status: .loaded)` |
| `FilterActivityEvent(filter)` | `_onFilterActivity` | Filter in-memory | `copyWith(activityFilter)` |
| `QuickActionExecutedEvent(actionId)` | `_onQuickAction` | — | Navigation side-effect |

| UI Binding | Widget | State Field |
|------------|--------|-------------|
| Online/Offline pulse pill | `AnimatedContainer` | `isOnline` |
| Metrics grid (8 cards) | `GridView` | `metrics` |
| Active order card | `Card` | `activeOrder` |
| Earnings sparkline | `CustomPaint` | `earningsData` |
| Activity timeline | `ListView` | `activities` |
| Quick actions grid | `GridView` | `QuickActionExecutedEvent` on tap |
| Floating online pill (mobile) | `DeliveryFloatingOnlinePill` | `isOnline` |

| Gaps |
|------|
| **Active order card has no tap handler** — GAP-3 |
| `DeliveryActiveOrderSessionRepository` not subscribed — GAP-11 |
| 22 state fields is too many |

---

### 3.8 Delivery_Orders (Tab 1, `Delivery_Orders_page/`)

| Field | Detail |
|-------|--------|
| **BLoC** | `DeliveryOrdersPageBloc` |
| **Auto-refresh** | `Timer.periodic(30s)` |
| **Status Enum** | `initial, loading, loaded, error, empty` |
| **Tab Enum** | `all, active, pending, completed` |
| **Sort Enum** | `time, distance, amountHigh` |
| **Payment Filter** | `all, cash, card, online` |
| **Sub-Model** | `DeliveryOrderCardModel` (17 fields) |

| State Fields (10) | `status`, `orders`, `currentTab`, `searchQuery`, `sortBy`, `paymentFilter`, `isAutoRefreshEnabled`, `stats` (10 values), `lastRefreshed`, `errorMessage` |
| **Computed** | `filteredOrders`, `activeOrders`, `isLoadingFirstTime`, `hasNoOrders` |

| Event | Handler | Repo Call | State |
|-------|---------|-----------|-------|
| `InitEvent` | `_onInit` | `_repo.fetchOrders()` | `loaded` |
| `TabChangedEvent(tab)` | `_onTabChanged` | — | `copyWith(currentTab)` |
| `SearchQueryChangedEvent(query)` | `_onSearch` | — | `copyWith(searchQuery)` |
| `RefreshEvent` | `_onRefresh` | `_repo.fetchOrders()` | `copyWith(status: .loaded)` |
| `SortChangedEvent(sort)` | `_onSortChanged` | Sort in-memory | `copyWith(sortBy)` |
| `AutoRefreshToggledEvent` | `_onToggleAutoRefresh` | Start/stop `Timer` | `copyWith(isAutoRefreshEnabled)` |

| Gaps |
|------|
| **Order card `onTap` has no navigation** — GAP-1 |
| `CardModel.orderId` never used for routing |
| `Timer` runs even when page not visible on `IndexedStack` |

---

### 3.9 Delivery_Order_Details (`Delivery_Order_Details_page/`)

| Field | Detail |
|-------|--------|
| **BLoC** | `DeliveryOrderDetailsPageBloc` |
| **Repo/Service** | **None** — mock data with `Future.delayed` in BLoC |
| **Status Enum** | `initial, loading, success, error` |
| **Sub-Model** | `OrderModel` (8 fields) |

| Event | Handler | Data Source | State |
|-------|---------|-------------|-------|
| `FetchOrderDetailsEvent(orderId)` | `_onFetch` | `Future.delayed(1s)` → hardcoded `OrderModel` | `loading → success` |
| `UpdateOrderStatusEvent(id, status)` | `_onUpdateStatus` | `Future.delayed(500ms)` | `copyWith(order.copyWith(status))` |
| `CallCustomerEvent(phone)` | `_onCallCustomer` | — (no `url_launcher`) | No state change |
| `CallMerchantEvent(phone)` | `_onCallMerchant` | — (no `url_launcher`) | No state change |

| Navigation | Trigger | Route |
|------------|---------|-------|
| Back | `AutoHideAppBarWrapper` | `Navigator.pop()` |

| Gaps |
|------|
| **`FetchOrderDetailsEvent` ignores `orderId`** — always returns same order — GAP-9 |
| No repository/service abstraction |
| Call buttons don't trigger phone calls |
| Navigation button is decorative |

---

### 3.10 Delivery_Order_History (Tab 6, `Delivery_Order History_page/`)

| Field | Detail |
|-------|--------|
| **BLoC** | `DeliveryOrderHistoryPageBloc` |
| **Status Enum** | `initial, loading, loaded, empty, error` |
| **Sub-Models** | `DeliveryOrderHistoryModel`, `DeliveryOrderHistoryStats` |
| **State Fields** (15) | `status`, `allOrders`, `filteredOrders`, `searchQuery`, `statusFilter`, `dateRange`, `paymentFilter`, `currentPage`, `pageSize`, `totalPages` (computed), `stats`, `isSidebarOpen`, ... |

| Event | Handler | Data | State |
|-------|---------|------|-------|
| `InitEvent` | `_onInit` | `_repo.fetchOrderHistory()` | `loaded` |
| `SearchChangedEvent` | `_onSearch` | Filter in-memory | `copyWith(searchQuery)` |
| `PageChangedEvent` | `_onPageChanged` | Paginate | `copyWith(currentPage)` |
| `RefreshEvent` | `_onRefresh` | `_repo.fetchOrderHistory()` | `copyWith(status: .loaded)` |

| Gaps |
|------|
| **Order item tap has no navigation to OrderDetails** — GAP-2 |

---

### 3.11 Delivery_Wallet (Tab 5, `Delivery_Wallet_page/`)

| Field | Detail |
|-------|--------|
| **BLoC** | `DeliveryWalletPageBloc` |
| **Status Enum** | `initial, loading, loaded, error, refreshing` |
| **Filter Enums** | `all, income, withdrawals, bonuses` ; `thisWeek, thisMonth, lastMonth, last3Months` |
| **State Fields** (16) | `status`, `walletBalance`, `pendingWithdrawal`, `transactions`, `filteredTransactions` (computed), `transactionFilter`, `selectedPeriod`, `earningsData`, `breakdownSlices`, `paymentMethods`, `bankAccount`, `settlements`, ... |

| Event | Handler | Repo Call | State |
|-------|---------|-----------|-------|
| `InitEvent` | `_onInit` | `_repo.fetchWalletData()` | `loaded` |
| `RefreshEvent` | `_onRefresh` | `_repo.fetchWalletData()` | `copyWith(status: .refreshing)` |
| `WithdrawRequestedEvent(amount)` | `_onWithdraw` | `_repo.requestWithdrawal(amount)` | Updated balance |
| `AddPaymentMethodEvent` | `_onAddPayment` | Simulated | `copyWith(paymentMethods: [...])` |

| Gaps |
|------|
| `DeliveryActiveOrderSessionRepository` not subscribed — GAP-11 |
| `withdrawRequested` doesn't call `sessionRepo.processWithdrawal()` |

---

### 3.12 Delivery_Earnings_Dashboard (Tab 2, `Delivery_Earnings Dashboard_page/`)

| Field | Detail |
|-------|--------|
| **BLoC** | `DeliveryEarningsDashboardPageBloc` |
| **Status Enum** | `initial, loading, loaded, error, refreshing` |
| **Date Range** | `today, last7Days, thisWeek, thisMonth` |
| **Tab Enum** | `overview, transactions, withdrawals` |
| **State Fields** (20) | `status`, `selectedTab`, `selectedRange`, `totalEarnings`, `todaysEarnings`, `weeklyEarnings`, `monthlyEarnings`, `earningsChartData`, `transactions`, `withdrawals`, `uploadProgress`, `walletBalance`, ... |

| Gaps |
|------|
| `DeliveryActiveOrderSessionRepository` not subscribed — GAP-11 |
| Withdraw doesn't call `sessionRepo.processWithdrawal()` |

---

### 3.13 Delivery_Incentives_Dashboard (Tab 3, `Delivery_Incentives Dashboard_page/`)

| Field | Detail |
|-------|--------|
| **BLoC** | `DeliveryIncentivesDashboardPageBloc` |
| **State Pattern** | **Polymorphic** — `abstract class State` → `Initial`, `Loading`, `Empty`, `Error`, `Loaded` |
| **Sub-Models** (5) | `BonusPoint`, `Achievement`, `DonutSlice`, `Milestone`, `RewardRecord` |

| Gaps |
|------|
| Export button not wired |
| Polymorphic state requires `if (state is Loaded)` checks — verbose |

---

### 3.14 Delivery_Profile (Tab 8, `Delivery_Profile_page/`)

| Field | Detail |
|-------|--------|
| **BLoC** | `DeliveryProfileBloc` |
| **Dependencies** | `repository` (required), `service` (required) |
| **Status Enums** | `initial, loading, loaded, error, empty` ; `idle, saving, saved, failed` ; `notUploaded, uploading, uploaded, verified` |
| **State Fields** (20) | `status`, `saveStatus`, `name`, `phone`, `email`, `photoUrl`, `vehicleType`, `vehicleNumber`, `drivingLicense`, `aadhaarNumber`, `address`, `documents` (4), `checklist`, `profileCompletion`, `errorMessage`, `isFormDirty` |

| Gaps |
|------|
| Backend save is wired but load uses mock data |
| No file size/type validation for document uploads |

---

### 3.15 Delivery_Settings (Tab 7, `Delivery_Settings_page/`)

| Field | Detail |
|-------|--------|
| **BLoC** | `DeliverySettingsBloc` |
| **Dependencies** | `repository` (required), `service` (required) |
| **Status Enums** | `initial, loading, loaded, saving, error, empty` ; `idle, saving, saved, failed` |
| **State Fields** (12) | `status`, `saveStatus`, `deliveryRadius`, `selectedLanguage`, `notificationsEnabled`, `autoAcceptEnabled`, `darkModeEnabled`, `sunModeEnabled`, `oledModeEnabled`, `estimatedDailyEarnings`, `errorMessage`, `isFormDirty` |

| Gaps |
|------|
| Theme toggles (dark/sun/OLED) are mutually exclusive — correct but not synced with `ThemeManager` |
| Language change doesn't propagate to app |

---

### 3.16 Delivery_Navigation_Screen (`Delivery_Navigation Screen_page/`)

| Field | Detail |
|-------|--------|
| **BLoC** | `DeliveryNavigationBloc` |
| **StreamSubscription** | `StreamSubscription<double>?` for mock location ticks |
| **Status Enum** | `initial, loading, loaded, navigating, empty, error` |
| **Traffic Enum** | `clear, moderate, heavy` |
| **State Fields** (17) | `status`, `currentLat`, `currentLng`, `pickupLat`, `pickupLng`, `dropLat`, `dropLng`, `routePoints`, `etaMinutes`, `distanceKm`, `trafficLevel`, `isAudioEnabled`, `isMapFullScreen`, `orderSummary`, `isSosTriggered`, `localeCode`, ... |

| Event | Handler | Repo Call | State |
|-------|---------|-----------|-------|
| `InitEvent` | `_onInit` | `_repo.fetchNavigationData()` | `loaded` |
| `StartNavigationEvent` | `_onStart` | `_service.startLocationUpdates()` (stream) | `copyWith(status: .navigating)` |
| `ExitNavigationEvent` | `_onExit` | `_service.stopLocationUpdates()` | `pop` |
| `SOSClickedEvent` | `_onSOS` | `_service.sendSOSAlert()` | `copyWith(isSosTriggered: true)` |

| Gaps |
|------|
| **"Arrived" button has no navigation to DeliveryCompleted** — GAP-6 |
| Mock location stream, no real GPS |
| SOS sends mock alert |

---

### 3.17 Delivery_Incoming_Order (`Delivery_Incoming_Order_page/`)

| Field | Detail |
|-------|--------|
| **BLoC** | **NONE** — plain `StatefulWidget` with `TickerProviderStateMixin` |
| **Timer** | `AnimationController` 15s → 0s countdown |
| **Local State** | `_remainingSeconds`, `_timerExpired` |

| Navigation | From | Route |
|------------|------|-------|
| Decline btn / auto-expire | UI | `Navigator.pop(context)` |
| Accept btn | **GAP-4** | No navigation after accept |

| Critical Gaps |
|---------------|
| **No BLoC** — GAP-8 |
| **Accept has no navigation to PickupConfirmation** — GAP-4 |
| **No call to `sessionRepo.acceptOrder()`** |
| Order details are hardcoded, not from sessionRepo |

---

### 3.18 Delivery_Pickup_Confirmation (`Delivery_Pickup Confirmation_page/`)

| Field | Detail |
|-------|--------|
| **BLoC** | `DeliveryPickupConfirmationPageBloc` |
| **Constructor** | Takes `orderId` (optional, default `'#ORD98234'`) |
| **Status Enum** | `initial, loading, success, deliveryStarted, error` |
| **Sub-Model** | `PickupConfirmationModel` (13 fields) |

| Event | Handler | Repo Call | State |
|-------|---------|-----------|-------|
| `FetchPickupConfirmationDetailsEvent(id)` | `_onFetch` | `_repo.getPickupDetails(id)` | `loading → success` |
| `StartDeliveryEvent(id)` | `_onStartDelivery` | `_repo.startDelivery(id)` | `copyWith(status: .deliveryStarted)` |

| Navigation | From | Route |
|------------|------|-------|
| "Start Delivery" | `BlocConsumer` | **GAP-5: no navigation** |

| Gaps |
|------|
| `StartDeliveryEvent` sets `deliveryStarted` but UI doesn't navigate |
| `sessionRepo.confirmPickup()` never called |
| Call/WhatsApp buttons don't use `url_launcher` |

---

### 3.19 Delivery_Delivery_Completed (`Delivery_Delivery Completed_page/`)

| Field | Detail |
|-------|--------|
| **BLoC** | `DeliveryCompletedBloc` |
| **Constructor** | Takes `orderId` (optional, default `'#ORD98234'`) |
| **Status Enum** | `initial, loading, success, completed, error, empty` |
| **Sub-Model** | `DeliveryCompletedModel` (13 fields) |
| **State Fields** (9) | `status`, `order`, `rating`, `proofOfDeliveryPath`, `uploadStatus`, `isEarningsClaimed`, `errorMessage`, `isCompleteButtonEnabled` (computed), `navigateHome` |

| Navigation | Route |
|------------|-------|
| "Return Home" | `Navigator.popUntil(context, ModalRoute.withName('/deliveryNavigationBar'))` |

| Gaps |
|------|
| `sessionRepo.completeDelivery()` never called |
| Incoming → Pickup → Nav → Complete chain broken before this point |

---

## 4. Gap Analysis – Summary

### 4.1 Missing Navigation Wiring (Critical)

| # | From | To | Current | Fix |
|---|------|----|---------|-----|
| GAP-1 | Orders card tap | OrderDetails | No `onTap` | `pushNamed('/deliveryOrderDetails', arguments: {'orderId': order.id})` |
| GAP-2 | OrderHistory item tap | OrderDetails | No `onTap` | Same |
| GAP-3 | Dashboard active order card | OrderDetails | No `onTap` | Same |
| GAP-4 | IncomingOrder Accept | PickupConfirmation | Button stops timer, no nav | `pushReplacementNamed('/deliveryPickupConfirmation', arguments: {'orderId': id})` + `sessionRepo.acceptOrder()` |
| GAP-5 | PickupConfirmation Start | NavigationScreen | `deliveryStarted` emitted but not listened | `BlocListener` → `pushReplacementNamed('/deliveryNavigationScreen')` + `sessionRepo.confirmPickup()` |
| GAP-6 | NavigationScreen Arrived | DeliveryCompleted | No button handler | `pushReplacementNamed('/deliveryCompleted', arguments: {'orderId': id})` + `sessionRepo.completeDelivery()` |
| GAP-7 | NavigationBar tab 4 | NavigationScreen | Hardcoded in UI | Add `NavigateToScreenEvent` in BLoC |

### 4.2 Missing BLoC / Wiring

| # | Issue |
|---|-------|
| GAP-8 | `DeliveryIncomingOrderPage` has no BLoC — bare `StatefulWidget` |
| GAP-9 | `DeliveryOrderDetailsPage` BLoC uses raw `Future.delayed` — no repository |
| GAP-10 | All 9 tab BLoCs not subscribed to `sessionStream` |
| GAP-11 | `DeliveryActiveOrderSessionRepository` not injected into any tab BLoC |

### 4.3 Architecture Debt

| # | Issue |
|---|-------|
| GAP-12 | Duplicate route: `/deliverylogin` AND `/deliveryLogin` |
| GAP-13 | `signInWithApple()` throws `UnimplementedError` |
| GAP-14 | `EmailSignInClickedEvent` defined but no handler in Onboarding BLoC |
| GAP-15 | No routing library — only `Map<String, WidgetBuilder>` |
| GAP-16 | Auth BLoCs use `required` repo/service — not testable |
| GAP-17 | `ThemeManager`/`LocaleManager` use `ChangeNotifier` — inconsistent |
| GAP-18 | No auth guard on post-login routes |
| GAP-19 | `selectedLocale` doesn't change app locale |
| GAP-20 | Call/WhatsApp buttons have no `url_launcher` integration |

---

## 5. Architecture Recommendations

### R1: Migrate to `go_router` (Priority: High)
Add auth guards, path parameters (`:orderId`), shell routes for NavigationBar persistence, and deep linking support.

### R2: Create `DeliveryIncomingOrderBloc` (Priority: High)
Replace `AnimationController` timer with BLoC-managed `Stream.periodic`.

### R3: Inject `DeliveryActiveOrderSessionRepository` (Priority: High)
Add to all BLoC constructors in the delivery flow and subscribe to `sessionStream` for cross-tab state sync.

### R4: Standardize Dependency Injection (Priority: Medium)
Change `required` repo/service to optional with defaults across all BLoCs.

### R5: Wire All Missing Navigation Links (Priority: Critical)
Implement GAP-1 through GAP-7 as specified above.

### R6: Remove Duplicate Route & Fix Apple Sign-In (Priority: Low)
Remove `/deliverylogin`; implement or explicitly document `signInWithApple()`.

### R7: Add Auth Guard (Priority: High)
Redirect logged-out users away from post-login routes.

### R8: Create App-Level Cubits (Priority: Medium)
Replace `ThemeManager`/`LocaleManager` `ChangeNotifier` with `Cubit` + `BlocProvider`.

---

## 6. Delivery Order State Machine

```
┌──────────────────────────────────────────────────┐
│ DeliveryActiveOrderSessionRepository             │
│ (Broadcast StreamController)                     │
│                                                  │
│ IDLE ──triggerIncomingOrder()──► INCOMING_ORDER  │
│                                     │            │
│                         ┌───────────┴─────────┐  │
│                    acceptOrder()        declineOrder()
│                         │                     │   │
│                         ▼                     ▼   │
│                 ACCEPTED_ORDER               IDLE │
│                         │                         │
│                  confirmPickup()                   │
│                         │                         │
│                         ▼                         │
│               NAVIGATING_TO_CUSTOMER              │
│                         │                         │
│                  completeDelivery()               │
│                  (+earnings, +wallet, +count)     │
│                         │                         │
│                         ▼                         │
│                DELIVERY_COMPLETED                 │
│                         │                         │
│                    resetOrder()                   │
│                         │                         │
│                         ▼                         │
│                       IDLE                        │
└──────────────────────────────────────────────────┘
```

---

> **End of Audit Report**
