# Data Model

This document describes the intended V1 conceptual model only. It does not define a database schema or persistence technology.

| Entity | Purpose | Primary identity | Key relationships |
| --- | --- | --- | --- |
| Project | Top-level apartment planning container | `projectId` | Owns tasks, categories, budget lines, visits, members, and notifications |
| User | Person interacting with the project | `userId` | Participates in projects through `ProjectMember` |
| ProjectMember | Membership and project-specific permissions | Composite of project and user identity | Links a user to a project with a role |
| Category | Grouping for tasks and planning work | `categoryId` | Belongs to a project and groups tasks |
| Task | Canonical unit of work | `taskId` | Belongs to a project, may have assignment, dependencies, attachments, and shopping data |
| TaskAssignment | Assignment of a task to a project member | Composite assignment identity | Connects a task to a project member |
| TaskDependency | Ordering rule between tasks | Composite dependency identity | Connects one task to another task in the same project |
| ShoppingItem | Shopping-related work item | `shoppingItemId` | Belongs to a task or project and may later carry shopping details |
| BudgetLine | Planned budget bucket | `budgetLineId` | Belongs to a project and collects expenses |
| Expense | Actual spend record | `expenseId` | Belongs to a budget line or project |
| ApartmentVisit | Scheduled visit or inspection | `apartmentVisitId` | Belongs to a project and may later connect to calendar events |
| CalendarSync | External calendar synchronization state | `calendarSyncId` | Belongs to a project and tracks sync status |
| NotificationPreference | User or project notification settings | `notificationPreferenceId` | Belongs to a user and/or project depending on future scope |
| TaskAttachment | File or media attached to a task | `taskAttachmentId` | Belongs to a task |

## Canonical Notes

- `ShoppingItem` is the canonical term for shopping work. If later implementations need richer shopping metadata, that data should extend this entity instead of creating parallel concepts.
- `ProjectMember` is the canonical join between a user and a project.
- `TaskDependency` should remain a relationship between two tasks, not an ad hoc local rule in a view.
- Database table names, persistence keys, and sync schemas are intentionally undecided.

