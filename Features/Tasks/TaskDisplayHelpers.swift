import Foundation
import SwiftUI

enum TaskListFilter: String, CaseIterable, Identifiable {
    case all
    case mine
    case highPriority
    case blocked
    case shopping

    var id: String { rawValue }

    var title: String {
        switch self {
        case .all:
            return "All"
        case .mine:
            return "Mine"
        case .highPriority:
            return "High Priority"
        case .blocked:
            return "Blocked"
        case .shopping:
            return "Shopping"
        }
    }

    var iconName: String {
        switch self {
        case .all:
            return "tray.full"
        case .mine:
            return "person.fill"
        case .highPriority:
            return "flame.fill"
        case .blocked:
            return "exclamationmark.triangle.fill"
        case .shopping:
            return "cart.fill"
        }
    }
}

enum TaskSectionKind: Int, CaseIterable, Identifiable {
    case inProgress = 0
    case todo = 1
    case done = 2

    var id: Int { rawValue }

    var title: String {
        switch self {
        case .inProgress:
            return "In Progress"
        case .todo:
            return "To Do"
        case .done:
            return "Done"
        }
    }
}

enum TaskBadgeTone: Equatable {
    case neutral
    case accent
    case secondary
    case attention
    case warning

    var foregroundColor: Color {
        switch self {
        case .neutral:
            return .apartmentPlannerSecondaryText
        case .accent:
            return .apartmentPlannerPrimaryAccent
        case .secondary:
            return .apartmentPlannerSecondaryAccent
        case .attention:
            return .apartmentPlannerAttention
        case .warning:
            return .apartmentPlannerWarning
        }
    }

    var backgroundColor: Color {
        switch self {
        case .neutral:
            return Color.apartmentPlannerBorder.opacity(0.22)
        case .accent:
            return Color.apartmentPlannerPrimaryAccent.opacity(0.15)
        case .secondary:
            return Color.apartmentPlannerSecondaryAccent.opacity(0.15)
        case .attention:
            return Color.apartmentPlannerAttention.opacity(0.15)
        case .warning:
            return Color.apartmentPlannerWarning.opacity(0.15)
        }
    }
}

struct TaskReadinessDisplay: Equatable {
    let title: String
    let tone: TaskBadgeTone
    let blockerSummary: String?
}

struct TaskCardModel: Identifiable, Equatable {
    let id: UUID
    let title: String
    let categoryName: String
    let assigneeTitle: String
    let statusTitle: String
    let statusTone: TaskBadgeTone
    let estimatedDurationTitle: String?
    let isHighPriority: Bool
    let isShopping: Bool
    let readiness: TaskReadinessDisplay?
}

struct TaskSectionModel: Identifiable, Equatable {
    let kind: TaskSectionKind
    let cards: [TaskCardModel]

    var id: TaskSectionKind { kind }
}

struct TaskSuggestion: Identifiable, Equatable {
    let id: UUID
    let title: String
    let categoryName: String
}

enum TaskDisplayHelpers {
    static func statusTitle(for status: TaskStatus) -> String {
        switch status {
        case .todo:
            return "To Do"
        case .inProgress:
            return "In Progress"
        case .done:
            return "Done"
        }
    }

    static func statusTone(for status: TaskStatus) -> TaskBadgeTone {
        switch status {
        case .todo:
            return .neutral
        case .inProgress:
            return .accent
        case .done:
            return .secondary
        }
    }

    static func estimatedDurationTitle(for task: Task) -> String? {
        guard let estimatedDurationDays = task.estimatedDurationDays else {
            return nil
        }

        return estimatedDurationDays == 1 ? "1 day" : "\(estimatedDurationDays) days"
    }

    static func dueDateTitle(for task: Task) -> String? {
        guard let dueDate = task.dueDate else {
            return nil
        }

        return dueDate.formatted(.dateTime.month(.abbreviated).day().year())
    }

    static func categoryName(for categoryID: Category.ID, categories: [Category]) -> String {
        categories.first(where: { $0.id == categoryID })?.name ?? "Unknown category"
    }

    static func assigneeTitle(for task: Task, assignments: [TaskAssignment], users: [User]) -> String {
        let assignedUserIDs = Array(
            Set(assignments.filter { $0.taskId == task.id }.map(\.userId))
        )

        guard !assignedUserIDs.isEmpty else {
            return "Unassigned"
        }

        let userLookup = Dictionary(uniqueKeysWithValues: users.map { ($0.id, $0) })
        let userOrder = Dictionary(uniqueKeysWithValues: users.enumerated().map { ($1.id, $0) })

        let assignedUsers = assignedUserIDs.compactMap { userLookup[$0] }.sorted {
            (userOrder[$0.id] ?? Int.max) < (userOrder[$1.id] ?? Int.max)
        }

        let names = assignedUsers.map(\.displayName)
        guard !names.isEmpty else {
            return "Unknown user"
        }

        return names.count == 1 ? names[0] : names.joined(separator: " + ")
    }

