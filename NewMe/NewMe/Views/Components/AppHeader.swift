import SwiftUI

struct AppHeader: View {
    let kicker: String       // e.g. "BUGÜN"
    let title: String        // e.g. "3 Mayıs Pazar"
    let showBackToToday: Bool
    let onBackToToday: (() -> Void)?
    let onCalendar: () -> Void
    let onSettings: () -> Void

    init(
        kicker: String,
        title: String,
        showBackToToday: Bool = false,
        onBackToToday: (() -> Void)? = nil,
        onCalendar: @escaping () -> Void,
        onSettings: @escaping () -> Void
    ) {
        self.kicker = kicker
        self.title = title
        self.showBackToToday = showBackToToday
        self.onBackToToday = onBackToToday
        self.onCalendar = onCalendar
        self.onSettings = onSettings
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack(alignment: .bottom) {
                VStack(alignment: .leading, spacing: 2) {
                    Text(kicker)
                        .font(.system(size: 11, weight: .semibold))
                        .tracking(1.2)
                        .foregroundStyle(showBackToToday ? AppColor.gold : AppColor.text3)
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

            if showBackToToday, let onBackToToday {
                Button(action: onBackToToday) {
                    HStack(spacing: 4) {
                        Image(systemName: "arrow.uturn.left")
                            .font(.system(size: 10, weight: .semibold))
                        Text("Bugüne dön")
                            .font(.system(size: 12, weight: .semibold))
                    }
                    .foregroundStyle(AppColor.gold)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 5)
                    .background(
                        Capsule().fill(AppColor.gold.opacity(0.15))
                            .overlay(Capsule().stroke(AppColor.gold.opacity(0.4), lineWidth: 1))
                    )
                }
                .buttonStyle(.plain)
            }
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
