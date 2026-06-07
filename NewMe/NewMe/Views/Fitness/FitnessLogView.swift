import SwiftUI
import SwiftData

struct FitnessLogView: View {
    let activeDate: Date

    @Environment(\.modelContext) private var context
    @Query(sort: [SortDescriptor(\ExerciseItem.sortOrder), SortDescriptor(\ExerciseItem.name)])
    private var exercises: [ExerciseItem]
    @Query private var allEntries: [FitnessLogEntry]
    @Query private var allSessions: [WorkoutSession]

    @State private var openExerciseID: PersistentIdentifier?
    @State private var openGroups: Set<String> = []
    @State private var didInit = false
    @State private var showExercisePicker = false

    // MARK: — Session

    private var session: WorkoutSession? {
        allSessions.first { Calendar.current.isDate($0.date, inSameDayAs: activeDate) }
    }

    private func startSession() {
        let s = WorkoutSession(date: activeDate)
        context.insert(s)
        try? context.save()
    }

    // MARK: — Exercise groups

    private struct ExGroup: Identifiable {
        let id: String
        let exercises: [ExerciseItem]
    }

    private var groups: [ExGroup] {
        var bucket: [String: [ExerciseItem]] = [:]
        var order: [String] = []
        for ex in exercises {
            let key = ex.kind == .cardio ? "Kardiyo" : ex.muscleGroup
            if bucket[key] == nil { bucket[key] = []; order.append(key) }
            bucket[key]?.append(ex)
        }
        return order.map { ExGroup(id: $0, exercises: bucket[$0] ?? []) }
    }

    private var entriesByExercise: [PersistentIdentifier: FitnessLogEntry] {
        var map: [PersistentIdentifier: FitnessLogEntry] = [:]
        for entry in allEntries where Calendar.current.isDate(entry.date, inSameDayAs: activeDate) {
            if let id = entry.exercise?.persistentModelID { map[id] = entry }
        }
        return map
    }

    private func entryFor(_ ex: ExerciseItem) -> FitnessLogEntry? {
        entriesByExercise[ex.persistentModelID]
    }

    private func setsToday(in group: ExGroup) -> Int {
        group.exercises.reduce(0) { $0 + (entryFor($1)?.sets.count ?? 0) }
    }

    private var totalSets: Int { entriesByExercise.values.reduce(0) { $0 + $1.sets.count } }
    private var totalVolume: Double { entriesByExercise.values.reduce(0) { $0 + $1.volume } }
    private var movementCount: Int { entriesByExercise.values.filter { !$0.sets.isEmpty }.count }

    // MARK: — Set CRUD

    private func ensureEntry(_ ex: ExerciseItem) -> FitnessLogEntry {
        if let e = entryFor(ex) { return e }
        let e = FitnessLogEntry(date: activeDate, exercise: ex, session: session)
        context.insert(e)
        return e
    }

    private func addSet(_ ex: ExerciseItem) {
        if session == nil { startSession() }
        let entry = ensureEntry(ex)
        let last = entry.sets.last
        switch ex.kind {
        case .weight:     entry.sets.append(SetData(reps: last?.reps ?? 8, kg: last?.kg ?? 20))
        case .bodyweight: entry.sets.append(SetData(reps: last?.reps ?? 10))
        case .cardio:     entry.sets.append(SetData(minutes: last?.minutes ?? 10))
        }
        try? context.save()
    }

    private func updateSet(_ ex: ExerciseItem, at index: Int, with set: SetData) {
        guard let entry = entryFor(ex), entry.sets.indices.contains(index) else { return }
        if entry.sets[index] != set { entry.sets[index] = set; try? context.save() }
    }

    private func deleteSet(_ ex: ExerciseItem, at index: Int) {
        guard let entry = entryFor(ex), entry.sets.indices.contains(index) else { return }
        entry.sets.remove(at: index)
        if entry.sets.isEmpty { context.delete(entry) }
        try? context.save()
    }

    private func toggleGroup(_ id: String) {
        withAnimation(.spring(response: 0.28, dampingFraction: 0.85)) {
            if openGroups.contains(id) { openGroups.remove(id) } else { openGroups.insert(id) }
        }
    }

