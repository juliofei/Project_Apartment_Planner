import XCTest
@testable import ApartmentPlanner

final class TaskListViewModelTests: XCTestCase {
    private let sample = SampleApartmentData.shared
    private let calendar: Calendar = {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(secondsFromGMT: 0)!
        return calendar
    }()

    private var fixedDate: Date {
        calendar.date(from: DateComponents(year: 2026, month: 9, day: 4, hour: 12))!
    }

    @MainActor
    func testInitialSampleTasksLoad() {
        let viewModel = makeViewModel()

        XCTAssertEqual(viewModel.tasks.count, sample.tasks.count)
        XCTAssertEqual(viewModel.activeCategories.count, sample.categories.filter { !$0.archived }.count)
    }

    @MainActor
    func testSectionsContainExpectedTaskStatuses() {
        let viewModel = makeViewModel()
        let sections = viewModel.sections(for: .all)

        XCTAssertEqual(sections.map { $0.kind }, [.inProgress, .todo, .done])
        XCTAssertEqual(Set(sections.flatMap { $0.cards.map { $0.title } }), Set(sample.tasks.map { $0.title }))
    }

    @MainActor
    func testMineFilterReturnsTasksAssignedToJulia() {
        let viewModel = makeViewModel()
        let titles = taskTitles(in: viewModel.sections(for: .mine))

        XCTAssertEqual(Set(titles), Set([
            "Buy bathroom paint",
            "Paint bathroom tiles",
            "Order wardrobe"
        ]))
    }

    @MainActor
    func testHighPriorityFilterReturnsOnlyHighPriorityTasks() {
        let viewModel = makeViewModel()
        let cards = viewModel.sections(for: .highPriority).flatMap { $0.cards }

        XCTAssertFalse(cards.isEmpty)
        XCTAssertTrue(cards.allSatisfy { $0.isHighPriority })
        XCTAssertEqual(Set(cards.map { $0.title }), Set([
            "Prep bathroom tiles",
            "Paint bathroom tiles",
            "Book moving van",
            "Final clean"
        ]))
    }

    @MainActor
    func testBlockedFilterUsesDependencyRules() {
        let viewModel = makeViewModel()
        let titles = taskTitles(in: viewModel.sections(for: .blocked))

        XCTAssertEqual(Set(titles), Set([
            "Paint bathroom tiles",
            "Install shower storage",
            "Final clean",
            "Order wardrobe"
        ]))
    }

    @MainActor
    func testShoppingFilterReturnsShoppingTasks() {
        let viewModel = makeViewModel()
        let titles = taskTitles(in: viewModel.sections(for: .shopping))

        XCTAssertEqual(Set(titles), Set([
            "Buy bathroom paint",
            "Order wardrobe",
            "Buy storage bins"
        ]))
    }

    @MainActor
    func testMarkingPrerequisiteDoneChangesDependentReadinessToReady() {
        let viewModel = makeViewModel()
        let prerequisite = try! task(named: "Prep bathroom tiles", in: viewModel)
        let dependent = try! task(named: "Paint bathroom tiles", in: viewModel)

        viewModel.completeTask(prerequisite.id)

        XCTAssertEqual(viewModel.readiness(for: dependent.id), .some(.ready))
        XCTAssertFalse(viewModel.sections(for: .blocked).flatMap { $0.cards }.contains(where: { $0.id == dependent.id }))
    }

    @MainActor
    func testMarkingTaskDoneSetsCompletedFields() {
        let viewModel = makeViewModel()
        let task = try! task(named: "Measure bedroom wall", in: viewModel)

        viewModel.completeTask(task.id)

        let updated = try! XCTUnwrap(viewModel.task(for: task.id))
        XCTAssertEqual(updated.status, .done)
        XCTAssertEqual(updated.completedAt, fixedDate)
        XCTAssertEqual(updated.completedByUserId, viewModel.currentUser.id)
        XCTAssertEqual(updated.updatedAt, fixedDate)
    }

