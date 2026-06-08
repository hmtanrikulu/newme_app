import Foundation

enum GeminiService {
    private static let model = "gemini-2.0-flash-lite"

    static var apiKey: String {
        get { UserDefaults.standard.string(forKey: "gemini.apiKey") ?? "" }
        set { UserDefaults.standard.set(newValue, forKey: "gemini.apiKey") }
    }

    enum ServiceError: LocalizedError {
        case missingKey
        case rateLimited
        case badResponse(Int)
        case emptyResponse
        case parseError(String)

        var errorDescription: String? {
            switch self {
            case .missingKey:            return "API anahtarı eksik — Ayarlar → Hedefler'den Gemini API anahtarını gir."
            case .rateLimited:           return "İstek limiti aşıldı — birkaç saniye beklenip tekrar deneniyor…"
            case .badResponse(let code): return "API hatası: \(code)"
            case .emptyResponse:         return "Boş yanıt geldi"
            case .parseError(let msg):   return "Ayrıştırma hatası: \(msg)"
            }
        }
    }

    // Attempts the call up to maxRetries times, backing off on 429.
    static func parseFood(_ description: String, maxRetries: Int = 3) async throws -> [ParsedFoodItem] {
        guard !apiKey.isEmpty else { throw ServiceError.missingKey }

        var lastError: Error = ServiceError.emptyResponse
        for attempt in 0..<maxRetries {
            do {
                return try await _parseFood(description)
            } catch ServiceError.rateLimited {
                lastError = ServiceError.rateLimited
                // Exponential backoff: 2s, 4s, 8s
                let delay = UInt64(pow(2.0, Double(attempt + 1))) * 1_000_000_000
                try? await Task.sleep(nanoseconds: delay)
            } catch {
                throw error
            }
        }
        throw lastError
    }

    private static func _parseFood(_ description: String) async throws -> [ParsedFoodItem] {
        let urlString = "https://generativelanguage.googleapis.com/v1beta/models/\(model):generateContent?key=\(apiKey)"
        guard let url = URL(string: urlString) else { throw URLError(.badURL) }

        let prompt = """
        Aşağıdaki Türkçe yemek açıklamasını analiz et. Her yiyecek/içecek için besin değerlerini hesapla.

        Açıklama: "\(description)"

        Yanıt olarak SADECE şu JSON formatını kullan, başka hiçbir şey yazma:
        {"items":[{"name":"Yiyecek Adı","gram":100,"kcal":200,"protein":10,"carbs":25,"fat":5}]}

        Kurallar:
        - name: Türkçe yiyecek adı
        - gram: tahmini gram (belirtilmemişse tipik porsiyon)
        - kcal/protein/carbs/fat: standart USDA veya Türk gıda veritabanı değerleri
        - Sadece JSON döndür
        """

        let body: [String: Any] = [
            "contents": [["parts": [["text": prompt]]]],
            "generationConfig": [
                "responseMimeType": "application/json",
                "temperature": 0.1
            ]
        ]

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try JSONSerialization.data(withJSONObject: body)
        request.timeoutInterval = 20

        let (data, response) = try await URLSession.shared.data(for: request)

        if let http = response as? HTTPURLResponse {
            if http.statusCode == 429 { throw ServiceError.rateLimited }
            if http.statusCode != 200 { throw ServiceError.badResponse(http.statusCode) }
        }

        guard
            let root = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
            let candidates = root["candidates"] as? [[String: Any]],
            let content = candidates.first?["content"] as? [String: Any],
            let parts = content["parts"] as? [[String: Any]],
            let text = parts.first?["text"] as? String
        else {
            throw ServiceError.emptyResponse
        }

        guard let jsonData = text.data(using: .utf8) else {
            throw ServiceError.parseError("Metin UTF-8 değil")
        }

        do {
            struct Wrapper: Decodable { let items: [ParsedFoodItem] }
            let wrapper = try JSONDecoder().decode(Wrapper.self, from: jsonData)
            return wrapper.items
        } catch {
            throw ServiceError.parseError(error.localizedDescription)
        }
    }
}
