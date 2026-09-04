# Decision Log

## DEC-001

Decision: Native iPhone application using Swift and SwiftUI.
Reason: Matches the requested platform and keeps the shell Apple-native.
Status: Accepted
Date: 2026-09-03

## DEC-002

Decision: Repository architecture favors centralized domain logic and feature-separated UI.
Reason: Prevents duplicated behavior and keeps future implementation boundaries clear.
Status: Accepted
Date: 2026-09-03

## DEC-003

Decision: Repository structure remains shallow and minimal.
Reason: Reduces navigation overhead and avoids nested helper sprawl.
Status: Accepted
Date: 2026-09-03

## DEC-004

Decision: No unnecessary generated outputs or duplicate historical code are committed.
Reason: Git history should remain the record of superseded work.
Status: Accepted
Date: 2026-09-03

## DEC-005

Decision: Tests are risk-based rather than exhaustive UI duplication.
Reason: Task 00 only needs to prove the shell and canonical terminology can initialize.
Status: Accepted
Date: 2026-09-03

## DEC-006

Decision: Backend and persistence technology remain intentionally undecided after Task 00.
Reason: Prevents premature infrastructure lock-in before product behavior is defined.
Status: Accepted
Date: 2026-09-03

## DEC-007

Decision: GitHub Actions on a standard macOS runner is the canonical native iOS build/test verification path for development environments that do not provide Xcode.
Reason: The primary development environment may be Windows/VS Code, while native iOS compilation and XCTest require the Apple toolchain.
Status: Accepted
Date: 2026-09-03

## DEC-008

Decision: V1 exposes exactly five main tabs: Home, Tasks, Plan, Budget, and Calendar. Shopping, Categories, People, Settings, Dependencies, and Expenses are contextual surfaces, not permanent tabs.
Reason: Keeps the navigation model simple and matches the product's glance-act-manage hierarchy.
Status: Accepted
Date: 2026-09-03

## DEC-009

Decision: Budget owns Shopping, Expenses, and Excel import/export flows.
Reason: Keeps purchase and financial workflows together and avoids a sixth top-level tab.
Status: Accepted
Date: 2026-09-03

## DEC-010

Decision: Calendar remains separate from Plan, and the in-app apartment calendar is the source of truth for apartment presence while Apple Calendar is a per-user sync setting.
Reason: Preserves a clear distinction between scheduling and attendance.
Status: Accepted
Date: 2026-09-03

## DEC-011

Decision: Quick Add defaults to Task creation and must stay lightweight.
Reason: Reduces capture friction and keeps normal task creation fast.
Status: Accepted
Date: 2026-09-03

## DEC-012

Decision: Task status remains To Do / In Progress / Done, while Ready / Blocked is derived separately from prerequisites.
Reason: Keeps lifecycle state user-managed and prevents Blocked from becoming a fourth task status.
Status: Accepted
Date: 2026-09-03

## DEC-013

Decision: V1 uses a single prerequisite dependency relationship between tasks in the same project, and that relationship may cross categories.
Reason: Keeps ordering rules simple while still allowing real project sequencing.
Status: Accepted
Date: 2026-09-03

## DEC-014

Decision: Circular task dependencies are invalid and must be rejected before save.
Reason: Prevents impossible work order loops and keeps readiness calculation deterministic.
Status: Accepted
Date: 2026-09-03

## DEC-015

Decision: Category progress uses equal task weighting rather than duration weighting.
Reason: Keeps progress simple, stable, and independent of estimated task durations.
Status: Accepted
Date: 2026-09-03

## DEC-016

Decision: V1 planning uses calendar days rather than business days.
Reason: Apartment work can happen on weekends, so the schedule model must stay calendar-based.
Status: Accepted
Date: 2026-09-03

## DEC-017

Decision: Apartment Visits are a planning signal, not a person-hour capacity model.
Reason: The app should surface availability without pretending to perform resource scheduling.
Status: Accepted
Date: 2026-09-03

## DEC-018

