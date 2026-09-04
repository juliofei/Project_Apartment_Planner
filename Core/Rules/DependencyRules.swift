import Foundation

enum DependencyRules {
    /// `taskId` depends on `dependsOnTaskId`, so the arrow points `dependsOnTaskId -> taskId`.
    struct DependencyEdge: Equatable {
        var taskId: Task.ID
        var dependsOnTaskId: Task.ID
    }

    /// Readiness is derived from the dependency graph, not stored on `Task`.
    enum TaskReadiness: Equatable {
        case done
        case ready
        case blocked(blockerTaskIDs: [Task.ID])
        case invalidPrerequisiteReferences(missingTaskIDs: [Task.ID])
    }

    enum DependencyValidationError: Error, Equatable {
        case missingTask(Task.ID)
        case missingDependencyTask(Task.ID)
        case selfDependency
        case duplicateDependency
        case cycleDetected
    }

    enum DependencyValidationResult: Equatable {
        case valid
        case invalid(DependencyValidationError)
    }

    enum DependencySequenceValidationError: Error, Equatable {
        case tooFewTasks
        case missingTask(Task.ID)
        case duplicateTaskInSequence(Task.ID)
        case cycleDetected
    }

    enum DependencySequenceValidationResult: Equatable {
        case valid
        case invalid(DependencySequenceValidationError)
    }

    static func readiness(for taskID: Task.ID, tasks: [Task], dependencies: [TaskDependency]) -> TaskReadiness? {
        let taskLookup = taskLookup(from: tasks)
        guard let task = taskLookup[taskID] else {
            return nil
        }

        // Done stays Done even if the graph is imperfect.
        if task.status == .done {
            return .done
        }

        let missingPrerequisiteTaskIDs = missingPrerequisiteTaskIDs(for: taskID, taskLookup: taskLookup, dependencies: dependencies)
        if !missingPrerequisiteTaskIDs.isEmpty {
            return .invalidPrerequisiteReferences(missingTaskIDs: missingPrerequisiteTaskIDs)
        }

        let blockerTaskIDs = directPrerequisiteTaskIDs(for: taskID, tasks: tasks, dependencies: dependencies).filter { prerequisiteTaskID in
            taskLookup[prerequisiteTaskID]?.status != .done
        }

        return blockerTaskIDs.isEmpty ? .ready : .blocked(blockerTaskIDs: blockerTaskIDs)
    }

    static func readinessMap(tasks: [Task], dependencies: [TaskDependency]) -> [Task.ID: TaskReadiness] {
        var readinessByTaskID: [Task.ID: TaskReadiness] = [:]
        for task in tasks where readinessByTaskID[task.id] == nil {
            if let readiness = readiness(for: task.id, tasks: tasks, dependencies: dependencies) {
                readinessByTaskID[task.id] = readiness
            }
        }

        return readinessByTaskID
    }

    static func directPrerequisiteTaskIDs(for taskID: Task.ID, tasks: [Task], dependencies: [TaskDependency]) -> [Task.ID] {
        let taskLookup = taskLookup(from: tasks)
        let taskOrder = taskOrderIndex(from: tasks)

        let prerequisiteTaskIDs = dependencies.compactMap { dependency -> Task.ID? in
            guard dependency.taskId == taskID, taskLookup[dependency.dependsOnTaskId] != nil else {
                return nil
            }

            return dependency.dependsOnTaskId
        }

        return orderedUniqueTaskIDs(prerequisiteTaskIDs, taskOrder: taskOrder)
    }

    static func directDependentTaskIDs(for taskID: Task.ID, tasks: [Task], dependencies: [TaskDependency]) -> [Task.ID] {
        let taskLookup = taskLookup(from: tasks)
        let taskOrder = taskOrderIndex(from: tasks)

        let dependentTaskIDs = dependencies.compactMap { dependency -> Task.ID? in
            guard dependency.dependsOnTaskId == taskID, taskLookup[dependency.taskId] != nil else {
                return nil
            }

            return dependency.taskId
        }

        return orderedUniqueTaskIDs(dependentTaskIDs, taskOrder: taskOrder)
    }