    // MARK: — Summary section (extracted to help type-checker)

    @ViewBuilder
    private var summarySection: some View {
        if totalSets > 0 {
            Section { statsRow }
        } else {
            Section {
                emptyState
                    .listRowBackground(Color.clear)
                    .listRowInsets(EdgeInsets())
            }
        }
    }

    @ViewBuilder
    private func groupSection(_ group: ExGroup) -> some View {
        let isOpen = openGroups.contains(group.id)
        let groupSets = setsToday(in: group)
        Section {
            if isOpen {
                ForEach(group.exercises) { ex in
                    exerciseRow(ex)
                }
            }
        } header: {
            groupHeader(group, isOpen: isOpen, setCount: groupSets)
        }
    }

    @ViewBuilder
    private func exerciseRow(_ ex: ExerciseItem) -> some View {
        ExerciseCard(
            exercise: ex,
            entry: entryFor(ex),
            recentSessions: ExerciseSessionSummary.makeRecent(for: ex, from: allEntries, activeDate: activeDate),
            isOpen: openExerciseID == ex.persistentModelID,
            onToggleOpen: { openExerciseID = openExerciseID == ex.persistentModelID ? nil : ex.persistentModelID },
            onAddSet:    { addSet(ex) },
            onUpdateSet: { idx, set in updateSet(ex, at: idx, with: set) },
            onDeleteSet: { idx in deleteSet(ex, at: idx) }
        )
        .listRowInsets(EdgeInsets(top: 4, leading: 16, bottom: 4, trailing: 16))
        .listRowBackground(Color.clear)
    }

    private func groupHeader(_ group: ExGroup, isOpen: Bool, setCount: Int) -> some View {
        Button { toggleGroup(group.id) } label: {
            HStack {
                Image(systemName: isOpen ? "chevron.down" : "chevron.right")
                    .font(.caption.weight(.semibold))
                    .frame(width: 14)
                Text(group.id)
                    .font(.footnote.weight(.semibold))
                Text("\(group.exercises.count)")
                    .font(.caption2)
                    .padding(.horizontal, 5)
                    .padding(.vertical, 1)
                    .background(Capsule().fill(.quaternary))
                Spacer()
                if setCount > 0 {
                    Text("\(setCount) set")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(Color.accentColor)
                }
            }
            .foregroundStyle(.primary)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }

    // MARK: — Body

    var body: some View {
        List {
            summarySection

            // Muscle group sections
            ForEach(groups) { group in
                groupSection(group)
            }
        }
        .listStyle(.insetGrouped)
        .navigationTitle("Antrenman")
        .navigationBarTitleDisplayMode(.large)
        .onAppear {
            guard !didInit else { return }
            didInit = true
            for g in groups where setsToday(in: g) > 0 {
                openGroups.insert(g.id)
            }
        }
        .onChange(of: activeDate) { _, _ in
            openGroups.removeAll()
            openExerciseID = nil
            for g in groups where setsToday(in: g) > 0 {
                openGroups.insert(g.id)
            }
        }
    }

    // MARK: — Sub-views

    private var statsRow: some View {
        HStack(spacing: 0) {
            statCell(label: "Set", value: "\(totalSets)")
            Divider().frame(height: 36)
            statCell(label: "Hacim", value: "\(Int(totalVolume.rounded()))kg")
            Divider().frame(height: 36)
            statCell(label: "Hareket", value: "\(movementCount)")
            if let s = session, s.durationMinutes > 0 {
                Divider().frame(height: 36)
                statCell(label: "Süre", value: "\(s.durationMinutes)dk")
            }
        }
    }

    private func statCell(label: String, value: String) -> some View {
        VStack(spacing: 2) {
            Text(value)
                .font(.headline)
                .monospacedDigit()
            Text(label)
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
    }

    private var emptyState: some View {
        VStack(spacing: 12) {
            Image(systemName: "dumbbell")
                .font(.system(size: 40))
                .foregroundStyle(.secondary)
            Text("Antrenman başlatmak için bir egzersiz ekle")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 32)
    }
}
