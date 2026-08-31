/// ---------------------------------------------------------------------------
/// Seller BLoC / Cubit Architecture - Unified Barrel Export & Facade Index
/// ---------------------------------------------------------------------------
/// This barrel file exports all 30 BLoCs, Cubits, Events, States, Repositories,
/// and Services in `lib/features/seller_bloc_architecture/`.
///
/// It also provides canonical type aliases conforming to standard feature-based
/// naming conventions while preserving full backward compatibility with the
/// existing Clean Architecture implementation.
/// ---------------------------------------------------------------------------

library seller_bloc_architecture;

// ============================================================================
// 1. Authentication & Onboarding
// ============================================================================
export 'seller_login_page/seller_login_page_bloc.dart';
export 'seller_login_page/seller_login_page_event.dart';
export 'seller_login_page/seller_login_page_state.dart';
export 'seller_login_page/seller_login_page_ui.dart';

export 'seller_sign_up_page/seller_sign_up_page_bloc.dart';
export 'seller_sign_up_page/seller_sign_up_page_event.dart';
export 'seller_sign_up_page/seller_sign_up_page_state.dart';
export 'seller_sign_up_page/seller_sign_up_page_ui.dart';

export 'seller_forgot_password/seller_forgot_password_bloc.dart';
export 'seller_forgot_password/seller_forgot_password_event.dart';
export 'seller_forgot_password/seller_forgot_password_state.dart';
export 'seller_forgot_password/seller_forgot_password_ui.dart';

export 'seller_onboard_page/seller_onboard_page_bloc.dart';
export 'seller_onboard_page/seller_onboard_page_event.dart';
export 'seller_onboard_page/seller_onboard_page_state.dart';
export 'seller_onboard_page/seller_onboard_page_ui.dart';

// ============================================================================
// 2. Seller & Restaurant Profile Management
// ============================================================================
export 'seller_profile_page/seller_profile_page__bloc.dart';
export 'seller_profile_page/seller_profile_page__event.dart';
export 'seller_profile_page/seller_profile_page__state.dart';
export 'seller_profile_page/seller_profile_page__ui.dart';
export 'seller_profile_page/seller_verification_form_page.dart';

export 'seller_store_details_page/seller_store_details_page__bloc.dart';
export 'seller_store_details_page/seller_store_details_page__event.dart';
export 'seller_store_details_page/seller_store_details_page__state.dart';
export 'seller_store_details_page/seller_store_details_page__ui.dart';

export 'business_hours_page_/business_hours_page_bloc.dart';
export 'business_hours_page_/business_hours_page_event.dart';
export 'business_hours_page_/business_hours_page_state.dart';
export 'business_hours_page_/business_hours_page_ui.dart';

// ============================================================================
// 3. Navigation & Dashboard
// ============================================================================
export 'seller_NavigationBarView_page/seller_NavigationBarView_page_bloc.dart';
export 'seller_NavigationBarView_page/seller_NavigationBarView_page_event.dart';
export 'seller_NavigationBarView_page/seller_NavigationBarView_page_state.dart';
export 'seller_NavigationBarView_page/seller_NavigationBarView_page_ui.dart';

export 'seller_dashboard_page/seller_dashboard_page_bloc.dart';
export 'seller_dashboard_page/seller_dashboard_page_event.dart';
export 'seller_dashboard_page/seller_dashboard_page_state.dart';
export 'seller_dashboard_page/seller_dashboard_page_ui.dart';
export 'seller_dashboard_page/seller_dashboard_repository.dart';

export 'seller_app_bar_page/seller_app_bar_page_ui.dart';

// ============================================================================
// 4. Products, Menu & Inventory
// ============================================================================
export 'product_list_page_/product_list_page__bloc.dart';
export 'product_list_page_/product_list_page__event.dart';
export 'product_list_page_/product_list_page__state.dart';
export 'product_list_page_/product_list_page__ui.dart';
export 'product_list_page_/product_image_carousel.dart';

export 'add_product_page_/add_product_page__bloc.dart';
export 'add_product_page_/add_product_page__event.dart';
export 'add_product_page_/add_product_page__state.dart';
export 'add_product_page_/add_product_page__ui.dart';

