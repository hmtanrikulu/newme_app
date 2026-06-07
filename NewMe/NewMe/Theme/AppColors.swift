import SwiftUI

// System-adaptive color palette — works in both light and dark mode.
// AppColor.accent is the single brand color; everything else defers to system.
enum AppColor {
    // Backgrounds — system grouped style
    static let bg       = Color(UIColor.systemGroupedBackground)
    static let surface  = Color(UIColor.secondarySystemGroupedBackground)
    static let surface2 = Color(UIColor.tertiarySystemGroupedBackground)
    static let hairline = Color(UIColor.separator)

    // Text — semantic, auto dark/light
    static let textPrimary = Color.primary
    static let text2       = Color.secondary
    static let text3       = Color(UIColor.tertiaryLabel)

    // Brand accent — warm amber; set app .tint() once to propagate everywhere
    static let accent    = Color.accentColor
    static let gold      = Color.accentColor         // legacy alias
    static let goldSoft  = Color.accentColor
    static let goldDim   = Color.accentColor.opacity(0.15)

    // Macro colors — semantic
    static let macroProt = Color.red
    static let macroCarb = Color.blue
    static let macroFat  = Color.orange

    // Domain colors
    static let food     = Color.orange
    static let fitness  = Color.green
    static let spending = Color.blue

    // Status
    static let danger  = Color.red
    static let success = Color.green
    static let info    = Color.blue
}

enum AppFont {
    static func display(_ size: CGFloat, weight: Font.Weight = .bold) -> Font {
        .system(size: size, weight: weight, design: .default)
    }
    static func body(_ size: CGFloat, weight: Font.Weight = .regular) -> Font {
        .system(size: size, weight: weight, design: .default)
    }
    static func mono(_ size: CGFloat, weight: Font.Weight = .semibold) -> Font {
        .system(size: size, weight: weight, design: .default)
            .monospacedDigit()
    }
}
