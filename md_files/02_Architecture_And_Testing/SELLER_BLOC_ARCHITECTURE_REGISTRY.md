# Seller BLoC / Cubit Architectural Registry

This registry documents all 30 BLoCs, Cubits, Events, States, Repositories, and Services implemented under `lib/features/seller_bloc_architecture/` for the enterprise Food Delivery platform.

---

## 1. Architectural Overview & Design Patterns

The Seller Module adheres strictly to **Clean Architecture** with **BLoC Pattern (flutter_bloc)**:
- **Presentation Layer**: Responsive UI widgets with real-time UI/UX updates (`*_ui.dart`).
- **BLoC / Cubit Layer**: State management handling UI events, transformations, and emitting immutable states (`*_bloc.dart`, `*_event.dart`, `*_state.dart`).
- **Data & Repository Layer**: Direct Firestore stream integration (`cloud_firestore`), eliminating hardcoded fallbacks and static placeholders.
- **Unified Barrel Export**: Available at `lib/features/seller_bloc_architecture/seller_bloc_architecture.dart`.

---

## 2. Feature BLoC / Cubit Mapping Matrix

| Requested Feature BLoC | Implemented BLoC / Cubit | Directory Location | Aliased Typedef | Real-Time Sync & Responsibilities |
|---|---|---|---|---|
| **AuthBloc** | `SellerLoginPageBloc`<br>`SellerSignUpPageBloc`<br>`SellerForgotPasswordBloc`<br>`SellerOnboardPageBloc` | `seller_login_page/`<br>`seller_sign_up_page/`<br>`seller_forgot_password/`<br>`seller_onboard_page/` | - | Multi-method auth (Email, Phone/OTP, Google, Apple), onboarding wizard, seller verification. |
| **SellerProfileBloc** | `SellerProfilePageBloc` | `seller_profile_page/` | `SellerProfileBloc` | Profile stream, live open/closed & accepting orders toggle, cover/profile image updates. |
| **RestaurantBloc** | `SellerStoreDetailsBloc`<br>`BusinessHoursBloc` | `seller_store_details_page/`<br>`business_hours_page_/` | `RestaurantBloc` | Store identity, FSSAI/GST license info, weekly operational schedule and business hours. |
| **DashboardBloc** | `SellerDashboardPageBloc`<br>`SellerNavigationBarViewPageBloc` | `seller_dashboard_page/`<br>`seller_NavigationBarView_page/` | `DashboardBloc` | Real-time dashboard stream: daily revenue, active orders, low stock items, navigation state. |
| **ProductBloc** | `ProductListBloc`<br>`MenuCategoryManagementBloc` | `product_list_page_/`<br>`menu_category_management_page_/` | `ProductBloc` | Product catalogue stream, category categorization, search, availability toggle, pagination. |
| **ProductFormCubit** | `AddProductPageBloc`<br>`CarouselCubit` | `add_product_page_/`<br>`product_list_page_/` | `ProductFormBloc`<br>`ProductCarouselCubit` | Product creation/editing, variant and add-on configuration, tax/GST auto-calculation, image carousel. |
| **InventoryBloc** | `InventoryBloc`<br>`LowStockAlertBloc` | `inventory_low_stock/`<br>`add_product_page_/` | - | Real-time stock level monitoring, threshold adjustments, critical low-stock alert stream. |
| **OrderBloc** | `OrdersListBloc`<br>`NewOrderNotificationBloc` | `orders_list/`<br>`new_order_notification/` | `OrderBloc` | Real-time lifecycle pipeline (Incoming, Preparing, Ready, Out for Delivery, Completed, Cancelled). |
| **OrderDetailsBloc** | `OrdersListBloc`<br>`DisputesRefundsBloc` | `orders_list/`<br>`disputes_refunds_page_/` | - | Order item breakdown, customer/delivery address details, disputes & refund dispute resolution. |
| **CustomerBloc** | `SellerCustomerBloc` | `seller_customer_page/` | `CustomerBloc` | Real-time customer list, customer lifetime value, order frequency, direct contact action. |
| **DeliveryBloc** | `AssignDeliveryBloc`<br>`OutForDeliveryPageBloc` | `assign_delivery_page_/`<br>`out_for_delivery_page_/` | `DeliveryBloc` | Delivery partner assignment, broadcast ride requests, real-time GPS tracking. |
| **EarningsBloc** | `SellerWalletBloc`<br>`SellerPaymentPageBloc` | `seller_wallet_page/`<br>`seller_payment_page/` | `EarningsBloc` | Wallet balance stream, gross revenue, net payout computation, transaction history. |
| **PayoutBloc** | `SellerRequestPayoutBloc`<br>`SellerPayoutHistoryBloc` | `seller_request_payout_page/`<br>`seller_payout_history_page/` | `PayoutBloc` | Bank account verification, withdrawal request processing, payout status history. |
| **AnalyticsBloc** | `SellerAnalyticsBloc` | `seller_analytics_page/` | `AnalyticsBloc` | Revenue trend charts, top-selling dishes, peak order times, customer retention metrics. |
| **ReviewBloc** | `OverallRatingBloc` | `overall_rating_page/` | `ReviewBloc` | Real-time ratings breakdown, star distribution, customer feedback response stream. |
| **CouponBloc** | `PromotionsCouponsBloc` | `promotions_coupons_page_/` | `CouponBloc` | Promotional discount engine, flat/percentage discounts, coupon expiry & toggle. |
| **ChatBloc** | `ChatSupportBloc` | `chat_support_page_/` | `ChatBloc` | Real-time customer and platform support chat messaging with Firestore stream. |
| **NotificationBloc** | `SellerNotificationBloc` | `seller_notifications/` | `NotificationBloc` | In-app notification center, category filtering, unread badges, mark-as-read stream. |
| **SettingsBloc** | `SellerSettingBloc` | `seller_setting_page/` | `SettingsBloc` | Push notification toggles, sound alerts, language localization, security and profile settings. |

