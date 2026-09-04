import XCTest
@testable import ApartmentPlanner

final class DependencyRulesTests: XCTestCase {
    private let projectID = UUID()
    private let categoryID = UUID()
    private let userID = UUID()
    private let timestamp = Date(timeIntervalSince1970: 1_700_000_000)

    func testTaskWithNoPrerequisitesIsReady() {
        let taskID = UUID()
        let task = makeTask(id: taskID, status: .todo)

        let readiness = DependencyRules.readiness(for: taskID, tasks: [task], dependencies: [])

        XCTAssertEqual(readiness, .some(.ready))
    }

    func testDoneTaskIsDone() {
        let taskID = UUID()
        let task = makeTask(id: taskID, status: .done)

        let readiness = DependencyRules.readiness(for: taskID, tasks: [task], dependencies: [])

        XCTAssertEqual(readiness, .some(.done))
    }

    func testTaskBlockedByUnfinishedPrerequisite() {
        let prerequisiteID = UUID()
        let dependentID = UUID()
        let prerequisite = makeTask(id: prerequisiteID, status: .todo, title: "A")
        let dependent = makeTask(id: dependentID, status: .todo, title: "B")
        let dependency = makeDependency(taskID: dependentID, dependsOnTaskID: prerequisiteID)

        let readiness = DependencyRules.readiness(for: dependentID, tasks: [prerequisite, dependent], dependencies: [dependency])

        XCTAssertEqual(readiness, .some(.blocked(blockerTaskIDs: [prerequisiteID])))
    }

    func testTaskReadyWhenPrerequisiteIsDone() {
        let prerequisiteID = UUID()
        let dependentID = UUID()
        let prerequisite = makeTask(id: prerequisiteID, status: .done, title: "A")
        let dependent = makeTask(id: dependentID, status: .todo, title: "B")
        let dependency = makeDependency(taskID: dependentID, dependsOnTaskID: prerequisiteID)

        let readiness = DependencyRules.readiness(for: dependentID, tasks: [prerequisite, dependent], dependencies: [dependency])

        XCTAssertEqual(readiness, .some(.ready))
    }

    func testInProgressTaskCanBeBlocked() {
        let prerequisiteID = UUID()
        let dependentID = UUID()
        let prerequisite = makeTask(id: prerequisiteID, status: .todo, title: "A")
        let dependent = makeTask(id: dependentID, status: .inProgress, title: "B")
        let dependency = makeDependency(taskID: dependentID, dependsOnTaskID: prerequisiteID)

        let readiness = DependencyRules.readiness(for: dependentID, tasks: [prerequisite, dependent], dependencies: [dependency])

        XCTAssertEqual(readiness, .some(.blocked(blockerTaskIDs: [prerequisiteID])))
    }

    func testMultipleBlockers() {
        let prerequisiteAID = UUID()
        let prerequisiteBID = UUID()
        let dependentID = UUID()
        let prerequisiteA = makeTask(id: prerequisiteAID, status: .todo, title: "A")
        let prerequisiteB = makeTask(id: prerequisiteBID, status: .todo, title: "B")
        let dependent = makeTask(id: dependentID, status: .todo, title: "C")
        let dependencies = [
            makeDependency(taskID: dependentID, dependsOnTaskID: prerequisiteAID),
            makeDependency(taskID: dependentID, dependsOnTaskID: prerequisiteBID)
        ]

        let readiness = DependencyRules.readiness(for: dependentID, tasks: [prerequisiteA, prerequisiteB, dependent], dependencies: dependencies)

        XCTAssertEqual(readiness, .some(.blocked(blockerTaskIDs: [prerequisiteAID, prerequisiteBID])))
    }

    func testDirectPrerequisites() {
        let prerequisiteAID = UUID()
        let prerequisiteBID = UUID()
        let dependentID = UUID()
        let prerequisiteA = makeTask(id: prerequisiteAID, status: .todo, title: "A")
        let prerequisiteB = makeTask(id: prerequisiteBID, status: .todo, title: "B")
        let dependent = makeTask(id: dependentID, status: .todo, title: "C")
        let dependencies = [
            makeDependency(taskID: dependentID, dependsOnTaskID: prerequisiteAID),
            makeDependency(taskID: dependentID, dependsOnTaskID: prerequisiteBID)
        ]

        let prerequisites = DependencyRules.directPrerequisiteTaskIDs(for: dependentID, tasks: [prerequisiteA, prerequisiteB, dependent], dependencies: dependencies)

        XCTAssertEqual(prerequisites, [prerequisiteAID, prerequisiteBID])
    }

