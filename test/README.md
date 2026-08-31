# 🧪 Food Delivery App Test Suite

> **Official Enterprise 3-Role Test Architecture**  
> For full architecture details and runner commands, see [TEST_ARCHITECTURE.md](../TEST_ARCHITECTURE.md).

---

## 📂 Quick Directory Reference

- **`buyer_test/`**: 13 test categories for Buyer flows (Unit, Widget, Integration, Golden, Performance, Accessibility, Security, Localization, Snapshot, Dependency, State Restoration, Error Handling, Permission).
- **`seller_test/`**: 13 test categories for Seller portal & store operations.
- **`delivery_partner_test/`**: 13 test categories for Delivery Partner flows.
- **`e2e/`**: End-to-End full user journeys (auth, order processing, delivery assignment, payments, cancellations, refunds, complete lifecycle).
- **`core_test/`**: App core utilities, security, dependency injection, and error boundaries.
- **`firebase_test/`**: Firebase auth, Firestore, Cloud Storage, Cloud Functions, and Security Rules.
- **`shared_test/`**: Shared widgets, models, services, repositories, and validators.
- **`fixtures/`**: Mock JSON and model seed fixtures.
- **`mocks/`**: Centralized mock classes (Firebase, Repositories, Services, APIs).
- **`test_data/`**: Realistic sample datasets (buyer_user, products, orders, coupons).
- **`helpers/`**: Test automation harnesses, widget wrappers, font loaders, and assertion helpers.
- **`test_config/`**: Test constants, environment configs, mock routes, and binding setup.

---

## 🚀 Execution Commands

```bash
# Run all tests
flutter test

# Run by Role
flutter test test/buyer_test
flutter test test/seller_test
flutter test test/delivery_partner_test

# Run E2E journeys
flutter test test/e2e

# Run Core, Firebase & Shared tests
flutter test test/core_test
flutter test test/firebase_test
flutter test test/shared_test
```
