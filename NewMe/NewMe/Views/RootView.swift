import SwiftUI

struct RootView: View {
    @State private var tab: AppTab = .today
    @State private var showCalendar = false
    @State private var showSettings = false
    @State private var showLogSheet = false
    @State private var activeDate: Date = Calendar.current.startOfDay(for: .now)

    private var isToday: Bool {
        Calendar.current.isDate(activeDate, inSameDayAs: .now)
    }

    var body: some View {
        ZStack(alignment: .bottom) {
            AppColor.bg.ignoresSafeArea()

            Group {
                switch tab {
                case .today:
                    TodayView(
                        activeDate: activeDate,
                        onOpenFood:    { tab = .food },
                        onOpenFitness: { tab = .fit },
                        onOpenSpend:   { tab = .spend },
                        onCalendar:    openCalendar,
                        onSettings:    openSettings,
                        onShowLogSheet: { showLogSheet = true }
                    )
                case .food:
                    FoodLogView(
                        activeDate: activeDate,
                        isToday: isToday,
                        onBackToToday: backToToday,
                        onCalendar: openCalendar,
                        onSettings: openSettings
                    )
                case .fit:
                    FitnessLogView(
                        activeDate: activeDate,
                        isToday: isToday,
                        onBackToToday: backToToday,
                        onCalendar: openCalendar,
                        onSettings: openSettings
                    )
                case .spend:
                    SpendingLogView(
                        activeDate: activeDate,
                        isToday: isToday,
                        onBackToToday: backToToday,
                        onCalendar: openCalendar,
                        onSettings: openSettings
                    )
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
            .padding(.bottom, 64)

            CustomTabBar(selection: $tab, onFAB: { showLogSheet = true })
        }
        .sheet(isPresented: $showCalendar) {
            CalendarView(
                initialSelection: activeDate,
                onOpenForEditing: { date in
                    activeDate = Calendar.current.startOfDay(for: date)
                    showCalendar = false
                }
            )
            .preferredColorScheme(.dark)
        }
        .sheet(isPresented: $showSettings) {
            SettingsView()
                .preferredColorScheme(.dark)
        }
        .sheet(isPresented: $showLogSheet) {
            UniversalLogSheet(
                onOpenFood:    { tab = .food },
                onOpenFitness: { tab = .fit },
                onOpenSpend:   { tab = .spend }
            )
        }
    }

    private func openCalendar() { showCalendar = true }
    private func openSettings() { showSettings = true }
    private func backToToday() {
        activeDate = Calendar.current.startOfDay(for: .now)
    }
}

#Preview {
    RootView()
        .modelContainer(for: [
            FoodItem.self, ExerciseItem.self,
            FoodLogEntry.self, FitnessLogEntry.self,
            SpendLogEntry.self, UserGoals.self,
            ManualFoodEntry.self,
        ], inMemory: true)
}