export 'menu_category_management_page_/menu_category_management_page_bloc.dart';
export 'menu_category_management_page_/menu_category_management_page_event.dart';
export 'menu_category_management_page_/menu_category_management_page_state.dart';
export 'menu_category_management_page_/menu_category_management_page_ui.dart';

export 'inventory_low_stock/inventory_low_stock_page_bloc.dart';
export 'inventory_low_stock/inventory_low_stock_page_event.dart';
export 'inventory_low_stock/inventory_low_stock_page_state.dart';
export 'inventory_low_stock/inventory_low_stock_page_ui.dart';

// ============================================================================
// 5. Orders & Notifications
// ============================================================================
export 'orders_list/orders_list_page_bloc.dart';
export 'orders_list/orders_list_page_event.dart';
export 'orders_list/orders_list_page_state.dart';
export 'orders_list/orders_list_page_ui.dart';

export 'new_order_notification/new_order_notification_bloc.dart';
export 'new_order_notification/new_order_notification_event.dart' hide RejectOrderEvent;
export 'new_order_notification/new_order_notification_state.dart';
export 'new_order_notification/new_order_notification_ui.dart';

export 'disputes_refunds_page_/disputes_refunds_page_bloc.dart';
export 'disputes_refunds_page_/disputes_refunds_page_event.dart';
export 'disputes_refunds_page_/disputes_refunds_page_state.dart';
export 'disputes_refunds_page_/disputes_refunds_page_ui.dart';

// ============================================================================
// 6. Delivery Management
// ============================================================================
export 'assign_delivery_page_/assign_delivery_page__bloc.dart';
export 'assign_delivery_page_/assign_delivery_page__event.dart';
export 'assign_delivery_page_/assign_delivery_page__state.dart';
export 'assign_delivery_page_/assign_delivery_page__ui.dart';

export 'out_for_delivery_page_/out_for_delivery_page__bloc.dart';
export 'out_for_delivery_page_/out_for_delivery_page__event.dart';
export 'out_for_delivery_page_/out_for_delivery_page__state.dart';
export 'out_for_delivery_page_/out_for_delivery_page__ui.dart';

// ============================================================================
// 7. Customers, Support & Communication
// ============================================================================
export 'seller_customer_page/seller_customer_page__bloc.dart';
export 'seller_customer_page/seller_customer_page__event.dart';
export 'seller_customer_page/seller_customer_page__state.dart';
export 'seller_customer_page/seller_customer_page__ui.dart';

export 'chat_support_page_/chat_support_page_bloc.dart';
export 'chat_support_page_/chat_support_page_event.dart';
export 'chat_support_page_/chat_support_page_state.dart';
export 'chat_support_page_/chat_support_page_ui.dart';

export 'seller_notifications/seller_notification_bloc.dart';
export 'seller_notifications/seller_notification_event.dart';
export 'seller_notifications/seller_notification_state.dart';
export 'seller_notifications/seller_notification_service.dart';
export 'seller_notifications/seller_notification_strings.dart';
export 'seller_notifications/seller_notification_ui.dart';

// ============================================================================
// 8. Finance, Payments & Payouts
// ============================================================================
export 'seller_wallet_page/seller_wallet_page__bloc.dart';
export 'seller_wallet_page/seller_wallet_page__event.dart';
export 'seller_wallet_page/seller_wallet_page__state.dart';
export 'seller_wallet_page/seller_wallet_page__ui.dart';

export 'seller_payment_page/seller_payment_page_bloc.dart';
export 'seller_payment_page/seller_payment_page_event.dart';
export 'seller_payment_page/seller_payment_page_state.dart';
export 'seller_payment_page/seller_payment_page_ui.dart';

export 'seller_request_payout_page/seller_request_payout_page__bloc.dart';
export 'seller_request_payout_page/seller_request_payout_page__event.dart';
export 'seller_request_payout_page/seller_request_payout_page__state.dart';
export 'seller_request_payout_page/seller_request_payout_page__ui.dart';

export 'seller_payout_history_page/seller_payout_history_page__bloc.dart';
export 'seller_payout_history_page/seller_payout_history_page__event.dart' hide LoadMorePayoutHistory;
export 'seller_payout_history_page/seller_payout_history_page__state.dart';
export 'seller_payout_history_page/seller_payout_history_page__ui.dart';

