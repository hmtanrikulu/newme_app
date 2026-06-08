import SwiftUI
import SwiftData

struct FoodLogView: View {
    let activeDate: Date

    @Environment(\.modelContext) private var context
    @Query(sort: \FoodItem.sortOrder) private var catalog: [FoodItem]
    @Query private var allEntries: [FoodLogEntry]
    @Query private var goalsRows: [UserGoals]

    @State private var showAddSheet = false
    @State private var showAISheet = false
    @State private var showBarcodeSheet = false
    @State private var addingForMeal: MealType = .breakfast
    @State private var editingEntry: FoodLogEntry?

    private var goals: UserGoals { goalsRows.first ?? UserGoals() }

    private var dayEntries: [FoodLogEntry] {
        allEntries
            .filter { Calendar.current.isDate($0.date, inSameDayAs: activeDate) }
            .sorted { $0.loggedAt < $1.loggedAt }
    }

    private func entries(for meal: MealType) -> [FoodLogEntry] {
        dayEntries.filter { $0.mealType == meal }
    }

    private var totalKcal: Double { dayEntries.reduce(0) { $0 + $1.kcal } }
    private var totalProtein: Double { dayEntries.reduce(0) { $0 + $1.protein } }
    private var totalCarbs: Double { dayEntries.reduce(0) { $0 + $1.carbs } }
    private var totalFat: Double { dayEntries.reduce(0) { $0 + $1.fat } }

    private func delete(_ entry: FoodLogEntry) {
        context.delete(entry)
        try? context.save()
    }

