import Foundation
import SwiftData

enum SpendCategory: String, CaseIterable, Identifiable, Codable {
    case food           = "food"
    case fuel           = "fuel"
    case market         = "market"
    case clothing       = "cloth"
    case entertainment  = "entertainment"
    case other          = "other"

    var id: String { rawValue }

    var label: String {
        switch self {
        case .food:          return "Yiyecek & İçecek"
        case .fuel:          return "Yakıt"
        case .market:        return "Market"
        case .clothing:      return "Kıyafet"
        case .entertainment: return "Eğlence"
        case .other:         return "Diğer"
        }
    }

    var systemImage: String {
        switch self {
        case .food:          return "fork.knife"
        case .fuel:          return "fuelpump.fill"
        case .market:        return "cart.fill"
        case .clothing:      return "tshirt.fill"
        case .entertainment: return "sparkles"
        case .other:         return "ellipsis"
        }
    }
}

@Model
final class SpendLogEntry {
    var date: Date = Date()
    var timestamp: Date = Date()
    var categoryRaw: String = SpendCategory.other.rawValue
    var amount: Double = 0

    var category: SpendCategory {
        get { SpendCategory(rawValue: categoryRaw) ?? .other }
        set { categoryRaw = newValue.rawValue }
    }

    init(date: Date = Date(), category: SpendCategory, amount: Double) {
        self.timestamp = date
        self.date = Calendar.current.startOfDay(for: date)
        self.categoryRaw = category.rawValue
        self.amount = amount
    }
}
