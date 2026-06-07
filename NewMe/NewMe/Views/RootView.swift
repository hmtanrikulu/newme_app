import SwiftUI

struct RootView: View {
    var body: some View {
        TabView {
            TodayTab()
                .tabItem { Label("Bugün", systemImage: "house.fill") }

            HistoryTab()
                .tabItem { Label("Geçmiş", systemImage: "calendar") }

            SettingsNavTab()
                .tabItem { Label("Ayarlar", systemImage: "gearshape.fill") }
        }
    }
}

// MARK: — Tab containers

private struct TodayTab: View {
    @State private var activeDate = Calendar.current.startOfDay(for: .now)
    @State private var showDatePicker = false

    var body: some View {
        NavigationStack {
            TodayView(activeDate: $activeDate)
                .navigationTitle(isToday ? "Bugün" : shortDate)
                .navigationBarTitleDisplayMode(.large)
                .toolbar {
                    ToolbarItem(placement: .topBarTrailing) {
                        Button {
                            showDatePicker = true
                        } label: {
                            Image(systemName: isToday ? "calendar" : "calendar.badge.clock")
                        }
                    }
                    if !isToday {
                        ToolbarItem(placement: .topBarLeading) {
                            Button("Bugün") {
                                withAnimation { activeDate = Calendar.current.startOfDay(for: .now) }
                            }
                        }
                    }
                }
                .sheet(isPresented: $showDatePicker) {
                    DatePickerSheet(selection: $activeDate)
                }
        }
    }

    private var isToday: Bool {
        Calendar.current.isDateInToday(activeDate)
    }

    private var shortDate: String {
        let f = DateFormatter()
        f.locale = Locale(identifier: "tr_TR")
        f.dateFormat = "d MMM"
        return f.string(from: activeDate)
    }
}

private struct HistoryTab: View {
    var body: some View {
        NavigationStack {
            HistoryView()
                .navigationTitle("Geçmiş")
                .navigationBarTitleDisplayMode(.large)
        }
    }
}

private struct SettingsNavTab: View {
    var body: some View {
        NavigationStack {
            SettingsView()
                .navigationTitle("Ayarlar")
                .navigationBarTitleDisplayMode(.large)
        }
    }
}

// MARK: — Date picker sheet

private struct DatePickerSheet: View {
    @Binding var selection: Date
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            DatePicker(
                "Tarih",
                selection: $selection,
                in: ...Date.now,
                displayedComponents: .date
            )
            .datePickerStyle(.graphical)
            .padding()
            .navigationTitle("Tarih Seç")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Tamam") { dismiss() }
                        .fontWeight(.semibold)
                }
            }
        }
        .presentationDetents([.medium])
    }
}

#Preview {
    RootView()
        .modelContainer(for: [
            FoodItem.self, ExerciseItem.self,
            FoodLogEntry.self, FitnessLogEntry.self,
            WorkoutSession.self,
            SpendLogEntry.self, UserGoals.self,
            ManualFoodEntry.self,
        ], inMemory: true)
}
