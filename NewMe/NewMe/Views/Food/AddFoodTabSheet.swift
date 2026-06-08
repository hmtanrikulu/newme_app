import SwiftUI
import SwiftData
import VisionKit

// MARK: — Tab enum

enum AddFoodTab: String, CaseIterable {
    case scan    = "Tara"
    case search  = "Ara"
    case quick   = "Hızlı Ekle"
    case library = "Kütüphane"
    case ai      = "AI Anlat"
}

// MARK: — Main sheet

struct AddFoodTabSheet: View {
    let activeDate: Date
    let defaultMeal: MealType

    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss
    @Query(sort: \FoodItem.sortOrder) private var catalog: [FoodItem]
    @Query private var allEntries: [FoodLogEntry]

    @State private var selectedTab: AddFoodTab = .search
    @State private var meal: MealType

    init(activeDate: Date, defaultMeal: MealType) {
        self.activeDate = activeDate
        self.defaultMeal = defaultMeal
        _meal = State(initialValue: defaultMeal)
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                mealPicker
                    .padding(.horizontal, 16)
                    .padding(.top, 12)
                    .padding(.bottom, 8)
                tabBar
                Divider()
                tabContent
            }
            .background(Color(UIColor.systemGroupedBackground))
            .navigationTitle("Besin Ekle")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("İptal") { dismiss() }
                }
            }
        }
        .presentationDetents([.large])
    }

    // MARK: — Meal picker

    private var mealPicker: some View {
        Picker("Öğün", selection: $meal) {
            ForEach(MealType.allCases) { m in
                Label(m.label, systemImage: m.systemImage).tag(m)
            }
        }
        .pickerStyle(.segmented)
    }

    // MARK: — Tab bar

    private var tabBar: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 0) {
                ForEach(AddFoodTab.allCases, id: \.rawValue) { tab in
                    Button {
                        selectedTab = tab
                    } label: {
                        VStack(spacing: 4) {
                            Text(tab.rawValue)
                                .font(.subheadline.weight(selectedTab == tab ? .semibold : .regular))
                                .foregroundStyle(selectedTab == tab ? Color.accentColor : Color.secondary)
                                .padding(.horizontal, 14)
                                .padding(.top, 10)
                                .padding(.bottom, 6)
                            Rectangle()
                                .fill(selectedTab == tab ? Color.accentColor : Color.clear)
                                .frame(height: 2)
                        }
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, 8)
        }
        .background(Color(UIColor.systemGroupedBackground))
    }

    // MARK: — Tab content

    @ViewBuilder
    private var tabContent: some View {
        switch selectedTab {
        case .scan:
            ScanTab(activeDate: activeDate, meal: $meal, onAdded: { dismiss() })
        case .search:
            SearchTab(activeDate: activeDate, meal: $meal, catalog: catalog, recentEntries: recentFoods, onAdded: { dismiss() })
        case .quick:
            QuickAddTab(activeDate: activeDate, meal: $meal, onAdded: { dismiss() })
        case .library:
            LibraryTab(activeDate: activeDate, meal: $meal, catalog: catalog, onAdded: { dismiss() })
        case .ai:
            AITab(activeDate: activeDate, meal: $meal, onAdded: { dismiss() })
        }
    }

    private var recentFoods: [FoodItem] {
        var seen = Set<PersistentIdentifier>()
        var result: [FoodItem] = []
        for entry in allEntries.sorted(by: { $0.loggedAt > $1.loggedAt }) {
            guard let item = entry.item else { continue }
            if seen.insert(item.persistentModelID).inserted {
                result.append(item)
                if result.count == 5 { break }
            }
        }
        return result
    }
}

// MARK: — Scan tab

private struct ScanTab: View {
    let activeDate: Date
    @Binding var meal: MealType
    let onAdded: () -> Void

    @Environment(\.modelContext) private var context
    @State private var scannedBarcode: String?
    @State private var lookupResult: BarcodeLookupService.Result?
    @State private var isLoading = false
    @State private var errorMessage: String?
    @State private var gram: String = "100"

