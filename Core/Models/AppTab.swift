import SwiftUI

enum AppTab: String, CaseIterable, Identifiable {
    case home
    case tasks
    case plan
    case budget
    case calendar

    var id: String { rawValue }

    var title: String {
        switch self {
        case .home:
            return "Home"
        case .tasks:
            return "Tasks"
        case .plan:
            return "Plan"
        case .budget:
            return "Budget"
        case .calendar:
            return "Calendar"
        }
    }

    var systemImageName: String {
        switch self {
        case .home:
            return "house.fill"
        case .tasks:
            return "checklist"
        case .plan:
            return "map"
        case .budget:
            return "eurosign.circle"
        case .calendar:
            return "calendar"
        }
    }

    var accentColor: Color {
        switch self {
        case .home:
            return .apartmentPlannerPrimaryAccent
        case .tasks:
            return .apartmentPlannerSecondaryAccent
        case .plan:
            return .apartmentPlannerAttention
        case .budget:
            return .apartmentPlannerWarning
        case .calendar:
            return .apartmentPlannerPrimaryAccent
        }
    }
}

