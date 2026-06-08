import SwiftUI
import SwiftData

struct AIFoodInputSheet: View {
    let activeDate: Date
    let defaultMeal: MealType

    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss

    @State private var inputText = ""
    @State private var isLoading = false
    @State private var parsedItems: [ParsedFoodItem] = []
    @State private var selectedIDs: Set<UUID> = []
    @State private var errorMessage: String?
    @State private var meal: MealType

    init(activeDate: Date, defaultMeal: MealType) {
        self.activeDate = activeDate
        self.defaultMeal = defaultMeal
        self._meal = State(initialValue: defaultMeal)
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                if parsedItems.isEmpty {
                    inputView
                } else {
                    resultsView
                }
            }
            .background(Color(UIColor.systemGroupedBackground))
            .navigationTitle("AI ile Ekle")
            .navigationBarTitleDisplayMode(.inline)
            .onAppear { errorMessage = nil }
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("İptal") { dismiss() }
                }
                if !parsedItems.isEmpty {
                    ToolbarItem(placement: .confirmationAction) {
                        Button("Ekle (\(selectedIDs.count))") { addSelected() }
                            .fontWeight(.semibold)
                            .disabled(selectedIDs.isEmpty)
                    }
                }
            }
        }
        .presentationDetents([.large])
    }

    // MARK: — Input view

    private var inputView: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                VStack(alignment: .leading, spacing: 8) {
                    Label("Ne yedin?", systemImage: "sparkles")
                        .font(.headline)

                    ZStack(alignment: .topLeading) {
                        RoundedRectangle(cornerRadius: 14)
                            .fill(Color(UIColor.secondarySystemGroupedBackground))
                            .frame(minHeight: 110)
                        if inputText.isEmpty {
                            Text("Örnek: \"akşam 200g tavuk göğsü ve 1 tabak pirinç yedim\"")
                                .foregroundStyle(.tertiary)
                                .padding(14)
                        }
                        TextEditor(text: $inputText)
                            .scrollContentBackground(.hidden)
                            .background(Color.clear)
                            .padding(10)
                            .frame(minHeight: 110)
                    }
                }

                Picker("Öğün", selection: $meal) {
                    ForEach(MealType.allCases) { m in
                        Label(m.label, systemImage: m.systemImage).tag(m)
                    }
                }
                .pickerStyle(.segmented)

                if let err = errorMessage {
                    HStack {
                        Image(systemName: "exclamationmark.triangle.fill").foregroundStyle(.red)
                        Text(err).font(.caption).foregroundStyle(.red)
                    }
                }

                Button(action: analyze) {
                    HStack {
                        if isLoading {
                            ProgressView().tint(.black)
                        } else {
                            Image(systemName: "sparkles")
                            Text("Analiz Et")
                        }
                    }
                    .fontWeight(.semibold)
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .background(
                        RoundedRectangle(cornerRadius: 14)
                            .fill(inputText.trimmingCharacters(in: .whitespaces).isEmpty ? Color.secondary.opacity(0.3) : Color.accentColor)
                    )
                    .foregroundStyle(.black)
                }
                .buttonStyle(.plain)
                .disabled(inputText.trimmingCharacters(in: .whitespaces).isEmpty || isLoading)

                Text("Gemini AI, USDA besin değerlerini kullanarak tahmin yapar. Sonuçları eklemeden önce gözden geçirebilirsin.")
                    .font(.caption2)
                    .foregroundStyle(.tertiary)
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: .infinity)
            }
            .padding(20)
        }
    }

    // MARK: — Results view

    private var resultsView: some View {
        List {
            Section {
                ForEach(parsedItems) { item in
                    ParsedItemRow(item: item, isSelected: selectedIDs.contains(item.id)) {
                        if selectedIDs.contains(item.id) { selectedIDs.remove(item.id) }
                        else { selectedIDs.insert(item.id) }
                    }
                }
            } header: {
                Text("Tespit Edilenler — \(meal.label)")
            } footer: {
                let total = parsedItems.filter { selectedIDs.contains($0.id) }.reduce(0) { $0 + $1.kcal }
                if total > 0 {
                    Text("Seçili: \(Int(total.rounded())) kcal")
                        .fontWeight(.semibold)
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
            }
        }
        .listStyle(.insetGrouped)
        .onAppear { selectedIDs = Set(parsedItems.map(\.id)) }
    }

    // MARK: — Actions

    private func analyze() {
        isLoading = true
        errorMessage = nil
        Task {
            do {
                let items = try await GeminiService.parseFood(inputText)
                await MainActor.run {
                    parsedItems = items
                    selectedIDs = Set(items.map(\.id))
                    isLoading = false
                }
            } catch GeminiService.ServiceError.rateLimited {
                await MainActor.run {
                    // Retry already happened inside parseFood; show permanent error only if all retries failed
                    errorMessage = "Sunucu meşgul, biraz bekleyip tekrar dene."
                    isLoading = false
                }
            } catch {
                await MainActor.run {
                    errorMessage = error.localizedDescription
                    isLoading = false
                }
            }
        }
    }

    private func addSelected() {
        for item in parsedItems where selectedIDs.contains(item.id) {
            let entry = FoodLogEntry(
                date: activeDate,
                mealType: meal,
                name: item.name,
                protein: item.protein,
                carbs: item.carbs,
                fat: item.fat
            )
            context.insert(entry)
        }
        try? context.save()
        dismiss()
    }
}

// MARK: — Parsed item row

private struct ParsedItemRow: View {
    let item: ParsedFoodItem
    let isSelected: Bool
    let toggle: () -> Void

    var body: some View {
        Button(action: toggle) {
            HStack(spacing: 12) {
                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .foregroundStyle(isSelected ? Color.accentColor : .secondary)
                    .font(.title3)
                VStack(alignment: .leading, spacing: 2) {
                    Text(item.name)
                        .fontWeight(.medium)
                        .foregroundStyle(Color.primary)
                    Text("\(Int(item.gram))g · \(Int(item.kcal.rounded())) kcal · P \(Int(item.protein.rounded()))g  K \(Int(item.carbs.rounded()))g  Y \(Int(item.fat.rounded()))g")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                Spacer()
            }
        }
        .buttonStyle(.plain)
    }
}
