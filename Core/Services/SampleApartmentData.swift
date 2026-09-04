import Foundation

enum SampleApartmentData {
    struct Dataset {
        let project: Project
        let users: [User]
        let projectMembers: [ProjectMember]
        let categories: [Category]
        let tasks: [Task]
        let taskAssignments: [TaskAssignment]
        let taskDependencies: [TaskDependency]
        let budgetLines: [BudgetLine]
        let shoppingItems: [ShoppingItem]
        let expenses: [Expense]
        let apartmentVisits: [ApartmentVisit]
        let notificationPreferences: [NotificationPreference]
        let calendarSyncSettings: [CalendarSyncSetting]
        let attachments: [Attachment]
    }

    static let shared = makeDataset()

    private static let calendar: Calendar = {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(secondsFromGMT: 0)!
        return calendar
    }()

    private static func date(_ year: Int, _ month: Int, _ day: Int, hour: Int = 12, minute: Int = 0) -> Date {
        guard let date = calendar.date(from: DateComponents(year: year, month: month, day: day, hour: hour, minute: minute)) else {
            preconditionFailure("Invalid sample date components.")
        }

        return date
    }

    private static func money(_ string: String) -> Decimal {
        guard let value = Decimal(string: string, locale: Locale(identifier: "en_US_POSIX")) else {
            preconditionFailure("Invalid sample money value.")
        }

        return value
    }

