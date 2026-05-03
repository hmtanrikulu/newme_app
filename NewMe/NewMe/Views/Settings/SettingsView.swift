import SwiftUI

struct SettingsView: View {
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ZStack {
                AppColor.bg.ignoresSafeArea()
                Text("Ayarlar (yapım aşamasında)")
                    .foregroundStyle(AppColor.text3)
            }
            .navigationTitle("Ayarlar")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Bitti") { dismiss() }
                        .foregroundStyle(AppColor.gold)
                }
            }
        }
    }
}
