import SwiftUI
import SwiftData

struct SpendingLogView: View {
    let activeDate: Date
    let isToday: Bool
    let onBackToToday: () -> Void
    let onCalendar: () -> Void
    let onSettings: () -> Void

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

    private var dayTotal: Double {
        dayEntries.reduce(0) { $0 + $1.amount }
    }

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
        let entry = SpendLogEntry(date: activeDate, category: category, amount: amountValue)
        context.insert(entry)
        try? context.save()
        amountText = "0"
    }

    private func delete(_ entry: SpendLogEntry) {
        withAnimation {
            context.delete(entry)
            try? context.save()
        }
    }

    private var headerTitle: String {
        isToday ? "Harcama" : DateFormatters.monthDay.string(from: activeDate)
    }

    var body: some View {
        VStack(spacing: 0) {
            AppHeader(
                kicker: DateFormatters.kicker(for: activeDate),
                title: headerTitle,
                showBackToToday: !isToday,
                onBackToToday: onBackToToday,
                onCalendar: onCalendar,
                onSettings: onSettings
            )
            progress
            entriesSection
            categoryBlock
            amountDisplay
            AmountKeypad(onPress: press)
                .padding(.horizontal, 16)
                .padding(.top, 4)
            submitButton
        }
        .padding(.top, 54)
        .sheet(item: $editingEntry) { entry in
            SpendEntryEditorSheet(entry: entry) {
                delete(entry)
            }
            .preferredColorScheme(.dark)
        }
    }

    private var progress: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(isToday ? "BUGÜN" : "GÜNLÜK")
                    .font(.system(size: 11, weight: .semibold))
                    .tracking(1.2)
                    .foregroundStyle(AppColor.text3)
                Spacer()
                HStack(spacing: 0) {
                    Text(DateFormatters.lira.string(from: NSNumber(value: dayTotal)) ?? "₺0")
                        .font(.system(size: 15, weight: .semibold))
                        .monospacedDigit()
                        .foregroundStyle(AppColor.textPrimary)
                    Text(" / ")
                        .font(.system(size: 15))
                        .foregroundStyle(AppColor.text3)
                    Text(DateFormatters.lira.string(from: NSNumber(value: goal)) ?? "₺0")
                        .font(.system(size: 15))
                        .monospacedDigit()
                        .foregroundStyle(AppColor.text3)
                }
            }
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Capsule().fill(Color.white.opacity(0.08))
                    Capsule().fill(AppColor.gold)
                        .frame(width: geo.size.width * min(1, dayTotal / Double(goal)))
                }
            }
            .frame(height: 4)
        }
        .padding(.horizontal, 22)
        .padding(.bottom, 12)
        .padding(.top, 4)
    }

    private var entriesSection: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(isToday ? "BUGÜNKÜ KAYITLAR" : "GÜN KAYITLARI")
                .font(.system(size: 11, weight: .heavy))
                .tracking(1)
                .foregroundStyle(AppColor.text3)
                .padding(.horizontal, 6)
            DayEntriesList(
                entries: dayEntries,
                onTapEntry: { editingEntry = $0 },
                onDelete: { delete($0) }
            )
        }
        .padding(.horizontal, 16)
        .padding(.bottom, 10)
    }

    private var categoryBlock: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("KATEGORİ")
                .font(.system(size: 11, weight: .heavy))
                .tracking(1)
                .foregroundStyle(AppColor.text3)
                .padding(.horizontal, 6)
            CategoryGrid(selection: $category)
        }
        .padding(.horizontal, 16)
        .padding(.bottom, 4)
    }

    private var amountDisplay: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("TUTAR")
                .font(.system(size: 11, weight: .heavy))
                .tracking(1)
                .foregroundStyle(AppColor.text3)
            HStack(alignment: .lastTextBaseline, spacing: 10) {
                Text("₺")
                    .font(.system(size: 28, weight: .light))
                    .foregroundStyle(AppColor.gold)
                Text(amountText)
                    .font(.system(size: 34, weight: .medium))
                    .monospacedDigit()
                    .tracking(-1)
                    .foregroundStyle(AppColor.textPrimary)
                Rectangle()
                    .fill(AppColor.gold)
                    .frame(width: 2, height: 32)
                Spacer(minLength: 0)
            }
            .padding(.bottom, 6)
            .overlay(
                Rectangle().fill(AppColor.gold.opacity(0.5)).frame(height: 1),
                alignment: .bottom
            )
        }
        .padding(.horizontal, 22)
        .padding(.top, 8)
        .padding(.bottom, 2)
    }

    private var submitButton: some View {
        Button(action: submit) {
            Text("EKLE")
                .font(.system(size: 15, weight: .heavy))
                .tracking(1.5)
                .foregroundStyle(.black)
                .frame(maxWidth: .infinity)
                .frame(height: 46)
                .background(
                    RoundedRectangle(cornerRadius: 14).fill(AppColor.gold)
                )
        }
        .buttonStyle(.plain)
        .disabled(amountValue <= 0)
        .opacity(amountValue <= 0 ? 0.5 : 1)
        .padding(.horizontal, 16)
        .padding(.top, 4)
        .padding(.bottom, 10)
    }
}
