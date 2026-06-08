import SwiftUI
import SwiftData

struct FoodLogView: View {
    let activeDate: Date

    @Environment(\.modelContext) private var context
    @Query(sort: \FoodItem.sortOrder) private var catalog: [FoodItem]
    @Query private var allEntries: [FoodLogEntry]
    @Query private var goalsRows: [UserGoals]

    @State private var showFoodSheet = false
    @State private var addingForMeal: MealType = .breakfast
    @State private var editingEntry: FoodLogEntry?
    @State private var macroExpanded = false

    private var goals: UserGoals { goalsRows.first ?? UserGoals() }

    private var dayEntries: [FoodLogEntry] {
        allEntries
            .filter { Calendar.current.isDate($0.date, inSameDayAs: activeDate) }
            .sorted { $0.loggedAt < $1.loggedAt }
    }

    private func entries(for meal: MealType) -> [FoodLogEntry] {
        dayEntries.filter { $0.mealType == meal }
    }

    private var totalKcal:    Double { dayEntries.reduce(0) { $0 + $1.kcal } }
    private var totalProtein: Double { dayEntries.reduce(0) { $0 + $1.protein } }
    private var totalCarbs:   Double { dayEntries.reduce(0) { $0 + $1.carbs } }
    private var totalFat:     Double { dayEntries.reduce(0) { $0 + $1.fat } }

    private func delete(_ entry: FoodLogEntry) {
        context.delete(entry)
        try? context.save()
    }

    var body: some View {
        List {
            Section {
                macroHeader
            }
            .listRowBackground(Color.clear)
            .listRowSeparator(.hidden)
            .listRowInsets(EdgeInsets(top: 0, leading: 16, bottom: 0, trailing: 16))

            ForEach(MealType.allCases) { meal in
                mealSection(meal)
            }
        }
        .listStyle(.insetGrouped)
        .navigationTitle("Yemek")
        .navigationBarTitleDisplayMode(.large)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    addingForMeal = MealType.current()
                    showFoodSheet = true
                } label: {
                    Image(systemName: "plus")
                }
            }
        }
        .sheet(isPresented: $showFoodSheet) {
            AddFoodTabSheet(activeDate: activeDate, defaultMeal: addingForMeal)
        }
        .sheet(item: $editingEntry) { entry in
            EditFoodEntrySheet(entry: entry)
        }
    }

    // MARK: — Compact macro header (MacroFactor style)

    @ViewBuilder
    private var macroHeader: some View {
        let consumed = Int(totalKcal.rounded())
        let goal     = goals.kcal
        let remaining = goal - consumed
        let over      = remaining < 0

        VStack(spacing: 10) {
            // Compact 2×2 grid
            HStack {
                macroCell(
                    value: "\(consumed) / \(goal)",
                    label: "kcal",
                    color: over ? .red : Color.accentColor
                )
                Spacer()
                macroCell(
                    value: "\(Int(totalFat.rounded())) / \(goals.fat)g",
                    label: "Yağ",
                    color: AppColor.macroFat
                )
                chevronButton
            }
            HStack {
                macroCell(
                    value: "\(Int(totalProtein.rounded())) / \(goals.protein)g",
                    label: "Protein",
                    color: AppColor.macroProt
                )
                Spacer()
                macroCell(
                    value: "\(Int(totalCarbs.rounded())) / \(goals.carbs)g",
                    label: "Karb",
                    color: AppColor.macroCarb
                )
                Spacer().frame(width: 28) // align with chevron above
            }

            // Expanded: full progress bars
            if macroExpanded {
                VStack(spacing: 8) {
                    // Calorie bar
                    GeometryReader { geo in
                        ZStack(alignment: .leading) {
                            RoundedRectangle(cornerRadius: 3).fill(Color(UIColor.systemFill)).frame(height: 6)
                            RoundedRectangle(cornerRadius: 3)
                                .fill(over ? Color.red : Color.accentColor)
                                .frame(width: min(geo.size.width, geo.size.width * CGFloat(min(1, totalKcal / Double(max(1, goal))))), height: 6)
                                .animation(.easeOut(duration: 0.3), value: totalKcal)
                        }
                    }
                    .frame(height: 6)

                    macroBar("Protein",      value: totalProtein, goal: Double(goals.protein), color: AppColor.macroProt)
                    macroBar("Karbonhidrat", value: totalCarbs,   goal: Double(goals.carbs),   color: AppColor.macroCarb)
                    macroBar("Yağ",          value: totalFat,     goal: Double(goals.fat),      color: AppColor.macroFat)
                }
                .padding(.top, 4)
                .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
        .padding(.vertical, 8)
        .animation(.easeInOut(duration: 0.2), value: macroExpanded)
    }

    private func macroCell(value: String, label: String, color: Color) -> some View {
        VStack(alignment: .leading, spacing: 1) {
            Text(value)
                .font(.subheadline.weight(.semibold))
                .monospacedDigit()
                .foregroundStyle(color)
            Text(label)
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
    }

    private var chevronButton: some View {
        Button {
            withAnimation { macroExpanded.toggle() }
        } label: {
            Image(systemName: macroExpanded ? "chevron.up" : "chevron.down")
                .font(.caption.weight(.semibold))
                .foregroundStyle(.secondary)
                .frame(width: 28, height: 28)
        }
        .buttonStyle(.plain)
    }

    private func macroBar(_ name: String, value: Double, goal: Double, color: Color) -> some View {
        HStack(spacing: 10) {
            Text(name)
                .font(.caption).foregroundStyle(.secondary)
                .frame(width: 88, alignment: .leading)
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 2).fill(color.opacity(0.15)).frame(height: 5)
                    RoundedRectangle(cornerRadius: 2)
                        .fill(color)
                        .frame(width: min(geo.size.width, geo.size.width * CGFloat(min(1, value / max(1, goal)))), height: 5)
                        .animation(.easeOut(duration: 0.3), value: value)
                }
            }
            .frame(height: 5)
            Text("\(Int(value.rounded()))g / \(Int(goal.rounded()))g")
                .font(.caption.weight(.medium)).monospacedDigit().foregroundStyle(.secondary)
                .frame(width: 72, alignment: .trailing)
        }
    }

    // MARK: — Meal section

    @ViewBuilder
    private func mealSection(_ meal: MealType) -> some View {
        let mealEntries = entries(for: meal)
        let mealKcal = mealEntries.reduce(0) { $0 + $1.kcal }

        Section {
            ForEach(mealEntries) { entry in
                FoodEntryRow(entry: entry)
                    .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                        Button(role: .destructive) { delete(entry) } label: {
                            Label("Sil", systemImage: "trash")
                        }
                    }
                    .swipeActions(edge: .leading) {
                        Button { editingEntry = entry } label: {
                            Label("Düzenle", systemImage: "pencil")
                        }
                        .tint(.orange)
                    }
            }

            Button {
                addingForMeal = meal
                showFoodSheet = true
            } label: {
                HStack {
                    Image(systemName: "plus.circle.fill").foregroundStyle(Color.accentColor)
                    Text("Besin ekle").foregroundStyle(Color.accentColor)
                }
                .font(.subheadline)
            }
        } header: {
            HStack {
                Image(systemName: meal.systemImage).foregroundStyle(Color.accentColor)
                Text(meal.label.uppercased()).fontWeight(.semibold)
                Spacer()
                if mealKcal > 0 {
                    Text("\(Int(mealKcal.rounded())) kcal").monospacedDigit().fontWeight(.medium)
                }
            }
            .font(.caption)
        }
    }
}

