import SwiftUI
import SwiftData

struct ExerciseCatalogTab: View {
    @Environment(\.modelContext) private var context
    @Query(sort: [SortDescriptor(\ExerciseItem.sortOrder), SortDescriptor(\ExerciseItem.name)])
    private var exercises: [ExerciseItem]

    @State private var presentingNew = false

    var body: some View {
        List {
            Section {
                ForEach(exercises) { ex in
                    CatalogRow(title: ex.name, subtitle: subtitle(for: ex))
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
    let onSave: (ExerciseDraft) -> Void

    @Environment(\.dismiss) private var dismiss
    @State private var draft: ExerciseDraft

    private let groups = ["Göğüs", "Sırt", "Bacak", "Omuz", "Kol", "Core", "Diğer"]

    init(initial: ExerciseDraft?, onSave: @escaping (ExerciseDraft) -> Void) {
        self.initial = initial
        self.onSave = onSave
        _draft = State(initialValue: initial ?? ExerciseDraft())
    }

    private var canSave: Bool {
        !draft.name.trimmingCharacters(in: .whitespaces).isEmpty
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
                    Button("Kaydet") { onSave(draft); dismiss() }
                        .foregroundStyle(canSave ? AppColor.gold : .gray)
                        .disabled(!canSave)
                }
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
