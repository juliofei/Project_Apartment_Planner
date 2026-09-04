import SwiftUI

struct TaskDetailView: View {
    @ObservedObject var viewModel: TaskListViewModel
    let taskID: UUID

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
                if let task = viewModel.task(for: taskID) {
                    let card = viewModel.cardModel(for: task)

                    VStack(alignment: .leading, spacing: ApartmentPlannerTheme.Spacing.lg) {
                        detailSummaryCard(task: task, card: card)
                        detailFactsCard(task: task, card: card)

                        if let notes = task.notes, !notes.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                            detailNotesCard(notes: notes)
                        }

                        detailActionsCard(task: task)
                    }
                    .padding(ApartmentPlannerTheme.Spacing.lg)
                    .frame(maxWidth: .infinity, alignment: .leading)
                } else {
                    TaskEmptyStateView(
                        title: "Task not found",
                        subtitle: "The task may have been removed from local state."
                    )
                    .padding(ApartmentPlannerTheme.Spacing.lg)
                }
            }
        }
        .navigationTitle(viewModel.task(for: taskID)?.title ?? "Task detail")
        .navigationBarTitleDisplayMode(.inline)
    }

    private func detailSummaryCard(task: Task, card: TaskCardModel) -> some View {
        VStack(alignment: .leading, spacing: ApartmentPlannerTheme.Spacing.md) {
            Text(task.title)
                .font(ApartmentPlannerTypography.screenTitle)
                .foregroundStyle(Color.apartmentPlannerPrimaryText)
                .fixedSize(horizontal: false, vertical: true)

            HStack(spacing: ApartmentPlannerTheme.Spacing.sm) {
                TaskBadgeView(title: card.statusTitle, tone: card.statusTone)

                if let readiness = card.readiness {
                    TaskBadgeView(title: readiness.title, tone: readiness.tone)
                }
            }

            if let readiness = card.readiness, let blockerSummary = readiness.blockerSummary {
                Text(blockerSummary)
                    .font(ApartmentPlannerTypography.secondaryBody)
                    .foregroundStyle(Color.apartmentPlannerSecondaryText)
                    .fixedSize(horizontal: false, vertical: true)
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

    private func detailFactsCard(task: Task, card: TaskCardModel) -> some View {
        VStack(alignment: .leading, spacing: ApartmentPlannerTheme.Spacing.sm) {
            Text("Task details")
                .font(ApartmentPlannerTypography.badge)
                .foregroundStyle(Color.apartmentPlannerPrimaryText)

            VStack(alignment: .leading, spacing: ApartmentPlannerTheme.Spacing.sm) {
                detailRow(label: "Category", value: card.categoryName)
                detailRow(label: "Assignees", value: card.assigneeTitle)
                detailRow(label: "Estimated duration", value: card.estimatedDurationTitle ?? "None")

                if let dueDateTitle = TaskDisplayHelpers.dueDateTitle(for: task) {
                    detailRow(label: "Due date", value: dueDateTitle)
                }

                detailRow(label: "High priority", value: task.highPriority ? "Yes" : "No")
                detailRow(label: "Shopping", value: task.shoppingFlag ? "Yes" : "No")
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

    private func detailNotesCard(notes: String) -> some View {
        VStack(alignment: .leading, spacing: ApartmentPlannerTheme.Spacing.sm) {
            Text("Notes")
                .font(ApartmentPlannerTypography.badge)
                .foregroundStyle(Color.apartmentPlannerPrimaryText)

            Text(notes)
                .font(ApartmentPlannerTypography.body)
                .foregroundStyle(Color.apartmentPlannerPrimaryText)
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

    private func detailActionsCard(task: Task) -> some View {
        VStack(alignment: .leading, spacing: ApartmentPlannerTheme.Spacing.sm) {
            Text("Actions")
                .font(ApartmentPlannerTypography.badge)
                .foregroundStyle(Color.apartmentPlannerPrimaryText)

            VStack(spacing: ApartmentPlannerTheme.Spacing.sm) {
                switch task.status {
                case .todo:
                    actionButton(
                        title: "Start",
                        systemImage: "play.fill",
                        prominent: true
                    ) {
                        viewModel.startTask(task.id)
                    }

                    actionButton(
                        title: "Done",
                        systemImage: "checkmark.circle.fill",
                        prominent: false
                    ) {
                        viewModel.completeTask(task.id)
                    }
                case .inProgress:
                    actionButton(
                        title: "Move to To Do",
                        systemImage: "arrow.counterclockwise",
                        prominent: false
                    ) {
                        viewModel.moveTaskToToDo(task.id)
                    }

                    actionButton(
                        title: "Done",
                        systemImage: "checkmark.circle.fill",
                        prominent: true
                    ) {
                        viewModel.completeTask(task.id)
                    }
                case .done:
                    actionButton(
                        title: "Reopen",
                        systemImage: "arrow.uturn.backward",
                        prominent: true
                    ) {
                        viewModel.reopenTask(task.id)
                    }
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

    @ViewBuilder
    private func actionButton(
        title: String,
        systemImage: String,
        prominent: Bool,
        action: @escaping () -> Void
    ) -> some View {
        if prominent {
            Button(action: action) {
                Label(title, systemImage: systemImage)
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .tint(Color.apartmentPlannerPrimaryAccent)
        } else {
            Button(action: action) {
                Label(title, systemImage: systemImage)
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.bordered)
            .tint(Color.apartmentPlannerSecondaryAccent)
        }
    }

    private func detailRow(label: String, value: String) -> some View {
        HStack(alignment: .firstTextBaseline, spacing: ApartmentPlannerTheme.Spacing.lg) {
            Text(label)
                .font(ApartmentPlannerTypography.secondaryBody)
                .foregroundStyle(Color.apartmentPlannerSecondaryText)

            Spacer(minLength: 0)

            Text(value)
                .font(ApartmentPlannerTypography.secondaryBody)
                .foregroundStyle(Color.apartmentPlannerPrimaryText)
                .multilineTextAlignment(.trailing)
                .fixedSize(horizontal: false, vertical: true)
        }
    }
}
