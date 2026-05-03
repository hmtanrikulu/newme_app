import SwiftUI

struct DaySummaryCard: View {
    let day: DayRollup
    let isToday: Bool
    let onOpenForEditing: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(alignment: .firstTextBaseline) {
                Text(DateFormatters.dateLabel.string(from: day.date))
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(AppColor.textPrimary)
                Spacer()
                if isToday {
                    Text("Bugün")
                        .font(.system(size: 12))
                        .foregroundStyle(AppColor.text3)
                }
            }
            .padding(.bottom, 10)

            Row(systemImage: "fork.knife",
                text: "\(Int(day.kcal.rounded())) kcal · \(Int(day.protein.rounded()))g protein")
            Row(systemImage: "dumbbell.fill",
                text: day.totalSets == 0
                    ? "antrenman yok"
                    : day.setsByGroup
                        .sorted { $0.key < $1.key }
                        .map { "\($0.key.lowercased()): \($0.value) set" }
                        .joined(separator: " · "))
            Row(systemImage: "turkishlirasign",
                text: day.totalSpend == 0
                    ? "harcama yok"
                    : day.spendByCategory
                        .sorted { $0.key.label < $1.key.label }
                        .map { "\($0.key.label): ₺\(Int($0.value.rounded()))" }
                        .joined(separator: " · "))

            Button(action: onOpenForEditing) {
                HStack(spacing: 6) {
                    Image(systemName: "square.and.pencil")
                        .font(.system(size: 12, weight: .semibold))
                    Text(day.hasAnyData ? "Bu günü düzenle" : "Bu güne ekle")
                        .font(.system(size: 13, weight: .semibold))
                }
                .foregroundStyle(AppColor.gold)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 10)
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .fill(AppColor.gold.opacity(0.12))
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(AppColor.gold.opacity(0.4), lineWidth: 1)
                        )
                )
            }
            .buttonStyle(.plain)
            .padding(.top, 12)
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

private struct Row: View {
    let systemImage: String
    let text: String

    var body: some View {
        HStack(alignment: .top, spacing: 8) {
            Image(systemName: systemImage)
                .font(.system(size: 12))
                .foregroundStyle(AppColor.text2)
                .frame(width: 16, alignment: .center)
                .padding(.top, 2)
            Text(text)
                .font(.system(size: 13))
                .foregroundStyle(AppColor.text2)
                .lineLimit(2)
        }
        .padding(.vertical, 4)
    }
}
