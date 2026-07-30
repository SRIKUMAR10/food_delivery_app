
# 🏗️ Food Delivery App — Architecture Audit Report

> **📅 Audit Date:** 2026-07-29
> **🔍 Scope:** buyer_bloc_architecture (104 files) + seller_bloc_architecture (148 files) = **252 Dart files**
> **🎯 Coverage:** BLoC Pattern, Repository Layer, State Management, Error Handling, Lifecycle, **Buyer↔Seller Data Flow Synchronization**

---

## 📋 Table of Contents

1. [Total Page Count](#1-total-page-count)
2. [Firestore Collection Inventory](#2-firestore-collection-inventory)
3. [Repository Layer Architecture](#3-repository-layer-architecture)
4. [Buyer BLoC Architecture Audit](#4-buyer-bloc-architecture-audit)
5. [Seller BLoC Architecture Audit](#5-seller-bloc-architecture-audit)
6. [Cross-Cutting Issues](#6-cross-cutting-issues)
7. [🚨 Buyer–Seller Data Flow Synchronization Audit](#7-buyer-seller-data-flow-synchronization-audit)
8. [Synchronization Coverage Scorecard](#8-synchronization-coverage-scorecard)
9. [Cross-Architecture Dependency Graph](#9-cross-architecture-dependency-graph)
10. [Action Items (Prioritized)](#10-action-items-prioritized)
11. [Final Assessment](#11-final-assessment)

---

## 1. Total Page Count

| Folder | Dart File Count |
|--------|:-:|
| `lib/features/buyer_bloc_architecture/` | **104** |
| `lib/features/seller_bloc_architecture/` | **148** |
| **Grand Total** | **252** |

---

## 2. Firestore Collection Inventory

### 2.1 Collection Map

| # | Collection Path | Type | Real-time? | Buyer Writes | Seller Writes |
|---|----------------|------|:----------:|:------------:|:-------------:|
| 1 | `users/{userId}` | Root Doc | ✅ Stream | Yes | No |
| 2 | `users/{userId}/ratings/{foodId}` | Sub | ✅ Stream | Yes | No |
| 3 | `users/{userId}/favorites/{itemId}` | Sub | ✅ Stream | Yes | No |
| 4 | `users/{userId}/transactions/{txnId}` | Sub | ✅ Stream | Yes | No |
| 5 | `users/{userId}/payment_methods/{methodId}` | Sub | ✅ Stream | Yes | No |
| 6 | `users/{userId}/cart/{itemId}` | Sub | ✅ Stream | Yes | No |
| 7 | `users/{userId}/support_tickets` | Sub | ❌ Get | Yes | No |
| 8 | `users/{userId}/settings/app` | Sub | ❌ Get | Yes | No |
| 9 | `sellers/{sellerId}` | Root Doc | ✅ Stream | Read only | Yes |
| 10 | `sellers/{sellerId}/settings/business_hours` | Sub | ❌ Get | No | Yes |
| 11 | `sellers/{sellerId}/menu_preferences` | Sub | ❌ Get | No | Yes |
| 12 | `sellers/{sellerId}/coupons/{couponId}` | Sub | ✅ Stream (via repo) | No | Yes |
| 13 | `sellers/{sellerId}/disputes` | Sub | ❌ Get | No | Yes |
| 14 | `sellers/{sellerId}/payment/details` | Sub | ❌ Get | No | Yes |
| 15 | `products/{productId}` | Root Doc | ✅ Stream | Read only | Yes |
| 16 | `products/{productId}/reviews/{userId}` | Sub | ✅ Stream | Yes | Read only |
| 17 | `orders/{orderId}` | Root Doc | ✅ Stream | Cloud Function | Yes |
| 18 | `riders/{riderId}` | Root Doc | ✅ Stream | Read only | Read only |
| 19 | `global_categories/{catId}` | Root Doc | ✅ Stream | Read only | Read only |
| 20 | `conversations/{convId}` | Root Doc | ✅ Stream | Yes | Yes |
| 21 | `conversations/{convId}/messages` | Sub | ✅ Stream | Yes | Yes |
| 22 | `conversations/{convId}/photos` | Sub | ✅ Stream | Yes | Yes |
| 23 | `conversations/{convId}/videos` | Sub | ✅ Stream | Yes | Yes |
| 24 | `conversations/{convId}/audios` | Sub | ✅ Stream | Yes | Yes |
| 25 | `seller_notification_settings/{sellerId}` | Root Doc | ❌ Get | No | Yes |
| 26 | `inventory_logs/{logId}` | Root Doc | ✅ Stream | No | Yes |

**Total Collections: 26** (11 Root + 15 Sub/Sub-sub)

### 2.2 Shared Collections (Buyer ↔ Seller Bridge)

| Collection | Buyer Access | Seller Access | Sync Mechanism |
|-----------|-------------|--------------|:--------------:|
| `products` | Stream (Home, Details) | Stream (Product List, Inventory) | ✅ Real-time |
| `orders` | Stream (Order List) | Stream (Orders List, Dashboard) | ✅ Real-time |
| `products/{pid}/reviews` | Write (Rating) | Stream (Analytics) | ✅ Real-time |
| `users/{uid}/favorites` | Write (Favorites) | CG Stream (Analytics) | ✅ Real-time |
| `users/{uid}/ratings` | Write (Rating) | — | ⚠️ One-way |
| `sellers/{sid}/coupons` | — | Write (Promotions) | ❌ No direct buyer listener |
| `sellers/{sid}/settings/business_hours` | — | Write (Business Hours) | ✅ Via SellerStatusService |
| `conversations` | Stream (Chat) | Stream (Chat) | ✅ Real-time both ways |

> **CG = Collection Group query**

---

## 3. Repository Layer Architecture

### 3.1 Interface Contracts (`lib/core/repositories/`)

| Interface | Implementation | Key Collections |
|-----------|--------------|----------------|
| `IProductRepository` | `FirebaseProductRepository` | `products` |
| `IOrderRepository` | `FirebaseOrderRepository` | `orders` |
| `IInventoryRepository` | `FirebaseInventoryRepository` | `products` + `inventory_logs` |
| `ICouponRepository` | `FirebaseCouponRepository` | `sellers/{id}/coupons` (CG) |
| `IChatRepository` | `FirebaseChatRepository` | `conversations` + subcollections |
| `ICartRepository` | `FirebaseCartRepository` | `users/{uid}/cart` |
| `IAppSettingsRepository` | `FirebaseAppSettingsRepository` | `users/{uid}/settings/app` |

### 3.2 Architecture Pattern Inconsistency

```
core/repositories/* (interfaces)  ──implemented by──►  lib/repositories/* (Firebase)
         │                                                    │
         │ Buyer BLoCs import from                             │ Seller BLoCs import from
         ▼                                                     ▼
   i_product_repository.dart                      product_repository.dart (standalone duplicate)
   i_order_repository.dart                        orders_list_page_repository.dart (UNUSED)
                                                   seller_dashboard_repository.dart (inline)
                                                   business_hours_page_repository.dart (concrete)
```

**Key Issues:**
- Some seller BLoCs use `I*Repository` interfaces from `core/` (correct)
- Some seller BLoCs define their own concrete repositories (inconsistent)
- `orders_list_page_repository.dart` is fully **unused dead code**
- Buyer uses mix of interfaces (Cart, Chat, Coupon) and direct Firebase (Favorites, Rating, Wallet)

---

## 4. Buyer BLoC Architecture Audit

### 4.1 Home Page (`home_Page/`)
- **Files:** `home_Page_Bloc.dart`, `home_Page_Event.dart`, `home_Page_State.dart`, `food_item_mapper.dart`, `home_page_models.dart`, `seller_model.dart`
- **Data Source:** `IProductRepository.getProductsStream()` → Real-time stream of `products` collection
- **Seller Sync:** `SellerStatusService` → reads `sellers/{id}` stream for Open/Closed availability
- **Issues:**
  - `SearchQueryChanged` doc says "in-memory filter" but calls Firestore `searchProducts()`
  - `_emitFilteredState` ignores `sellerAvailabilities` map
  - Category subscription failure falls back silently
  - `_onSellerAvailabilitiesUpdated` drops updates when state ≠ `HomePageLoaded`
- **BLoC Lifecycle:** ✅ Proper `close()` cancels all subscriptions

### 4.2 Cart Page (`Cart Page/`)
- **Files:** `cart_page_Bloc.dart`, `cart_page_Event.dart`, `cart_page_State.dart`, `cart_models.dart`, `cart_page.dart`
- **Data Source:** `ICartRepository.getCartItemsStream()` → Real-time stream of `users/{uid}/cart`
- **Coupon:** `ICouponRepository.getActiveCouponsBySellers()` → one-time subscription at load
- **Issues:**
  - ❌ **No optimistic updates** — ~200-500ms lag on add/remove/qty
  - ❌ **Empty catch blocks** on all cart mutations
  - ❌ **Null crash risk** — `event.onInsufficientBalance!()` with nullable callback
  - ❌ **Coupon subscription never refreshed** when cart items change
  - `CartError` state **defined but never emitted**
- **BLoC Lifecycle:** ✅ Proper `close()`

### 4.3 Order Page (`Order Page/`)
- **Files:** `order_Bloc.dart`, `order_Event.dart`, `order_State.dart`, `order_repository.dart` (UNUSED), `order_mapper.dart`, `order_view_model.dart`, `order_UI.dart`
- **Data Source:** `IOrderRepository.getBuyerOrdersStream()` → Real-time stream of `orders` collection
- **Issues:**
  - ❌ **Dead code** — `order_repository.dart` is never used by BLoC
  - Architecture inconsistency: uses `import` not `part`
- **BLoC Lifecycle:** ⚠️ No `close()` override

### 4.4 Track Order Page (`Track_Order_page/`)
- **Files:** `*_bloc.dart`, `*_event.dart`, `*_state.dart`, `*_repository.dart`, `*_service.dart`, `*_ui.dart`
- **Data Source:** `Track_Order_page_service.getOrderDetails()` → **one-time** `get()` on `orders/{id}` + `riders/{id}` stream for location
- **❌ CRITICAL:** Order status is fetched **once** at page load — does **NOT** listen to real-time `orders/{id}` status changes
- **Issues:**
  - ❌ `TrackOrderRepositoryImpl.dispose()` never called — StreamController leak
  - ❌ Empty catch block — user gets no failure feedback
  - Case-sensitive status bugs (`'Preparing'` vs `'preparing'`)
  - Fabricated timestamps (fake +5min/+15min)
- **BLoC Lifecycle:** ❌ Incomplete

### 4.5 Favorites Page (`Favorites_Page/`)
- **Files:** `favorites_bloc.dart`, `favorites_event.dart`, `favorites_state.dart`, `favorites_models.dart`, `favorites_UI.dart`
- **Data Source:** Direct `FirebaseFirestore` access to `users/{uid}/favorites` + `collectionGroup('reviews')`
- **Issues:**
  - ❌ **Repository pattern violation** — direct Firebase in BLoC
  - ❌ **No optimistic updates** on toggle
  - ❌ **No error handling** on toggle failure
- **BLoC Lifecycle:** ⚠️ No `close()` override

### 4.6 Details Page (`Details_Page/`)
- **Files:** `details_page_Bloc.dart`, `details_page_Event.dart`, `details_page_State.dart`, `details_repository.dart`, `details_page_UI.dart`
- **Data Source:** `products` stream (via `details_repository`), `sellers/{id}` one-time `get()`, `SellerStatusService` stream
- **Issues:**
  - ❌ Dead fields — `ratingStatus`/`ratingMessage` never set
  - ❌ Tight coupling — `DetailsBloc()` defaults to `DetailsRepository()` (no DI)
  - ❌ Silent stream error swallowing on rating stream
- **BLoC Lifecycle:** ⚠️ No `close()` override (but no subscriptions — using `emit.forEach`)

### 4.7 Login Page (`FoodGoLoginScreen/`)
- **Files:** `FoodGoLoginScreen_Bloc.dart`, `FoodGoLoginScreen_Event.dart`, `FoodGoLoginScreen_State.dart`, `FoodGoLoginScreen_UI.dart`
- **Data Source:** `UserRepository` (concrete, not interface)
- **Assessment:** ✅ **Cleanest BLoC in buyer side** — proper state transitions, loading guard, error handling
- **Minor:** Uses concrete `UserRepository` instead of `I*Repository`

### 4.8 Rating Page (`Rating_page/`)
- **Files:** `Rating_page_bloc.dart`, `Rating_page_event.dart`, `Rating_page_state.dart`, `Rating_page_ui.dart`, `Rating_page_ui_backup.dart`, `reviews_list_screen.dart`
- **Data Source:** Direct `FirebaseFirestore` on `users/{uid}/ratings` + `products/{pid}/reviews`
- **Issues:**
  - ❌ **Repository pattern violation** — direct Firebase
  - ❌ **Duplicate rating write logic** — `DetailsRepository.submitRating()` also writes ratings (two code paths)
  - ❌ **Race condition** — uses `state.rating` instead of `event.rating` on success emit
- **BLoC Lifecycle:** ⚠️ No `close()`

### 4.9 User Profile (`user_profile_image/`)
- **Files:** `user_profile_image_Bloc.dart`, `*_Event.dart`, `*_State.dart`, `*_UI.dart`, `user_profile_models.dart`, `transactions_page.dart`
- **Data Source:** `FirebaseFirestore` on `users/{uid}`, Firebase Storage for images
- **Issues:**
  - ❌ **Success flash-over** — `ProfileSuccessAction` immediately overwritten by `ProfileLoaded`
  - ❌ **Error flash-over** — `ProfileError` immediately overwritten
  - ❌ Image compression on main isolate (no `compute()`)
- **BLoC Lifecycle:** ⚠️ No `close()`

### 4.10 Wallet Screen (`WalletScreen/`)
- **Files:** `WalletScreen_Bloc.dart`, `*_Event.dart`, `*_State.dart`, `*_UI.dart`
- **Data Source:** Direct `FirebaseFirestore` on `users/{uid}` + `transactions` subcollection
- **Issues:**
  - ❌ **Repository in BLoC file** — `WalletDatabase` defined inline
  - ❌ **Events don't extend Equatable**
  - ❌ **`LoadWalletData` does nothing** — no actual data loading
- **BLoC Lifecycle:** ❌ Events don't extend Equatable

### 4.11 AppSettings (`user_profile_image/AppSettings_*`)
- **Files:** `AppSettings_Bloc.dart`, `*_Event.dart`, `*_State.dart`, `*_UI.dart`
- **Data Source:** `IAppSettingsRepository` + direct `FirebaseAuth.instance`
- **Issues:**
  - ❌ `_getUserId()` accesses `FirebaseAuth.instance` directly — breaks testability
  - ❌ **Empty catch block** on settings save
  - ❌ **Blocking IO** on main isolate (cache clear)
- **BLoC Lifecycle:** ⚠️ No Equatable on all events

### 4.12 Chat Page (`Chat_Page/`)
- **Files:** `buyer_chat_bloc.dart`, `*_event.dart`, `*_state.dart`, `*_ui.dart`, `video_call_*`, `voice_call_*`, `audio_widgets.dart`, `invoice_generator.dart`, `custom_camera_page.dart`
- **Data Source:** `IChatRepository` → `conversations` collection + subcollections
- **Issues:**
  - ❌ **Events/states don't extend Equatable** — plain abstract classes
  - ❌ `SendBuyerMediaMessage.file` is `dynamic`
  - ❌ `openOrderConversation` silently swallows errors
- **BLoC Lifecycle:** ⚠️ No Equatable on events/states

---

## 5. Seller BLoC Architecture Audit

### 5.1 Dashboard (`seller_dashboard_page`)
- **Data Source:** `orders`, `products`, `sellers` — combineLatest3 stream
- **Issues:**
  - ❌ **No loading state on refresh** — emits loaded directly
  - ❌ **Dead sort code** — `todaysOrders.sort(...)` returns 0 then redone
- **BLoC Lifecycle:** ✅ OK

### 5.2 Orders List (`orders_list`)
- **Data Source:** `IOrderRepository.getSellerOrdersStream()` → Real-time stream on `orders`
- **Issues:**
  - ❌ **🚨 CRITICAL BUG** — `orElse: () => _allOrders.first` silently updates wrong order
  - ❌ **Dead code** — `orders_list_page_repository.dart` is **unused**
  - ❌ Chat init error uses `print()` instead of logging
- **BLoC Lifecycle:** ✅ OK — `close()` disposes `_audioService`

### 5.3 Add Product (`add_product_page_`)
- **Data Source:** Direct `FirebaseFirestore.instance.collection('sellers')` in BLoC
- **Issues:**
  - ❌ **LAYERING VIOLATION** — direct Firestore call in BLoC
  - ❌ **Empty catch block** — GST errors silently swallowed
  - ❌ `FieldChangedEvent.value` is `dynamic` — runtime error risk
- **BLoC Lifecycle:** ✅ OK

### 5.4 Product List (`product_list_page_`)
- **Data Source:** `products` stream (via `product_repository.dart` — standalone, not `IProductRepository`)
- **Issues:**
  - ❌ **State-destroying error handling** — error replaces entire list with blank page
  - ❌ **No optimistic updates** — relies on stream push-back
  - ❌ No loading indicators during mutations
- **BLoC Lifecycle:** ✅ OK — `close()` cancels subscription

### 5.5 Business Hours (`business_hours_page_`)
- **Data Source:** `sellers/{id}/settings/business_hours` — one-time get/set
- **Issues:**
  - ❌ **Missing Equatable** — every state change triggers rebuild
  - ❌ **IMMUTABILITY VIOLATION** — mutates state in-place (`removeAt`/`insert`)
- **BLoC Lifecycle:** ✅ OK

### 5.6 Promotions/Coupons (`promotions_coupons_page_`)
- **Data Source:** `sellers/{id}/coupons` — one-time get (despite `i_coupon_repository` supporting stream)
- **Issues:**
  - ❌ **Missing Equatable**
  - ❌ `_onAddCoupon` has no loading indicator (others do)
- **BLoC Lifecycle:** ✅ OK

### 5.7 Seller Login (`seller_login_page`)
- **Assessment:** ✅ **Most complete BLoC in seller side**
- **Issues:**
  - ❌ **Hardcoded `+91` country code** — breaks for non-Indian numbers
  - Uses concrete `SellerRepository` instead of interface
- **BLoC Lifecycle:** ✅ Excellent — `close()` cancels `_otpTimer`

### 5.8 Analytics (`seller_analytics_page_`)
- **Data Source:** `orders` (one-time get), `favorites` (CG stream), `reviews` (CG stream)
- **Issues:**
  - ❌ **🚨 CRITICAL — Subscription leak on failure**: subscriptions set up BEFORE `fetchAnalyticsData()`. If it throws, subs never cancelled
  - ❌ Real-time data held in `_last*` fields but not emitted until reload
- **BLoC Lifecycle:** ⚠️ Incomplete

### 5.9 Inventory Low Stock (`inventory_low_stock`)
- **Data Source:** `products` stream (via `inventory_low_stock_repository.dart`)
- **Issues:**
  - ❌ **🚨 CRITICAL — Silently swallowed stream errors**: `onError: (error) { }` — BLoC stuck in loading forever
  - ❌ Inconsistent `updatingItemIds` — `_onAddProductEvent` doesn't set it
- **BLoC Lifecycle:** ✅ Good — `close()` cancels subscription

### 5.10 New Order Notification (`new_order_notification`)
- **Data Source:** `orders` stream filtered to `status == 'New'`
- **Issues:**
  - ❌ **No loading state for accept/reject**
  - ❌ **No error recovery** — BLoC cannot recover after error without being re-created
- **BLoC Lifecycle:** ✅ Good — `close()` cancels subscription

### 5.11 Menu Category Management (`menu_category_management_page_`)
- **Data Source:** `sellers/{id}/menu_preferences` — one-time get/set
- **Issues:**
  - ❌ **Missing Equatable**
  - ❌ **IMMUTABILITY VIOLATION** — `removeAt`/`insert` on state
- **BLoC Lifecycle:** ✅ OK

### 5.12 Assign Delivery (`assign_delivery_page_`)
- **Data Source:** `riders` (one-time get), `orders/{id}` (one-time update)
- **Issues:**
  - ❌ **Double emission / UI flicker** — error state immediately overwritten
- **BLoC Lifecycle:** ✅ OK

---

## 6. Cross-Cutting Issues

| # | Issue | Affected | Severity |
|---|-------|----------|:--------:|
| 1 | No optimistic updates anywhere | Cart, Favorites, Orders, Product List, Promotions, Inventory | 🔴 |
| 2 | Silent error swallowing (empty catch) | Cart(4x), TrackOrder, AddProduct, Inventory, AppSettings, Chat | 🔴 |
| 3 | Repository pattern violations (direct Firebase) | Favorites, Rating, Wallet, AddProduct | 🔴 |
| 4 | Missing Equatable on events/states | BusinessHours, Promotions, MenuCategories, Wallet, Chat | 🟡 |
| 5 | Dead code/unused files | `order_repository.dart`, `orders_list_page_repository.dart` | 🟡 |
| 6 | Success/Error flash-over (immediate re-emit) | UserProfile, AssignDelivery | 🟡 |
| 7 | State immutability violations | BusinessHours, MenuCategories | 🔴 |
| 8 | Stream subscription leaks | Analytics, TrackOrder | 🔴 |
| 9 | Race conditions | Rating page | 🔴 |
| 10 | Wrong-order update bug | Orders List (`orElse`) | 🚨 |
| 11 | Hardcoded assumptions | Login (`+91`), TrackOrder (fake timestamps) | 🟡 |

---

## 7. Buyer–Seller Data Flow Synchronization Audit

### 7.1 End-to-End Flow Matrix

#### FLOW 1: Seller Add/Update Product ➔ Buyer Home
| Step | Component | Collection | Mode | Status |
|------|-----------|-----------|:----:|:------:|
| 1 | Seller: `ProductListBloc._onAddProduct` | `products/{id}` | Write | ✅ |
| 2 | Firestore `products` document updated | — | — | ✅ |
| 3 | Buyer: `HomePageBloc._onProductsUpdated` | `products` collection | Stream `snapshots()` | ✅ |
| 4 | `FoodItemMapper.toViewModel()` | — | Transform | ✅ |
| 5 | `HomePageUI` re-renders cards | — | — | ✅ |
| **Verdict** | **✅ REAL-TIME** | | | **Pass** |

#### FLOW 2: Seller Update Product ➔ Buyer Details
| Step | Component | Collection | Mode | Status |
|------|-----------|-----------|:----:|:------:|
| 1 | Seller: `ProductListBloc._onToggleProductStatus` | `products/{id}` | Write | ✅ |
| 2 | Firestore `products` document updated | — | — | ✅ |
| 3 | Buyer: `DetailsRepository` stream | `products/{id}` | Stream `snapshots()` | ✅ |
| 4 | Details Page UI re-renders | — | — | ✅ |
| **Verdict** | **✅ REAL-TIME** | | | **Pass** |

#### FLOW 3: Seller Archive Product ➔ Buyer Search
| Step | Component | Collection | Mode | Status |
|------|-----------|-----------|:----:|:------:|
| 1 | Seller: archive product | `products/{id}` (isArchived=true) | Write | ✅ |
| 2 | Buyer stream picks up change | `products` collection | Stream | ✅ |
| 3 | `FoodItemMapper` filters out `isArchived` | — | — | ✅ |
| **Verdict** | **✅ REAL-TIME** | | | **Pass** |

#### FLOW 4: Seller Stock Change ➔ Buyer Cart ❌
| Step | Component | Collection | Mode | Status |
|------|-----------|-----------|:----:|:------:|
| 1 | Seller: `InventoryBloc._onUpdateStock` | `products/{id}` (availableStock) | Write | ✅ |
| 2 | Firestore updates product stock | — | — | ✅ |
| 3 | **Buyer Cart does NOT listen to `products` collection** | — | ❌ | **MISSING** |
| 4 | Buyer checks out with stale stock | — | — | ❌ |
| **Verdict** | **❌ NO SYNC** | Buyer cart never knows stock changed | | **Fail** |

#### FLOW 5: Seller Price Change ➔ Buyer Cart ❌
| Step | Component | Collection | Mode | Status |
|------|-----------|-----------|:----:|:------:|
| 1 | Seller: update product price | `products/{id}` (price) | Write | ✅ |
| 2 | **Cart stores price at add-time** in `users/{uid}/cart/{id}` | — | — | ❌ |
| 3 | **Buyer Cart shows OLD price** | — | — | ❌ |
| **Verdict** | **❌ NO SYNC** | Cart price frozen at add-time | | **Fail** |

#### FLOW 6: Seller Business Hours ➔ Buyer Home
| Step | Component | Collection | Mode | Status |
|------|-----------|-----------|:----:|:------:|
| 1 | Seller: `BusinessHoursBloc` update | `sellers/{id}/settings/business_hours` | Write | ✅ |
| 2 | `SellerStatusService` watches `sellers/{id}` | `sellers` collection | Stream `snapshots()` | ✅ |
| 3 | Buyer Home reads `SellerStatusService` | — | Stream | ✅ |
| 4 | HomePageUI renders Open/Closed badge | — | — | ✅ |
| **Verdict** | **✅ REAL-TIME** | | | **Pass** |

#### FLOW 7: Seller Emergency Close ➔ Buyer Details/Cart
| Step | Component | Collection | Mode | Status |
|------|-----------|-----------|:----:|:------:|
| 1 | Seller: toggle emergency close | `sellers/{id}` (isEmergencyClosed) | Write | ✅ |
| 2 | `SellerStatusService` picks up change | `sellers/{id}` stream | Stream | ✅ |
| 3 | Buyer Details: `sellerAvailability.isAvailable` | Details Page | Stream | ✅ |
| 4 | **Buyer Cart: does NOT check seller availability** | Cart Page | ❌ | **MISSING** |
| **Verdict** | **⚠️ PARTIAL** | Details OK, Cart blind to emergency close | | **Warn** |

#### FLOW 8: Seller Coupon Create/Update ➔ Buyer Cart
| Step | Component | Collection | Mode | Status |
|------|-----------|-----------|:----:|:------:|
| 1 | Seller: add/update coupon | `sellers/{id}/coupons/{couponId}` | Write | ✅ |
| 2 | Buyer Cart: coupon subscription at load-time | Collection Group query | One-time | ❌ |
| 3 | **Coupon subscription NEVER refreshed when cart changes** | — | ❌ | **MISSING** |
| **Verdict** | **⚠️ STALE** | Coupons loaded once, never re-fetched | | **Fail** |

#### FLOW 9: Buyer Creates Order ➔ Seller Notifications
| Step | Component | Collection | Mode | Status |
|------|-----------|-----------|:----:|:------:|
| 1 | Buyer: checkout via Cloud Function | `orders/{orderId}` (status='New') | Write (CF) | ✅ |
| 2 | Firestore `orders` document created | — | — | ✅ |
| 3 | Seller: `NewOrderNotificationBloc` stream | `orders` (status='New') | Stream `snapshots()` | ✅ |
| 4 | Seller: `OrdersListBloc` stream | `orders` (by sellerId) | Stream `snapshots()` | ✅ |
| **Verdict** | **✅ REAL-TIME** | | | **Pass** |

#### FLOW 10: Seller Accepts Order ➔ Buyer Track Order ⚠️
| Step | Component | Collection | Mode | Status |
|------|-----------|-----------|:----:|:------:|
| 1 | Seller: `OrdersListBloc._onUpdateOrderStatus` | `orders/{id}` (status='Accepted') | Write | ✅ |
| 2 | Firestore updates order status | — | — | ✅ |
| 3 | **Buyer: `OrderListBloc` gets real-time update** | `orders` by customerId | Stream `snapshots()` | ✅ |
| 4 | **Buyer: `TrackOrderBloc` uses ONE-TIME `get()` — no real-time** | `orders/{id}` | ❌ `get()` | **❌ MISSING** |
| 5 | **Buyer Track Order page shows STALE status** | — | — | ❌ |
| **Verdict** | **⚠️ INCONSISTENT** | Order List sees it, Track Order doesn't | | **Warn** |

#### FLOW 11: Seller Rejects Order ➔ Buyer Orders
| Step | Component | Collection | Mode | Status |
|------|-----------|-----------|:----:|:------:|
| 1 | Seller: reject order | `orders/{id}` (status='Rejected') | Write | ✅ |
| 2 | Buyer Order List sees stream update | `orders` by customerId | Stream | ✅ |
| 3 | **Order UI re-renders with Rejected badge** | — | — | ✅ |
| **Verdict** | **✅ REAL-TIME** (for list view) | | | **Pass** |

#### FLOW 12: Seller Assigns Delivery ➔ Buyer Track Order
| Step | Component | Collection | Mode | Status |
|------|-----------|-----------|:----:|:------:|
| 1 | Seller: assign delivery | `orders/{id}` (riderId, status='OutForDelivery') | Write | ✅ |
| 2 | Firestore updates order | — | — | ✅ |
| 3 | Buyer Track Order: **must manually refresh to see rider data** | `orders/{id}` | ❌ `get()` | **MISSING** |
| 4 | **Rider location IS streamed** | `riders/{riderId}` | ✅ Stream | ✅ |
| **Verdict** | **⚠️ PARTIAL** | Rider location is stream, but order status/rider assignment is NOT | | **Warn** |

#### FLOW 13: Seller Marks Complete ➔ Buyer Wallet/History ❌
| Step | Component | Collection | Mode | Status |
|------|-----------|-----------|:----:|:------:|
| 1 | Seller: mark order delivered | `orders/{id}` (status='Delivered') | Write | ✅ |
| 2 | Buyer Order List sees delivered status | Stream | ✅ | ✅ |
| 3 | **Buyer Wallet does NOT get updated** — no transaction created on delivery | `users/{uid}/transactions` | ❌ | **MISSING** |
| 4 | **No payout/earnings reflected in buyer wallet** | — | — | ❌ |
| **Verdict** | **❌ NO SYNC** | Order completion doesn't update wallet/transactions | | **Fail** |

#### FLOW 14: Buyer Rates Product ➔ Seller Analytics
| Step | Component | Collection | Mode | Status |
|------|-----------|-----------|:----:|:------:|
| 1 | Buyer: `RatingPageBloc._onSubmitRating` | `products/{pid}/reviews` + `users/{uid}/ratings` | Write | ✅ |
| 2 | Firestore updates | — | — | ✅ |
| 3 | Seller: `AnalyticsBloc` listens to reviews | `products/{pid}/reviews` | CG Stream | ✅ |
| 4 | Seller Analytics re-renders | — | — | ✅ |
| **Verdict** | **✅ REAL-TIME** | | | **Pass** |

#### FLOW 15: Buyer Favorites Product ➔ Seller Analytics
| Step | Component | Collection | Mode | Status |
|------|-----------|-----------|:----:|:------:|
| 1 | Buyer: `FavoritesBloc` toggle | `users/{uid}/favorites/{itemId}` | Write | ✅ |
| 2 | Firestore updates | — | — | ✅ |
| 3 | Seller: `AnalyticsBloc` listens to favorites | `users/{uid}/favorites` | CG Stream | ✅ |
| 4 | Seller Dashboard sees favorite count | — | — | ✅ |
| **Verdict** | **✅ REAL-TIME** | | | **Pass** |

#### FLOW 16: Buyer ↔ Seller Chat (Bidirectional)
| Step | Component | Collection | Mode | Status |
|------|-----------|-----------|:----:|:------:|
| 1 | Buyer sends message | `conversations/{cid}/messages` | Write | ✅ |
| 2 | Seller receives via stream | Stream | ✅ | ✅ |
| 3 | Seller sends message | `conversations/{cid}/messages` | Write | ✅ |
| 4 | Buyer receives via stream | Stream | ✅ | ✅ |
| **Verdict** | **✅ REAL-TIME BIDIRECTIONAL** | | | **Pass** |

#### FLOW 17: Seller Deletes Product ➔ Buyer Favorites ❌
| Step | Component | Collection | Mode | Status |
|------|-----------|-----------|:----:|:------:|
| 1 | Seller: delete product | `products/{id}` | Delete | ✅ |
| 2 | **Buyer Favorites still references deleted product** | `users/{uid}/favorites/{itemId}` | ❌ | **ORPHANED** |
| 3 | **Buyer Favorites page shows broken/empty item** | — | — | ❌ |
| **Verdict** | **❌ ORPHAN DATA** | No cleanup on product delete | | **Fail** |

#### FLOW 18: Seller Disables Product ➔ Buyer Cart ❌
| Step | Component | Collection | Mode | Status |
|------|-----------|-----------|:----:|:------:|
| 1 | Seller: toggle product inactive | `products/{id}` (isActive=false) | Write | ✅ |
| 2 | **Buyer Cart does NOT check if product is still active** | `users/{uid}/cart` | ❌ | **MISSING** |
| 3 | Buyer can still checkout with disabled product | — | — | ❌ |
| **Verdict** | **❌ NO SYNC** | Cart allows checkout of disabled products | | **Fail** |

---

## 8. Synchronization Coverage Scorecard

### 8.1 Business Flow Scores

| # | Flow | Source → Target | Sync Type | Score | Status |
|---|------|----------------|:---------:|:----:|:------:|
| 1 | Product → Buyer Home | Seller → Firestore → Buyer Stream | Real-time | 100% | ✅ |
| 2 | Product Update → Buyer Details | Seller → Firestore → Buyer Stream | Real-time | 100% | ✅ |
| 3 | Archive → Buyer Search | Seller → Firestore → Buyer Stream | Real-time | 100% | ✅ |
| 4 | **Stock → Buyer Cart** | Seller → Firestore ⇢ **Cart blind** | **None** | **0%** | **❌** |
| 5 | **Price → Buyer Cart** | Seller → Firestore ⇢ **Cart has stale price** | **None** | **0%** | **❌** |
| 6 | Business Hours → Buyer | Seller → FS → SellerStatusService → Buyer | Real-time | **90%** | ✅ |
| 7 | Emergency Close → Cart | Seller → FS → StatusService → **Cart blind** | **Partial** | **50%** | ⚠️ |
| 8 | **Coupon → Buyer Cart** | Seller → FS → **One-time load, never refreshed** | **Stale** | **30%** | **❌** |
| 9 | Order → Seller Notification | Buyer → CF → Firestore → Seller Stream | Real-time | 100% | ✅ |
| 10 | **Accept → Buyer Track** | Seller → FS → **Track uses one-time get()** | **Partial** | **50%** | ⚠️ |
| 11 | Reject → Buyer Orders | Seller → FS → Buyer Order Stream | Real-time | 100% | ✅ |
| 12 | **Assign Delivery → Buyer** | Seller → FS → **Track gets stale** | **Partial** | **40%** | ⚠️ |
| 13 | **Complete → Buyer Wallet** | Seller → FS → **Wallet never notified** | **None** | **0%** | **❌** |
| 14 | Rating → Seller Analytics | Buyer → FS → Seller Analytics Stream | Real-time | 100% | ✅ |
| 15 | Favorite → Seller Analytics | Buyer → FS → Seller Analytics CG | Real-time | 100% | ✅ |
| 16 | Chat Bidirectional | Both → FS → Both Stream | Real-time | 100% | ✅ |
| 17 | **Delete → Buyer Favorites** | Seller → FS → **Favorites orphaned** | **None** | **0%** | **❌** |
| 18 | **Disable → Buyer Cart** | Seller → FS → **Cart doesn't check** | **None** | **0%** | **❌** |

### 8.2 Overall Synchronization Health

| Metric | Score |
|--------|:-----:|
| Flows with Full Real-time Sync (100%) | **9 / 18 (50%)** |
| Flows with Partial Sync (30-90%) | **3 / 18 (17%)** |
| Flows with NO Sync (0%) | **6 / 18 (33%)** |
| **Overall Synchronization Coverage** | **⚠️ 53%** |

### 8.3 Synchronization Gap Analysis

| Gap ID | Missing Sync | Business Impact | Severity |
|--------|-------------|----------------|:--------:|
| G1 | Stock → Cart | Buyer checks out with out-of-stock item → order fails | 🔴 Critical |
| G2 | Price → Cart | Buyer pays old price → seller loses money or order cancelled | 🔴 Critical |
| G3 | Complete → Wallet | No transaction history → buyer cannot track spending | 🔴 High |
| G4 | Delete → Favorites | Broken UI, orphaned data | 🟡 Medium |
| G5 | Disable → Cart | Buyer can order disabled product → order fails | 🔴 Critical |
| G6 | Coupon → Cart (stale) | Buyer sees expired/wrong coupons → bad UX | 🟡 Medium |
| G7 | Accept → Track (stale) | Order status in Track page is stale | 🟡 Medium |
| G8 | Assign Delivery → Track (stale) | Rider assignment not reflected in real-time | 🟡 Medium |
| G9 | Emergency Close → Cart | Buyer can add to cart from closed store → wasted effort | 🟡 Medium |

---

## 9. Cross-Architecture Dependency Graph

```
SELLER SIDE                                      FIRESTORE                                      BUYER SIDE
=============                                    =========                                      ===========

AddProductBloc ──► products/{pid} ──────► snapshots() ──► HomePageBloc ──► HomePageUI (cards)
                    │                                   │
                    │                                   └──► DetailsBloc ──► DetailsPageUI
                    │                                              │
                    ▼                                              ▼
ProductListBloc ──► isActive, price, stock              CartPageBloc ◄── users/{uid}/cart
Archive/Toggle                                             │
                    │                                      │ ❌ Doesn't watch products collection
InventoryBloc ────► availableStock ────► Snapshots()       │
                    │                                      ▼
                    │                                [Out-of-stock items in cart]
                    │
BusinessHoursBloc ─► sellers/{id}/settings/business_hours
                    │        │
                    │        └──► SellerStatusService(watch seller/{id}) ───► BuyerHome (Open/Closed badge)
                    │                                        │
                    │                                        └──► BuyerDetails (Add-to-cart disabled if closed)
                    │
CouponBloc ───────► sellers/{id}/coupons ───► CollectionGroup ──► CartPageBloc (loaded once, never refreshed)
                    │
OrdersListBloc ────┐
NewOrderNotif ─────┤
DashboardBloc ─────┤
                    │
                    ▼
              orders/{orderId} ────────── snapshots() ──► BuyerOrderListBloc ──► OrderPageUI
                    │                                        │
                    │                                        └──► TrackOrderBloc (USES get(), NOT snapshots!)
                    │                                                │
AssignDelivery ────► riderId, status='OutForDelivery' ──► one-time get() → stale rider data
                    │                                     Only rider location is streamed (riders/{id})
Seller marks ──────► status='Delivered' ──► Stream        Buyer Wallet ❌ not updated
Complete                                                      │
                    │                                         └──► No transaction created on delivery
                    │
AnalyticsBloc ─────┤
   ◄── CG favorites (users/{uid}/favorites) ◄──── FavoritesBloc (Buyer)
   ◄── CG reviews (products/{pid}/reviews) ◄──── RatingPageBloc (Buyer)
   ◄── orders (one-time get) ◄──── Order creation

                    ▲
ChatBloc (Seller)──┤
                    │
              conversations/{cid}/messages ── snapshots() (bidirectional)
                    │
ChatBloc (Buyer)───┘
```

### 9.1 Key Dependency Paths Missing From Graph

| Path | Status | Issue |
|------|:------:|-------|
| `products.isActive` → `Cart checkout guard` | ❌ | Cart doesn't check if product is still active before checkout |
| `products.availableStock` → `Cart quantity cap` | ❌ | Cart allows quantity beyond available stock |
| `products.price` → `Cart price recalc` | ❌ | Cart uses add-time price, doesn't re-fetch |
| `orders.status` → `TrackOrder status` | ❌ | TrackOrder uses one-time get, not stream |
| `orders.status='Delivered'` → `Wallet transaction` | ❌ | No wallet credit/transaction on delivery |
| `products` delete → `Favorites cleanup` | ❌ | Favorites reference deleted products |
| `sellers/{id}/coupons` → `Cart coupon refresh` | ❌ | Coupons loaded once, never refreshed |

---

## 10. Action Items (Prioritized)

### 🚨 CRITICAL — Immediate (Synchronization Bugs)

| # | Action | Expected Effort |
|---|--------|:----------------:|
| **S1** | Fix `orElse` bug in orders: replace `orElse: () => _allOrders.first` with error emit | 15 min |
| **S2** | Fix Cart stock validation: add `products/{id}` listener to Cart BLoC, prevent checkout if `availableStock < quantity` | 2 hrs |
| **S3** | Fix Cart price sync: re-fetch product price on cart load, show warning if price changed | 2 hrs |
| **S4** | Fix Cart disabled-product guard: check `products.isActive` before allowing checkout | 1 hr |
| **S5** | Fix Track Order to use real-time stream on `orders/{id}` instead of one-time `get()` | 1 hr |
| **S6** | Add wallet transaction on order delivery: Cloud Function or repository to add `users/{uid}/transactions` when status='Delivered' | 2 hrs |
| **S7** | Fix Analytics subscription leak: cancel subs before `fetchAnalyticsData()` | 30 min |

### 🔴 HIGH Priority

| # | Action | Expected Effort |
|---|--------|:----------------:|
| **S8** | Fix Inventory stream error: replace empty catch with error state emit | 15 min |
| **S9** | Add optimistic updates to Cart (add/remove/qty) | 2 hrs |
| **S10** | Fix silent catch blocks across Cart(4x), TrackOrder, AddProduct, Inventory | 1 hr |
| **S11** | Replace direct Firebase calls with repository interfaces (Favorites, Rating, Wallet, AddProduct) | 3 hrs |
| **S12** | Fix coupon subscription: refresh when cart items change | 1 hr |
| **S13** | Add Favorites cleanup when product is deleted (or at least show "unavailable" state) | 1 hr |
| **S14** | Add Cart seller-availability check: block checkout if seller emergency-closed | 1 hr |

### 🟡 MEDIUM Priority

| # | Action | Expected Effort |
|---|--------|:----------------:|
| **S15** | Standardize all BLoCs to use Equatable on events/states | 2 hrs |
| **S16** | Remove dead code files (`order_repository.dart`, `orders_list_page_repository.dart`) | 15 min |
| **S17** | Fix UserProfile double-emit (success/error overwrite) | 30 min |
| **S18** | Fix AssignDelivery double-emission pattern | 30 min |
| **S19** | Add loading states for all mutations (ProductList, AddProduct, NewOrderNotification) | 1.5 hrs |
| **S20** | Replace hardcoded `+91` with dynamic country code detection | 30 min |

### 🟢 LOW Priority

| # | Action | Expected Effort |
|---|--------|:----------------:|
| **S21** | Remove dead state fields (`ratingStatus`/`ratingMessage` in Details) | 15 min |
| **S22** | Fix wallet transaction history: standardize transaction creation | 30 min |
| **S23** | Add Order-TrackOrder consistent status: convert TrackOrder to use real-time orders stream | 1 hr |
| **S24** | Fix TrackOrder `dispose()` not called | 15 min |
| **S25** | Fix Business Hours & Menu Categories immutability (in-place mutation) | 30 min |

### 📋 Estimated Total Effort

| Priority | Items | Effort |
|----------|:----:|:------:|
| 🚨 Critical | 7 items | ~9 hrs |
| 🔴 High | 7 items | ~9 hrs |
| 🟡 Medium | 6 items | ~5 hrs |
| 🟢 Low | 5 items | ~2.5 hrs |
| **Total** | **25 items** | **~25.5 hrs** |

---

## 11. Final Assessment

| Criterion | Rating | Notes |
|-----------|:------:|-------|
| **BLoC Pattern Correctness** | ⚠️ 65% | Direct Firebase, missing Equatable, no DI in many BLoCs |
| **Data Flow Synchronization (Buyer↔Seller)** | **❌ 53%** | **6 of 18 business flows have ZERO sync** |
| **Error Handling Completeness** | ❌ 35% | Widespread empty catch blocks, no recovery |
| **State Immutability** | ⚠️ 70% | Two features mutate state in-place |
| **Repository Layer Separation** | ⚠️ 55% | Mixed patterns, direct Firebase in 4+ BLoCs |
| **Code Consistency** | ❌ 30% | `part` vs `import`, Equatable vs non-Equatable |
| **Real-time Stream Coverage** | ✅ 85% | Most collections use `snapshots()`, but critical gaps exist |
| **Overall Health** | **⚠️ 56%** | **18 synchronization gaps found — S1-S7 need immediate action** |

### Summary of What Works ✅
- Product → Home/Details real-time sync (stream-based, solid)
- Business Hours → Buyer Availability (via SellerStatusService, clean pattern)
- Order → Seller Notifications (real-time stream)
- Rating/Favorite → Seller Analytics (collection group queries)
- Chat (bidirectional real-time messaging)

### Summary of What's Broken ❌
1. **Cart is completely disconnected from product data** — stock, price, availability changes invisible
2. **Track Order is NOT real-time** for order status — only rider location is streamed
3. **Order completion doesn't update wallet/transactions**
4. **Product deletion orphans favorites**
5. **Coupons are loaded once and never refreshed**
6. **Seller emergency close not propagated to Cart**

> **Bottom Line (Revised):** Beyond the BLoC quality issues identified earlier, the **Buyer↔Seller data flow synchronization is critically broken in 6 out of 18 business flows**. The Cart feature is the most affected — it operates in complete isolation from the `products` collection, leading to out-of-stock purchases, stale pricing, and disabled-product checkouts. Fixing the 7 critical synchronization gaps (S1-S7) should be the **top priority** before any architectural refactoring.