// MARK: — Food entry row

private struct FoodEntryRow: View {
    let entry: FoodLogEntry

    var body: some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading, spacing: 3) {
                Text(entry.displayName).font(.body.weight(.medium))
                if let item = entry.item {
                    Text("\(entry.quantity) × \(item.name)  ·  \(Int(item.kcalPerPortion.rounded())) kcal/porsiyon")
                        .font(.caption).foregroundStyle(.secondary)
                } else {
                    Text("P \(Int(entry.protein.rounded()))g  K \(Int(entry.carbs.rounded()))g  Y \(Int(entry.fat.rounded()))g")
                        .font(.caption).foregroundStyle(.secondary)
                }
            }
            Spacer()
            Text("\(Int(entry.kcal.rounded()))")
                .font(.body.weight(.semibold)).monospacedDigit()
            + Text(" kcal")
                .font(.caption).foregroundStyle(.secondary)
        }
    }
}

// MARK: — Edit food entry sheet

struct EditFoodEntrySheet: View {
    let entry: FoodLogEntry
    @Environment(\.dismiss) private var dismiss

    @State private var selectedMeal: MealType
    @State private var quantity: Int

    init(entry: FoodLogEntry) {
        self.entry = entry
        _selectedMeal = State(initialValue: entry.mealType)
        _quantity = State(initialValue: max(1, entry.quantity))
    }

    var body: some View {
        NavigationStack {
            Form {
                Picker("Öğün", selection: $selectedMeal) {
                    ForEach(MealType.allCases) { meal in
                        Label(meal.label, systemImage: meal.systemImage).tag(meal)
                    }
                }
                if !entry.isManual {
                    Stepper("Miktar: \(quantity)", value: $quantity, in: 1...99)
                }
            }
            .navigationTitle(entry.displayName)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) { Button("İptal") { dismiss() } }
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Kaydet") {
                        entry.mealType = selectedMeal
                        entry.quantity = quantity
                        dismiss()
                    }
                    .fontWeight(.semibold)
                }
            }
        }
        .presentationDetents([.medium])
    }
}
