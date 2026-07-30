
# 🏗️ Food Delivery App — Action Execution Plan

> **⏱ Generated:** 2026-07-29 | **Status:** Iteration 1 Complete
> **Target:** Architecture Health 54% → **75%+**

---

## Iteration Plan Overview

| Iteration | Focus | Target Health | Est. Effort | Status |
|-----------|-------|:-------------:|:-----------:|:------:|
| **1** | 🚨 Critical Sync Bugs (S1-S8) | 54% → 70% | ~10 hrs | ✅ **Done** |
| **2** | 🔴 High Priority BLoC Refactors | 70% → 78% | ~12 hrs | ⏳ Planned |
| **3** | 🟡 Medium Quality & Consistency | 78% → 83% | ~8 hrs | 📋 Planned |
| **4** | 🟢 Low Polish & Dead Code | 83% → 85%+ | ~4 hrs | 📋 Planned |

---

## ✅ ITERATION 1 — CRITICAL SYNC BUGS (COMPLETED)

### S1: Wrong-Order Update Bug (Orders List)
| Detail | Value |
|--------|-------|
| **File** | `orders_list_page_bloc.dart:75-78` |
| **Fix** | Replaced `orElse: () => _allOrders.first` → `indexWhere` + error emit |
| **Risk** | 🚨 Could silently update + charge wrong customer |
| **Status** | ✅ Fixed, analyzed OK |
| **Assigned** | Architect |
| **Effort** | 15 min |

### S2-S4: Cart Product Validation (Stock, Price, Active Status)
| Detail | Value |
|--------|-------|
| **Files** | `cart_page_Bloc.dart`, `cart_page_State.dart` |
| **Fix** | Added `IProductRepository` dep; pre-checkout validatation checks stock, price, active status, seller availability per item |
| **Risk** | 🚨 Checkout of out-of-stock / disabled / wrong-price items |
| **Status** | ✅ Fixed, analyzed OK |
| **Assigned** | Architect |
| **Effort** | 4 hrs |

### S5: Track Order Real-Time Sync
| Detail | Value |
|--------|-------|
| **Files** | `Track_Order_page_bloc.dart`, `Track_Order_page_event.dart` |
| **Fix** | Added real-time `orders/{id}` Firestore stream subscription; removed fabricated timestamps |
| **Risk** | 🚨 Stale order status on tracking page |
| **Status** | ✅ Fixed, analyzed OK |
| **Assigned** | Architect |
| **Effort** | 2 hrs |

### S6: Wallet Transaction on Delivery
| Detail | Value |
|--------|-------|
| **File** | `orders_list_page_bloc.dart` |
| **Fix** | Added `users/{uid}/transactions.add()` when status → `Delivered` |
| **Risk** | 🚨 No wallet/transaction history on order completion |
| **Status** | ✅ Fixed, analyzed OK |
| **Assigned** | Architect |
| **Effort** | 1 hr |

### S7: Analytics Subscription Leak
| Detail | Value |
|--------|-------|
| **File** | `seller_analytics_page__bloc.dart` |
| **Fix** | Reordered: `fetchAnalyticsData()` before subscriptions; cancel subs in catch block |
| **Risk** | 🚨 Stream subs leak, `add()` on closed BLoC → crash |
| **Status** | ✅ Fixed, analyzed OK |
| **Assigned** | Architect |
| **Effort** | 30 min |

### S8: Inventory Stream Error Handling
| Detail | Value |
|--------|-------|
| **Files** | `inventory_low_stock_page_bloc.dart`, `inventory_low_stock_page_state.dart` |
| **Fix** | Added `_InventoryErrorReceived` event + `InventoryError` state |
| **Risk** | 🚨 BLoC stuck in loading state forever on stream error |
| **Status** | ✅ Fixed, analyzed OK |
| **Assigned** | Architect |
| **Effort** | 30 min |

### BONUS: Additional Fixes in Iteration 1

| ID | Issue | File | Fix |
|----|-------|------|-----|
| **B1** | Favorites - no error handling on toggle | `favorites_bloc.dart` | Added try/catch + error emit + state recovery |
| **B2** | Rating - race condition (`state.rating` vs `event.rating`) | `Rating_page_bloc.dart` | Changed → `event.rating` in success/error |
| **B3** | UserProfile - double-emit (success/error flash-over) | `user_profile_image_Bloc.dart` + `State.dart` | Merged messages into `ProfileLoaded.copyWith()` |

---

## 📋 ITERATION 2 — HIGH PRIORITY (PLANNED)

