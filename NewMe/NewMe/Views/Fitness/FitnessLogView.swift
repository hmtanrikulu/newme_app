import SwiftUI
import SwiftData

struct FitnessLogView: View {
    let activeDate: Date
    let isToday: Bool
    let onBackToToday: () -> Void
    let onCalendar: () -> Void
    let onSettings: () -> Void

    @Environment(\.modelContext) private var context
    @Query(sort: [SortDescriptor(\ExerciseItem.sortOrder), SortDescriptor(\ExerciseItem.name)])
    private var exercises: [ExerciseItem]
    @Query private var allEntries: [FitnessLogEntry]

    @State private var openExerciseID: PersistentIdentifier?
    @State private var openGroups: Set<String> = []
    @State private var didInitOpenGroups = false

    private struct ExerciseGroup: Identifiable {
        let id: String
        let exercises: [ExerciseItem]
    }

    private var groups: [ExerciseGroup] {
        var bucket: [String: [ExerciseItem]] = [:]
        var order: [String] = []
        for ex in exercises {
            let key = ex.kind == .cardio ? "Kardiyo" : ex.muscleGroup
            if bucket[key] == nil {
                bucket[key] = []
                order.append(key)
            }
            bucket[key]?.append(ex)
        }
        return order.map { ExerciseGroup(id: $0, exercises: bucket[$0] ?? []) }
    }

    private func setsToday(in group: ExerciseGroup) -> Int {
        group.exercises.reduce(0) { $0 + (entryFor($1)?.sets.count ?? 0) }
    }

    private func toggleGroup(_ id: String) {
        withAnimation(.spring(response: 0.28, dampingFraction: 0.85)) {
            if openGroups.contains(id) {
                openGroups.remove(id)
            } else {
                openGroups.insert(id)
            }
        }
    }

    private func syncOpenGroupsToToday() {
        openGroups.removeAll()
        for g in groups where setsToday(in: g) > 0 {
            openGroups.insert(g.id)
        }
    }

    private var entriesByExercise: [PersistentIdentifier: FitnessLogEntry] {
        var map: [PersistentIdentifier: FitnessLogEntry] = [:]
        for entry in allEntries where Calendar.current.isDate(entry.date, inSameDayAs: activeDate) {
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
        let new = FitnessLogEntry(date: activeDate, sets: [], exercise: ex)
        context.insert(new)
        return new
    }

    private func addSet(for ex: ExerciseItem) {
        let entry = ensureEntry(for: ex)
        let last = entry.sets.last
        let newSet: SetData
        switch ex.kind {
        case .weight:
            newSet = SetData(reps: last?.reps ?? 8, kg: last?.kg ?? 20)
        case .bodyweight:
            newSet = SetData(reps: last?.reps ?? 10)
        case .cardio:
            newSet = SetData(minutes: last?.minutes ?? 10)
        }
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
                kicker: DateFormatters.kicker(for: activeDate),
                title: DateFormatters.dateLabel.string(from: activeDate),
                showBackToToday: !isToday,
                onBackToToday: onBackToToday,
                onCalendar: onCalendar,
                onSettings: onSettings
            )
            summary
            list
        }
        .padding(.top, 54)
        .onAppear {
            if !didInitOpenGroups {
                syncOpenGroupsToToday()
                didInitOpenGroups = true
            }
        }
        .onChange(of: activeDate) { _, _ in
            syncOpenGroupsToToday()
            openExerciseID = nil
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
            VStack(spacing: 6) {
                ForEach(groups) { group in
                    groupSection(group)
                }
                Color.clear.frame(height: 16)
            }
            .padding(.horizontal, 16)
            .padding(.top, 2)
        }
    }

    @ViewBuilder
    private func groupSection(_ group: ExerciseGroup) -> some View {
        let isOpen = openGroups.contains(group.id)
        let setCount = setsToday(in: group)
        VStack(spacing: 6) {
            Button(action: { toggleGroup(group.id) }) {
                HStack(spacing: 10) {
                    Text(group.id.uppercased())
                        .font(.system(size: 12, weight: .heavy))
                        .tracking(1.2)
                        .foregroundStyle(AppColor.text2)
                    Text("\(group.exercises.count)")
                        .font(.system(size: 11, weight: .semibold))
                        .monospacedDigit()
                        .foregroundStyle(AppColor.text3)
                        .padding(.horizontal, 7)
                        .padding(.vertical, 2)
                        .background(Capsule().fill(Color.white.opacity(0.06)))
                    Spacer()
                    if setCount > 0 {
                        Text("\(setCount) set bugün")
                            .font(.system(size: 11, weight: .semibold))
                            .monospacedDigit()
                            .foregroundStyle(AppColor.gold)
                    }
                    Image(systemName: "chevron.right")
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundStyle(Color.white.opacity(0.4))
                        .rotationEffect(.degrees(isOpen ? 90 : 0))
                }
                .padding(.vertical, 10)
                .padding(.horizontal, 8)
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)

            if isOpen {
                VStack(spacing: 8) {
                    ForEach(group.exercises) { ex in
                        ExerciseCard(
                            exercise: ex,
                            entry: entryFor(ex),
                            recentSessions: ExerciseSessionSummary.makeRecent(
                                for: ex,
                                from: allEntries,
                                activeDate: activeDate
                            ),
                            isOpen: openExerciseID == ex.persistentModelID,
                            onToggleOpen: {
                                openExerciseID = openExerciseID == ex.persistentModelID ? nil : ex.persistentModelID
                            },
                            onAddSet:    { addSet(for: ex) },
                            onUpdateSet: { idx, set in updateSet(for: ex, at: idx, with: set) },
                            onDeleteSet: { idx in deleteSet(for: ex, at: idx) }
                        )
                    }
                }
                .padding(.bottom, 4)
                .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
    }
}