    var body: some View {
        List {
            // ── Calorie summary (MacroFactor style) ──
            Section {
                calorieSummary
                macroRows
            }
            .listRowBackground(Color.clear)
            .listRowSeparator(.hidden)
            .listRowInsets(EdgeInsets(top: 0, leading: 16, bottom: 0, trailing: 16))

            // ── Meal sections ──
            ForEach(MealType.allCases) { meal in
                mealSection(meal)
            }
        }
        .listStyle(.insetGrouped)
        .navigationTitle("Yemek")
        .navigationBarTitleDisplayMode(.large)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                HStack(spacing: 2) {
                    Button {
                        showBarcodeSheet = true
                    } label: {
                        Image(systemName: "barcode.viewfinder")
                    }
                    Button {
                        addingForMeal = MealType.current()
                        showAISheet = true
                    } label: {
                        Image(systemName: "sparkles")
                    }
                    Button {
                        addingForMeal = MealType.current()
                        showAddSheet = true
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
        }
        .sheet(isPresented: $showAddSheet) {
            AddFoodSheet(date: activeDate, defaultMeal: addingForMeal)
        }
        .sheet(isPresented: $showAISheet) {
            AIFoodInputSheet(activeDate: activeDate, defaultMeal: addingForMeal)
        }
        .sheet(isPresented: $showBarcodeSheet) {
            BarcodeScannerView(activeDate: activeDate, defaultMeal: MealType.current())
        }
        .sheet(item: $editingEntry) { entry in
            EditFoodEntrySheet(entry: entry)
        }
    }

    // MARK: — Calorie summary (MacroFactor style)

    @ViewBuilder
    private var calorieSummary: some View {
        let consumed = Int(totalKcal.rounded())
        let goal = goals.kcal
        let remaining = goal - consumed
        let over = remaining < 0

        VStack(spacing: 10) {
            HStack(alignment: .firstTextBaseline, spacing: 0) {
                Text("\(consumed)")
                    .font(.system(size: 52, weight: .bold, design: .rounded))
                    .monospacedDigit()
                    .foregroundStyle(over ? Color.red : Color.accentColor)
                Text(" kcal")
                    .font(.title3.weight(.medium))
                    .foregroundStyle(.secondary)
                    .padding(.leading, 2)
                Spacer()
                VStack(alignment: .trailing, spacing: 3) {
                    Text("Hedef \(goal)")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Text(over ? "\(abs(remaining)) fazla" : "\(remaining) kalan")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(over ? .red : Color.accentColor)
                }
            }

            // Thin calorie bar
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 3)
                        .fill(Color(UIColor.systemFill))
                        .frame(height: 6)
                    RoundedRectangle(cornerRadius: 3)
                        .fill(over ? Color.red : Color.accentColor)
                        .frame(width: min(geo.size.width, geo.size.width * CGFloat(min(1, totalKcal / Double(max(1, goal))))), height: 6)
                        .animation(.easeOut(duration: 0.3), value: totalKcal)
                }
            }
            .frame(height: 6)
        }
        .padding(.vertical, 6)
    }

    // MARK: — Macro rows (MacroFactor style)

    private var macroRows: some View {
        VStack(spacing: 8) {
            macroBar("Protein", value: totalProtein, goal: Double(goals.protein), color: AppColor.macroProt)
            macroBar("Karbonhidrat", value: totalCarbs, goal: Double(goals.carbs), color: AppColor.macroCarb)
            macroBar("Yağ", value: totalFat, goal: Double(goals.fat), color: AppColor.macroFat)
        }
        .padding(.bottom, 4)
    }

    private func macroBar(_ name: String, value: Double, goal: Double, color: Color) -> some View {
        HStack(spacing: 10) {
            Text(name)
                .font(.caption)
                .foregroundStyle(.secondary)
                .frame(width: 88, alignment: .leading)
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 2)
                        .fill(color.opacity(0.15))
                        .frame(height: 5)
                    RoundedRectangle(cornerRadius: 2)
                        .fill(color)
                        .frame(width: min(geo.size.width, geo.size.width * CGFloat(min(1, value / max(1, goal)))), height: 5)
                        .animation(.easeOut(duration: 0.3), value: value)
                }
            }
            .frame(height: 5)
            Text("\(Int(value.rounded()))g / \(Int(goal.rounded()))g")
                .font(.caption.weight(.medium))
                .monospacedDigit()
                .foregroundStyle(.secondary)
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

            // Inline add button
            Button {
                addingForMeal = meal
                showAddSheet = true
            } label: {
                HStack {
                    Image(systemName: "plus.circle.fill")
                        .foregroundStyle(Color.accentColor)
                    Text("Besin ekle")
                        .foregroundStyle(Color.accentColor)
                }
                .font(.subheadline)
            }
        } header: {
            HStack {
                Image(systemName: meal.systemImage)
                    .foregroundStyle(Color.accentColor)
                Text(meal.label.uppercased())
                    .fontWeight(.semibold)
                Spacer()
                if mealKcal > 0 {
                    Text("\(Int(mealKcal.rounded())) kcal")
                        .monospacedDigit()
                        .fontWeight(.medium)
                }
            }
            .font(.caption)
        }
    }
}

// MARK: — Food entry row (MacroFactor style)

private struct FoodEntryRow: View {
    let entry: FoodLogEntry

    var body: some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading, spacing: 3) {
                Text(entry.displayName)
                    .font(.body.weight(.medium))
                if let item = entry.item {
                    Text("\(entry.quantity) × \(item.name)  ·  \(Int(item.kcalPerPortion.rounded())) kcal/porsiyon")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                } else {
                    Text("P \(Int(entry.protein.rounded()))g  K \(Int(entry.carbs.rounded()))g  Y \(Int(entry.fat.rounded()))g")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            Spacer()
            Text("\(Int(entry.kcal.rounded()))")
                .font(.body.weight(.semibold))
                .monospacedDigit()
            + Text(" kcal")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
    }
}

// MARK: — Add food sheet

struct AddFoodSheet: View {
    let date: Date
    let defaultMeal: MealType

    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss
    @Query(sort: \FoodItem.sortOrder) private var catalog: [FoodItem]

    @State private var selectedMeal: MealType
    @State private var search = ""
    @State private var manualMode = false
    @State private var manualName = ""
    @State private var manualProtein = ""
    @State private var manualCarbs = ""
    @State private var manualFat = ""

