# Product Specification

This document is the canonical V1 navigation and screen contract for Apartment Planner. It defines user-visible behavior only. It does not define storage, sync, parsing, or engine implementation.

## 1. Product Purpose

Apartment Planner is a native iPhone app for remembering apartment work, capturing it quickly, and helping the user see what matters without managing a traditional project-management system. V1 presents one active apartment project in the UI. Future multi-project support may exist in architecture, but it is not a V1 UX requirement.

## 2. V1 Scope

- V1 covers navigation, screen ownership, and surface boundaries.
- Exactly five primary tabs exist: Home, Tasks, Plan, Budget, and Calendar.
- There are no permanent tabs for Shopping, Categories, People, Settings, Dependencies, Expenses, Profile, or Excel.
- Shopping, Expenses, Excel import/export, People, Permissions, Settings, Notifications, and Apple Calendar settings are contextual surfaces.
- Later tasks own persistence, planning logic, budget logic, calendar sync, notifications, authentication, and backend concerns.

## 3. Navigation Model

- Native iOS patterns only: `TabView`, `NavigationStack`, `sheet`, `confirmation dialog`, `context menu`, and `swipe actions`.
- Push navigation is for drill-down detail.
- Sheets are for quick create or edit flows.
- The global add action is always available or highly accessible and defaults to Add Task.
- Back navigation preserves tab, filter, selected category, selected date, and scroll context where practical.
- No custom router framework is required for V1.

## 4. Global Interactions

- Global `+` default action: Add Task.
- Optional quick-create targets from the same entry point: Shopping item and Apartment visit.
- Quick Add Task is lightweight: Task title and Category are mandatory; Assignee and Estimated duration are useful optional fields; everything else sits behind Add details.
- While typing a task title, surface existing task suggestions to reduce duplicates and expose dependency candidates. Prefer text similarity, then same category, then relevant active or recent tasks, then other categories. No AI is required.
- Errors stay in context. Loading uses a native progress indicator, with skeletons only where materially useful.
- Visual language should stay warm, minimal, and home-oriented rather than dashboard-like.

## 5. Screen Inventory

These are user-visible surfaces. Some are sheets or states rather than full screens.

- Main tabs: Home, Tasks, Plan, Budget, Calendar.
- Task surfaces: Quick Add Task, Task Detail, Add Before / Add After, Task Search / Existing Task Suggestion.
- Category surfaces: Category Detail, Category Flow, Category Shopping.
- Plan surfaces: Plan Timeline, Plan This Week, Plan Schedule.
- Budget surfaces: Budget Overview, Category Budget Detail, Shopping, Add Shopping Item, Shopping Item Detail, Mark Purchased, Expenses, Add Expense, Expense Detail, Excel Import Select, Excel Import Preview, Excel Import Result / Error.
- Calendar surfaces: Calendar Day Detail, Add Apartment Visit.
- Project/profile surfaces: People, Invite Person, Member / Role Detail, Settings, Notifications, Apple Calendar Settings.
- Onboarding surfaces: Welcome, Project Setup, Invite During Onboarding, Optional Excel Import During Onboarding, Optional Calendar Permission, Optional Notification Permission, First Category Setup.

## 6. Home

- Purpose: Project overview at a glance.
- Entry points: Primary Home tab, return from details, onboarding completion.
- Primary information: project identity, current date, overall progress, needs attention, today at apartment, category cards, and the global add action.
- Primary actions: open category, open task, add task, add visit, open settings or profile entry point.
- Secondary actions: surface high-priority attention items and project or category shortcuts.
- Destination screens: Category Detail, Task Detail, Calendar, Quick Add Task, Settings.
- Does not own: full task filtering, full calendar, detailed budget ledger, or the complete dependency list.
- Contract notes: progress uses equal task weighting; needs attention should stay small, with roughly three prominent items at most; schedule warnings shown here come from the central planning rules, not a separate Home calculation; today at apartment shows person and time interval.

## 7. Tasks

- Purpose: answer what needs to be done.
- Entry points: Tasks tab, Home shortcut, category context, dependency flows.
- Primary information: vertical status board with In Progress, To Do, and Done; quick filters; task cards with scan-level metadata plus readiness and dependency badges where relevant.
- Primary actions: mark done, start, priority, more, open task detail, quick create task.
- Secondary actions: filter by All, Mine, High Priority, Blocked, Shopping, Category, Assignee, or Due.
- Destination screens: Task Detail, Quick Add Task, Add Before / Add After, Category Detail.
- Does not own: category timeline, complete project dashboard, budget ledger, or calendar presence.
- Contract notes: mobile layout is vertical, not desktop Kanban; Done may collapse when large; task detail is not required for simple completion or status change; readiness is derived separately from status; Time Critical may appear on Task cards and detail surfaces as a derived planning warning.

### 7.1 Canonical task concept

A Task is something that needs to be done as part of the apartment project. Each Task belongs to exactly one Project and one Category. It may have zero, one, or multiple assignees; zero or more prerequisites; and zero or more dependent tasks. Dependencies are optional planning information, not mandatory project structure.

### 7.2 Required and optional fields

Required:

- `task_id`
- `project_id`
- `category_id`
- `title`
- `status`
- `created_at`
- `created_by`

Quick Add requires only:

- Title
- Category

Optional:

- `description` / notes
- `estimated_duration_days`
- `due_date`
- `high_priority`
- `shopping_flag`
- `estimated_cost`
- `assignees`
- `attachments`

System-managed identifiers and timestamps remain automatic. `created_at` and `created_by` are the minimum creation-history fields the app must preserve.

### 7.3 Status lifecycle

V1 has exactly three user-managed statuses:

- To Do
- In Progress
- Done

Canonical internal terminology:

- `todo`
- `inProgress`
- `done`

Do not add Backlog, Cancelled, Waiting, Blocked, Ready, Review, Paused, or Archived as additional statuses. `Blocked` and `Ready` are derived task states, not user-managed statuses.

### 7.4 Readiness

Readiness is system-derived.

A non-Done task is `Ready` when it has no unfinished prerequisite tasks.

A non-Done task is `Blocked` when one or more prerequisite tasks are not Done.

`Ready` and `Blocked` must never be manually edited, and they must recalculate immediately after completion, reopening, dependency changes, or deletion.

The app should be able to show:

- `Waiting for: [Task]`
- `Waiting for 3 tasks`

Done tasks do not need a Ready/Blocked user-facing state. They remain visible as Done.

### 7.5 Quick Add

Quick Add must remain fast.

Mandatory user input:

- Title
- Category

Convenient quick fields:

- Assignee
- Estimated duration

Everything else remains under Add details.

Do not make due date, priority, dependencies, notes, shopping, cost, or photos mandatory.

Where appropriate, Quick Add should inherit context. From a category view, Category can default to that category. From a filtered personal task view, Assignee can default to the current user. These are defaults only; the user can change them before saving.

### 7.6 Duplicate suggestions

As the user types a task title, the app may surface similar existing tasks to prevent accidental duplicates, speed navigation, and expose dependency candidates.

Use deterministic fuzzy/text matching. AI is not required.

Suggested ranking intent:

1. text similarity
2. same category
3. active or non-archived relevance
4. unfinished task relevance
5. recently created or updated relevance
6. other categories

Suggestions must not prevent deliberate creation of a similar task. The user must be able to open an existing task or create anyway.

### 7.7 Assignment

A task supports zero, one, or multiple assignees.

Use the normal person relationship for multiple assignees. Do not store `Both` as a fake person.