    private static func makeDataset() -> Dataset {
        let projectId = UUID()
        let juliaId = UUID()
        let lucasId = UUID()

        let juliaProfileAttachmentId = UUID()
        let bathroomPaintReceiptAttachmentId = UUID()
        let wardrobeImageAttachmentId = UUID()

        let bathroomCategoryId = UUID()
        let paintingCategoryId = UUID()
        let bedroomCategoryId = UUID()
        let movingCategoryId = UUID()

        let buyBathroomPaintTaskId = UUID()
        let prepBathroomTilesTaskId = UUID()
        let paintBathroomTilesTaskId = UUID()
        let installShowerStorageTaskId = UUID()
        let measureBedroomWallTaskId = UUID()
        let orderWardrobeTaskId = UUID()
        let bookMovingVanTaskId = UUID()
        let finalCleanTaskId = UUID()
        let buyStorageBinsTaskId = UUID()

        let bathroomBudgetLineId = UUID()
        let bedroomBudgetLineId = UUID()
        let movingBudgetLineId = UUID()

        let bathroomPaintShoppingItemId = UUID()
        let wardrobeShoppingItemId = UUID()
        let showerStorageShoppingItemId = UUID()
        let movingBoxesShoppingItemId = UUID()

        let bathroomPaintExpenseId = UUID()
        let wardrobeDepositExpenseId = UUID()
        let parkingPermitExpenseId = UUID()

        let juliaVisitId = UUID()
        let lucasVisitId = UUID()

        let projectCreatedAt = date(2026, 8, 28, hour: 9)
        let timelineStart = date(2026, 9, 1, hour: 9)

        let users: [User] = [
            User(
                id: juliaId,
                displayName: "Julia",
                email: "julia@example.com",
                profilePhotoAttachmentId: juliaProfileAttachmentId,
                createdAt: projectCreatedAt
            ),
            User(
                id: lucasId,
                displayName: "Lucas",
                email: "lucas@example.com",
                profilePhotoAttachmentId: nil,
                createdAt: projectCreatedAt
            )
        ]

        let project = Project(
            id: projectId,
            name: "Fredensgade 18A Renovation",
            address: "Fredensgade 18A, 2200 Copenhagen N",
            plannedStartDate: timelineStart,
            targetEndDate: date(2026, 9, 28, hour: 9),
            overallBudgetAmount: money("120000"),
            currencyCode: "DKK",
            createdAt: projectCreatedAt,
            createdByUserId: juliaId
        )

        let attachments: [Attachment] = [
            Attachment(
                id: juliaProfileAttachmentId,
                projectId: projectId,
                kind: .profilePhoto,
                localIdentifierOrPath: "sample://attachments/julia-profile-photo.jpg",
                createdAt: projectCreatedAt,
                createdByUserId: juliaId
            ),
            Attachment(
                id: bathroomPaintReceiptAttachmentId,
                projectId: projectId,
                kind: .receiptPhoto,
                localIdentifierOrPath: "sample://attachments/bathroom-paint-receipt.jpg",
                createdAt: date(2026, 9, 2, hour: 18),
                createdByUserId: juliaId
            ),
            Attachment(
                id: wardrobeImageAttachmentId,
                projectId: projectId,
                kind: .shoppingImage,
                localIdentifierOrPath: "sample://attachments/wardrobe-photo.jpg",
                createdAt: date(2026, 9, 4, hour: 11),
                createdByUserId: lucasId
            )
        ]

        let projectMembers: [ProjectMember] = [
            ProjectMember(
                id: UUID(),
                projectId: projectId,
                userId: juliaId,
                role: .owner,
                joinedAt: projectCreatedAt,
                invitedByUserId: nil,
                status: .active
            ),
            ProjectMember(
                id: UUID(),
                projectId: projectId,
                userId: lucasId,
                role: .member,
                joinedAt: date(2026, 8, 30, hour: 17),
                invitedByUserId: juliaId,
                status: .active
            )
        ]

        let categories: [Category] = [
            Category(
                id: bathroomCategoryId,
                projectId: projectId,
                name: "Bathroom",
                icon: "shower",
                plannedStartDate: timelineStart,
                targetEndDate: date(2026, 9, 14, hour: 18),
                categoryBudgetAmount: money("35000"),
                sortOrder: 0,
                archived: false,
                createdAt: projectCreatedAt,
                updatedAt: projectCreatedAt
            ),
            Category(
                id: paintingCategoryId,
                projectId: projectId,
                name: "Painting",
                icon: "paintbrush",
                plannedStartDate: date(2026, 9, 8, hour: 9),
                targetEndDate: date(2026, 9, 18, hour: 18),
                categoryBudgetAmount: money("18000"),
                sortOrder: 1,
                archived: false,
                createdAt: projectCreatedAt,
                updatedAt: projectCreatedAt
            ),
            Category(
                id: bedroomCategoryId,
                projectId: projectId,
                name: "Bedroom",
                icon: "bed.double",
                plannedStartDate: date(2026, 9, 10, hour: 9),
                targetEndDate: date(2026, 9, 22, hour: 18),
                categoryBudgetAmount: money("28000"),
                sortOrder: 2,
                archived: false,
                createdAt: projectCreatedAt,
                updatedAt: projectCreatedAt
            ),
            Category(
                id: movingCategoryId,
                projectId: projectId,
                name: "Moving",
                icon: "truck.box",
                plannedStartDate: date(2026, 9, 18, hour: 9),
                targetEndDate: date(2026, 9, 28, hour: 18),
                categoryBudgetAmount: money("12000"),
                sortOrder: 3,
                archived: false,
                createdAt: projectCreatedAt,
                updatedAt: projectCreatedAt
            )
        ]

        let tasks: [Task] = [
            Task(
                id: buyBathroomPaintTaskId,
                projectId: projectId,
                categoryId: bathroomCategoryId,
                title: "Buy bathroom paint",
                notes: "Choose a washable finish before the prep work starts.",
                status: .done,
                estimatedDurationDays: nil,
                dueDate: nil,
                highPriority: false,
                shoppingFlag: true,
                estimatedCost: money("650"),
                createdAt: date(2026, 8, 29, hour: 10),
                createdByUserId: juliaId,
                updatedAt: date(2026, 9, 2, hour: 18),
                completedAt: date(2026, 9, 2, hour: 18),
                completedByUserId: juliaId,
                archived: false
            ),
            Task(
                id: prepBathroomTilesTaskId,
                projectId: projectId,
                categoryId: bathroomCategoryId,
                title: "Prep bathroom tiles",
                notes: "Mask the edges and clean the surface before painting.",
                status: .inProgress,
                estimatedDurationDays: 2,
                dueDate: date(2026, 9, 10, hour: 17),
                highPriority: true,
                shoppingFlag: false,
                estimatedCost: nil,
                createdAt: date(2026, 9, 1, hour: 9),
                createdByUserId: juliaId,
                updatedAt: date(2026, 9, 4, hour: 15),
                completedAt: nil,
                completedByUserId: nil,
                archived: false
            ),
            Task(
                id: paintBathroomTilesTaskId,
                projectId: projectId,
                categoryId: paintingCategoryId,
                title: "Paint bathroom tiles",
                notes: "Use the selected primer and two finish coats.",
                status: .todo,
                estimatedDurationDays: 1,
                dueDate: date(2026, 9, 14, hour: 17),
                highPriority: true,
                shoppingFlag: false,
                estimatedCost: money("900"),
                createdAt: date(2026, 9, 1, hour: 9, minute: 30),
                createdByUserId: juliaId,
                updatedAt: date(2026, 9, 1, hour: 9, minute: 30),
                completedAt: nil,
                completedByUserId: nil,
                archived: false
            ),
            Task(
                id: installShowerStorageTaskId,
                projectId: projectId,
                categoryId: bathroomCategoryId,
                title: "Install shower storage",
                notes: nil,
                status: .todo,
                estimatedDurationDays: 1,
                dueDate: date(2026, 9, 16, hour: 17),
                highPriority: false,
                shoppingFlag: false,
                estimatedCost: money("350"),
                createdAt: date(2026, 9, 1, hour: 10),
                createdByUserId: lucasId,
                updatedAt: date(2026, 9, 1, hour: 10),
                completedAt: nil,
                completedByUserId: nil,
                archived: false
            ),
            Task(
                id: measureBedroomWallTaskId,
                projectId: projectId,
                categoryId: bedroomCategoryId,
                title: "Measure bedroom wall",
                notes: nil,
                status: .todo,
                estimatedDurationDays: 1,
                dueDate: nil,
                highPriority: false,
                shoppingFlag: false,
                estimatedCost: nil,
                createdAt: date(2026, 9, 2, hour: 8, minute: 45),
                createdByUserId: lucasId,
                updatedAt: date(2026, 9, 2, hour: 8, minute: 45),
                completedAt: nil,
                completedByUserId: nil,
                archived: false
            ),
            Task(
                id: orderWardrobeTaskId,
                projectId: projectId,
                categoryId: bedroomCategoryId,
                title: "Order wardrobe",
                notes: "Confirm dimensions after measuring the wall.",
                status: .inProgress,
                estimatedDurationDays: nil,
                dueDate: date(2026, 9, 15, hour: 17),
                highPriority: false,
                shoppingFlag: true,
                estimatedCost: money("4200"),
                createdAt: date(2026, 9, 2, hour: 9, minute: 15),
                createdByUserId: juliaId,
                updatedAt: date(2026, 9, 4, hour: 10),
                completedAt: nil,
                completedByUserId: nil,
                archived: false
            ),
            Task(
                id: bookMovingVanTaskId,
                projectId: projectId,
                categoryId: movingCategoryId,
                title: "Book moving van",
                notes: "Reserve the smallest van that fits the mattress.",
                status: .done,
                estimatedDurationDays: 1,
                dueDate: date(2026, 9, 20, hour: 12),
                highPriority: true,
                shoppingFlag: false,
                estimatedCost: money("1400"),
                createdAt: date(2026, 9, 1, hour: 11),
                createdByUserId: lucasId,
                updatedAt: date(2026, 9, 3, hour: 14),
                completedAt: date(2026, 9, 3, hour: 14),
                completedByUserId: lucasId,
                archived: false
            ),
            Task(
                id: finalCleanTaskId,
                projectId: projectId,
                categoryId: movingCategoryId,
                title: "Final clean",
                notes: "Leave the apartment ready for handover.",
                status: .todo,
                estimatedDurationDays: nil,
                dueDate: date(2026, 9, 27, hour: 16),
                highPriority: true,
                shoppingFlag: false,
                estimatedCost: money("600"),
                createdAt: date(2026, 9, 3, hour: 8, minute: 30),
                createdByUserId: juliaId,
                updatedAt: date(2026, 9, 3, hour: 8, minute: 30),
                completedAt: nil,
                completedByUserId: nil,
                archived: false
            ),
            Task(
                id: UUID(),
                projectId: projectId,
                categoryId: movingCategoryId,
                title: "Clear hallway clutter",
                notes: nil,
                status: .todo,
                estimatedDurationDays: 1,
                dueDate: nil,
                highPriority: false,
                shoppingFlag: false,
                estimatedCost: nil,
                createdAt: date(2026, 9, 3, hour: 9),
                createdByUserId: lucasId,
                updatedAt: date(2026, 9, 3, hour: 9),
                completedAt: nil,
                completedByUserId: nil,
                archived: false
            ),
            Task(
                id: buyStorageBinsTaskId,
                projectId: projectId,
                categoryId: movingCategoryId,
                title: "Buy storage bins",
                notes: "Pick stackable bins for the final packing pass.",
                status: .todo,
                estimatedDurationDays: 1,
                dueDate: date(2026, 9, 21, hour: 17),
                highPriority: false,
                shoppingFlag: true,
                estimatedCost: money("250"),
                createdAt: date(2026, 9, 3, hour: 10),
                createdByUserId: juliaId,
                updatedAt: date(2026, 9, 3, hour: 10),
                completedAt: nil,
                completedByUserId: nil,
                archived: false
            )
        ]

        let taskAssignments: [TaskAssignment] = [
            TaskAssignment(id: UUID(), taskId: buyBathroomPaintTaskId, userId: juliaId),
            TaskAssignment(id: UUID(), taskId: prepBathroomTilesTaskId, userId: lucasId),
            TaskAssignment(id: UUID(), taskId: paintBathroomTilesTaskId, userId: juliaId),
            TaskAssignment(id: UUID(), taskId: paintBathroomTilesTaskId, userId: lucasId),
            TaskAssignment(id: UUID(), taskId: orderWardrobeTaskId, userId: juliaId),
            TaskAssignment(id: UUID(), taskId: bookMovingVanTaskId, userId: lucasId)
        ]

        let taskDependencies: [TaskDependency] = [
            TaskDependency(
                id: UUID(),
                taskId: prepBathroomTilesTaskId,
                dependsOnTaskId: buyBathroomPaintTaskId,
                createdAt: date(2026, 9, 1, hour: 9, minute: 5),
                createdByUserId: juliaId
            ),
            TaskDependency(
                id: UUID(),
                taskId: paintBathroomTilesTaskId,
                dependsOnTaskId: prepBathroomTilesTaskId,
                createdAt: date(2026, 9, 1, hour: 9, minute: 10),
                createdByUserId: juliaId
            ),
            TaskDependency(
                id: UUID(),
                taskId: installShowerStorageTaskId,
                dependsOnTaskId: paintBathroomTilesTaskId,
                createdAt: date(2026, 9, 1, hour: 9, minute: 15),
                createdByUserId: juliaId
            ),
            TaskDependency(
                id: UUID(),
                taskId: finalCleanTaskId,
                dependsOnTaskId: installShowerStorageTaskId,
                createdAt: date(2026, 9, 1, hour: 9, minute: 20),
                createdByUserId: juliaId
            ),
            TaskDependency(
                id: UUID(),
                taskId: orderWardrobeTaskId,
                dependsOnTaskId: measureBedroomWallTaskId,
                createdAt: date(2026, 9, 2, hour: 9, minute: 20),
                createdByUserId: lucasId
            )
        ]

        let budgetLines: [BudgetLine] = [
            BudgetLine(
                id: bathroomBudgetLineId,
                projectId: projectId,
                categoryId: bathroomCategoryId,
                stableBudgetLineCode: "BUD-001",
                name: "Bathroom finishes",
                plannedAmount: money("14500"),
                notes: "Paint, sealant, and shower storage.",
                source: .manual,
                ownerUserId: juliaId,
                supplierOrStore: "Silvan",
                targetPurchaseDate: date(2026, 9, 2, hour: 12),
                createdAt: projectCreatedAt,
                updatedAt: projectCreatedAt
            ),
            BudgetLine(
                id: bedroomBudgetLineId,
                projectId: projectId,
                categoryId: bedroomCategoryId,
                stableBudgetLineCode: "BUD-002",
                name: "Bedroom storage",
                plannedAmount: money("22000"),
                notes: "Wardrobe and related fittings.",
                source: .excelImport,
                ownerUserId: lucasId,
                supplierOrStore: "IKEA",
                targetPurchaseDate: date(2026, 9, 8, hour: 12),
                createdAt: projectCreatedAt,
                updatedAt: date(2026, 9, 4, hour: 9)
            ),
            BudgetLine(
                id: movingBudgetLineId,
                projectId: projectId,
                categoryId: movingCategoryId,
                stableBudgetLineCode: "BUD-003",
                name: "Moving day costs",
                plannedAmount: money("9000"),
                notes: "Van, permits, and packing supplies.",
                source: .manual,
                ownerUserId: juliaId,
                supplierOrStore: "Local suppliers",
                targetPurchaseDate: date(2026, 9, 18, hour: 12),
                createdAt: projectCreatedAt,
                updatedAt: date(2026, 9, 4, hour: 9)
            )
        ]

        let shoppingItems: [ShoppingItem] = [
            ShoppingItem(
                id: bathroomPaintShoppingItemId,
                projectId: projectId,
                categoryId: bathroomCategoryId,
                linkedTaskId: buyBathroomPaintTaskId,
                budgetLineId: bathroomBudgetLineId,
                title: "Bathroom paint",
                url: "https://example.com/bathroom-paint",
                notes: "Matte washable finish.",
                imageAttachmentId: nil,
                quantity: money("2"),
                estimatedPrice: money("650"),
                store: "Silvan",
                highPriority: false,
                purchased: true,
                purchasedAt: date(2026, 9, 2, hour: 18),
                purchasedByUserId: juliaId,
                createdAt: date(2026, 8, 31, hour: 16),
                createdByUserId: juliaId,
                updatedAt: date(2026, 9, 2, hour: 18)
            ),
            ShoppingItem(
                id: wardrobeShoppingItemId,
                projectId: projectId,
                categoryId: bedroomCategoryId,
                linkedTaskId: orderWardrobeTaskId,
                budgetLineId: bedroomBudgetLineId,
                title: "Wardrobe",
                url: "https://example.com/wardrobe",
                notes: "No price set until the final measurement is confirmed.",
                imageAttachmentId: wardrobeImageAttachmentId,
                quantity: money("1"),
                estimatedPrice: nil,
                store: "IKEA",
                highPriority: true,
                purchased: false,
                purchasedAt: nil,
                purchasedByUserId: nil,
                createdAt: date(2026, 9, 2, hour: 9, minute: 20),
                createdByUserId: juliaId,
                updatedAt: date(2026, 9, 4, hour: 10)
            ),
            ShoppingItem(
                id: showerStorageShoppingItemId,
                projectId: projectId,
                categoryId: bathroomCategoryId,
                linkedTaskId: installShowerStorageTaskId,
                budgetLineId: bathroomBudgetLineId,
                title: "Shower storage caddy",
                url: nil,
                notes: "Rust-resistant rack for the shower niche.",
                imageAttachmentId: nil,
                quantity: money("1"),
                estimatedPrice: money("350"),
                store: "JYSK",
                highPriority: true,
                purchased: false,
                purchasedAt: nil,
                purchasedByUserId: nil,
                createdAt: date(2026, 9, 1, hour: 11, minute: 30),
                createdByUserId: lucasId,
                updatedAt: date(2026, 9, 1, hour: 11, minute: 30)
            ),
            ShoppingItem(
                id: movingBoxesShoppingItemId,
                projectId: projectId,
                categoryId: movingCategoryId,
                linkedTaskId: buyStorageBinsTaskId,
                budgetLineId: movingBudgetLineId,
                title: "Moving boxes",
                url: nil,
                notes: "Stackable bins for the final packing pass.",
                imageAttachmentId: nil,
                quantity: money("12"),
                estimatedPrice: money("250"),
                store: "Bauhaus",
                highPriority: false,
                purchased: true,
                purchasedAt: date(2026, 9, 3, hour: 19),
                purchasedByUserId: lucasId,
                createdAt: date(2026, 9, 2, hour: 14),
                createdByUserId: lucasId,
                updatedAt: date(2026, 9, 3, hour: 19)
            )
        ]

        let expenses: [Expense] = [
            Expense(
                id: bathroomPaintExpenseId,
                projectId: projectId,
                categoryId: bathroomCategoryId,
                budgetLineId: bathroomBudgetLineId,
                shoppingItemId: bathroomPaintShoppingItemId,
                taskId: buyBathroomPaintTaskId,
                description: "Bathroom paint purchase",
                amount: money("645.50"),
                paidByUserId: juliaId,
                store: "Silvan",
                expenseDate: date(2026, 9, 2, hour: 18),
                receiptAttachmentId: bathroomPaintReceiptAttachmentId,
                notes: "Tint adjusted after the first sample.",
                createdAt: date(2026, 9, 2, hour: 18, minute: 15),
                createdByUserId: juliaId,
                updatedAt: date(2026, 9, 2, hour: 18, minute: 15)
            ),
            Expense(
                id: wardrobeDepositExpenseId,
                projectId: projectId,
                categoryId: bedroomCategoryId,
                budgetLineId: bedroomBudgetLineId,
                shoppingItemId: wardrobeShoppingItemId,
                taskId: orderWardrobeTaskId,
                description: "Wardrobe deposit",
                amount: money("1200"),
                paidByUserId: lucasId,
                store: "IKEA",
                expenseDate: date(2026, 9, 4, hour: 9),
                receiptAttachmentId: nil,
                notes: nil,
                createdAt: date(2026, 9, 4, hour: 9, minute: 5),
                createdByUserId: lucasId,
                updatedAt: date(2026, 9, 4, hour: 9, minute: 5)
            ),
            Expense(
                id: parkingPermitExpenseId,
                projectId: projectId,
                categoryId: movingCategoryId,
                budgetLineId: nil,
                shoppingItemId: nil,
                taskId: nil,
                description: "Parking permit for moving day",
                amount: money("75"),
                paidByUserId: juliaId,
                store: "City of Copenhagen",
                expenseDate: date(2026, 9, 3, hour: 13),
                receiptAttachmentId: nil,
                notes: "Manual cash expense.",
                createdAt: date(2026, 9, 3, hour: 13, minute: 30),
                createdByUserId: juliaId,
                updatedAt: date(2026, 9, 3, hour: 13, minute: 30)
            )
        ]

        let apartmentVisits: [ApartmentVisit] = [
            ApartmentVisit(
                id: juliaVisitId,
                projectId: projectId,
                userId: juliaId,
                startDateTime: date(2026, 9, 6, hour: 9),
                endDateTime: date(2026, 9, 6, hour: 11),
                note: "Tile prep and paint check.",
                createdAt: date(2026, 9, 4, hour: 8),
                createdByUserId: juliaId,
                updatedAt: date(2026, 9, 4, hour: 8)
            ),
            ApartmentVisit(
                id: lucasVisitId,
                projectId: projectId,
                userId: lucasId,
                startDateTime: date(2026, 9, 7, hour: 13),
                endDateTime: date(2026, 9, 7, hour: 16),
                note: "Wardrobe measurement and storage planning.",
                createdAt: date(2026, 9, 4, hour: 8, minute: 30),
                createdByUserId: juliaId,
                updatedAt: date(2026, 9, 4, hour: 8, minute: 30)
            )
        ]

        let notificationPreferences: [NotificationPreference] = [
            NotificationPreference(
                id: UUID(),
                userId: juliaId,
                enabledGroups: [.tasks, .planning],
                taskAssigned: true,
                highPriorityAssigned: true,
                taskDueSoon: true,
                blockedTaskReady: true,
                timeCriticalTask: true,
                categoryDeadlineWarning: true,
                apartmentVisitAdded: false,
                budgetWarning: true,
                purchaseAssigned: true,
                quietHoursStart: .defaultQuietHoursStart,
                quietHoursEnd: .defaultQuietHoursEnd
            ),
            NotificationPreference(
                id: UUID(),
                userId: lucasId,
                enabledGroups: [.tasks, .apartment, .budget],
                taskAssigned: true,
                highPriorityAssigned: false,
                taskDueSoon: true,
                blockedTaskReady: false,
                timeCriticalTask: true,
                categoryDeadlineWarning: false,
                apartmentVisitAdded: true,
                budgetWarning: true,
                purchaseAssigned: false,
                quietHoursStart: .defaultQuietHoursStart,
                quietHoursEnd: .defaultQuietHoursEnd
            )
        ]

        let calendarSyncSettings: [CalendarSyncSetting] = [
            CalendarSyncSetting(
                id: UUID(),
                userId: juliaId,
                projectId: projectId,
                syncApartmentVisits: true,
                syncTaskDeadlines: false,
                syncCategoryMilestones: true,
                selectedCalendarIdentifier: "julia-home"
            ),
            CalendarSyncSetting(
                id: UUID(),
                userId: lucasId,
                projectId: projectId,
                syncApartmentVisits: true,
                syncTaskDeadlines: true,
                syncCategoryMilestones: false,
                selectedCalendarIdentifier: "lucas-renovation"
            )
        ]

        return Dataset(
            project: project,
            users: users,
            projectMembers: projectMembers,
            categories: categories,
            tasks: tasks,
            taskAssignments: taskAssignments,
            taskDependencies: taskDependencies,
            budgetLines: budgetLines,
            shoppingItems: shoppingItems,
            expenses: expenses,
            apartmentVisits: apartmentVisits,
            notificationPreferences: notificationPreferences,
            calendarSyncSettings: calendarSyncSettings,
            attachments: attachments
        )
    }
}
