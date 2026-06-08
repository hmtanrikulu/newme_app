import SwiftUI
import Charts

// MARK: — Public shell (holds @State, renders picker + child chart)

struct SpendChart: View {
    let entries: [SpendLogEntry]
    @State private var selectedRange: ChartRange = .month

    enum ChartRange: String, CaseIterable, Equatable {
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
            // Pass range as a `let` so SwiftUI sees the dependency directly
            SpendChartBody(entries: entries, range: selectedRange)
            summaryRow
        }
    }

    // MARK: Picker

    private var rangePicker: some View {
        HStack(spacing: 0) {
            ForEach(ChartRange.allCases, id: \.rawValue) { range in
                Button {
                    selectedRange = range
                } label: {
                    Text(range.rawValue)
                        .font(.caption.weight(selectedRange == range ? .bold : .regular))
                        .foregroundStyle(selectedRange == range ? Color.accentColor : Color.secondary)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 6)
                        .background(
                            Group {
                                if selectedRange == range {
                                    Capsule().fill(Color.accentColor.opacity(0.15))
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
        let data = SpendChartBody.buildPoints(entries: entries, range: selectedRange)
        let total = data.reduce(0) { $0 + $1.amount }
        let nonZero = data.filter { $0.amount > 0 }
        let avg = nonZero.isEmpty ? 0.0 : total / Double(nonZero.count)
        return HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text("Toplam").font(.caption2).foregroundStyle(.secondary)
                Text("₺\(Int(total.rounded()))").font(.subheadline.weight(.semibold)).monospacedDigit()
            }
            Spacer()
            VStack(alignment: .trailing, spacing: 2) {
                Text("Günlük Ort.").font(.caption2).foregroundStyle(.secondary)
                Text("₺\(Int(avg.rounded()))").font(.subheadline.weight(.semibold)).monospacedDigit()
            }
        }
    }
}

// MARK: — Private child view (range is a `let` — SwiftUI tracks it as input)

private struct SpendChartBody: View {
    let entries: [SpendLogEntry]
    let range: SpendChart.ChartRange

    struct DayPoint: Identifiable {
        let id: Date
        let date: Date
        let amount: Double
    }

    static func buildPoints(entries: [SpendLogEntry], range: SpendChart.ChartRange) -> [DayPoint] {
        let cal = Calendar.current
        let now = Date.now
        return (0..<range.calendarDays).reversed().compactMap { offset -> DayPoint? in
            guard let day = cal.date(byAdding: .day, value: -offset, to: now) else { return nil }
            let start = cal.startOfDay(for: day)
            guard let end = cal.date(byAdding: .day, value: 1, to: start) else { return nil }
            let total = entries
                .filter { $0.date >= start && $0.date < end }
                .reduce(0) { $0 + $1.amount }
            return DayPoint(id: start, date: start, amount: total)
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

    private var maxY: Double { (data.map(\.amount).max() ?? 1) * 1.25 }

    private var xAxisCount: Int {
        switch range {
        case .day: return 4; case .week: return 7
        case .month: return 5; case .quarter, .year: return 6
        }
    }

    private var xFormat: Date.FormatStyle {
        switch range {
        case .day:             return .dateTime.hour()
        case .week, .month:    return .dateTime.day().month(.abbreviated)
        case .quarter, .year:  return .dateTime.month(.abbreviated)
        }
    }

    var body: some View {
        Chart(data) { point in
            LineMark(
                x: .value("Tarih", point.date, unit: .day),
                y: .value("Harcama", point.amount)
            )
            .foregroundStyle(Color.accentColor)
            .interpolationMethod(.catmullRom)
            .lineStyle(StrokeStyle(lineWidth: 2))

            AreaMark(
                x: .value("Tarih", point.date, unit: .day),
                yStart: .value("Zero", 0),
                yEnd: .value("Harcama", point.amount)
            )
            .foregroundStyle(
                LinearGradient(
                    colors: [Color.accentColor.opacity(0.25), Color.accentColor.opacity(0)],
                    startPoint: .top, endPoint: .bottom
                )
            )
            .interpolationMethod(.catmullRom)
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
                        Text(v >= 1000 ? "₺\(Int(v / 1000))k" : "₺\(Int(v))")
                            .font(.caption2).foregroundStyle(Color.secondary)
                    }
                }
            }
        }
        .frame(height: 180)
    }
}
