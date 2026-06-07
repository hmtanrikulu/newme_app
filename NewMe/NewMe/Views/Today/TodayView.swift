import SwiftUI
import SwiftData

struct TodayView: View {
    @Binding var activeDate: Date

    @Query private var allFoodEntries: [FoodLogEntry]
    @Query private var allFitnessEntries: [FitnessLogEntry]
    @Query private var allSpendEntries: [SpendLogEntry]
    @Query private var goalsRows: [UserGoals]

    private var goals: UserGoals { goalsRows.first ?? UserGoals() }

    // MARK: — Aggregates

    private var kcalToday: Double {
        dayFood.reduce(0) { $0 + $1.kcal }
    }

    private var proteinToday: Double {
        dayFood.reduce(0) { $0 + $1.protein }
    }

    private var dayFood: [FoodLogEntry] {
        allFoodEntries.filter { Calendar.current.isDate($0.date, inSameDayAs: activeDate) }
    }

    private var dayFitness: [FitnessLogEntry] {
        allFitnessEntries.filter { Calendar.current.isDate($0.date, inSameDayAs: activeDate) }
    }

    private var daySpend: [SpendLogEntry] {
        allSpendEntries.filter { Calendar.current.isDate($0.date, inSameDayAs: activeDate) }
    }

    private var totalSets: Int { dayFitness.reduce(0) { $0 + $1.sets.count } }
    private var movements: Int { dayFitness.filter { !$0.sets.isEmpty }.count }
    private var spendTotal: Double { daySpend.reduce(0) { $0 + $1.amount } }

    private var kcalProgress: Double { goals.kcal > 0 ? min(1, kcalToday / Double(goals.kcal)) : 0 }
    private var spendProgress: Double { goals.dailySpendLimit > 0 ? min(1, spendTotal / Double(goals.dailySpendLimit)) : 0 }
    private var fitnessProgress: Double { min(1, Double(totalSets) / 15.0) }

    var body: some View {
        List {
            // Rings hero
            Section {
                ringsRow
                    .listRowInsets(EdgeInsets(top: 12, leading: 0, bottom: 12, trailing: 0))
                    .listRowBackground(Color.clear)
            }

            // Food
            Section {
                NavigationLink {
                    FoodLogView(activeDate: activeDate)
                } label: {
                    TodaySummaryRow(
                        icon: "fork.knife.circle.fill",
                        color: AppColor.food,
                        title: "Yemek",
                        primary: "\(Int(kcalToday.rounded())) kcal",
                        secondary: "Hedef: \(goals.kcal) kcal",
                        progress: kcalProgress
                    )
                }
            }

            // Fitness
            Section {
                NavigationLink {
                    FitnessLogView(activeDate: activeDate)
                } label: {
                    TodaySummaryRow(
                        icon: "dumbbell.fill",
                        color: AppColor.fitness,
                        title: "Antrenman",
                        primary: totalSets > 0 ? "\(totalSets) set · \(movements) hareket" : "Antrenman yok",
                        secondary: totalSets > 0 ? "Protein: \(Int(proteinToday.rounded()))g" : "Başlamak için dokun",
                        progress: fitnessProgress
                    )
                }
            }

            // Spending
            Section {
                NavigationLink {
                    SpendingLogView(activeDate: activeDate)
                } label: {
                    TodaySummaryRow(
                        icon: "turkishlirasign.circle.fill",
                        color: AppColor.spending,
                        title: "Harcama",
                        primary: "₺\(Int(spendTotal.rounded()))",
                        secondary: "Limit: ₺\(goals.dailySpendLimit)",
                        progress: spendProgress
                    )
                }
            }
        }
        .listStyle(.insetGrouped)
    }

    // MARK: — Rings row

    private var ringsRow: some View {
        HStack(spacing: 0) {
            ringCell(
                progress: kcalProgress,
                color: AppColor.food,
                value: "\(Int(kcalToday.rounded()))",
                unit: "kcal",
                label: "KALORİ"
            )
            Divider().frame(height: 72)
            ringCell(
                progress: spendProgress,
                color: AppColor.spending,
                value: "₺\(Int(spendTotal.rounded()))",
                unit: "",
                label: "HARCAMA"
            )
            Divider().frame(height: 72)
            ringCell(
                progress: fitnessProgress,
                color: AppColor.fitness,
                value: "\(totalSets)",
                unit: "set",
                label: "FİTNESS"
            )
        }
        .padding(.vertical, 8)
    }

    private func ringCell(progress: Double, color: Color, value: String, unit: String, label: String) -> some View {
        VStack(spacing: 8) {
            ZStack {
                ActivityRing(progress: progress, color: color, ringWidth: 8, size: 66)
                VStack(spacing: 1) {
                    Text(value)
                        .font(.system(size: 12, weight: .bold))
                        .monospacedDigit()
                        .minimumScaleFactor(0.6)
                        .lineLimit(1)
                    if !unit.isEmpty {
                        Text(unit)
                            .font(.system(size: 9, weight: .medium))
                            .foregroundStyle(.secondary)
                    }
                }
            }
            Text(label)
                .font(.system(size: 10, weight: .semibold))
                .tracking(0.5)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
    }
}

// MARK: — Summary row (used in Today list)

struct TodaySummaryRow: View {
    let icon: String
    let color: Color
    let title: String
    let primary: String
    let secondary: String
    let progress: Double

    var body: some View {
        HStack(spacing: 14) {
            Image(systemName: icon)
                .font(.system(size: 22))
                .foregroundStyle(color)
                .frame(width: 32)

            VStack(alignment: .leading, spacing: 3) {
                Text(title)
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                Text(primary)
                    .font(.headline)
                    .monospacedDigit()
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 4) {
                Text(secondary)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .monospacedDigit()
                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        Capsule().fill(color.opacity(0.12))
                        Capsule().fill(color.opacity(0.8))
                            .frame(width: geo.size.width * progress)
                    }
                }
                .frame(width: 72, height: 4)
            }
        }
        .padding(.vertical, 4)
    }
}
