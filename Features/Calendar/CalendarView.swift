import SwiftUI

struct CalendarView: View {
    var body: some View {
        FeatureShellView(
            title: AppTab.calendar.title,
            subtitle: "Calendar will later coordinate apartment visits, reminders, and external calendar sync.",
            symbol: AppTab.calendar.systemImageName,
            accent: AppTab.calendar.accentColor
        )
        .navigationTitle(AppTab.calendar.title)
        .navigationBarTitleDisplayMode(.large)
    }
}

