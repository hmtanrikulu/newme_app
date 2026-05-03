import SwiftUI

struct CalendarView: View {
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ZStack {
                AppColor.bg.ignoresSafeArea()
                Text("Takvim (yapım aşamasında)")
                    .foregroundStyle(AppColor.text3)
            }
            .navigationTitle("Takvim")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Bugün") { dismiss() }
                        .foregroundStyle(AppColor.gold)
                }
            }
        }
    }
}
