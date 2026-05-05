import SwiftUI
import SwiftData

struct SpendEntryEditorSheet: View {
    let entry: SpendLogEntry
    let onDelete: () -> Void

    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var context

    @State private var category: SpendCategory
    @State private var amountText: String
    @State private var showDeleteConfirm = false

    init(entry: SpendLogEntry, onDelete: @escaping () -> Void) {
        self.entry = entry
        self.onDelete = onDelete
        _category = State(initialValue: entry.category)
        _amountText = State(initialValue: Self.format(entry.amount))
    }

    private static func format(_ v: Double) -> String {
        let nf = NumberFormatter()
        nf.locale = Locale(identifier: "tr_TR")
        nf.numberStyle = .decimal
        nf.maximumFractionDigits = 2
        nf.minimumFractionDigits = 0
        nf.usesGroupingSeparator = false
        return nf.string(from: NSNumber(value: v)) ?? "\(v)"
    }

    private var amountValue: Double {
        Double(amountText.replacingOccurrences(of: ",", with: ".")) ?? 0
    }

    private var canSave: Bool { amountValue > 0 }

    private func save() {
        entry.category = category
        entry.amount = amountValue
        try? context.save()
        dismiss()
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Kategori") {
                    Picker("Kategori", selection: $category) {
                        ForEach(SpendCategory.allCases) { cat in
                            Label(cat.label, systemImage: cat.systemImage).tag(cat)
                        }
                    }
                }

                Section("Tutar") {
                    HStack {
                        Text("₺")
                            .font(.system(size: 18, weight: .light))
                            .foregroundStyle(AppColor.gold)
                        TextField("", text: $amountText)
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                            .font(.system(size: 18, weight: .semibold))
                            .monospacedDigit()
                    }
                }

                Section {
                    Button(role: .destructive) {
                        showDeleteConfirm = true
                    } label: {
                        HStack {
                            Image(systemName: "trash")
                            Text("Bu kaydı sil")
                        }
                    }
                }
            }
            .scrollContentBackground(.hidden)
            .background(AppColor.bg)
            .navigationTitle("Harcamayı Düzenle")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("İptal") { dismiss() }.foregroundStyle(AppColor.gold)
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Kaydet") { save() }
                        .foregroundStyle(canSave ? AppColor.gold : .gray)
                        .fontWeight(.semibold)
                        .disabled(!canSave)
                }
            }
            .alert("Bu kaydı sil?", isPresented: $showDeleteConfirm) {
                Button("Sil", role: .destructive) {
                    onDelete()
                    dismiss()
                }
                Button("Vazgeç", role: .cancel) { }
            } message: {
                Text("Bu işlem geri alınamaz.")
            }
        }
    }
}