    var body: some View {
        ZStack {
            if let result = lookupResult {
                scanConfirmView(result: result)
            } else if isLoading {
                VStack(spacing: 16) {
                    ProgressView().scaleEffect(1.5)
                    Text("Ürün aranıyor…").foregroundStyle(.secondary)
                }
            } else if let err = errorMessage {
                VStack(spacing: 20) {
                    Image(systemName: "exclamationmark.triangle.fill").font(.largeTitle).foregroundStyle(.orange)
                    Text(err).multilineTextAlignment(.center).foregroundStyle(.secondary)
                    Button("Tekrar Dene") { scannedBarcode = nil; errorMessage = nil }
                        .buttonStyle(.borderedProminent)
                }
                .padding(32)
            } else {
                if DataScannerViewController.isSupported && DataScannerViewController.isAvailable {
                    DataScannerRepresentable(scannedCode: Binding(
                        get: { scannedBarcode },
                        set: { code in
                            guard let code, scannedBarcode == nil else { return }
                            scannedBarcode = code
                            fetchProduct(barcode: code)
                        }
                    ))
                    .ignoresSafeArea(edges: .bottom)
                    .overlay(alignment: .bottom) {
                        Text("Ürünün barkodunu kameraya göster")
                            .font(.callout.weight(.medium))
                            .padding(.horizontal, 20).padding(.vertical, 12)
                            .background(.ultraThinMaterial, in: Capsule())
                            .padding(.bottom, 32)
                    }
                } else {
                    ContentUnavailableView(
                        "Kamera Desteklenmiyor",
                        systemImage: "camera.slash",
                        description: Text("Bu cihaz barkod taramayı desteklemiyor.")
                    )
                }
            }
        }
    }

    private func scanConfirmView(result: BarcodeLookupService.Result) -> some View {
        let gramVal = Double(gram) ?? 100
        let m = gramVal / 100.0
        return ScrollView {
            VStack(spacing: 20) {
                Text(result.name).font(.title3.weight(.semibold))
                    .frame(maxWidth: .infinity, alignment: .leading).padding(.horizontal, 20)

                HStack(spacing: 12) {
                    Text("Porsiyon").fontWeight(.medium)
                    Spacer()
                    TextField("100", text: $gram)
                        .keyboardType(.decimalPad).multilineTextAlignment(.trailing).frame(width: 72)
                        .padding(.horizontal, 12).padding(.vertical, 8)
                        .background(Color(UIColor.secondarySystemGroupedBackground), in: RoundedRectangle(cornerRadius: 10))
                    Text("g").foregroundStyle(.secondary)
                }
                .padding(.horizontal, 20)

                NutritionGrid(
                    kcal: result.kcalPer100g * m,
                    protein: result.proteinPer100g * m,
                    carbs: result.carbsPer100g * m,
                    fat: result.fatPer100g * m
                )
                .padding(.horizontal, 20)

                Button {
                    let entry = FoodLogEntry(
                        date: activeDate, mealType: meal, name: result.name,
                        protein: result.proteinPer100g * m,
                        carbs: result.carbsPer100g * m,
                        fat: result.fatPer100g * m
                    )
                    context.insert(entry)
                    try? context.save()
                    onAdded()
                } label: {
                    Text("Ekle").fontWeight(.semibold).frame(maxWidth: .infinity).frame(height: 50)
                        .background(Color.accentColor, in: RoundedRectangle(cornerRadius: 14))
                        .foregroundStyle(.black)
                }
                .buttonStyle(.plain).padding(.horizontal, 20)

                Button { scannedBarcode = nil; lookupResult = nil; errorMessage = nil } label: {
                    Label("Farklı Barkod Tara", systemImage: "barcode.viewfinder").foregroundStyle(Color.accentColor)
                }
            }
            .padding(.top, 24)
        }
    }

    private func fetchProduct(barcode: String) {
        isLoading = true
        Task {
            do {
                let result = try await BarcodeLookupService.lookup(barcode: barcode)
                await MainActor.run { lookupResult = result; isLoading = false }
            } catch {
                await MainActor.run { errorMessage = error.localizedDescription; isLoading = false }
            }
        }
    }
}

// MARK: — Search tab

private struct SearchTab: View {
    let activeDate: Date
    @Binding var meal: MealType
    let catalog: [FoodItem]
    let recentEntries: [FoodItem]
    let onAdded: () -> Void

    @Environment(\.modelContext) private var context
    @State private var search = ""
    @State private var expandedItem: PersistentIdentifier?
    @State private var quantity: Int = 1

    private var filtered: [FoodItem] {
        search.isEmpty ? catalog : catalog.filter { $0.name.localizedCaseInsensitiveContains(search) }
    }

