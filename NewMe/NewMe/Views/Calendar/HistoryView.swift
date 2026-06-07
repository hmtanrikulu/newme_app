import SwiftUI
import SwiftData

struct HistoryView: View {
    @Environment(\.modelContext) private var context

    @Query private var foodEntries: [FoodLogEntry]
    @Query private var fitnessEntries: [FitnessLogEntry]
    @Query private var spendEntries: [SpendLogEntry]
    @Query private var goalsRows: [UserGoals]

    @State private var month: Date = Calendar.current.startOfDay(for: .now)
    @State private var selected: Date = Calendar.current.startOfDay(for: .now)

    private var today: Date { Calendar.current.startOfDay(for: .now) }

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
            // Streak badge
            if streak >= 2 {
                Section {
                    HStack(spacing: 12) {
                        Image(systemName: "flame.fill")
                            .font(.title2)
                            .foregroundStyle(.orange)
                        VStack(alignment: .leading, spacing: 2) {
                            Text("\(streak) gün streak")
                                .font(.headline)
                            Text("Harika gidiyorsun!")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        Spacer()
                    }
                    .padding(.vertical, 4)
                }
            }

            // Month navigation + grid
            Section {
                monthHeader
                MonthGrid(
                    month: month,
                    today: today,
                    selected: $selected,
                    dayHasData: { rollup(on: $0).hasAnyData }
                )
                .padding(.bottom, 8)
            }

            // Selected day — tap to open detail
            Section("Seçili Gün") {
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

            // Spending chart
            Section("Harcama Grafiği") {
                SpendChart(entries: spendEntries)
                    .listRowInsets(EdgeInsets(top: 12, leading: 16, bottom: 12, trailing: 16))
                    .listRowBackground(Color.clear)
            }
        }
        .listStyle(.insetGrouped)
    }

    private var monthHeader: some View {
        HStack {
            Button {
                withAnimation {
                    month = Calendar.current.date(byAdding: .month, value: -1, to: month) ?? month
                }
            } label: {
                Image(systemName: "chevron.left")
                    .font(.body.weight(.semibold))
            }
            Spacer()
            Text(DateFormatters.monthYear.string(from: month).capitalized(with: Locale(identifier: "tr_TR")))
                .font(.headline)
            Spacer()
            Button {
                withAnimation {
                    month = Calendar.current.date(byAdding: .month, value: 1, to: month) ?? month
                }
            } label: {
                Image(systemName: "chevron.right")
                    .font(.body.weight(.semibold))
            }
            .disabled(Calendar.current.isDate(month, equalTo: today, toGranularity: .month))
        }
        .buttonStyle(.borderless)
    }
}