---

## 3. Directory & File Inventory (30 Feature Modules)

1. `seller_login_page/`: `SellerLoginPageBloc`, `SellerLoginPageEvent`, `SellerLoginPageState`, `SellerLoginPageUI`
2. `seller_sign_up_page/`: `SellerSignUpPageBloc`, `SellerSignUpPageEvent`, `SellerSignUpPageState`, `SellerSignUpPageUI`
3. `seller_forgot_password/`: `SellerForgotPasswordBloc`, `SellerForgotPasswordEvent`, `SellerForgotPasswordState`, `SellerForgotPasswordUI`
4. `seller_onboard_page/`: `SellerOnboardPageBloc`, `SellerOnboardPageEvent`, `SellerOnboardPageState`, `SellerOnboardPageUI`
5. `seller_profile_page/`: `SellerProfilePageBloc`, `SellerProfilePageEvent`, `SellerProfilePageState`, `SellerProfilePageUI`, `SellerVerificationFormPage`
6. `seller_store_details_page/`: `SellerStoreDetailsBloc`, `SellerStoreDetailsPageEvent`, `SellerStoreDetailsPageState`, `SellerStoreDetailsPageUI`
7. `business_hours_page_/`: `BusinessHoursBloc`, `BusinessHoursEvent`, `BusinessHoursState`, `BusinessHoursPageUI`
8. `seller_NavigationBarView_page/`: `SellerNavigationBarViewPageBloc`, `SellerNavigationBarViewPageEvent`, `SellerNavigationBarViewPageState`, `SellerNavigationBarViewPageUI`
9. `seller_dashboard_page/`: `SellerDashboardPageBloc`, `SellerDashboardPageEvent`, `SellerDashboardPageState`, `SellerDashboardPageUI`, `SellerDashboardRepository`
10. `seller_app_bar_page/`: `SellerAppBarPageUI`
11. `product_list_page_/`: `ProductListBloc`, `ProductListPageEvent`, `ProductListPageState`, `ProductListPageUI`, `CarouselCubit`
12. `add_product_page_/`: `AddProductPageBloc`, `AddProductPageEvent`, `AddProductPageState`, `AddProductPageUI`, `LowStockAlertBloc`, `LowStockAlertEvent`, `LowStockAlertState`, `LowStockAlertUI`
13. `menu_category_management_page_/`: `MenuCategoryManagementBloc`, `MenuCategoryManagementEvent`, `MenuCategoryManagementState`, `MenuCategoryManagementUI`
14. `inventory_low_stock/`: `InventoryBloc`, `InventoryEvent`, `InventoryState`, `InventoryLowStockPageUI`
15. `orders_list/`: `OrdersListBloc`, `OrdersListEvent`, `OrdersListState`, `OrdersListPageUI`
16. `new_order_notification/`: `NewOrderNotificationBloc`, `NewOrderNotificationEvent`, `NewOrderNotificationState`, `NewOrderNotificationUI`
17. `disputes_refunds_page_/`: `DisputesRefundsBloc`, `DisputesRefundsEvent`, `DisputesRefundsState`, `DisputesRefundsUI`
18. `assign_delivery_page_/`: `AssignDeliveryBloc`, `AssignDeliveryEvent`, `AssignDeliveryState`, `AssignDeliveryPageUI`
19. `out_for_delivery_page_/`: `OutForDeliveryPageBloc`, `OutForDeliveryPageEvent`, `OutForDeliveryPageState`, `OutForDeliveryPageUI`
20. `seller_customer_page/`: `SellerCustomerBloc`, `SellerCustomerEvent`, `SellerCustomerState`, `SellerCustomerPageUI`
21. `chat_support_page_/`: `ChatSupportBloc`, `ChatSupportEvent`, `ChatSupportState`, `ChatSupportPageUI`
22. `seller_notifications/`: `SellerNotificationBloc`, `SellerNotificationEvent`, `SellerNotificationState`, `SellerNotificationService`, `SellerNotificationStrings`, `SellerNotificationUI`, plus component widgets
23. `seller_wallet_page/`: `SellerWalletBloc`, `SellerWalletEvent`, `SellerWalletState`, `SellerWalletPageUI`
24. `seller_payment_page/`: `SellerPaymentPageBloc`, `SellerPaymentPageEvent`, `SellerPaymentPageState`, `SellerPaymentPageUI`
25. `seller_request_payout_page/`: `SellerRequestPayoutBloc`, `SellerRequestPayoutEvent`, `SellerRequestPayoutState`, `SellerRequestPayoutPageUI`
26. `seller_payout_history_page/`: `SellerPayoutHistoryBloc`, `SellerPayoutHistoryEvent`, `SellerPayoutHistoryState`, `SellerPayoutHistoryPageUI`
27. `seller_analytics_page/`: `SellerAnalyticsBloc`, `SellerAnalyticsEvent`, `SellerAnalyticsState`, `SellerAnalyticsPageUI`
28. `overall_rating_page/`: `OverallRatingBloc`, `OverallRatingEvent`, `OverallRatingState`, `OverallRatingPageUI`
29. `promotions_coupons_page_/`: `PromotionsCouponsBloc`, `PromotionsCouponsEvent`, `PromotionsCouponsState`, `PromotionsCouponsPageUI`
30. `seller_setting_page/`: `SellerSettingBloc`, `SellerSettingEvent`, `SellerSettingState`, `SellerSettingPageUI`

---

## 4. Usage Example

To access any Seller BLoC, Cubit, or typed alias:

```dart
import 'package:food_delivery_app/features/seller_bloc_architecture/seller_bloc_architecture.dart';

// Access using standard alias:
BlocProvider<ProductBloc>(
  create: (context) => ProductBloc()..add(LoadProductList()),
  child: const ProductListPageUI(),
);

// Access using original naming:
BlocProvider<ProductListBloc>(
  create: (context) => ProductListBloc()..add(LoadProductList()),
  child: const ProductListPageUI(),
);
```
