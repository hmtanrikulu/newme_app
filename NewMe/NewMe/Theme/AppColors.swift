import SwiftUI

enum AppColor {
    static let bg          = Color(hex: 0x000000)
    static let surface     = Color(hex: 0x1C1C1E)
    static let surface2    = Color(hex: 0x2C2C2E)
    static let surface3    = Color(hex: 0x3A3A3C)
    static let hairline    = Color.white.opacity(0.08)

    static let textPrimary = Color.white
    static let text2       = Color(red: 235/255, green: 235/255, blue: 245/255).opacity(0.6)
    static let text3       = Color(red: 235/255, green: 235/255, blue: 245/255).opacity(0.4)

    static let gold        = Color(hex: 0xC9A961)
    static let goldSoft    = Color(hex: 0xD4B872)
    static let goldDim     = Color(hex: 0xC9A961, opacity: 0.18)

    static let macroProt   = Color(hex: 0xFF6B6B)
    static let macroCarb   = Color(hex: 0x5AB7FF)
    static let macroFat    = Color(hex: 0xFFC857)

    static let danger      = Color(hex: 0xFF453A)
    static let success     = Color(hex: 0x34C759)
    static let info        = Color(hex: 0x0A84FF)
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
