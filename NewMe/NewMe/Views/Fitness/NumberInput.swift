import SwiftUI

/// Tiny inline numeric editor with **eager** commit: every valid keystroke
/// writes the parsed text straight back into the binding, so backgrounding
/// the app (e.g. switching to another app while the keyboard is open),
/// collapsing a parent card, or switching tabs can never strand a typed
/// value in local @State. Blur only re-formats the displayed text.
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
                // Eager write-through: parse on every keystroke and update
                // the binding immediately. Empty / partial input (e.g. ".",
                // "abc") fails the parse and leaves the previous value
                // intact, so the field is always representing a valid
                // number the moment the app loses focus.
                .onChange(of: text) { _, newValue in
                    let normalized = newValue.replacingOccurrences(of: ",", with: ".")
                    if let parsed = Double(normalized), parsed != value {
                        value = parsed
                    }
                }
                // External value changes (parent re-init, addSet defaults,
                // CloudKit pull) should reformat the field — but only when
                // the user isn't actively typing, otherwise we'd clobber
                // their input.
                .onChange(of: value) { _, newValue in
                    if !focused { text = format(newValue) }
                }
                // Re-canonicalize text on blur ("1." → "1", "1.50" → "1.5").
                .onChange(of: focused) { _, isFocused in
                    if !isFocused { text = format(value) }
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
}
