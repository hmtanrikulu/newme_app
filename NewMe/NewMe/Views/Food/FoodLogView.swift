import SwiftUI

struct FoodLogView: View {
    let onCalendar: () -> Void
    let onSettings: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            AppHeader(
                kicker: "BUGÜN",
                title: DateFormatters.dateLabel.string(from: .now),
                onCalendar: onCalendar,
                onSettings: onSettings
            )
            Spacer()
            Text("Yemek (yapım aşamasında)")
                .foregroundStyle(AppColor.text3)
            Spacer()
        }
        .padding(.top, 54)
    }
}
