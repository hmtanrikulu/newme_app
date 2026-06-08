import SwiftUI

struct CategoryGrid: View {
    @Binding var selection: SpendCategory

    private let columns = Array(repeating: GridItem(.flexible(), spacing: 8), count: 3)

    var body: some View {
        LazyVGrid(columns: columns, spacing: 8) {
            ForEach(SpendCategory.allCases) { cat in
                CategoryTile(category: cat, selected: cat == selection) {
                    selection = cat
                }
            }
        }
    }
}

private struct CategoryTile: View {
    let category: SpendCategory
    let selected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 6) {
                Image(systemName: category.systemImage)
                    .font(.system(size: 22, weight: .regular))
                Text(category.label)
                    .font(.system(size: 13, weight: .semibold))
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .foregroundStyle(selected ? Color.black : AppColor.textPrimary)
            .background(
                RoundedRectangle(cornerRadius: 14)
                    .fill(selected ? AppColor.gold : AppColor.surface)
                    .overlay(
                        RoundedRectangle(cornerRadius: 14)
                            .stroke(
                                selected ? Color.clear : Color(UIColor.systemFill),
                                lineWidth: 1
                            )
                    )
            )
        }
        .buttonStyle(.plain)
    }
}
