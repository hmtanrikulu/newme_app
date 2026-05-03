import SwiftUI

struct SettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var tab: SettingsTab = .food

    var body: some View {
        NavigationStack {
            ZStack {
                AppColor.bg.ignoresSafeArea()
                VStack(spacing: 0) {
                    SettingsTabPicker(selection: $tab)
                    Group {
                        switch tab {
                        case .food:     FoodCatalogTab()
                        case .exercise: ExerciseCatalogTab()
                        case .goals:    GoalsTab()
                        }
                    }
                }
            }
            .navigationTitle("Ayarlar")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Bitti") { dismiss() }
                        .foregroundStyle(AppColor.gold)
                        .fontWeight(.semibold)
                }
            }
            .toolbarBackground(AppColor.bg, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
        }
    }
}
