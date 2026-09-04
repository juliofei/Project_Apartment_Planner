import Foundation
import Combine

@MainActor
final class TaskListViewModel: ObservableObject {
    enum QuickAddValidationError: Equatable {
        case blankTitle
        case missingCategory

        var message: String {
            switch self {
            case .blankTitle:
                return "Title is required."
            case .missingCategory:
                return "Category is required."
            }
        }
    }

    @Published private(set) var tasks: [Task]
    @Published private(set) var taskAssignments: [TaskAssignment]

    private(set) var categories: [Category]
    private(set) var users: [User]
    private(set) var taskDependencies: [TaskDependency]

    let currentUser: User
    let projectID: Project.ID
    let projectName: String

    private let now: () -> Date
    private var sourceOrderIndex: [Task.ID: Int]
    private var nextSourceOrderIndex: Int

    init(dataset: SampleApartmentData.Dataset = SampleApartmentData.shared, now: @escaping () -> Date = Date.init) {
        tasks = dataset.tasks
        taskAssignments = dataset.taskAssignments
        categories = dataset.categories
        users = dataset.users
        taskDependencies = dataset.taskDependencies
        projectID = dataset.project.id
        projectName = dataset.project.name
        self.now = now
        sourceOrderIndex = Dictionary(uniqueKeysWithValues: dataset.tasks.enumerated().map { ($1.id, $0) })
        nextSourceOrderIndex = dataset.tasks.count

        guard let julia = dataset.users.first(where: { $0.displayName == "Julia" }) ?? dataset.users.first else {
            preconditionFailure("SampleApartmentData must provide at least one user.")
        }

        currentUser = julia
    }

    var activeTasks: [Task] {
        tasks.filter { !$0.archived }
    }

    var activeCategories: [Category] {
        categories
            .filter { !$0.archived }
            .sorted {
                if $0.sortOrder != $1.sortOrder {
                    return $0.sortOrder < $1.sortOrder
                }

                return $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending
            }
    }

    func task(for taskID: Task.ID) -> Task? {
        tasks.first(where: { $0.id == taskID })
    }

    func sections(for filter: TaskListFilter) -> [TaskSectionModel] {
        let filteredTasks = activeTasks.filter { matches(filter: filter, task: $0) }
        guard !filteredTasks.isEmpty else {
            return []
        }

        let groupedTasks = Dictionary(grouping: filteredTasks, by: { self.sectionKind(for: $0) })
        return TaskSectionKind.allCases.compactMap { sectionKind in
            guard let sectionTasks = groupedTasks[sectionKind] else {
                return nil
            }

            return TaskSectionModel(
                kind: sectionKind,
                cards: sectionTasks.sorted { self.sortTasks($0, $1) }.map { self.cardModel(for: $0) }
            )
        }
    }

    func cardModel(for task: Task) -> TaskCardModel {
        let readiness = readiness(for: task.id)
        return TaskCardModel(
            id: task.id,
            title: task.title,
            categoryName: TaskDisplayHelpers.categoryName(for: task.categoryId, categories: categories),
            assigneeTitle: TaskDisplayHelpers.assigneeTitle(for: task, assignments: taskAssignments, users: users),
            statusTitle: TaskDisplayHelpers.statusTitle(for: task.status),
            statusTone: TaskDisplayHelpers.statusTone(for: task.status),
            estimatedDurationTitle: TaskDisplayHelpers.estimatedDurationTitle(for: task),
            isHighPriority: task.highPriority,
            isShopping: task.shoppingFlag,
            readiness: TaskDisplayHelpers.readinessDisplay(for: readiness, tasks: tasks)
        )
    }

    func readiness(for taskID: Task.ID) -> DependencyRules.TaskReadiness? {
        DependencyRules.readiness(for: taskID, tasks: tasks, dependencies: taskDependencies)
    }

    func categoryName(for categoryID: Category.ID) -> String {
        TaskDisplayHelpers.categoryName(for: categoryID, categories: categories)
    }

    func assigneeDisplay(for task: Task) -> String {
        TaskDisplayHelpers.assigneeTitle(for: task, assignments: taskAssignments, users: users)
    }

    func directBlockerNames(for task: Task) -> [String] {
        switch readiness(for: task.id) {
        case .blocked(let blockerTaskIDs):
            return blockerTitles(for: blockerTaskIDs)
        case .invalidPrerequisiteReferences(let missingTaskIDs):
            let existingPrerequisiteIDs = DependencyRules.directPrerequisiteTaskIDs(
                for: task.id,
                tasks: tasks,
                dependencies: taskDependencies
            )

            let existingTitles = blockerTitles(for: existingPrerequisiteIDs)
            let missingTitles = missingTaskIDs.map { _ in "Unknown task" }
            return existingTitles + missingTitles
        case .ready, .done, .none:
            return []
        }
    }

    func quickAddSuggestions(for title: String, selectedCategoryID: Category.ID?) -> [TaskSuggestion] {
        TaskDisplayHelpers.quickAddSuggestions(
            for: title,
            selectedCategoryID: selectedCategoryID,
            tasks: activeTasks,
            categories: categories,
            sourceOrderIndex: sourceOrderIndex
        )
    }

