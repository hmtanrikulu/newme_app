import SwiftUI
import SwiftData

struct GoalsTab: View {
    @Environment(\.modelContext) private var context
    @Query private var goalsRows: [UserGoals]
    @State private var geminiKey: String = GeminiService.apiKey

    private var goals: UserGoals {
        if let existing = goalsRows.first { return existing }
        let new = UserGoals()
        context.insert(new)
        try? context.save()
        return new
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 14) {
                GoalRow(label: "Günlük kalori",        unit: "kcal", value: goals.kcal,            step: 50, prefix: false, tone: nil)              { goals.kcal = $0; save() }
                GoalRow(label: "Protein hedefi",       unit: "g",    value: goals.protein,         step: 5,  prefix: false, tone: AppColor.macroProt) { goals.protein = $0; save() }
                GoalRow(label: "Karbonhidrat hedefi",  unit: "g",    value: goals.carbs,           step: 5,  prefix: false, tone: AppColor.macroCarb) { goals.carbs = $0; save() }
                GoalRow(label: "Yağ hedefi",           unit: "g",    value: goals.fat,             step: 5,  prefix: false, tone: AppColor.macroFat)  { goals.fat = $0; save() }

                Rectangle().fill(Color.white.opacity(0.08)).frame(height: 1).padding(.vertical, 4)

                GoalRow(label: "Günlük harcama limiti", unit: "₺",  value: goals.dailySpendLimit, step: 100, prefix: true,  tone: AppColor.gold)     { goals.dailySpendLimit = $0; save() }

                Rectangle().fill(Color.white.opacity(0.08)).frame(height: 1).padding(.vertical, 4)

                VStack(alignment: .leading, spacing: 8) {
                    Label("Gemini API Anahtarı", systemImage: "sparkles")
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(.secondary)
                    SecureField("API anahtarını gir…", text: $geminiKey)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()
                        .padding(.horizontal, 14)
                        .padding(.vertical, 10)
                        .background(Color.white.opacity(0.07), in: RoundedRectangle(cornerRadius: 12))
                        .onChange(of: geminiKey) { _, new in
                            GeminiService.apiKey = new
                        }
                    Text("AI ile yemek girişi için gerekli. Google AI Studio'dan ücretsiz alınabilir.")
                        .font(.caption2)
                        .foregroundStyle(.tertiary)
                }
                .padding(.horizontal, 2)
            }
            .padding(.horizontal, 16)
            .padding(.top, 8)
            .padding(.bottom, 30)
        }
    }

    private func save() {
        try? context.save()
    }
}

private struct GoalRow: View {
    let label: String
    let unit: String
    let value: Int
    let step: Int
    let prefix: Bool
    let tone: Color?
    let onChange: (Int) -> Void

    private var formatted: String {
        let n = NSNumber(value: value)
        let f = NumberFormatter()
        f.locale = Locale(identifier: "tr_TR")
        f.numberStyle = .decimal
        let body = f.string(from: n) ?? "\(value)"
        return prefix ? "\(unit)\(body)" : "\(body) \(unit)"
    }

    var body: some View {
        VStack(spacing: 8) {
            HStack(spacing: 8) {
                if let tone {
                    Circle().fill(tone).frame(width: 6, height: 6)
                }
                Text(label)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundStyle(AppColor.textPrimary)
                Spacer()
                Text(formatted)
                    .font(.system(size: 16, weight: .semibold))
                    .monospacedDigit()
                    .foregroundStyle(AppColor.gold)
            }
            HStack(spacing: 8) {
                StepButton(symbol: "minus") { onChange(max(0, value - step)) }
                StepButton(symbol: "plus")  { onChange(value + step) }
            }
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 14)
                .fill(AppColor.surface)
                .overlay(
                    RoundedRectangle(cornerRadius: 14)
                        .stroke(Color.white.opacity(0.06), lineWidth: 1)
                )
        )
    }
}

private struct StepButton: View {
    let symbol: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Image(systemName: symbol)
                .font(.system(size: 14, weight: .medium))
                .foregroundStyle(AppColor.textPrimary)
                .frame(maxWidth: .infinity)
                .frame(height: 32)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color.white.opacity(0.05))
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color.white.opacity(0.08), lineWidth: 1)
                        )
                )
        }
        .buttonStyle(.plain)
    }
}