Owners and Members may change task assignment. Limited users cannot reassign tasks.

Changing assignee must not:

- change task status
- remove dependencies
- change category
- automatically change priority

### 7.8 Duration, due date, priority, and shopping

Task duration is stored numerically in days.

Accepted examples:

- `0.25`
- `0.5`
- `1`
- `1.5`
- `2`
- `3`
- `5`

Estimated duration represents expected elapsed working time required for the task. Multiple assignees do not automatically reduce duration.

`due_date` is optional. A task may have no due date.

`high_priority` is a manual boolean and must remain manual. `shopping_flag` is also manual. `estimated_cost` is optional. When present, `estimated_duration_days` is a positive number of days. Time Critical is a derived planning warning, not a user-managed status, and may appear on Task cards and detail surfaces when the schedule requires attention.

These fields do not auto-change status, readiness, or dependencies. Shopping-flagged tasks remain normal tasks and use the same dependency rules. Shopping-specific details are audited more fully in DESIGN-04.

### 7.9 Completion, reopening, and deletion

Marking a task Done completes it.

Done tasks remain visible and retain their dependency history.

Editing a Done task is allowed. Editing does not automatically reopen the task.

Reopening a Done task returns it to `To Do` by default and recalculates readiness from current prerequisites. If prerequisites are still unfinished, the reopened task is Blocked.

Deletion does not add an undelete feature in V1.

Require stronger warning when the task has dependency relationships or is a shopping purchase with linked expense.

When a task is deleted, dependency links to and from it are removed, and any affected tasks recalculate readiness immediately.

### 7.10 Ordering and sequencing

Task ordering is deterministic and sequence-based. The user-facing ordering contract is the dependency graph, not a separate manual rank system.

Add Before and Add After reuse existing tasks.

Add Before means the selected task depends on the new task, so the new task comes first.

Add After means the new task depends on the selected task, so the selected task comes first.

There is no separate multi-task sequencing editor in V1.

### 7.11 Task history and state model

Task history must preserve creation metadata and enough status-transition history to know when a task was completed or reopened.

Stored state includes:

- status
- high_priority
- shopping_flag
- estimated_duration_days
- due_date
- dependencies
- assignees
- estimated_cost
- notes
- attachments

Derived state includes:

- Ready
- Blocked
- blocking count
- unblocked-after-completion
- must_start_by
- Time Critical
- blocking urgency

Do not persist duplicate copies of derived state unless later architecture proves a performance requirement. The product contract is a single source of truth.

### 7.12 Edge cases

At minimum, the following outcomes are accepted:

- Task with no assignee: valid and shown as Unassigned.
- Task with multiple assignees: valid.
- Task with no duration: valid.
- Task with no due date: valid.
- Task with no dependencies: Ready when not Done.
- Task with multiple prerequisites: Blocked until all prerequisites are Done.
- Task blocking multiple tasks: valid; dependents recalculate independently.
- Cross-category dependency: valid within the same project.
- Category move with dependencies: allowed; dependencies are preserved because they connect tasks inside the same project.
- Task reopened after dependent task started: dependent keeps its own status; readiness recalculates and may become Blocked again.
- Done task edited: allowed, and the task stays Done until explicitly reopened.
- Done task receives new dependency: allowed, and the task stays Done until explicitly reopened.
- Task with due date earlier than category target end: valid; the earlier due date tightens timing for that task.
- Task with no duration: valid and counted as a missing estimate, not zero.
- Task with missing duration on a required chain: planning may become Unknown until enough information exists.
- In Progress task can still be Time Critical.
- Deletion of blocking task: dependency links are removed and dependents recalculate.
- Duplicate dependency attempt: do not create a second identical edge.
- Direct cycle attempt: reject.
- Indirect cycle attempt: reject.
- Similar but intentionally duplicated task: allowed; suggestions are advisory only.

## 8. Categories

- Purpose: organize work by apartment area or workstream.
- Entry points: Home category cards, Tasks context or filtering, Plan timeline, Budget category view.
- Primary information: category identity, progress, dates, schedule health, remaining work, budget summary, category-specific tasks, category-specific shopping, and dependency flow.
- Primary actions: open category tasks, open flow, open shopping, create or add work from category context.
- Secondary actions: switch between Tasks, Flow, and Shopping views inside the category.
- Destination screens: Category Detail, Category Flow, Category Shopping, Task Detail, Shopping Item Detail, Category Budget Detail.
- Does not own: the complete project task board, all project shopping, all apartment visits, or settings.
- Contract notes: Category Tasks should surface In Progress, Ready Next, Blocked, Other To Do, and Done; Ready Next is a required concept and is the next Ready task surfaced by category order, not a separate status.

### 8.1 Planning fields

Each Category conceptually supports:

- `category_id`
- `project_id`
- `name`
- `icon`
- `planned_start_date`
- `target_end_date`
- `budget`
- `sort_order`
- `archived`

For DESIGN-03, the relevant planning fields are `planned_start_date` and `target_end_date`. Both may be optional.

`planned_start_date` means the date the user intends work in this Category to begin. It is a planning boundary only. It does not force the first task to start, does not block earlier work, and does not apply to every task automatically.

`target_end_date` means the date the user wants the Category completed. It is the principal deadline used in category schedule-health calculations. It does not automatically become every task's due date.

Reject `target_end_date < planned_start_date` with a simple validation message. Do not silently swap the dates.

### 8.2 Category progress

V1 progress remains:

`Done tasks / All tasks`

with equal task weighting.

Duration does not affect percentage completion.

If a Category contains zero Tasks, progress is `0%` and the UI should show an empty or neutral state, not 100%.

If a Category has at least one Task and every Task is Done, progress is `100%` and the Category can show `Complete`.

If a user adds a new unfinished Task to a previously complete Category, progress recalculates below 100% immediately.

### 8.3 Remaining workload and missing estimates

Category remaining workload is `SUM(estimated_duration_days)` for unfinished Tasks where duration is known.

A missing estimate is not zero.

Unknown-duration tasks are counted separately and should be surfaced as a count such as `3 tasks without estimates`.

Suggested presentation:

- `5.5+ days estimated work`
- `3 tasks without estimates`

Do not collapse known and unknown work into a single exact total when estimates are missing.

### 8.4 Dependency-chain timing

Use accepted prerequisite relationships from DESIGN-02.

For planning purposes, `A -> B` means `B` cannot be Ready until `A` is Done.

The planning engine must derive the longest remaining sequential path required to finish the Category by its deadline.

Completed tasks contribute `0` remaining duration.

Parallel branches use `max`, not sum.

Merged branches wait for all prerequisites; the longest prerequisite branch determines when the task becomes Ready.

External prerequisite tasks in other Categories are included only when they directly block tasks required for the current Category deadline.

If any required unfinished task on the relevant chain has no estimate, that chain is unknown unless known data already proves the Category is At Risk.

### 8.5 Schedule health

V1 uses exactly four schedule-health states for incomplete Categories:

- `On Track`
- `Tight`
- `At Risk`
- `Unknown`

Canonical internal terminology:

- `onTrack`
- `tight`
- `atRisk`
- `unknown`

A completed Category may instead show `Complete`; `Complete` is not a schedule-health state.

Schedule calculations use local calendar dates only.

Recommended canonical convention:

- `calendar_days_remaining = max(0, target_end_date - today)`
- `overdue_days = max(0, today - target_end_date)`

Weekends and public holidays do not change the calculation. V1 uses calendar days, not business days.

Health precedence for incomplete Categories:

