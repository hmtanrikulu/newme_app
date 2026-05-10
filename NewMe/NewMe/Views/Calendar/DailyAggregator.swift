import Foundation

/// Per-day rollup used by CalendarView and TrendChart.
struct DayRollup: Identifiable, Equatable {
    let date: Date
    var kcal: Double = 0
    var protein: Double = 0
    var carbs: Double = 0
    var fat: Double = 0
    var setsByGroup: [String: Int] = [:]
    var spendByCategory: [SpendCategory: Double] = [:]

    var id: Date { date }
    var totalSets: Int { setsByGroup.values.reduce(0, +) }
    var totalSpend: Double { spendByCategory.values.reduce(0, +) }
    var hasAnyData: Bool { kcal > 0 || totalSets > 0 || totalSpend > 0 }
}

enum DailyAggregator {
    static func rollup(
        on day: Date,
        foodEntries: [FoodLogEntry],
        fitnessEntries: [FitnessLogEntry],
        spendEntries: [SpendLogEntry]
    ) -> DayRollup {
        let cal = Calendar.current
        let normalized = cal.startOfDay(for: day)
        var roll = DayRollup(date: normalized)

        for entry in foodEntries where cal.isDate(entry.date, inSameDayAs: normalized) {
            guard let item = entry.item else { continue }
            let q = Double(entry.quantity)
            roll.kcal    += q * item.kcalPerPortion
            roll.protein += q * item.proteinPerPortion
            roll.carbs   += q * item.carbsPerPortion
            roll.fat     += q * item.fatPerPortion
        }

        for entry in fitnessEntries where cal.isDate(entry.date, inSameDayAs: normalized) {
            let group = entry.exercise?.muscleGroup ?? "Diğer"
            roll.setsByGroup[group, default: 0] += entry.sets.count
        }

        for entry in spendEntries where cal.isDate(entry.date, inSameDayAs: normalized) {
            roll.spendByCategory[entry.category, default: 0] += entry.amount
        }

        return roll
    }

    static func last7Days(
        ending today: Date,
        foodEntries: [FoodLogEntry],
        fitnessEntries: [FitnessLogEntry],
        spendEntries: [SpendLogEntry]
    ) -> [DayRollup] {
        let cal = Calendar.current
        let base = cal.startOfDay(for: today)
        return (0..<7).reversed().map { offset in
            let day = cal.date(byAdding: .day, value: -offset, to: base)!
            return rollup(on: day,
                          foodEntries: foodEntries,
                          fitnessEntries: fitnessEntries,
                          spendEntries: spendEntries)
        }
    }
}
