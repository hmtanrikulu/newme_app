import SwiftUI

struct FoodRow: View {
    let food: FoodItem
    let quantity: Int
    let onIncrement: () -> Void
    let onDecrement: () -> Void

    private var servedAmount: String {
        let s = Double(quantity) * food.servingSize
        if s == s.rounded() {
            return "\(Int(s))"
        } else {
            return String(format: "%.1f", s)
        }
    }

    private var kcalForQty: Int {
        Int((Double(quantity) * food.kcalPerPortion).rounded())
    }

    var body: some View {
        HStack(spacing: 10) {
            VStack(alignment: .leading, spacing: 3) {
                Text(food.name)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundStyle(AppColor.textPrimary)
                Text("\(servedAmount) \(food.unit) · \(kcalForQty) kcal")
                    .font(.system(size: 12))
                    .monospacedDigit()
                    .foregroundStyle(AppColor.text2)
            }
            Spacer(minLength: 0)

            QtyButton(symbol: "minus", filled: false, action: onDecrement)
                .disabled(quantity == 0)
                .opacity(quantity == 0 ? 0.4 : 1)

            Text("\(quantity)")
                .font(.system(size: 17, weight: .medium))
                .monospacedDigit()
                .foregroundStyle(AppColor.textPrimary)
                .frame(width: 26)

            QtyButton(symbol: "plus", filled: true, action: onIncrement)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 14).fill(AppColor.surface)
        )
    }
}

private struct QtyButton: View {
    let symbol: String
    let filled: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Image(systemName: symbol)
                .font(.system(size: 11, weight: .semibold))
                .foregroundStyle(filled ? Color.white.opacity(0.85) : Color.white.opacity(0.6))
                .frame(width: 30, height: 30)
                .background(
                    Circle()
                        .fill(filled ? AppColor.goldDim : Color.white.opacity(0.06))
                        .overlay(
                            Circle().stroke(
                                filled ? AppColor.gold.opacity(0.4) : Color.white.opacity(0.08),
                                lineWidth: 1
                            )
                        )
                )
        }
        .buttonStyle(.plain)
    }
}
