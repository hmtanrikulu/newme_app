import Foundation
import LLM

// On-device LLM for food NLP extraction.
// Model: Qwen2.5-0.5B-Instruct Q4_K_M (~340MB GGUF)
// Role: Turkish text → [{name: "english name", gram: 100}]
// Macros always come from USDA FDC (USDAService.enrich), never from this model.

// @unchecked Sendable: LLM (ObservableObject class) crosses concurrency boundaries;
// access is serialised by callers (single-inflight request pattern in AITab).
final class LocalLLMService: @unchecked Sendable {
    static let shared = LocalLLMService()
    private init() {}

    // MARK: — Model config

    static let modelFilename  = "qwen2.5-0.5b-instruct-q4_k_m.gguf"
    static let modelRemoteURL = URL(string:
        "https://huggingface.co/Qwen/Qwen2.5-0.5B-Instruct-GGUF/resolve/main/qwen2.5-0.5b-instruct-q4_k_m.gguf"
    )!

    var localModelURL: URL {
        let support = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask)[0]
        return support.appendingPathComponent(Self.modelFilename)
    }

    var isModelDownloaded: Bool {
        FileManager.default.fileExists(atPath: localModelURL.path)
    }

    // MARK: — Errors

    enum ServiceError: LocalizedError {
        case modelNotDownloaded
        case modelLoadFailed
        case parseError(String)

        var errorDescription: String? {
            switch self {
            case .modelNotDownloaded: return "Model henüz indirilmedi"
            case .modelLoadFailed:    return "Model yüklenemedi"
            case .parseError(let m):  return "Ayrıştırma hatası: \(m)"
            }
        }
    }

    // MARK: — State

    private var llm: LLM?

    // MARK: — Download (streaming, reports progress 0→1)

    func downloadModel(progress: @Sendable @escaping (Double) -> Void) async throws {
        let dest = localModelURL
        try FileManager.default.createDirectory(
            at: dest.deletingLastPathComponent(),
            withIntermediateDirectories: true
        )

        var observation: NSKeyValueObservation?
        let tempURL: URL = try await withCheckedThrowingContinuation { continuation in
            let task = URLSession.shared.downloadTask(with: Self.modelRemoteURL) { url, _, error in
                if let error { return continuation.resume(throwing: error) }
                guard let url else { return continuation.resume(throwing: ServiceError.modelLoadFailed) }
                continuation.resume(returning: url)
            }
            observation = task.progress.observe(\.fractionCompleted) { p, _ in
                progress(p.fractionCompleted)
            }
            task.resume()
        }
        _ = observation
        // Move from temp location to permanent app support path
        if FileManager.default.fileExists(atPath: dest.path) {
            try FileManager.default.removeItem(at: dest)
        }
        try FileManager.default.moveItem(at: tempURL, to: dest)
        progress(1.0)
    }

    // MARK: — Load model into memory

    func loadModel() async throws {
        guard llm == nil else { return }

        let url = localModelURL
        // LLM.init is synchronous + blocking — run on a detached background task
        let loaded: LLM? = await Task.detached(priority: .userInitiated) {
            LLM(
                from: url,
                stopSequence: "<|im_end|>",  // stop token for ChatML / Qwen2.5
                maxTokenCount: 512            // enough for our tiny JSON output
            )
        }.value

        guard let loaded else { throw ServiceError.modelLoadFailed }
        llm = loaded
    }

    // MARK: — NLP extraction (same contract as GeminiService.extractFoods)

    func extractFoods(_ description: String) async throws -> [(name: String, gram: Double)] {
        guard isModelDownloaded else { throw ServiceError.modelNotDownloaded }
        try await loadModel()
        guard let llm else { throw ServiceError.modelLoadFailed }

        // Format as ChatML so Qwen2.5-Instruct follows the instruction correctly
        let chatInput = """
        <|im_start|>system
        You extract food items from Turkish text. Output ONLY valid JSON with no explanation.
        <|im_end|>
        <|im_start|>user
        Extract food items and gram weights from this text: "\(description)"

        Output format (JSON only):
        {"items":[{"name":"english food name","gram":100}]}

        Rules: name=English generic (e.g. "plain yogurt"), gram=convert if needed (1 scoop≈31g, 1 egg≈50g)
        <|im_end|>
        <|im_start|>assistant
        """

        // getCompletion returns the full accumulated output string
        let output = await llm.getCompletion(from: chatInput)
        return try parseResponse(output)
    }

    // MARK: — Robust JSON parser (strips any preamble the model might add)

    private func parseResponse(_ raw: String) throws -> [(name: String, gram: Double)] {
        guard
            let start = raw.firstIndex(of: "{"),
            let end   = raw.lastIndex(of: "}")
        else {
            throw ServiceError.parseError("JSON bulunamadı: \(raw.prefix(120))")
        }

        let jsonString = String(raw[start...end])
        guard let data = jsonString.data(using: .utf8) else {
            throw ServiceError.parseError("UTF-8 encode başarısız")
        }

        struct Item: Decodable { let name: String; let gram: Double }
        struct Wrapper: Decodable { let items: [Item] }
        let wrapper = try JSONDecoder().decode(Wrapper.self, from: data)
        return wrapper.items.map { (name: $0.name, gram: $0.gram) }
    }

    // MARK: — Unload (free ~340MB when not needed)

    func unload() { llm = nil }
}
