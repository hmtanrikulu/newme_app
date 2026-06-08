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
            // Macro summary
            macroSection

            // Meal sections
            ForEach(MealType.allCases) { meal in
                let mealEntries = entries(for: meal)
                let mealKcal = mealEntries.reduce(0) { $0 + $1.kcal }

                Section {
                    ForEach(mealEntries) { entry in
                        FoodEntryRow(entry: entry)
                            .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                                Button(role: .destructive) {
                                    delete(entry)
                                } label: {
                                    Label("Sil", systemImage: "trash")
                                }
                            }
                            .swipeActions(edge: .leading) {
                                Button {
                                    editingEntry = entry
                                } label: {
                                    Label("Düzenle", systemImage: "pencil")
                                }
                                .tint(.orange)
                            }
                    }
                    Button {
                        addingForMeal = meal
                        showAddSheet = true
                    } label: {
                        Label("Ekle", systemImage: "plus")
                            .font(.subheadline)
                    }
                } header: {
                    HStack {
                        Image(systemName: meal.systemImage)
                        Text(meal.label)
                        Spacer()
                        if mealKcal > 0 {
                            Text("\(Int(mealKcal.rounded())) kcal")
                                .monospacedDigit()
                        }
                    }
                }
            }
        }
        .listStyle(.insetGrouped)
        .navigationTitle("Yemek")
        .navigationBarTitleDisplayMode(.large)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                HStack(spacing: 4) {
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

    // MARK: — Macro summary section

    private var macroSection: some View {
        Section {
            // Calorie progress
            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    Text("Kalori")
                        .font(.subheadline)
                        .fontWeight(.medium)
                    Spacer()
                    Text("\(Int(totalKcal.rounded())) / \(goals.kcal) kcal")
                        .font(.subheadline)
                        .monospacedDigit()
                        .foregroundStyle(.secondary)
                }
                ProgressView(value: min(1, totalKcal / Double(goals.kcal)))
                    .tint(totalKcal > Double(goals.kcal) ? .red : .accentColor)
            }

            // Macros
            HStack(spacing: 0) {
                macroCell(
                    label: "Protein",
                    value: Int(totalProtein.rounded()),
                    goal: goals.protein,
                    color: AppColor.macroProt
                )
                Divider()
                macroCell(
                    label: "Karb.",
                    value: Int(totalCarbs.rounded()),
                    goal: goals.carbs,
                    color: AppColor.macroCarb
                )
                Divider()
                macroCell(
                    label: "Yağ",
                    value: Int(totalFat.rounded()),
                    goal: goals.fat,
                    color: AppColor.macroFat
                )
            }
            .listRowInsets(EdgeInsets())
        }
    }

    private func macroCell(label: String, value: Int, goal: Int, color: Color) -> some View {
        VStack(spacing: 4) {
            HStack(alignment: .firstTextBaseline, spacing: 2) {
                Text("\(value)")
                    .font(.title3)
                    .fontWeight(.semibold)
                    .monospacedDigit()
                Text("g")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .foregroundStyle(color)
            Text(label)
                .font(.caption2)
                .foregroundStyle(.secondary)
            ProgressView(value: min(1, Double(value) / Double(max(1, goal))))
                .tint(color)
                .frame(width: 48)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 10)
    }
}

// MARK: — Food entry row

private struct FoodEntryRow: View {
    let entry: FoodLogEntry

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text(entry.displayName)
                    .font(.body)
                if let item = entry.item {
                    Text("\(entry.quantity) × \(item.name)")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            Spacer()
            VStack(alignment: .trailing, spacing: 2) {
                Text("\(Int(entry.kcal.rounded())) kcal")
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .monospacedDigit()
                HStack(spacing: 6) {
                    Text("P\(Int(entry.protein.rounded()))")
                    Text("K\(Int(entry.carbs.rounded()))")
                    Text("Y\(Int(entry.fat.rounded()))")
                }
                .font(.caption2)
                .monospacedDigit()
                .foregroundStyle(.secondary)
            }
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
                // Meal picker
                Section {
                    Picker("Öğün", selection: $selectedMeal) {
                        ForEach(MealType.allCases) { meal in
                            Label(meal.label, systemImage: meal.systemImage).tag(meal)
                        }
                    }
                    .pickerStyle(.menu)
                }

                // Manual entry toggle
                Section {
                    if manualMode {
                        manualFields
                    } else {
                        Button("Manuel makro gir") {
                            withAnimation { manualMode = true }
                        }
                    }
                }

                // Catalog
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
            .navigationTitle("Yemek Ekle")
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

// MARK: — Catalog row (reused in AddFoodSheet)

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
