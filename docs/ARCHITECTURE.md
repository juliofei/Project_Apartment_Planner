# Architecture

## 1. V1 Pattern

Apartment Planner uses a SwiftUI-first, feature-based architecture with centralized domain rules and repository-backed data access.

The current shell already matches the intended top-level shape:

- `TabView` for the five main tabs
- one `NavigationStack` per tab
- root tab state in `App/RootNavigationState.swift`
- shared shell composition in `App/RootView.swift` and `App/FeatureShellView.swift`

Keep the implementation small:

- no Redux-style global store
- no coordinator framework
- no broad dependency-injection container
- no business logic inside SwiftUI views
- no duplicate rule engines inside feature screens

Feature state should live close to the screen that uses it. Use local `@State` for simple interaction, and `@StateObject` or `@Observable` only when a flow needs state that must survive re-rendering or be shared across a screen.

## 2. Layering

```text
Views
-> Feature state / view models
-> Core models and rules
-> Repositories
-> Persistence and integrations
```

Rules:

- views display state and collect interaction
- feature state orchestrates a flow, but does not calculate domain truth
- core rules are pure and deterministic
- repositories translate between domain models and persistence records
- integrations stay behind adapters

If a rule can be tested without SwiftUI, it belongs in `Core/Rules`.

## 3. Folder Ownership

- `App/` - app entry point, bootstrap, root shell, global add routing, and tab state
- `Features/Home/` - home tab composition and feature-local state
- `Features/Tasks/` - tasks tab composition and task flows
- `Features/Plan/` - plan tab composition and planning surfaces
- `Features/Budget/` - budget tab composition, shopping, and expense flows
- `Features/Calendar/` - calendar tab composition and visit flows
- `Core/Models/` - shared identifiers, enums, and value types
- `Core/Rules/` - dependency, planning, budget, permission, notification, and calendar rules
- `Core/Services/` - shared services, sample data, and mapping helpers that are not persistence-specific
- `Core/DesignSystem/` - colors, spacing, corner radius, and typography
- `Data/Persistence/` - SwiftData models, stores, and migrations
- `Data/Repositories/` - concrete repository implementations
- `Integrations/Excel/` - Excel import/export adapter
- `Integrations/AppleCalendar/` - Apple Calendar adapter
- `Integrations/Notifications/` - notification adapter
- `Tests/` - rule tests, mapper tests, integration tests, and shell smoke tests

Keep the tree shallow. Do not add helper sprawl or duplicate root folders.

## 4. Persistence, Sync, and Backend

V1 uses Apple-managed CloudKit-backed persistence with a local SwiftData cache. There is no custom backend service.

- shared project data is the source of truth in the Apple-managed cloud-backed store
- the local device cache is the working copy and supports offline use
- project-scoped records live in the shared container
- user-scoped settings and integration state live in the private container or local settings layer
- the UI can present one active project at a time, but the model is not hard-coded to a single project forever
- offline read and edit are supported
- sync is opportunistic and background-driven; there is no manual sync UI in V1
- conflicts are resolved deterministically at the repository layer with last-write-wins behavior per record, with domain-specific merge only when trivial
- if a future backend replaces CloudKit, feature screens should not notice because the repository boundary stays stable

## 5. Identity and Membership

There is no separate app password or email-login system in V1. Apple ID / iCloud identity is the only account layer.

- users are identified by Apple account identity plus an app-managed `User` record
- Julia and Lucas are normal `User` and `ProjectMember` records, not hard-coded personas
- invites create pending `ProjectMember` records
- email can be used as invite transport, but it is not the authentication system
- an invited person becomes active only after accepting the project invite and signing in with an Apple identity

CloudKit sharing is the sync transport, not the permission model. Project roles are enforced by app data and rules.

## 6. Repository and Data Boundary

Repository boundaries should stay thin and aggregate-oriented.

- prefer one repository per domain aggregate or integration boundary, not one protocol per screen
- use a protocol only when it improves testability or there is a real chance of multiple implementations
- repositories should not hold business rules
- repositories read and write records, then map them to domain models
- concrete persistence code lives in `Data/Persistence`
- concrete repository code lives in `Data/Repositories`
- external adapter code lives in `Integrations`
- feature code may depend on a concrete repository when there is only one implementation

Likely repository groups:

- `ProjectRepository`
- `TaskRepository`
- `CategoryRepository`
- `BudgetRepository`
- `VisitRepository`
- `AttachmentRepository`
- `UserSettingsRepository`
- `ExcelImportRepository`

The exact names may change, but the grouping should not.

## 7. Rule Ownership

| Rule area | Owns | Notes |
| --- | --- | --- |
| DependencyRules | readiness, validation, duplicate rejection, cycle rejection, Add Before / Add After edge semantics, dependency removal consequences | single source of truth for task graph behavior in `Core/Rules/DependencyRules.swift` |
| PlanningRules | category progress, remaining workload, missing estimate warnings, longest remaining dependency chain, calendar days remaining, planned apartment days, schedule buffer, health classification, must-start-by, Time Critical, planning explanations | no screen should recalculate schedule health |
| BudgetRules | spent totals, remaining estimated, anti-double-counting, projected final cost, projected remaining / overrun, budget warnings, purchase-to-expense consequences, paid-by totals, missing estimate warnings | no screen should recalculate budget math |
| PermissionRules | can view project, can edit settings, can invite, role changes, member removal, category / task / budget / expense / visit access | role checks stay centralized |
| NotificationRules | eligibility, deduplication, quiet-hours handling, task assignment trigger, high-priority trigger, due-soon trigger, blocked-to-ready trigger, time-critical trigger, category risk trigger, budget warning trigger, purchase assigned trigger | notifications consume derived rule output |
| CalendarRules | visit validation, day grouping, Apple Calendar sync eligibility, event update / delete mapping, permission-denied behavior, sync-failure behavior | calendar UI displays results only |