Decision: Category schedule health uses deterministic On Track / Tight / At Risk / Unknown thresholds based on calendar-day buffer versus longest known remaining chain.
Reason: Planning must be auditable, explainable, and centralized.
Status: Accepted
Date: 2026-09-03

## DEC-019

Decision: Task due dates act as local deadlines in planning calculations, and the earlier applicable deadline governs must-start-by timing.
Reason: Preserves task-level urgency without replacing category deadlines.
Status: Accepted
Date: 2026-09-03

## DEC-020

Decision: Category target dates are authoritative for Category planning, and a Project target date does not silently impose the same deadline on every Category without an explicit Category target.
Reason: Avoids hidden coupling and keeps category deadlines explicit.
Status: Accepted
Date: 2026-09-03

## DEC-021

Decision: V1 does not perform person-level capacity planning, resource leveling, or hour-by-hour optimization.
Reason: Keeps the planning engine deterministic and avoids fake precision.
Status: Accepted
Date: 2026-09-03

## DEC-022

Decision: V1 uses controlled Excel template import and export, not live spreadsheet sync.
Reason: Keeps budget editing deterministic and avoids sync conflict complexity.
Status: Accepted
Date: 2026-09-03

## DEC-023

Decision: Stable Budget Line IDs are required for Excel round-trip matching.
Reason: Prevents row-order matching and makes re-import updates deterministic.
Status: Accepted
Date: 2026-09-03

## DEC-024

Decision: Actual spending is represented by Expense records, not by overwriting planned budget values.
Reason: Keeps planned amounts and real spend distinct.
Status: Accepted
Date: 2026-09-03

## DEC-025

Decision: Shopping items are wishlist-style project items that may link to tasks when they need lifecycle, assignment, or dependency behavior.
Reason: Preserves shopping metadata while keeping task flow available where needed.
Status: Accepted
Date: 2026-09-03

## DEC-026

Decision: Paid-by tracking is informational, and Splitwise-style settlement is out of scope for V1.
Reason: Records who paid without adding a debt-settlement system.
Status: Accepted
Date: 2026-09-03

## DEC-027

Decision: Receipt photos are supported on expenses, but OCR is out of scope for V1.
Reason: Captures proof of purchase without adding document parsing complexity.
Status: Accepted
Date: 2026-09-03

## DEC-028

Decision: Project currency is project-level, defaults to DKK, and does not support multi-currency conversion in V1.
Reason: Keeps all budget, shopping, and expense amounts comparable within one apartment project.
Status: Accepted
Date: 2026-09-03

## DEC-029

Decision: V1 roles are Owner, Member, and Limited.
Reason: Keeps the permission model explicit and bounded for V1.
Status: Accepted
Date: 2026-09-03

## DEC-030

Decision: Notifications and Apple Calendar sync are personal per-user settings.
Reason: Prevents one user from controlling another user's delivery preferences or calendar integration.
Status: Accepted
Date: 2026-09-03

## DEC-031

Decision: Limited role is included in V1 permission logic and its UI may reuse filtered versions of existing screens.
Reason: Supports constrained participants without introducing a separate admin or contractor UX.
Status: Accepted
Date: 2026-09-03

## DEC-032

Decision: Invitations become assignable only after acceptance, and V1 assignments are limited to active members.
Reason: Avoids pending-member edge cases in task ownership and assignment flows.
Status: Accepted
Date: 2026-09-03

## DEC-033

Decision: At least one Owner must remain, final Owner removal is rejected, and removal preserves historical references while clearing future visits and active assignments.
Reason: Keeps the project administrable and preserves audit history.
Status: Accepted
Date: 2026-09-03

## DEC-034

Decision: Notification delivery is restrained and preference-driven, with in-app attention broader than push.
Reason: Prevents noisy alerts while keeping the product useful without notifications.
Status: Accepted
Date: 2026-09-03

## DEC-035

Decision: Apple Calendar task deadline sync applies only to the current user's assigned tasks, and category milestone sync applies only to active categories.
Reason: Keeps personal calendar sync bounded and predictable.
Status: Accepted
Date: 2026-09-03