    var body: some View {
        List {
            if search.isEmpty && !recentEntries.isEmpty {
                Section("Son eklenenler") {
                    ForEach(recentEntries) { food in
                        foodRow(food)
                    }
                }
            }
            Section(search.isEmpty ? "Katalog" : "Sonuçlar") {
                ForEach(filtered) { food in
                    foodRow(food)
                }
            }
        }
        .listStyle(.insetGrouped)
        .searchable(text: $search, prompt: "Yiyecek ara")
    }

    @ViewBuilder
    private func foodRow(_ food: FoodItem) -> some View {
        if expandedItem == food.persistentModelID {
            VStack(alignment: .leading, spacing: 10) {
                HStack {
                    VStack(alignment: .leading, spacing: 2) {
                        Text(food.name).font(.body.weight(.medium))
                        Text("P\(Int(food.proteinPerPortion.rounded()))  K\(Int(food.carbsPerPortion.rounded()))  Y\(Int(food.fatPerPortion.rounded()))")
                            .font(.caption).foregroundStyle(.secondary).monospacedDigit()
                    }
                    Spacer()
                    Text("\(Int(food.kcalPerPortion.rounded())) kcal").font(.subheadline).foregroundStyle(.secondary)
                }
                HStack(spacing: 12) {
                    Stepper("\(quantity) porsiyon", value: $quantity, in: 1...20)
                    Button("Ekle") {
                        let entry = FoodLogEntry(date: activeDate, mealType: meal, quantity: quantity, item: food)
                        context.insert(entry)
                        try? context.save()
                        onAdded()
                    }
                    .buttonStyle(.borderedProminent)
                    .controlSize(.small)
                }
            }
            .padding(.vertical, 4)
        } else {
            Button {
                expandedItem = food.persistentModelID
                quantity = 1
            } label: {
                HStack {
                    VStack(alignment: .leading, spacing: 2) {
                        Text(food.name).font(.body).foregroundStyle(Color.primary)
                        Text("P\(Int(food.proteinPerPortion.rounded()))  K\(Int(food.carbsPerPortion.rounded()))  Y\(Int(food.fatPerPortion.rounded()))")
                            .font(.caption).foregroundStyle(.secondary).monospacedDigit()
                    }
                    Spacer()
                    Text("\(Int(food.kcalPerPortion.rounded())) kcal").font(.subheadline).foregroundStyle(.secondary)
                }
            }
            .buttonStyle(.plain)
        }
    }
}

// MARK: — Quick Add tab

private struct QuickAddTab: View {
    let activeDate: Date
    @Binding var meal: MealType
    let onAdded: () -> Void

    @Environment(\.modelContext) private var context
    @State private var energyText = ""
    @State private var proteinText = ""
    @State private var carbsText = ""
    @State private var fatText = ""
    @State private var nameText = ""
    @State private var energyOverridden = false

    private var protein: Double { Double(proteinText.replacingOccurrences(of: ",", with: ".")) ?? 0 }
    private var carbs:   Double { Double(carbsText.replacingOccurrences(of: ",", with: ".")) ?? 0 }
    private var fat:     Double { Double(fatText.replacingOccurrences(of: ",", with: ".")) ?? 0 }
    private var computedKcal: Double { protein * 4 + carbs * 4 + fat * 9 }
    private var displayKcal: Double {
        if energyOverridden, let v = Double(energyText.replacingOccurrences(of: ",", with: ".")) { return v }
        return computedKcal
    }

    private var canApply: Bool { protein + carbs + fat > 0 || (energyOverridden && displayKcal > 0) }