1. If there is no `target_end_date`, health is `Unknown`.
2. If today is on or after `target_end_date` and any unfinished Task remains, health is `At Risk`.
3. If a required chain cannot be estimated because a required unfinished task has no duration, health is `Unknown` unless known information already proves `At Risk`.
4. Otherwise calculate:
   - `schedule_buffer_days = calendar_days_remaining - longest_known_remaining_chain_days`
   - `tight_threshold_days = max(1 day, 20% of longest_known_remaining_chain_days)`

Classification:

- `buffer < 0` -> `At Risk`
- `0 <= buffer < tight_threshold_days` -> `Tight`
- `buffer >= tight_threshold_days` -> `On Track`

Unknown must not hide a known failure.

### 8.6 Must-start-by and Time Critical

`must_start_by` means the latest date the Task should begin under the current dependency and duration plan to preserve the earliest applicable downstream deadline.

Users do not manually edit it.

A Task's earliest applicable downstream deadline is the earliest of:

- the Task's own due date, if any
- the Category target end date, if the Task belongs to that Category
- the `must_start_by` of any unfinished dependent Task

`must_start_by` is derived by subtracting the Task's remaining duration from that downstream deadline.

If the Task's remaining duration is unknown, `must_start_by` is unknown.

V1 does not track partial progress inside an In Progress Task, so an In Progress Task keeps its full remaining duration estimate.

A Task becomes `Time Critical` when:

- it is unfinished
- `must_start_by` is known
- local today is on or after `must_start_by`

Done Tasks are never Time Critical.

Blocked Tasks can still be Time Critical, but the UI should surface the blocking prerequisite first. The derived urgency may be shown as `Schedule critical` or similar wording instead of implying the task is immediately actionable.

Ready + Time Critical is a strong actionable warning.

In Progress + Time Critical is allowed and should remain visible.

### 8.7 Task due dates

Task due dates are local deadlines and can tighten planning ahead of the Category target end date.

If both a Task due date and a Category target end date exist, the earlier applicable deadline governs the Task's `must_start_by`.

If a Task has no due date, downstream dependency constraints and Category target end date supply the deadline when available.

If a Task has neither a due date nor a downstream deadline, it has no derived time-critical deadline.

### 8.8 Apartment Visits as a planning signal

Apartment Visits are project-level presence, not Category-specific capacity.

A calendar date with at least one Apartment Visit by a project member counts as one planned apartment day.

Multiple visits on the same date still count as one planned apartment day.

Multiple people present on the same date still count as one planned apartment day.

For a Category with a target end date, remaining planned apartment days are the number of distinct calendar dates from today through the target end date inclusive that have at least one Apartment Visit.

Visits after a Category deadline do not count toward that Category's remaining planned apartment days.

Past visits do not count toward remaining planned apartment days.

Apartment Visits provide context for planning. They do not directly override dependency-based health and they do not create a person-hour scheduler.

### 8.9 Stored versus derived planning fields

Stored:

- `planned_start_date`
- `target_end_date`
- `estimated_duration_days`
- `due_date`
- `status`
- `dependencies`
- `Apartment Visits`

Derived:

- `progress`
- `remaining workload`
- `missing estimate count`
- `calendar days remaining`
- `planned apartment days remaining`
- `longest remaining dependency chain`
- `schedule buffer`
- `schedule health`
- `must_start_by`
- `Time Critical`
- `blocking urgency`

Derived values must have one canonical calculation source later. The UI must not invent competing calculations.

### 8.10 Category edge cases

At minimum, the following outcomes are accepted:

- Category without dates: progress still works; schedule health is `Unknown`.
- Category with start but no target: schedule health is `Unknown`.
- Category with target but no start: schedule health can still be calculated.
- `target_end_date < planned_start_date`: reject.
- Empty Category: progress is `0%`.
- Completed Category: show `Complete` and `100%`.
- Overdue Category with unfinished tasks: `At Risk`.
- New Task added after completion: progress drops below 100% and planning recalculates immediately.
- All unfinished Tasks missing durations: schedule health is `Unknown` unless the deadline is already missed or the known chain already proves `At Risk`.
- Some Tasks missing durations: unrelated missing estimates do not force `Unknown`; missing estimates on the required chain may.
- Critical-chain Task missing duration: `must_start_by` is unknown and the Category may be `Unknown`.
- Independent Task missing duration: does not affect other independent chains, but it still appears in the missing estimate count.
- Parallel branches: use the longest branch, not the sum.
- Merged branches: all prerequisites must be Done.
- Cross-category dependency: valid and included when it directly blocks the current Category deadline.
- Cross-category blocker overdue: the blocked Category may become `At Risk`.
- Task due before Category end: the Task due date governs that Task.
- Task due after Category end: the Category target end still governs tasks in that Category.
- Independent Task due date: can create a derived `must_start_by` without any dependency chain.
- In Progress task on a critical chain: can still be Time Critical.
- Blocked task reaches latest-start date: show schedule urgency plus the blocking prerequisite.
- Reopened prerequisite: downstream readiness and planning recalculate immediately.
- Deleted dependency: downstream readiness and planning recalculate immediately.
- Changed duration or changed deadline: all derived planning values recalculate immediately.
- No Apartment Visits planned: the signal is simply `0` planned apartment days.
- Multiple people visit same day: count the date once.
- Visits after deadline: do not count toward that deadline.
- Project target without Category target: project target is informational only and does not change Category health.

## 9. Dependencies

- Purpose: express ordering without project-management jargon.
- Entry points: Task Detail, category sequencing interactions, Add Before / Add After.
- Primary information: Before this, Then, Waiting for, and dependency candidates.
- Primary actions: Add before, Add after, search existing task, create new task if needed, create dependency only when an existing task is selected.
- Secondary actions: multi-task sequencing is reserved for later category or task organization.
- Destination screens: Task Search / Existing Task Suggestion, Quick Add Task, Task Detail.
- Does not own: a standalone dependency engine UI or a separate dependency tab.
- Contract notes: the UI should use user-facing language such as Before this, Then, Waiting for, Add before, and Add after. Dependencies are optional planning information, not status.

### 9.1 Dependency model

A dependency is a single prerequisite relationship between two tasks in the same project. Categories may differ. V1 uses one dependency type only: task A must happen before task B. No advanced dependency types, soft links, or status-specific dependency variants are added in V1.

Each task may have zero or more prerequisites and zero or more dependent tasks.

### 9.2 Ready and blocked calculation

A non-Done task is Ready when all prerequisite tasks are Done.

A non-Done task is Blocked when one or more prerequisite tasks are not Done.

This calculation is derived from the dependency graph and must not be edited directly. Recalculate immediately when prerequisite status, dependency links, or task deletion changes.

### 9.3 Add Before and Add After

Add Before and Add After are sequencing shortcuts that create normal prerequisite links.

Add Before inserts a new task before the selected task. The selected task becomes dependent on the new task.

Add After inserts a new task after the selected task. The new task becomes dependent on the selected task.

These flows may search for an existing task or create a new one when needed. They are not a separate dependency type.

### 9.4 Validation and cycles

Dependency creation must be validated centrally.

Reject:

- self-dependencies
- duplicate dependency edges
- cross-project links
- direct cycles
- indirect cycles

Cross-category dependencies are valid.

### 9.5 Dependency deletion and dependent behavior

Removing a dependency link is allowed. If the removed link was the last unfinished prerequisite, the dependent task becomes Ready.

Deleting a task removes its dependency links to and from other tasks. Dependents recalculate readiness immediately.

Reopening a prerequisite can re-block dependents. It does not automatically change the dependents' own statuses; it only changes readiness.

