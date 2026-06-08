import SwiftUI

enum AppColor {
    // Backgrounds — system grouped style (adapts light/dark)
    static let bg       = Color(UIColor.systemGroupedBackground)
    static let surface  = Color(UIColor.secondarySystemGroupedBackground)
    static let surface2 = Color(UIColor.tertiarySystemGroupedBackground)
    static let hairline = Color(UIColor.separator)

    // Text — semantic, auto light/dark
    static let textPrimary = Color.primary
    static let text2       = Color.secondary
    static let text3       = Color(UIColor.tertiaryLabel)

    // Brand accent — purple (MacroFactor-style); set once via .tint()
    static let accent   = Color.accentColor
    static let gold     = Color.accentColor         // legacy alias
    static let goldSoft = Color.accentColor
    static let goldDim  = Color.accentColor.opacity(0.15)

    // Macro colors — MacroFactor palette
    static let macroProt = Color(red: 0.25, green: 0.55, blue: 0.95)  // blue
    static let macroCarb = Color(red: 0.98, green: 0.60, blue: 0.15)  // orange
    static let macroFat  = Color(red: 0.22, green: 0.72, blue: 0.45)  // green

    // Domain colors
    static let food     = Color(red: 0.25, green: 0.55, blue: 0.95)   // blue (protein=food)
    static let fitness  = Color(red: 0.22, green: 0.72, blue: 0.45)   // green
    static let spending = Color.accentColor                             // purple

    // Status
    static let danger  = Color.red
    static let success = Color(red: 0.22, green: 0.72, blue: 0.45)
    static let info    = Color.accentColor
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
