import Foundation

/// A local time-of-day value without a calendar date.
struct TimeOfDay: Codable, Equatable {
    var hour: Int
    var minute: Int

    init(hour: Int, minute: Int) {
        guard (0...23).contains(hour), (0...59).contains(minute) else {
            preconditionFailure("TimeOfDay must use a valid 24-hour clock value.")
        }

        self.hour = hour
        self.minute = minute
    }

    static let defaultQuietHoursStart = TimeOfDay(hour: 8, minute: 0)
    static let defaultQuietHoursEnd = TimeOfDay(hour: 21, minute: 0)
}

enum ProjectMemberStatus: String, CaseIterable, Codable, Hashable {
    case active
    case invited
    case removed
    case left

    var displayName: String {
        switch self {
        case .active:
            return "Active"
        case .invited:
            return "Invited"
        case .removed:
            return "Removed"
        case .left:
            return "Left"
        }
    }
}

enum BudgetLineSource: String, CaseIterable, Codable, Hashable {
    case manual
    case excelImport

    var displayName: String {
        switch self {
        case .manual:
            return "Manual"
        case .excelImport:
            return "Excel import"
        }
    }
}

enum AttachmentKind: String, CaseIterable, Codable, Hashable {
    case taskPhoto
    case shoppingImage
    case receiptPhoto
    case profilePhoto

    var displayName: String {
        switch self {
        case .taskPhoto:
            return "Task photo"
        case .shoppingImage:
            return "Shopping image"
        case .receiptPhoto:
            return "Receipt photo"
        case .profilePhoto:
            return "Profile photo"
        }
    }
}

enum NotificationGroup: String, CaseIterable, Codable, Hashable {
    case tasks
    case planning
    case apartment
    case budget

    var displayName: String {
        switch self {
        case .tasks:
            return "Tasks"
        case .planning:
            return "Planning"
        case .apartment:
            return "Apartment"
        case .budget:
            return "Budget"
        }
    }
}

struct Project: Identifiable, Codable {
    typealias ID = UUID

    var id: ID
    var name: String
    var address: String?
    var plannedStartDate: Date?
    var targetEndDate: Date?
    var overallBudgetAmount: Decimal?
    var currencyCode: String
    var createdAt: Date
    var createdByUserId: User.ID
}

struct User: Identifiable, Codable {
    typealias ID = UUID

    var id: ID
    var displayName: String
    var email: String
    var profilePhotoAttachmentId: Attachment.ID?
    var createdAt: Date
}

struct ProjectMember: Identifiable, Codable {
    typealias ID = UUID

    var id: ID
    var projectId: Project.ID
    var userId: User.ID
    var role: ProjectRole
    var joinedAt: Date?
    var invitedByUserId: User.ID?
    var status: ProjectMemberStatus
}

struct Category: Identifiable, Codable {
    typealias ID = UUID

    var id: ID
    var projectId: Project.ID
    var name: String
    var icon: String
    var plannedStartDate: Date?
    var targetEndDate: Date?
    var categoryBudgetAmount: Decimal?
    var sortOrder: Int
    var archived: Bool
    var createdAt: Date
    var updatedAt: Date
}

struct Task: Identifiable, Codable {
    typealias ID = UUID

    var id: ID
    var projectId: Project.ID
    var categoryId: Category.ID
    var title: String
    var notes: String?
    var status: TaskStatus
    var estimatedDurationDays: Int?
    var dueDate: Date?
    var highPriority: Bool
    var shoppingFlag: Bool
    var estimatedCost: Decimal?
    var createdAt: Date
    var createdByUserId: User.ID
    var updatedAt: Date
    var completedAt: Date?
    var completedByUserId: User.ID?
    var archived: Bool
}

struct TaskAssignment: Identifiable, Codable {
    typealias ID = UUID

    var id: ID
    var taskId: Task.ID
    var userId: User.ID
}

/// `taskId` depends on `dependsOnTaskId`.
struct TaskDependency: Identifiable, Codable {
    typealias ID = UUID

    var id: ID
    var taskId: Task.ID
    var dependsOnTaskId: Task.ID
    var createdAt: Date
    var createdByUserId: User.ID
}

struct BudgetLine: Identifiable, Codable {
    typealias ID = UUID

    var id: ID
    var projectId: Project.ID
    var categoryId: Category.ID
    var stableBudgetLineCode: String
    var name: String
    var plannedAmount: Decimal
    var notes: String?
    var source: BudgetLineSource
    var ownerUserId: User.ID?
    var supplierOrStore: String?
    var targetPurchaseDate: Date?
    var createdAt: Date
    var updatedAt: Date
}

struct ShoppingItem: Identifiable, Codable {
    typealias ID = UUID

    var id: ID
    var projectId: Project.ID
    var categoryId: Category.ID
    var linkedTaskId: Task.ID?
    var budgetLineId: BudgetLine.ID?
    var title: String
    var url: String?
    var notes: String?
    var imageAttachmentId: Attachment.ID?
    var quantity: Decimal?
    var estimatedPrice: Decimal?
    var store: String?
    var highPriority: Bool
    var purchased: Bool
    var purchasedAt: Date?
    var purchasedByUserId: User.ID?
    var createdAt: Date
    var createdByUserId: User.ID
    var updatedAt: Date
}

struct Expense: Identifiable, Codable {
    typealias ID = UUID

    var id: ID
    var projectId: Project.ID
    var categoryId: Category.ID
    var budgetLineId: BudgetLine.ID?
    var shoppingItemId: ShoppingItem.ID?
    var taskId: Task.ID?
    var description: String
    var amount: Decimal
    var paidByUserId: User.ID
    var store: String?
    var expenseDate: Date
    var receiptAttachmentId: Attachment.ID?
    var notes: String?
    var createdAt: Date
    var createdByUserId: User.ID
    var updatedAt: Date
}

struct ApartmentVisit: Identifiable, Codable {
    typealias ID = UUID

    var id: ID
    var projectId: Project.ID
    var userId: User.ID
    var startDateTime: Date
    var endDateTime: Date
    var note: String?
    var createdAt: Date
    var createdByUserId: User.ID
    var updatedAt: Date
}

struct NotificationPreference: Identifiable, Codable {
    typealias ID = UUID

    var id: ID
    var userId: User.ID
    var enabledGroups: Set<NotificationGroup>
    var taskAssigned: Bool
    var highPriorityAssigned: Bool
    var taskDueSoon: Bool
    var blockedTaskReady: Bool
    var timeCriticalTask: Bool
    var categoryDeadlineWarning: Bool
    var apartmentVisitAdded: Bool
    var budgetWarning: Bool
    var purchaseAssigned: Bool
    var quietHoursStart: TimeOfDay
    var quietHoursEnd: TimeOfDay
}

struct CalendarSyncSetting: Identifiable, Codable {
    typealias ID = UUID

    var id: ID
    var userId: User.ID
    var projectId: Project.ID
    var syncApartmentVisits: Bool
    var syncTaskDeadlines: Bool
    var syncCategoryMilestones: Bool
    var selectedCalendarIdentifier: String?
}

struct Attachment: Identifiable, Codable {
    typealias ID = UUID

    var id: ID
    var projectId: Project.ID
    var kind: AttachmentKind
    var localIdentifierOrPath: String
    var createdAt: Date
    var createdByUserId: User.ID
}
