import SwiftUI
import VisionKit
import SwiftData

struct BarcodeScannerView: View {
    let activeDate: Date
    let defaultMeal: MealType

    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss

    @State private var scannedBarcode: String?
    @State private var lookupResult: BarcodeLookupService.Result?
    @State private var isLoading = false
    @State private var errorMessage: String?
    @State private var gram: String = "100"
    @State private var meal: MealType

    init(activeDate: Date, defaultMeal: MealType) {
        self.activeDate = activeDate
        self.defaultMeal = defaultMeal
        self._meal = State(initialValue: defaultMeal)
    }

    var body: some View {
        NavigationStack {
            ZStack {
                if let result = lookupResult {
                    confirmationView(result: result)
                } else if isLoading {
                    loadingView
                } else if errorMessage != nil {
                    errorView
                } else {
                    scannerView
                }
            }
            .navigationTitle("Barkod Tara")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("İptal") { dismiss() }
                }
            }
        }
        .presentationDetents([.large])
    }

    // MARK: — Scanner

    private var scannerView: some View {
        Group {
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
                        .padding(.horizontal, 20)
                        .padding(.vertical, 12)
                        .background(.ultraThinMaterial, in: Capsule())
                        .padding(.bottom, 32)
                }
            } else {
                ContentUnavailableView(
                    "Kamera Desteklenmiyor",
                    systemImage: "camera.slash",
                    description: Text("Bu cihaz veya iOS sürümü barkod taramayı desteklemiyor.")
                )
            }
        }
    }

    // MARK: — Loading

    private var loadingView: some View {
        VStack(spacing: 16) {
            ProgressView()
                .scaleEffect(1.5)
            Text("Ürün aranıyor…")
                .foregroundStyle(.secondary)
        }
    }

    // MARK: — Error

    private var errorView: some View {
        VStack(spacing: 20) {
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.largeTitle)
                .foregroundStyle(.orange)
            Text(errorMessage ?? "Bilinmeyen hata")
                .multilineTextAlignment(.center)
                .foregroundStyle(.secondary)
            Button("Tekrar Dene") {
                scannedBarcode = nil
                errorMessage = nil
            }
            .buttonStyle(.borderedProminent)
        }
        .padding(32)
    }

    // MARK: — Confirmation

    private func confirmationView(result: BarcodeLookupService.Result) -> some View {
        let gramVal = Double(gram) ?? 100
        let multiplier = gramVal / 100.0

        return ScrollView {
            VStack(spacing: 20) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(result.name)
                        .font(.title3.weight(.semibold))
                    if let code = scannedBarcode {
                        Text(code)
                            .font(.caption)
                            .foregroundStyle(.tertiary)
                            .monospacedDigit()
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 20)

                // Gram input
                HStack(spacing: 12) {
                    Text("Porsiyon")
                        .fontWeight(.medium)
                    Spacer()
                    TextField("100", text: $gram)
                        .keyboardType(.decimalPad)
                        .multilineTextAlignment(.trailing)
                        .frame(width: 72)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(Color(UIColor.secondarySystemGroupedBackground), in: RoundedRectangle(cornerRadius: 10))
                    Text("g")
                        .foregroundStyle(.secondary)
                }
                .padding(.horizontal, 20)

                // Macros preview
                NutritionGrid(
                    kcal: result.kcalPer100g * multiplier,
                    protein: result.proteinPer100g * multiplier,
                    carbs: result.carbsPer100g * multiplier,
                    fat: result.fatPer100g * multiplier
                )
                .padding(.horizontal, 20)

                // Meal picker
                Picker("Öğün", selection: $meal) {
                    ForEach(MealType.allCases) { m in
                        Label(m.label, systemImage: m.systemImage).tag(m)
                    }
                }
                .pickerStyle(.segmented)
                .padding(.horizontal, 20)

                Button(action: addEntry) {
                    Text("Ekle")
                        .fontWeight(.semibold)
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                        .background(Color.accentColor, in: RoundedRectangle(cornerRadius: 14))
                        .foregroundStyle(.black)
                }
                .buttonStyle(.plain)
                .padding(.horizontal, 20)

                Button {
                    scannedBarcode = nil
                    lookupResult = nil
                    errorMessage = nil
                } label: {
                    Label("Farklı Barkod Tara", systemImage: "barcode.viewfinder")
                        .foregroundStyle(Color.accentColor)
                }
                .padding(.top, 4)
            }
            .padding(.top, 24)
        }
    }

    // MARK: — Actions

    private func fetchProduct(barcode: String) {
        isLoading = true
        Task {
            do {
                let result = try await BarcodeLookupService.lookup(barcode: barcode)
                await MainActor.run {
                    lookupResult = result
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

    private func addEntry() {
        guard let result = lookupResult else { return }
        let g = Double(gram) ?? 100
        let m = g / 100.0
        let entry = FoodLogEntry(
            date: activeDate,
            mealType: meal,
            name: result.name,
            protein: result.proteinPer100g * m,
            carbs: result.carbsPer100g * m,
            fat: result.fatPer100g * m
        )
        context.insert(entry)
        try? context.save()
        dismiss()
    }
}

// DataScannerRepresentable and NutritionGrid live in ScannerComponents.swift
