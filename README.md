# Apartment Planner

Task 00 established the repository shell. TECH-01 now defines the technical architecture and build sequence before feature implementation begins.

Current stage:

- SwiftUI application shell only
- five-tab navigation scaffold
- centralized design tokens
- canonical terminology for core enums
- minimal unit test target
- no third-party dependencies yet
- architecture, data-model, and decision docs now describe the implementation contract

## Open and build

1. Open `ApartmentPlanner.xcodeproj` in Xcode.
2. Build the `ApartmentPlanner` scheme.
3. Run the `ApartmentPlannerTests` test target.

## Repository structure

- `App/` - app entry point, root navigation state, shell view composition, and future global add routing
- `Core/Models/` - canonical application terminology and shared value types
- `Core/Rules/` - future pure rule engines
- `Core/Services/` - shared services, sample data, and mapping helpers
- `Core/DesignSystem/` - centralized colors, spacing, corner radius, and typography
- `Features/Home/` - home tab composition and feature-local state
- `Features/Tasks/` - tasks tab composition and task flows
- `Features/Plan/` - plan tab composition and planning surfaces
- `Features/Budget/` - budget tab composition, shopping, and expense flows
- `Features/Calendar/` - calendar tab composition and visit flows
- `Data/` - persistence, repositories, and migrations
- `Integrations/` - Apple Calendar, Excel, and notification adapters
- `docs/` - product spec, architecture, data-model, and decision log

## Architecture rules

- One source of truth for each concept.
- Keep business logic out of SwiftUI views.
- Keep directories shallow.
- Prefer Apple-native frameworks.
- Do not add infrastructure before it is approved.
- Keep repositories thin and aggregate-oriented.

## Where to start

1. `docs/ARCHITECTURE.md`
2. `docs/DATA_MODEL.md`
3. `docs/DECISIONS.md`
4. `docs/PRODUCT_SPEC.md`
5. `App/RootView.swift`

## Testing

The repository uses one primary unit test target for shell and terminology checks. Future tests should stay focused on high-risk rules, mappers, and repository integration, and avoid duplicate UI coverage or snapshot noise.

## Native verification

Development may occur from Windows/VS Code, but native iOS compilation and XCTest require Apple's toolchain. GitHub Actions is the canonical macOS build and test path; macOS/Xcode developers can run the same `xcodebuild` checks locally.

## Git workflow

- Keep Task 00 and TECH-01 changes intentional and bounded.
- Do not commit generated build output, IDE state, secrets, or temp files.
- Preserve unrelated work if the worktree is dirty.
- Treat superseded code as history, not as a parallel implementation.
