import SwiftUI
import SwiftData

struct UniversalLogSheet: View {
    let onOpenFood: () -> Void
    let onOpenFitness: () -> Void
    let onOpenSpend: () -> Void

    @Query(sort: \FoodLogEntry.date, order: .reverse) private var foodEntries: [FoodLogEntry]
    @Query(sort: \FitnessLogEntry.date, order: .reverse) private var fitnessEntries: [FitnessLogEntry]
    @Query(sort: \SpendLogEntry.timestamp, order: .reverse) private var spendEntries: [SpendLogEntry]

    @Environment(\.dismiss) private var dismiss

    private var recentFoods: [FoodItem] {
        var seen = Set<PersistentIdentifier>()
        var result: [FoodItem] = []
        for entry in foodEntries {
            guard let item = entry.item else { continue }
            if seen.insert(item.persistentModelID).inserted {
                result.append(item)
                if result.count == 3 { break }
            }
        }
        return result
    }

    private var recentExercises: [ExerciseItem] {
        var seen = Set<PersistentIdentifier>()
        var result: [ExerciseItem] = []
        for entry in fitnessEntries {
            guard let ex = entry.exercise else { continue }
            if seen.insert(ex.persistentModelID).inserted {
                result.append(ex)
                if result.count == 2 { break }
            }
        }
        return result
    }

    private var recentSpend: [SpendLogEntry] {
        Array(spendEntries.prefix(2))
    }

    var body: some View {
        NavigationStack {
            ZStack {
                AppColor.bg.ignoresSafeArea()
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 24) {
                        domainButtons
                        if !recentFoods.isEmpty || !recentExercises.isEmpty || !recentSpend.isEmpty {
                            recentSection
                        }
                        Spacer(minLength: 40)
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 20)
                }
            }
            .navigationTitle("Ne eklemek istersin?")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Kapat") { dismiss() }
                        .foregroundStyle(AppColor.gold)
                }
            }
            .toolbarBackground(AppColor.bg, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
        }
        .preferredColorScheme(.dark)
        .presentationDetents([.medium])
        .presentationDragIndicator(.visible)
    }

    private var domainButtons: some View {
        HStack(spacing: 12) {
            logDomainButton(icon: "fork.knife", label: "Yemek", color: AppColor.gold) {
                dismiss()
                onOpenFood()
            }
            logDomainButton(icon: "dumbbell.fill", label: "Antrenman", color: AppColor.success) {
                dismiss()
                onOpenFitness()
            }
            logDomainButton(icon: "turkishlirasign.circle.fill", label: "Harcama", color: AppColor.info) {
                dismiss()
                onOpenSpend()
            }
        }
    }

    private func logDomainButton(icon: String, label: String, color: Color, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            VStack(spacing: 10) {
                Image(systemName: icon)
                    .font(.system(size: 26, weight: .medium))
                    .foregroundStyle(color)
                    .frame(width: 56, height: 56)
                    .background(RoundedRectangle(cornerRadius: 16).fill(color.opacity(0.12)))
                Text(label)
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(AppColor.text2)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(RoundedRectangle(cornerRadius: 16).fill(AppColor.surface))
        }
        .buttonStyle(.plain)
    }

    private var recentSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("SON KULLANILANLAR")
                .font(.system(size: 11, weight: .heavy))
                .tracking(1.2)
                .foregroundStyle(AppColor.text3)
                .padding(.horizontal, 4)

            VStack(spacing: 6) {
                ForEach(recentFoods) { food in
                    recentRow(
                        icon: "fork.knife",
                        color: AppColor.gold,
                        title: food.name,
                        detail: "\(Int(food.kcalPerPortion.rounded())) kcal / porsiyon",
                        action: { dismiss(); onOpenFood() }
                    )
                }
                ForEach(recentExercises) { ex in
                    recentRow(
                        icon: "dumbbell.fill",
                        color: AppColor.success,
                        title: ex.name,
                        detail: ex.muscleGroup,
                        action: { dismiss(); onOpenFitness() }
                    )
                }
                ForEach(recentSpend) { entry in
                    recentRow(
                        icon: entry.category.systemImage,
                        color: AppColor.info,
                        title: entry.category.label,
                        detail: "₺\(Int(entry.amount))",
                        action: { dismiss(); onOpenSpend() }
                    )
                }
            }
        }
    }

    private func recentRow(icon: String, color: Color, title: String, detail: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: 12) {
                Image(systemName: icon)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(color)
                    .frame(width: 32, height: 32)
                    .background(Circle().fill(color.opacity(0.12)))
                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.system(size: 14, weight: .medium))
                        .foregroundStyle(AppColor.textPrimary)
                    Text(detail)
                        .font(.system(size: 12))
                        .foregroundStyle(AppColor.text3)
                }
                Spacer()
                Image(systemName: "arrow.up.right")
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundStyle(AppColor.text3)
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 10)
            .background(RoundedRectangle(cornerRadius: 12).fill(AppColor.surface))
        }
        .buttonStyle(.plain)
    }
}
