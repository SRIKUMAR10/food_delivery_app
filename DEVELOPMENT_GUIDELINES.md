# Project Development Guidelines

**Use these 24 requirements as the standard foundation for the entire project. All existing pages, new pages, features, and modules must strictly follow the same architecture and development standards, including BLoC pattern, Clean Architecture, SOLID principles, responsive UI design, accessibility compliance, performance optimization, state management, lifecycle management, and comprehensive testing practices. Ensure consistency in folder structure, naming conventions, code organization, reusable components, and user experience across the application. This approach guarantees maintainability, scalability, reliability, code quality, and a unified experience throughout the project lifecycle.**

## 1. Testing Architecture
1. Maintain the `test/` folder separated into specific sub-folders.
2. **Unit Tests** (`test/unit/`): Test Repositories, Services, and BLoCs using mock examples, `setUp()`, and `tearDown()`.
3. **Widget Tests** (`test/widget/`): Test UI screens, user interactions, and state validation.
4. **Integration Tests** (`test/integration/`): Test end-to-end flows, app launch, navigation, and API success/error states.
5. **Golden Tests** (`test/golden/`): Visual comparison, screen render golden files.
6. **Performance Tests** (`test/performance/`): Measure app load time, frame rate, and scrolling performance.
7. **Accessibility Tests** (`test/accessibility/`): Validate screen readers, focus order, and semantics.
8. **Security Tests** (`test/security/`): Verify authentication and secure data handling.
9. **Localization Tests** (`test/localization/`): Ensure translation correctness and locale-based UI.
10. **Snapshot Tests** (`test/snapshot/`): UI/state serialization snapshots.
11. **Dependency Tests** (`test/dependency/`): Test fallback behavior when APIs fail.
12. All test files must end with `_test.dart`.
13. Use standard test packages: `flutter_test`, `bloc_test`, `mocktail`, `integration_test`.
14. Ensure all tests run successfully via `flutter test`.

## 2. Architecture & Code Quality
15. Follow **Clean Architecture** and **SOLID principles**.
16. Ensure absolutely **no business logic** resides in the UI layer. All business logic and Firebase calls must be in the BLoC/Repository layers.
17. Write clean, organized, and null-safe code.
18. Validate logic functions via unit tests (repository logic, BLoC methods).
19. Ensure all code comments are in **English**.

## 3. UI/UX & Accessibility
20. Design the UI using **Material 3 principles**, ensuring a modern and stylish look.
21. Implement accessible color contrast, smooth animations, skeleton loaders, and intuitive navigation.
22. Ensure **Accessibility Compliance** for all users:
    - Screen reader support via `Semantics`.
    - Minimum tappable areas of 48x48.
    - High color contrast.
23. Ensure responsive breakpoints are handled gracefully.
24. Retain state after page reload or navigation (prevent unnecessary UI rebuilds).

## 4. Performance & Memory Management
25. Optimize performance using **lazy loading**, **image caching**, and pagination.
26. Actively detect and prevent memory leaks.
27. Utilize `initState()` and `dispose()` lifecycle methods meticulously. 
    - Use `initState()` to initialize state variables (e.g., `TextEditingController`, `FocusNode`, Streams).
    - Use `dispose()` to clean up memory and manage resource usage efficiently.
28. Ensure BLoC logic properly manages state consistency and memory safety.

---
*These guidelines must be followed for all current and future development within the Food Delivery App workspace.*
