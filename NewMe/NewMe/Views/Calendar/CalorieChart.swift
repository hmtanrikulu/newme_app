import SwiftUI
import Charts

// MARK: — Public shell

struct CalorieChart: View {
    let entries: [FoodLogEntry]
    let goalKcal: Int
    @State private var selectedRange: KcalRange = .month

    enum KcalRange: String, CaseIterable, Equatable {
        case day     = "1G"
        case week    = "1H"
        case month   = "1AY"
        case quarter = "3AY"
        case year    = "1YIL"

        var calendarDays: Int {
            switch self {
            case .day:     return 1
            case .week:    return 7
            case .month:   return 30
            case .quarter: return 90
            case .year:    return 365
            }
        }
    }

    var body: some View {
        VStack(spacing: 14) {
            rangePicker
            CalorieChartBody(entries: entries, goalKcal: goalKcal, range: selectedRange)
            summaryRow
        }
    }

    // MARK: Picker

    private var rangePicker: some View {
        HStack(spacing: 0) {
            ForEach(KcalRange.allCases, id: \.rawValue) { range in
                Button {
                    selectedRange = range
                } label: {
                    Text(range.rawValue)
                        .font(.caption.weight(selectedRange == range ? .bold : .regular))
                        .foregroundStyle(selectedRange == range ? AppColor.food : Color.secondary)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 6)
                        .background(
                            Group {
                                if selectedRange == range {
                                    Capsule().fill(AppColor.food.opacity(0.15))
                                }
                            }
                        )
                }
                .buttonStyle(.plain)
            }
        }
        .padding(4)
        .background(Color(UIColor.tertiarySystemGroupedBackground), in: RoundedRectangle(cornerRadius: 12))
    }

    // MARK: Summary row

    private var summaryRow: some View {
        let data = CalorieChartBody.buildPoints(entries: entries, range: selectedRange)
        let total = data.reduce(0) { $0 + $1.kcal }
        let nonZero = data.filter { $0.kcal > 0 }
        let avg = nonZero.isEmpty ? 0.0 : total / Double(nonZero.count)
        return HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text("Toplam").font(.caption2).foregroundStyle(.secondary)
                Text("\(Int(total.rounded())) kcal").font(.subheadline.weight(.semibold)).monospacedDigit()
            }
            Spacer()
            VStack(alignment: .trailing, spacing: 2) {
                Text("Günlük Ort.").font(.caption2).foregroundStyle(.secondary)
                Text("\(Int(avg.rounded())) kcal").font(.subheadline.weight(.semibold)).monospacedDigit()
            }
        }
    }
}

// MARK: — Private child view

private struct CalorieChartBody: View {
    let entries: [FoodLogEntry]
    let goalKcal: Int
    let range: CalorieChart.KcalRange

    struct DayPoint: Identifiable {
        let id: Date
        let date: Date
        let kcal: Double
    }

    static func buildPoints(entries: [FoodLogEntry], range: CalorieChart.KcalRange) -> [DayPoint] {
        let cal = Calendar.current
        let now = Date.now
        return (0..<range.calendarDays).reversed().compactMap { offset -> DayPoint? in
            guard let day = cal.date(byAdding: .day, value: -offset, to: now) else { return nil }
            let start = cal.startOfDay(for: day)
            guard let end = cal.date(byAdding: .day, value: 1, to: start) else { return nil }
            let total = entries
                .filter { $0.date >= start && $0.date < end }
                .reduce(0) { $0 + $1.kcal }
            return DayPoint(id: start, date: start, kcal: total)
        }
    }

    private var data: [DayPoint] { Self.buildPoints(entries: entries, range: range) }

    private var xDomain: ClosedRange<Date> {
        let cal = Calendar.current
        let today = cal.startOfDay(for: .now)
        let end = cal.date(byAdding: .day, value: 1, to: today) ?? today
        let start = cal.date(byAdding: .day, value: -(range.calendarDays - 1), to: today) ?? today
        return start...end
    }

    private var maxY: Double {
        let goal = Double(goalKcal)
        return max(goal * 1.2, (data.map(\.kcal).max() ?? 1) * 1.2)
    }

    private var xAxisCount: Int {
        switch range {
        case .day: return 4; case .week: return 7
        case .month: return 5; case .quarter, .year: return 6
        }
    }

    private var xFormat: Date.FormatStyle {
        switch range {
        case .day:            return .dateTime.hour()
        case .week, .month:   return .dateTime.day().month(.abbreviated)
        case .quarter, .year: return .dateTime.month(.abbreviated)
        }
    }

    var body: some View {
        Chart {
            if goalKcal > 0 {
                RuleMark(y: .value("Hedef", Double(goalKcal)))
                    .foregroundStyle(AppColor.food.opacity(0.4))
                    .lineStyle(StrokeStyle(lineWidth: 1, dash: [5]))
                    .annotation(position: .trailing) {
                        Text("Hedef")
                            .font(.system(size: 9))
                            .foregroundStyle(AppColor.food.opacity(0.6))
                    }
            }

            ForEach(data) { point in
                LineMark(
                    x: .value("Tarih", point.date, unit: .day),
                    y: .value("Kalori", point.kcal)
                )
                .foregroundStyle(AppColor.food)
                .interpolationMethod(.catmullRom)
                .lineStyle(StrokeStyle(lineWidth: 2))

                AreaMark(
                    x: .value("Tarih", point.date, unit: .day),
                    yStart: .value("Zero", 0),
                    yEnd: .value("Kalori", point.kcal)
                )
                .foregroundStyle(
                    LinearGradient(
                        colors: [AppColor.food.opacity(0.25), AppColor.food.opacity(0)],
                        startPoint: .top, endPoint: .bottom
                    )
                )
                .interpolationMethod(.catmullRom)
            }
        }
        .chartXScale(domain: xDomain)
        .chartYScale(domain: 0...maxY)
        .chartXAxis {
            AxisMarks(values: .automatic(desiredCount: xAxisCount)) { _ in
                AxisGridLine(stroke: StrokeStyle(lineWidth: 0.5, dash: [4]))
                    .foregroundStyle(Color.secondary.opacity(0.3))
                AxisValueLabel(format: xFormat)
                    .font(.caption2)
                    .foregroundStyle(Color.secondary)
            }
        }
        .chartYAxis {
            AxisMarks(values: .automatic(desiredCount: 4)) { value in
                AxisGridLine(stroke: StrokeStyle(lineWidth: 0.5, dash: [4]))
                    .foregroundStyle(Color.secondary.opacity(0.3))
                AxisValueLabel {
                    if let v = value.as(Double.self) {
                        Text("\(Int(v))").font(.caption2).foregroundStyle(Color.secondary)
                    }
                }
            }
        }
        .frame(height: 160)
    }
}
