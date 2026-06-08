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

    static func monthStats(
        month: Date,
        foodEntries: [FoodLogEntry],
        fitnessEntries: [FitnessLogEntry],
        spendEntries: [SpendLogEntry]
    ) -> (spend: Double, workouts: Int, avgKcal: Double) {
        let cal = Calendar.current
        guard
            let monthStart = cal.date(from: cal.dateComponents([.year, .month], from: month)),
            let nextMonth  = cal.date(byAdding: .month, value: 1, to: monthStart)
        else { return (0, 0, 0) }

        let spend = spendEntries
            .filter { $0.date >= monthStart && $0.date < nextMonth }
            .reduce(0) { $0 + $1.amount }

        let workoutDays = Set(
            fitnessEntries
                .filter { !$0.sets.isEmpty && $0.date >= monthStart && $0.date < nextMonth }
                .map { cal.startOfDay(for: $0.date) }
        ).count

        let daysInMonth = cal.range(of: .day, in: .month, for: monthStart)!.count
        var kcalPerDay: [Double] = []
        for d in 0..<daysInMonth {
            guard let day = cal.date(byAdding: .day, value: d, to: monthStart),
                  let end = cal.date(byAdding: .day, value: 1, to: day) else { continue }
            let total = foodEntries
                .filter { $0.date >= day && $0.date < end }
                .reduce(0) { $0 + $1.kcal }
            if total > 0 { kcalPerDay.append(total) }
        }
        let avgKcal = kcalPerDay.isEmpty ? 0 : kcalPerDay.reduce(0, +) / Double(kcalPerDay.count)

        return (spend, workoutDays, avgKcal)
    }

    /// Consecutive days from today backwards where any data was logged.
    static func currentStreak(
        foodEntries: [FoodLogEntry],
        manualEntries: [ManualFoodEntry],
        fitnessEntries: [FitnessLogEntry],
        spendEntries: [SpendLogEntry]
    ) -> Int {
        let cal = Calendar.current
        var streak = 0
        var day = cal.startOfDay(for: .now)
        for _ in 0..<365 {
            let hasFood    = foodEntries.contains    { cal.isDate($0.date, inSameDayAs: day) }
            let hasManual  = manualEntries.contains  { cal.isDate($0.date, inSameDayAs: day) }
            let hasFitness = fitnessEntries.contains { cal.isDate($0.date, inSameDayAs: day) }
            let hasSpend   = spendEntries.contains   { cal.isDate($0.date, inSameDayAs: day) }
            guard hasFood || hasManual || hasFitness || hasSpend else { break }
            streak += 1
            day = cal.date(byAdding: .day, value: -1, to: day)!
        }
        return streak
    }
}
