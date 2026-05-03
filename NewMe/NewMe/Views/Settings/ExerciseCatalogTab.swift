import SwiftUI
import SwiftData

struct ExerciseCatalogTab: View {
    @Environment(\.modelContext) private var context
    @Query(sort: [SortDescriptor(\ExerciseItem.sortOrder), SortDescriptor(\ExerciseItem.name)])
    private var exercises: [ExerciseItem]

    @State private var presentingNew = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 6) {
                Text("EGZERSİZLER")
                    .font(.system(size: 11, weight: .heavy))
                    .tracking(1)
                    .foregroundStyle(AppColor.text3)
                    .padding(.horizontal, 6)
                    .padding(.top, 8)
                    .padding(.bottom, 2)

                ForEach(exercises) { ex in
                    CatalogRow(
                        title: ex.name,
                        subtitle: ex.muscleGroup,
                        onRemove: { remove(ex) }
                    )
                }

                AddRowButton(label: "+ Egzersiz Ekle") { presentingNew = true }
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 30)
        }
        .sheet(isPresented: $presentingNew) {
            ExerciseEditorSheet(initial: nil) { draft in
                let nextOrder = (exercises.map(\.sortOrder).max() ?? -1) + 1
                let ex = ExerciseItem(name: draft.name, muscleGroup: draft.muscleGroup, sortOrder: nextOrder)
                context.insert(ex)
                try? context.save()
            }
            .presentationDetents([.medium, .large])
        }
    }

    private func remove(_ ex: ExerciseItem) {
        context.delete(ex)
        try? context.save()
    }
}

struct ExerciseDraft {
    var name: String = ""
    var muscleGroup: String = "Göğüs"
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
                    Picker("Kas grubu", selection: $draft.muscleGroup) {
                        ForEach(groups, id: \.self) { Text($0).tag($0) }
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
                    Button("Kaydet") { onSave(draft); dismiss() }
                        .foregroundStyle(canSave ? AppColor.gold : .gray)
                        .disabled(!canSave)
                }
            }
        }
    }
}