    static func validateDependency(taskID: Task.ID, dependsOnTaskID: Task.ID, tasks: [Task], dependencies: [TaskDependency]) -> DependencyValidationResult {
        let taskLookup = taskLookup(from: tasks)

        guard taskLookup[taskID] != nil else {
            return .invalid(.missingTask(taskID))
        }

        guard taskLookup[dependsOnTaskID] != nil else {
            return .invalid(.missingDependencyTask(dependsOnTaskID))
        }

        guard taskID != dependsOnTaskID else {
            return .invalid(.selfDependency)
        }

        guard !dependencyExists(taskID: taskID, dependsOnTaskID: dependsOnTaskID, dependencies: dependencies) else {
            return .invalid(.duplicateDependency)
        }

        let graph = dependencyGraph(from: dependencies, validTaskIDs: Set(taskLookup.keys))
        // A new edge `dependsOnTaskID -> taskID` is only valid if `taskID` cannot already reach `dependsOnTaskID`.
        guard !pathExists(from: taskID, to: dependsOnTaskID, graph: graph) else {
            return .invalid(.cycleDetected)
        }

        return .valid
    }

    /// Add Before inserts a prerequisite in front of the current task: `beforeTaskID -> currentTaskID`.
    static func dependencyEdgeForAddBefore(
        currentTaskID: Task.ID,
        beforeTaskID: Task.ID,
        tasks: [Task],
        dependencies: [TaskDependency]
    ) -> Result<DependencyEdge, DependencyValidationError> {
        switch validateDependency(taskID: currentTaskID, dependsOnTaskID: beforeTaskID, tasks: tasks, dependencies: dependencies) {
        case .valid:
            return .success(DependencyEdge(taskId: currentTaskID, dependsOnTaskId: beforeTaskID))
        case .invalid(let error):
            return .failure(error)
        }
    }

    /// Add After makes the new follow-up depend on the current task: `currentTaskID -> afterTaskID`.
    static func dependencyEdgeForAddAfter(
        currentTaskID: Task.ID,
        afterTaskID: Task.ID,
        tasks: [Task],
        dependencies: [TaskDependency]
    ) -> Result<DependencyEdge, DependencyValidationError> {
        switch validateDependency(taskID: afterTaskID, dependsOnTaskID: currentTaskID, tasks: tasks, dependencies: dependencies) {
        case .valid:
            return .success(DependencyEdge(taskId: afterTaskID, dependsOnTaskId: currentTaskID))
        case .invalid(let error):
            return .failure(error)
        }
    }

    /// Removing `A -> B` changes readiness for `B`; future callers can widen this if they need transitive refreshes.
    static func affectedTaskIDsWhenRemovingDependency(_ dependency: TaskDependency) -> [Task.ID] {
        [dependency.taskId]
    }

    static func validateDependencySequence(
        taskIDs: [Task.ID],
        tasks: [Task],
        dependencies: [TaskDependency]
    ) -> DependencySequenceValidationResult {
        switch dependencyEdgesToCreate(forSequence: taskIDs, tasks: tasks, dependencies: dependencies) {
        case .success:
            return .valid
        case .failure(let error):
            return .invalid(error)
        }
    }

    /// The sequence is validated as one operation so later edges see the earlier edges in the same chain.
    static func dependencyEdgesToCreate(
        forSequence taskIDs: [Task.ID],
        tasks: [Task],
        dependencies: [TaskDependency]
    ) -> Result<[DependencyEdge], DependencySequenceValidationError> {
        let taskLookup = taskLookup(from: tasks)

        guard taskIDs.count >= 2 else {
            return .failure(.tooFewTasks)
        }

        for taskID in taskIDs {
            guard taskLookup[taskID] != nil else {
                return .failure(.missingTask(taskID))
            }
        }

        var seenTaskIDs = Set<Task.ID>()
        for taskID in taskIDs {
            guard seenTaskIDs.insert(taskID).inserted else {
                return .failure(.duplicateTaskInSequence(taskID))
            }
        }

        var graph = dependencyGraph(from: dependencies, validTaskIDs: Set(taskLookup.keys))
        var edgesToCreate: [DependencyEdge] = []

        for index in 0..<(taskIDs.count - 1) {
            let prerequisiteTaskID = taskIDs[index]
            let dependentTaskID = taskIDs[index + 1]

            if pathExists(from: dependentTaskID, to: prerequisiteTaskID, graph: graph) {
                return .failure(.cycleDetected)
            }

            if !dependencyExists(taskID: dependentTaskID, dependsOnTaskID: prerequisiteTaskID, dependencies: dependencies) {
                edgesToCreate.append(DependencyEdge(taskId: dependentTaskID, dependsOnTaskId: prerequisiteTaskID))
            }

            var dependents = graph[prerequisiteTaskID, default: []]
            dependents.insert(dependentTaskID)
            graph[prerequisiteTaskID] = dependents
        }

        return .success(edgesToCreate)
    }

