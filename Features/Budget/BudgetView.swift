import SwiftUI

struct BudgetView: View {
    var body: some View {
        FeatureShellView(
            title: AppTab.budget.title,
            subtitle: "Budget will own budget lines, expenses, and the financial view of apartment work.",
            symbol: AppTab.budget.systemImageName,
            accent: AppTab.budget.accentColor
        )
        .navigationTitle(AppTab.budget.title)
        .navigationBarTitleDisplayMode(.large)
    }
}