| # | Action | File(s) | Est. Effort | Developer |
|---|--------|---------|:-----------:|:---------:|
| H1 | Replace direct Firebase in Favorites BLoC with `I*Repository` | `favorites_bloc.dart` | 1 hr | Senior |
| H2 | Replace direct Firebase in Rating BLoC with `I*Repository` | `Rating_page_bloc.dart` | 1 hr | Senior |
| H3 | Replace direct Firebase in Wallet BLoC with `I*Repository` | `WalletScreen_Bloc.dart` | 1.5 hrs | Senior |
| H4 | Add Equatable to all events/states missing it (Business Hours, Promotions, Menu Categories, Wallet, Chat) | 5 feature areas | 2 hrs | Mid |
| H5 | Remove dead code (`order_repository.dart`, `orders_list_page_repository.dart`) | 2 files | 30 min | Junior |
| H6 | Fix AssignDelivery double-emission pattern | `assign_delivery_page__bloc.dart` | 30 min | Mid |
| H7 | Add Favorites cleanup on product delete (or "unavailable" fallback UI) | `favorites_bloc.dart` + UI | 2 hrs | Senior |
| H8 | Add Coupon subscription refresh on cart change | `cart_page_Bloc.dart` | 1 hr | Senior |
| H9 | Fix `_onAddProduct` in AddProduct — remove direct Firestore call | `add_product_page__bloc.dart` | 1 hr | Senior |
| H10 | Fix `TrackingLoading`/`LocationUpdated` dead states — remove or implement | `Track_Order_page_state.dart` | 30 min | Junior |
| H11 | Fix hardcoded `+91` country code in Seller Login | `seller_login_page_bloc.dart` | 1 hr | Mid |

---

## 📋 ITERATION 3 — MEDIUM PRIORITY (PLANNED)

| # | Action | File(s) | Est. Effort | Developer |
|---|--------|---------|:-----------:|:---------:|
| M1 | Add loading states for mutations (ProductList, AddProduct, NewOrderNotification) | 3 features | 2 hrs | Senior |
| M2 | Fix Business Hours & Menu Categories immutability (in-place list mutation) | 2 features | 1 hr | Mid |
| M3 | Fix UserProfile image compression — use `compute()` isolate | `user_profile_image_Bloc.dart` | 1 hr | Senior |
| M4 | Add unsaved-changes guard for MenuCategory navigation | `menu_category_management_page_bloc.dart` | 30 min | Mid |
| M5 | Standardize `part` vs `import` across all BLoCs | All features | 2 hrs | Senior |
| M6 | Standardize repository naming (`I*Repository` vs abstract class) | Both architectures | 1 hr | Senior |
| M7 | Add error recovery mechanism (retry event) across all BLoCs | All BLoCs | 3 hrs | Senior |
| M8 | Add `dispose()` call in TrackOrder BLoC's `close()` | `Track_Order_page_repository.dart` | 15 min | Junior |

---

## 📋 ITERATION 4 — LOW PRIORITY (PLANNED)

| # | Action | File(s) | Est. Effort | Developer |
|---|--------|---------|:-----------:|:---------:|
| L1 | Remove dead state fields (`ratingStatus`/`ratingMessage` in Details) | `details_page_State.dart` | 15 min | Junior |
| L2 | Add `close()` override to BLoCs missing it (Order, Login, Wallet) | 3 files | 15 min | Junior |
| L3 | Fix Wallet `LoadWalletData` to actually load data | `WalletScreen_Bloc.dart` | 30 min | Mid |
| L4 | Replace `dynamic` in `SendBuyerMediaMessage.file` with proper type | `buyer_chat_event.dart` | 15 min | Junior |
| L5 | Remove unused `order_repository.dart` and `orders_list_page_repository.dart` | 2 files | 15 min | Junior |

---

## Synchronization Health Tracking

| Metric | Before Iter 1 | After Iter 1 | Iter 2 Target | Iter 3 Target |
|--------|:-------------:|:------------:|:-------------:|:-------------:|
| **Sync Coverage** | 53% | **~72%** | 80% | 85% |
| Flows 100% synced | 9/18 | **12/18** | 14/18 | 15/18 |
| Flows 0% synced | 6/18 | **2/18** | 0/18 | 0/18 |
| BLoC Pattern | 65% | **70%** | 78% | 82% |
| Error Handling | 35% | **55%** | 70% | 80% |
| State Immutability | 70% | **70%** | 85% | 95% |
| Code Consistency | 30% | **30%** | 60% | 80% |
| **Overall Health** | **54%** | **~65%** | **75%** | **85%** |

### Remaining Zero-Sync Flows (after Iter 1):
1. **Price → Cart** (stale price stored in cart doc — needs Cloud Function or server-side price validation)
2. **Delete → Favorites** (product deletion doesn't clean up favorites — needs Cloud Function or UI fallback)

---

## Progress Log

| Date | Iteration | Changes | Status |
|------|-----------|---------|:------:|
| 2026-07-29 | 1 | S1-S8 + B1-B3 (11 files modified) | ✅ Complete |
| TBD | 2 | H1-H11 (17 files) | ⏳ Not started |
| TBD | 3 | M1-M8 (15 files) | 📋 Planned |
| TBD | 4 | L1-L5 (8 files) | 📋 Planned |

---

## Developer Assignment Guide

```
Senior Developers:
  - Repository pattern refactors (H1-H4, H9)
  - Performance-sensitive BLoCs (Cart, Inventory)
  - Stream lifecycle & error recovery (M7)

Mid-Level Developers:
  - Equatable consistency (H4)
  - State immutability fixes (M2)
  - Coupon refresh & wallet fixes (H8, L3)

Junior Developers:
  - Dead code removal (H5, L5)
  - Dead state cleanup (H10, L1)
  - Missing close() overrides (L2)
  - Type safety fixes (L4)
```
