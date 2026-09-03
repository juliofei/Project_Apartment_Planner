import SwiftUI
import UIKit

enum ApartmentPlannerTheme {
    enum Colors {
        static let background = adaptiveColor(
            light: UIColor(red: 0.969, green: 0.949, blue: 0.914, alpha: 1.0),
            dark: UIColor(red: 0.101, green: 0.094, blue: 0.086, alpha: 1.0)
        )

        static let surface = adaptiveColor(
            light: UIColor(red: 0.991, green: 0.986, blue: 0.969, alpha: 1.0),
            dark: UIColor(red: 0.161, green: 0.145, blue: 0.133, alpha: 1.0)
        )

        static let primaryText = adaptiveColor(
            light: UIColor(red: 0.171, green: 0.136, blue: 0.108, alpha: 1.0),
            dark: UIColor(red: 0.956, green: 0.944, blue: 0.918, alpha: 1.0)
        )

        static let secondaryText = adaptiveColor(
            light: UIColor(red: 0.422, green: 0.365, blue: 0.310, alpha: 1.0),
            dark: UIColor(red: 0.783, green: 0.747, blue: 0.701, alpha: 1.0)
        )

        static let primaryAccent = adaptiveColor(
            light: UIColor(red: 0.474, green: 0.531, blue: 0.282, alpha: 1.0),
            dark: UIColor(red: 0.631, green: 0.706, blue: 0.408, alpha: 1.0)
        )

        static let secondaryAccent = adaptiveColor(
            light: UIColor(red: 0.551, green: 0.674, blue: 0.537, alpha: 1.0),
            dark: UIColor(red: 0.668, green: 0.777, blue: 0.646, alpha: 1.0)
        )

        static let attention = adaptiveColor(
            light: UIColor(red: 0.764, green: 0.596, blue: 0.240, alpha: 1.0),
            dark: UIColor(red: 0.859, green: 0.694, blue: 0.363, alpha: 1.0)
        )

        static let warning = adaptiveColor(
            light: UIColor(red: 0.717, green: 0.438, blue: 0.326, alpha: 1.0),
            dark: UIColor(red: 0.835, green: 0.562, blue: 0.451, alpha: 1.0)
        )

        static let border = adaptiveColor(
            light: UIColor(red: 0.842, green: 0.803, blue: 0.733, alpha: 1.0),
            dark: UIColor(red: 0.314, green: 0.281, blue: 0.252, alpha: 1.0)
        )
    }

    enum Spacing {
        static let xs: CGFloat = 4
        static let sm: CGFloat = 8
        static let md: CGFloat = 12
        static let lg: CGFloat = 20
        static let xl: CGFloat = 28
    }

    enum CornerRadius {
        static let sm: CGFloat = 10
        static let md: CGFloat = 16
        static let lg: CGFloat = 20
        static let xl: CGFloat = 28
    }

    private static func adaptiveColor(light: UIColor, dark: UIColor) -> Color {
        Color(uiColor: UIColor { traits in
            traits.userInterfaceStyle == .dark ? dark : light
        })
    }
}

extension Color {
    static let apartmentPlannerBackground = ApartmentPlannerTheme.Colors.background
    static let apartmentPlannerSurface = ApartmentPlannerTheme.Colors.surface
    static let apartmentPlannerPrimaryText = ApartmentPlannerTheme.Colors.primaryText
    static let apartmentPlannerSecondaryText = ApartmentPlannerTheme.Colors.secondaryText
    static let apartmentPlannerPrimaryAccent = ApartmentPlannerTheme.Colors.primaryAccent
    static let apartmentPlannerSecondaryAccent = ApartmentPlannerTheme.Colors.secondaryAccent
    static let apartmentPlannerAttention = ApartmentPlannerTheme.Colors.attention
    static let apartmentPlannerWarning = ApartmentPlannerTheme.Colors.warning
    static let apartmentPlannerBorder = ApartmentPlannerTheme.Colors.border
}

