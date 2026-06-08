import Foundation

struct ParsedFoodItem: Identifiable {
    var id = UUID()
    var name: String
    var gram: Double
    var kcal: Double
    var protein: Double
    var carbs: Double
    var fat: Double
}

extension ParsedFoodItem: Decodable {
    enum CodingKeys: String, CodingKey {
        case name, gram, kcal, protein, carbs, fat
    }

    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        id      = UUID()
        name    = (try? c.decode(String.self, forKey: .name)) ?? "Bilinmiyor"
        gram    = (try? c.decode(Double.self, forKey: .gram)) ?? 100
        kcal    = (try? c.decode(Double.self, forKey: .kcal)) ?? 0
        protein = (try? c.decode(Double.self, forKey: .protein)) ?? 0
        carbs   = (try? c.decode(Double.self, forKey: .carbs)) ?? 0
        fat     = (try? c.decode(Double.self, forKey: .fat)) ?? 0
    }
}
