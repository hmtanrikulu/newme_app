import SwiftUI

struct MonthGrid: View {
    let month: Date                 // any date within the month to display
    let today: Date
    @Binding var selected: Date
    let dayHasData: (Date) -> Bool

    private var cal: Calendar {
        var c = Calendar(identifier: .gregorian)
        c.locale = Locale(identifier: "tr_TR")
        c.firstWeekday = 2          // Monday
        return c
    }

    private struct Cell: Identifiable {
        let id: Int
        let date: Date?             // nil for blank padding
        let dayNumber: Int
    }

    private var cells: [Cell] {
        let comps = cal.dateComponents([.year, .month], from: month)
        let firstOfMonth = cal.date(from: comps)!
        let weekdayIdx = (cal.component(.weekday, from: firstOfMonth) - cal.firstWeekday + 7) % 7
        let range = cal.range(of: .day, in: .month, for: firstOfMonth)!.count

        var cells: [Cell] = []
        for i in 0..<weekdayIdx {
            cells.append(Cell(id: cells.count, date: nil, dayNumber: -i - 1))
        }
        for d in 1...range {
            let dt = cal.date(byAdding: .day, value: d - 1, to: firstOfMonth)!
            cells.append(Cell(id: cells.count, date: cal.startOfDay(for: dt), dayNumber: d))
        }
        while cells.count % 7 != 0 {
            cells.append(Cell(id: cells.count, date: nil, dayNumber: cells.count))
        }
        return cells
    }

    private let columns = Array(repeating: GridItem(.flexible(), spacing: 0), count: 7)

    var body: some View {
        VStack(spacing: 0) {
            LazyVGrid(columns: columns, spacing: 0) {
                ForEach(["Pzt","Sal","Çar","Per","Cum","Cmt","Paz"], id: \.self) { wd in
                    Text(wd)
                        .font(.system(size: 10, weight: .semibold))
                        .tracking(0.6)
                        .foregroundStyle(AppColor.text3)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 4)
                }
            }
            .padding(.horizontal, 12)

            LazyVGrid(columns: columns, spacing: 4) {
                ForEach(cells) { cell in
                    if let date = cell.date {
                        DayCell(
                            day: cell.dayNumber,
                            isToday: cal.isDate(date, inSameDayAs: today),
                            isSelected: cal.isDate(date, inSameDayAs: selected),
                            hasData: dayHasData(date)
                        )
                        .onTapGesture { selected = date }
                    } else {
                        Color.clear.frame(height: 42)
                    }
                }
            }
            .padding(.horizontal, 8)
        }
    }
}

private struct DayCell: View {
    let day: Int
    let isToday: Bool
    let isSelected: Bool
    let hasData: Bool

    var body: some View {
        VStack(spacing: 2) {
            Text("\(day)")
                .font(.system(size: 14, weight: (isToday || isSelected) ? .semibold : .regular))
                .monospacedDigit()
                .foregroundStyle(textColor)
                .frame(width: 30, height: 30)
                .background(
                    Circle()
                        .fill(circleFill)
                )
            Circle()
                .fill(hasData && !isSelected ? AppColor.gold : Color.clear)
                .frame(width: 4, height: 4)
        }
        .frame(height: 42)
        .contentShape(Rectangle())
    }

    private var circleFill: Color {
        if isSelected { return AppColor.gold }
        if isToday { return AppColor.gold.opacity(0.15) }
        return .clear
    }

    private var textColor: Color {
        if isSelected { return .black }
        if isToday { return AppColor.gold }
        return AppColor.textPrimary
    }
}
