import SwiftUI

/// Card-styled row for the Settings catalog lists.
/// Delete + drag handles come from the parent List's edit mode (no custom
/// affordances inside the row itself, so the native red dash on the left
/// and the three-line drag handle on the right show up in their standard
/// iOS positions).
struct CatalogRow: View {
    let title: String
    let subtitle: String

    var body: some View {
        VStack(alignment: .leading, spacing: 1) {
            Text(title)
                .font(.system(size: 15, weight: .medium))
                .foregroundStyle(AppColor.textPrimary)
            Text(subtitle)
                .font(.system(size: 12))
                .foregroundStyle(AppColor.text2)
                .lineLimit(1)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
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
