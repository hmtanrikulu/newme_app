import SwiftUI
import SwiftData

struct ExerciseCatalogTab: View {
    @Environment(\.modelContext) private var context
    @Query(sort: [SortDescriptor(\ExerciseItem.sortOrder), SortDescriptor(\ExerciseItem.name)])
    private var exercises: [ExerciseItem]

    @State private var presentingNew = false
    @State private var editingExercise: ExerciseItem?

    var body: some View {
        List {
            Section {
                ForEach(exercises) { ex in
                    CatalogRow(title: ex.name, subtitle: subtitle(for: ex))
                        .contentShape(Rectangle())
                        .onTapGesture { editingExercise = ex }
                        .listRowBackground(Color.clear)
                        .listRowSeparator(.hidden)
                        .listRowInsets(EdgeInsets(top: 3, leading: 16, bottom: 3, trailing: 16))
                }
                .onMove(perform: move)
                .onDelete(perform: delete)

                AddRowButton(label: "+ Egzersiz Ekle") { presentingNew = true }
                    .listRowBackground(Color.clear)
                    .listRowSeparator(.hidden)
                    .listRowInsets(EdgeInsets(top: 6, leading: 16, bottom: 8, trailing: 16))
                    .moveDisabled(true)
                    .deleteDisabled(true)
            } header: {
                Text("EGZERSİZLER")
                    .font(.system(size: 11, weight: .heavy))
                    .tracking(1)
                    .foregroundStyle(AppColor.text3)
                    .listRowInsets(EdgeInsets(top: 8, leading: 22, bottom: 4, trailing: 16))
            }
        }
        .listStyle(.plain)
        .scrollContentBackground(.hidden)
        .environment(\.editMode, .constant(.active))
        .sheet(isPresented: $presentingNew) {
            ExerciseEditorSheet(initial: nil) { draft in
                let nextOrder = (exercises.map(\.sortOrder).max() ?? -1) + 1
                let ex = ExerciseItem(
                    name: draft.name,
                    muscleGroup: draft.kind.hasMuscleGroup ? draft.muscleGroup : "—",
                    kind: draft.kind,
                    sortOrder: nextOrder
                )
                context.insert(ex)
                try? context.save()
            }
            .presentationDetents([.medium, .large])
        }
        .sheet(item: $editingExercise) { ex in
            ExerciseEditorSheet(initial: draft(from: ex), existingLogCount: ex.logEntries?.count ?? 0) { draft in
                let kindChanged = draft.kind != ex.kind
                if kindChanged, let entries = ex.logEntries {
                    // Old SetData fields would no longer match the new kind's
                    // semantics — clear logs to keep history clean.
                    for entry in entries {
                        context.delete(entry)
                    }
                }
                ex.name = draft.name
                ex.kind = draft.kind
                ex.muscleGroup = draft.kind.hasMuscleGroup ? draft.muscleGroup : "—"
                try? context.save()
            }
            .presentationDetents([.medium, .large])
        }
    }

    private func draft(from ex: ExerciseItem) -> ExerciseDraft {
        ExerciseDraft(
            name: ex.name,
            muscleGroup: ex.kind.hasMuscleGroup ? ex.muscleGroup : "Göğüs",
            kind: ex.kind
        )
    }

    private func subtitle(for ex: ExerciseItem) -> String {
        ex.kind.hasMuscleGroup
            ? "\(ex.kind.label) · \(ex.muscleGroup)"
            : ex.kind.label
    }

    private func delete(at offsets: IndexSet) {
        for index in offsets {
            context.delete(exercises[index])
        }
        try? context.save()
    }

    private func move(from source: IndexSet, to destination: Int) {
        var arr = exercises
        arr.move(fromOffsets: source, toOffset: destination)
        for (idx, item) in arr.enumerated() {
            item.sortOrder = idx
        }
        try? context.save()
    }
}

struct ExerciseDraft {
    var name: String = ""
    var muscleGroup: String = "Göğüs"
    var kind: ExerciseKind = .weight
}

struct ExerciseEditorSheet: View {
    let initial: ExerciseDraft?
    let existingLogCount: Int
    let onSave: (ExerciseDraft) -> Void

    @Environment(\.dismiss) private var dismiss
    @State private var draft: ExerciseDraft
    @State private var confirmKindChange = false

    private let groups = ["Göğüs", "Sırt", "Bacak", "Omuz", "Kol", "Core", "Diğer"]

    init(initial: ExerciseDraft?, existingLogCount: Int = 0, onSave: @escaping (ExerciseDraft) -> Void) {
        self.initial = initial
        self.existingLogCount = existingLogCount
        self.onSave = onSave
        _draft = State(initialValue: initial ?? ExerciseDraft())
    }

    private var canSave: Bool {
        !draft.name.trimmingCharacters(in: .whitespaces).isEmpty
    }

    private var kindChanged: Bool {
        guard let initial else { return false }
        return draft.kind != initial.kind
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Hareket") {
                    TextField("İsim (örn. Bench Press)", text: $draft.name)
                    Picker("Tür", selection: $draft.kind) {
                        ForEach(ExerciseKind.allCases) { kind in
                            Label(kind.label, systemImage: kind.systemImage).tag(kind)
                        }
                    }
                    if draft.kind.hasMuscleGroup {
                        Picker("Kas grubu", selection: $draft.muscleGroup) {
                            ForEach(groups, id: \.self) { Text($0).tag($0) }
                        }
                    }
                }
                Section {
                    Text(hintText)
                        .font(.system(size: 12))
                        .foregroundStyle(AppColor.text2)
                }
                if kindChanged && existingLogCount > 0 {
                    Section {
                        Label(
                            "Tür değişikliği ile bu hareketin \(existingLogCount) eski kaydı silinecek.",
                            systemImage: "exclamationmark.triangle.fill"
                        )
                        .font(.system(size: 12))
                        .foregroundStyle(.orange)
                    }
                }
            }
            .scrollContentBackground(.hidden)
            .background(AppColor.bg)
            .navigationTitle(initial == nil ? "Yeni Hareket" : "Hareket")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("İptal") { dismiss() }.foregroundStyle(AppColor.gold)
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Kaydet") {
                        if kindChanged && existingLogCount > 0 {
                            confirmKindChange = true
                        } else {
                            onSave(draft)
                            dismiss()
                        }
                    }
                    .foregroundStyle(canSave ? AppColor.gold : .gray)
                    .disabled(!canSave)
                }
            }
            .confirmationDialog(
                "Tür değişikliği eski log'ları silecek",
                isPresented: $confirmKindChange,
                titleVisibility: .visible
            ) {
                Button("Sil ve kaydet", role: .destructive) {
                    onSave(draft)
                    dismiss()
                }
                Button("İptal", role: .cancel) { }
            } message: {
                Text("Bu hareketin \(existingLogCount) eski kaydı yeni tür ile uyuşmadığı için silinecek.")
            }
        }
    }

    private var hintText: String {
        switch draft.kind {
        case .weight:     return "Her set için ağırlık (kg) ve tekrar sayısı girilir."
        case .bodyweight: return "Her set için yalnızca tekrar sayısı girilir."
        case .cardio:     return "Her set için süre (dakika) girilir."
        }
    }
}
