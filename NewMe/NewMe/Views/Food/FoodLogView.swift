import SwiftUI
import SwiftData

struct FoodLogView: View {
    let activeDate: Date
    let isToday: Bool
    let onBackToToday: () -> Void
    let onCalendar: () -> Void
    let onSettings: () -> Void

    @Environment(\.modelContext) private var context
    @Query(sort: [SortDescriptor(\FoodItem.sortOrder), SortDescriptor(\FoodItem.name)])
    private var foods: [FoodItem]
    @Query private var allFoodEntries: [FoodLogEntry]
    @Query private var goalsRows: [UserGoals]

    private var goals: UserGoals {
        goalsRows.first ?? UserGoals()
    }

    private var entriesByItem: [PersistentIdentifier: FoodLogEntry] {
        var result: [PersistentIdentifier: FoodLogEntry] = [:]
        for entry in allFoodEntries where Calendar.current.isDate(entry.date, inSameDayAs: activeDate) {
            if let id = entry.item?.persistentModelID {
                result[id] = entry
            }
        }
        return result
    }

    private func quantity(for food: FoodItem) -> Int {
        entriesByItem[food.persistentModelID]?.quantity ?? 0
    }

    private var totalKcal: Double {
        foods.reduce(0) { $0 + Double(quantity(for: $1)) * $1.kcalPerServing }
    }
    private var totalProtein: Double {
        foods.reduce(0) { $0 + Double(quantity(for: $1)) * $1.protein }
    }
    private var totalCarbs: Double {
        foods.reduce(0) { $0 + Double(quantity(for: $1)) * $1.carbs }
    }
    private var totalFat: Double {
        foods.reduce(0) { $0 + Double(quantity(for: $1)) * $1.fat }
    }

    private func adjust(_ food: FoodItem, by delta: Int) {
        if let entry = entriesByItem[food.persistentModelID] {
            let next = entry.quantity + delta
            if next <= 0 {
                context.delete(entry)
            } else {
                entry.quantity = next
            }
        } else if delta > 0 {
            context.insert(FoodLogEntry(date: activeDate, quantity: delta, item: food))
        }
        try? context.save()
    }

    var body: some View {
        VStack(spacing: 0) {
            AppHeader(
                kicker: DateFormatters.kicker(for: activeDate),
                title: DateFormatters.dateLabel.string(from: activeDate),
                showBackToToday: !isToday,
                onBackToToday: onBackToToday,
                onCalendar: onCalendar,
                onSettings: onSettings
            )
            calorieHeader
            foodList
            bottomSummary
        }
        .padding(.top, 54)
    }

    private var calorieHeader: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("KALORİ")
                    .font(.system(size: 11, weight: .semibold))
                    .tracking(1.2)
                    .foregroundStyle(AppColor.text3)
                Spacer()
                HStack(spacing: 0) {
                    Text("\(Int(totalKcal.rounded()))")
                        .font(.system(size: 15, weight: .semibold))
                        .monospacedDigit()
                        .foregroundStyle(AppColor.textPrimary)
                    Text(" / \(goals.kcal)")
                        .font(.system(size: 15))
                        .monospacedDigit()
                        .foregroundStyle(AppColor.text3)
                }
            }
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Capsule().fill(Color.white.opacity(0.08))
                    Capsule().fill(AppColor.gold)
                        .frame(width: geo.size.width * min(1, totalKcal / Double(goals.kcal)))
                }
            }
            .frame(height: 4)
        }
        .padding(.horizontal, 22)
        .padding(.bottom, 14)
    }

    private var foodList: some View {
        ScrollView {
            VStack(spacing: 8) {
                HStack {
                    Text("YİYECEK")
                    Spacer()
                    Text("ADET")
                }
                .font(.system(size: 11, weight: .semibold))
                .tracking(1)
                .foregroundStyle(AppColor.text3)
                .padding(.horizontal, 8)
                .padding(.bottom, 2)

                ForEach(foods) { food in
                    FoodRow(
                        food: food,
                        quantity: quantity(for: food),
                        onIncrement: { adjust(food, by: 1) },
                        onDecrement: { adjust(food, by: -1) }
                    )
                }
                Color.clear.frame(height: 16)
            }
            .padding(.horizontal, 16)
            .padding(.top, 4)
        }
    }

    private var bottomSummary: some View {
        VStack(alignment: .leading, spacing: 10) {
            VStack(alignment: .leading, spacing: 2) {
                Text("TOPLAM")
                    .font(.system(size: 10, weight: .heavy))
                    .tracking(1.4)
                    .foregroundStyle(AppColor.text3)
                HStack(alignment: .firstTextBaseline, spacing: 6) {
                    Text("\(Int(totalKcal.rounded()))")
                        .font(.system(size: 30, weight: .bold))
                        .tracking(-0.6)
                        .monospacedDigit()
                        .foregroundStyle(AppColor.textPrimary)
                    Text("kcal")
                        .font(.system(size: 18, weight: .medium))
                        .foregroundStyle(AppColor.text2)
                }
            }
            .padding(.horizontal, 6)

            HStack(spacing: 8) {
                MacroCard(label: "PROTEİN", current: totalProtein, goal: goals.protein, unit: "g", tone: AppColor.macroProt)
                MacroCard(label: "KARB.",   current: totalCarbs,   goal: goals.carbs,   unit: "g", tone: AppColor.macroCarb)
                MacroCard(label: "YAĞ",     current: totalFat,     goal: goals.fat,     unit: "g", tone: AppColor.macroFat)
            }
        }
        .padding(.horizontal, 16)
        .padding(.top, 14)
        .padding(.bottom, 14)
        .background(
            LinearGradient(
                colors: [Color.black.opacity(0), Color.black],
                startPoint: .top, endPoint: .center
            )
        )
        .overlay(
            Rectangle().fill(Color.white.opacity(0.06)).frame(height: 0.5),
            alignment: .top
        )
    }
}