    /// Used by sample-data validation and future import checks.
    static func graphContainsCycle(tasks: [Task], dependencies: [TaskDependency]) -> Bool {
        let taskLookup = taskLookup(from: tasks)
        let graph = dependencyGraph(from: dependencies, validTaskIDs: Set(taskLookup.keys))

        var visitState: [Task.ID: VisitState] = [:]
        for task in tasks {
            if hasCycle(from: task.id, graph: graph, visitState: &visitState) {
                return true
            }
        }

        return false
    }

    private enum VisitState {
        case visiting
        case visited
    }

    private static func taskLookup(from tasks: [Task]) -> [Task.ID: Task] {
        var lookup: [Task.ID: Task] = [:]
        for task in tasks where lookup[task.id] == nil {
            lookup[task.id] = task
        }

        return lookup
    }

    private static func taskOrderIndex(from tasks: [Task]) -> [Task.ID: Int] {
        var order: [Task.ID: Int] = [:]
        for (index, task) in tasks.enumerated() where order[task.id] == nil {
            order[task.id] = index
        }

        return order
    }

    private static func orderedUniqueTaskIDs(_ taskIDs: [Task.ID], taskOrder: [Task.ID: Int]) -> [Task.ID] {
        var seen = Set<Task.ID>()
        let uniqueTaskIDs = taskIDs.filter { seen.insert($0).inserted }

        return uniqueTaskIDs.sorted { lhs, rhs in
            (taskOrder[lhs] ?? Int.max) < (taskOrder[rhs] ?? Int.max)
        }
    }

    private static func missingPrerequisiteTaskIDs(
        for taskID: Task.ID,
        taskLookup: [Task.ID: Task],
        dependencies: [TaskDependency]
    ) -> [Task.ID] {
        var missingTaskIDs: [Task.ID] = []
        var seen = Set<Task.ID>()

        for dependency in dependencies where dependency.taskId == taskID {
            guard taskLookup[dependency.dependsOnTaskId] == nil else {
                continue
            }

            if seen.insert(dependency.dependsOnTaskId).inserted {
                missingTaskIDs.append(dependency.dependsOnTaskId)
            }
        }

        return missingTaskIDs
    }

    private static func dependencyExists(taskID: Task.ID, dependsOnTaskID: Task.ID, dependencies: [TaskDependency]) -> Bool {
        dependencies.contains { dependency in
            dependency.taskId == taskID && dependency.dependsOnTaskId == dependsOnTaskID
        }
    }

    private static func dependencyGraph(from dependencies: [TaskDependency], validTaskIDs: Set<Task.ID>) -> [Task.ID: Set<Task.ID>] {
        var graph: [Task.ID: Set<Task.ID>] = [:]
        for dependency in dependencies {
            guard validTaskIDs.contains(dependency.taskId), validTaskIDs.contains(dependency.dependsOnTaskId) else {
                continue
            }

            var dependents = graph[dependency.dependsOnTaskId, default: []]
            dependents.insert(dependency.taskId)
            graph[dependency.dependsOnTaskId] = dependents
        }

        return graph
    }

    private static func pathExists(from startTaskID: Task.ID, to targetTaskID: Task.ID, graph: [Task.ID: Set<Task.ID>]) -> Bool {
        if startTaskID == targetTaskID {
            return true
        }

        var visited = Set<Task.ID>()
        var stack = [startTaskID]

        while let currentTaskID = stack.popLast() {
            if !visited.insert(currentTaskID).inserted {
                continue
            }

            if currentTaskID == targetTaskID {
                return true
            }

            guard let dependentTaskIDs = graph[currentTaskID] else {
                continue
            }

            for dependentTaskID in dependentTaskIDs where !visited.contains(dependentTaskID) {
                stack.append(dependentTaskID)
            }
        }

        return false
    }

    private static func hasCycle(
        from taskID: Task.ID,
        graph: [Task.ID: Set<Task.ID>],
        visitState: inout [Task.ID: VisitState]
    ) -> Bool {
        switch visitState[taskID] {
        case .visiting:
            return true
        case .visited:
            return false
        case .none:
            break
        }

        visitState[taskID] = .visiting

        for dependentTaskID in graph[taskID, default: []] {
            if hasCycle(from: dependentTaskID, graph: graph, visitState: &visitState) {
                return true
            }
        }

        visitState[taskID] = .visited
        return false
    }
}
