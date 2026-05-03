import SwiftUI
import SwiftData

struct CalendarView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var context

    @Query private var foodEntries: [FoodLogEntry]
    @Query private var fitnessEntries: [FitnessLogEntry]
    @Query private var spendEntries: [SpendLogEntry]
    @Query private var goalsRows: [UserGoals]

    @State private var month: Date = Calendar.current.startOfDay(for: .now)
    @State private var selected: Date = Calendar.current.startOfDay(for: .now)

    private var goalKcal: Int { goalsRows.first?.kcal ?? 2400 }
    private var today: Date { Calendar.current.startOfDay(for: .now) }

    private func rollup(on day: Date) -> DayRollup {
        DailyAggregator.rollup(
            on: day,
            foodEntries: foodEntries,
            fitnessEntries: fitnessEntries,
            spendEntries: spendEntries
        )
    }

    private var last7: [DayRollup] {
        DailyAggregator.last7Days(
            ending: .now,
            foodEntries: foodEntries,
            fitnessEntries: fitnessEntries,
            spendEntries: spendEntries
        )
    }

    var body: some View {
        NavigationStack {
            ZStack(alignment: .top) {
                AppColor.bg.ignoresSafeArea()
                ScrollView {
                    VStack(spacing: 0) {
                        monthHeader
                        MonthGrid(
                            month: month,
                            today: today,
                            selected: $selected,
                            dayHasData: { rollup(on: $0).hasAnyData }
                        )
                        .padding(.bottom, 14)

                        DaySummaryCard(
                            day: rollup(on: selected),
                            isToday: Calendar.current.isDate(selected, inSameDayAs: today)
                        )
                        .padding(.horizontal, 16)
                        .padding(.bottom, 14)

                        TrendChart(days: last7, goalKcal: goalKcal, selected: $selected)
                            .padding(.horizontal, 16)
                            .padding(.bottom, 30)
                    }
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        selected = today
                        month = today
                    } label: {
                        HStack(spacing: 4) {
                            Image(systemName: "chevron.left")
                                .font(.system(size: 12, weight: .semibold))
                            Text("Bugün")
                        }
                        .foregroundStyle(AppColor.gold)
                    }
                }
                ToolbarItem(placement: .principal) {
                    Text(DateFormatters.monthYear.string(from: month).capitalized(with: Locale(identifier: "tr_TR")))
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundStyle(AppColor.textPrimary)
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Kapat") { dismiss() }
                        .foregroundStyle(AppColor.gold)
                }
            }
            .toolbarBackground(AppColor.bg, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
        }
    }

    private var monthHeader: some View {
        HStack {
            Spacer()
            Button {
                month = Calendar.current.date(byAdding: .month, value: -1, to: month) ?? month
            } label: {
                Image(systemName: "chevron.left")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(AppColor.gold)
                    .frame(width: 34, height: 34)
            }
            .buttonStyle(.plain)
            Button {
                month = Calendar.current.date(byAdding: .month, value: 1, to: month) ?? month
            } label: {
                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(AppColor.gold)
                    .frame(width: 34, height: 34)
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, 16)
        .padding(.top, 4)
        .padding(.bottom, 8)
    }
}
