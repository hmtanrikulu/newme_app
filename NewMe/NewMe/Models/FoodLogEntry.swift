import Foundation
import SwiftData

@Model
final class FoodLogEntry {
    var date: Date = Date()           // normalized to startOfDay
    var loggedAt: Date = Date()       // exact insertion time (for meal grouping)
    var mealTypeRaw: String = MealType.breakfast.rawValue
    var quantity: Int = 0
    var item: FoodItem?

    // Manual entry fields — used when item == nil
    var manualName: String = ""
    var manualProtein: Double = 0
    var manualCarbs: Double = 0
    var manualFat: Double = 0

    var mealType: MealType {
        get { MealType(rawValue: mealTypeRaw) ?? .breakfast }
        set { mealTypeRaw = newValue.rawValue }
    }

    var isManual: Bool { item == nil }

    var kcal: Double {
        if let item { return Double(quantity) * item.kcalPerPortion }
        return manualProtein * 4 + manualCarbs * 4 + manualFat * 9
    }
    var protein: Double {
        if let item { return Double(quantity) * item.proteinPerPortion }
        return manualProtein
    }
    var carbs: Double {
        if let item { return Double(quantity) * item.carbsPerPortion }
        return manualCarbs
    }
    var fat: Double {
        if let item { return Double(quantity) * item.fatPerPortion }
        return manualFat
    }

    var displayName: String {
        item?.name ?? (manualName.isEmpty ? "Manuel" : manualName)
    }

    init(
        date: Date,
        mealType: MealType = MealType.current(),
        quantity: Int,
        item: FoodItem?
    ) {
        let now = Date()
        self.date = Calendar.current.startOfDay(for: date)
        self.loggedAt = now
        self.mealTypeRaw = mealType.rawValue
        self.quantity = quantity
        self.item = item
    }

    init(
        date: Date,
        mealType: MealType = MealType.current(),
        name: String,
        protein: Double,
        carbs: Double,
        fat: Double
    ) {
        let now = Date()
        self.date = Calendar.current.startOfDay(for: date)
        self.loggedAt = now
        self.mealTypeRaw = mealType.rawValue
        self.quantity = 1
        self.item = nil
        self.manualName = name
        self.manualProtein = protein
        self.manualCarbs = carbs
        self.manualFat = fat
    }
}
