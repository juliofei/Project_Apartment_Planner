import SwiftUI

struct TasksView: View {
    @StateObject private var viewModel = TaskListViewModel()
    @State private var selectedFilter: TaskListFilter = .all
    @State private var showingQuickAdd = false

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [
                    Color.apartmentPlannerBackground,
                    Color.apartmentPlannerSurface
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            ScrollView {
                VStack(alignment: .leading, spacing: ApartmentPlannerTheme.Spacing.lg) {
                    introCard
                    filterBar

                    if visibleSections.isEmpty {
                        if hasActiveTasks {
                            TaskEmptyStateView(
                                title: "No matching tasks",
                                subtitle: "Try a different filter."
                            )
                        } else {
                            TaskEmptyStateView(
                                title: "No tasks yet",
                                subtitle: "Add your first task"
                            )
                        }
                    } else {
                        ForEach(visibleSections) { section in
                            TaskSectionView(section: section)
                        }
                    }
                }
                .padding(ApartmentPlannerTheme.Spacing.lg)
                .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
        .navigationTitle(AppTab.tasks.title)
        .navigationBarTitleDisplayMode(.large)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    showingQuickAdd = true
                } label: {
                    Label("Add task", systemImage: "plus")
                }
            }
        }
        .navigationDestination(for: UUID.self) { taskID in
            TaskDetailView(viewModel: viewModel, taskID: taskID)
        }
        .sheet(isPresented: $showingQuickAdd) {
            QuickAddTaskView(viewModel: viewModel)
        }
    }

    private var visibleSections: [TaskSectionModel] {
        viewModel.sections(for: selectedFilter)
    }

    private var hasActiveTasks: Bool {
        viewModel.tasks.contains { !$0.archived }
    }

    private var introCard: some View {
        VStack(alignment: .leading, spacing: ApartmentPlannerTheme.Spacing.sm) {
            HStack(alignment: .top, spacing: ApartmentPlannerTheme.Spacing.md) {
                Image(systemName: AppTab.tasks.systemImageName)
                    .font(.title2.weight(.semibold))
                    .foregroundStyle(AppTab.tasks.accentColor)
                    .padding(ApartmentPlannerTheme.Spacing.sm)
                    .background(AppTab.tasks.accentColor.opacity(0.14), in: RoundedRectangle(cornerRadius: ApartmentPlannerTheme.CornerRadius.md, style: .continuous))

                VStack(alignment: .leading, spacing: ApartmentPlannerTheme.Spacing.xs) {
                    Text(viewModel.projectName)
                        .font(ApartmentPlannerTypography.screenTitle)
                        .foregroundStyle(Color.apartmentPlannerPrimaryText)

                    Text("Everything here runs from `SampleApartmentData`. Status changes stay local, and Ready / Blocked comes from `DependencyRules`.")
                        .font(ApartmentPlannerTypography.secondaryBody)
                        .foregroundStyle(Color.apartmentPlannerSecondaryText)
                        .fixedSize(horizontal: false, vertical: true)

                    Text("Current user: \(viewModel.currentUser.displayName)")
                        .font(ApartmentPlannerTypography.badge)
                        .foregroundStyle(AppTab.tasks.accentColor)
                }

                Spacer(minLength: 0)
            }
        }
        .padding(ApartmentPlannerTheme.Spacing.lg)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.apartmentPlannerSurface, in: RoundedRectangle(cornerRadius: ApartmentPlannerTheme.CornerRadius.xl, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: ApartmentPlannerTheme.CornerRadius.xl, style: .continuous)
                .stroke(Color.apartmentPlannerBorder, lineWidth: 1)
        )
    }

    private var filterBar: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: ApartmentPlannerTheme.Spacing.sm) {
                ForEach(TaskListFilter.allCases) { filter in
                    TaskFilterChip(filter: filter, isSelected: filter == selectedFilter) {
                        selectedFilter = filter
                    }
                }
            }
            .padding(.vertical, 2)
        }
    }
}

private struct TaskSectionView: View {
    let section: TaskSectionModel

    var body: some View {
        VStack(alignment: .leading, spacing: ApartmentPlannerTheme.Spacing.md) {
            HStack(alignment: .firstTextBaseline, spacing: ApartmentPlannerTheme.Spacing.sm) {
                Text(section.kind.title)
                    .font(ApartmentPlannerTypography.badge)
                    .foregroundStyle(Color.apartmentPlannerPrimaryText)

                TaskBadgeView(title: "\(section.cards.count)", tone: .neutral)

                Spacer(minLength: 0)
            }

            VStack(alignment: .leading, spacing: ApartmentPlannerTheme.Spacing.md) {
                ForEach(section.cards) { card in
                    NavigationLink(value: card.id) {
                        TaskCardView(model: card)
                    }
                    .buttonStyle(.plain)
                }
            }
        }
        .padding(ApartmentPlannerTheme.Spacing.lg)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.apartmentPlannerSurface, in: RoundedRectangle(cornerRadius: ApartmentPlannerTheme.CornerRadius.xl, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: ApartmentPlannerTheme.CornerRadius.xl, style: .continuous)
                .stroke(Color.apartmentPlannerBorder, lineWidth: 1)
        )
    }
}

private struct TaskFilterChip: View {
    let filter: TaskListFilter
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Label(filter.title, systemImage: filter.iconName)
                .font(ApartmentPlannerTypography.badge)
                .foregroundStyle(isSelected ? .white : Color.apartmentPlannerPrimaryText)
                .padding(.horizontal, ApartmentPlannerTheme.Spacing.md)
                .padding(.vertical, ApartmentPlannerTheme.Spacing.sm)
                .background(
                    Capsule(style: .continuous)
                        .fill(isSelected ? Color.apartmentPlannerPrimaryAccent : Color.apartmentPlannerSurface)
                )
                .overlay(
                    Capsule(style: .continuous)
                        .stroke(isSelected ? Color.clear : Color.apartmentPlannerBorder, lineWidth: 1)
                )
        }
        .buttonStyle(.plain)
    }
}

struct TaskEmptyStateView: View {
    let title: String
    let subtitle: String

    var body: some View {
        VStack(alignment: .leading, spacing: ApartmentPlannerTheme.Spacing.sm) {
            Text(title)
                .font(ApartmentPlannerTypography.body.weight(.semibold))
                .foregroundStyle(Color.apartmentPlannerPrimaryText)

            Text(subtitle)
                .font(ApartmentPlannerTypography.secondaryBody)
                .foregroundStyle(Color.apartmentPlannerSecondaryText)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(ApartmentPlannerTheme.Spacing.lg)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.apartmentPlannerSurface, in: RoundedRectangle(cornerRadius: ApartmentPlannerTheme.CornerRadius.xl, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: ApartmentPlannerTheme.CornerRadius.xl, style: .continuous)
                .stroke(Color.apartmentPlannerBorder, lineWidth: 1)
        )
    }
}