A Done task can receive a new dependency link without reopening. The new dependency is stored for history and will matter if the task is reopened later.

### 9.6 Sequencing and presentation

Dependency relationships should be readable as order:

- Before this
- Then
- Waiting for

Task Detail should clearly distinguish the task that comes before from the task that comes next.

Large dependency lists should remain compact and expandable. Dependency management should stay secondary to completing actual work.

### 9.7 Implementation ownership

Deterministic dependency rules must be centralized conceptually under `Core/Rules/DependencyRules` or an equivalent future core rule engine. The UI must not embed its own competing dependency logic in Task Detail, Category, Home, or Plan.

## 10. Plan

- Purpose: answer whether everything fits into the planned time.
- Entry points: Plan tab, Home category shortcuts, category detail, project-level scheduling context.
- Primary information: category timeline, schedule health, category start and target end periods, workload context, dependency-driven timing context, and this-week planning context.
- Primary actions: inspect timeline, inspect this week, inspect schedule detail, open category detail.
- Secondary actions: move between Timeline, This Week, and Schedule views.
- Destination screens: Category Detail.
- Does not own: the full task board or budget ledger.
- Contract notes: Timeline is the default macro view; categories can overlap; schedule status must be derived centrally, not recalculated independently in the UI.

### 10.1 Plan Timeline

Plan Timeline is the default macro view.

Each Category row or bar shows, at minimum:

- Category name
- planned start date
- target end date
- progress
- schedule health

Categories may overlap.

The Timeline should remain readable on iPhone and does not need to expand into a full task tree by default.

Timeline scope may switch between Week, Month, and Full Project when useful.

Users can edit Category dates from the Timeline using either drag handles or a date-edit sheet. The contract requires easy date editing, not a specific gesture implementation.

Changing dates must recalculate timing data immediately, including schedule health, buffer, must-start-by, and Time Critical.

### 10.2 Plan This Week

Plan This Week answers what deserves attention now.

It should show:

- Apartment Visits
- Time Critical Tasks
- Upcoming due dates
- Category deadlines
- Relevant blocking tasks
- Schedule warnings

This Week is recommendation and context only. It does not auto-schedule every unfinished Task onto a day.

The UI may rank items deterministically using Ready, Time Critical, High Priority, Due soon, Blocks downstream Tasks, and Category schedule health. It must not silently modify tasks.

### 10.3 Plan Schedule

Plan Schedule is the deeper explanatory view.

It may show:

- Category deadline
- Calendar days remaining
- Known remaining workload
- Tasks missing estimates
- Longest remaining dependency chain
- Must-start-by Tasks
- Planned apartment days remaining
- Cross-category blockers
- Health explanation

Every schedule warning must be explainable with the numbers or blockers that caused it. The UI must not show an opaque health score.

Example explanation shape:

- `Bathroom - Tight`
- `Target: 12 Sep`
- `Known remaining work: 5.5+ days`
- `Longest dependent sequence: 4.5 days`
- `Calendar time remaining: 5 days`
- `Planned apartment days: 3`
- `Paint bathroom must start by: 8 Sep`
- `2 tasks have no estimate`

### 10.4 Planning ownership

Home, Category Detail, Tasks, and Calendar consume the central planning results. They do not calculate schedule health independently.

Plan owns the timeline, this-week view, schedule-health display, and schedule explanations. It is the only surface that presents schedule health directly.

Category Detail should expose progress, target, time remaining, known workload, schedule health, and optionally longest chain and missing estimates.

Task cards may display `Time Critical` when derived from central planning. `TasksView` must not recalculate it independently.

Calendar may surface task due dates, category milestones, and Apartment Visits for visibility, but Calendar is not responsible for schedule-health calculation.

## 11. Budget

- Purpose: answer what the project plans to spend, what it needs to buy, and what it has actually spent.
- Entry points: Budget tab, category budget links, shopping and expense flows, Excel import entry.
- Primary information: project budget, category budgets, budget lines, spent, remaining estimated, projected final cost, projected remaining or overrun, shopping list, and expense history.
- Primary actions: open overview, open shopping, add shopping item, mark purchased, add expense, import Excel budget.
- Secondary actions: open category budget detail, export budget data when supported.
- Destination screens: Category Budget Detail, Shopping, Add Shopping Item, Shopping Item Detail, Mark Purchased, Expenses, Add Expense, Expense Detail, Excel Import Select, Excel Import Preview, Excel Import Result / Error.
- Does not own: the full task experience or a separate shopping tab.
- Contract notes: Budget contains internal views Overview, Shopping, and Expenses; Shopping is not a sixth main tab. Budget Overview shows project budget, spent, remaining estimated, projected final cost, projected remaining or overrun, and category budget summaries. Category Budget Detail shows the category budget amount and the budget lines total for that category.

### 11.1 Budget hierarchy

V1 budget hierarchy is:

- Project budget
- Category budget
- Budget lines
- Expenses

Project budget is optional and stores `overall_budget_amount` and `currency` on the Project.

Currency is project-level, defaults to `DKK`, and is not separately editable on each task or expense in V1.

Category budget is optional and stores `category_budget_amount` on the Category.

Budget lines represent planned allocations inside a Category.

Expenses represent actual money spent.

### 11.2 Budget lines

Budget line fields:

- `budget_line_id`
- `project_id`
- `category_id`
- `name`
- `planned_amount`
- `notes`
- `source`
- `created_at`
- `updated_at`

Optional fields may include:

- `owner`
- `supplier_or_store`
- `target_purchase_date`

Budget line source supports:

- `manual`
- `excel_import`

Stable Budget Line IDs are mandatory for Excel round-tripping.

If the first imported Excel row has no ID, the app generates one and exports it on subsequent rounds.

Budget Line IDs must be stable, unique within Project, and used for re-import matching rather than row order.

A readable format such as `BUD-001` is recommended.

### 11.3 Expenses and actual spend

Expense fields:

- `expense_id`
- `project_id`
- `category_id`
- `budget_line_id` optional
- `shopping_item_id` optional
- `task_id` optional
- `description`
- `amount`
- `paid_by_user_id`
- `store`
- `expense_date`
- `receipt_attachment_id` optional
- `notes`
- `created_at`
- `created_by`
- `updated_at`

Category is required for V1 expenses.

Budget line is optional.

Actual spending must be recorded as Expense records, not by overwriting planned budget values.

Manual expenses may be created directly from Budget > Expenses and do not automatically create a Task.

Expense editing updates budget calculations immediately.

Deleting an Expense removes actual spend from the calculations.

If a deleted Expense is linked to a purchased Shopping Item, warn that the item remains purchased unless the user reopens it separately.

### 11.4 Budget calculations

Spent is:

- `SUM(expense.amount)`

For project scope, use all project expenses.

For category scope, filter by `category_id`.

For budget line scope, filter by `budget_line_id`.

Remaining estimated includes unfinished non-shopping Task estimated costs and unpurchased Shopping Item estimated prices.

When a Shopping Item and its linked Task both have estimates, use the Shopping Item estimate as the shopping-specific source of truth and do not double-count the task estimate.

Projected final cost is:

- actual spent
- plus remaining estimated

If a project budget exists, projected remaining or overrun is:

- project budget - projected final cost

If there is no project budget, show projected final cost without remaining or overrun.

Category projected cost is:

- category spent
- plus category remaining estimated

Budget line projected values show planned amount, spent, remaining estimated, projected total, and remaining or over budget.

Missing estimates are not zero and must be surfaced as incomplete projection information.