    @discardableResult
    func addQuickTask(title: String, categoryID: Category.ID?, assigneeID: User.ID?) -> Result<Task, QuickAddValidationError> {
        let trimmedTitle = title.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedTitle.isEmpty else {
            return .failure(.blankTitle)
        }

        guard let categoryID, activeCategories.contains(where: { $0.id == categoryID }) else {
            return .failure(.missingCategory)
        }

        let timestamp = now()
        let task = Task(
            id: UUID(),
            projectId: projectID,
            categoryId: categoryID,
            title: trimmedTitle,
            notes: nil,
            status: .todo,
            estimatedDurationDays: nil,
            dueDate: nil,
            highPriority: false,
            shoppingFlag: false,
            estimatedCost: nil,
            createdAt: timestamp,
            createdByUserId: currentUser.id,
            updatedAt: timestamp,
            completedAt: nil,
            completedByUserId: nil,
            archived: false
        )

        tasks.append(task)
        sourceOrderIndex[task.id] = nextSourceOrderIndex
        nextSourceOrderIndex += 1

        if let assigneeID, users.contains(where: { $0.id == assigneeID }) {
            taskAssignments.append(
                TaskAssignment(
                    id: UUID(),
                    taskId: task.id,
                    userId: assigneeID
                )
            )
        }

        return .success(task)
    }

    func startTask(_ taskID: Task.ID) {
        updateTask(taskID) { task, timestamp in
            task.status = .inProgress
            task.updatedAt = timestamp
        }
    }

    func moveTaskToToDo(_ taskID: Task.ID) {
        updateTask(taskID) { task, timestamp in
            task.status = .todo
            task.updatedAt = timestamp
        }
    }

    func completeTask(_ taskID: Task.ID) {
        updateTask(taskID) { task, timestamp in
            task.status = .done
            task.completedAt = timestamp
            task.completedByUserId = currentUser.id
            task.updatedAt = timestamp
        }
    }

    func reopenTask(_ taskID: Task.ID) {
        updateTask(taskID) { task, timestamp in
            task.status = .todo
            task.completedAt = nil
            task.completedByUserId = nil
            task.updatedAt = timestamp
        }
    }

    private func updateTask(_ taskID: Task.ID, mutation: (inout Task, Date) -> Void) {
        guard let taskIndex = tasks.firstIndex(where: { $0.id == taskID }) else {
            return
        }

        let timestamp = now()
        mutation(&tasks[taskIndex], timestamp)
    }

    private func matches(filter: TaskListFilter, task: Task) -> Bool {
        switch filter {
        case .all:
            return true
        case .mine:
            return taskIsAssignedToCurrentUser(task)
        case .highPriority:
            return task.highPriority
        case .blocked:
            return TaskDisplayHelpers.isBlockedReadiness(readiness(for: task.id))
        case .shopping:
            return task.shoppingFlag
        }
    }

    private func taskIsAssignedToCurrentUser(_ task: Task) -> Bool {
        taskAssignments.contains { assignment in
            assignment.taskId == task.id && assignment.userId == currentUser.id
        }
    }

    private func sectionKind(for task: Task) -> TaskSectionKind {
        switch task.status {
        case .inProgress:
            return .inProgress
        case .todo:
            return .todo
        case .done:
            return .done
        }
    }

    private func sortTasks(_ lhs: Task, _ rhs: Task) -> Bool {
        if lhs.highPriority != rhs.highPriority {
            return lhs.highPriority && !rhs.highPriority
        }

        let lhsReadinessRank = readinessSortRank(for: lhs)
        let rhsReadinessRank = readinessSortRank(for: rhs)
        if lhsReadinessRank != rhsReadinessRank {
            return lhsReadinessRank < rhsReadinessRank
        }

        switch compareDueDates(lhs.dueDate, rhs.dueDate) {
        case .orderedAscending:
            return true
        case .orderedDescending:
            return false
        case .orderedSame:
            break
        }

        let lhsOrder = sourceOrderIndex[lhs.id] ?? Int.max
        let rhsOrder = sourceOrderIndex[rhs.id] ?? Int.max
        if lhsOrder != rhsOrder {
            return lhsOrder < rhsOrder
        }

        return lhs.title.localizedCaseInsensitiveCompare(rhs.title) == .orderedAscending
    }

    private func readinessSortRank(for task: Task) -> Int {
        switch readiness(for: task.id) {
        case .blocked, .invalidPrerequisiteReferences:
            return 0
        case .ready:
            return 1
        case .done:
            return 2
        case .none:
            return 3
        }
    }

    private func compareDueDates(_ lhs: Date?, _ rhs: Date?) -> ComparisonResult {
        switch (lhs, rhs) {
        case let (lhs?, rhs?):
            return lhs.compare(rhs)
        case (nil, nil):
            return .orderedSame
        case (nil, _?):
            return .orderedDescending
        case (_?, nil):
            return .orderedAscending
        }
    }

    private func blockerTitles(for taskIDs: [Task.ID]) -> [String] {
        let taskLookup = Dictionary(tasks.map { ($0.id, $0) }, uniquingKeysWith: { first, _ in first })
        return taskIDs.map { taskLookup[$0]?.title ?? "Unknown task" }
    }
}
