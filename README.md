# Apartment Planner

Task 00 establishes the repository baseline for a native iPhone apartment planning app.

Current stage:

- SwiftUI application shell only
- five-tab navigation scaffold
- centralized design tokens
- canonical terminology for core enums
- minimal unit test target
- no third-party dependencies

## Open and build

1. Open `ApartmentPlanner.xcodeproj` in Xcode.
2. Build the `ApartmentPlanner` scheme.
3. Run the `ApartmentPlannerTests` test target.

## Repository structure

- `App/` - app entry point, root navigation state, and shell view composition
- `Core/Models/` - canonical application terminology
- `Core/DesignSystem/` - centralized colors, spacing, corner radius, and typography
- `Features/Home/` - home tab placeholder
- `Features/Tasks/` - tasks tab placeholder
- `Features/Plan/` - plan tab placeholder
- `Features/Budget/` - budget tab placeholder
- `Features/Calendar/` - calendar tab placeholder
- `Data/` - reserved for future persistence and repository code
- `Integrations/` - reserved for future Apple Calendar, Excel, and notification adapters
- `docs/` - architecture, data-model, and decision log

## Architecture rules

- One source of truth for each concept.
- Keep business logic out of SwiftUI views.
- Keep directories shallow.
- Prefer Apple-native frameworks.
- Do not add infrastructure before it is approved.

## Where to start

1. `docs/ARCHITECTURE.md`
2. `docs/DATA_MODEL.md`
3. `App/RootView.swift`
4. `Core/DesignSystem/ApartmentPlannerTheme.swift`
5. `Core/Models/AppTab.swift`

## Testing

The repository uses one primary unit test target for shell and terminology checks. Future tests should stay focused on high-risk rules and avoid duplicate UI coverage.

## Native verification

Development may occur from Windows/VS Code, but native iOS compilation and XCTest require Apple's toolchain. GitHub Actions is the canonical macOS build and test path; macOS/Xcode developers can run the same `xcodebuild` checks locally.

## Git workflow

- Keep Task 00 changes intentional and bounded.
- Do not commit generated build output, IDE state, secrets, or temp files.
- Preserve unrelated work if the worktree is dirty.
- Treat superseded code as history, not as a parallel implementation.
