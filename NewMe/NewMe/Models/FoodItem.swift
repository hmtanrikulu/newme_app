import Foundation
import SwiftData

@Model
final class FoodItem {
    var name: String = ""
    var kcalPerServing: Double = 0
    var protein: Double = 0
    var carbs: Double = 0
    var fat: Double = 0
    var unit: String = "g"           // "g", "adet", "dilim", "ml"
    var servingSize: Double = 1
    var sortOrder: Int = 0

    @Relationship(deleteRule: .cascade, inverse: \FoodLogEntry.item)
    var logEntries: [FoodLogEntry]? = []

    init(
        name: String,
        kcalPerServing: Double,
        protein: Double = 0,
        carbs: Double = 0,
        fat: Double = 0,
        unit: String = "g",
        servingSize: Double = 1,
        sortOrder: Int = 0
    ) {
        self.name = name
        self.kcalPerServing = kcalPerServing
        self.protein = protein
        self.carbs = carbs
        self.fat = fat
        self.unit = unit
        self.servingSize = servingSize
        self.sortOrder = sortOrder
    }
}