    init(date: Date, defaultMeal: MealType) {
        self.date = date
        self.defaultMeal = defaultMeal
        _selectedMeal = State(initialValue: defaultMeal)
    }

    private var filtered: [FoodItem] {
        search.isEmpty ? catalog : catalog.filter { $0.name.localizedCaseInsensitiveContains(search) }
    }

    var body: some View {
        NavigationStack {
            List {
                Section {
                    Picker("Öğün", selection: $selectedMeal) {
                        ForEach(MealType.allCases) { meal in
                            Label(meal.label, systemImage: meal.systemImage).tag(meal)
                        }
                    }
                    .pickerStyle(.menu)
                }

                Section {
                    if manualMode {
                        manualFields
                    } else {
                        Button("Manuel makro gir") {
                            withAnimation { manualMode = true }
                        }
                    }
                }

                if !manualMode {
                    Section("Katalog") {
                        ForEach(filtered) { food in
                            Button {
                                addFood(food)
                            } label: {
                                FoodCatalogRow(food: food)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
            }
            .searchable(text: $search, prompt: "Yiyecek ara")
            .navigationTitle("Besin Ekle")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("İptal") { dismiss() }
                }
                if manualMode {
                    ToolbarItem(placement: .topBarTrailing) {
                        Button("Ekle") { commitManual() }
                            .fontWeight(.semibold)
                            .disabled(!canCommitManual)
                    }
                }
            }
        }
        .presentationDetents([.large])
    }

    private var manualFields: some View {
        Group {
            HStack {
                Text("Protein (g)")
                Spacer()
                TextField("0", text: $manualProtein)
                    .keyboardType(.decimalPad)
                    .multilineTextAlignment(.trailing)
                    .frame(width: 72)
            }
            HStack {
                Text("Karbonhidrat (g)")
                Spacer()
                TextField("0", text: $manualCarbs)
                    .keyboardType(.decimalPad)
                    .multilineTextAlignment(.trailing)
                    .frame(width: 72)
            }
            HStack {
                Text("Yağ (g)")
                Spacer()
                TextField("0", text: $manualFat)
                    .keyboardType(.decimalPad)
                    .multilineTextAlignment(.trailing)
                    .frame(width: 72)
            }
            Button("İptal") {
                withAnimation { manualMode = false }
            }
            .foregroundStyle(.secondary)
        }
    }

    private var canCommitManual: Bool {
        let p = Double(manualProtein.replacingOccurrences(of: ",", with: ".")) ?? 0
        let c = Double(manualCarbs.replacingOccurrences(of: ",", with: ".")) ?? 0
        let f = Double(manualFat.replacingOccurrences(of: ",", with: ".")) ?? 0
        return p + c + f > 0
    }

    private func addFood(_ food: FoodItem) {
        let entry = FoodLogEntry(date: date, mealType: selectedMeal, quantity: 1, item: food)
        context.insert(entry)
        try? context.save()
        dismiss()
    }

    private func commitManual() {
        let p = Double(manualProtein.replacingOccurrences(of: ",", with: ".")) ?? 0
        let c = Double(manualCarbs.replacingOccurrences(of: ",", with: ".")) ?? 0
        let f = Double(manualFat.replacingOccurrences(of: ",", with: ".")) ?? 0
        let entry = FoodLogEntry(date: date, mealType: selectedMeal, name: "Manuel", protein: p, carbs: c, fat: f)
        context.insert(entry)
        try? context.save()
        dismiss()
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
                ToolbarItem(placement: .topBarLeading) {
                    Button("İptal") { dismiss() }
                }
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

// MARK: — Catalog row

private struct FoodCatalogRow: View {
    let food: FoodItem

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text(food.name)
                    .font(.body)
                Text("P\(Int(food.proteinPerPortion.rounded()))  K\(Int(food.carbsPerPortion.rounded()))  Y\(Int(food.fatPerPortion.rounded()))")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .monospacedDigit()
            }
            Spacer()
            Text("\(Int(food.kcalPerPortion.rounded())) kcal")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .monospacedDigit()
        }
    }
}