Over-budget warnings trigger when projected_final_cost exceeds the applicable budget amount, not only after actual spending already exceeds budget.

### 11.5 Budget edge cases

If no project budget exists, the UI may show category budgets total or budget lines total as planning totals, but each total must be labeled clearly.

If a category budget and its budget lines total differ, show both values and do not force equality.

Expenses without a budget line are valid and still count at category and project level.

Expenses without a category are invalid in V1.

A paid-by person who later leaves the project remains preserved historically on the Expense.

Receipt photos are optional and do not affect calculations.

No multi-currency conversion exists in V1.

## 12. Shopping

- Purpose: provide a wishlist-style purchase flow linked to project structure.
- Entry points: Budget > Shopping, category shopping views, purchase-related links.
- Primary information: item title, category, URL, notes, photo, quantity, estimated price, store, assigned buyer or buyers, priority, needed-by date, budget line, dependency or blocking relationship, and purchased status.
- Primary actions: add shopping item, open item detail, open product page, mark purchased.
- Secondary actions: filter by To Buy, Purchased, All, Mine, Priority, Blocking, and Category.
- Destination screens: Add Shopping Item, Shopping Item Detail, Mark Purchased, Category Shopping.
- Does not own: accounting, budget planning, or the main task board.
- Contract notes: item title and category are the only mandatory fields for basic entry. Shopping items are wishlist-style project items, not accounting records. Shopping-specific details and task lifecycle must not diverge.

### 12.1 Shopping item fields

Shopping item fields:

- `shopping_item_id`
- `project_id`
- `category_id`
- `linked_task_id` optional
- `budget_line_id` optional
- `title`
- `url`
- `notes`
- `image_attachment_id` optional
- `quantity`
- `estimated_price`
- `store`
- `assigned_buyer_user_ids`
- `high_priority`
- `needed_by_date`
- `purchased`
- `purchased_at`
- `purchased_by`
- `created_at`
- `created_by`
- `updated_at`

`title` and `category` are the only required user-facing fields.

`assigned_buyer_user_ids` may contain zero, one, or many people. Do not use a fake `Both` person.

`url`, `notes`, `image`, `quantity`, `estimated_price`, `store`, `budget_line`, and assigned buyers are optional.

Do not require automatic title extraction, automatic price extraction, or automatic image scraping from the URL.

Missing estimated price is not zero and should surface as an unknown estimate.

### 12.2 Shopping and task linkage

A Shopping Item may be represented as, or linked to, a Task when it needs task status, assignment, dependencies, or project progress.

Budget > Shopping > Add Item creates a Shopping Item and a linked Task with `shopping_flag = true`.

Quick Add Task with Shopping toggled on attaches shopping metadata so the item appears in Shopping.

The user experiences the item as one object, but the model keeps shopping metadata and task lifecycle distinct.

Marking or reopening the Shopping Item must not duplicate lifecycle state inconsistently.

### 12.3 Wishlist detail and primary actions

Shopping Item Detail shows:

- product image
- title
- category
- estimated price
- URL or Open product page
- notes
- quantity
- store
- assigned buyer
- priority
- needed by
- budget line
- dependency or blocking information
- purchase status

Primary actions are:

- Open product page
- Mark purchased
- Edit

Blocking purchases should be surfaced clearly from dependency state rather than maintained as a separate manual label.

Shopping dependency state comes from linked task dependencies.

### 12.4 Purchased lifecycle

Purchased equals Done for the linked shopping task.

Mark Purchased opens a lightweight purchase sheet.

Required purchase fields are:

- `paid_by`
- `purchase_date`

`actual_price` is optional at the moment of purchase.

If `actual_price` is entered, create or update an Expense with:

- category
- budget_line optional
- shopping_item_id
- linked_task_id
- description equal to the Shopping Item title
- amount equal to `actual_price`
- paid_by
- store
- expense_date equal to `purchase_date`
- receipt optional
- notes if present

If `actual_price` is omitted, mark the Shopping Item Purchased and the linked Task Done, but do not create a monetary Expense yet.

Surface missing actual price later in Budget or Expenses.

If a linked shopping task is marked Done from Tasks, open the purchase confirmation flow rather than silently completing the shopping state. The user may skip price entry, but the item still becomes Purchased and Done.

### 12.5 Reopen and delete behavior

Reopening a Purchased Shopping Item reopens the linked Task to To Do and sets purchased to false.

If an Expense already exists, prompt whether to Keep expense or Delete expense.

Keep expense is the default.

If the user deletes the linked Expense, the recorded cost disappears but the item remains purchased until the user explicitly reopens it.

Deleting a Shopping Item does not silently delete the linked Task. If a linked Task exists, the user should choose whether to keep the Task as a normal task or delete it as well.

Deleting an unlinked pure wishlist item simply removes the Shopping Item.

## 13. Expenses

- Purpose: record actual spend.
- Entry points: Budget > Expenses, mark purchased flow, budget detail.
- Primary information: recorded actual expenditure, manual expense creation, expense detail and edit access.
- Primary actions: add expense, open expense detail, edit expense.
- Secondary actions: none required for V1 beyond basic entry and review.
- Destination screens: Add Expense, Expense Detail.
- Does not own: shopping wishlist behavior or budget planning.
- Contract notes: not every expense should require a shopping item. Expense Detail stays a simple review and edit surface for the actual spend record, not accounting software. Expenses are the source of truth for actual spend.

### 13.1 Expense model

Expense fields:

- `expense_id`
- `project_id`
- `category_id`
- `budget_line_id` optional
- `shopping_item_id` optional
- `task_id` optional
- `description`
- `amount`
- `paid_by_user_id`
- `store`
- `expense_date`
- `receipt_attachment_id` optional
- `notes`
- `created_at`
- `created_by`
- `updated_at`

Category is required.

Budget line is optional.

Shopping item is optional.

Task is optional.

Manual expense creation from Budget > Expenses does not create a Task.

All amounts use the project currency.

`paid_by_user_id` defaults to the current user.

### 13.2 Edit and delete behavior

Users may edit:

- description
- amount
- category
- budget line
- paid by
- store
- date
- notes
- receipt

Editing updates budget calculations immediately.

Editing an Expense does not change Task status unless the user is explicitly undoing a purchase.

Deleting an Expense removes actual spending from budget calculations.

If the Expense is linked to a purchased Shopping Item, warn that the item remains purchased unless reopened separately.

No automatic reopen of the Shopping Item occurs when deleting an Expense.

### 13.3 Paid by and receipt

Paid by is informational only; no settlement is required in V1.

If a payer later leaves the project, preserve the historical reference on the Expense.

Receipt photos are optional.

Receipt photos do not affect calculations.

No OCR is performed in V1.

## 14. Excel

- Purpose: controlled import and export entry within Budget.
- Entry points: Budget > More or Import.
- Primary information: workbook selection, validation, preview changes, new or unknown category resolution, import result or error.
- Primary actions: select workbook, validate, preview, resolve categories, apply import, retry on error.
- Secondary actions: export entry if supported.
- Destination screens: Excel Import Select, Excel Import Preview, Excel Import Result / Error.
- Does not own: live synchronization.
- Contract notes: Excel is controlled import/export, not a real-time synced spreadsheet integration. V1 uses a standard budget template. Budget Plan is the round-trip sheet; other sheets are reporting only. Excel import modifies Budget Lines and may create Categories; it does not import Tasks, Shopping Items, Expenses, Visits, People, or Dependencies.
- Required flow: Select workbook -> Validate -> Preview changes -> Resolve new or unknown categories -> Apply -> Result or Error.