    func testDirectDependents() {
        let prerequisiteID = UUID()
        let dependentAID = UUID()
        let dependentBID = UUID()
        let prerequisite = makeTask(id: prerequisiteID, status: .todo, title: "A")
        let dependentA = makeTask(id: dependentAID, status: .todo, title: "B")
        let dependentB = makeTask(id: dependentBID, status: .todo, title: "C")
        let dependencies = [
            makeDependency(taskID: dependentAID, dependsOnTaskID: prerequisiteID),
            makeDependency(taskID: dependentBID, dependsOnTaskID: prerequisiteID)
        ]

        let dependents = DependencyRules.directDependentTaskIDs(for: prerequisiteID, tasks: [prerequisite, dependentA, dependentB], dependencies: dependencies)

        XCTAssertEqual(dependents, [dependentAID, dependentBID])
    }

    func testRejectSelfDependency() {
        let taskID = UUID()
        let task = makeTask(id: taskID, status: .todo)

        let result = DependencyRules.validateDependency(taskID: taskID, dependsOnTaskID: taskID, tasks: [task], dependencies: [])

        XCTAssertEqual(result, .invalid(.selfDependency))
    }

    func testRejectDuplicateDependency() {
        let prerequisiteID = UUID()
        let dependentID = UUID()
        let prerequisite = makeTask(id: prerequisiteID, status: .todo, title: "A")
        let dependent = makeTask(id: dependentID, status: .todo, title: "B")
        let dependency = makeDependency(taskID: dependentID, dependsOnTaskID: prerequisiteID)

        let result = DependencyRules.validateDependency(taskID: dependentID, dependsOnTaskID: prerequisiteID, tasks: [prerequisite, dependent], dependencies: [dependency])

        XCTAssertEqual(result, .invalid(.duplicateDependency))
    }

    func testRejectDirectCycle() {
        let prerequisiteID = UUID()
        let dependentID = UUID()
        let prerequisite = makeTask(id: prerequisiteID, status: .todo, title: "A")
        let dependent = makeTask(id: dependentID, status: .todo, title: "B")
        let dependency = makeDependency(taskID: dependentID, dependsOnTaskID: prerequisiteID)

        let result = DependencyRules.validateDependency(taskID: prerequisiteID, dependsOnTaskID: dependentID, tasks: [prerequisite, dependent], dependencies: [dependency])

        XCTAssertEqual(result, .invalid(.cycleDetected))
    }

    func testRejectIndirectCycle() {
        let aID = UUID()
        let bID = UUID()
        let cID = UUID()
        let dID = UUID()
        let a = makeTask(id: aID, status: .todo, title: "A")
        let b = makeTask(id: bID, status: .todo, title: "B")
        let c = makeTask(id: cID, status: .todo, title: "C")
        let d = makeTask(id: dID, status: .todo, title: "D")
        let dependencies = [
            makeDependency(taskID: bID, dependsOnTaskID: aID),
            makeDependency(taskID: cID, dependsOnTaskID: bID),
            makeDependency(taskID: dID, dependsOnTaskID: cID)
        ]

        let result = DependencyRules.validateDependency(taskID: aID, dependsOnTaskID: dID, tasks: [a, b, c, d], dependencies: dependencies)

        XCTAssertEqual(result, .invalid(.cycleDetected))
    }

    func testAddBeforeMapping() {
        let currentTaskID = UUID()
        let beforeTaskID = UUID()
        let currentTask = makeTask(id: currentTaskID, status: .todo, title: "Current")
        let beforeTask = makeTask(id: beforeTaskID, status: .todo, title: "Before")

        let result = DependencyRules.dependencyEdgeForAddBefore(
            currentTaskID: currentTaskID,
            beforeTaskID: beforeTaskID,
            tasks: [beforeTask, currentTask],
            dependencies: []
        )

        switch result {
        case .success(let edge):
            XCTAssertEqual(edge.taskId, currentTaskID)
            XCTAssertEqual(edge.dependsOnTaskId, beforeTaskID)
        case .failure(let error):
            XCTFail("Expected a valid add-before edge, got \(error)")
        }
    }

