import Foundation

enum BarcodeLookupService {
    struct Result {
        var name: String
        var kcalPer100g: Double
        var proteinPer100g: Double
        var carbsPer100g: Double
        var fatPer100g: Double
    }

    enum LookupError: LocalizedError {
        case notFound
        case networkError(Error)

        var errorDescription: String? {
            switch self {
            case .notFound:             return "Ürün bulunamadı"
            case .networkError(let e):  return "Ağ hatası: \(e.localizedDescription)"
            }
        }
    }

    static func lookup(barcode: String) async throws -> Result {
        let urlString = "https://world.openfoodfacts.org/api/v0/product/\(barcode).json"
        guard let url = URL(string: urlString) else { throw URLError(.badURL) }

        var request = URLRequest(url: url)
        request.setValue("NewMeApp/1.0", forHTTPHeaderField: "User-Agent")
        request.timeoutInterval = 10

        let data: Data
        do {
            (data, _) = try await URLSession.shared.data(for: request)
        } catch {
            throw LookupError.networkError(error)
        }

        guard
            let root = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
            let status = root["status"] as? Int, status == 1,
            let product = root["product"] as? [String: Any]
        else {
            throw LookupError.notFound
        }

        let name = (product["product_name"] as? String)
            ?? (product["product_name_tr"] as? String)
            ?? "Bilinmiyor"

        let n = product["nutriments"] as? [String: Any] ?? [:]

        func val(_ keys: String...) -> Double {
            for k in keys { if let v = n[k] as? Double { return v } }
            return 0
        }

        return Result(
            name: name,
            kcalPer100g:    val("energy-kcal_100g", "energy_100g"),
            proteinPer100g: val("proteins_100g"),
            carbsPer100g:   val("carbohydrates_100g"),
            fatPer100g:     val("fat_100g")
        )
    }
}