### 14.1 Template and required columns

Budget Plan columns:

- `Budget Line ID`
- `Category`
- `Budget Item`
- `Planned Amount`
- `Notes`

Optional columns may include:

- `Owner`
- `Supplier / Store`
- `Target Purchase Date`

Minimum required import columns:

- `Category`
- `Budget Item`
- `Planned Amount`

`Budget Line ID` may be blank on first import.

If `Budget Line ID` is missing, generate a stable ID and include it on future export.

Do not require complex workbook formatting.

### 14.2 Validation and preview

Validate:

- required columns exist
- planned amount is numeric
- category is not blank
- budget item is not blank
- duplicate Budget Line IDs
- invalid dates in optional date columns

Invalid rows should be shown in preview or error state.

Do not partially import invalid data silently.

If Excel contains Category names that do not yet exist, preview should show the new categories and allow the user to create them automatically with confirmation or map them manually.

Before applying import, show summary:

- new budget lines
- updated budget lines
- unchanged budget lines
- new categories
- validation warnings or errors
- total planned amount

### 14.3 Matching and re-import

Primary matching key:

- `Budget Line ID`

If the ID matches an existing Budget Line:

- update the existing line

If the ID is blank:

- create a new ID and a new Budget Line

If the ID exists but is unknown:

- treat it as a new imported Budget Line
- flag it in preview

Do not match primarily by row order.

Re-import may update:

- name
- category
- planned amount
- notes
- optional owner
- optional store
- optional date

If a previously imported Budget Line is absent from re-import, do not automatically delete it. Show it as not present in import and leave it unchanged unless the user explicitly archives or deletes it later.

### 14.4 Export and round-trip

Excel export may produce sheets conceptually including:

- Overview
- Budget Plan
- Expenses
- Shopping
- Tasks
- Categories
- Dependencies
- Visits
- People

The key round-trip sheet is Budget Plan.

Only Budget Plan is importable in V1.

Budget Plan export must include stable `Budget Line ID` and the import-compatible columns.

Export may be broader than import.

Because V1 is not live sync, conflicts are resolved during import preview. There is no background merge engine.

## 15. Calendar

- Purpose: answer who will be at the apartment and what project dates matter.
- Entry points: Calendar tab, Home today section, project and task shortcuts, Apple Calendar settings.
- Primary information: shared in-app apartment calendar, apartment visits, project date visibility, and Apple Calendar sync entry.
- Primary actions: inspect a day, add visit, open Apple Calendar settings.
- Secondary actions: distinguish apartment presence from project dates.
- Destination screens: Calendar Day Detail, Add Apartment Visit, Apple Calendar Settings.
- Does not own: the Plan timeline or scheduling engine.
- Contract notes: Calendar remains distinct from Plan, and the shared in-app calendar is the source of truth for apartment presence. Apartment Visits are a planning signal, not capacity; a date with at least one visit counts as one planned apartment day, and multiple visits on the same date count once. Calendar may surface task due dates, category target end dates, category start dates, and important milestones for visibility, but it must not calculate schedule health or dependency timing.
- Calendar Day Detail separates "At the apartment" from "Project" so attendance and project milestones stay visually distinct.
- Calendar Day Detail primary action is `+ Add visit`.
- Add Apartment Visit is the fast path for the current user and uses inferred identity with fields for Date, From, Until, and Add to Apple Calendar.

### 15.1 Apartment Visit model

An Apartment Visit represents planned presence at the apartment.

It is shared within the app.

It is not a task.

It is not an expense.

It is not a calendar sync record.

Conceptual fields:

- `visit_id`
- `project_id`
- `user_id`
- `start_datetime`
- `end_datetime`
- `note`
- `created_at`
- `created_by`
- `updated_at`

Optional future field:

- `apple_calendar_event_id`

Required:

- `user_id`
- `start_datetime`
- `end_datetime`

Reject `end_datetime <= start_datetime`.

Do not silently reverse times.

A Visit may cross midnight if the user intentionally enters it, but V1 UI should not optimize for overnight visits.

Owners may create, edit, and delete any Visit.

Members may create, edit, and delete their own Visits.

Limited users may create, edit, and delete their own Visits only.

Editing a Visit updates planning signals and personal Apple Calendar sync if enabled.

Deleting a Visit removes it from the shared in-app Calendar and updates planning signals.

If synced to Apple Calendar for that user, the app should attempt to remove or update the corresponding Apple event.

If Apple Calendar removal fails, the in-app Visit deletion still succeeds and the user is warned.

### 15.2 Apple Calendar sync

Apple Calendar sync is optional and personal.

The app remains the source of truth.

Apple Calendar is not used as the shared project database.

Do not rely on Apple Calendar to share Visits between users.

Per user settings:

- `sync_apartment_visits`
- `sync_task_deadlines`
- `sync_category_milestones`
- `selected_calendar_identifier`

Recommended V1 defaults after permission:

- Apartment Visits = on
- Task deadlines = off
- Category milestones = off

If permission is denied:

- shared in-app Calendar remains fully usable
- Add Visit still works
- the Apple Calendar toggle is disabled or explains permission is required
- Settings shows a route to enable permission in iOS Settings

Do not block project-calendar functionality.

A synced Apple Calendar event belongs only to the user whose device/account created it.

If Julia syncs her visits, Lucas does not automatically get Apple Calendar events unless Lucas enables his own sync.

When a synced Visit changes:

- update the corresponding Apple Calendar event for the syncing user where possible
- if update fails, keep the in-app Visit as source of truth
- surface a sync warning
- do not create duplicate Apple Calendar events for the same Visit update

When a synced Visit is deleted:

- remove the corresponding Apple Calendar event where possible
- if removal fails, keep the in-app deletion
- surface a sync warning

Task deadline sync is off by default.

If enabled, only tasks assigned to the current user sync to Apple Calendar.

Category milestone sync is off by default.

If enabled, sync category target end dates for active categories only.

Do not sync every category start date by default unless later explicitly enabled.

### 15.3 Calendar edge cases

At minimum, the following outcomes are accepted:

- visit end before start: reject
- visit crosses midnight: valid
- delete synced visit: in-app deletion succeeds; Apple event removal is attempted; warn if removal fails
- Apple Calendar permission denied: in-app calendar still works; toggle is disabled or explained
- Apple Calendar update fails: in-app change still succeeds; warn
- task deadline sync disabled: no task deadline events are created
- task deadline sync enabled: only the current user's assigned tasks sync
- category milestone sync enabled: sync active categories only
- same day multiple visits: count the date once
- same day multiple users: count the date once
- removed member future visits: remove or cancel them during removal confirmation; past visits remain historical

## 16. People

- Purpose: show project members and roles.
- Entry points: Project or profile menu, Settings.
- Primary information: member name, avatar, role.
- Primary actions: invite person, open member or role detail.
- Secondary actions: none required for V1 beyond role inspection.
- Destination screens: Invite Person, Member / Role Detail.
- Does not own: a main tab or task management. It does include a concise permission matrix rather than a separate admin surface.
- Contract notes: People is contextual, not permanent navigation.
- Project members use conceptual fields: `project_id`, `user_id`, `role`, `joined_at`, `invited_by`, and `status`.
- Status values: `active`, `invited`, `removed`, `left`.
- Invite Person is the add-member flow from the people area.
- Member / Role Detail shows the member's role and permission scope without turning into a matrix UI.

### 16.1 Roles

V1 roles:

- Owner
- Member
- Limited

