import SwiftUI

struct AppHeader: View {
    let kicker: String       // e.g. "BUGÜN"
    let title: String        // e.g. "3 Mayıs Pazar"
    let onCalendar: () -> Void
    let onSettings: () -> Void

    var body: some View {
        HStack(alignment: .bottom) {
            VStack(alignment: .leading, spacing: 2) {
                Text(kicker)
                    .font(.system(size: 11, weight: .semibold))
                    .tracking(1.2)
                    .foregroundStyle(AppColor.text3)
                Text(title)
                    .font(.system(size: 26, weight: .bold))
                    .tracking(-0.5)
                    .foregroundStyle(AppColor.textPrimary)
            }
            Spacer()
            HStack(spacing: 14) {
                IconButton(systemName: "calendar", action: onCalendar)
                IconButton(systemName: "gearshape", action: onSettings)
            }
            .padding(.bottom, 6)
        }
        .padding(.horizontal, 22)
        .padding(.top, 8)
        .padding(.bottom, 10)
    }
}

struct IconButton: View {
    let systemName: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Image(systemName: systemName)
                .font(.system(size: 20, weight: .regular))
                .foregroundStyle(AppColor.gold)
                .frame(width: 34, height: 34)
                .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}
