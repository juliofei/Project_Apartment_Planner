# Architecture

## Principles

- One source of truth for each application concept.
- Centralized business rules, not logic embedded in SwiftUI views.
- Thin views that display state and collect interaction.
- Clear feature boundaries.
- Shallow directories and simple file placement.
- No duplicate implementations.
- No speculative abstraction for features that do not exist yet.
- Minimal third-party dependencies.

## Dependency Direction

Allowed direction:

```text
Features -> Core
Features -> Data interfaces
Integrations -> Core contracts
```

Rules:

- Features must not depend on each other for domain logic.
- Views may consume shared design tokens and shared terminology from `Core`.
- Persistence lives under `Data`.
- External adapters live under `Integrations`.

## Ownership

- Task UI -> `Features/Tasks`
- Home UI -> `Features/Home`
- Planning UI -> `Features/Plan`
- Budget UI -> `Features/Budget`
- Calendar UI -> `Features/Calendar`
- Central navigation state -> `App`
- App shell and launch entry point -> `App`
- Task status and project role terminology -> `Core/Models`
- Design tokens -> `Core/DesignSystem`
- Future rules engines -> `Core/Rules`
- Future shared services -> `Core/Services`
- Persistence implementations -> `Data`
- Excel adapter -> `Integrations/Excel`
- Apple Calendar adapter -> `Integrations/AppleCalendar`
- Notification adapter -> `Integrations/Notifications`

## Current Scope

Task 00 intentionally stops at the shell:

- no task persistence
- no planning engine
- no budget engine
- no Excel integration
- no calendar integration
- no notification engine
- no authentication
- no backend

