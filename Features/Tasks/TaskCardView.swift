import SwiftUI

struct TaskCardView: View {
    let model: TaskCardModel

    var body: some View {
        VStack(alignment: .leading, spacing: ApartmentPlannerTheme.Spacing.sm) {
            HStack(alignment: .top, spacing: ApartmentPlannerTheme.Spacing.md) {
                VStack(alignment: .leading, spacing: ApartmentPlannerTheme.Spacing.xs) {
                    Text(model.title)
                        .font(ApartmentPlannerTypography.body.weight(.semibold))
                        .foregroundStyle(Color.apartmentPlannerPrimaryText)
                        .fixedSize(horizontal: false, vertical: true)

                    Text(model.categoryName)
                        .font(ApartmentPlannerTypography.secondaryBody)
                        .foregroundStyle(Color.apartmentPlannerSecondaryText)
                        .fixedSize(horizontal: false, vertical: true)
                }

                Spacer(minLength: 0)

                TaskBadgeView(title: model.statusTitle, tone: model.statusTone)
            }

            HStack(alignment: .center, spacing: ApartmentPlannerTheme.Spacing.sm) {
                TaskBadgeView(title: model.assigneeTitle, tone: .neutral)

                if let duration = model.estimatedDurationTitle {
                    TaskBadgeView(title: duration, tone: .neutral)
                }
            }

            HStack(alignment: .center, spacing: ApartmentPlannerTheme.Spacing.sm) {
                if model.isHighPriority {
                    TaskBadgeView(title: "High priority", tone: .warning)
                }

                if model.isShopping {
                    TaskBadgeView(title: "Shopping", tone: .secondary)
                }

                if let readiness = model.readiness {
                    TaskBadgeView(title: readiness.title, tone: readiness.tone)
                }
            }

            if let blockerSummary = model.readiness?.blockerSummary {
                Text(blockerSummary)
                    .font(ApartmentPlannerTypography.secondaryBody)
                    .foregroundStyle(Color.apartmentPlannerSecondaryText)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .padding(ApartmentPlannerTheme.Spacing.lg)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.apartmentPlannerBackground.opacity(0.28), in: RoundedRectangle(cornerRadius: ApartmentPlannerTheme.CornerRadius.lg, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: ApartmentPlannerTheme.CornerRadius.lg, style: .continuous)
                .stroke(Color.apartmentPlannerBorder, lineWidth: 1)
        )
    }
}
