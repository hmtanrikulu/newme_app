import Foundation

enum USDAService {
    static var apiKey: String {
        get { UserDefaults.standard.string(forKey: "usda.apiKey") ?? "DEMO_KEY" }
        set { UserDefaults.standard.set(newValue, forKey: "usda.apiKey") }
    }

    struct FoodResult {
        var fdcId: Int
        var name: String
        var kcalPer100g: Double
        var proteinPer100g: Double
        var carbsPer100g: Double
        var fatPer100g: Double
    }

    enum ServiceError: LocalizedError {
        case notFound(String)
        case badResponse(Int)
        case networkError

        var errorDescription: String? {
            switch self {
            case .notFound(let q): return "USDA'da bulunamadı: \(q)"
            case .badResponse(let code): return "USDA API hatası: \(code)"
            case .networkError: return "İnternet bağlantısı gerekli"
            }
        }
    }

    // Search by English food name, return best Foundation/SR Legacy match
    static func search(query: String) async throws -> FoodResult {
        var comps = URLComponents(string: "https://api.nal.usda.gov/fdc/v1/foods/search")!
        comps.queryItems = [
            URLQueryItem(name: "query", value: query),
            URLQueryItem(name: "dataType", value: "Foundation,SR Legacy"),
            URLQueryItem(name: "pageSize", value: "1"),
            URLQueryItem(name: "api_key", value: apiKey)
        ]
        guard let url = comps.url else { throw URLError(.badURL) }

        let (data, response) = try await URLSession.shared.data(from: url)
        if let http = response as? HTTPURLResponse, http.statusCode != 200 {
            throw ServiceError.badResponse(http.statusCode)
        }

        guard
            let root = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
            let foods = root["foods"] as? [[String: Any]],
            let first = foods.first
        else {
            throw ServiceError.notFound(query)
        }

        let name = first["description"] as? String ?? query
        let fdcId = first["fdcId"] as? Int ?? 0
        let nutrients = first["foodNutrients"] as? [[String: Any]] ?? []

        // nutrientId: 1008=energy(kcal), 1003=protein, 1005=carbs, 1004=fat
        func nutrient(id: Int) -> Double {
            nutrients.first { ($0["nutrientId"] as? Int) == id }.flatMap { $0["value"] as? Double } ?? 0
        }

        return FoodResult(
            fdcId: fdcId,
            name: name,
            kcalPer100g: nutrient(id: 1008),
            proteinPer100g: nutrient(id: 1003),
            carbsPer100g: nutrient(id: 1005),
            fatPer100g: nutrient(id: 1004)
        )
    }

    // Enrich (name, gram) pairs → [ParsedFoodItem] with verified macros
    // Falls back to zero macros if USDA returns nothing for a given item
    static func enrich(_ items: [(name: String, gram: Double)]) async throws -> [ParsedFoodItem] {
        try await withThrowingTaskGroup(of: ParsedFoodItem.self) { group in
            for item in items {
                group.addTask {
                    do {
                        let result = try await search(query: item.name)
                        let m = item.gram / 100.0
                        return ParsedFoodItem(
                            name: result.name,
                            gram: item.gram,
                            kcal: result.kcalPer100g * m,
                            protein: result.proteinPer100g * m,
                            carbs: result.carbsPer100g * m,
                            fat: result.fatPer100g * m,
                            source: .usda
                        )
                    } catch {
                        // USDA miss → return item with zero macros flagged as estimated
                        return ParsedFoodItem(
                            name: item.name,
                            gram: item.gram,
                            kcal: 0, protein: 0, carbs: 0, fat: 0,
                            source: .estimated
                        )
                    }
                }
            }

            var results: [ParsedFoodItem] = []
            for try await item in group { results.append(item) }
            // Restore original order
            let nameOrder = items.map(\.name)
            return results.sorted { a, b in
                let ai = nameOrder.firstIndex(where: { $0.caseInsensitiveCompare(a.name) == .orderedSame }) ?? 0
                let bi = nameOrder.firstIndex(where: { $0.caseInsensitiveCompare(b.name) == .orderedSame }) ?? 0
                return ai < bi
            }
        }
    }
}