    @MainActor
    func testReopeningDoneTaskClearsCompletedFields() {
        let viewModel = makeViewModel()
        let task = try! task(named: "Buy bathroom paint", in: viewModel)

        viewModel.reopenTask(task.id)

        let updated = try! XCTUnwrap(viewModel.task(for: task.id))
        XCTAssertEqual(updated.status, .todo)
        XCTAssertNil(updated.completedAt)
        XCTAssertNil(updated.completedByUserId)
        XCTAssertEqual(updated.updatedAt, fixedDate)
    }

    @MainActor
    func testQuickAddCreatesTodoTaskWithSelectedCategory() {
        let viewModel = makeViewModel()
        let category = try! XCTUnwrap(viewModel.activeCategories.first(where: { $0.name == "Bathroom" }))

        let result = viewModel.addQuickTask(
            title: "  Replace towel hook  ",
            categoryID: category.id,
            assigneeID: viewModel.currentUser.id
        )

        guard case .success(let createdTask) = result else {
            XCTFail("Expected quick add to succeed.")
            return
        }

        let storedTask = try! XCTUnwrap(viewModel.task(for: createdTask.id))
        XCTAssertEqual(storedTask.title, "Replace towel hook")
        XCTAssertEqual(storedTask.status, .todo)
        XCTAssertEqual(storedTask.categoryId, category.id)
        XCTAssertEqual(storedTask.createdAt, fixedDate)
        XCTAssertEqual(storedTask.updatedAt, fixedDate)
        XCTAssertEqual(storedTask.createdByUserId, viewModel.currentUser.id)
        XCTAssertNil(storedTask.completedAt)
        XCTAssertNil(storedTask.completedByUserId)
        XCTAssertFalse(storedTask.archived)

        let assignments = viewModel.taskAssignments.filter { $0.taskId == createdTask.id }
        XCTAssertEqual(assignments.map { $0.userId }, [viewModel.currentUser.id])
    }

    @MainActor
    func testQuickAddBlankTitleIsRejected() {
        let viewModel = makeViewModel()
        let category = try! XCTUnwrap(viewModel.activeCategories.first)

        let result = viewModel.addQuickTask(title: "   ", categoryID: category.id, assigneeID: nil)

        switch result {
        case .failure(.blankTitle):
            break
        default:
            XCTFail("Expected blank title validation to fail.")
        }
    }

    @MainActor
    func testQuickAddMissingCategoryIsRejected() {
        let viewModel = makeViewModel()

        let result = viewModel.addQuickTask(title: "New task", categoryID: nil, assigneeID: nil)

        switch result {
        case .failure(.missingCategory):
            break
        default:
            XCTFail("Expected missing category validation to fail.")
        }
    }

    @MainActor
    func testAssigneeDisplayHandlesUnassignedSingleAndMultipleUsers() {
        let viewModel = makeViewModel()

        let unassigned = try! task(named: "Measure bedroom wall", in: viewModel)
        let singleAssignee = try! task(named: "Book moving van", in: viewModel)
        let multipleAssignees = try! task(named: "Paint bathroom tiles", in: viewModel)

        XCTAssertEqual(viewModel.assigneeDisplay(for: unassigned), "Unassigned")
        XCTAssertEqual(viewModel.assigneeDisplay(for: singleAssignee), "Lucas")
        XCTAssertEqual(viewModel.assigneeDisplay(for: multipleAssignees), "Julia + Lucas")
    }

    @MainActor
    private func makeViewModel() -> TaskListViewModel {
        TaskListViewModel(dataset: sample, now: { self.fixedDate })
    }

    @MainActor
    private func task(named title: String, in viewModel: TaskListViewModel) throws -> Task {
        try XCTUnwrap(viewModel.tasks.first(where: { $0.title == title }))
    }

    @MainActor
    private func taskTitles(in sections: [TaskSectionModel]) -> [String] {
        sections.flatMap { $0.cards.map { $0.title } }
    }
}
