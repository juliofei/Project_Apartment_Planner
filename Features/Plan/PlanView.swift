import SwiftUI

struct PlanView: View {
    var body: some View {
        FeatureShellView(
            title: AppTab.plan.title,
            subtitle: "Plan will hold sequencing, must-start-by dates, and dependency-aware planning workflows.",
            symbol: AppTab.plan.systemImageName,
            accent: AppTab.plan.accentColor
        )
        .navigationTitle(AppTab.plan.title)
        .navigationBarTitleDisplayMode(.large)
    }
}

