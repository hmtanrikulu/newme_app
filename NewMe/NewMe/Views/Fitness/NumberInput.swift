import SwiftUI

/// Tiny inline numeric editor: tap, type, blur or Enter to commit.
struct NumberInput: View {
    @Binding var value: Double
    var decimals: Int = 0
    var suffix: String? = nil

    @State private var text: String = ""
    @FocusState private var focused: Bool

    private func format(_ v: Double) -> String {
        decimals > 0 ? String(format: "%.\(decimals)f", v) : String(Int(v.rounded()))
    }

    var body: some View {
        HStack(spacing: 1) {
            TextField("", text: $text)
                .keyboardType(decimals > 0 ? .decimalPad : .numberPad)
                .multilineTextAlignment(.center)
                .font(.system(size: 14, weight: .semibold))
                .monospacedDigit()
                .foregroundStyle(AppColor.textPrimary)
                .focused($focused)
                .onAppear { text = format(value) }
                .onChange(of: value) { _, newValue in
                    if !focused { text = format(newValue) }
                }
                .onChange(of: focused) { _, isFocused in
                    if !isFocused { commit() }
                }
                .submitLabel(.done)
                .onSubmit { focused = false }
                .frame(height: 28)
            if let suffix {
                Text(suffix)
                    .font(.system(size: 9))
                    .foregroundStyle(AppColor.text3)
            }
        }
        .padding(.horizontal, 6)
        .frame(height: 30)
        .background(
            RoundedRectangle(cornerRadius: 6)
                .fill(Color.white.opacity(0.05))
                .overlay(
                    RoundedRectangle(cornerRadius: 6)
                        .stroke(Color.white.opacity(0.10), lineWidth: 1)
                )
        )
    }

    private func commit() {
        let normalized = text.replacingOccurrences(of: ",", with: ".")
        if let parsed = Double(normalized) {
            value = parsed
        }
        text = format(value)
    }
}
