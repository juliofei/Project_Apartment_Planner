import SwiftUI

struct RootView: View {
    @StateObject private var navigationState = RootNavigationState()

    var body: some View {
        TabView(selection: $navigationState.selectedTab) {
            NavigationStack {
                HomeView()
            }
            .tabItem {
                Label(AppTab.home.title, systemImage: AppTab.home.systemImageName)
            }
            .tag(AppTab.home)

            NavigationStack {
                TasksView()
            }
            .tabItem {
                Label(AppTab.tasks.title, systemImage: AppTab.tasks.systemImageName)
            }
            .tag(AppTab.tasks)

            NavigationStack {
                PlanView()
            }
            .tabItem {
                Label(AppTab.plan.title, systemImage: AppTab.plan.systemImageName)
            }
            .tag(AppTab.plan)

            NavigationStack {
                BudgetView()
            }
            .tabItem {
                Label(AppTab.budget.title, systemImage: AppTab.budget.systemImageName)
            }
            .tag(AppTab.budget)

            NavigationStack {
                CalendarView()
            }
            .tabItem {
                Label(AppTab.calendar.title, systemImage: AppTab.calendar.systemImageName)
            }
            .tag(AppTab.calendar)
        }
        .tint(Color.apartmentPlannerPrimaryAccent)
    }
}

