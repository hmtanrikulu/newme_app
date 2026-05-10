import SwiftUI

struct FoodDraft {
    var name: String = ""
    var kcal: Double = 100
    var protein: Double = 0
    var carbs: Double = 0
    var fat: Double = 0
    var unit: String = "g"
    var gramsPerUnit: Double = 1
    var servingSize: Double = 100
}

struct FoodEditorSheet: View {
    let initial: FoodDraft?
    let onSave: (FoodDraft) -> Void

    @Environment(\.dismiss) private var dismiss
    @State private var draft: FoodDraft

    init(initial: FoodDraft?, onSave: @escaping (FoodDraft) -> Void) {
        self.initial = initial
        self.onSave = onSave
        _draft = State(initialValue: initial ?? FoodDraft())
    }

    private var canSave: Bool {
        !draft.name.trimmingCharacters(in: .whitespaces).isEmpty
    }

    private var isWeightUnit: Bool { draft.unit == "g" || draft.unit == "ml" }

    private var portionGrams: Double { draft.servingSize * draft.gramsPerUnit }

    private var previewKcal: Int {
        Int((portionGrams / 100 * draft.kcal).rounded())
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Yiyecek") {
                    TextField("İsim (örn. Yulaf)", text: $draft.name)
                    HStack {
                        Text("Birim")
                        Spacer()
                        Picker("", selection: $draft.unit) {
                            ForEach(["g", "ml", "adet", "dilim"], id: \.self) { Text($0).tag($0) }
                        }
                        .pickerStyle(.menu)
                        .onChange(of: draft.unit) { _, newUnit in
                            // g/ml: 1 unit = 1 g implicitly. adet/dilim: keep current
                            // gramsPerUnit if the user already set one, else prefill 50.
                            if newUnit == "g" || newUnit == "ml" {
                                draft.gramsPerUnit = 1
                            } else if draft.gramsPerUnit <= 1 {
                                draft.gramsPerUnit = 50
                            }
                        }
                    }
                    if !isWeightUnit {
                        LabeledNumberField(
                            label: "1 \(draft.unit) ağırlığı",
                            value: $draft.gramsPerUnit,
                            suffix: "g",
                            decimals: 1
                        )
                    }
                    LabeledNumberField(
                        label: "Porsiyon büyüklüğü",
                        value: $draft.servingSize,
                        suffix: draft.unit,
                        decimals: 1
                    )
                    if portionGrams > 0 && draft.kcal > 0 {
                        HStack {
                            Text("1 porsiyon")
                                .foregroundStyle(AppColor.text2)
                            Spacer()
                            Text("\(formatGrams(portionGrams)) g · \(previewKcal) kcal")
                                .monospacedDigit()
                                .foregroundStyle(AppColor.text3)
                        }
                    }
                }
                Section("100 g için") {
                    LabeledNumberField(label: "Kalori", value: $draft.kcal, suffix: "kcal", decimals: 0)
                    LabeledNumberField(label: "Protein", value: $draft.protein, suffix: "g", decimals: 1)
                    LabeledNumberField(label: "Karbonhidrat", value: $draft.carbs, suffix: "g", decimals: 1)
                    LabeledNumberField(label: "Yağ", value: $draft.fat, suffix: "g", decimals: 1)
                }
            }
            .scrollContentBackground(.hidden)
            .background(AppColor.bg)
            .navigationTitle(initial == nil ? "Yeni Yiyecek" : "Yiyecek")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("İptal") { dismiss() }.foregroundStyle(AppColor.gold)
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Kaydet") {
                        onSave(draft)
                        dismiss()
                    }
                    .foregroundStyle(canSave ? AppColor.gold : Color.gray)
                    .disabled(!canSave)
                }
            }
        }
    }

    private func formatGrams(_ v: Double) -> String {
        v == v.rounded() ? "\(Int(v))" : String(format: "%.1f", v)
    }
}

private struct LabeledNumberField: View {
    let label: String
    @Binding var value: Double
    let suffix: String
    let decimals: Int

    @State private var text: String = ""

    var body: some View {
        HStack {
            Text(label)
            Spacer()
            TextField("", text: $text)
                .keyboardType(decimals > 0 ? .decimalPad : .numberPad)
                .multilineTextAlignment(.trailing)
                .monospacedDigit()
                .onAppear { text = format(value) }
                .onChange(of: text) { _, newValue in
                    let normalized = newValue.replacingOccurrences(of: ",", with: ".")
                    if let n = Double(normalized) { value = n }
                }
            Text(suffix).foregroundStyle(AppColor.text3)
        }
    }

    private func format(_ v: Double) -> String {
        decimals > 0 ? String(format: "%.\(decimals)f", v) : "\(Int(v.rounded()))"
    }
}