If a derived value can be computed from domain state, it belongs here or in a pure helper under `Core/Rules`.

`Core/Rules/DependencyRules.swift` owns dependency graph validation, readiness derivation, direct relationship lookups, and edge-construction helpers.

## 8. UI Composition and Routing

- each main tab owns its own `NavigationStack` and preserves navigation state across tab switches
- the root shell owns the global add surface and passes the current tab plus selection context as a small value object
- the global add action defaults to Task and may also offer Shopping Item and Apartment Visit as quick targets
- detail screens for durable entities should push
- quick create and edit flows should use sheets

Recommended V1 routing:

- push: Task Detail, Category Detail, Category Budget Detail, Shopping Item Detail, Calendar Day Detail
- sheet: Add Task, Add Before / Add After, Add Shopping Item, Add Expense, Add Apartment Visit, Mark Purchased, Excel Import, Settings edit flows
- Expense Detail may push once the record exists; the creation flow should still use a sheet
- Category date editing should use a date-edit sheet first; drag handles are deferred

Empty-state copy belongs to the product spec, not the feature screen. Screens may consume shared constants, but they should not invent new product behavior.

## 9. Integrations

- Excel import/export should live in `Integrations/Excel` and should work with true `.xlsx` files, not CSV-only stand-ins
- validation and preview logic should stay in core domain code; the adapter should only parse and write workbooks
- Budget Line IDs must remain stable across round-trips
- Apple Calendar integration is personal and per-user; it stores the selected calendar and event references in user-scoped sync state
- notification delivery in V1 is local notification scheduling from derived rule output; remote push infrastructure is deferred
- attachment payloads should live outside the database as local files or asset blobs, while the database stores metadata and references

## 10. Testing and CI

Test the rules before the screens.

- domain rule unit tests: dependency, planning, budget, permission, notification, and calendar
- persistence integration tests: repository reads / writes and migration behavior once storage is real
- Excel mapper tests: import parsing, preview validation, stable Budget Line ID mapping, and export round-trip
- minimal shell smoke tests: tab order, navigation defaults, root state, and terminology
- avoid snapshot testing and UI automation by default

CI should use one GitHub Actions macOS workflow that builds the app and runs unit tests.

- do not add more workflows unless the repository grows enough to need them
- do not upload heavy artifacts by default
- keep native verification canonical even when local development happens on Windows

## 11. Safety, Dependencies, and Migrations

- project data is private to members
- receipts and photos are never public
- roles gate sensitive actions centrally
- no secrets or API keys are committed to the repository
- do not commit DerivedData, xcresult files, build logs, screenshots, temporary exports, or backup project files
- no third-party dependency unless it materially reduces risk or complexity and is recorded in `docs/DECISIONS.md` before use
- early schema work may reset during development, but once a build phase depends on persistent data, migrations must be explicit and documented

## 12. Sample Data

Use one central sample-data provider for previews and shell tests.

- keep sample data development-only
- reuse it across features instead of copying fixture data into each screen
- sample data is not production truth and should not leak into shipping migrations or runtime records
- the first provider lives at `Core/Services/SampleApartmentData.swift`

## 13. Build Sequence

`BUILD-00` is only needed if the shell layout has to change. The current repo does not need it.

Recommended build order:

1. `APP-BUILD-01_DOMAIN_MODEL_AND_SAMPLE_DATA_FOUNDATION`
2. `APP-BUILD-02_DEPENDENCY_RULES`
3. `APP-BUILD-03_TASK_UI_AND_TASK_LIFECYCLE`
4. `APP-BUILD-04_CATEGORY_UI_AND_CATEGORY_GROUPING`
5. `APP-BUILD-05_PLANNING_RULES_AND_PLAN_UI`
6. `APP-BUILD-06_BUDGET_RULES_AND_BUDGET_OVERVIEW`
7. `APP-BUILD-07_SHOPPING_LIFECYCLE`
8. `APP-BUILD-08_EXPENSES_AND_ATTACHMENTS`
9. `APP-BUILD-09_EXCEL_IMPORT_EXPORT`
10. `APP-BUILD-10_CALENDAR_AND_VISITS`
11. `APP-BUILD-11_PEOPLE_AND_PERMISSIONS`
12. `APP-BUILD-12_NOTIFICATIONS_AND_SETTINGS`
13. `APP-BUILD-13_ONBOARDING_AND_IDENTITY`
14. `APP-BUILD-14_INTEGRATION_POLISH`
15. `APP-BUILD-15_FINAL_QA_AND_RELEASE_READINESS`

The first actual feature implementation should start with `APP-BUILD-01_DOMAIN_MODEL_AND_SAMPLE_DATA_FOUNDATION`.

## 14. Build Task Standard

Every build task should state:

- objective
- scope
- files allowed to change
- files not allowed to change
- implementation rules
- tests required
- repository cleanliness checks
- native CI run requirement
- closure response
- status rules

Build tasks should stay small enough to review in one pass. No giant "build the whole app" task.

## 15. Implementation Gate

After TECH-01 is accepted, feature implementation may begin. Until then, only architecture, data-model, and decision-log work should change the repo.
