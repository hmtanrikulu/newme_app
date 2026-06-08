import SwiftUI

struct WeekStrip: View {
    @Binding var selected: Date
    let today: Date
    let dayHasData: (Date) -> Bool

    @State private var weekStart: Date

    init(selected: Binding<Date>, today: Date, dayHasData: @escaping (Date) -> Bool) {
        self._selected = selected
        self.today = today
        self.dayHasData = dayHasData
        self._weekStart = State(initialValue: Self.monday(of: selected.wrappedValue))
    }

    static func monday(of date: Date) -> Date {
        let cal = Calendar.current
        let weekday = cal.component(.weekday, from: date)
        let offset = (weekday + 5) % 7 // Mon=0 … Sun=6
        return cal.startOfDay(for: cal.date(byAdding: .day, value: -offset, to: date)!)
    }

    private var days: [Date] {
        (0..<7).compactMap { Calendar.current.date(byAdding: .day, value: $0, to: weekStart) }
    }

    private var canGoForward: Bool {
        weekStart < Self.monday(of: today)
    }

    var body: some View {
        HStack(spacing: 0) {
            navButton(systemImage: "chevron.left") {
                let prev = Calendar.current.date(byAdding: .day, value: -7, to: weekStart)!
                weekStart = prev
                if !days.contains(where: { Calendar.current.isDate($0, inSameDayAs: selected) }) {
                    selected = prev
                }
            }

            ForEach(days, id: \.self) { day in
                WeekDayCell(
                    day: day,
                    isSelected: Calendar.current.isDate(day, inSameDayAs: selected),
                    isToday: Calendar.current.isDate(day, inSameDayAs: today),
                    hasData: dayHasData(day)
                ) {
                    withAnimation(.easeInOut(duration: 0.12)) { selected = day }
                }
            }

            navButton(systemImage: "chevron.right", disabled: !canGoForward) {
                guard canGoForward else { return }
                let next = Calendar.current.date(byAdding: .day, value: 7, to: weekStart)!
                weekStart = next
                if !days.contains(where: { Calendar.current.isDate($0, inSameDayAs: selected) }) {
                    selected = next
                }
            }
        }
        .onChange(of: selected) { _, newVal in
            let newMonday = Self.monday(of: newVal)
            if newMonday != weekStart {
                withAnimation(.spring(response: 0.28)) { weekStart = newMonday }
            }
        }
    }

    private func navButton(systemImage: String, disabled: Bool = false, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Image(systemName: systemImage)
                .font(.caption.weight(.semibold))
                .frame(width: 28, height: 56)
                .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .disabled(disabled)
        .foregroundStyle(disabled ? Color.secondary.opacity(0.3) : Color.secondary)
    }
}

private struct WeekDayCell: View {
    let day: Date
    let isSelected: Bool
    let isToday: Bool
    let hasData: Bool
    let action: () -> Void

    private static let weekdayFmt: DateFormatter = {
        let f = DateFormatter()
        f.locale = Locale(identifier: "tr_TR")
        f.dateFormat = "EEE"
        return f
    }()

    private var num: String { "\(Calendar.current.component(.day, from: day))" }
    private var abbr: String { String(Self.weekdayFmt.string(from: day).prefix(3)) }

    var body: some View {
        Button(action: action) {
            VStack(spacing: 2) {
                Text(abbr)
                    .font(.system(size: 10, weight: .medium))
                    .foregroundStyle(isSelected ? .black : .secondary)

                ZStack {
                    Circle()
                        .fill(isSelected
                              ? Color.accentColor
                              : isToday ? Color.accentColor.opacity(0.18) : Color.clear)
                        .frame(width: 34, height: 34)
                    Text(num)
                        .font(.system(size: 15, weight: isToday ? .bold : .regular))
                        .foregroundStyle(isSelected ? .black : isToday ? Color.accentColor : Color.primary)
                }

                Circle()
                    .fill(hasData && !isSelected ? Color.accentColor : Color.clear)
                    .frame(width: 4, height: 4)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 6)
        }
        .buttonStyle(.plain)
    }
}