    var body: some View {
        List {
            Section {
                HStack {
                    Text("Makro Kalori Tahmini")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                    Spacer()
                    Text("\(Int(displayKcal.rounded())) kcal")
                        .font(.subheadline.weight(.semibold))
                        .monospacedDigit()
                        .foregroundStyle(Color.accentColor)
                }
            }

            Section {
                quickRow(label: "Enerji (kcal)", text: $energyText, onChange: { energyOverridden = !$0.isEmpty })
                quickRow(label: "Protein (g)", text: $proteinText)
                quickRow(label: "Yağ (g)", text: $fatText)
                quickRow(label: "Karbonhidrat (g)", text: $carbsText)
                HStack {
                    Text("İsim (isteğe bağlı)")
                    Spacer()
                    TextField("Hızlı Ekle", text: $nameText)
                        .multilineTextAlignment(.trailing)
                }
            }

            Section {
                Button("Uygula") {
                    let entry = FoodLogEntry(
                        date: activeDate,
                        mealType: meal,
                        name: nameText.isEmpty ? "Hızlı Ekle" : nameText,
                        protein: protein,
                        carbs: carbs,
                        fat: fat
                    )
                    context.insert(entry)
                    try? context.save()
                    onAdded()
                }
                .frame(maxWidth: .infinity, alignment: .center)
                .fontWeight(.semibold)
                .foregroundStyle(canApply ? Color.accentColor : Color.secondary)
                .disabled(!canApply)
            }
        }
        .listStyle(.insetGrouped)
    }

    private func quickRow(label: String, text: Binding<String>, onChange: ((String) -> Void)? = nil) -> some View {
        HStack {
            Text(label).foregroundStyle(Color.primary)
            Spacer()
            TextField("0", text: text)
                .keyboardType(.decimalPad)
                .multilineTextAlignment(.trailing)
                .frame(width: 80)
                .onChange(of: text.wrappedValue) { _, v in onChange?(v) }
        }
    }
}

// MARK: — Library tab

private struct LibraryTab: View {
    let activeDate: Date
    @Binding var meal: MealType
    let catalog: [FoodItem]
    let onAdded: () -> Void

    @Environment(\.modelContext) private var context

