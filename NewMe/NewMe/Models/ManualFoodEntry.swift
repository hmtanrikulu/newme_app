import Foundation
import SwiftData

@Model
final class ManualFoodEntry {
    var date: Date = Date()
    var protein: Double = 0
    var carbs: Double = 0
    var fat: Double = 0

    init(date: Date, protein: Double = 0, carbs: Double = 0, fat: Double = 0) {
        self.date = Calendar.current.startOfDay(for: date)
        self.protein = protein
        self.carbs = carbs
        self.fat = fat
    }

    var kcal: Double { protein * 4 + carbs * 4 + fat * 9 }
}