// ============================================================================
// 9. Analytics, Ratings, Promotions & Settings
// ============================================================================
export 'seller_analytics_page/seller_analytics_page__bloc.dart';
export 'seller_analytics_page/seller_analytics_page__event.dart';
export 'seller_analytics_page/seller_analytics_page__state.dart';
export 'seller_analytics_page/seller_analytics_page__ui.dart';

export 'overall_rating_page/overall_rating_page__bloc.dart';
export 'overall_rating_page/overall_rating_page__event.dart';
export 'overall_rating_page/overall_rating_page__state.dart';
export 'overall_rating_page/overall_rating_page__ui.dart';

export 'promotions_coupons_page_/promotions_coupons_page_bloc.dart';
export 'promotions_coupons_page_/promotions_coupons_page_event.dart';
export 'promotions_coupons_page_/promotions_coupons_page_state.dart';
export 'promotions_coupons_page_/promotions_coupons_page_ui.dart';

export 'seller_setting_page/seller_setting_page__bloc.dart';
export 'seller_setting_page/seller_setting_page__event.dart' hide UpdateBusinessHoursSchedule, ToggleAcceptingOrders, LogoutRequested;
export 'seller_setting_page/seller_setting_page__state.dart';
export 'seller_setting_page/seller_setting_page__ui.dart';

// ============================================================================
// 10. UI Tokens, Unified Dialogs & Backend Data Models
// ============================================================================
export 'seller_ui_tokens.dart';
export 'seller_unified_dialog.dart';

export '../../core/models/seller_pos_printer_model.dart';
export '../../core/models/seller_delivery_surge_model.dart';
export '../../core/models/seller_staff_model.dart';
export '../../core/models/seller_ledger_model.dart';
export '../../core/models/seller_performance_model.dart';
export '../../app_data_collection/seller_collections/seller_collection.dart';

// ============================================================================
// Canonical Type Aliases for Standard Feature BLoC / Cubit Conventions
// ============================================================================
import 'add_product_page_/add_product_page__bloc.dart';
import 'assign_delivery_page_/assign_delivery_page__bloc.dart';
import 'chat_support_page_/chat_support_page_bloc.dart';
import 'orders_list/orders_list_page_bloc.dart';
import 'overall_rating_page/overall_rating_page__bloc.dart';
import 'product_list_page_/product_image_carousel.dart';
import 'product_list_page_/product_list_page__bloc.dart';
import 'promotions_coupons_page_/promotions_coupons_page_bloc.dart';
import 'seller_analytics_page/seller_analytics_page__bloc.dart';
import 'seller_customer_page/seller_customer_page__bloc.dart';
import 'seller_dashboard_page/seller_dashboard_page_bloc.dart';
import 'seller_notifications/seller_notification_bloc.dart';
import 'seller_profile_page/seller_profile_page__bloc.dart';
import 'seller_request_payout_page/seller_request_payout_page__bloc.dart';
import 'seller_setting_page/seller_setting_page__bloc.dart';
import 'seller_store_details_page/seller_store_details_page__bloc.dart';
import 'seller_wallet_page/seller_wallet_page__bloc.dart';

typedef ProductBloc = ProductListBloc;
typedef ReviewBloc = OverallRatingBloc;
typedef CouponBloc = PromotionsCouponsBloc;
typedef ChatBloc = ChatSupportBloc;
typedef NotificationBloc = SellerNotificationBloc;
typedef SettingsBloc = SellerSettingBloc;
typedef CustomerBloc = SellerCustomerBloc;
typedef AnalyticsBloc = SellerAnalyticsBloc;
typedef DeliveryBloc = AssignDeliveryBloc;
typedef EarningsBloc = SellerWalletBloc;
typedef PayoutBloc = SellerRequestPayoutBloc;
typedef RestaurantBloc = SellerStoreDetailsBloc;
typedef SellerProfileBloc = SellerProfilePageBloc;
typedef DashboardBloc = SellerDashboardPageBloc;
typedef OrderBloc = OrdersListBloc;
typedef ProductFormBloc = AddProductPageBloc;
typedef ProductCarouselCubit = CarouselCubit;
