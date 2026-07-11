# Universal Continuous Development Lifecycle Management Rules

## 1. 8-Step Enterprise Development Workflow
You MUST strictly follow this 8-step continuous workflow for every development task to ensure resilience against session interruptions (token limits, crashes, network cuts) and to maintain the highest code quality:

1. **Session Recovery & Context Sync:**
   - If the previous task was interrupted due to token limits, IDE quota limits, network interruptions, crashes, or unexpected termination, automatically perform a deep recovery analysis of the entire codebase.
   - Identify unfinished implementations, partially updated source files, incomplete BLoC components, repositories, centralized database configurations, missing or outdated tests, and continue from the last consistent state instead of restarting the task.
2. **Deep Analysis:** Understand the user's request fully and research the current codebase before writing any code.
3. **Impact Analysis:** Evaluate the cross-module impact of the proposed changes. Determine how it affects other features, shared components, or core logic.
4. **Existing Code Audit:** Review existing code patterns, architecture, and dependencies relevant to the task.
5. **Implementation:** Write the code, strictly adhering to the Architecture and Code Modification rules.
6. **Test Sync (Continuous Maintenance):** Whenever possible, identify and synchronize all affected test files. Ensure continuous test maintenance across all three timeframes: **Past** (audit existing code and generate missing tests), **Present** (synchronize affected tests immediately), and **Future** (generate all applicable test categories upfront for new features).
7. **Verification:** Autonomously run the tests in the terminal (e.g., using `flutter test`) whenever execution capability is available. Verify that the tests pass before reporting completion. If the environment does not permit test execution, clearly report that the tests could not be executed instead of claiming they passed. Ensure the folder structure remains unchanged, naming conventions are maintained, and imports are valid.
8. **Report:** Output a detailed final report of the work done.

## 2. Architecture & Project Protection
- Never change, rename, move, or delete the existing project architecture, folder structure, or file organization unless the user explicitly requests it.
- Never migrate, replace, or refactor the existing architecture or state management solution (including BLoC, Clean Architecture, MVVM, MVC, Provider, Riverpod, GetX, MobX, Redux, etc.) unless explicitly instructed by the user.
- Do not create new folders (e.g., `core`, `core_models`, `core_module`, `shared`) unless explicitly approved by the user.
- Always preserve and strictly follow the existing project structure and coding patterns.

## 3. Code Modification Rules
- Modify only the files required for the current task.
- Never refactor unrelated modules.
- Never rewrite working code unless explicitly requested.
- Always preserve the existing coding style, naming conventions, formatting, and project patterns.
- Do not introduce new coding patterns unless explicitly requested by the user.

## 4. BLoC Rules
- Follow the existing BLoC pattern exactly.
- Reuse the existing Events, States, Repositories, Services, and Models whenever possible.
- Do not introduce a different state management solution.

## 5. Backend & API Rules
- Do not alter the existing backend infrastructure, database schema, APIs, authentication flow, or storage structure unless explicitly instructed by the user.

## 6. Comprehensive Test Lifecycle & Maintenance
- During every development session, perform a deep analysis of the entire project to ensure that all existing and newly generated tests remain synchronized with the current implementation.
- Continuously maintain all applicable test categories, including:
  - Unit Tests
  - Widget Tests
  - BLoC Tests
  - Integration Tests
  - Golden Tests
  - Performance Tests
  - Accessibility Tests
  - Security Tests
  - Localization Tests
  - Snapshot Tests
  - Dependency Tests
  - State Restoration Tests
  - Error Handling Tests
  - Permission Tests
- If any test category is missing, outdated, incomplete, or inconsistent with the current implementation, whenever possible regenerate or update only the affected tests while preserving unrelated tests.
Ensure continuous test synchronization and coverage across all three timeframes:
- **Past (Legacy Code):** Audit existing code and tests. Proactively identify code that lacks tests or has outdated tests, and generate/update them across all applicable categories to ensure full coverage.
- **Present (Active Changes):** Whenever making code modifications, immediately identify and synchronize all affected tests to maintain strict alignment.
- **Future (New Features):** For every new feature, generate all applicable test categories upfront (including unit, widget, bloc, integration, golden, performance, accessibility, security, localization, snapshot, dependency, state restoration, error handling, and permission tests). Keep them continuously synchronized with any subsequent changes.
- Never modify unrelated tests.
- If a test cannot be safely updated, report it instead of guessing.

## 7. Enhanced Output Rules
At the end of every task, you must provide a detailed report including:
- Modified Source Files
- Updated Test Files
- Lacking/Missing Tests
- Cross-Module Impact Analysis
- Reason for each change
- Any manual steps or checks required
