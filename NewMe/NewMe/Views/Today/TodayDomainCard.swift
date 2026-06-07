import SwiftUI

struct TodayDomainCard: View {
    let icon: String
    let title: String
    let color: Color
    let primaryText: String
    let secondaryText: String
    let progress: Double
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 14) {
                Image(systemName: icon)
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundStyle(color)
                    .frame(width: 40, height: 40)
                    .background(Circle().fill(color.opacity(0.12)))

                VStack(alignment: .leading, spacing: 3) {
                    Text(title)
                        .font(.system(size: 12, weight: .semibold))
                        .tracking(0.3)
                        .foregroundStyle(AppColor.text2)
                    Text(primaryText)
                        .font(.system(size: 18, weight: .bold))
                        .monospacedDigit()
                        .foregroundStyle(AppColor.textPrimary)
                }

                Spacer()

                VStack(alignment: .trailing, spacing: 6) {
                    Text(secondaryText)
                        .font(.system(size: 11))
                        .monospacedDigit()
                        .foregroundStyle(AppColor.text3)
                    HStack(spacing: 8) {
                        GeometryReader { geo in
                            ZStack(alignment: .leading) {
                                Capsule().fill(color.opacity(0.1))
                                Capsule().fill(color.opacity(0.75))
                                    .frame(width: geo.size.width * min(1, max(0, progress)))
                            }
                        }
                        .frame(width: 60, height: 4)
                        Image(systemName: "chevron.right")
                            .font(.system(size: 11, weight: .semibold))
                            .foregroundStyle(AppColor.text3)
                    }
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
            .background(RoundedRectangle(cornerRadius: 14).fill(AppColor.surface))
        }
        .buttonStyle(.plain)
    }
}
