import SwiftUI

enum KeypadKey: Hashable {
    case digit(String)
    case dot
    case delete
}

struct AmountKeypad: View {
    let onPress: (KeypadKey) -> Void

    private let rows: [[KeypadKey]] = [
        [.digit("1"), .digit("2"), .digit("3")],
        [.digit("4"), .digit("5"), .digit("6")],
        [.digit("7"), .digit("8"), .digit("9")],
        [.dot,         .digit("0"), .delete],
    ]

    var body: some View {
        VStack(spacing: 4) {
            ForEach(rows.indices, id: \.self) { row in
                HStack(spacing: 4) {
                    ForEach(rows[row].indices, id: \.self) { col in
                        keyView(for: rows[row][col])
                    }
                }
            }
        }
    }

    @ViewBuilder
    private func keyView(for key: KeypadKey) -> some View {
        Button {
            onPress(key)
        } label: {
            Group {
                switch key {
                case .digit(let s):
                    Text(s)
                        .font(.system(size: 24, weight: .regular))
                case .dot:
                    Text(".")
                        .font(.system(size: 24, weight: .regular))
                case .delete:
                    Image(systemName: "delete.left")
                        .font(.system(size: 18, weight: .regular))
                }
            }
            .foregroundStyle(AppColor.textPrimary)
            .frame(maxWidth: .infinity)
            .frame(height: 42)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}
