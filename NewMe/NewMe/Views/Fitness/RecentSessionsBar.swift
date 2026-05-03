import SwiftUI

/// One past session, condensed for the read-only "Son N antrenman" bar.
/// Field meaning depends on the exercise kind; the bar just renders
/// whatever strings the factory produced.
struct ExerciseSessionSummary: Identifiable, Equatable {
    var id: Date { date }
    let date: Date
    let valueText: String          // e.g. "80", "10", "30"
    let unitText: String           // e.g. "kg", "rep", "dk"
    let detailText: String         // e.g. "x 8 rep" (weight) or "" (others)
    let deltaValue: Double?        // signed delta vs previous session
    let deltaUnit: String          // "kg" / "rep" / "dk"
    let isActive: Bool             // matches the currently-active editing date

    /// Build summaries (chronological order, oldest → newest) for the
    /// up-to-3 most recent sessions of `exercise` whose date is ≤
    /// `activeDate`. The card matching `activeDate` gets `isActive = true`.
    static func makeRecent(
        for exercise: ExerciseItem,
        from allEntries: [FitnessLogEntry],
        activeDate: Date
    ) -> [ExerciseSessionSummary] {
        let cal = Calendar.current
        let endDay = cal.startOfDay(for: activeDate)

        let sorted = allEntries
            .filter {
                $0.exercise?.persistentModelID == exercise.persistentModelID
                && !$0.sets.isEmpty
            }
            .sorted { $0.date < $1.date }

        let upTo = sorted.filter { $0.date <= endDay }
        guard !upTo.isEmpty else { return [] }

        let visibleCount = min(3, upTo.count)
        let visibleStart = upTo.count - visibleCount

        return (visibleStart..<upTo.count).map { idx in
            let entry = upTo[idx]
            let prev: FitnessLogEntry? = idx > 0 ? upTo[idx - 1] : nil
            return summary(for: entry, prev: prev, kind: exercise.kind, activeDate: endDay)
        }
    }

    private static func summary(
        for entry: FitnessLogEntry,
        prev: FitnessLogEntry?,
        kind: ExerciseKind,
        activeDate: Date
    ) -> ExerciseSessionSummary {
        let cal = Calendar.current
        let isActive = cal.isDate(entry.date, inSameDayAs: activeDate)

        switch kind {
        case .weight:
            let top = entry.sets.max(by: { $0.kg < $1.kg })
            let kg = top?.kg ?? 0
            let reps = top?.reps ?? 0
            let prevKg = prev?.sets.max(by: { $0.kg < $1.kg })?.kg
            return .init(
                date: entry.date,
                valueText: format(kg),
                unitText: "kg",
                detailText: reps > 0 ? "x \(reps) rep" : "",
                deltaValue: prevKg.map { kg - $0 },
                deltaUnit: "kg",
                isActive: isActive
            )
        case .bodyweight:
            let top = entry.sets.max(by: { $0.reps < $1.reps })
            let reps = top?.reps ?? 0
            let prevReps = prev?.sets.max(by: { $0.reps < $1.reps })?.reps
            return .init(
                date: entry.date,
                valueText: "\(reps)",
                unitText: "rep",
                detailText: "",
                deltaValue: prevReps.map { Double(reps - $0) },
                deltaUnit: "rep",
                isActive: isActive
            )
        case .cardio:
            let mins = entry.totalMinutes
            let prevMins = prev?.totalMinutes
            return .init(
                date: entry.date,
                valueText: format(mins),
                unitText: "dk",
                detailText: "",
                deltaValue: prevMins.map { mins - $0 },
                deltaUnit: "dk",
                isActive: isActive
            )
        }
    }

    private static func format(_ v: Double) -> String {
        v == v.rounded() ? "\(Int(v))" : String(format: "%.1f", v)
    }
}

struct RecentSessionsBar: View {
    let sessions: [ExerciseSessionSummary]

    var body: some View {
        if sessions.isEmpty {
            EmptyView()
        } else {
            VStack(alignment: .leading, spacing: 8) {
                Text("SON \(sessions.count) ANTRENMAN")
                    .font(.system(size: 10, weight: .heavy))
                    .tracking(1)
                    .foregroundStyle(AppColor.text3)
                HStack(spacing: 8) {
                    ForEach(sessions) { s in
                        SessionMiniCard(summary: s)
                    }
                }
            }
            .padding(.top, 14)
            .allowsHitTesting(false)
        }
    }
}

private struct SessionMiniCard: View {
    let summary: ExerciseSessionSummary

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(headerText)
                .font(.system(size: 9, weight: .heavy))
                .tracking(0.5)
                .foregroundStyle(summary.isActive ? AppColor.gold : AppColor.text3)
            HStack(alignment: .firstTextBaseline, spacing: 2) {
                Text(summary.valueText)
                    .font(.system(size: 18, weight: .bold))
                    .monospacedDigit()
                    .foregroundStyle(AppColor.textPrimary)
                Text(summary.unitText)
                    .font(.system(size: 10))
                    .foregroundStyle(AppColor.text3)
            }
            if !summary.detailText.isEmpty {
                Text(summary.detailText)
                    .font(.system(size: 10))
                    .foregroundStyle(AppColor.text2)
            }
            deltaRow
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(10)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(Color.white.opacity(0.04))
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(
                            summary.isActive ? AppColor.gold.opacity(0.55) : Color.white.opacity(0.06),
                            lineWidth: summary.isActive ? 1.2 : 1
                        )
                )
        )
    }

    private var headerText: String {
        if Calendar.current.isDateInToday(summary.date) { return "BUGÜN" }
        return DateFormatters.monthDayShort.string(from: summary.date).uppercased()
    }

    @ViewBuilder
    private var deltaRow: some View {
        if let delta = summary.deltaValue, delta != 0 {
            HStack(spacing: 2) {
                Image(systemName: delta > 0 ? "arrow.up" : "arrow.down")
                    .font(.system(size: 9, weight: .bold))
                Text("\(formatAbs(delta)) \(summary.deltaUnit)")
                    .font(.system(size: 10, weight: .semibold))
                    .monospacedDigit()
            }
            .foregroundStyle(delta > 0 ? AppColor.success : AppColor.danger)
        } else {
            // Reserve space so cards stay the same height even when delta is absent
            Text(" ")
                .font(.system(size: 10, weight: .semibold))
        }
    }

    private func formatAbs(_ v: Double) -> String {
        let abs = Swift.abs(v)
        return abs == abs.rounded() ? "\(Int(abs))" : String(format: "%.1f", abs)
    }
}
