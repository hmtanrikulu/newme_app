import SwiftUI

struct SpendingLogView: View {
    let onCalendar: () -> Void
    let onSettings: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            AppHeader(
                kicker: "BUGÜN",
                title: "Harcama",
                onCalendar: onCalendar,
                onSettings: onSettings
            )
            Spacer()
            Text("Harcama (yapım aşamasında)")
                .foregroundStyle(AppColor.text3)
            Spacer()
        }
        .padding(.top, 54)
    }
}
