import SwiftUI

struct MacroCard: View {
    let label: String
    let current: Double
    let goal: Int
    let unit: String
    let tone: Color

    private var pct: Double {
        guard goal > 0 else { return 0 }
        return min(1, current / Double(goal))
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack(spacing: 5) {
                Circle().fill(tone).frame(width: 6, height: 6)
                Text(label)
                    .font(.system(size: 9.5, weight: .heavy))
                    .tracking(1)
                    .foregroundStyle(AppColor.text3)
                    .lineLimit(1)
            }
            HStack(alignment: .firstTextBaseline, spacing: 3) {
                Text("\(Int(current.rounded()))")
                    .font(.system(size: 18, weight: .semibold))
                    .monospacedDigit()
                    .tracking(-0.3)
                    .foregroundStyle(AppColor.textPrimary)
                Text("/\(goal)\(unit)")
                    .font(.system(size: 11, weight: .medium))
                    .monospacedDigit()
                    .foregroundStyle(AppColor.text3)
                    .lineLimit(1)
            }
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Capsule().fill(Color.white.opacity(0.07))
                    Capsule().fill(tone).frame(width: geo.size.width * pct)
                }
            }
            .frame(height: 3)
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 10)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 14)
                .fill(AppColor.surface)
                .overlay(
                    RoundedRectangle(cornerRadius: 14)
                        .stroke(Color.white.opacity(0.08), lineWidth: 1)
                )
        )
    }
}
