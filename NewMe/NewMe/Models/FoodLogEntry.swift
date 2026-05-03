import Foundation
import SwiftData

@Model
final class FoodLogEntry {
    var date: Date = Date()           // normalized to startOfDay
    var quantity: Int = 0
    var item: FoodItem?

    init(date: Date, quantity: Int, item: FoodItem?) {
        self.date = Calendar.current.startOfDay(for: date)
        self.quantity = quantity
        self.item = item
    }
}
