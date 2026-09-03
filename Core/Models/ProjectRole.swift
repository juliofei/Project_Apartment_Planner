enum ProjectRole: String, CaseIterable, Hashable, Codable {
    case owner
    case member
    case limited

    var displayName: String {
        switch self {
        case .owner:
            return "Owner"
        case .member:
            return "Member"
        case .limited:
            return "Limited"
        }
    }
}

