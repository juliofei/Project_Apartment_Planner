import SwiftUI

struct HomeView: View {
    var body: some View {
        FeatureShellView(
            title: AppTab.home.title,
            subtitle: "Home will surface the day at a glance, priorities, and the next action to take.",
            symbol: AppTab.home.systemImageName,
            accent: AppTab.home.accentColor
        )
        .navigationTitle(AppTab.home.title)
        .navigationBarTitleDisplayMode(.large)
    }
}

