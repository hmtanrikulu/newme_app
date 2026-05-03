import SwiftUI
import SwiftData

struct FoodCatalogTab: View {
    @Environment(\.modelContext) private var context
    @Query(sort: [SortDescriptor(\FoodItem.sortOrder), SortDescriptor(\FoodItem.name)])
    private var foods: [FoodItem]

    @State private var presentingNew = false

    var body: some View {
        List {
            Section {
                ForEach(foods) { food in
                    CatalogRow(title: food.name, subtitle: subtitle(for: food))
                        .listRowBackground(Color.clear)
                        .listRowSeparator(.hidden)
                        .listRowInsets(EdgeInsets(top: 3, leading: 16, bottom: 3, trailing: 16))
                }
                .onMove(perform: move)
                .onDelete(perform: delete)

                AddRowButton(label: "+ Yiyecek Ekle") { presentingNew = true }
                    .listRowBackground(Color.clear)
                    .listRowSeparator(.hidden)
                    .listRowInsets(EdgeInsets(top: 6, leading: 16, bottom: 8, trailing: 16))
                    .moveDisabled(true)
                    .deleteDisabled(true)
            } header: {
                Text("YİYECEKLER")
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
            FoodEditorSheet(initial: nil) { draft in
                let nextOrder = (foods.map(\.sortOrder).max() ?? -1) + 1
                let food = FoodItem(
                    name: draft.name,
                    kcalPerServing: draft.kcal,
                    protein: draft.protein,
                    carbs: draft.carbs,
                    fat: draft.fat,
                    unit: draft.unit,
                    servingSize: draft.servingSize,
                    sortOrder: nextOrder
                )
                context.insert(food)
                try? context.save()
            }
            .presentationDetents([.large])
        }
    }

    private func subtitle(for food: FoodItem) -> String {
        let kcal = Int(food.kcalPerServing.rounded())
        let p = trim(food.protein), c = trim(food.carbs), f = trim(food.fat)
        return "\(kcal) kcal · \(p)P / \(c)K / \(f)Y"
    }

    private func trim(_ v: Double) -> String {
        v == v.rounded() ? "\(Int(v))" : String(format: "%.1f", v)
    }

    private func delete(at offsets: IndexSet) {
        for index in offsets {
            context.delete(foods[index])
        }
        try? context.save()
    }

    private func move(from source: IndexSet, to destination: Int) {
        var arr = foods
        arr.move(fromOffsets: source, toOffset: destination)
        for (idx, item) in arr.enumerated() {
            item.sortOrder = idx
        }
        try? context.save()
    }
}
