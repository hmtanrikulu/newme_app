import SwiftUI
import SwiftData

struct SpendingLogView: View {
    let activeDate: Date

    @Environment(\.modelContext) private var context
    @Query private var allEntries: [SpendLogEntry]
    @Query private var goalsRows: [UserGoals]

    @State private var category: SpendCategory = .food
    @State private var amountText: String = "0"
    @State private var editingEntry: SpendLogEntry?

    private var goal: Int { goalsRows.first?.dailySpendLimit ?? 5000 }

    private var dayEntries: [SpendLogEntry] {
        allEntries
            .filter { Calendar.current.isDate($0.date, inSameDayAs: activeDate) }
            .sorted { $0.timestamp > $1.timestamp }
    }

    private var dayTotal: Double { dayEntries.reduce(0) { $0 + $1.amount } }

    private var amountValue: Double {
        Double(amountText.replacingOccurrences(of: ",", with: ".")) ?? 0
    }

    private func press(_ key: KeypadKey) {
        switch key {
        case .digit(let d):
            amountText = (amountText == "0") ? d : amountText + d
        case .dot:
            if !amountText.contains(".") { amountText += "." }
        case .delete:
            amountText = String(amountText.dropLast())
            if amountText.isEmpty { amountText = "0" }
        }
    }

    private func submit() {
        guard amountValue > 0 else { return }
        context.insert(SpendLogEntry(date: activeDate, category: category, amount: amountValue))
        try? context.save()
        amountText = "0"
    }

    private func delete(_ entry: SpendLogEntry) {
        context.delete(entry)
        try? context.save()
    }

    var body: some View {
        VStack(spacing: 0) {
            // Entries + category in a scrollable area
            List {
                // Progress
                Section {
                    VStack(alignment: .leading, spacing: 6) {
                        HStack {
                            Text("Bugün")
                                .font(.subheadline)
                            Spacer()
                            Text("₺\(Int(dayTotal.rounded())) / ₺\(goal)")
                                .font(.subheadline)
                                .monospacedDigit()
                                .foregroundStyle(.secondary)
                        }
                        ProgressView(value: min(1, dayTotal / Double(goal)))
                            .tint(dayTotal > Double(goal) ? .red : .accentColor)
                    }
                }

                // Category picker
                Section("Kategori") {
                    CategoryGrid(selection: $category)
                        .listRowInsets(EdgeInsets(top: 8, leading: 8, bottom: 8, trailing: 8))
                }

                // Logged entries
                if !dayEntries.isEmpty {
                    Section("Kayıtlar") {
                        ForEach(dayEntries) { entry in
                            SpendEntryRow(entry: entry)
                                .onTapGesture { editingEntry = entry }
                                .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                                    Button(role: .destructive) {
                                        delete(entry)
                                    } label: {
                                        Label("Sil", systemImage: "trash")
                                    }
                                }
                        }
                    }
                }
            }
            .listStyle(.insetGrouped)

            // Fixed bottom: amount + keypad + add button
            Divider()
            VStack(spacing: 8) {
                amountDisplay
                AmountKeypad(onPress: press)
                    .padding(.horizontal, 16)
                addButton
            }
            .background(Color(UIColor.systemGroupedBackground))
            .padding(.bottom, 8)
        }
        .navigationTitle("Harcama")
        .navigationBarTitleDisplayMode(.large)
        .sheet(item: $editingEntry) { entry in
            SpendEntryEditorSheet(entry: entry) { delete(entry) }
        }
    }

    private var amountDisplay: some View {
        HStack(alignment: .lastTextBaseline, spacing: 6) {
            Text("₺")
                .font(.title2)
                .foregroundStyle(Color.accentColor)
            Text(amountText)
                .font(.system(size: 32, weight: .medium))
                .monospacedDigit()
            Spacer()
        }
        .padding(.horizontal, 22)
        .padding(.top, 10)
    }

    private var addButton: some View {
        Button(action: submit) {
            Text("Ekle")
                .font(.headline)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .background(RoundedRectangle(cornerRadius: 14).fill(Color.accentColor))
                .foregroundStyle(.black)
        }
        .buttonStyle(.plain)
        .disabled(amountValue <= 0)
        .opacity(amountValue <= 0 ? 0.4 : 1)
        .padding(.horizontal, 16)
        .padding(.bottom, 4)
        .animation(.easeInOut(duration: 0.15), value: amountValue > 0)
    }
}

// MARK: — Spend entry row

private struct SpendEntryRow: View {
    let entry: SpendLogEntry

    var body: some View {
        HStack {
            Image(systemName: entry.category.systemImage)
                .foregroundStyle(Color.accentColor)
                .frame(width: 24)
            Text(entry.category.label)
            Spacer()
            Text("₺\(Int(entry.amount))")
                .fontWeight(.medium)
                .monospacedDigit()
        }
    }
}
