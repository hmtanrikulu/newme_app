import Foundation
import SwiftData

enum SpendCategory: String, CaseIterable, Identifiable, Codable {
    case food, drink, fun, cloth, market, other
    var id: String { rawValue }

    var label: String {
        switch self {
        case .food:   return "Yemek"
        case .drink:  return "İçecek"
        case .fun:    return "Eğlence"
        case .cloth:  return "Kıyafet"
        case .market: return "Market"
        case .other:  return "Diğer"
        }
    }
}

@Model
final class SpendLogEntry {
    var date: Date = Date()           // normalized to startOfDay
    var timestamp: Date = Date()      // exact entry time
    var categoryRaw: String = SpendCategory.other.rawValue
    var amount: Double = 0

    var category: SpendCategory {
        get { SpendCategory(rawValue: categoryRaw) ?? .other }
        set { categoryRaw = newValue.rawValue }
    }

    init(date: Date = Date(), category: SpendCategory, amount: Double) {
        let now = date
        self.timestamp = now
        self.date = Calendar.current.startOfDay(for: now)
        self.categoryRaw = category.rawValue
        self.amount = amount
    }
}
