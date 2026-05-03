import Foundation
import SwiftData

@Model
final class UserGoals {
    var kcal: Int = 2400
    var protein: Int = 180
    var carbs: Int = 240
    var fat: Int = 80
    var dailySpendLimit: Int = 5000

    init(
        kcal: Int = 2400,
        protein: Int = 180,
        carbs: Int = 240,
        fat: Int = 80,
        dailySpendLimit: Int = 5000
    ) {
        self.kcal = kcal
        self.protein = protein
        self.carbs = carbs
        self.fat = fat
        self.dailySpendLimit = dailySpendLimit
    }
}