## DEC-036

Decision: V1 uses a SwiftUI-first feature architecture with one NavigationStack per tab and a thin root shell.
Reason: Preserves tab context without a router framework or global store.
Status: Accepted
Date: 2026-09-03

## DEC-037

Decision: V1 uses a local SwiftData cache backed by Apple-managed CloudKit sync, with no custom backend.
Reason: Keeps the app Apple-native, offline-capable, and realistic for a small shared household project.
Status: Accepted
Date: 2026-09-03

## DEC-038

Decision: Apple ID / iCloud identity is the only V1 account layer, and email is only an invite transport.
Reason: Avoids a custom login system while keeping the project shareable across members.
Status: Accepted
Date: 2026-09-03

## DEC-039

Decision: Repository boundaries stay thin and aggregate-oriented, with concrete implementations in Data.
Reason: Protects domain logic without protocol sprawl.
Status: Accepted
Date: 2026-09-03

## DEC-040

Decision: Central rule engines own dependency, planning, budget, permission, notification, and calendar calculations.
Reason: Keeps derived truth centralized and testable.
Status: Accepted
Date: 2026-09-03

## DEC-041

Decision: V1 uses true .xlsx import/export behind an isolated Excel adapter, and Budget Line IDs are the stable round-trip key.
Reason: Controlled Excel flows need workbook fidelity without mixing spreadsheet logic into feature screens.
Status: Accepted
Date: 2026-09-03

## DEC-042

Decision: Attachment bytes live outside the database as local files or asset blobs, while the database stores metadata and references.
Reason: Keeps records small and preserves private media separately from domain state.
Status: Accepted
Date: 2026-09-03

## DEC-043

Decision: Apple Calendar sync is per-user and personal, with event references stored as integration state rather than shared project data.
Reason: Calendar access is a private device capability, not a shared apartment database.
Status: Accepted
Date: 2026-09-03

## DEC-044

Decision: V1 supports offline read and edit, and sync is opportunistic with deterministic per-record reconciliation and no manual merge UI.
Reason: Simple offline behavior is enough for a small household app and keeps conflict handling bounded.
Status: Accepted
Date: 2026-09-03

## DEC-045

Decision: V1 notifications are local-first, and remote push infrastructure is deferred.
Reason: Keeps the first version reliable without standing up notification backend plumbing.
Status: Accepted
Date: 2026-09-03

## DEC-046

Decision: Global add and push-vs-sheet routing are owned by the root shell: detail screens push, creation and edit flows use sheets, and category date editing starts with a sheet.
Reason: Produces a consistent native iOS navigation model.
Status: Accepted
Date: 2026-09-03

## DEC-047

Decision: One GitHub Actions macOS workflow remains the canonical native verification path, and build tasks must stay small.
Reason: Keeps verification simple and reviewable while the app is still small.
Status: Accepted
Date: 2026-09-03

## DEC-048

Decision: Third-party dependencies require a documented risk-reduction case and must stay behind adapters, and generated artifacts are not committed.
Reason: Prevents speculative complexity and keeps the repository clean.
Status: Accepted
Date: 2026-09-03

## DEC-049

Decision: Project data is private to members, receipts and photos are not public, and secrets or API keys stay out of the repo.
Reason: Establishes the minimum privacy and secret-handling baseline for V1.
Status: Accepted
Date: 2026-09-03

## DEC-050

Decision: Migration discipline starts once persistent data matters; early shell work may reset.
Reason: Avoids overengineering migrations before there is real data to protect.
Status: Accepted
Date: 2026-09-03

## DEC-051

Decision: The build sequence starts at APP-BUILD-01_DOMAIN_MODEL_AND_SAMPLE_DATA_FOUNDATION; BUILD-00 is only added if the shell layout later needs adjustment.
Reason: The current repo already has the shell, so the next controlled build should start with domain data and sample data.
Status: Accepted
Date: 2026-09-03
