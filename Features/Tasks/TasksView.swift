import SwiftUI

struct TasksView: View {
    var body: some View {
        FeatureShellView(
            title: AppTab.tasks.title,
            subtitle: "Tasks will become the canonical place for task status, assignment, and dependency logic.",
            symbol: AppTab.tasks.systemImageName,
            accent: AppTab.tasks.accentColor
        )
        .navigationTitle(AppTab.tasks.title)
        .navigationBarTitleDisplayMode(.large)
    }
}

