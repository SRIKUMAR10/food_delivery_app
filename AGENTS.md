# AGENTS.md — Mandatory Workflow

Every task MUST follow these 10 steps in order. Do not skip any step. This file is the source of truth for how work is done in this project.

## 1. Session Recovery & Context Sync
- If a previous session was interrupted, re-explore the whole codebase.
- Detect partially completed files, broken imports, or unfinished refactors.
- Resume from the exact state where work stopped before doing anything new.

## 2. Deep Analysis
- Fully understand the user's requested task.
- Explore the current codebase to find where the change will land.
- Identify every file, widget, state, and event that is relevant.

## 3. Impact Analysis
- Evaluate how the proposed change affects other modules, shared components, and core logic.
- List every file/feature that could break as a result of the change.
- Do not proceed until impact is known.

## 4. Existing Code Audit
- Review current code patterns, architecture, and dependencies.
- Confirm the existing setup is suitable for the task.
- Reuse existing utilities, themes, models, and services — do not reinvent.

## 5. Implementation
- Strictly follow the existing architecture, coding rules, and BLoC pattern.
- Match naming conventions, folder structure, and code style of neighboring files.
- No comments unless asked. No new dependencies unless required.

## 6. Test Sync (Continuous Maintenance)
- Find all related test files.
- Update/create unit, widget, BLoC, and integration tests to match old code, current changes, and new features.
- Keep tests in sync with implementation continuously — this is mandatory, not optional.

## 7. Verification
- Run the tests with: `flutter test --verbose` (or the test command specified in the task).
- All tests MUST pass at the end. If a test cannot pass, clearly report which test, why, and what is blocking.

## 8. Report
- At the end of every task, produce a full report containing:
  - What was changed (files + summary)
  - What was tested (test files + results)
  - Which test types are still missing (unit/widget/BLoC/integration)
  - Which modules are impacted
  - Reason for each change
  - Any remaining manual work the user must do

## 9. Architecture & Project Protection
- Never change the existing architecture, folder structure, or BLoC pattern.
- Every new change must preserve the current architecture exactly.
- If a change would force an architecture change, stop and report it instead of doing it.

## 10. Real-time UI Update
- UI changes must remain real-time capable: responsive, consistent UI/UX across devices.
- Preserve real-time update mechanisms (streams, listeners) already in use.
- Do not replace reactive UI with one-shot updates.

## Rules
- Never commit unless explicitly asked.
- Verify with `flutter test --verbose` after implementation — never skip.
- If any step cannot be completed, state it clearly in the report.
