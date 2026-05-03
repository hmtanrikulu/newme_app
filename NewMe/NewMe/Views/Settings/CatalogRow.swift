import SwiftUI

struct CatalogRow: View {
    let title: String
    let subtitle: String
    let onRemove: () -> Void

    var body: some View {
        HStack(spacing: 10) {
            Button(action: onRemove) {
                ZStack {
                    Circle().fill(AppColor.danger).frame(width: 22, height: 22)
                    Rectangle().fill(.white).frame(width: 10, height: 2)
                }
            }
            .buttonStyle(.plain)

            VStack(alignment: .leading, spacing: 1) {
                Text(title)
                    .font(.system(size: 15, weight: .medium))
                    .foregroundStyle(AppColor.textPrimary)
                Text(subtitle)
                    .font(.system(size: 12))
                    .foregroundStyle(AppColor.text2)
                    .lineLimit(1)
            }
            Spacer(minLength: 0)
            Image(systemName: "line.3.horizontal")
                .font(.system(size: 13))
                .foregroundStyle(Color.white.opacity(0.3))
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 11)
        .background(
            RoundedRectangle(cornerRadius: 12).fill(AppColor.surface)
        )
    }
}

struct AddRowButton: View {
    let label: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack {
                Text(label)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(AppColor.gold)
                Spacer()
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(AppColor.gold.opacity(0.12))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(style: StrokeStyle(lineWidth: 1, dash: [3, 3]))
                            .foregroundStyle(AppColor.gold.opacity(0.4))
                    )
            )
        }
        .buttonStyle(.plain)
    }
}
