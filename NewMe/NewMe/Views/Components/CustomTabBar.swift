import SwiftUI

enum AppTab: String, CaseIterable, Identifiable {
    case food, fit, spend
    var id: String { rawValue }

    var label: String {
        switch self {
        case .food:  return "Yemek"
        case .fit:   return "Fitness"
        case .spend: return "Harcama"
        }
    }

    var systemImage: String {
        switch self {
        case .food:  return "fork.knife"
        case .fit:   return "dumbbell.fill"
        case .spend: return "turkishlirasign.circle"
        }
    }
}

struct CustomTabBar: View {
    @Binding var selection: AppTab

    var body: some View {
        HStack(spacing: 0) {
            ForEach(AppTab.allCases) { tab in
                TabButton(tab: tab, active: tab == selection) {
                    selection = tab
                }
            }
        }
        .padding(.bottom, 14)
        .frame(height: 64)
        .background(
            Color(white: 0.08).opacity(0.85)
                .background(.ultraThinMaterial)
                .overlay(
                    Rectangle()
                        .fill(AppColor.hairline)
                        .frame(height: 0.5),
                    alignment: .top
                )
        )
    }
}

private struct TabButton: View {
    let tab: AppTab
    let active: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 2) {
                Image(systemName: tab.systemImage)
                    .font(.system(size: 22, weight: .regular))
                Text(tab.label)
                    .font(.system(size: 10, weight: .semibold))
            }
            .foregroundStyle(active ? AppColor.gold : Color.white.opacity(0.45))
            .padding(.top, 6)
            .frame(maxWidth: .infinity)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}
