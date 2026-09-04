import XCTest
@testable import ApartmentPlanner

final class SampleApartmentDataTests: XCTestCase {
    private let sample = SampleApartmentData.shared

    func testSampleProjectAndActiveMembersExist() {
        XCTAssertEqual(sample.project.name, "Fredensgade 18A Renovation")
        XCTAssertEqual(sample.project.currencyCode, "DKK")
        XCTAssertEqual(sample.users.map(\.displayName), ["Julia", "Lucas"])

        let membersByUserId = Dictionary(uniqueKeysWithValues: sample.projectMembers.map { ($0.userId, $0) })
        XCTAssertEqual(sample.projectMembers.count, 2)
        XCTAssertEqual(membersByUserId[sample.users[0].id]?.status, .active)
        XCTAssertEqual(membersByUserId[sample.users[1].id]?.status, .active)
    }

    func testSampleTaskStatusesAndAssignmentCoverage() {
        let statuses = Set(sample.tasks.map(\.status))
        XCTAssertEqual(statuses, Set(TaskStatus.allCases))

        let tasksByTitle = Dictionary(uniqueKeysWithValues: sample.tasks.map { ($0.title, $0) })
        let assignmentsByTaskId = Dictionary(grouping: sample.taskAssignments, by: \.taskId)

        XCTAssertTrue((assignmentsByTaskId[tasksByTitle["Measure bedroom wall"]!.id] ?? []).isEmpty)
        XCTAssertEqual(assignmentsByTaskId[tasksByTitle["Paint bathroom tiles"]!.id]?.count, 2)
        XCTAssertTrue(sample.tasks.contains { $0.estimatedDurationDays == nil })
        XCTAssertTrue(sample.tasks.contains { $0.dueDate != nil })
        XCTAssertTrue(sample.tasks.contains { $0.status == .done })
        XCTAssertTrue(sample.tasks.contains { $0.status == .inProgress })
        XCTAssertTrue(sample.tasks.contains { $0.status == .todo })
    }

    func testSampleDependenciesIncludeCrossCategoryChain() {
        XCTAssertGreaterThanOrEqual(sample.taskDependencies.count, 4)
        XCTAssertFalse(sample.taskDependencies.contains { $0.taskId == $0.dependsOnTaskId })

        let tasksById = Dictionary(uniqueKeysWithValues: sample.tasks.map { ($0.id, $0) })
        let hasCrossCategoryDependency = sample.taskDependencies.contains { dependency in
            guard let dependentTask = tasksById[dependency.taskId],
                  let prerequisiteTask = tasksById[dependency.dependsOnTaskId] else {
                return false
            }

            return dependentTask.categoryId != prerequisiteTask.categoryId
        }

        XCTAssertTrue(hasCrossCategoryDependency)
    }

    func testShoppingAndExpenseCoverageIsPresent() {
        XCTAssertTrue(sample.shoppingItems.contains { $0.linkedTaskId != nil })
        XCTAssertTrue(sample.shoppingItems.contains { $0.estimatedPrice == nil })
        XCTAssertTrue(sample.shoppingItems.contains { $0.purchased })
        XCTAssertTrue(sample.expenses.contains { $0.shoppingItemId != nil || $0.taskId != nil })
        XCTAssertTrue(sample.expenses.contains { $0.shoppingItemId == nil && $0.taskId == nil && $0.budgetLineId == nil })
    }

    func testBudgetLineCodesAreUnique() {
        let codes = sample.budgetLines.map(\.stableBudgetLineCode)
        XCTAssertEqual(Set(codes).count, codes.count)
        XCTAssertEqual(codes, ["BUD-001", "BUD-002", "BUD-003"])
    }

    func testPreferencesAndCalendarSettingsExistForBothUsers() throws {
        XCTAssertEqual(sample.notificationPreferences.count, 2)
        XCTAssertEqual(sample.calendarSyncSettings.count, 2)

        let juliaPreferences = try XCTUnwrap(sample.notificationPreferences.first { $0.userId == sample.users[0].id })
        XCTAssertEqual(juliaPreferences.quietHoursStart.hour, 8)
        XCTAssertEqual(juliaPreferences.quietHoursStart.minute, 0)
        XCTAssertEqual(juliaPreferences.quietHoursEnd.hour, 21)
        XCTAssertEqual(juliaPreferences.quietHoursEnd.minute, 0)
    }
}
