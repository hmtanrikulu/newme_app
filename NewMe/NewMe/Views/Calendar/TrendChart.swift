import SwiftUI
import Charts

struct TrendChart: View {
    let days: [DayRollup]
    let goalKcal: Int
    @Binding var selected: Date

    private var maxKcal: Double {
        max(Double(goalKcal) * 1.1, days.map(\.kcal).max() ?? 0)
    }
    private var maxSpend: Double {
        max(1, days.map(\.totalSpend).max() ?? 1)
    }
    /// Spend bars are scaled into the kcal axis so a single Y range
    /// hosts both series. 70% of chart height max bar.
    private func scaledSpend(_ v: Double) -> Double {
        (v / maxSpend) * maxKcal * 0.7
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack {
                Text("SON 7 GÜN")
                    .font(.system(size: 11, weight: .heavy))
                    .tracking(1)
                    .foregroundStyle(AppColor.text3)
                Spacer()
                Text("kcal · harcama")
                    .font(.system(size: 11))
                    .foregroundStyle(AppColor.text3)
            }
            .padding(.horizontal, 6)
            .padding(.bottom, 10)

            chart
                .frame(height: 150)
                .padding(.horizontal, 4)
                .padding(.top, 12)

            HStack(spacing: 0) {
                ForEach(days) { day in
                    Button {
                        selected = day.date
                    } label: {
                        VStack(spacing: 2) {
                            Text(DateFormatters.weekdayShort.string(from: day.date).uppercased())
                                .font(.system(size: 9, weight: .heavy))
                                .tracking(0.5)
                            Text("\(Calendar.current.component(.day, from: day.date))")
                                .font(.system(size: 12, weight: .semibold))
                                .monospacedDigit()
                        }
                        .foregroundStyle(textColor(for: day))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 4)
                        .contentShape(Rectangle())
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, 4)

            HStack(spacing: 12) {
                LegendDot(color: AppColor.gold, label: "kcal", isLine: true)
                LegendDot(color: AppColor.macroCarb, label: "harcama", isLine: false)
            }
            .padding(.horizontal, 10)
            .padding(.top, 4)
            .padding(.bottom, 8)
        }
        .padding(.horizontal, 4)
        .padding(.vertical, 4)
        .background(
            RoundedRectangle(cornerRadius: 14)
                .fill(AppColor.surface)
                .overlay(
                    RoundedRectangle(cornerRadius: 14)
                        .stroke(Color.white.opacity(0.06), lineWidth: 1)
                )
        )
    }

    private var chart: some View {
        Chart {
            // Spend bars (scaled into kcal axis)
            ForEach(days) { day in
                BarMark(
                    x: .value("Day", day.date, unit: .day),
                    y: .value("Spend", scaledSpend(day.totalSpend)),
                    width: .fixed(12)
                )
                .foregroundStyle(
                    LinearGradient(
                        colors: [AppColor.macroCarb.opacity(0.95), AppColor.macroCarb.opacity(0.55)],
                        startPoint: .top, endPoint: .bottom
                    )
                )
                .opacity(Calendar.current.isDate(day.date, inSameDayAs: selected) ? 1.0 : 0.7)
                .cornerRadius(2)
            }

            // Goal line
            RuleMark(y: .value("Hedef", goalKcal))
                .lineStyle(StrokeStyle(lineWidth: 1, dash: [3, 3]))
                .foregroundStyle(AppColor.gold.opacity(0.3))
                .annotation(position: .top, alignment: .trailing) {
                    Text("hedef")
                        .font(.system(size: 9))
                        .foregroundStyle(AppColor.gold.opacity(0.6))
                }

            // Kcal area + line
            ForEach(days) { day in
                AreaMark(
                    x: .value("Day", day.date, unit: .day),
                    y: .value("Kcal", day.kcal)
                )
                .interpolationMethod(.catmullRom)
                .foregroundStyle(
                    LinearGradient(
                        colors: [AppColor.gold.opacity(0.4), AppColor.gold.opacity(0)],
                        startPoint: .top, endPoint: .bottom
                    )
                )
            }
            ForEach(days) { day in
                LineMark(
                    x: .value("Day", day.date, unit: .day),
                    y: .value("Kcal", day.kcal)
                )
                .interpolationMethod(.catmullRom)
                .foregroundStyle(AppColor.gold)
                .lineStyle(StrokeStyle(lineWidth: 2, lineCap: .round, lineJoin: .round))
            }

            // Points
            ForEach(days) { day in
                let isSel = Calendar.current.isDate(day.date, inSameDayAs: selected)
                PointMark(
                    x: .value("Day", day.date, unit: .day),
                    y: .value("Kcal", day.kcal)
                )
                .symbolSize(isSel ? 80 : 30)
                .foregroundStyle(isSel ? .white : AppColor.gold)
            }
        }
        .chartYScale(domain: 0...maxKcal)
        .chartXAxis(.hidden)
        .chartYAxis(.hidden)
        .chartLegend(.hidden)
        .chartOverlay { proxy in
            GeometryReader { geo in
                Rectangle().fill(.clear).contentShape(Rectangle())
                    .onTapGesture { location in
                        if let plotFrame = proxy.plotFrame {
                            let frame = geo[plotFrame]
                            let x = location.x - frame.minX
                            guard frame.contains(location),
                                  let date: Date = proxy.value(atX: x) else { return }
                            // snap to nearest day in `days`
                            let nearest = days.min(by: {
                                abs($0.date.timeIntervalSince(date)) < abs($1.date.timeIntervalSince(date))
                            })
                            if let d = nearest { selected = d.date }
                        }
                    }
            }
        }
    }

    private func textColor(for day: DayRollup) -> Color {
        let cal = Calendar.current
        if cal.isDate(day.date, inSameDayAs: selected) { return AppColor.gold }
        if cal.isDateInToday(day.date) { return AppColor.textPrimary }
        return AppColor.text3
    }
}

private struct LegendDot: View {
    let color: Color
    let label: String
    let isLine: Bool

    var body: some View {
        HStack(spacing: 5) {
            if isLine {
                Capsule().fill(color).frame(width: 10, height: 2)
            } else {
                RoundedRectangle(cornerRadius: 2).fill(color).frame(width: 8, height: 8)
            }
            Text(label)
                .font(.system(size: 10))
                .foregroundStyle(AppColor.text3)
        }
    }
}
