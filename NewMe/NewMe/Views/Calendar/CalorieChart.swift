import SwiftUI
import Charts

struct CalorieChart: View {
    let entries: [FoodLogEntry]
    let goalKcal: Int

    @State private var selectedRange: KcalRange = .month

    enum KcalRange: String, CaseIterable {
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

    private struct DayPoint: Identifiable {
        let id: Date
        let date: Date
        let kcal: Double
    }

    private var dataPoints: [DayPoint] {
        let cal = Calendar.current
        let now = Date.now
        let days = selectedRange.calendarDays
        return (0..<days).reversed().compactMap { offset -> DayPoint? in
            guard let day = cal.date(byAdding: .day, value: -offset, to: now) else { return nil }
            let start = cal.startOfDay(for: day)
            guard let end = cal.date(byAdding: .day, value: 1, to: start) else { return nil }
            let total = entries
                .filter { $0.date >= start && $0.date < end }
                .reduce(0) { $0 + $1.kcal }
            return DayPoint(id: start, date: start, kcal: total)
        }
    }

    var body: some View {
        VStack(spacing: 14) {
            rangePicker
            chartBody
            summaryRow
        }
    }

    private var rangePicker: some View {
        HStack(spacing: 0) {
            ForEach(KcalRange.allCases, id: \.rawValue) { range in
                Button(range.rawValue) {
                    withAnimation(.spring(response: 0.28, dampingFraction: 0.8)) {
                        selectedRange = range
                    }
                }
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
                .animation(.easeInOut(duration: 0.15), value: selectedRange)
            }
        }
        .padding(4)
        .background(Color(UIColor.tertiarySystemGroupedBackground), in: RoundedRectangle(cornerRadius: 12))
    }

    @ViewBuilder
    private var chartBody: some View {
        let data = dataPoints
        let goal = Double(goalKcal)
        let maxY = max(goal * 1.2, (data.map(\.kcal).max() ?? 1) * 1.2)

        Chart {
            if goalKcal > 0 {
                RuleMark(y: .value("Hedef", goal))
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
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .interpolationMethod(.catmullRom)
            }
        }
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

    private var summaryRow: some View {
        let data = dataPoints
        let total = data.reduce(0) { $0 + $1.kcal }
        let nonZero = data.filter { $0.kcal > 0 }
        let avg = nonZero.isEmpty ? 0.0 : total / Double(nonZero.count)
        return HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text("Toplam").font(.caption2).foregroundStyle(.secondary)
                Text("\(Int(total.rounded())) kcal")
                    .font(.subheadline.weight(.semibold)).monospacedDigit()
            }
            Spacer()
            VStack(alignment: .trailing, spacing: 2) {
                Text("Günlük Ort.").font(.caption2).foregroundStyle(.secondary)
                Text("\(Int(avg.rounded())) kcal")
                    .font(.subheadline.weight(.semibold)).monospacedDigit()
            }
        }
    }

    private var xAxisCount: Int {
        switch selectedRange {
        case .day: return 4; case .week: return 7
        case .month: return 5; case .quarter, .year: return 6
        }
    }

    private var xFormat: Date.FormatStyle {
        switch selectedRange {
        case .day:            return .dateTime.hour()
        case .week, .month:   return .dateTime.day().month(.abbreviated)
        case .quarter, .year: return .dateTime.month(.abbreviated)
        }
    }
}
