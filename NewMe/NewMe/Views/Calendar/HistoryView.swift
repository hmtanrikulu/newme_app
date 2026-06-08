import SwiftUI
import SwiftData

struct HistoryView: View {
    @Environment(\.modelContext) private var context

    @Query private var foodEntries: [FoodLogEntry]
    @Query private var fitnessEntries: [FitnessLogEntry]
    @Query private var spendEntries: [SpendLogEntry]
    @Query private var goalsRows: [UserGoals]

    @State private var selected: Date = Calendar.current.startOfDay(for: .now)

    private var today: Date { Calendar.current.startOfDay(for: .now) }
    private var goals: UserGoals { goalsRows.first ?? UserGoals() }

    private var displayMonth: Date {
        let c = Calendar.current.dateComponents([.year, .month], from: selected)
        return Calendar.current.date(from: c) ?? selected
    }

    private var stats: (spend: Double, workouts: Int, avgKcal: Double) {
        DailyAggregator.monthStats(
            month: displayMonth,
            foodEntries: foodEntries,
            fitnessEntries: fitnessEntries,
            spendEntries: spendEntries
        )
    }

    private var streak: Int {
        DailyAggregator.currentStreak(
            foodEntries: foodEntries,
            manualEntries: [],
            fitnessEntries: fitnessEntries,
            spendEntries: spendEntries
        )
    }

    private func rollup(on day: Date) -> DayRollup {
        DailyAggregator.rollup(
            on: day,
            foodEntries: foodEntries,
            fitnessEntries: fitnessEntries,
            spendEntries: spendEntries
        )
    }

    var body: some View {
        List {
            // ── Monthly stats header ──
            Section {
                monthStatsRow
            }

            // ── Week strip + streak ──
            Section {
                if streak >= 2 {
                    HStack(spacing: 10) {
                        Image(systemName: "flame.fill").foregroundStyle(.orange)
                        Text("\(streak) gün streak").font(.subheadline.weight(.semibold))
                        Spacer()
                        Text("Harika!").font(.caption).foregroundStyle(.secondary)
                    }
                }
                WeekStrip(
                    selected: $selected,
                    today: today,
                    dayHasData: { rollup(on: $0).hasAnyData }
                )
                .listRowInsets(EdgeInsets(top: 4, leading: 8, bottom: 4, trailing: 8))
            }

            // ── Selected day ──
            Section(dayTitle) {
                NavigationLink {
                    DayDetailView(date: selected)
                } label: {
                    DaySummaryCard(
                        day: rollup(on: selected),
                        isToday: Calendar.current.isDate(selected, inSameDayAs: today),
                        onOpenForEditing: { }
                    )
                    .listRowInsets(EdgeInsets())
                }
                .listRowBackground(Color.clear)
                .listRowInsets(EdgeInsets())
            }

            // ── Spending chart ──
            Section("Harcama Grafiği") {
                SpendChart(entries: spendEntries)
                    .listRowInsets(EdgeInsets(top: 12, leading: 16, bottom: 12, trailing: 16))
                    .listRowBackground(Color.clear)
            }

            // ── Calorie chart ──
            Section("Kalori Trendi") {
                CalorieChart(entries: foodEntries, goalKcal: goals.kcal)
                    .listRowInsets(EdgeInsets(top: 12, leading: 16, bottom: 12, trailing: 16))
                    .listRowBackground(Color.clear)
            }
        }
        .listStyle(.insetGrouped)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                if !Calendar.current.isDateInToday(selected) {
                    Button("Bugün") {
                        withAnimation { selected = today }
                    }
                    .font(.subheadline.weight(.semibold))
                }
            }
        }
    }

    // MARK: — Month stats row

    private var monthStatsRow: some View {
        let monthFmt: DateFormatter = {
            let f = DateFormatter()
            f.locale = Locale(identifier: "tr_TR")
            f.dateFormat = "MMMM yyyy"
            return f
        }()

        return VStack(spacing: 10) {
            Text(monthFmt.string(from: displayMonth).capitalized(with: Locale(identifier: "tr_TR")))
                .font(.footnote.weight(.semibold))
                .foregroundStyle(.secondary)
                .frame(maxWidth: .infinity, alignment: .leading)

            HStack(spacing: 0) {
                statChip(
                    icon: "turkishlirasign.circle.fill",
                    color: AppColor.spending,
                    value: "₺\(Int(stats.spend.rounded()))",
                    label: "harcama"
                )
                Divider().frame(height: 30)
                statChip(
                    icon: "dumbbell.fill",
                    color: AppColor.fitness,
                    value: "\(stats.workouts)",
                    label: "antrenman"
                )
                Divider().frame(height: 30)
                statChip(
                    icon: "fork.knife.circle.fill",
                    color: AppColor.food,
                    value: "\(Int(stats.avgKcal.rounded()))",
                    label: "ort. kcal"
                )
            }
        }
        .padding(.vertical, 4)
    }

    private func statChip(icon: String, color: Color, value: String, label: String) -> some View {
        VStack(spacing: 3) {
            Image(systemName: icon)
                .foregroundStyle(color)
                .font(.title3)
            Text(value)
                .font(.headline)
                .monospacedDigit()
            Text(label)
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
    }

    // MARK: — Helpers

    private var dayTitle: String {
        let f = DateFormatter()
        f.locale = Locale(identifier: "tr_TR")
        f.dateFormat = "d MMMM"
        return f.string(from: selected)
    }
}
