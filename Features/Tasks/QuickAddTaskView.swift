import SwiftUI

struct QuickAddTaskView: View {
    @ObservedObject var viewModel: TaskListViewModel
    @Environment(\.dismiss) private var dismiss

    @State private var title = ""
    @State private var selectedCategoryID: Category.ID?
    @State private var selectedAssigneeID: User.ID?
    @State private var attemptedSave = false
    @FocusState private var isTitleFocused: Bool

    var body: some View {
        NavigationStack {
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
                        Text("Add a task")
                            .font(ApartmentPlannerTypography.screenTitle)
                            .foregroundStyle(Color.apartmentPlannerPrimaryText)

                        quickAddIntroCard
                        quickAddFormCard
                        suggestionsCard
                    }
                    .padding(ApartmentPlannerTheme.Spacing.lg)
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
            }
            .navigationTitle("Quick Add")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button("Add") {
                        saveTask()
                    }
                    .fontWeight(.semibold)
                }
            }
            .onAppear {
                isTitleFocused = true
            }
        }
    }

    private var quickAddIntroCard: some View {
        VStack(alignment: .leading, spacing: ApartmentPlannerTheme.Spacing.sm) {
            Text("Keeps only local state for now")
                .font(ApartmentPlannerTypography.badge)
                .foregroundStyle(Color.apartmentPlannerPrimaryAccent)

            Text("Title and Category are required. Assignee is optional, and suggestions stay deterministic.")
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

    private var quickAddFormCard: some View {
        VStack(alignment: .leading, spacing: ApartmentPlannerTheme.Spacing.lg) {
            VStack(alignment: .leading, spacing: ApartmentPlannerTheme.Spacing.sm) {
                Text("Title")
                    .font(ApartmentPlannerTypography.badge)
                    .foregroundStyle(Color.apartmentPlannerPrimaryText)

                TextField("Task title", text: $title)
                    .textInputAutocapitalization(.sentences)
                    .submitLabel(.done)
                    .padding(.horizontal, ApartmentPlannerTheme.Spacing.md)
                    .padding(.vertical, ApartmentPlannerTheme.Spacing.md)
                    .background(Color.apartmentPlannerBackground, in: RoundedRectangle(cornerRadius: ApartmentPlannerTheme.CornerRadius.md, style: .continuous))
                    .overlay(
                        RoundedRectangle(cornerRadius: ApartmentPlannerTheme.CornerRadius.md, style: .continuous)
                            .stroke(Color.apartmentPlannerBorder, lineWidth: 1)
                    )
                .focused($isTitleFocused)

                if shouldShowTitleError {
                    Text("Title is required.")
                        .font(ApartmentPlannerTypography.secondaryBody)
                        .foregroundStyle(Color.apartmentPlannerWarning)
                }
            }

            VStack(alignment: .leading, spacing: ApartmentPlannerTheme.Spacing.sm) {
                Text("Category")
                    .font(ApartmentPlannerTypography.badge)
                    .foregroundStyle(Color.apartmentPlannerPrimaryText)

                Picker("Category", selection: $selectedCategoryID) {
                    Text("Select a category").tag(nil as Category.ID?)
                    ForEach(viewModel.activeCategories) { category in
                        Text(category.name).tag(Optional(category.id))
                    }
                }
                .pickerStyle(.menu)

                if shouldShowCategoryError {
                    Text("Category is required.")
                        .font(ApartmentPlannerTypography.secondaryBody)
                        .foregroundStyle(Color.apartmentPlannerWarning)
                }
            }

            VStack(alignment: .leading, spacing: ApartmentPlannerTheme.Spacing.sm) {
                Text("Assignee")
                    .font(ApartmentPlannerTypography.badge)
                    .foregroundStyle(Color.apartmentPlannerPrimaryText)

                Picker("Assignee", selection: $selectedAssigneeID) {
                    Text("Unassigned").tag(nil as User.ID?)
                    ForEach(viewModel.users, id: \.id) { user in
                        Text(user.displayName).tag(Optional(user.id))
                    }
                }
                .pickerStyle(.menu)
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

    private var suggestionsCard: some View {
        let suggestions = viewModel.quickAddSuggestions(for: title, selectedCategoryID: selectedCategoryID)

        return Group {
            if !suggestions.isEmpty {
                VStack(alignment: .leading, spacing: ApartmentPlannerTheme.Spacing.sm) {
                    Text("Similar tasks")
                        .font(ApartmentPlannerTypography.badge)
                        .foregroundStyle(Color.apartmentPlannerPrimaryText)

                    VStack(alignment: .leading, spacing: ApartmentPlannerTheme.Spacing.sm) {
                        ForEach(suggestions) { suggestion in
                            Button {
                                title = suggestion.title
                            } label: {
                                HStack(alignment: .firstTextBaseline, spacing: ApartmentPlannerTheme.Spacing.md) {
                                    VStack(alignment: .leading, spacing: ApartmentPlannerTheme.Spacing.xs) {
                                        Text(suggestion.title)
                                            .font(ApartmentPlannerTypography.body.weight(.semibold))
                                            .foregroundStyle(Color.apartmentPlannerPrimaryText)
                                            .fixedSize(horizontal: false, vertical: true)

                                        Text(suggestion.categoryName)
                                            .font(ApartmentPlannerTypography.secondaryBody)
                                            .foregroundStyle(Color.apartmentPlannerSecondaryText)
                                    }

                                    Spacer(minLength: 0)

                                    Image(systemName: "arrow.up.right")
                                        .font(.caption.weight(.semibold))
                                        .foregroundStyle(Color.apartmentPlannerPrimaryAccent)
                                }
                                .padding(ApartmentPlannerTheme.Spacing.md)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .background(Color.apartmentPlannerBackground, in: RoundedRectangle(cornerRadius: ApartmentPlannerTheme.CornerRadius.md, style: .continuous))
                                .overlay(
                                    RoundedRectangle(cornerRadius: ApartmentPlannerTheme.CornerRadius.md, style: .continuous)
                                        .stroke(Color.apartmentPlannerBorder, lineWidth: 1)
                                )
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
    }

    private var shouldShowTitleError: Bool {
        attemptedSave && title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    private var shouldShowCategoryError: Bool {
        attemptedSave && selectedCategoryID == nil
    }

    private func saveTask() {
        attemptedSave = true

        guard !title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            return
        }

        guard selectedCategoryID != nil else {
            return
        }

        switch viewModel.addQuickTask(title: title, categoryID: selectedCategoryID, assigneeID: selectedAssigneeID) {
        case .success:
            dismiss()
        case .failure:
            break
        }
    }
}
