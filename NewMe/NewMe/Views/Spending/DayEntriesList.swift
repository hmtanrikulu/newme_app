import SwiftUI

struct DayEntriesList: View {
    let entries: [SpendLogEntry]
    let onTapEntry: (SpendLogEntry) -> Void
    let onDelete: (SpendLogEntry) -> Void

    var body: some View {
        Group {
            if entries.isEmpty {
                emptyState
            } else {
                ScrollView {
                    LazyVStack(spacing: 4) {
                        ForEach(entries) { entry in
                            EntryRow(
                                entry: entry,
                                onTap: { onTapEntry(entry) },
                                onDelete: { onDelete(entry) }
                            )
                        }
                    }
                    .padding(.vertical, 2)
                }
            }
        }
        .frame(height: 110)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.white.opacity(0.02))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.white.opacity(0.05), lineWidth: 1)
                )
        )
    }

    private var emptyState: some View {
        Text("Henüz kayıt yok")
            .font(.system(size: 12))
            .foregroundStyle(AppColor.text3)
            .frame(maxWidth: .infinity, alignment: .center)
    }
}

private struct EntryRow: View {
    let entry: SpendLogEntry
    let onTap: () -> Void
    let onDelete: () -> Void

    private var timeString: String {
        let f = DateFormatter()
        f.locale = Locale(identifier: "tr_TR")
        f.dateFormat = "HH:mm"
        return f.string(from: entry.timestamp)
    }

    private var amountString: String {
        DateFormatters.lira.string(from: NSNumber(value: entry.amount)) ?? "₺0"
    }

    var body: some View {
        HStack(spacing: 0) {
            Button(action: onTap) {
                HStack(spacing: 10) {
                    Image(systemName: entry.category.systemImage)
                        .font(.system(size: 13))
                        .foregroundStyle(AppColor.text2)
                        .frame(width: 22, height: 22)
                    Text(entry.category.label)
                        .font(.system(size: 12))
                        .foregroundStyle(AppColor.text2)
                    Spacer(minLength: 4)
                    Text(amountString)
                        .font(.system(size: 14, weight: .semibold))
                        .monospacedDigit()
                        .foregroundStyle(AppColor.textPrimary)
                    Text(timeString)
                        .font(.system(size: 11))
                        .monospacedDigit()
                        .foregroundStyle(AppColor.text3)
                        .frame(width: 38, alignment: .trailing)
                }
                .padding(.horizontal, 10)
                .padding(.vertical, 7)
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)

            Button(action: onDelete) {
                Image(systemName: "trash")
                    .font(.system(size: 12))
                    .foregroundStyle(AppColor.danger.opacity(0.8))
                    .frame(width: 30, height: 30)
                    .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
        }
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(Color.white.opacity(0.03))
        )
        .padding(.horizontal, 6)
    }
}
