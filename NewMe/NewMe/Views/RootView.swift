import SwiftUI

struct RootView: View {
    @State private var tab: AppTab = .food
    @State private var showCalendar = false
    @State private var showSettings = false

    var body: some View {
        ZStack(alignment: .bottom) {
            AppColor.bg.ignoresSafeArea()

            Group {
                switch tab {
                case .food:  FoodLogView(onCalendar: openCalendar, onSettings: openSettings)
                case .fit:   FitnessLogView(onCalendar: openCalendar, onSettings: openSettings)
                case .spend: SpendingLogView(onCalendar: openCalendar, onSettings: openSettings)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
            .padding(.bottom, 64)   // tab bar overlay

            CustomTabBar(selection: $tab)
        }
        .sheet(isPresented: $showCalendar) {
            CalendarView()
                .preferredColorScheme(.dark)
        }
        .sheet(isPresented: $showSettings) {
            SettingsView()
                .preferredColorScheme(.dark)
        }
    }

    private func openCalendar() { showCalendar = true }
    private func openSettings() { showSettings = true }
}

#Preview {
    RootView()
        .modelContainer(for: [
            FoodItem.self, ExerciseItem.self,
            FoodLogEntry.self, FitnessLogEntry.self,
            SpendLogEntry.self, UserGoals.self,
        ], inMemory: true)
}