    static func readinessDisplay(for readiness: DependencyRules.TaskReadiness?, tasks: [Task]) -> TaskReadinessDisplay? {
        guard let readiness else {
            return nil
        }

        switch readiness {
        case .done:
            return nil
        case .ready:
            return TaskReadinessDisplay(title: "Ready", tone: .accent, blockerSummary: nil)
        case .blocked(let blockerTaskIDs):
            return TaskReadinessDisplay(
                title: "Blocked",
                tone: .attention,
                blockerSummary: blockerSummary(for: blockerTaskIDs, tasks: tasks)
            )
        case .invalidPrerequisiteReferences(let missingTaskIDs):
            return TaskReadinessDisplay(
                title: "Blocked",
                tone: .warning,
                blockerSummary: blockerSummary(for: missingTaskIDs, tasks: tasks)
            )
        }
    }

    static func isBlockedReadiness(_ readiness: DependencyRules.TaskReadiness?) -> Bool {
        switch readiness {
        case .blocked, .invalidPrerequisiteReferences:
            return true
        case .ready, .done, .none:
            return false
        }
    }

    static func quickAddSuggestions(
        for title: String,
        selectedCategoryID: Category.ID?,
        tasks: [Task],
        categories: [Category],
        sourceOrderIndex: [Task.ID: Int]
    ) -> [TaskSuggestion] {
        let query = title.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        guard !query.isEmpty else {
            return []
        }

        let categoryLookup = Dictionary(uniqueKeysWithValues: categories.map { ($0.id, $0) })

        let matches = tasks.filter { task in
            let candidate = task.title.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
            return candidate.contains(query) || query.contains(candidate)
        }

        let sortedMatches = matches.sorted { lhs, rhs in
            let lhsSameCategory = selectedCategoryID.map { lhs.categoryId == $0 } ?? false
            let rhsSameCategory = selectedCategoryID.map { rhs.categoryId == $0 } ?? false
            if lhsSameCategory != rhsSameCategory {
                return lhsSameCategory && !rhsSameCategory
            }

            let lhsRank = suggestionRank(candidate: lhs.title, query: query)
            let rhsRank = suggestionRank(candidate: rhs.title, query: query)
            if lhsRank != rhsRank {
                return lhsRank < rhsRank
            }

            let lhsOrder = sourceOrderIndex[lhs.id] ?? Int.max
            let rhsOrder = sourceOrderIndex[rhs.id] ?? Int.max
            if lhsOrder != rhsOrder {
                return lhsOrder < rhsOrder
            }

            return lhs.title.localizedCaseInsensitiveCompare(rhs.title) == .orderedAscending
        }

        return sortedMatches.prefix(3).map { task in
            TaskSuggestion(
                id: task.id,
                title: task.title,
                categoryName: categoryLookup[task.categoryId]?.name ?? "Unknown category"
            )
        }
    }

    private static func blockerSummary(for taskIDs: [Task.ID], tasks: [Task]) -> String? {
        let taskLookup = Dictionary(tasks.map { ($0.id, $0) }, uniquingKeysWith: { first, _ in first })
        let titles = taskIDs.compactMap { taskLookup[$0]?.title ?? "Unknown task" }

        guard !titles.isEmpty else {
            return "Waiting for: Unknown task"
        }

        return "Waiting for: " + titles.joined(separator: ", ")
    }

    private static func suggestionRank(candidate: String, query: String) -> Int {
        let normalizedCandidate = candidate.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        if normalizedCandidate == query {
            return 0
        }

        if normalizedCandidate.contains(query) || query.contains(normalizedCandidate) {
            return 1
        }

        return 2
    }
}

struct TaskBadgeView: View {
    let title: String
    let tone: TaskBadgeTone

    var body: some View {
        Text(title)
            .font(ApartmentPlannerTypography.badge)
            .foregroundStyle(tone.foregroundColor)
            .lineLimit(1)
            .padding(.horizontal, ApartmentPlannerTheme.Spacing.md)
            .padding(.vertical, ApartmentPlannerTheme.Spacing.xs)
            .background(tone.backgroundColor, in: Capsule(style: .continuous))
            .overlay(
                Capsule(style: .continuous)
                    .stroke(tone.foregroundColor.opacity(0.16), lineWidth: 1)
            )
    }
}
