import Foundation

enum MealType: String, CaseIterable, Identifiable, Codable {
    case breakfast, lunch, dinner, snack

    var id: String { rawValue }

    var label: String {
        switch self {
        case .breakfast: return "Kahvaltı"
        case .lunch:     return "Öğle"
        case .dinner:    return "Akşam"
        case .snack:     return "Atıştırmalık"
        }
    }

    var systemImage: String {
        switch self {
        case .breakfast: return "sun.rise.fill"
        case .lunch:     return "sun.max.fill"
        case .dinner:    return "moon.fill"
        case .snack:     return "takeoutbag.and.cup.and.straw.fill"
        }
    }

    /// Infer meal type from the current hour.
    static func current() -> MealType {
        let hour = Calendar.current.component(.hour, from: .now)
        switch hour {
        case 5..<11:  return .breakfast
        case 11..<15: return .lunch
        case 15..<18: return .snack
        default:      return .dinner
        }
    }
}