    func testAddAfterMapping() {
        let currentTaskID = UUID()
        let afterTaskID = UUID()
        let currentTask = makeTask(id: currentTaskID, status: .todo, title: "Current")
        let afterTask = makeTask(id: afterTaskID, status: .todo, title: "After")

        let result = DependencyRules.dependencyEdgeForAddAfter(
            currentTaskID: currentTaskID,
            afterTaskID: afterTaskID,
            tasks: [currentTask, afterTask],
            dependencies: []
        )

        switch result {
        case .success(let edge):
            XCTAssertEqual(edge.taskId, afterTaskID)
            XCTAssertEqual(edge.dependsOnTaskId, currentTaskID)
        case .failure(let error):
            XCTFail("Expected a valid add-after edge, got \(error)")
        }
    }

    func testSequenceCreatesMissingEdgesOnly() {
        let prepID = UUID()
        let paintID = UUID()
        let installID = UUID()
        let prep = makeTask(id: prepID, status: .todo, title: "Prep")
        let paint = makeTask(id: paintID, status: .todo, title: "Paint")
        let install = makeTask(id: installID, status: .todo, title: "Install")
        let existingDependency = makeDependency(taskID: paintID, dependsOnTaskID: prepID)

        let result = DependencyRules.dependencyEdgesToCreate(
            forSequence: [prepID, paintID, installID],
            tasks: [prep, paint, install],
            dependencies: [existingDependency]
        )

        switch result {
        case .success(let edges):
            XCTAssertEqual(edges.count, 1)
            XCTAssertEqual(edges.first?.taskId, installID)
            XCTAssertEqual(edges.first?.dependsOnTaskId, paintID)
        case .failure(let error):
            XCTFail("Expected a valid sequence, got \(error)")
        }
    }

    func testSequenceRejectsDuplicateTaskInInput() {
        let prepID = UUID()
        let paintID = UUID()
        let prep = makeTask(id: prepID, status: .todo, title: "Prep")
        let paint = makeTask(id: paintID, status: .todo, title: "Paint")

        let result = DependencyRules.validateDependencySequence(taskIDs: [prepID, paintID, prepID], tasks: [prep, paint], dependencies: [])

        XCTAssertEqual(result, .invalid(.duplicateTaskInSequence(prepID)))
    }

    func testSequenceRejectsCycle() {
        let aID = UUID()
        let bID = UUID()
        let cID = UUID()
        let a = makeTask(id: aID, status: .todo, title: "A")
        let b = makeTask(id: bID, status: .todo, title: "B")
        let c = makeTask(id: cID, status: .todo, title: "C")
        let existingDependency = makeDependency(taskID: aID, dependsOnTaskID: cID)

        let result = DependencyRules.validateDependencySequence(taskIDs: [aID, bID, cID], tasks: [a, b, c], dependencies: [existingDependency])

        XCTAssertEqual(result, .invalid(.cycleDetected))
    }

    func testSampleDataDependencyGraphIsValid() {
        let sample = SampleApartmentData.shared
        let taskIDs = Set(sample.tasks.map(\.id))
        var seenDependencies = Set<DependencyKey>()

        for dependency in sample.taskDependencies {
            XCTAssertTrue(taskIDs.contains(dependency.taskId))
            XCTAssertTrue(taskIDs.contains(dependency.dependsOnTaskId))
            XCTAssertNotEqual(dependency.taskId, dependency.dependsOnTaskId)
            XCTAssertTrue(seenDependencies.insert(DependencyKey(taskId: dependency.taskId, dependsOnTaskId: dependency.dependsOnTaskId)).inserted)
        }

        XCTAssertFalse(DependencyRules.graphContainsCycle(tasks: sample.tasks, dependencies: sample.taskDependencies))
    }

    private func makeTask(id: UUID, status: TaskStatus, title: String = "Task") -> Task {
        Task(
            id: id,
            projectId: projectID,
            categoryId: categoryID,
            title: title,
            notes: nil,
            status: status,
            estimatedDurationDays: nil,
            dueDate: nil,
            highPriority: false,
            shoppingFlag: false,
            estimatedCost: nil,
            createdAt: timestamp,
            createdByUserId: userID,
            updatedAt: timestamp,
            completedAt: status == .done ? timestamp : nil,
            completedByUserId: status == .done ? userID : nil,
            archived: false
        )
    }

    private func makeDependency(taskID: UUID, dependsOnTaskID: UUID) -> TaskDependency {
        TaskDependency(
            id: UUID(),
            taskId: taskID,
            dependsOnTaskId: dependsOnTaskID,
            createdAt: timestamp,
            createdByUserId: userID
        )
    }

    private struct DependencyKey: Hashable {
        let taskId: UUID
        let dependsOnTaskId: UUID
    }
}
