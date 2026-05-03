import SwiftUI

enum SettingsTab: String, CaseIterable, Identifiable {
    case food, exercise, goals
    var id: String { rawValue }

    var label: String {
        switch self {
        case .food:     return "Yiyecek"
        case .exercise: return "Egzersiz"
        case .goals:    return "Hedefler"
        }
    }
}

struct SettingsTabPicker: View {
    @Binding var selection: SettingsTab

    var body: some View {
        HStack(spacing: 6) {
            ForEach(SettingsTab.allCases) { tab in
                Button {
                    selection = tab
                } label: {
                    Text(tab.label)
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundStyle(selection == tab ? AppColor.gold : AppColor.textPrimary)
                        .frame(maxWidth: .infinity)
                        .frame(height: 32)
                        .background(
                            RoundedRectangle(cornerRadius: 10)
                                .fill(selection == tab ? AppColor.gold.opacity(0.2) : Color.white.opacity(0.05))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 10)
                                        .stroke(selection == tab ? AppColor.gold.opacity(0.5) : Color.clear,
                                                lineWidth: 1)
                                )
                        )
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.horizontal, 16)
        .padding(.top, 12)
        .padding(.bottom, 8)
    }
}
