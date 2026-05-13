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
    @Query private var allManualEntries: [ManualFoodEntry]
    @Query private var goalsRows: [UserGoals]

    @State private var manualExpanded = false
    @State private var manualProtein = ""
    @State private var manualCarbs = ""
    @State private var manualFat = ""
    @FocusState private var manualFocus: ManualField?

    enum ManualField { case protein, carbs, fat }

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

    private var manualEntry: ManualFoodEntry? {
        allManualEntries.first { Calendar.current.isDate($0.date, inSameDayAs: activeDate) }
    }

    private func quantity(for food: FoodItem) -> Int {
        entriesByItem[food.persistentModelID]?.quantity ?? 0
    }

    private var totalKcal: Double {
        foods.reduce(0) { $0 + Double(quantity(for: $1)) * $1.kcalPerPortion }
            + (manualEntry?.kcal ?? 0)
    }
    private var totalProtein: Double {
        foods.reduce(0) { $0 + Double(quantity(for: $1)) * $1.proteinPerPortion }
            + (manualEntry?.protein ?? 0)
    }
    private var totalCarbs: Double {
        foods.reduce(0) { $0 + Double(quantity(for: $1)) * $1.carbsPerPortion }
            + (manualEntry?.carbs ?? 0)
    }
    private var totalFat: Double {
        foods.reduce(0) { $0 + Double(quantity(for: $1)) * $1.fatPerPortion }
            + (manualEntry?.fat ?? 0)
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

    private func commitManualEntry() {
        let p = Double(manualProtein.replacingOccurrences(of: ",", with: ".")) ?? 0
        let c = Double(manualCarbs.replacingOccurrences(of: ",", with: ".")) ?? 0
        let f = Double(manualFat.replacingOccurrences(of: ",", with: ".")) ?? 0
        guard p > 0 || c > 0 || f > 0 else {
            withAnimation(.spring(response: 0.32, dampingFraction: 0.85)) {
                manualExpanded = false
            }
            return
        }
        if let entry = manualEntry {
            entry.protein += p
            entry.carbs += c
            entry.fat += f
        } else {
            context.insert(ManualFoodEntry(date: activeDate, protein: p, carbs: c, fat: f))
        }
        try? context.save()
        manualProtein = ""
        manualCarbs = ""
        manualFat = ""
        manualFocus = nil
        withAnimation(.spring(response: 0.32, dampingFraction: 0.85)) {
            manualExpanded = false
        }
    }

    private func deleteManualEntry() {
        guard let entry = manualEntry else { return }
        context.delete(entry)
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
                if let entry = manualEntry, entry.kcal > 0 {
                    ManualEntryRow(entry: entry, onDelete: deleteManualEntry)
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
                HStack(alignment: .center, spacing: 8) {
                    if !manualExpanded {
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
                        .transition(.move(edge: .leading).combined(with: .opacity))
                    }
                    Spacer(minLength: 0)
                    manualPanel
                }
                .frame(height: 36)
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

    @ViewBuilder
    private var manualPanel: some View {
        if manualExpanded {
            HStack(spacing: 6) {
                MacroInputField(
                    placeholder: "P",
                    text: $manualProtein,
                    tone: AppColor.macroProt,
                    focus: $manualFocus,
                    field: .protein
                )
                MacroInputField(
                    placeholder: "K",
                    text: $manualCarbs,
                    tone: AppColor.macroCarb,
                    focus: $manualFocus,
                    field: .carbs
                )
                MacroInputField(
                    placeholder: "Y",
                    text: $manualFat,
                    tone: AppColor.macroFat,
                    focus: $manualFocus,
                    field: .fat
                )
                ManualCircleButton(symbol: "checkmark", action: commitManualEntry)
            }
            .transition(.move(edge: .trailing).combined(with: .opacity))
        } else {
            ManualCircleButton(symbol: "plus") {
                withAnimation(.spring(response: 0.32, dampingFraction: 0.85)) {
                    manualExpanded = true
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
                    manualFocus = .protein
                }
            }
            .transition(.move(edge: .trailing).combined(with: .opacity))
        }
    }
}

private struct MacroInputField: View {
    let placeholder: String
    @Binding var text: String
    let tone: Color
    var focus: FocusState<FoodLogView.ManualField?>.Binding
    let field: FoodLogView.ManualField

    var body: some View {
        TextField("", text: $text, prompt: Text(placeholder).foregroundStyle(AppColor.text3))
            .focused(focus, equals: field)
            .keyboardType(.decimalPad)
            .multilineTextAlignment(.center)
            .font(.system(size: 14, weight: .semibold))
            .monospacedDigit()
            .foregroundStyle(AppColor.textPrimary)
            .frame(width: 52, height: 36)
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(AppColor.surface)
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(tone.opacity(focus.wrappedValue == field ? 0.7 : 0.3), lineWidth: 1)
                    )
            )
    }
}

private struct ManualCircleButton: View {
    let symbol: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Image(systemName: symbol)
                .font(.system(size: 13, weight: .bold))
                .foregroundStyle(Color.white.opacity(0.9))
                .frame(width: 36, height: 36)
                .background(
                    Circle()
                        .fill(AppColor.goldDim)
                        .overlay(
                            Circle().stroke(AppColor.gold.opacity(0.5), lineWidth: 1)
                        )
                )
        }
        .buttonStyle(.plain)
    }
}

private struct ManualEntryRow: View {
    let entry: ManualFoodEntry
    let onDelete: () -> Void

    private var kcalInt: Int { Int(entry.kcal.rounded()) }
    private var pInt: Int { Int(entry.protein.rounded()) }
    private var cInt: Int { Int(entry.carbs.rounded()) }
    private var fInt: Int { Int(entry.fat.rounded()) }

    var body: some View {
        HStack(spacing: 10) {
            VStack(alignment: .leading, spacing: 3) {
                Text("Manuel")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundStyle(AppColor.textPrimary)
                Text("\(kcalInt) kcal · P\(pInt) · K\(cInt) · Y\(fInt)")
                    .font(.system(size: 12))
                    .monospacedDigit()
                    .foregroundStyle(AppColor.text2)
            }
            Spacer(minLength: 0)
            Button(action: onDelete) {
                Image(systemName: "xmark")
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundStyle(Color.white.opacity(0.6))
                    .frame(width: 30, height: 30)
                    .background(
                        Circle()
                            .fill(Color.white.opacity(0.06))
                            .overlay(Circle().stroke(Color.white.opacity(0.08), lineWidth: 1))
                    )
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 14).fill(AppColor.surface)
        )
    }
}
