import SwiftUI
import SwiftData

struct FitnessLogView: View {
    let onCalendar: () -> Void
    let onSettings: () -> Void

    @Environment(\.modelContext) private var context
    @Query(sort: [SortDescriptor(\ExerciseItem.sortOrder), SortDescriptor(\ExerciseItem.name)])
    private var exercises: [ExerciseItem]
    @Query private var todayEntries: [FitnessLogEntry]

    @State private var openExerciseID: PersistentIdentifier?

    private var entriesByExercise: [PersistentIdentifier: FitnessLogEntry] {
        let today = Calendar.current.startOfDay(for: .now)
        var map: [PersistentIdentifier: FitnessLogEntry] = [:]
        for entry in todayEntries where Calendar.current.isDate(entry.date, inSameDayAs: today) {
            if let id = entry.exercise?.persistentModelID {
                map[id] = entry
            }
        }
        return map
    }

    private var totalSets: Int {
        entriesByExercise.values.reduce(0) { $0 + $1.sets.count }
    }
    private var totalVolume: Double {
        entriesByExercise.values.reduce(0) { $0 + $1.volume }
    }
    private var movementCount: Int {
        entriesByExercise.values.filter { !$0.sets.isEmpty }.count
    }

    private func entryFor(_ ex: ExerciseItem) -> FitnessLogEntry? {
        entriesByExercise[ex.persistentModelID]
    }

    private func ensureEntry(for ex: ExerciseItem) -> FitnessLogEntry {
        if let existing = entryFor(ex) { return existing }
        let new = FitnessLogEntry(date: .now, sets: [], exercise: ex)
        context.insert(new)
        return new
    }

    private func addSet(for ex: ExerciseItem) {
        let entry = ensureEntry(for: ex)
        let last = entry.sets.last
        let newSet = SetData(reps: last?.reps ?? 8, kg: last?.kg ?? 20)
        entry.sets.append(newSet)
        try? context.save()
    }

    private func updateSet(for ex: ExerciseItem, at index: Int, with set: SetData) {
        guard let entry = entryFor(ex), entry.sets.indices.contains(index) else { return }
        if entry.sets[index] != set {
            entry.sets[index] = set
            try? context.save()
        }
    }

    private func deleteSet(for ex: ExerciseItem, at index: Int) {
        guard let entry = entryFor(ex), entry.sets.indices.contains(index) else { return }
        entry.sets.remove(at: index)
        if entry.sets.isEmpty { context.delete(entry) }
        try? context.save()
    }

    var body: some View {
        VStack(spacing: 0) {
            AppHeader(
                kicker: "BUGÜN",
                title: DateFormatters.dateLabel.string(from: .now),
                onCalendar: onCalendar,
                onSettings: onSettings
            )
            summary
            list
        }
        .padding(.top, 54)
        .onAppear {
            if openExerciseID == nil {
                openExerciseID = exercises.first?.persistentModelID
            }
        }
    }

    private var summary: some View {
        HStack(spacing: 10) {
            SummaryPill(label: "SET", value: "\(totalSets)")
            SummaryPill(label: "HACİM", value: "\(Int(totalVolume.rounded()).formatted(.number.locale(Locale(identifier: "tr_TR")))) kg")
            SummaryPill(label: "HAREKET", value: "\(movementCount)")
        }
        .padding(.horizontal, 22)
        .padding(.bottom, 14)
    }

    private var list: some View {
        ScrollView {
            VStack(spacing: 8) {
                ForEach(exercises) { ex in
                    ExerciseCard(
                        exercise: ex,
                        entry: entryFor(ex),
                        isOpen: openExerciseID == ex.persistentModelID,
                        onToggleOpen: {
                            openExerciseID = openExerciseID == ex.persistentModelID ? nil : ex.persistentModelID
                        },
                        onAddSet:    { addSet(for: ex) },
                        onUpdateSet: { idx, set in updateSet(for: ex, at: idx, with: set) },
                        onDeleteSet: { idx in deleteSet(for: ex, at: idx) }
                    )
                }
                Color.clear.frame(height: 16)
            }
            .padding(.horizontal, 16)
        }
    }
}