Do not add Admin, Viewer, Contractor, Guest, or Editor as separate roles in V1.

Limited can later cover contractor or family use cases.

### 16.2 Permission matrix

| Action | Owner | Member | Limited |
| --- | --- | --- | --- |
| View project | Full | Full | Filtered/shared only |
| Edit project settings | Yes | No | No |
| Invite members | Yes | No | No |
| Change roles | Yes | No | No |
| Remove members | Yes | No | No |
| Create category | Yes | No | No |
| Edit category | Yes | No | No |
| Delete category | Yes | No | No |
| Create task | Yes | Yes | No |
| Edit any task | Yes | Yes | No |
| Edit assigned task | Yes | Yes | Assigned-task only |
| Delete task | Yes | Yes | No |
| Complete task | Yes | Yes | Assigned-task only |
| Reopen task | Yes | Yes | Assigned-task only |
| Assign task | Yes | Yes | No |
| Manage dependencies | Yes | Yes | Assigned-task only |
| Create/edit/delete shopping item | Yes | Yes | No |
| Mark purchased | Yes | Yes | Assigned shopping only |
| Create/edit/delete expense | Yes | Yes | Own purchase-linked only |
| View budget | Yes | Yes | No by default |
| Edit budget lines | Yes | Yes | No |
| Import/export Excel | Yes | Yes | No |
| Add/edit/delete own visit | Yes | Yes | Yes |
| Edit/delete others' visits | Yes | No | No |
| Configure own notifications | Yes | Yes | Yes |
| Configure own Apple Calendar | Yes | Yes | Yes |

Permission eligibility is derived from role, ownership, and assignment state. It is not stored as a separate user-editable field.

### 16.3 Invite flow

Entry:

`People -> Invite Person`

V1 invite fields:

- `email`
- `role`
- optional message

Default role:

- Member

Do not default invitees to Owner.

An invited person may appear as `Invited` until they accept.

Tasks may be assigned only to active members. Invited users become assignable after accepting.

If the same email is invited again while a pending invite already exists, do not create a duplicate pending member. Surface the existing invite instead.

### 16.4 Member removal and leaving

Owners may remove Members and Limited users.

At least one Owner must remain, and an Owner cannot remove the final Owner.

If removing someone with assigned tasks, expenses, or future visits, preserve historical data.

Historical `created_by`, `paid_by`, and task status history remain intact after removal.

Future visits for a removed member are removed during removal confirmation.

Past visits remain historical.

Active assignments to removed or left users are cleared and shown as Unassigned unless they were reassigned before removal.

If the member leaves instead of being removed, the same historical retention rules apply.

Reject final Owner removal with a clear explanation.

### 16.5 Role change

Owner may change a member's role.

Rules:

- cannot remove or change the final Owner in a way that leaves no Owner
- changing role does not alter historical data
- changing role may alter future visibility and actions

An Owner should not be able to demote themselves if they are the sole Owner.

If multiple Owners exist, self-demotion is allowed with confirmation.

### 16.6 Limited user behavior

Limited role is included in V1 permission logic, but its UI may reuse filtered versions of existing screens.

Limited users should focus on:

- assigned tasks
- assigned shopping
- their visits
- relevant due dates

Limited users can:

- see tasks assigned to them
- see task details for assigned tasks
- update status on assigned tasks
- add notes or photos to assigned tasks
- see visits relevant to them
- add and edit their own Visits
- see shopping items assigned to them
- mark assigned shopping items purchased
- record purchase-linked expense details for assigned purchases when that flow is enabled

Limited users cannot:

- see the full budget by default
- import or export Excel
- edit categories
- invite people
- change roles
- delete project data
- manage standalone expenses
- see all project tasks unless explicitly shared

### 16.7 People edge cases

At minimum, the following outcomes are accepted:

- invite same email twice: reuse the existing pending invite instead of creating a duplicate
- invite already active member: reject and show that the person is already a member
- remove member with assigned tasks: preserve history and clear active assignments unless reassigned first
- remove member with expenses: preserve expense history
- remove member with future visits: remove future visits during removal confirmation
- remove final Owner: reject
- member leaves with assigned tasks: treat the same as removal for active assignments
- role changed from Member to Limited: future visibility narrows; historical data remains
- role changed from Limited to Member: future visibility expands; historical data remains
- `paid_by` references removed user: retain the historical reference and label it as inactive or former member where needed
- `created_by` references removed user: retain the historical reference and label it as inactive or former member where needed

## 17. Settings

- Purpose: hold personal and project settings.
- Entry points: profile avatar or project menu.
- Primary information: My Profile, Notifications, Calendar Sync, optional Appearance, and project settings entry where appropriate.
- Primary actions: edit profile, configure notifications, configure calendar sync.
- Secondary actions: open related settings sub-screens.
- Destination screens: Notifications, Apple Calendar Settings.
- Does not own: a dedicated settings tab.
- Contract notes: settings are contextual and lightweight. Notifications and Apple Calendar sync are personal settings, and owners cannot control another user's notification or Apple Calendar settings.

### 17.1 Notification preferences

Notifications are personal.

Each user controls their own notification preferences.

Notification eligibility is derived from the user's preferences, quiet hours, and the event type; it is not stored as a separate state.

V1 settings groups:

- Tasks
- Planning
- Apartment
- Budget

During onboarding, ask only `Enable notifications?`

Do not ask a long list of granular questions during onboarding.

If notifications are enabled, use sensible defaults:

- Task assigned to me = on
- High-priority task assigned to me = on
- Task due soon = on
- Blocked task becomes ready = on
- Time-critical assigned task = on
- Category deadline warning = on
- Apartment visit added = off
- Budget warning = off

Support personal quiet hours.

Recommended default:

- `08:00-21:00`

Notifications outside quiet hours should be delayed or suppressed according to later technical architecture.

Non-urgent apartment notifications should respect quiet hours.

There are no emergency notifications in V1.

### 17.2 Notification triggers

- Task assigned to me: trigger when a task is newly assigned to the current user. Do not notify if the user assigns a task to themselves. Do not notify for every edit to an already assigned task unless later explicitly enabled.
- High priority assigned: trigger when a task assigned to the user has `high_priority = true`, or when an already assigned task is newly marked High Priority. Avoid duplicate notification if the same action already produced a more specific one.
- Due soon: trigger for assigned tasks with due dates approaching. Default timing is 1 day before due date. Do not repeat every hour.
- Blocked task becomes ready: trigger when an assigned task changes derived readiness from Blocked to Ready because prerequisites were completed. Do not notify if the user has disabled planning or task-readiness notifications.
- Time-critical task: trigger when an assigned unfinished task becomes Time Critical. If the task is blocked, surface the blocker first where possible.
- Category deadline warning: trigger to Owners or Members when a Category becomes At Risk. Tight stays in-app by default, without a push notification.
- Apartment visit added: if enabled, notify when another user adds a Visit. Do not notify the user for their own Visit. Default off.
- Budget warning: if enabled, notify when projected cost crosses over budget. Do not notify repeatedly for every small edit after already over budget unless the crossing state changes.
- Purchase assigned: trigger when a Shopping Item is assigned to the current user as buyer. Do not notify if the user assigns it to themselves.

### 17.3 Notification delivery

Avoid duplicate notifications for the same event.

If the same action could generate multiple notices, send the more specific notification.

If many events happen at once, the app may aggregate them.

Not every in-app attention item becomes a push notification.

Home and Plan may show more warnings than push notifications.

Push notifications should be restrained and preference-driven.

### 17.4 Notification and permission edge cases