    var body: some View {
        List {
            Section("Yiyecekler") {
                ForEach(catalog) { food in
                    HStack {
                        VStack(alignment: .leading, spacing: 2) {
                            Text(food.name).font(.body)
                            Text("P\(Int(food.proteinPerPortion.rounded()))  K\(Int(food.carbsPerPortion.rounded()))  Y\(Int(food.fatPerPortion.rounded()))")
                                .font(.caption).foregroundStyle(.secondary).monospacedDigit()
                        }
                        Spacer()
                        Text("\(Int(food.kcalPerPortion.rounded())) kcal")
                            .font(.subheadline).foregroundStyle(.secondary)
                        Button {
                            let entry = FoodLogEntry(date: activeDate, mealType: meal, quantity: 1, item: food)
                            context.insert(entry)
                            try? context.save()
                            onAdded()
                        } label: {
                            Image(systemName: "plus.circle.fill")
                                .font(.title3)
                                .foregroundStyle(Color.accentColor)
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
        }
        .listStyle(.insetGrouped)
    }
}

// MARK: — AI tab

private struct AITab: View {
    let activeDate: Date
    @Binding var meal: MealType
    let onAdded: () -> Void

    @Environment(\.modelContext) private var context

    // Model download state
    @State private var modelDownloaded = false
    @State private var isDownloading = false
    @State private var downloadProgress: Double = 0

    // Inference state
    @State private var inputText = ""
    @State private var isAnalyzing = false
    @State private var loadingStage = ""
    @State private var parsedItems: [ParsedFoodItem] = []
    @State private var selectedIDs: Set<UUID> = []
    @State private var errorMessage: String?

    var body: some View {
        Group {
            if !modelDownloaded {
                downloadView
            } else if parsedItems.isEmpty {
                inputView
            } else {
                resultsView
            }
        }
        .onAppear {
            modelDownloaded = LocalLLMService.shared.isModelDownloaded
        }
    }

    // MARK: — Download view

    private var downloadView: some View {
        ScrollView {
            VStack(spacing: 28) {
                Spacer(minLength: 40)

                VStack(spacing: 12) {
                    Image(systemName: "cpu.fill")
                        .font(.system(size: 48))
                        .foregroundStyle(Color.accentColor)

                    Text("Yerel AI Modeli")
                        .font(.title2.weight(.bold))

                    Text("Yiyecek girişi için cihazında çalışan küçük bir dil modeli kullanılır. İnternet bağlantısı veya API anahtarı gerekmez, tüm işlem cihazında gerçekleşir.")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                }

                VStack(spacing: 8) {
                    HStack {
                        Label("Qwen2.5-0.5B", systemImage: "checkmark.circle.fill")
                            .foregroundStyle(Color.accentColor)
                        Spacer()
                        Text("~340 MB").foregroundStyle(.secondary)
                    }
                    HStack {
                        Label("Türkçe desteği", systemImage: "checkmark.circle.fill")
                            .foregroundStyle(Color.accentColor)
                        Spacer()
                    }
                    HStack {
                        Label("İnternetsiz çalışır", systemImage: "checkmark.circle.fill")
                            .foregroundStyle(Color.accentColor)
                        Spacer()
                    }
                }
                .font(.subheadline)
                .padding(.horizontal, 8)

                if isDownloading {
                    VStack(spacing: 8) {
                        ProgressView(value: downloadProgress)
                            .tint(Color.accentColor)
                        Text("\(Int(downloadProgress * 100))% indirildi…")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                } else {
                    if let err = errorMessage {
                        Text(err).font(.caption).foregroundStyle(.red).multilineTextAlignment(.center)
                    }

                    Button(action: startDownload) {
                        Label("Modeli İndir", systemImage: "arrow.down.circle.fill")
                            .fontWeight(.semibold)
                            .frame(maxWidth: .infinity).frame(height: 50)
                            .background(Color.accentColor, in: RoundedRectangle(cornerRadius: 14))
                            .foregroundStyle(.white)
                    }
                    .buttonStyle(.plain)
                }

                Spacer(minLength: 20)
            }
            .padding(24)
        }
        .background(Color(UIColor.systemGroupedBackground))
    }

    private func startDownload() {
        isDownloading = true
        downloadProgress = 0
        errorMessage = nil

        Task {
            do {
                try await LocalLLMService.shared.downloadModel { pct in
                    Task { @MainActor in downloadProgress = pct }
                }
                await MainActor.run {
                    modelDownloaded = true
                    isDownloading = false
                }
            } catch {
                await MainActor.run {
                    errorMessage = "İndirme başarısız: \(error.localizedDescription)"
                    isDownloading = false
                }
            }
        }
    }

    // MARK: — Input view

    private var inputView: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                VStack(alignment: .leading, spacing: 8) {
                    Label("Ne yedin?", systemImage: "cpu").font(.headline)

                    ZStack(alignment: .topLeading) {
                        RoundedRectangle(cornerRadius: 14)
                            .fill(Color(UIColor.secondarySystemGroupedBackground))
                            .frame(minHeight: 110)
                        if inputText.isEmpty {
                            Text("Örnek: 300gr yoğurt, 50g yulaf, 1 scoop whey")
                                .foregroundStyle(.tertiary).padding(14)
                        }
                        TextEditor(text: $inputText)
                            .scrollContentBackground(.hidden).background(Color.clear)
                            .padding(10).frame(minHeight: 110)
                    }
                }

                if let err = errorMessage {
                    HStack {
                        Image(systemName: "exclamationmark.triangle.fill").foregroundStyle(.red)
                        Text(err).font(.caption).foregroundStyle(.red)
                    }
                }

                Button(action: analyze) {
                    HStack {
                        if isAnalyzing {
                            ProgressView().tint(.white)
                            Text(loadingStage.isEmpty ? "Analiz ediliyor…" : loadingStage)
                        } else {
                            Image(systemName: "cpu")
                            Text("Analiz Et")
                        }
                    }
                    .fontWeight(.semibold)
                    .frame(maxWidth: .infinity).frame(height: 50)
                    .background(
                        RoundedRectangle(cornerRadius: 14)
                            .fill(inputText.trimmingCharacters(in: .whitespaces).isEmpty ? Color.secondary.opacity(0.3) : Color.accentColor)
                    )
                    .foregroundStyle(inputText.trimmingCharacters(in: .whitespaces).isEmpty ? Color.secondary : .white)
                }
                .buttonStyle(.plain)
                .disabled(inputText.trimmingCharacters(in: .whitespaces).isEmpty || isAnalyzing)

                HStack(spacing: 4) {
                    Image(systemName: "cpu.fill").font(.caption2).foregroundStyle(Color.accentColor)
                    Text("Cihazda çalışır · İnternet gerekmez · USDA besin değerleri")
                        .font(.caption2).foregroundStyle(.tertiary)
                }
                .frame(maxWidth: .infinity, alignment: .center)
            }
            .padding(20)
        }
        .background(Color(UIColor.systemGroupedBackground))
        .onAppear { errorMessage = nil }
    }

    // MARK: — Results view

    private var resultsView: some View {
        List {
            Section {
                ForEach(parsedItems) { item in
                    parsedItemRow(item)
                }
            } header: {
                Text("Tespit Edilenler — \(meal.label)")
            } footer: {
                let total = parsedItems.filter { selectedIDs.contains($0.id) }.reduce(0) { $0 + $1.kcal }
                if total > 0 {
                    Text("Seçili: \(Int(total.rounded())) kcal").fontWeight(.semibold)
                }
            }

            Section {
                Button {
                    parsedItems = []
                    selectedIDs = []
                    errorMessage = nil
                } label: {
                    Label("Tekrar Analiz Et", systemImage: "arrow.counterclockwise")
                        .foregroundStyle(Color.accentColor)
                }

                Button {
                    for item in parsedItems where selectedIDs.contains(item.id) {
                        let entry = FoodLogEntry(
                            date: activeDate, mealType: meal, name: item.name,
                            protein: item.protein, carbs: item.carbs, fat: item.fat
                        )
                        context.insert(entry)
                    }
                    try? context.save()
                    onAdded()
                } label: {
                    Text("Ekle (\(selectedIDs.count))")
                        .fontWeight(.semibold)
                        .frame(maxWidth: .infinity)
                        .foregroundStyle(selectedIDs.isEmpty ? Color.secondary : Color.accentColor)
                }
                .disabled(selectedIDs.isEmpty)
            }
        }
        .listStyle(.insetGrouped)
        .onAppear { selectedIDs = Set(parsedItems.map(\.id)) }
    }

    private func parsedItemRow(_ item: ParsedFoodItem) -> some View {
        Button {
            if selectedIDs.contains(item.id) { selectedIDs.remove(item.id) }
            else { selectedIDs.insert(item.id) }
        } label: {
            HStack(spacing: 12) {
                Image(systemName: selectedIDs.contains(item.id) ? "checkmark.circle.fill" : "circle")
                    .foregroundStyle(selectedIDs.contains(item.id) ? Color.accentColor : .secondary)
                    .font(.title3)
                VStack(alignment: .leading, spacing: 2) {
                    HStack(spacing: 6) {
                        Text(item.name).fontWeight(.medium).foregroundStyle(Color.primary)
                        sourceBadge(item.source)
                    }
                    Text("\(Int(item.gram))g · \(Int(item.kcal.rounded())) kcal · P \(Int(item.protein.rounded()))g  K \(Int(item.carbs.rounded()))g  Y \(Int(item.fat.rounded()))g")
                        .font(.caption).foregroundStyle(.secondary)
                }
                Spacer()
            }
        }
        .buttonStyle(.plain)
    }

    @ViewBuilder
    private func sourceBadge(_ source: ParsedFoodItem.Source) -> some View {
        switch source {
        case .usda:
            Text("USDA").font(.caption2).foregroundStyle(.white)
                .padding(.horizontal, 5).padding(.vertical, 2)
                .background(Color.accentColor.opacity(0.8), in: Capsule())
        case .estimated:
            Text("Tahmini").font(.caption2).foregroundStyle(.secondary)
                .padding(.horizontal, 5).padding(.vertical, 2)
                .background(Color(UIColor.systemFill), in: Capsule())
        }
    }

    // MARK: — Two-stage inference

    private func analyze() {
        isAnalyzing = true
        loadingStage = "Model yükleniyor…"
        errorMessage = nil

        Task {
            do {
                // Stage 1: Local LLM NLP — extract (name, gram) pairs
                await MainActor.run { loadingStage = "Yiyecekler tanınıyor…" }
                let extracted = try await LocalLLMService.shared.extractFoods(inputText)

                // Stage 2: USDA FDC — fetch verified macros
                await MainActor.run { loadingStage = "Besin değerleri yükleniyor…" }
                let items = try await USDAService.enrich(extracted)

                await MainActor.run {
                    parsedItems = items
                    selectedIDs = Set(items.map(\.id))
                    isAnalyzing = false
                    loadingStage = ""
                }
            } catch LocalLLMService.ServiceError.modelNotDownloaded {
                await MainActor.run {
                    modelDownloaded = false  // go back to download view
                    isAnalyzing = false; loadingStage = ""
                }
            } catch {
                await MainActor.run {
                    errorMessage = error.localizedDescription
                    isAnalyzing = false; loadingStage = ""
                }
            }
        }
    }
}
