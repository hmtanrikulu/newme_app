import SwiftUI
import SwiftData

struct FoodCatalogTab: View {
    @Environment(\.modelContext) private var context
    @Query(sort: [SortDescriptor(\FoodItem.sortOrder), SortDescriptor(\FoodItem.name)])
    private var foods: [FoodItem]

    @State private var presentingNew = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 6) {
                Text("YİYECEKLER")
                    .font(.system(size: 11, weight: .heavy))
                    .tracking(1)
                    .foregroundStyle(AppColor.text3)
                    .padding(.horizontal, 6)
                    .padding(.top, 8)
                    .padding(.bottom, 2)

                ForEach(foods) { food in
                    CatalogRow(
                        title: food.name,
                        subtitle: subtitle(for: food),
                        onRemove: { remove(food) }
                    )
                }

                AddRowButton(label: "+ Yiyecek Ekle") { presentingNew = true }
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 30)
        }
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

    private func remove(_ food: FoodItem) {
        context.delete(food)
        try? context.save()
    }
}
