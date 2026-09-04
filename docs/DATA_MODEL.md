# Data Model

This document describes the intended V1 conceptual model. It does not choose a schema technology or lock field names.

## 1. Model Scope

The model is split into shared project data, private user data, and integration state.

- shared project data covers the apartment project and its work
- private user data covers identity and personal preferences
- integration state covers external calendar, Excel, and attachment plumbing

Persistence may split one conceptual entity into multiple records if the chosen store needs it. The conceptual ownership does not change.

## 2. Entity Map

| Entity | Classification | Scope | Relationships / notes |
| --- | --- | --- | --- |
| Project | stored entity | shared project data | Root aggregate for one apartment project. Owns categories, tasks, shopping, budget lines, expenses, visits, and memberships. The UI may surface one active project at a time, but the store should not assume only one project can ever exist. |
| User | stored entity | private user identity | App-managed user profile keyed to the signed-in Apple account. Referenced by `ProjectMember`, `TaskAssignment`, `NotificationPreference`, and `CalendarSyncSetting`. |
| ProjectMember | join entity | shared project data | Connects a `User` to a `Project`. Stores role, status, joined_at, invited_by, and membership metadata. Pending invites become active members only after acceptance. |
| Category | stored entity | shared project data | Belongs to one `Project`. Owns the category name, icon, sort order, planning dates, and archive flag. |
| Task | stored entity | shared project data | Belongs to one `Project` and one `Category`. Stores lifecycle status, title, notes, due date, estimate, priority, shopping flag, cost estimate, and attachment references. Persist enough history to know when it was completed or reopened. |
| TaskAssignment | join entity | shared project data | Connects a `Task` to a `User`. Multiple assignees are represented by multiple rows; do not use a fake combined person. |
| TaskDependency | join entity | shared project data | Directed edge between two `Task` records in the same project. Stored as `taskId depends on dependsOnTaskId`, which means `dependsOnTaskId -> taskId`. The dependency graph is owned by `Core/Rules/DependencyRules.swift`. |
| ShoppingItem | stored entity | shared project data | Wishlist-style shopping work item. May belong to a project directly or be linked to a task when lifecycle behavior is needed. |
| BudgetLine | stored entity | shared project data | Planned budget bucket. Stable internal IDs are the canonical round-trip key for Excel import and export. |
| Expense | stored entity | shared project data | Actual spend record. May belong to a `BudgetLine`, reference a shopping purchase, and point to a receipt attachment. |
| ApartmentVisit | stored entity | shared project data | Project-level presence record and calendar signal. Calendar event IDs belong to integration state, not the domain concept itself. |
| NotificationPreference | integration state | private user data | Per-user notification group toggles, task/event switches, quiet hours, and delivery preferences. This is not shared project truth. |
| CalendarSyncSetting | integration state | private user data | Per-user calendar sync target, project linkage, and selected external calendar identifier. |
| Attachment | stored entity | shared project data | Metadata for photos and files attached to tasks, shopping items, expenses, or user profile records. The binary payload lives outside the database as a local file or asset blob. |

## 3. Relationship Rules

- `ProjectMember` is the canonical join between a user and a project.
- `TaskAssignment` is the canonical join between a task and a user.
- `TaskDependency` is a directed edge between tasks, not a local view-only rule.
- `TaskDependency.taskId` is the dependent task and `TaskDependency.dependsOnTaskId` is the prerequisite task.
- `ShoppingItem` may stay standalone or link to a task when it needs lifecycle or assignment behavior.
- `BudgetLine` should never be overwritten by actual spend; `Expense` records carry the real spend.
- `Attachment` metadata is shared, but the file bytes or asset payload are external.
- `NotificationPreference` and `CalendarSyncSetting` are user-scoped integration state, not shared project truth.
## 4. Derived Values

The following are derived outputs and should not be treated as authoritative source entities:

- Ready / Blocked
- schedule health
- must-start-by
- Time Critical
- projected final cost
- projected remaining / overrun
- permission eligibility
- notification eligibility
- Apple Calendar sync eligibility
- Excel matching and preview results

These values are owned by `Core/Rules` or by a pure helper that feeds those rules. They should not be persisted as the source of truth unless a later performance decision explicitly adds a cached copy.

## 5. Storage Notes

- IDs must stay stable across sync, import, export, and UI refreshes.
- Display names are not primary keys.
- Row order is not a persistence key.
- Deletions that must preserve history should clear active links rather than destroy the audit trail.
- The chosen persistence technology may reshape how records are stored, but it should not change these conceptual boundaries.
