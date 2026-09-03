import SwiftUI

struct FeatureShellView: View {
    let title: String
    let subtitle: String
    let symbol: String
    let accent: Color

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
                    HStack(alignment: .top, spacing: ApartmentPlannerTheme.Spacing.md) {
                        Image(systemName: symbol)
                            .font(.title2.weight(.semibold))
                            .foregroundStyle(accent)
                            .padding(ApartmentPlannerTheme.Spacing.sm)
                            .background(accent.opacity(0.14), in: RoundedRectangle(cornerRadius: ApartmentPlannerTheme.CornerRadius.md, style: .continuous))

                        VStack(alignment: .leading, spacing: ApartmentPlannerTheme.Spacing.sm) {
                            Text(title)
                                .font(ApartmentPlannerTypography.screenTitle)
                                .foregroundStyle(Color.apartmentPlannerPrimaryText)

                            Text(subtitle)
                                .font(ApartmentPlannerTypography.secondaryBody)
                                .foregroundStyle(Color.apartmentPlannerSecondaryText)
                                .fixedSize(horizontal: false, vertical: true)
                        }

                        Spacer(minLength: 0)
                    }

                    VStack(alignment: .leading, spacing: ApartmentPlannerTheme.Spacing.sm) {
                        Text("Task 00 baseline")
                            .font(ApartmentPlannerTypography.badge)
                            .foregroundStyle(accent)

                        Text("This screen is a shell only. Product logic will be added in later tasks after the architecture is stable.")
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
                .padding(ApartmentPlannerTheme.Spacing.lg)
                .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
    }
}

