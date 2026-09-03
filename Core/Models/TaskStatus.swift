enum TaskStatus: String, CaseIterable, Hashable, Codable {
    case todo
    case inProgress
    case done

    var displayName: String {
        switch self {
        case .todo:
            return "To do"
        case .inProgress:
            return "In progress"
        case .done:
            return "Done"
        }
    }
}

