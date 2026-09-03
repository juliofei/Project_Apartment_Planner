import SwiftUI

@MainActor
final class RootNavigationState: ObservableObject {
    @Published var selectedTab: AppTab = .home
}

