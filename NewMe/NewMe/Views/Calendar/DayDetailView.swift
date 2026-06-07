import SwiftUI
import SwiftData

struct DayDetailView: View {
    let date: Date

    @Query private var allFoodEntries: [FoodLogEntry]
    @Query private var allFitnessEntries: [FitnessLogEntry]
    @Query private var allSpendEntries: [SpendLogEntry]
    @Query private var goalsRows: [UserGoals]

    private var goals: UserGoals { goalsRows.first ?? UserGoals() }

    private var kcal: Double {
        allFoodEntries.filter { Calendar.current.isDate($0.date, inSameDayAs: date) }
            .reduce(0) { $0 + $1.kcal }
    }

    private var totalSets: Int {
        allFitnessEntries.filter { Calendar.current.isDate($0.date, inSameDayAs: date) }
            .reduce(0) { $0 + $1.sets.count }
    }

    private var movements: Int {
        allFitnessEntries.filter { Calendar.current.isDate($0.date, inSameDayAs: date) && !$0.sets.isEmpty }
            .count
    }

    private var spend: Double {
        allSpendEntries.filter { Calendar.current.isDate($0.date, inSameDayAs: date) }
            .reduce(0) { $0 + $1.amount }
    }

    var body: some View {
        List {
            Section {
                NavigationLink {
                    FoodLogView(activeDate: date)
                } label: {
                    TodaySummaryRow(
                        icon: "fork.knife.circle.fill",
                        color: AppColor.food,
                        title: "Yemek",
                        primary: "\(Int(kcal.rounded())) kcal",
                        secondary: "Hedef: \(goals.kcal) kcal",
                        progress: goals.kcal > 0 ? min(1, kcal / Double(goals.kcal)) : 0
                    )
                }

                NavigationLink {
                    FitnessLogView(activeDate: date)
                } label: {
                    TodaySummaryRow(
                        icon: "dumbbell.fill",
                        color: AppColor.fitness,
                        title: "Antrenman",
                        primary: totalSets > 0 ? "\(totalSets) set · \(movements) hareket" : "Kayıt yok",
                        secondary: totalSets > 0 ? "\(movements) egzersiz" : "—",
                        progress: min(1, Double(totalSets) / 15.0)
                    )
                }

                NavigationLink {
                    SpendingLogView(activeDate: date)
                } label: {
                    TodaySummaryRow(
                        icon: "turkishlirasign.circle.fill",
                        color: AppColor.spending,
                        title: "Harcama",
                        primary: "₺\(Int(spend.rounded()))",
                        secondary: "Limit: ₺\(goals.dailySpendLimit)",
                        progress: goals.dailySpendLimit > 0 ? min(1, spend / Double(goals.dailySpendLimit)) : 0
                    )
                }
            } footer: {
                Text("Geçmiş kayıtları düzenleyebilir ve yeni giriş ekleyebilirsin.")
                    .font(.caption)
            }
        }
        .listStyle(.insetGrouped)
        .navigationTitle(navTitle)
        .navigationBarTitleDisplayMode(.large)
    }

    private var navTitle: String {
        let f = DateFormatter()
        f.locale = Locale(identifier: "tr_TR")
        f.dateFormat = "d MMMM"
        return f.string(from: date)
    }
}
