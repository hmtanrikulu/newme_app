import Foundation
import SwiftData

@Model
final class FoodItem {
    var name: String = ""
    // Macros are stored "per 100 g" (canonical reference, regardless of unit).
    var kcalPerServing: Double = 0
    var protein: Double = 0
    var carbs: Double = 0
    var fat: Double = 0
    var unit: String = "g"           // "g", "adet", "dilim", "ml"
    // Grams represented by 1 unit. For "g"/"ml" this is 1; for "adet"/"dilim" the user sets it.
    var gramsPerUnit: Double = 1
    var servingSize: Double = 1      // number of `unit` per logged portion
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
        gramsPerUnit: Double = 1,
        servingSize: Double = 1,
        sortOrder: Int = 0
    ) {
        self.name = name
        self.kcalPerServing = kcalPerServing
        self.protein = protein
        self.carbs = carbs
        self.fat = fat
        self.unit = unit
        self.gramsPerUnit = gramsPerUnit
        self.servingSize = servingSize
        self.sortOrder = sortOrder
    }

    /// Grams represented by one logged portion (servingSize × gramsPerUnit).
    var portionGrams: Double { servingSize * gramsPerUnit }
    /// Scale factor that converts a per-100g macro value into per-portion.
    var portionFactor: Double { portionGrams / 100 }

    var kcalPerPortion: Double { kcalPerServing * portionFactor }
    var proteinPerPortion: Double { protein * portionFactor }
    var carbsPerPortion: Double { carbs * portionFactor }
    var fatPerPortion: Double { fat * portionFactor }
}