If iOS notification permission is denied:

- the app remains usable
- Settings explains that permission is needed
- in-app attention still works
- do not repeatedly nag for permission

If a user is removed from a project, they stop receiving future project notifications.

Limited users only receive notifications for assigned or explicitly shared work.

## 18. Onboarding

- Purpose: get the user to Home quickly without forcing every optional setup step.
- Entry points: first launch.
- Primary information: welcome, account or identity, project setup, project name and dates, invite people, optional Excel import, optional Apple Calendar connection, optional notifications, and first category setup.
- Primary actions: continue, skip optional steps, create the first project and category.
- Secondary actions: none required beyond the setup path.
- Destination screens: Home.
- Does not own: long mandatory configuration or setup bloat.
- Contract notes: onboarding should remain short and optional where possible.
- Preferred flow: Welcome -> Create account or identity -> Create apartment project -> Project name and dates -> Invite people -> Optional Excel import -> Optional Apple Calendar permission -> Optional notification permission -> First category setup -> Home.

## 19. Empty, Loading, and Error Behavior

- Home empty state: guide the user to create a category and add the first task.
- Tasks empty state: add your first task.
- Plan empty state: add start and target dates to categories.
- Budget empty state: create budget or import Excel budget.
- Shopping empty state: add shopping item.
- Calendar empty state: add apartment visit.
- Loading state: use a native progress indicator; use skeletons only where they add value.
- Error behavior: keep errors in context, such as Excel validation, permission denial, save failure, or network failure.

## 20. Navigation Rules

- Push navigation is for drill-down details such as Task Detail, Category Detail, Category Budget Detail, and Calendar Day Detail.
- Sheets are for quick create or edit flows such as Quick Add Task, Add Shopping Item, Add Expense, Add Apartment Visit, Mark Purchased, and Add Before / Add After.
- Context menus and swipe actions are for fast task and shopping actions.
- Back navigation should return to the prior tab or detail state with filters, selected category, selected date, and scroll context preserved where practical.
- Quick Add must return to the originating context, not always Home.
- The UI must not require a type picker before every task capture.
- Shopping, People, Settings, and Excel remain contextual surfaces, not permanent tabs.

## 21. Visual Language

- Direction: warm Scandinavian utility, earthy, minimal, home-oriented, and native-iOS-inspired.
- Use: warm cream or off-white, earthy olive, muted sage, ochre, clay or terracotta, near-black or warm brown typography, restrained borders, soft cards, and generous whitespace.
- Avoid: corporate dashboard styling, bright rainbow categories, heavy shadows, excessive gradients, Jira or Trello styling, and dense KPI grids.
- Status semantics must stay distinct: Done, In Progress, To Do, Blocked, High Priority, Time Critical, and schedule warnings are not interchangeable.
- High Priority is manually important; Time Critical is calculated from schedule.

## 22. Cross-screen Ownership Matrix

| Surface | Owns | Does not own |
| --- | --- | --- |
| Home | project identity, progress, attention items, today's apartment context, category cards, global add | full tasks, detailed timeline, budget ledger, full dependency list |
| Tasks | vertical status board, filters, task fast actions, readiness badges, time-critical badges, task detail entry | planning calculations, budget calculations, calendar logic, permission rules |
| Quick Add Task | lightweight task capture | long form creation, dependency engine, budget ledger |
| Task Detail | task-specific fields, status, notes, photos, order, cost, dependency links, must-start-by, Time Critical | global project dashboard, category timeline |
| Category Detail | category progress, dates, schedule health, remaining work, missing estimates, category task and shopping views | all-project task board, settings, full calendar |
| Category Flow | dependency visualization within a category | task board, budget totals, calendar |
| Plan | timeline, this week, schedule-health display, schedule explanations, central planning results | detailed task editing, shopping workflow, expense entry |
| Budget | overall budget, category budgets, budget lines, shopping, expenses, Excel entry | full task board, calendar presence |
| Shopping | wishlist purchase workflow and linked shopping metadata | accounting, full task board, project scheduling |
| Expenses | actual spend records, manual entry, paid-by and receipt tracking | shopping wishlist, task dependencies |
| Excel | controlled budget import, validation, and round-trip matching | live sync, task management, calendar presence |
| Calendar | shared apartment visits, day detail, project date visibility, Apple Calendar sync entry | plan timeline, shopping workflow, budget ledger, schedule-health calculation |
| People | members, roles, invites, filtered limited view | main navigation, task engine, budget engine |
| Settings | profile, notifications, calendar sync, personal preferences, project settings entry | main navigation, task engine, budget engine |
| Onboarding | create account, project, first category, optional integrations | long-term settings hub, feature editing flows |

## 23. Deferred / Out-of-scope Items

Not V1 requirements unless later added by an accepted decision:

- AI planning
- live Excel synchronization
- full accounting
- Splitwise-style settlement
- automatic receipt OCR
- automatic product scraping from shopping URLs
- multi-currency conversion
- advanced contractor portal
- desktop or web app
- multiple active projects in the UI
- advanced resource scheduling
- hour-by-hour labour optimization
- complex dependency types
- chat
- comments system
- full document management
- backend provider selection
- database provider selection
- authentication provider selection
- offline storage framework selection
- notification infrastructure selection
- image storage provider selection

## 24. Open Decisions

No material navigation, task, dependency, planning, budget, shopping, Excel, people, calendar, or notifications contradictions remain for V1.

Resolved contradictions:

- Shopping is a Budget sub-view, not a permanent main tab.
- Excel is controlled import and export, not live sync.
- Priority and schedule criticality are distinct concepts.
- Apple Calendar settings are per-user.
- Notification settings are per-user.
- Quick Add stays lightweight.
- Dependencies are optional and are represented as prerequisite links, not as statuses.
- Ready and Blocked are derived states, not user-managed statuses.
- Cross-category dependencies are valid within one project.
- Circular dependencies are rejected before save.
- The UI presents one active apartment in V1.
- AI is not required.
- Progress remains equal task weighting.
- Duration is for schedule and workload, not percentage progress.
- High Priority remains manual.
- Time Critical is derived.
- Blocked describes readiness, not status.
- Calendar is distinct from Plan.
- Apple Calendar is not a shared database.
- Calendar sync is personal.
- Owners cannot control another user’s notification or Apple Calendar settings.
- Visits inform planning but do not precisely schedule Tasks.
- Weekends count.
- Missing durations are not zero.
- Known failure overrides Unknown.
- Project target dates are informational unless a Category target exists.
- No person-level resource optimization exists.
- Budget lines are planned allocations; Expenses are actual spend.
- Shopping items are wishlist-style project items that can link to Tasks.
- Excel Budget Plan round-trips on stable Budget Line IDs.
- Paid-by is tracked without settlement.
- Receipt photos are supported without OCR.
- Limited role does not imply full project visibility.
- Limited role is included in V1 permission logic with filtered screens.
- At least one Owner remains.
- Final Owner removal is rejected.
- Invitees become assignable only after acceptance.
- Removed member future visits are removed during removal confirmation.
- Historical task and expense references remain after member removal.
- Notification triggers do not duplicate in-app attention.
- Tight does not necessarily push-notify.
- At Risk may push-notify if enabled.
- Push notifications are restrained and preference-driven.
- Task deadline sync applies only to the current user's assigned tasks.
- Category milestone sync applies only to active categories.

The remaining implementation choices are documented in `docs/ARCHITECTURE.md`, `docs/DATA_MODEL.md`, and `docs/DECISIONS.md`. They do not change the V1 product contract.
