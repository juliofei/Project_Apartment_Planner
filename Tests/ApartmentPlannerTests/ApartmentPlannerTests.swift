import XCTest
@testable import ApartmentPlanner

final class ApartmentPlannerTests: XCTestCase {
    func testPrimaryNavigationTabsAreDeclaredInOrder() {
        XCTAssertEqual(AppTab.allCases, [.home, .tasks, .plan, .budget, .calendar])
    }

    func testTaskStatusTerminologyIsCanonical() {
        XCTAssertEqual(TaskStatus.todo.rawValue, "todo")
        XCTAssertEqual(TaskStatus.inProgress.rawValue, "inProgress")
        XCTAssertEqual(TaskStatus.done.rawValue, "done")
        XCTAssertEqual(TaskStatus.todo.displayName, "To do")
        XCTAssertEqual(TaskStatus.inProgress.displayName, "In progress")
        XCTAssertEqual(TaskStatus.done.displayName, "Done")
    }

    func testProjectRoleTerminologyIsCanonical() {
        XCTAssertEqual(ProjectRole.owner.rawValue, "owner")
        XCTAssertEqual(ProjectRole.member.rawValue, "member")
        XCTAssertEqual(ProjectRole.limited.rawValue, "limited")
        XCTAssertEqual(ProjectRole.owner.displayName, "Owner")
        XCTAssertEqual(ProjectRole.member.displayName, "Member")
        XCTAssertEqual(ProjectRole.limited.displayName, "Limited")
    }

    func testSpacingScaleIsAscending() {
        XCTAssertLessThan(ApartmentPlannerTheme.Spacing.xs, ApartmentPlannerTheme.Spacing.sm)
        XCTAssertLessThan(ApartmentPlannerTheme.Spacing.sm, ApartmentPlannerTheme.Spacing.md)
        XCTAssertLessThan(ApartmentPlannerTheme.Spacing.md, ApartmentPlannerTheme.Spacing.lg)
        XCTAssertLessThan(ApartmentPlannerTheme.Spacing.lg, ApartmentPlannerTheme.Spacing.xl)
    }

    func testCornerRadiusScaleIsAscending() {
        XCTAssertLessThan(ApartmentPlannerTheme.CornerRadius.sm, ApartmentPlannerTheme.CornerRadius.md)
        XCTAssertLessThan(ApartmentPlannerTheme.CornerRadius.md, ApartmentPlannerTheme.CornerRadius.lg)
        XCTAssertLessThan(ApartmentPlannerTheme.CornerRadius.lg, ApartmentPlannerTheme.CornerRadius.xl)
    }

    @MainActor
    func testRootNavigationStateDefaultsToHome() {
        let state = RootNavigationState()
        XCTAssertEqual(state.selectedTab, .home)
    }
}

